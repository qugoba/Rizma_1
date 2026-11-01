const crypto = require('crypto');
const fs = require('fs');
const path = require('path');
const { publicKeyBase64 } = require('./keygen');

const root = path.resolve(__dirname, '../..');

const MAX_CORE = 20 * 1024 * 1024;
const MAX_VIDEO = 400 * 1024 * 1024;
const MAX_ATTACHMENT = 50 * 1024 * 1024;
const MAX_ATTACHMENTS = 20;
const ID = /^[a-z0-9]+(\.[a-z0-9]+)*$/;
const PATH = /^[a-z0-9_\-]+(\/[a-z0-9_\-]+)*\.[a-z0-9]+$/;
const CONTENT_FORMAT = 1;

const sha256 = (bytes) => crypto.createHash('sha256').update(bytes).digest('hex');

function parseArgs(argv) {
  const opts = {
    grade: null,
    key: null,
    out: path.join(root, 'build/content'),
    assets: path.join(root, 'assets/content'),
    media: path.join(root, 'content-media'),
    state: path.join(__dirname, 'published'),
    dryRun: false,
    now: null,
  };
  for (let i = 0; i < argv.length; i++) {
    const a = argv[i];
    const next = () => argv[++i];
    if (a === '--grade') opts.grade = Number(next());
    else if (a === '--key') opts.key = next();
    else if (a === '--out') opts.out = path.resolve(next());
    else if (a === '--assets') opts.assets = path.resolve(next());
    else if (a === '--media') opts.media = path.resolve(next());
    else if (a === '--state') opts.state = path.resolve(next());
    else if (a === '--now') opts.now = next();
    else if (a === '--dry-run') opts.dryRun = true;
    else throw new Error(`خيار غير معروف: ${a}`);
  }
  if (!Number.isInteger(opts.grade) || opts.grade < 1 || opts.grade > 12) {
    throw new Error('--grade مطلوب (1–12)');
  }
  if (!opts.dryRun && !opts.key) throw new Error('--key مطلوب (أو --dry-run)');
  return opts;
}

function mediaFor(mediaDir, lessonId) {
  const dir = path.join(mediaDir, lessonId);
  const files = {};
  let video = null;
  const attachments = [];
  if (!fs.existsSync(dir)) return { files, video, attachments };
  const walk = (d) => {
    for (const e of fs.readdirSync(d, { withFileTypes: true })) {
      const full = path.join(d, e.name);
      if (e.isDirectory()) walk(full);
      else {
        const rel = path.relative(dir, full).split(path.sep).join('/');
        if (rel === 'video.mp4') video = fs.readFileSync(full);
        else if (rel.startsWith('attachments/')) attachments.push(fs.readFileSync(full));
        else files[rel] = fs.readFileSync(full);
      }
    }
  };
  walk(dir);
  return { files, video, attachments };
}

function check(cond, msg) {
  if (!cond) throw new Error(msg);
}

function plan(opts) {
  const catalogPath = path.join(opts.assets, `catalog_grade${opts.grade}.json`);
  check(fs.existsSync(catalogPath), `لا كتالوج للصف ${opts.grade}: ${catalogPath}`);
  const catalogBytes = fs.readFileSync(catalogPath);
  const catalog = JSON.parse(catalogBytes.toString('utf8'));
  const lessonIds = [];
  for (const s of catalog.subjects) {
    for (const u of s.units) for (const l of u.lessons) lessonIds.push(l.id);
  }

  const statePath = path.join(opts.state, `grade${opts.grade}.manifest.json`);
  const previous = fs.existsSync(statePath)
    ? JSON.parse(fs.readFileSync(statePath, 'utf8'))
    : null;
  const prevLessons = new Map((previous?.lessons ?? []).map((l) => [l.id, l]));

  const blobs = new Map();
  const add = (bytes, max, what) => {
    check(bytes.length > 0 && bytes.length <= max, `${what}: الحجم ${bytes.length} خارج الحد`);
    const sha = sha256(bytes);
    blobs.set(sha, bytes);
    return { sha256: sha, size: bytes.length };
  };

  const lessons = [];
  const changes = [];
  for (const id of lessonIds) {
    const jsonPath = path.join(opts.assets, 'lessons', `${id}.json`);
    if (!fs.existsSync(jsonPath)) continue;
    check(ID.test(id), `معرّف درس غير صالح: ${id}`);
    const lessonJson = fs.readFileSync(jsonPath);
    const parsed = JSON.parse(lessonJson.toString('utf8'));
    check(parsed.lessonId === id, `${jsonPath}: lessonId لا يطابق اسم الملف`);

    const media = mediaFor(opts.media, id);
    const files = [{ path: 'lesson.json', ...add(lessonJson, MAX_CORE, `${id}/lesson.json`) }];
    for (const p of Object.keys(media.files).sort()) {
      check(PATH.test(p), `${id}: مسار غير صالح ${p}`);
      files.push({ path: p, ...add(media.files[p], MAX_CORE, `${id}/${p}`) });
    }
    const minutes = parsed.video?.minutes != null ? { minutes: parsed.video.minutes } : {};
    const declared = parsed.video?.file;
    let video = null;
    if (media.video) {
      video = { ...add(media.video, MAX_VIDEO, `${id}/video.mp4`), ...minutes };
      check(
        !declared || declared === video.sha256,
        `${id}: video.file في ملف الدرس (${declared}) لا يطابق بصمة content-media/${id}/video.mp4 (${video.sha256})`,
      );
    } else if (declared) {
      const prevVideo = prevLessons.get(id)?.video;
      check(
        prevVideo?.sha256 === declared,
        `${id}: الفيديو ${declared} غير موجود في content-media/${id}/ ولا في آخر فهرس منشور`,
      );
      video = { sha256: prevVideo.sha256, size: prevVideo.size, ...minutes };
    }

    const declaredAttachments = parsed.attachments ?? [];
    check(
      Array.isArray(declaredAttachments) && declaredAttachments.length <= MAX_ATTACHMENTS,
      `${id}: attachments يجب أن تكون قائمة (حتى ${MAX_ATTACHMENTS})`,
    );
    const localAttachments = new Map(
      media.attachments.map((bytes) => [sha256(bytes), bytes]),
    );
    const prevAttachments = new Map(
      (prevLessons.get(id)?.attachments ?? []).map((a) => [a.sha256, a]),
    );
    const attachments = declaredAttachments.map((a, i) => {
      check(
        typeof a.title === 'string' && a.title && typeof a.file === 'string',
        `${id}: المرفق ${i + 1} يحتاج title و file`,
      );
      let entry;
      const bytes = localAttachments.get(a.file);
      if (bytes) entry = add(bytes, MAX_ATTACHMENT, `${id}/attachments ${a.title}`);
      else {
        const p = prevAttachments.get(a.file);
        check(p, `${id}: المرفق «${a.title}» (${a.file}) غير موجود في content-media/${id}/attachments/ ولا في آخر فهرس منشور`);
        entry = { sha256: p.sha256, size: p.size };
      }
      const kb = Math.ceil(entry.size / 1024);
      check(a.sizeKb === kb, `${id}: sizeKb للمرفق «${a.title}» يجب أن يكون ${kb}`);
      return entry;
    });
    for (const sha of localAttachments.keys()) {
      check(
        declaredAttachments.some((a) => a.file === sha),
        `${id}: ملف في attachments/ لا يذكره ملف الدرس؛ أضفه بـ file: "${sha}"`,
      );
    }

    const signature = JSON.stringify({
      files,
      video: video?.sha256 ?? null,
      attachments: attachments.map((a) => a.sha256),
    });
    const prev = prevLessons.get(id);
    const prevSignature = prev
      ? JSON.stringify({
          files: prev.files,
          video: prev.video?.sha256 ?? null,
          attachments: (prev.attachments ?? []).map((a) => a.sha256),
        })
      : null;
    const version = !prev ? 1 : prevSignature === signature ? prev.version : prev.version + 1;
    if (version !== prev?.version) changes.push(`${id}: نسخة ${version}${prev ? '' : ' (جديد)'}`);

    lessons.push({
      id,
      version,
      content_format: CONTENT_FORMAT,
      files,
      ...(video ? { video } : {}),
      ...(attachments.length ? { attachments } : {}),
    });
  }
  for (const id of prevLessons.keys()) {
    if (!lessons.some((l) => l.id === id)) changes.push(`${id}: أُزيل من الفهرس`);
  }

  const catalogBlob = add(catalogBytes, MAX_CORE, 'catalog');
  if (previous?.catalog?.sha256 !== catalogBlob.sha256) changes.push('الكتالوج تغيّر');

  const manifest = {
    format: 1,
    grade: opts.grade,
    sequence: (previous?.sequence ?? 0) + 1,
    published_at: opts.now ?? new Date().toISOString().replace(/\.\d{3}Z$/, 'Z'),
    catalog: catalogBlob,
    lessons,
  };
  return { manifest, blobs, changes, statePath };
}

function publish(opts) {
  const { manifest, blobs, changes, statePath } = plan(opts);
  if (changes.length === 0) {
    console.log('لا جديد للنشر.');
    return 0;
  }
  const newBytes = [...blobs.entries()]
    .filter(([sha]) => !fs.existsSync(path.join(opts.out, 'v1/blobs', sha)))
    .reduce((n, [, b]) => n + b.length, 0);
  console.log(`الصف ${manifest.grade}، الفهرس رقم ${manifest.sequence}:`);
  for (const c of changes) console.log(`  - ${c}`);
  console.log(`  ملفات جديدة: ${(newBytes / 1024).toFixed(1)} KB`);
  if (opts.dryRun) {
    console.log('(تجربة فقط: لم يُكتب شيء)');
    return 0;
  }

  const body = Buffer.from(JSON.stringify(manifest, null, 1) + '\n', 'utf8');
  const key = crypto.createPrivateKey(fs.readFileSync(opts.key));
  const signature = crypto.sign(null, body, key);
  check(signature.length === 64, 'توقيع غير متوقع');
  check(crypto.verify(null, body, crypto.createPublicKey(key), signature), 'فشل فحص التوقيع');

  const blobDir = path.join(opts.out, 'v1/blobs');
  const gradeDir = path.join(opts.out, `v1/grades/${manifest.grade}`);
  fs.mkdirSync(blobDir, { recursive: true });
  fs.mkdirSync(gradeDir, { recursive: true });
  for (const [sha, bytes] of blobs) {
    const target = path.join(blobDir, sha);
    if (!fs.existsSync(target)) fs.writeFileSync(target, bytes);
  }
  fs.writeFileSync(path.join(gradeDir, 'manifest.json'), body);
  fs.writeFileSync(path.join(gradeDir, 'manifest.json.sig'), signature);

  fs.mkdirSync(path.dirname(statePath), { recursive: true });
  fs.writeFileSync(statePath, body);
  console.log(`كُتب في ${opts.out}`);
  console.log(`المفتاح العام المستعمل: ${publicKeyBase64(key)}`);
  console.log(`احفظ ${path.relative(root, statePath)} في المستودع بعد الرفع.`);
  return 0;
}

if (require.main === module) {
  try {
    process.exit(publish(parseArgs(process.argv.slice(2))));
  } catch (e) {
    console.error(`خطأ: ${e.message}`);
    process.exit(1);
  }
}

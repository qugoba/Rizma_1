const crypto = require('crypto');
const fs = require('fs');
const path = require('path');

const root = path.resolve(__dirname, '../..');

const sha256Hex = (data) => crypto.createHash('sha256').update(data).digest('hex');
const hmac = (key, data) => crypto.createHmac('sha256', key).update(data).digest();
const EMPTY_SHA = sha256Hex('');

const rfc3986 = (s) =>
  encodeURIComponent(s).replace(/[!'()*]/g, (c) => `%${c.charCodeAt(0).toString(16).toUpperCase()}`);

function canonicalQuery(query = {}) {
  return Object.keys(query)
    .sort()
    .map((k) => `${rfc3986(k)}=${rfc3986(String(query[k]))}`)
    .join('&');
}

function signV4({ method, host, pathname, query, headers, payloadHash, accessKeyId, secret, region, amzDate }) {
  const date = amzDate.slice(0, 8);
  const all = { host, 'x-amz-content-sha256': payloadHash, 'x-amz-date': amzDate, ...headers };
  const names = Object.keys(all).map((h) => h.toLowerCase()).sort();
  const lower = Object.fromEntries(Object.entries(all).map(([k, v]) => [k.toLowerCase(), String(v).trim()]));
  const canonicalUri = pathname.split('/').map(rfc3986).join('/');
  const canonical = [
    method,
    canonicalUri,
    canonicalQuery(query),
    names.map((n) => `${n}:${lower[n]}\n`).join(''),
    names.join(';'),
    payloadHash,
  ].join('\n');
  const scope = `${date}/${region}/s3/aws4_request`;
  const toSign = ['AWS4-HMAC-SHA256', amzDate, scope, sha256Hex(canonical)].join('\n');
  let key = hmac(`AWS4${secret}`, date);
  for (const part of [region, 's3', 'aws4_request']) key = hmac(key, part);
  const signature = crypto.createHmac('sha256', key).update(toSign).digest('hex');
  return {
    authorization: `AWS4-HMAC-SHA256 Credential=${accessKeyId}/${scope}, SignedHeaders=${names.join(';')}, Signature=${signature}`,
    headers: all,
    signature,
  };
}

function selfTest() {
  const { signature } = signV4({
    method: 'GET',
    host: 'examplebucket.s3.amazonaws.com',
    pathname: '/test.txt',
    headers: { range: 'bytes=0-9' },
    payloadHash: EMPTY_SHA,
    accessKeyId: 'AKIAIOSFODNN7EXAMPLE',
    secret: 'wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY',
    region: 'us-east-1',
    amzDate: '20130524T000000Z',
  });
  const expected = 'f0e8bdb87c964420e857bd35b5d6ed310bd44f0170aba48dd91039c6036bdb41';
  const withQuery = (query) =>
    signV4({
      method: 'GET',
      host: 'examplebucket.s3.amazonaws.com',
      pathname: '/',
      query,
      headers: {},
      payloadHash: EMPTY_SHA,
      accessKeyId: 'AKIAIOSFODNN7EXAMPLE',
      secret: 'wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY',
      region: 'us-east-1',
      amzDate: '20130524T000000Z',
    }).signature;
  const checks = [
    [signature, expected],
    [withQuery({ lifecycle: '' }), 'fea454ca298b7da1c68078a5d1bdbfbbe0d65c699e0f91ac7a200a0136783543'],
    [withQuery({ 'max-keys': 2, prefix: 'J' }), '34b48302e7b5fa45bde8084f4b7868a86f0a534bc59db6670ed5711ef69dc6f7'],
  ];
  for (const [got, want] of checks) {
    if (got !== want) {
      console.error(`فشل: ${got}`);
      return 1;
    }
  }
  console.log('التوقيع يطابق أمثلة AWS الموثّقة (3).');
  return 0;
}

function describe(e) {
  const c = e?.cause;
  const cause = c ? ` (${[c.code, c.name, c.message].filter(Boolean).join(': ')})` : '';
  return `${e?.message ?? e}${cause}`;
}

function client(bucket, stateDir) {
  const raw = {
    account: (process.env.R2_ACCOUNT_ID ?? '').trim(),
    accessKeyId: (process.env.R2_ACCESS_KEY_ID ?? '').trim(),
    secret: (process.env.R2_SECRET_ACCESS_KEY ?? '').trim(),
  };
  if (!raw.account || !raw.accessKeyId || !raw.secret) {
    throw new Error('اضبط R2_ACCOUNT_ID و R2_ACCESS_KEY_ID و R2_SECRET_ACCESS_KEY في الطرفية أولًا');
  }
  const account = /[0-9a-f]{32}/i.exec(raw.account)?.[0]?.toLowerCase();
  if (!account) throw new Error('Account ID غير صحيح: 32 حرفًا من 0–9 وa–f');
  const { accessKeyId, secret } = raw;
  if (accessKeyId.toLowerCase() === account) {
    throw new Error('Account ID وAccess Key ID متطابقان: يبدو أن قيمة وُضعت في الخانة الخطأ');
  }
  console.log(`  الحساب: ${account.slice(0, 5)}…${account.slice(-4)}`);
  if (!/^[0-9a-f]{32}$/i.test(accessKeyId)) {
    throw new Error('Access Key ID غير صحيح: 32 حرفًا من 0–9 وa–f (ليس الـ Token الذي يبدأ بـ cfat_)');
  }
  if (!/^[0-9a-f]{64}$/i.test(secret)) {
    throw new Error('Secret Access Key غير صحيح: 64 حرفًا من 0–9 وa–f');
  }
  const host = `${account}.r2.cloudflarestorage.com`;

  async function once(method, key, { body, headers = {}, query } = {}) {
    const pathname = `/${bucket}/${key}`;
    const payloadHash = body ? sha256Hex(body) : EMPTY_SHA;
    const amzDate = new Date().toISOString().replace(/[-:]/g, '').replace(/\.\d{3}/, '');
    const signed = signV4({ method, host, pathname, query, headers, payloadHash, accessKeyId, secret, region: 'auto', amzDate });
    const qs = canonicalQuery(query);
    const res = await fetch(`https://${host}${pathname.split('/').map(rfc3986).join('/')}${qs ? `?${qs}` : ''}`, {
      method,
      headers: { ...signed.headers, authorization: signed.authorization },
      body,
      signal: AbortSignal.timeout(120000),
    });
    const text = method === 'HEAD' ? '' : await res.text();
    return { status: res.status, etag: res.headers.get('etag'), text };
  }

  const TRIES = 8;

  async function request(method, key, opts = {}) {
    for (let attempt = 1; ; attempt++) {
      try {
        const res = await once(method, key, opts);
        const transient = res.status === 429 || res.status >= 500;
        if (!transient || attempt === TRIES) {
          if (method !== 'HEAD' && (res.status < 200 || res.status >= 300)) {
            throw Object.assign(new Error(`${method} ${key}: ${res.status} ${res.text.slice(0, 300)}`), { final: true });
          }
          return res;
        }
      } catch (e) {
        if (e.final || attempt === TRIES) throw e;
        console.log(`  ${method} ${key.slice(0, 28)}…: ${describe(e)}`);
      }
      const wait = Math.min(5000 * attempt, 30000);
      console.log(`  انقطاع، إعادة المحاولة ${attempt + 1}/${TRIES} بعد ${wait / 1000} ث…`);
      await new Promise((r) => setTimeout(r, wait));
    }
  }

  const PART = 8 * 1024 * 1024;

  const statePath = path.join(stateDir, '.upload-parts.json');
  const loadState = () => {
    try {
      return JSON.parse(fs.readFileSync(statePath, 'utf8'));
    } catch {
      return {};
    }
  };
  const saveState = (state) => fs.writeFileSync(statePath, JSON.stringify(state));

  async function multipart(key, body, headers) {
    const count = Math.ceil(body.length / PART);
    const state = loadState();
    let saved = state[key];
    if (!saved || saved.count !== count) {
      const created = await request('POST', key, { headers, query: { uploads: '' } });
      const uploadId = /<UploadId>([^<]+)<\/UploadId>/.exec(created.text)?.[1];
      if (!uploadId) throw new Error(`لم يبدأ الرفع على أجزاء: ${created.text.slice(0, 200)}`);
      saved = { uploadId, count, etags: {} };
      state[key] = saved;
      saveState(state);
    } else {
      console.log(`  ${key.slice(0, 20)}…: يكمل من حيث توقف (${Object.keys(saved.etags).length}/${count} مرفوعة)`);
    }
    for (let n = 1; n <= count; n++) {
      if (saved.etags[n]) continue;
      const chunk = body.subarray((n - 1) * PART, n * PART);
      const res = await request('PUT', key, { body: chunk, query: { partNumber: n, uploadId: saved.uploadId } });
      saved.etags[n] = res.etag;
      saveState(state);
      console.log(`  ${key.slice(0, 20)}…: جزء ${n}/${count}`);
    }
    const parts = Array.from(
      { length: count },
      (_, i) => `<Part><PartNumber>${i + 1}</PartNumber><ETag>${saved.etags[i + 1]}</ETag></Part>`,
    );
    try {
      await request('POST', key, {
        body: Buffer.from(`<CompleteMultipartUpload>${parts.join('')}</CompleteMultipartUpload>`),
        query: { uploadId: saved.uploadId },
      });
    } catch (e) {
      if (/NoSuchUpload/.test(e.message)) {
        delete state[key];
        saveState(state);
      }
      throw e;
    }
    delete state[key];
    saveState(state);
  }

  return {
    exists: async (key) => (await request('HEAD', key)).status === 200,
    put: async (key, body, contentType, cacheControl) => {
      const headers = { 'content-type': contentType, 'cache-control': cacheControl };
      if (body.length > PART) return multipart(key, body, headers);
      await request('PUT', key, { body, headers });
      return 200;
    },
  };
}

function wranglerClient(bucket) {
  const { execFileSync } = require('child_process');
  const os = require('os');
  const npx = process.platform === 'win32' ? 'npx.cmd' : 'npx';
  const run = (args) =>
    execFileSync(npx, ['--yes', 'wrangler@4', ...args], {
      stdio: ['ignore', 'pipe', 'pipe'],
      encoding: 'utf8',
      shell: process.platform === 'win32',
    });
  return {
    exists: async (key) => {
      try {
        const out = path.join(os.tmpdir(), `rizma-head-${process.pid}`);
        run(['r2', 'object', 'get', `${bucket}/${key}`, '--remote', '--file', out]);
        fs.rmSync(out, { force: true });
        return true;
      } catch {
        return false;
      }
    },
    put: async (key, body, contentType, cacheControl) => {
      const file = path.join(os.tmpdir(), `rizma-put-${process.pid}`);
      fs.writeFileSync(file, body);
      try {
        run([
          'r2', 'object', 'put', `${bucket}/${key}`, '--remote',
          '--file', file, '--content-type', contentType, '--cache-control', cacheControl,
        ]);
      } finally {
        fs.rmSync(file, { force: true });
      }
      return 200;
    },
  };
}

const IMMUTABLE = 'public, max-age=31536000, immutable';
const MANIFEST_CACHE = 'public, max-age=300';

async function upload(argv) {
  const opts = { grade: null, out: path.join(root, 'build/content'), bucket: 'rizma-content', dryRun: false };
  for (let i = 0; i < argv.length; i++) {
    const a = argv[i];
    if (a === '--grade') opts.grade = Number(argv[++i]);
    else if (a === '--out') opts.out = path.resolve(argv[++i]);
    else if (a === '--bucket') opts.bucket = argv[++i];
    else if (a === '--dry-run') opts.dryRun = true;
    else if (a === '--wrangler') opts.wrangler = true;
    else throw new Error(`خيار غير معروف: ${a}`);
  }
  if (!Number.isInteger(opts.grade)) throw new Error('--grade مطلوب');

  const gradeDir = path.join(opts.out, `v1/grades/${opts.grade}`);
  const manifestPath = path.join(gradeDir, 'manifest.json');
  if (!fs.existsSync(manifestPath)) throw new Error(`شغّل publish.js أولًا: لا يوجد ${manifestPath}`);
  const manifestBytes = fs.readFileSync(manifestPath);
  const sigBytes = fs.readFileSync(`${manifestPath}.sig`);
  const manifest = JSON.parse(manifestBytes.toString('utf8'));

  const shas = new Set();
  const videos = new Set();
  const pdfs = new Set();
  if (manifest.catalog) shas.add(manifest.catalog.sha256);
  for (const l of manifest.lessons) {
    for (const f of l.files) shas.add(f.sha256);
    if (l.video) {
      shas.add(l.video.sha256);
      videos.add(l.video.sha256);
    }
    for (const a of l.attachments ?? []) {
      shas.add(a.sha256);
      pdfs.add(a.sha256);
    }
  }
  const blobs = [...shas].map((sha) => {
    const file = path.join(opts.out, 'v1/blobs', sha);
    if (!fs.existsSync(file)) return { sha, bytes: null };
    const bytes = fs.readFileSync(file);
    if (sha256Hex(bytes) !== sha) throw new Error(`ملف لا يطابق بصمته: ${file}`);
    return { sha, bytes };
  });
  const remoteOnly = blobs.filter((b) => !b.bytes).length;

  console.log(
    `الصف ${manifest.grade}، الفهرس رقم ${manifest.sequence}: ${blobs.length} ملفًا` +
      (remoteOnly ? ` (${remoteOnly} منها على المخزن من نشر سابق)` : ''),
  );
  if (opts.dryRun) {
    console.log('(تجربة فقط: لم يُرفع شيء)');
    return 0;
  }

  const r2 = opts.wrangler ? wranglerClient(opts.bucket) : client(opts.bucket, opts.out);
  let uploaded = 0;
  let bytes = 0;
  for (const b of blobs) {
    const key = `v1/blobs/${b.sha}`;
    if (await r2.exists(key)) continue;
    if (!b.bytes) {
      throw new Error(`${b.sha} ليس على هذا الجهاز ولا على المخزن؛ لن يُرفع فهرس يشير إليه`);
    }
    const type = videos.has(b.sha)
      ? 'video/mp4'
      : pdfs.has(b.sha)
        ? 'application/pdf'
        : 'application/octet-stream';
    await r2.put(key, b.bytes, type, IMMUTABLE);
    uploaded++;
    bytes += b.bytes.length;
  }
  console.log(`  ملفات جديدة رُفعت: ${uploaded} (${(bytes / 1024).toFixed(1)} KB)، والباقي موجود`);
  const base = `v1/grades/${manifest.grade}/manifest.json`;
  await r2.put(`${base}.sig`, sigBytes, 'application/octet-stream', MANIFEST_CACHE);
  await r2.put(base, manifestBytes, 'application/json', MANIFEST_CACHE);
  console.log('  الفهرس وتوقيعه رُفعا (آخر شيء).');
  return 0;
}

module.exports = { signV4 };
if (require.main === module) {
  if (process.argv[2] === '--self-test') process.exit(selfTest());
  upload(process.argv.slice(2)).then(
    (code) => process.exit(code),
    (e) => {
      console.error(`خطأ: ${describe(e)}`);
      process.exit(1);
    },
  );
}

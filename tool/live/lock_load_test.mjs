import crypto from 'node:crypto';

const URL = 'https://znrxseznkjmcugmyzmya.supabase.co';
const KEY = 'sb_publishable_lULv0NY-Urx00TyuQoYBEQ_9S5MHHvo';
const BATCHES = Number(process.argv[2] ?? 25);
const PER_BATCH = 4;

const ALPHABET = '23456789ABCDEFGHJKMNPQRSTUVWXYZ';
const code = () => {
  const pick = () => ALPHABET[crypto.randomInt(ALPHABET.length)];
  const g = () => Array.from({ length: 4 }, pick).join('');
  return `RZ-${g()}-${g()}`;
};

async function signUp() {
  const r = await fetch(`${URL}/auth/v1/signup`, {
    method: 'POST',
    headers: { apikey: KEY, 'Content-Type': 'application/json' },
    body: '{}',
  });
  const j = await r.json();
  if (!j.access_token) throw new Error(`signup: ${JSON.stringify(j)}`);
  return { token: j.access_token, id: j.user.id };
}

async function rpc(user, name, params) {
  const r = await fetch(`${URL}/rest/v1/rpc/${name}`, {
    method: 'POST',
    headers: {
      apikey: KEY,
      Authorization: `Bearer ${user.token}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(params),
  });
  const text = await r.text();
  if (!r.ok) throw new Error(`${name} ${r.status}: ${text}`);
  return text ? JSON.parse(text) : null;
}

const attempt = (i) => ({
  id: crypto.randomUUID(),
  activity_id: 'math.u1.l1.practice',
  kind: 'practice',
  score: i % 5,
  total: 5,
  stars_earned: 3,
  hints_used: 0,
  details: null,
  created_at: new Date().toISOString(),
});

function check(cond, msg) {
  console.log(`${cond ? '✓' : '✗'} ${msg}`);
  if (!cond) process.exitCode = 1;
}

const a = await signUp();
const b = await signUp();
const reader = await signUp();
const profileId = crypto.randomUUID();
const studentCode = code();

await rpc(a, 'upload_batch', {
  p_batch: {
    profile_id: profileId,
    profile: {
      base_revision: 0,
      student_code: studentCode,
      grade: 5,
      color: 'teal',
      class_code: null,
      equipped: '',
      created_at: new Date().toISOString(),
    },
  },
});
for (const u of [b, reader]) {
  const r = await rpc(u, 'restore_profile', { p_code: studentCode });
  if (r.status !== 'restored') throw new Error(`restore: ${JSON.stringify(r)}`);
}
console.log(`student ${studentCode} (${profileId}), ${BATCHES} batches × 2 phones × ${PER_BATCH} attempts`);

const seen = new Map();
let cursor = 0;
let lastSeq = 0;
let monotonic = true;
let pulls = 0;
let uploading = true;
async function pullOnce() {
  for (;;) {
    const page = await rpc(reader, 'pull_changes', {
      p_profile_id: profileId,
      p_cursor: cursor,
      p_limit: 37,
    });
    pulls++;
    for (const at of page.attempts) {
      seen.set(at.id, (seen.get(at.id) ?? 0) + 1);
      if (at.server_seq <= lastSeq) monotonic = false;
      lastSeq = at.server_seq;
    }
    cursor = page.next_cursor;
    if (!page.has_more) return;
  }
}
const readerLoop = (async () => {
  while (uploading) await pullOnce();
  await pullOnce();
})();

const sent = new Set();
let updated = 0;
let conflicts = 0;
async function phone(user, seed) {
  let revision = 1;
  const jobs = [];
  for (let i = 0; i < BATCHES; i++) {
    const attempts = Array.from({ length: PER_BATCH }, (_, k) => attempt(seed + i * 10 + k));
    attempts.forEach((x) => sent.add(x.id));
    jobs.push(
      rpc(user, 'upload_batch', {
        p_batch: {
          profile_id: profileId,
          profile: {
            base_revision: revision,
            grade: 5 + (i % 2),
            color: 'teal',
            class_code: null,
            equipped: '',
          },
          attempts,
        },
      }).then((res) => {
        if (res.profile.status === 'updated') updated++;
        else conflicts++;
        revision = res.profile.revision;
        if (res.accepted.attempts.length !== PER_BATCH) {
          throw new Error(`accepted ${res.accepted.attempts.length}/${PER_BATCH}`);
        }
      }),
    );
  }
  await Promise.all(jobs);
}

const t0 = Date.now();
await Promise.all([phone(a, 0), phone(b, 5)]);
uploading = false;
await readerLoop;
const ms = Date.now() - t0;

const full = new Map();
let c = 0;
for (;;) {
  const page = await rpc(reader, 'pull_changes', { p_profile_id: profileId, p_cursor: c, p_limit: 1000 });
  for (const at of page.attempts) full.set(at.id, (full.get(at.id) ?? 0) + 1);
  c = page.next_cursor;
  if (!page.has_more) break;
}
const profile = (await rpc(reader, 'pull_changes', { p_profile_id: profileId, p_cursor: 0, p_limit: 1000 })).profile;

console.log(`${sent.size} attempts in ${ms} ms, reader pulled ${pulls} pages`);
check(full.size === sent.size && [...sent].every((id) => full.get(id) === 1),
  `on the server: all ${sent.size} attempts, each exactly once`);
check([...sent].every((id) => seen.get(id) === 1),
  `incremental reader saw every attempt exactly once (missed ${[...sent].filter((id) => !seen.has(id)).length})`);
check(monotonic, 'server_seq always increasing for the reader');
check(profile.revision === 1 + updated,
  `profile revision ${profile.revision} = 1 + ${updated} accepted edits (${conflicts} conflicts)`);
console.log(`cleanup: student_code = '${studentCode}', users = '${a.id}', '${b.id}', '${reader.id}'`);

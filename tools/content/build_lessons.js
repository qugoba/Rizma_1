const fs = require('fs');
const path = require('path');
const { validateQuestion } = require('./lib');

const root = path.resolve(__dirname, '../..');
const catalog = JSON.parse(fs.readFileSync(root + '/assets/content/catalog_grade5.json', 'utf8'));
const lessonIds = new Set();
const conceptIds = new Set();
for (const s of catalog.subjects) {
  for (const u of s.units) {
    for (const l of u.lessons) {
      lessonIds.add(l.id);
      l.concepts.forEach((c) => conceptIds.add(c.id));
    }
  }
}

const lessons = [
  ...require('./math'),
  ...require('./english'),
  ...require('./arabic'),
  ...require('./science'),
];
const outDir = root + '/assets/content/lessons';
fs.mkdirSync(outDir, { recursive: true });
for (const f of fs.readdirSync(outDir)) if (f.endsWith('.json')) fs.unlinkSync(path.join(outDir, f));

const errors = [];
const ids = new Set();
for (const lesson of lessons) {
  if (!lessonIds.has(lesson.lessonId)) errors.push(`درس غير موجود في الكتالوج: ${lesson.lessonId}`);
  for (const q of [...(lesson.practice || []), ...(lesson.quiz || [])]) {
    if (ids.has(q.id)) errors.push(`معرّف سؤال مكرر: ${q.id}`);
    ids.add(q.id);
    errors.push(...validateQuestion(q, conceptIds));
  }
  if ((lesson.practice || []).length < 8) errors.push(`${lesson.lessonId}: بنك التدريب أقل من 8 أسئلة`);
  if (lesson.video === null) delete lesson.video;
  for (const a of lesson.attachments || []) {
    if (!a.title || !/^[0-9a-f]{64}$/.test(a.file) || !Number.isInteger(a.sizeKb) || a.sizeKb < 1) {
      errors.push(`${lesson.lessonId}: مرفق يحتاج title و file (بصمة sha256) و sizeKb`);
    }
  }
  fs.writeFileSync(`${outDir}/${lesson.lessonId}.json`, JSON.stringify(lesson, null, 1) + '\n');
}
if (errors.length) {
  console.error('أخطاء:\n' + errors.join('\n'));
  process.exit(1);
}
console.log(`${lessons.length} lessons, ${ids.size} questions`);

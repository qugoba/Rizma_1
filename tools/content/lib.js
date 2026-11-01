const fr = (n, d) => `{${n}/${d}}`;
const blank = '{?}';

let counter = 0;
const nid = (lesson, prefix) => `${lesson}.${prefix}${++counter}`;
const reset = () => { counter = 0; };

function choice(lesson, prefix, concept, prompt, choices, answer, o = {}) {
  return { id: nid(lesson, prefix), type: 'choice', concept, prompt, choices, answer, ...o };
}
function tf(lesson, prefix, concept, statement, answer, o = {}) {
  return { id: nid(lesson, prefix), type: 'trueFalse', concept, prompt: 'هل هذه العبارة صحيحة؟', statement, answer, ...o };
}
function dd(lesson, prefix, concept, prompt, template, cards, answer, o = {}) {
  return { id: nid(lesson, prefix), type: 'dragDrop', concept, prompt, template, cards, answer, ...o };
}
function mp(lesson, prefix, concept, prompt, pairs, o = {}) {
  return { id: nid(lesson, prefix), type: 'matchPairs', concept, prompt, pairs, ...o };
}
function ord(lesson, prefix, concept, prompt, items, startLabel, endLabel, o = {}) {
  return { id: nid(lesson, prefix), type: 'order', concept, prompt, items, startLabel, endLabel, ...o };
}
function lc(lesson, prefix, concept, word, choices, answer, o = {}) {
  return { id: nid(lesson, prefix), type: 'listenChoose', concept, prompt: 'اضغط لتسمع الكلمة، ثم اختر صورتها', word, choices, answer, ...o };
}

function validateQuestion(q, conceptIds) {
  const errs = [];
  if (!conceptIds.has(q.concept)) errs.push(`${q.id}: مفهوم غير موجود ${q.concept}`);
  switch (q.type) {
    case 'choice':
    case 'listenChoose':
      if (!(q.answer >= 0 && q.answer < q.choices.length)) errs.push(`${q.id}: answer خارج النطاق`);
      if (new Set(q.choices).size !== q.choices.length) errs.push(`${q.id}: خيارات مكررة`);
      break;
    case 'dragDrop':
      if (!q.cards.includes(q.answer)) errs.push(`${q.id}: الجواب ليس بين البطاقات`);
      if (!q.template.includes('{?') && !q.template.includes('/?}')) errs.push(`${q.id}: القالب بلا خانة`);
      break;
    case 'matchPairs':
      if (q.pairs.length < 2) errs.push(`${q.id}: أقل من زوجين`);
      break;
    case 'order':
      if (q.items.length < 3) errs.push(`${q.id}: أقل من 3 عناصر`);
      if (q.items.some((i) => typeof i !== 'object' || typeof i.label !== 'string')) errs.push(`${q.id}: كل عنصر في الترتيب كائن له label`);
      break;
    case 'trueFalse':
      if (typeof q.answer !== 'boolean') errs.push(`${q.id}: answer ليست منطقية`);
      break;
    default:
      errs.push(`${q.id}: نوع مجهول ${q.type}`);
  }
  if (!['trueFalse'].includes(q.type) && (!q.hints || q.hints.length === 0)) {
  }
  return errs;
}

module.exports = { fr, blank, choice, tf, dd, mp, ord, lc, reset, validateQuestion };

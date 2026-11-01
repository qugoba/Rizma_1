// يستخرج أيقونات icon/* من مواصفات Figma إلى assets/icons/ui/<name>.svg بلون واحد أسود
// (يُلوَّن وقت العرض بـ ColorFilter). الأيقونات متعددة الألوان تُطبع تحذيرًا.
const fs = require('fs');
const path = require('path');
const root = path.resolve(__dirname, '../..');
const d = JSON.parse(fs.readFileSync(__dirname + '/spec_all.json', 'utf8'));
const out = path.join(root, 'assets/icons/ui');
fs.mkdirSync(out, { recursive: true });
const seen = {};
const multi = [];
function walk(n) {
  if (n.svg && /^icon\//.test(n.name)) {
    const key = n.name.replace('icon/', '');
    const cols = [...new Set((n.svg.match(/#[0-9A-Fa-f]{6}\b/g) || []).map((c) => c.toUpperCase()))];
    if (!seen[key] || (cols.length === 1 && seen[key].cols.length > 1)) seen[key] = { svg: n.svg, cols };
  }
  (n.children || []).forEach(walk);
}
d.frames.forEach(walk);
for (const [key, v] of Object.entries(seen)) {
  if (v.cols.length > 1) multi.push(key + ':' + v.cols.join(','));
  const norm = v.svg
    .replace(/#[0-9A-Fa-f]{6}\b/g, '#000000')
    .replace(/ preserveAspectRatio="none"/, '')
    .replace(/ style="display: block;"/, '')
    .replace(/ overflow="visible"/, '');
  fs.writeFileSync(path.join(out, key + '.svg'), norm);
}
console.log(Object.keys(seen).length, 'icons written to', out);
console.log('multi-color:', multi.join(' | ') || 'none');

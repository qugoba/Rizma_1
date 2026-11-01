// يطبع مخطط إطار من مواصفات Figma بشكل مضغوط: node outline.js <id-or-number-prefix>
const fs = require('fs');
const d = JSON.parse(fs.readFileSync(__dirname + '/spec_all.json', 'utf8'));
const q = process.argv[2];
const f = d.frames.find((x) => x.id === q || x.name.startsWith(q + ' ') || x.name === q);
if (!f) { console.log('not found; frames:', d.frames.map((x) => x.name).join(' | ')); process.exit(1); }
const fill = (n) => (n.fills || []).map((p) => p.color || p.type).join(',');
function line(n, ind) {
  const bits = [n.type[0] + (n.type === 'TEXT' ? '' : ''), JSON.stringify(n.name).slice(0, 40)];
  bits.push(`${Math.round(n.w)}x${Math.round(n.h)}`);
  if (n.layout) bits.push(`${n.layout.mode[0]} g${n.layout.gap} p[${n.layout.pad}] ${n.layout.main}/${n.layout.cross}`);
  if (n.sizing && (n.sizing.h === 'FILL' || n.sizing.v === 'FILL' || n.sizing.grow)) bits.push(`sz:${n.sizing.h[0]}${n.sizing.v[0]}${n.sizing.grow ? '+g' : ''}`);
  const fl = fill(n); if (fl) bits.push('f:' + fl);
  if (n.strokes) bits.push('s:' + n.strokes.map((p) => p.color).join(',') + '/' + n.strokeW + (n.dash ? ' dash' : ''));
  if (n.radius) bits.push('r' + (Array.isArray(n.radius) ? n.radius.join('/') : n.radius));
  if (n.effects && n.effects.length) bits.push('fx:' + n.effects.map((e) => e.type[0]).join(''));
  if (n.opacity != null) bits.push('op' + n.opacity);
  if (n.component) bits.push('comp:' + n.component);
  if (n.type === 'TEXT') { const s = n.segments[0]; bits.push(`"${n.text.replace(/\n/g, '\n')}"`, `${s.size}/${(s.font || '').replace('Cairo ', '')}/${s.color}`, n.textStyle ? 'ts:' + n.textStyle : ''); }
  if (n.svg) bits.push('SVG');
  console.log(' '.repeat(ind) + bits.join(' '));
  (n.children || []).forEach((c) => line(c, ind + 1));
}
console.log('FRAME', f.id, f.name, f.w + 'x' + f.h);
line(f, 0);

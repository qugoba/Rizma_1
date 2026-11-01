const fs = require('fs');
const d = JSON.parse(fs.readFileSync(__dirname + '/spec_all.json', 'utf8'));
const icons = {};
function walk(n, fr) {
  if (n.svg) {
    const k = n.name;
    const cols = [...new Set((n.svg.match(/(?:stroke|fill)="(#[0-9A-Fa-f]{3,6})"/g) || []).map((x) => x.match(/#[0-9A-Fa-f]+/)[0]))];
    icons[k] = icons[k] || { n: 0, cols: new Set(), size: new Set(), len: n.svg.length, frames: new Set() };
    icons[k].n++; cols.forEach((c) => icons[k].cols.add(c)); icons[k].size.add(Math.round(n.w)); icons[k].frames.add(fr);
  }
  (n.children || []).forEach((c) => walk(c, fr));
}
for (const f of d.frames) walk(f, f.name.slice(0, 2));
for (const [k, v] of Object.entries(icons)) console.log(k.padEnd(24), 'x' + v.n, 'cols:' + [...v.cols].length, 'sizes:' + [...v.size].join('/'), 'len', v.len);
console.log(Object.keys(icons).length, 'icon names');

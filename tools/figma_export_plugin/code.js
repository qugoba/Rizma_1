figma.showUI(__html__, { width: 360, height: 300 });

const hex = (c) =>
  '#' +
  [c.r, c.g, c.b]
    .map((v) => Math.round(v * 255).toString(16).padStart(2, '0'))
    .join('')
    .toUpperCase();

function paint(p) {
  if (p.visible === false) return null;
  if (p.type === 'SOLID') return { type: 'SOLID', color: hex(p.color), opacity: p.opacity == null ? 1 : p.opacity };
  if (p.type.indexOf('GRADIENT') === 0) {
    return {
      type: p.type,
      opacity: p.opacity == null ? 1 : p.opacity,
      stops: p.gradientStops.map((s) => ({ pos: +s.position.toFixed(3), color: hex(s.color), a: +s.color.a.toFixed(3) })),
    };
  }
  return { type: p.type };
}

async function styleName(id) {
  if (!id || id === figma.mixed) return undefined;
  try {
    const s = await figma.getStyleByIdAsync(id);
    return s ? s.name : undefined;
  } catch (e) {
    return undefined;
  }
}

const num = (v) => (typeof v === 'number' ? +v.toFixed(2) : v);

function put(o, k, v) {
  if (v !== undefined && v !== null && v !== figma.mixed) o[k] = v;
}

async function ser(node, depth) {
  const o = { id: node.id, name: node.name, type: node.type };
  put(o, 'x', num(node.x));
  put(o, 'y', num(node.y));
  put(o, 'w', num(node.width));
  put(o, 'h', num(node.height));
  if (node.rotation) o.rotation = num(node.rotation);
  if ('opacity' in node && node.opacity !== 1) o.opacity = num(node.opacity);
  if ('layoutPositioning' in node && node.layoutPositioning === 'ABSOLUTE') o.absolute = true;

  if ('layoutMode' in node && node.layoutMode !== 'NONE') {
    o.layout = {
      mode: node.layoutMode,
      gap: num(node.itemSpacing),
      pad: [num(node.paddingTop), num(node.paddingRight), num(node.paddingBottom), num(node.paddingLeft)],
      main: node.primaryAxisAlignItems,
      cross: node.counterAxisAlignItems,
      mainSizing: node.primaryAxisSizingMode,
      crossSizing: node.counterAxisSizingMode,
    };
    if (node.layoutWrap === 'WRAP') o.layout.wrap = true;
  }
  if ('layoutSizingHorizontal' in node) {
    o.sizing = { h: node.layoutSizingHorizontal, v: node.layoutSizingVertical };
    if (node.layoutGrow) o.sizing.grow = node.layoutGrow;
  }

  if ('fills' in node && node.fills !== figma.mixed && node.fills.length) {
    const fills = node.fills.map(paint).filter(Boolean);
    if (fills.length) o.fills = fills;
    const fs = await styleName(node.fillStyleId);
    if (fs) o.fillStyle = fs;
  }
  if ('strokes' in node && node.strokes.length) {
    o.strokes = node.strokes.map(paint).filter(Boolean);
    put(o, 'strokeW', num(node.strokeWeight));
    put(o, 'strokeAlign', node.strokeAlign);
    if (node.dashPattern && node.dashPattern.length) o.dash = node.dashPattern;
    const ss = await styleName(node.strokeStyleId);
    if (ss) o.strokeStyle = ss;
  }
  if ('cornerRadius' in node) {
    if (node.cornerRadius !== figma.mixed) {
      if (node.cornerRadius) o.radius = num(node.cornerRadius);
    } else {
      o.radius = [node.topLeftRadius, node.topRightRadius, node.bottomRightRadius, node.bottomLeftRadius].map(num);
    }
  }
  if ('effects' in node && node.effects.length) {
    o.effects = node.effects
      .filter((e) => e.visible !== false)
      .map((e) => ({
        type: e.type,
        color: e.color ? hex(e.color) : undefined,
        a: e.color ? +e.color.a.toFixed(3) : undefined,
        x: e.offset ? e.offset.x : undefined,
        y: e.offset ? e.offset.y : undefined,
        blur: e.radius,
        spread: e.spread,
      }));
  }
  if ('clipsContent' in node && node.clipsContent) o.clip = true;

  if (node.type === 'TEXT') {
    o.text = node.characters;
    o.align = node.textAlignHorizontal;
    o.valign = node.textAlignVertical;
    o.autoResize = node.textAutoResize;
    const segs = node.getStyledTextSegments(['fontSize', 'fontName', 'fills', 'lineHeight', 'letterSpacing', 'textDecoration']);
    const mapSeg = (s) => ({
      chars: s.characters,
      size: s.fontSize,
      font: s.fontName && s.fontName.family + ' ' + s.fontName.style,
      color: s.fills && s.fills.length && s.fills[0].type === 'SOLID' ? hex(s.fills[0].color) : undefined,
      lineHeight: s.lineHeight && s.lineHeight.unit !== 'AUTO' ? s.lineHeight : undefined,
      letterSpacing: s.letterSpacing && s.letterSpacing.value ? s.letterSpacing : undefined,
    });
    o.segments = segs.map(mapSeg);
    const ts = await styleName(node.textStyleId);
    if (ts) o.textStyle = ts;
  }

  if (node.type === 'INSTANCE') {
    try {
      const m = await node.getMainComponentAsync();
      if (m) o.component = m.name;
    } catch (e) {}
  }

  const isIcon =
    (/^(icon|Brand|Illustration|mascot)\b/i.test(node.name) ||
      /^(apple|orange|banana|grapes)$/i.test(node.name)) &&
    node.type !== 'TEXT';
  if (isIcon && node.exportAsync) {
    try {
      o.svg = await node.exportAsync({ format: 'SVG_STRING' });
      return o;
    } catch (e) {}
  }

  if ('children' in node && node.children.length && depth < 40) {
    o.children = [];
    for (const c of node.children) {
      if (c.visible === false) continue;
      o.children.push(await ser(c, depth + 1));
    }
  }
  return o;
}

(async () => {
  const sel = figma.currentPage.selection;
  if (!sel.length) {
    figma.notify('حدّد القسم أو الإطارات أولًا ثم شغّل الإضافة');
    figma.closePlugin();
    return;
  }
  const frames = [];
  for (const n of sel) {
    if (n.type === 'SECTION') {
      for (const c of n.children) if (c.type === 'FRAME' || c.type === 'COMPONENT') frames.push(c);
    } else {
      frames.push(n);
    }
  }
  figma.ui.postMessage({ type: 'start', count: frames.length });
  const out = [];
  for (let i = 0; i < frames.length; i++) {
    out.push(await ser(frames[i], 0));
    figma.ui.postMessage({ type: 'progress', done: i + 1, total: frames.length, name: frames[i].name });
  }
  figma.ui.postMessage({
    type: 'json',
    data: JSON.stringify({ file: figma.root.name, page: figma.currentPage.name, frames: out }),
  });
  for (let i = 0; i < frames.length; i++) {
    try {
      const bytes = await frames[i].exportAsync({ format: 'PNG', constraint: { type: 'SCALE', value: 1 } });
      figma.ui.postMessage({ type: 'png', index: i + 1, name: frames[i].name, bytes });
    } catch (e) {}
  }
  figma.ui.postMessage({ type: 'done' });
})();

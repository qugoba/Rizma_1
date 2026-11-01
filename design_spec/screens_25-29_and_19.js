const W=2430; const FX=k=>1960-k*470;
const NAME='٨ · الملفات وأول يوم';
const old=figma.currentPage.children.find(n=>n.type==='SECTION'&&n.name===NAME); if(old) old.remove();
const bottom=Math.max(...figma.currentPage.children.filter(n=>n.type==='SECTION').map(n=>n.y+n.height));
const S=figma.createSection(); S.name=NAME; S.x=0; S.y=bottom+160; S.resizeWithoutConstraints(W,1100);
{ const l=figma.createText(); l.fontName={family:'Cairo',style:'ExtraBold'}; l.characters=NAME; l.fontSize=44; await fill(l,'Ink'); S.appendChild(l); l.textAlignHorizontal='RIGHT'; l.x=W-80-l.width; l.y=28; }
async function TOPBAR(s,title,sub,back=true,end=null){ return R(s,{pad:[16,20,4,20],gap:12,name:'top bar'},async f=>{ if(back){ const b=await TILE(f,'back','Ink','Mute'); b.name='back button'; } const col=await AL(f,'VERTICAL',{gap:0,name:'titles'}); col.layoutSizingHorizontal='FILL'; if(sub) await T(col,sub,'Caption/13','Soft'); await T(col,title,'Heading/22'); if(end) await end(f); }); }
const BG={teal:'TealTint',coral:'CoralTint',blue:'#DEE7F8',purple:'#E9E3F6',amber:'AmberTint'};
const out=[];
// 25 Who is learning
{ const s=await SCREEN(S,'25 من يتعلّم الآن؟',FX(0),140);
  const c=await AL(s,'VERTICAL',{gap:16,pad:[28,20,24,20],name:'content'});
  await R(c,{gap:10,name:'brand'},async f=>{ SVG(f,'<svg width="34" height="34" viewBox="0 0 48 48" xmlns="http://www.w3.org/2000/svg"><path d="M12 4 H30 L40 14 V40 Q40 44 36 44 H12 Q8 44 8 40 V8 Q8 4 12 4 Z" fill="#177A63"/><path d="M30 4 V14 H40 Z" fill="#7ED3B2"/><path d="M19 21 L31 28 L19 35 Z" fill="#FFFFFF"/></svg>','Brand/Logo'); await T(f,'رِزمة',{size:22,w:'ExtraBold',lh:130},'Ink',{hug:true}); });
  const h=await AL(c,'VERTICAL',{gap:2,name:'heading'}); await T(h,'من يتعلّم الآن؟','Title/26'); await T(h,'اختر ملفك لتكمل من حيث توقفت.','Body/15','Soft');
  const P=[['أنس','الصف الخامس','teal','24 نجمة',false],['ليان','الصف الثاني','coral','8 نجوم',false],['يوسف','الصف الحادي عشر','blue','120 نجمة',true]];
  const grid=await AL(c,'HORIZONTAL',{gap:12,name:'profiles grid'}); grid.layoutWrap='WRAP'; grid.counterAxisSpacing=12; grid.primaryAxisAlignItems='MIN';
  const cw=169;
  const cards=[...P.map(p=>async()=>{ const [n,g,col,st,lock]=p; const cd=await AL(grid,'VERTICAL',{bg:'Card',stroke:'Line',r:22,pad:[16,10,14,10],gap:4,ca:'CENTER',w:cw,name:'profile/'+n});
      const av=await AL(cd,'HORIZONTAL',{bg:BG[col],r:40,w:80,h:80,pa:'CENTER',name:'avatar'}); SVG(av,MS(60,{body:col}),'mascot/'+col);
      await T(cd,n,'Section/18','Ink',{align:'CENTER'}); await T(cd,g,'Caption/13','Soft',{align:'CENTER'});
      await R(cd,{gap:6,w:'hug',pad:[4,0,0,0]},async f=>{ await CHIP(f,st,'AmberDark','AmberTint','starf'); if(lock) await TILE(f,'lock','Soft','Mute',28,16,14); }); }),
    async()=>{ const cd=await AL(grid,'VERTICAL',{stroke:'Disabled',sw:2,r:22,pad:[16,10,14,10],gap:8,ca:'CENTER',pa:'CENTER',w:cw,h:206,name:'profile/new'}); cd.dashPattern=[8,6]; await TILE(cd,'plus','Teal','TealTint',64,30,32); await T(cd,'طالب جديد','Section/18','Teal',{align:'CENTER'}); await T(cd,'أضف ملفًا لأخ أو أخت','Caption/13','Soft',{align:'CENTER'}); }];
  for(let i=0;i<cards.length;i+=2){ const pair=cards.slice(i,i+2).reverse(); for(const fn of pair) await fn(); }
  FIN(s,c); const sp=await AL(c,'VERTICAL',{name:'spacer'}); sp.layoutSizingVertical='FILL';
  await R(c,{bg:'Card',stroke:'Line',r:18,pad:[12,14],gap:12,name:'restore link'},async f=>{ await TILE(f,'sync','Blue','#DEE7F8',44,22); const col=await AL(f,'VERTICAL',{gap:0}); col.layoutSizingHorizontal='FILL'; await T(col,'لديك رمز طالب؟','Body/16 Strong'); await T(col,'استعد تقدّمك على هذا الجهاز','Caption/13','Soft'); IC(f,'fwd',20,'Soft'); });
  await R(c,{gap:8,pa:'CENTER',name:'privacy note'},async f=>{ IC(f,'shield',16,'Soft'); await T(f,'الملفات محفوظة على هذا الجهاز · لا نطلب بريدًا ولا رقم هاتف','Caption/13','Soft',{hug:true}); });
  out.push(s.id); }
// 26 Profile setup step 2
{ const s=await SCREEN(S,'26 إعداد الملف',FX(1),140);
  await TOPBAR(s,'اجعل الملف لك','خطوة 2 من 2');
  const c=await AL(s,'VERTICAL',{gap:16,pad:[12,20,24,20],name:'content'});
  const pv=await AL(c,'VERTICAL',{bg:'CoralTint',r:26,pad:[16,16,14,16],gap:4,ca:'CENTER',name:'preview'}); SVG(pv,MS(96,{body:'coral'}),'mascot preview'); await T(pv,'ليان · الصف الثاني','Section/18','Ink',{align:'CENTER',hug:true});
  const cp=await AL(c,'VERTICAL',{gap:10,name:'color picker'}); await T(cp,'اختر لون شخصيتك','Body/16 Strong');
  await R(cp,{gap:14,pa:'CENTER',name:'colors'},async f=>{ for(const [col,hex] of [['teal','#177A63'],['coral','#B94F2A'],['blue','#2F66C9'],['purple','#6A4FB3'],['amber','#B07316']]){ const on=col==='coral'; const ring=await AL(f,'HORIZONTAL',{stroke:on?'Ink':null,sw:3,r:30,w:56,h:56,pa:'CENTER',name:'color/'+col+(on?' selected':'')}); const dot=figma.createEllipse(); dot.resize(42,42); dot.fills=[{type:'SOLID',color:rgb(hex)}]; ring.appendChild(dot); } });
  const pin=await CARD(c,{pad:[14,16],gap:10,name:'pin card'});
  await R(pin,{gap:12},async f=>{ await TILE(f,'lock','Purple','#E9E3F6',40,20,12); const col=await AL(f,'VERTICAL',{gap:0}); col.layoutSizingHorizontal='FILL'; await T(col,'رمز سري','Body/16 Strong'); await T(col,'يمنع الآخرين من فتح ملفك على هذا الجهاز','Caption/13','Soft');
    const sw=await AL(f,'HORIZONTAL',{bg:'Disabled',r:16,w:52,h:32,pad:4,pa:'MAX',name:'switch off'}); const k=figma.createEllipse(); k.resize(24,24); await fill(k,'Card'); sw.appendChild(k); });
  await T(pin,'اختياري · يُنصح به للصفوف 7–12','Caption/13','Soft');
  const cc=await CARD(c,{pad:[14,16],gap:8,name:'class code card'});
  await R(cc,{gap:12},async f=>{ await TILE(f,'users','Teal','TealTint',40,20,12); const col=await AL(f,'VERTICAL',{gap:0}); col.layoutSizingHorizontal='FILL'; await T(col,'رمز الصف (اختياري)','Body/16 Strong'); await T(col,'يعطيك إياه معلمك لتنضم إلى مجموعته','Caption/13','Soft'); });
  await R(cc,{bg:'#F4F5F1',stroke:'Line',sw:2,r:14,h:50,pad:[0,14],name:'input'},async f=>{ await T(f,'مثال: GZ-5A',{size:16,w:'SemiBold',lh:150},'#9AA7A1',{grow:true}); });
  FIN(s,c); const sp=await AL(c,'VERTICAL',{name:'spacer'}); sp.layoutSizingVertical='FILL';
  await BTN(c,'ابدأ التعلّم','Teal','Card','fwd'); await T(c,'يمكنك تغيير كل هذا لاحقًا من حسابك.','Caption/13','Soft',{align:'CENTER'});
  out.push(s.id); }
// 27 PIN
{ const s=await SCREEN(S,'27 الرمز السري',FX(2),140);
  await TOPBAR(s,'',null,true);
  const c=await AL(s,'VERTICAL',{gap:14,pad:[8,24,24,24],ca:'CENTER',name:'content'});
  const av=await AL(c,'HORIZONTAL',{bg:'#DEE7F8',r:56,w:112,h:112,pa:'CENTER',name:'avatar'}); SVG(av,MS(84,{body:'blue'}),'mascot/blue');
  await T(c,'مرحبًا يوسف','Title/26','Ink',{align:'CENTER'}); await T(c,'أدخل رمزك السري','Body/15','Soft',{align:'CENTER'});
  const dots=await AL(c,'HORIZONTAL',{gap:18,w:'hug',pad:[10,0,10,0],name:'pin dots'}); for(let i=0;i<4;i++){ const d=figma.createEllipse(); d.resize(20,20); if(i<2) await fill(d,'Teal'); else { d.fills=[]; await strokeC(d,'Disabled',2); } dots.appendChild(d); }
  const kp=await AL(c,'VERTICAL',{gap:12,name:'keypad',ca:'CENTER'});
  for(const row of [['1','2','3'],['4','5','6'],['7','8','9'],['','0','del']]){ const r=await AL(kp,'HORIZONTAL',{gap:18,w:'hug',name:'row'}); for(const k of row){ const b=await AL(r,'HORIZONTAL',{bg:k===''?null:(k==='del'?null:'Card'),stroke:(k===''||k==='del')?null:'Line',r:40,w:80,h:64,pa:'CENTER',name:k===''?'empty':(k==='del'?'key/delete':'key/'+k)}); if(k==='del') IC(b,'del',26,'Ink'); else if(k) await T(b,k,{size:28,w:'Bold',lh:120},'Ink',{hug:true,align:'CENTER'}); } }
  FIN(s,c); const sp=await AL(c,'VERTICAL',{name:'spacer'}); sp.layoutSizingVertical='FILL';
  await T(c,'نسيت الرمز؟ استخدم رمز الطالب لإعادة تعيينه','Label/14','Teal',{align:'CENTER'});
  out.push(s.id); }
// 28 First-day home
{ const s=await SCREEN(S,'28 الرئيسية — أول يوم',FX(3),140);
  await R(s,{pad:[18,20,4,20],gap:12,name:'greeting'},async f=>{ const col=await AL(f,'VERTICAL',{gap:0}); col.layoutSizingHorizontal='FILL'; await T(col,'الصف الخامس','Label/14','Soft'); await T(col,'أهلًا، أنس','Title/26'); await T(col,'يومك الأول في رِزمة. لنبدأ معًا!','Body/15','Soft');
    const av=await AL(f,'HORIZONTAL',{bg:'TealTint',r:26,w:52,h:52,pa:'CENTER',name:'avatar'}); SVG(av,MS(40),'mascot'); });
  const c=await AL(s,'VERTICAL',{gap:14,pad:[12,20,24,20],name:'content'});
  const st=await AL(c,'VERTICAL',{bg:'Teal',r:24,pad:[18,20],gap:10,name:'start card'});
  await R(st,{gap:8},async f=>{ IC(f,'calc',18,'#D5EEE3'); await T(f,'الرياضيات · الوحدة الأولى','Label/14','#D5EEE3',{hug:true}); });
  await T(st,'ابدأ أول درس: الأعداد',{size:20,w:'ExtraBold',lh:140},'Card');
  await T(st,'نحو 15 دقيقة · شرح وتدريب قصير',{size:13,w:'SemiBold',lh:150},'#D5EEE3');
  await BTN(st,'ابدأ الدرس','Card','Teal','play',{h:48});
  const gs=await CARD(c,{pad:[14,16],gap:4,name:'getting started'});
  await R(gs,{gap:8},async f=>{ await T(f,'خطواتك الأولى','Section/18','Ink',{grow:true}); await T(f,'0 من 3','Label/14','Soft',{hug:true}); });
  for(const [ic,t,m] of [['download','نزّل أول درس','لتتعلّم حتى دون إنترنت'],['target','أكمل أول تدريب','واربح نجومك الأولى'],['trophy','جرّب أول اختبار','لتعرف ما تحتاج مراجعته']]){
    const r=await R(gs,{gap:12,pad:[8,0],name:'step/'+t},async f=>{ const e=figma.createEllipse(); e.name='not done'; e.resize(24,24); e.fills=[]; await strokeC(e,'Disabled',2); f.appendChild(e); const col=await AL(f,'VERTICAL',{gap:0}); col.layoutSizingHorizontal='FILL'; await T(col,t,'Body/15'); await T(col,m,'Caption/13','Soft'); await TILE(f,ic,'Soft','Mute',36,18,12); }); }
  const ph=await R(c,{stroke:'Disabled',sw:2,r:18,pad:[12,14],gap:12,name:'review placeholder (empty state)'},async f=>{ await TILE(f,'warn','Soft','Mute',40,20,12); await T(f,'ما يحتاج إلى مراجعة سيظهر هنا بعد أول اختبار.','Label/14','Soft',{grow:true}); }); ph.dashPattern=[6,5];
  await R(c,{gap:8,name:'my subjects header'},async f=>{ await T(f,'موادي','Section/18','Ink',{grow:true}); await T(f,'عرض الكل','Label/14','Teal',{hug:true}); });
  const sr=await R(c,{gap:12,name:'subjects carousel',ca:'MIN'},async f=>{ for(const [n,ic,fg,bg] of [['الرياضيات','calc','Teal','TealTint'],['العربية','book','Coral','CoralTint'],['الإنجليزية','chat','Purple','#E9E3F6']]){ const t=await CARD(f,{w:104,gap:6,pad:12,name:'subject/'+n}); await TILE(t,ic,fg,bg,40,20,12); await T(t,n,'Label/14'); await T(t,'لم تبدأ',{size:12,w:'Bold',lh:140},'Soft'); } });
  sr.clipsContent=true;
  const nv=navHome.createInstance(); s.appendChild(nv); nv.layoutSizingHorizontal='FILL';
  FIN(s,c); out.push(s.id); }
// 29 Student code
{ const s=await SCREEN(S,'29 رمز الطالب',FX(4),140);
  await TOPBAR(s,'رمز الطالب','حسابي');
  const c=await AL(s,'VERTICAL',{gap:14,pad:[12,20,24,20],name:'content'});
  const k=await AL(c,'VERTICAL',{bg:'Ink',r:24,pad:[20,20],gap:8,ca:'CENTER',name:'code card'});
  await T(k,'رمزك',{size:14,w:'Bold',lh:150},'#B9CFC8',{align:'CENTER'});
  await T(k,'RZ-7K4M',{size:40,w:'ExtraBold',lh:130},'#F4F1E8',{align:'CENTER'});
  await R(k,{gap:10,pad:[6,0,0,0]},async f=>{ for(const [ic,t] of [['copy','نسخ'],['share','مشاركة']]){ const b=await R(f,{bg:'#173A3E',r:14,h:44,pad:[0,16],gap:8,pa:'CENTER',grow:true,name:'button/'+t},async g=>{ IC(g,ic,18,'#7ED3B2'); await T(g,t,'Label/14','#F4F1E8',{hug:true}); }); } });
  const ex=await CARD(c,{pad:[14,16],gap:4,name:'what it does'}); await T(ex,'لماذا هذا الرمز؟','Section/18');
  for(const [ic,t,col,bg] of [['phone','انقل تقدّمك إلى جهاز جديد','Teal','TealTint'],['users','معلمك يضيفك إلى مجموعته','Blue','#DEE7F8'],['shield','لا يحتاج بريدًا ولا رقم هاتف','Purple','#E9E3F6']]) await R(ex,{gap:12,pad:[8,0]},async f=>{ await TILE(f,ic,col,bg,40,20,12); await T(f,t,'Body/15','Ink',{grow:true}); });
  await R(c,{bg:'Card',stroke:'Line',r:18,pad:[12,14],gap:12,name:'sync status'},async f=>{ await TILE(f,'sync','Teal','TealTint',40,20,12); const col=await AL(f,'VERTICAL',{gap:0}); col.layoutSizingHorizontal='FILL'; await T(col,'آخر حفظ على الإنترنت: أمس','Body/15'); await T(col,'3 نتائج بانتظار الاتصال','Caption/13','Soft'); });
  await R(c,{bg:'Card',stroke:'Line',r:18,pad:[12,14],gap:12,name:'class group'},async f=>{ await TILE(f,'users','AmberDark','AmberTint',40,20,12); const col=await AL(f,'VERTICAL',{gap:0}); col.layoutSizingHorizontal='FILL'; await T(col,'مجموعة الصف الخامس (أ)','Body/15'); await T(col,'رمز الصف: GZ-5A','Caption/13','Soft'); });
  FIN(s,c); const sp=await AL(c,'VERTICAL',{name:'spacer'}); sp.layoutSizingVertical='FILL';
  await T(c,'احتفظ بالرمز في مكان آمن، أو اطلب من معلمك تسجيله.','Caption/13','Soft',{align:'CENTER'});
  out.push(s.id); }
let maxB=0; for(const ch of S.children) maxB=Math.max(maxB,ch.y+ch.height); S.resizeWithoutConstraints(W,maxB+120);
// add profile group to screen 19
const prof=await figma.getNodeByIdAsync('6:732'); let added=null;
if(prof){ const cont=prof.findChild(n=>n.name==='content'); const ex=cont.findOne(n=>n.name==='settings/الملف'); if(ex) ex.remove();
  const g=await CARD(cont,{pad:[14,16],gap:0,name:'settings/الملف'}); await T(g,'الملف','Section/18');
  for(const [ic,fg,bg,l,end] of [['key','Teal','TealTint','رمز الطالب','RZ-7K4M'],['users','Blue','#DEE7F8','تبديل الطالب',null],['lock','Purple','#E9E3F6','الرمز السري','غير مفعّل']]){
    const r=await R(g,{gap:12,h:56,name:'setting/'+l},async f=>{ await TILE(f,ic,fg,bg,40,20,12); await T(f,l,'Body/15','Ink',{grow:true}); if(end) await T(f,end,'Label/14','Teal',{hug:true}); IC(f,'fwd',18,'Soft'); });
    r.strokes=[{type:'SOLID',color:rgb('#E1E6E2')}]; r.strokeTopWeight=0; r.strokeLeftWeight=0; r.strokeRightWeight=0; r.strokeBottomWeight=1; }
  const pc=cont.findChild(n=>n.name==='profile'); const idx=cont.children.indexOf(pc); cont.insertChild(idx+1,g);
  prof.primaryAxisSizingMode='AUTO'; cont.layoutSizingVertical='HUG'; const h=Math.max(prof.height,844); prof.primaryAxisSizingMode='FIXED'; prof.resize(390,h); cont.layoutSizingVertical='FILL'; added=g.id;
  const sec=prof.parent; let mb=0; for(const ch of sec.children) mb=Math.max(mb,ch.y+ch.height); if(sec.height<mb+120) sec.resizeWithoutConstraints(sec.width,mb+120); }
await S.screenshot({scale:0.5});
return {section:S.id,screens:out,profileGroup:added};

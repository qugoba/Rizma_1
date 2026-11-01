const { blank, choice, tf, dd, mp, ord, lc, reset } = require('./lib');

function newFriends() {
  const L = 'english.u1.l1';
  const c1 = `${L}.c1`;
  const c2 = `${L}.c2`;
  const w = (en, ar, ipa, sentenceEn, sentenceAr) => ({ en, ar, ipa, illustration: '', sentenceEn, sentenceAr });
  const words = [
    w('internet', 'الإنترنت', '/ˈɪn.tə.net/', 'Rania looks at cats on the internet.', 'رانيا تنظر إلى القطط على الإنترنت.'),
    w('cinema', 'سينما', '/ˈsɪn.ə.mə/', 'We watch films at the cinema.', 'نشاهد الأفلام في السينما.'),
    w('film', 'فيلم', '/fɪlm/', 'I like this film.', 'أحب هذا الفيلم.'),
    w('email', 'بريد إلكتروني', '/ˈiː.meɪl/', 'Ben likes writing emails.', 'بن يحب كتابة الرسائل الإلكترونية.'),
    w('art', 'فن، رسم', '/ɑːt/', 'Omar is good at art.', 'عمر جيد في الرسم.'),
    w('work', 'يعمل', '/wɜːk/', 'He works in Ramallah.', 'هو يعمل في رام الله.'),
    w('race', 'سباق', '/reɪs/', 'Dad likes walking races.', 'أبي يحب سباقات المشي.'),
    w('twin', 'توأم', '/twɪn/', 'Omar and Rania are twins.', 'عمر ورانيا توأم.'),
    w('parent', 'أحد الوالدين', '/ˈpeə.rənt/', 'My parents are my mum and dad.', 'والداي هما أمي وأبي.'),
    w('class', 'صف، فصل', '/klɑːs/', 'Ben is a new pupil in our class.', 'بن تلميذ جديد في صفنا.'),
  ];

  const pack = [
    {
      header: 'الإنجليزية · الصف الخامس',
      title: 'الوحدة 1: New friends',
      blocks: [
        { type: 'text', value: 'Ben تلميذ جديد في الصف. هو من بريطانيا، ويجلس بجانب عمر. وأخت عمر التوأم رانيا تجلس خلفه.' },
        { type: 'text', value: 'Hi, I’m Omar. This is my sister Rania. We’re twins. We’re 11 years old.' },
        { type: 'text', value: 'أبو بن مهندس يعمل في رام الله ويحب سباقات المشي، وأمه تساعده.' },
      ],
    },
    {
      header: 'ماذا يحبون أن يفعلوا؟',
      title: 'What do you like doing?',
      blocks: [
        { type: 'text', value: 'Ben likes drawing pictures and writing emails.' },
        { type: 'text', value: 'Omar is good at art. He likes watching films at the cinema.' },
        { type: 'text', value: 'Rania likes looking at cats on the internet.' },
      ],
    },
  ];

  const explanation = [
    { title: '1. تعرّف على الأصدقاء', body: 'Ben من بريطانيا، طالب جديد. يحب drawing pictures وwriting emails وwatching films. Omar توأم Rania، عمره 11 سنة، يحب drawing pictures وwatching films. Rania أخت Omar التوأم، تحب looking at cats on the internet.', tip: 'والد Ben مهندس (engineer) يعمل في رام الله، ويحب سباقات المشي (walking races).' },
    { title: '2. كلماتي الجديدة', body: 'class صف، parent أحد الوالدين، twin توأم، race سباق، work يعمل، art فن، email بريد إلكتروني، film فيلم، cinema سينما، internet الإنترنت.' },
    { title: '3. قاعدة اليوم: نضيف s', body: 'مع He وShe نضيف s للفعل، ومع I وWe وThey يبقى كما هو: I live ← He lives، I work ← She works، I walk ← He walks.', tip: 'وI am ← He is.' },
    { title: '4. أقول ماذا أحب', body: 'بعد like نكتب فعلًا ينتهي بـ ing: I like drawing pictures. I like watching films. She likes looking at cats.' },
    { title: '5. أحكي عن نفسي', body: 'Where do you live? ← I live in … · What’s your favourite subject? ← My favourite subject is … · What do you like doing? ← I like …' },
    { title: 'زيادة: النفي وhave', body: 'I don’t have a car. She doesn’t have a sister. They have a car. He has a cat.', tip: 'don’t مع I/We/They، وdoesn’t مع He/She، والفعل بعدها بلا s.' },
  ];

  const summary = [
    { text: 'twins يعني أخوين وُلدا معًا، مثل Omar وRania.' },
    { text: 'مع He وShe نضيف s للفعل: He lives و She works.' },
    { text: 'بعد like يأتي فعل بـ ing: I like drawing.' },
    { text: 'I am، He/She is، We/They are.' },
    { text: 'كلماتي الجديدة: internet، cinema، film، email، art، work، race، twin، parent، class.' },
  ];

  reset();
  const practice = [
    choice(L, 'p', c1, 'ما معنى كلمة twin؟', ['توأم', 'صديق', 'معلم', 'جار'], 0, { hints: ['عمر ورانيا عمرهما واحد ووُلدا معًا.'], solution: ['twin = توأم'], explanation: 'twin تعني توأم.' }),
    choice(L, 'p', c1, 'أين نشاهد الأفلام؟', ['cinema', 'class', 'race', 'email'], 0, { hints: ['مكان فيه شاشة كبيرة.'], solution: ['We watch films at the cinema.'], explanation: 'cinema = سينما.' }),
    choice(L, 'p', c1, 'ما معنى كلمة parents؟', ['الوالدان', 'الإخوة', 'الأصدقاء', 'المعلمون'], 0, { hints: ['أمي وأبي.'], solution: ['parents = الوالدان'], explanation: 'parents هما الأم والأب.' }),
    mp(L, 'p', c1, 'وصّل كل كلمة بمعناها', [
      { left: { text: 'film' }, right: { text: 'فيلم' } },
      { left: { text: 'email' }, right: { text: 'بريد إلكتروني' } },
      { left: { text: 'race' }, right: { text: 'سباق' } },
      { left: { text: 'class' }, right: { text: 'صف' } },
    ], { hints: ['ابدأ بالكلمة التي تعرفها.'], solution: ['film = فيلم', 'email = بريد إلكتروني', 'race = سباق', 'class = صف'] }),
    tf(L, 'p', c1, 'Ben is from Palestine.', false, { hints: ['تذكّر: I’m British.'], solution: ['Ben is from Britain.'], explanation: 'بن من بريطانيا.' }),
    tf(L, 'p', c1, 'Omar and Rania are twins.', true, { hints: ['We’re twins.'], solution: ['صحيح'], explanation: 'عمر ورانيا توأم عمرهما 11 سنة.' }),
    tf(L, 'p', c1, 'Rania likes looking at cats on the internet.', true, { hints: ['ماذا تحب رانيا؟'], solution: ['صحيح'], explanation: 'صحيح.' }),
    choice(L, 'p', c2, 'اختر الصحيح: He ____ in Ramallah.', ['works', 'work', 'working', 'are work'], 0, { hints: ['مع He نضيف s للفعل.'], solution: ['He works in Ramallah.'], explanation: 'He + فعل + s.' }),
    choice(L, 'p', c2, 'اختر الصحيح: I ____ in Gaza.', ['live', 'lives', 'is live', 'living'], 0, { hints: ['مع I يبقى الفعل كما هو.'], solution: ['I live in Gaza.'], explanation: 'I + الفعل بلا s.' }),
    choice(L, 'p', c2, 'اختر الصحيح: Omar ____ eleven years old.', ['is', 'are', 'am', 'be'], 0, { hints: ['Omar = He'], solution: ['Omar is eleven years old.'], explanation: 'He/She ← is.' }),
    dd(L, 'p', c2, 'اسحب الكلمة المناسبة إلى الفراغ', `She ${blank} have a sister.`, ['doesn’t', 'don’t', 'isn’t', 'aren’t'], 'doesn’t', { hints: ['She مثل He: نستعمل doesn’t.'], solution: ['She doesn’t have a sister.'], explanation: 'He/She ← doesn’t.' }),
    dd(L, 'p', c2, 'اسحب الكلمة المناسبة إلى الفراغ', `They ${blank} a car.`, ['have', 'has', 'is', 'does'], 'have', { hints: ['They مثل I وWe.'], solution: ['They have a car.'], explanation: 'I/We/They ← have، وHe/She ← has.' }),
    ord(L, 'p', c2, 'رتّب الكلمات لتكوين جملة', [{ label: 'I' }, { label: 'like' }, { label: 'watching' }, { label: 'films' }], 'أول الجملة', 'آخرها', { hints: ['ابدأ بـ I.'], solution: ['I like watching films.'] }),
    choice(L, 'p', c2, 'What do you like doing? اختر الجواب الصحيح', ['I like drawing.', 'I like draw.', 'I likes drawing.', 'I drawing like.'], 0, { hints: ['I like + فعل + ing'], solution: ['I like drawing.'], explanation: 'I like + ing.' }),
  ];

  reset();
  const quiz = [
    choice(L, 'q', c1, 'ما معنى cinema؟', ['سينما', 'صف', 'سباق', 'فيلم'], 0),
    choice(L, 'q', c1, 'كيف نقول «توأم» بالإنجليزية؟', ['twin', 'parent', 'class', 'art'], 0),
    choice(L, 'q', c1, 'أين يعمل أبو بن؟', ['Ramallah', 'Jerusalem', 'Gaza', 'London'], 0),
    tf(L, 'q', c1, 'Ben likes writing emails.', true),
    choice(L, 'q', c2, 'اختر الصحيح: She ____ in Jerusalem.', ['lives', 'live', 'living', 'are live'], 0),
    choice(L, 'q', c2, 'اختر الصحيح: My favourite subject ____ English.', ['is', 'are', 'am', 'do'], 0),
    choice(L, 'q', c2, 'اختر الصحيح: They ____ a car.', ['have', 'has', 'is', 'does'], 0),
    choice(L, 'q', c2, 'اختر الصحيح: He ____ have a brother.', ['doesn’t', 'don’t', 'isn’t', 'not'], 0),
  ];

  return {
    lessonId: L,
    note: 'من الوحدة 1 في كتاب English for Palestine 5 (الرزم التعليمية 2024). ينتظر مراجعة معلم.',
    pack,
    explanation,
    summary,
    words,
    video: { title: 'الوحدة الأولى: أصدقاء جدد!', minutes: 7, sizeMb: 31.5, file: '7a85c0d0baee4b56720fdd039de01ac26eb074de83a15c2fb4bef16b09387297', parts: [{ title: 'New friends: الدرس كاملًا', at: '0:00' }] },
    attachments: [{ title: 'ملخص الطالب: الدرس الأول', file: '5d0f3312cc94c828f0b874715e1ce35dfd0fefe1732926f97a1078d05a0c1ae7', sizeKb: 496 }],
    practice,
    quiz,
  };
}

function fruits() {
  const L = 'english.u2.l1';
  const c1 = `${L}.c1`;
  const words = [
    { en: 'Apple', ar: 'تفاحة', ipa: '/ˈæp.əl/', illustration: 'apple', sentenceEn: 'I eat an apple.', sentenceAr: 'أنا آكل تفاحة.' },
    { en: 'Banana', ar: 'موزة', ipa: '/bəˈnɑː.nə/', illustration: 'banana', sentenceEn: 'I like a banana.', sentenceAr: 'أنا أحب الموزة.' },
    { en: 'Orange', ar: 'برتقالة', ipa: '/ˈɒr.ɪndʒ/', illustration: 'orange', sentenceEn: 'The orange is sweet.', sentenceAr: 'البرتقالة حلوة.' },
    { en: 'Grapes', ar: 'عنب', ipa: '/ɡreɪps/', illustration: 'grapes', sentenceEn: 'I see red grapes.', sentenceAr: 'أرى عنبًا أحمر.' },
    { en: 'Lemon', ar: 'ليمونة', ipa: '/ˈlem.ən/', illustration: 'lemon', sentenceEn: 'The lemon is yellow.', sentenceAr: 'الليمونة صفراء.' },
    { en: 'Strawberry', ar: 'فراولة', ipa: '/ˈstrɔː.bər.i/', illustration: 'strawberry', sentenceEn: 'The strawberry is red.', sentenceAr: 'الفراولة حمراء.' },
  ];
  const keys = words.map((w) => w.illustration);
  reset();
  const listen = (i, others) => {
    const set = [keys[i], ...others];
    return lc(L, 'p', c1, words[i].en, set, 0, {
      hints: ['اضغط «أعد» لتسمع الكلمة مرة ثانية.', `الكلمة هي ${words[i].en}.`],
      solution: [`${words[i].en} تعني ${words[i].ar}`],
      explanation: `${words[i].en} تعني ${words[i].ar}.`,
    });
  };
  const practice = [
    listen(0, ['orange', 'banana', 'grapes']),
    listen(1, ['apple', 'lemon', 'strawberry']),
    listen(2, ['grapes', 'apple', 'banana']),
    listen(3, ['strawberry', 'orange', 'lemon']),
    listen(4, ['banana', 'grapes', 'apple']),
    listen(5, ['lemon', 'apple', 'orange']),
    choice(L, 'p', c1, 'ما معنى كلمة Apple؟', ['تفاحة', 'موزة', 'عنب', 'برتقالة'], 0, { hints: ['هي فاكهة حمراء أو خضراء مستديرة.'], solution: ['Apple = تفاحة'], explanation: 'Apple تعني تفاحة.' }),
    choice(L, 'p', c1, 'ما معنى كلمة Grapes؟', ['عنب', 'موزة', 'ليمونة', 'فراولة'], 0, { hints: ['فاكهة تأتي عناقيد صغيرة.'], solution: ['Grapes = عنب'], explanation: 'Grapes تعني عنبًا.' }),
    choice(L, 'p', c1, 'كيف نقول «موزة» بالإنجليزية؟', ['Banana', 'Lemon', 'Orange', 'Apple'], 0, { hints: ['لونها أصفر وشكلها هلال.'], solution: ['موزة = Banana'], explanation: 'موزة = Banana.' }),
    tf(L, 'p', c1, 'كلمة Orange تعني «برتقالة».', true, { hints: ['فاكهة برتقالية اللون.'], solution: ['Orange = برتقالة'], explanation: 'صحيح.' }),
    tf(L, 'p', c1, 'كلمة Lemon تعني «فراولة».', false, { hints: ['Lemon فاكهة صفراء حامضة.'], solution: ['Lemon = ليمونة'], explanation: 'Lemon تعني ليمونة.' }),
    mp(L, 'p', c1, 'وصّل كل كلمة بمعناها', [
      { left: { text: 'Apple' }, right: { text: 'تفاحة' } },
      { left: { text: 'Banana' }, right: { text: 'موزة' } },
      { left: { text: 'Lemon' }, right: { text: 'ليمونة' } },
      { left: { text: 'Grapes' }, right: { text: 'عنب' } },
    ], { hints: ['ابدأ بالكلمات التي تعرفها جيدًا.'], solution: ['Apple = تفاحة', 'Banana = موزة', 'Lemon = ليمونة', 'Grapes = عنب'] }),
  ];
  reset();
  const quiz = [
    choice(L, 'q', c1, 'ما معنى Strawberry؟', ['فراولة', 'عنب', 'تفاحة', 'ليمونة'], 0),
    choice(L, 'q', c1, 'كيف نقول «عنب» بالإنجليزية؟', ['Grapes', 'Apple', 'Lemon', 'Banana'], 0),
    choice(L, 'q', c1, 'ما معنى Lemon؟', ['ليمونة', 'برتقالة', 'موزة', 'فراولة'], 0),
    choice(L, 'q', c1, 'أكمل: I eat an ____ . (تفاحة)', ['apple', 'banana', 'orange', 'lemon'], 0),
    choice(L, 'q', c1, 'كيف نقول «برتقالة»؟', ['Orange', 'Lemon', 'Apple', 'Grapes'], 0),
    choice(L, 'q', c1, 'ما معنى Banana؟', ['موزة', 'عنب', 'تفاحة', 'فراولة'], 0),
    lc(L, 'q', c1, 'Apple', ['apple', 'orange', 'banana', 'grapes'], 0),
    lc(L, 'q', c1, 'Strawberry', ['strawberry', 'lemon', 'apple', 'grapes'], 0),
  ];
  return {
    lessonId: L,
    note: 'محتوى تجريبي مؤقت ينتظر مراجعة معلم.',
    words,
    video: null,
    practice,
    quiz,
  };
}

module.exports = [newFriends(), fruits()];

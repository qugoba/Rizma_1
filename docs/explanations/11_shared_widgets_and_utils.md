# 11 — المكوّنات المشتركة والثيم والأدوات والكتالوج

كل ما في `lib/core/` وما يشبهه مما تستعمله أكثر من شاشة. لكل عنصر: ما هو، معاملاته، لماذا كُتب هكذا، وأين يُستعمل.

## الثيم (`core/theme/`)

### `AppColors`
**(تحديث التصميم الجديد)** القيم صارت من لوحة «رِزمة — التصميم الجديد» في Figma. الأسماء القديمة بقيت حتى لا تتغيّر الشاشات، لكن قيمها تغيّرت:
- الأسطح: `bg` (`#EDFCFF` سماوي فاتح، خلفية الصفوف 1–6) و`cream` (`#F4F5F1`، خلفية الصفوف 7–12)، و`ground = bg` (الافتراضي قبل معرفة الصف)، `card`، `sky` (`#DCF5FA`) و`sky2` (`#C6EAF1`، مسار الأشرطة وحافة البطاقة البيضاء)، و`mute = sky` و`track = sky2`، و`line` (`#CBE8ED`)، `disabled`، `placeholder`.
- النصوص: `ink`، `soft` (`#3E4945`، أغمق من قبل لوضوح أكبر)، و`muteText` (`#6E7A74`) للنص الخافت.
- عائلات اللون بنمط `X / XDark / XTint`: `teal`، `amber` (`#FFB54D` مع `amberDark` و`amberInk` للنص فوقه)، `coral`، `blue`، `purple`، وجديد: `mint`، `red/redTint` للخطأ، و`star` للنجوم.

### `RizmaLook` (`rizma_look.dart`) — جديد
«طابع» الواجهة حسب عمر الطالب، من جدول «قواعد النسخة المعتمدة» في التصميم. `ThemeExtension` فيه: `calm`، `background`، `ledgeDepth` (سماكة الحافة السفلية)، `cardBorderWidth`، `buttonHeight`.
- `RizmaLook.playful` للصفوف 1–6 (والافتراضي قبل اختيار ملف): خلفية `bg`، حافة 4، بلا حدود، أزرار 56.
- `RizmaLook.quiet` للصفوف 7–12: خلفية `cream`، حافة 2 خفيفة، حدّ رفيع 1.5، أزرار 52.
- `RizmaLook.forGrade(grade)` يختار الطابع، و`RizmaLook.of(context)` يقرؤه من الثيم.
- **لماذا امتداد ثيم لا قيمة ثابتة؟** لأن الطابع يتغيّر حين يتبدّل الملف النشط؛ `RizmaApp` يبني الثيم من صف الطالب فتتحدّث كل الشاشات تلقائيًا بلا تمرير معامل لكل ودجت.

### `AppTextStyles`
أنماط Cairo. الاسم يحمل الحجم (`heading22`, `body15`…) لمطابقة أسماء Figma. **جديد من التصميم:** `display30`، `number30`، `big44` (الأرقام الضخمة كنتيجة الاختبار)، `h3_17`، `bodyL16`، `caption12`. ونص الأزرار `button16` صار 17/ExtraBold كما في «Button» (الاسم بقي للتوافق). تُبنى بدالة خاصة `_cairo(size, weight, height, color)`؛ `height` مضاعف لحجم الخط (يطابق `line-height` غير المقيّد بوحدة في Figma). لتغيير اللون فقط نستعمل `copyWith(color: …)` بدل نمط جديد.

### `AppTheme.forLook(look)` و`AppTheme.light`
`ThemeData` بـ Material 3، لوحة ألوان من `teal` مع تثبيت `primary/surface/onSurface/error`، و`scaffoldBackgroundColor` وخلفية الأوراق السفلية من `look.background`، و`extensions: [look]`، و`fontFamily: 'Cairo'`. `light` = `forLook(RizmaLook.playful)`. الأوراق السفلية لم تعد تمرّر `backgroundColor` بنفسها بل تأخذه من `bottomSheetTheme`.

### `ProfileColorPalette` (`profile_palette.dart`)
امتداد على `ProfileColor` يعطي أربعة ألوان: `body` (جسم التميمة)، `dark` (ظلّها الغامق — جديد مع التميمة الجديدة)، `fold` (الورقتان فوق الدفتر)، `avatarBackground` (خلفية الأفاتار الفاتحة). **(الجولة الثانية)** تغيّر جسما المرجاني والعنبري ليطابقا التصميم. القيم من `design_spec/README.md`. يستعملها أيضًا الكتالوج لتلوين المواد.

## المكوّنات (`core/widgets/`)

| المكوّن | المعاملات | ما يفعله ولماذا |
|---|---|---|
| `LedgeBox` و`ledgeEdgeFor` (`ledge.dart`) — جديد | `child`, `color`, `edge?`, `radius`, `depth?`, `border?`, `padding?`, `clip` | «الحافة السفلية» (Ledge) في التصميم: ظل صلب بلا تمويه (`BoxShadow` بإزاحة رأسية) يعطي إحساس الزر الملموس. يحجز مساحة الحافة أسفله (`Padding`) فلا يتراكب مع ما تحته. `depth` الافتراضي من الطابع (4/2). الحدّ يُرسم **فوق** المحتوى (`DecorationPosition.foreground`) حتى لا يغطيه `Material` داخلي. `ledgeEdgeFor(fill)` يختار لون الحافة: أخضر فوق أخضر غامق، عنبري فوق عنبري غامق، أبيض فوق سماوي. |
| `OfflineChip` (`offline_chip.dart`) — جديد | — | شارة «دون إنترنت» الصغيرة. قاعدة التصميم: الحالة تظهر **مرة واحدة** في الشريط العلوي لا في كل بطاقة. |
| `RizmaButton` + `ButtonKind` | `label`, `onPressed?`, `kind`, `icon?`, `height?` | الزر العريض بحافة سفلية. الأنواع: `filled`، `outlined` (أبيض بنص أخضر)، `soft`، `neutral` (سماوي)، `ink`، `amber` (عنبري ممتلئ)، `coral` (جديد). الارتفاع من الطابع ما لم يُحدَّد. يحجز مساحة الحافة دائمًا فلا يقفز حين يُعطَّل. |
| `PrimaryButton` | `label`, `onPressed?`, `iconAsset?`, `height?`, `backgroundColor`, `foregroundColor` | الزر العريض (بحافة سفلية الآن، وارتفاعه من الطابع). `onPressed == null` = معطّل (رمادي `disabled`) كالمعتاد في Flutter. `Material` + `InkWell` ليظهر التموّج فوق اللون. `Semantics` تعلن زرًّا بحالته. الأيقونة **أول** عنصر في الصف فتظهر يمين النص (RTL) كما في Figma. |
| `IconTile` | `asset?` أو `iconData?` أو `iconName?`, `iconColor?`, `color`, `size=48`, `iconSize=24`, `radius=14` | مربع ملوّن بأيقونة وسطه: SVG من Figma، أو أيقونة Material، أو اسم من مجموعة أيقونات التصميم (`assert` يتأكد من تمرير واحد فقط). منذ الجولة الثانية صارت الشاشات تستعمل `iconName` غالبًا. |
| `ProgressBar` | `value (0..1)`, `trackColor`, `fillColor`, `height=6` | شريط تقدّم كبسولي. المحاذاة `AlignmentDirectional.centerStart` فتبدأ التعبئة من **اليمين** في RTL. `FractionallySizedBox` يحسب العرض نسبيًا بلا `LayoutBuilder`. |
| `BottomNav` + `RizmaTab` | `current`, `onSelected` | الشريط السفلي: الرئيسية · المواد · تقدّمي · حسابي (الأولى يمينًا). الأيقونات خطوط بلون واحد فتُصبغ بـ `ColorFilter.mode(srcIn)` بلون التبويب (teal للمحدَّد، `soft` لغيره) فنستعمل ملفًا واحدًا لكل أيقونة. |
| `Mascot` + `MascotMood` | `size`, `color`, `mood` | **(الجولة الثانية)** تميمة Figma الجديدة (دفتر بشريط أحمر وورقتين) بثلاث حالات: `happy` و`sleepy` و`thinking` (التلميحات والرمز الخاطئ). SVG لكل حالة + `ColorMapper` يستبدل ثلاثة ألوان (الجسم `#177A63`، الغامق `#0E5C4A`، الورقة `#7FD7BC`) ويحافظ على الشفافية (الظلّ). `==`/`hashCode` على المبدّل ليعمل تخزين flutter_svg المؤقت. |
| `TagChip` (`tag_chip.dart`) — جديد | `label`, `icon?`, `background`, `foreground`, `outline` | **(الجولة الثانية)** الشارة الصغيرة المتكرّرة في التصميم («جاهز»، «مكتملة»، «4 دروس»، «محمّل»…). نص بسطر واحد يُقصّ بـ «…» إن ضاق، والأيقونة بعده. `outline` يرسمها بيضاء بحدّ ملوّن. |
| `BackTile` / `ScreenTopBar` | `onTap` / `title`, `subtitle?`, `onBack`, `end?`, `showOffline=true` | زر رجوع مربّع 44 **أبيض بحافة سفلية** (أيقونته سهم لليمين = الرجوع في RTL) وشريط علوي: رجوع + عنوان + عنصر في الطرف الآخر. إن لم يُمرَّر `end` تظهر `OfflineChip` (قاعدة «الحالة مرة واحدة في الشريط العلوي»). |
| `RizmaSwitch` | `value`, `onChanged`, `semanticsLabel` | مفتاح 52×32. المقبض يبدأ من اليمين وهو مطفأ (RTL) عبر `AlignmentDirectional`. `Semantics(toggled:)`. |
| `RizmaCard` | `child`, `padding`, `color` | بطاقة بزوايا 20 مبنية على `LedgeBox`: بلا حدّ وبحافة سماوية في الطابع المرح، وبحدّ رفيع وحافة خفيفة في الهادئ. |
| `DashedBorderBox` | `color`, `radius`, `strokeWidth`, `dash`, `gap`, `padding` | حد منقّط للصناديق الفارغة. `CustomPainter` يمرّ على `PathMetric` لمستطيل مدوّر ويرسم مقاطع قصيرة. |
| `PinDots` / `PinPad` | انظر `08_pin_entry_and_forgot.md` | نقاط الرمز السري ولوحة الأرقام (RTL منذ الجولة الثانية: «1» يمينًا). |

## الأدوات الصرفة (`core/utils/`)

| الملف | الدوال | ملاحظات |
|---|---|---|
| `student_code.dart` | `generate`, `isValid`, `normalize`, `generateUnique` | `RZ-XXXX` بأحرف بلا 0/O/1/I/L. الطول ثابت `randomLength`. التفرّد المحلي عبر استعلام القاعدة. |
| `pin_hasher.dart` | `PinHasher.hash/verify/generateSalt/isValidFormat` و`PinLockout` | SHA-256 مع salt، مقارنة بزمن ثابت، قفل 5 محاولات/30 ثانية. انظر `02_profiles_and_pin.md`. |
| `class_code.dart` | `normalize`, `isValid` | أحرف كبيرة بلا مسافات؛ حروف/أرقام/شرطة، حتى 16. |
| `streak.dart` | `currentStreak(times, now)` | أيام متتالية حتى اليوم (أو أمس). |

## النصوص (`core/strings/ar.dart`)
كل النصوص الظاهرة مجمّعة حسب الشاشة، مع دوال للنصوص المركّبة (`homeGreeting(name)`, `continueWithGrade(g)`…).
- **صيغ الجمع العربية:** `stars(n)`: 0 → «0 نجوم»، 1 → «نجمة واحدة»، 2 → «نجمتان»، 3–10 → «N نجوم»، 11+ → «N نجمة». `streakDays(n)`: «يوم واحد متتالٍ»، «يومان متتاليان»، «N أيام متتالية»، «N يومًا متتاليًا».
- `gradeName(g)` يحوّل 1–12 إلى «الصف الخامس» إلخ (قائمة صريحة لأن «الحادي عشر» و«الثاني عشر» لها قواعدها).
- `colorName(color)` أسماء الألوان لقارئ الشاشة.

## الكتالوج (`features/catalog/`)
| الملف | الدور |
|---|---|
| `assets/content/catalog_grade5.json` | مواد ← وحدات ← دروس ← مفاهيم (3 مواد، 6 وحدات، 12 درسًا). **العناوين مؤقتة وتنتظر مراجعة معلم** (حقل `_note`). |
| `catalog_models.dart` | `Catalog`, `CatalogSubject`, `CatalogUnit`, `CatalogLesson`, `CatalogConcept` مع `fromJson`. `Catalog` يبني فهارس سريعة: `lessonById`, `subjectById`, `unitOfLesson`, `nextLessonInSubject`, `conceptById`, `firstLesson`, `allLessons`. |
| `catalog_repository.dart` | يقرأ JSON من الأصول مرة واحدة ويحفظه (`loadString` قابلة للحقن للاختبار). إن كبر الملف لاحقًا يُنقل التحليل إلى `compute`. |
| `catalog_providers.dart` | `catalogRepositoryProvider` و`catalogProvider` (`FutureProvider`). |
| `subject_visuals.dart` | `subjectIconAsset(key)`: مفتاح الأيقونة ← ملف SVG. |

الواجهة **لا تكتب أسماء المواد والدروس في الكود**؛ تقرأها من الكتالوج.

## ملاحظة عن الشاشات الضيقة
`PinPad` ملفوف بـ `FittedBox(scaleDown)` (عرضه الطبيعي 300 بعد تكبير المفاتيح إلى 88×60)، و`BottomNav` يستعمل `Flexible` لكل تبويب و`FittedBox` لنص الاسم، فلا يفيضان على شاشة 320 أو بخط مكبّر. التفاصيل في `00_architecture.md` و`12_testing.md`.

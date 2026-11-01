# 09 — `HomeState`: الرئيسية مشتقّة من البيانات

**الملفات:** `lib/features/home/home_state.dart` · `home_providers.dart` · `lib/core/utils/streak.dart`

## الغرض
الرئيسية لا تحتوي أي رقم أو اسم ثابت. كل ما تعرضه يُشتقّ من **قاعدة البيانات والكتالوج للملف النشط**:
- طالب جديد ← شاشة 28 «أول يوم».
- بعد أول نشاط ← شاشة 03 بنجومه وسلسلته وتقدّمه.

`HomeState` هو الوسيط: كائن غير قابل للتغيير يصف «ما يجب أن تعرضه الشاشة». يُبنى بدالة **صرفة** (`HomeState.derive`) فتُختبر بلا واجهة (`test/features/home_state_test.dart`، 16 اختبارًا).

## المدخلات
| المدخل | المصدر |
|---|---|
| `profile` | `activeProfileProvider` |
| `catalog` | `catalogProvider` (من `catalog_grade5.json`) |
| `progress` | `lessonProgressProvider(profileId)` ← جدول `lesson_progress` |
| `attempts` | `attemptsProvider(profileId)` ← جدول `attempts` |
| `mastery` | `masteryProvider(profileId)` ← جدول `concept_mastery` |
| `now` | `clockProvider` (الساعة، قابلة للاستبدال في الاختبارات) |

## `homeStateProvider`
`Provider.autoDispose<AsyncValue<HomeState?>>` يجمع المزوّدات الخمسة:
- أي مصدر `error` ← `AsyncError`.
- ملف نشط `null` ← `AsyncData(null)` (الشاشة تعرض فراغًا والراوتر يعيد للإقلاع).
- أي مصدر لم يصل بعد ← `AsyncLoading`.
- وإلا `AsyncData(HomeState.derive(...))`.
لأن كل مصدر `StreamProvider`، أي تغيير في القاعدة (محاولة جديدة، تقدّم درس…) يعيد حساب الحالة وتتحدّث الشاشة وحدها.

## حقول `HomeState`
| الحقل | كيف يُحسب |
|---|---|
| `hasActivity` | `attempts` غير فارغة **أو** أي صف تقدّم حالته ≠ `notStarted` |
| `isFirstDay` | `!hasActivity` |
| `stars` | مجموع `starsEarned` لكل المحاولات |
| `streak` | `currentStreak(أوقات المحاولات + أوقات صفوف التقدّم غير notStarted, now)` |
| `featured` | الدرس المعروض في البطاقة الخضراء (القاعدة أدناه) |
| `firstSteps` | `downloaded`: أي تقدّم؛ `practiced`: محاولة `practice`؛ `quizzed`: محاولة `quiz` |
| `subjects` | لكل مادة: المكتمل ÷ الدروس + هل بدأت |
| `hasQuizAttempt` | وجود محاولة `quiz` |
| `review` | المفاهيم ذات الإتقان < 0.6 (أقصاها 3، من الأضعف) |
| `showReviewSection` | `hasQuizAttempt && review.isNotEmpty` |
| `showReviewPlaceholder` | `isFirstDay` (صندوق منقّط بدل المراجعة) |

### الدرس المعروض (`_pickFeatured`)
1. **بلا نشاط** ← أول درس في الكتالوج (`catalog.firstLesson`).
2. وإلا أحدث درس `inProgress` (بحسب `updatedAt`).
3. وإلا آخر درس لُمس: إن لم يكتمل (مثل `downloaded`) فهو نفسه؛ وإن اكتمل فالدرس **التالي في المادة** إن لم يكتمل؛ وإلا أول درس غير مكتمل في الكتالوج؛ وإن اكتمل كل شيء فآخر درس.

نسبة التقدّم في البطاقة (`LessonRef.progress`): `completed` = 1، `inProgress` = قيمة `progress` مقيّدة بين 0 و1، غير ذلك 0.

### السلسلة (`currentStreak`)
عدد الأيام المتتالية التي فيها نشاط. تنتهي **اليوم** إن وُجد نشاط اليوم، وإلا **أمس** (السلسلة ما زالت حيّة حتى نهاية اليوم)، وإن لم يكن اليوم ولا أمس فـ 0. أنشطة اليوم الواحد تُحسب يومًا واحدًا. (`test/core/streak_test.dart`).

### قسم المراجعة
- يظهر **فقط** بعد وجود محاولة `quiz` (حتى لو وُجد إتقان منخفض من مصدر آخر).
- العتبة `kReviewMasteryThreshold = 0.6` والحد الأقصى `kMaxReviewItems = 3` ثابتان في أعلى الملف.
- مفهوم غير موجود في الكتالوج يُتجاهل (حماية من بيانات قديمة).
- لا نعرض «خطة من 4 خطوات» الموجودة في Figma لأن خطة المراجعة (شاشة 16) غير مبنية؛ نعرض «الإتقان N%» فقط.

## ما لم يُبنَ عمدًا
صف «تحدّي اليوم» (موجود في Figma شاشة 03) لم يُضف: لا توجد أسئلة ولا نجوم قصوى حقيقية خلفه، وأرقامه («5 أسئلة · حتى 15 نجمة») أمثلة. يُضاف مع شاشات التدريب.

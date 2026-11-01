# 16 — هوية التطبيق: الاسم والأيقونة وشاشة البداية

**الملفات:** `branding/*.svg` · `android/app/src/main/res/` · `android/app/src/main/AndroidManifest.xml` · `ios/Runner/` · `web/` · `lib/app/rizma_app.dart`

## الاسم
| أين | القيمة |
|---|---|
| اسم الأيقونة على أندرويد | `android:label="Rizma"` في `AndroidManifest.xml` |
| iOS | `CFBundleDisplayName` و`CFBundleName` = `Rizma` |
| الويب | `web/manifest.json` (`name` و`short_name`) و`<title>` و`apple-mobile-web-app-title` |
| مبدّل المهام (Recents) | `MaterialApp.router(title: 'Rizma')` |
| داخل الواجهة | يبقى الشعار العربي «رِزمة» (`ArStrings.appName`) كما في تصميم Figma |

اسم حزمة التطبيق (`com.rizma.rizma`) واسم مشروع Dart (`rizma`) لم يتغيّرا: تغييرهما يكسر التثبيت فوق النسخة السابقة وبيانات الطلاب المحفوظة.

## الأيقونة
**التصميم:** تميمة التصميم الجديد (دفتر أخضر بشريط أحمر وورقتين، مصدرها `assets/images/brand/rizma_mascot.svg`) على خلفية الحبر `#0F2A2E`، كما في شاشة الترحيب، فتكون الأيقونة امتدادًا مباشرًا للهوية. التميمة بارتفاع نحو 64% من الأيقونة لتبقى كاملة بعد قصّ أي شكل (دائرة، مربع مدوّر…).

**تحديث (التميمة الجديدة):** كانت الأيقونة مبنية على التميمة القديمة (ورقة بزاوية مطوية). أُعيد توليد كل ملفات الأيقونة والبداية من التميمة الجديدة: ملفات `branding/` والمتجهات في `android/.../drawable/` (`ic_launcher_foreground` و`ic_launcher_monochrome` و`ic_mascot` و`ic_splash_icon`) وصور `mipmap-*` وأيقونات iOS و`LaunchImage*` وأيقونات الويب.

**المصدر الوحيد:** `branding/` (ليس ضمن أصول التطبيق، لا يُضمَّن في الـ APK):
- `app_icon.svg`: مربع كامل بلا زوايا (iOS وmaskable).
- `app_icon_rounded.svg`: زوايا مدوّرة (أندرويد القديم، الويب، favicon).
- `mascot_only.svg` و`mascot_tight.svg`: الشخصية وحدها بخلفية شفافة.
كل ملفات الأيقونات الأخرى مولَّدة منها (تحويل SVG إلى PNG بالأحجام المطلوبة) فلا تُعدَّل يدويًا.

**أندرويد:**
- **أندرويد 8+ (الأيقونة التكيّفية):** `mipmap-anydpi-v26/ic_launcher.xml` = خلفية لونية (`ic_launcher_background`) + مقدّمة متجهية (`ic_launcher_foreground`: الشخصية بمقياس 0.6 حول مركزها لتبقى داخل «المنطقة الآمنة» 66dp) + طبقة أحادية اللون (`ic_launcher_monochrome`) لأيقونات الثيم في أندرويد 13. المتجهات (vector drawables) تتحوّل لأي كثافة بلا ملفات PNG.
- **أندرويد 7 (minSdk 24):** صور `mipmap-*/ic_launcher.png` بخمس كثافات.
- **أحادية اللون:** عينان مثقوبتان (`evenOdd`) بلا ابتسامة، لأن أي عنصر يُرسم فوق الجسم بنفس الشفافية لن يظهر.

**iOS:** 15 حجمًا في `AppIcon.appiconset` من `app_icon.svg` (مربعة معتمة بلا زوايا مدوّرة: iOS يقصّها بنفسه).

**الويب:** `icons/Icon-192/512` (مدوّرة)، و`Icon-maskable-192/512` (مربعة لأن المتصفح يقصّها)، و`favicon.png`.

## شاشة البداية
الهدف: انتقال بلا وميض من لحظة فتح التطبيق إلى أول إطار من Flutter. شاشة الإقلاع في Flutter (`LaunchScreen`) خلفيتها لون الثيم، وهو قبل معرفة الملف `AppColors.bg` `#EDFCFF` (كان `#F4F5F1` قبل التصميم الجديد)، والشخصية في المنتصف؛ فشاشة البداية الأصلية تستعمل **نفس اللون ونفس الشخصية**.
- **أندرويد قبل 12:** `drawable/launch_background.xml` (و`drawable-v21`): لون `splash_background` + `ic_mascot` (96dp) في المنتصف.
- **أندرويد 12+:** واجهة الشاشة الرسمية في `values-v31/styles.xml`: `windowSplashScreenBackground` و`windowSplashScreenAnimatedIcon` (`ic_splash_icon`: الشخصية بمقياس 0.5 داخل دائرة 192dp). خلفية النافذة لون فقط حتى لا تتكرر الشخصية.
- **الوضع الليلي للجهاز:** `values-night` تستعمل الثيم الفاتح نفسه، لأن التطبيق فاتح فقط (لا ثيم داكن بعد)، وإلا ظهر وميض أسود قبل الواجهة الفاتحة.
- **iOS:** `LaunchScreen.storyboard` بخلفية `#EDFCFF` وصورة الشخصية (ثلاث دقّات).
- **الويب:** `manifest.json` بـ `background_color` نفسه `#EDFCFF`.
- **عند تغيير خلفية التطبيق** يجب تغيير هذه الأماكن الثلاثة معها (`colors.xml`، الـ storyboard، `manifest.json`) وإلا ظهر وميض لوني عند الفتح.

## ما لم نفعله
- **لم نضف حزمة** (`flutter_launcher_icons` أو `flutter_native_splash`) لأن الملفات المطلوبة قليلة ومعروفة، ولا نريد تبعية جديدة تحتاج اتفاقًا (ومشاكل نسخ `meta` المثبّتة عندنا).
- **لم نختبر iOS** (لا Mac هنا)؛ الملفات وُلِّدت بالأحجام الصحيحة من القائمة الرسمية.
- **لم تُجرَّب الأيقونة التكيّفية على أجهزة متعددة**؛ تحقق منها على جوالك (شكل الأيقونة وإن كان ثيم الأيقونات مفعّلًا في أندرويد 13+).

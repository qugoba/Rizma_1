# أدوات المحتوى

| الأداة | ماذا تفعل |
|---|---|
| `build_catalog.js` | يولّد `assets/content/catalog_grade5.json` |
| `build_lessons.js` | يولّد `assets/content/lessons/*.json` ويفحص الأسئلة |
| `keygen.js` | يولّد مفتاح توقيع الفهارس (مرة واحدة) |
| `publish.js` | يجهّز الدروس للنشر على مخزن الدروس، ويوقّع الفهرس (ADR 002) |
| `upload.js` | يرفع ما جهّزه `publish.js` إلى حاوية R2 |

## مفتاح التوقيع (مرة واحدة، مسؤول المحتوى)
```bash
node tools/content/keygen.js D:/keys/rizma-content-key.pem
```
- **المفتاح الخاص** يُحفظ خارج المستودع (الأداة ترفض غير ذلك)، مع نسخة احتياطية عند قائد الفريق. من يملكه يستطيع نشر أي محتوى للأطفال.
- **المفتاح العام** (السطر الأخير) يوضع في `ContentConfig.publishedKeys` في `lib/features/downloads/download_service.dart`.

## النشر
```bash
node tools/content/build_lessons.js
node tools/content/publish.js --grade 5 --dry-run
node tools/content/publish.js --grade 5 --key D:/keys/rizma-content-key.pem
```
1. `--dry-run` يعرض ما تغيّر (الدروس ونسخها الجديدة، وحجم الملفات الجديدة) دون كتابة.
2. بدونها: يكتب في `build/content/` بنفس ترتيب المخزن:
   - `v1/blobs/<sha256>` كل ملف باسم بصمته.
   - `v1/grades/5/manifest.json` و`.sig`.
3. **الرفع** (`upload.js`): الملفات الناقصة أولًا، ثم الفهرس وتوقيعه **آخر شيء**.
4. احفظ `tools/content/published/grade5.manifest.json` في المستودع بعد الرفع: منه يعرف النشر التالي أرقام النسخ.

## الرفع إلى R2
الحاوية: `rizma-content`. مفاتيح R2 تُنشأ من لوحة Cloudflare: **R2 ← Manage API Tokens ← Create** بصلاحية **Object Read & Write** على `rizma-content` وحدها. تُوضع في الطرفية فقط، لا في ملف ولا في المستودع:

```powershell
$env:R2_ACCOUNT_ID = "<Account ID>"
$env:R2_ACCESS_KEY_ID = "<Access Key ID>"
$env:R2_SECRET_ACCESS_KEY = "<Secret Access Key>"
node tools/content/upload.js --grade 5 --dry-run
node tools/content/upload.js --grade 5
```
- ما هو موجود على المخزن باسم بصمته لا يُرفع ثانية.
- قبل أي اتصال تُفحص بصمة كل ملف محليًا؛ ملف لا يطابق يوقف الرفع.
- `node tools/content/upload.js --self-test` يتأكد أن توقيع الطلبات (SigV4) يطابق مثال AWS الموثّق.
- **الرابط العام:** للتجربة، فعّل **Public Development URL** من إعدادات الحاوية (يعطي `https://pub-….r2.dev`)؛ للإنتاج دومين خاص (ADR 002، 4.1).

**الصور والفيديو:** في `content-media/<معرّف الدرس>/`. الصور (`img/*.webp`) تدخل حزمة الدرس، و`video.mp4` فيديو منفصل يُنزَّل باختيار الطالب. صيغة الفيديو في ADR 002 القسم 6.

**ملفات الدرس (ملخص PDF):** ضعها في `content-media/<معرّف الدرس>/attachments/`، واذكرها في الدرس (في `tools/content/<المادة>.js`):
`attachments: [{ title: 'ملخص الطالب', file: '<بصمة sha256>', sizeKb: <الحجم بالكيلوبايت مقربًا لأعلى> }]`.
لا تدخل حزمة الدرس: الطالب يفتحها من الإنترنت أو ينزّلها لتفتح دون اتصال. إن نسيت البصمة أو الحجم تخبرك `publish.js` بالقيمة الصحيحة. حد الملف 50 MB.

**قواعد** (ADR 002، القسم 7): معرّف الدرس والمفهوم والسؤال لا يتغيّر ولا يُعاد استعماله لشيء آخر. سؤال تغيّر معناه = معرّف جديد.

**نهايات السطور:** ملفات `assets/content/` لا تُحوَّل نهايات سطورها (`.gitattributes`)، لأن بصمتها يجب أن تطابق نسخة التطبيق على كل جهاز.

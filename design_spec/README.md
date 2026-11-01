# مواصفات تصميم الشاشات 25–29 وتعديل الشاشة 19 (رِزمة)

حصة Figma MCP انتهت، فهذا بديل لقراءة الإطارات. هذه الملفات هي **نفس السكربت الذي رسم الشاشات في Figma**، لذلك فيها القيم الدقيقة: النصوص، الألوان، المسافات، الأحجام، الزوايا، وترتيب العناصر.

## الملفات
- `screens_25-29_and_19.js` هو المرجع الأساسي. لكل شاشة كتلة `{ ... }` تبدأ بـ `SCREEN(S,'25 ...')`، وفي آخره تعديل الشاشة 19 (مجموعة «الملف»).
- `builder_helpers.js` فيه معنى الدوال المساعدة.
- `mascot.js` يرسم الشخصية بالألوان الخمسة.
- `overview_25-29.png` و`screen_19.png` لقطات مصغّرة للاسترشاد البصري فقط.

## كيف تقرأ السكربت
- الإطار عرضه 390 وارتفاعه الأدنى 844. خلفية الشاشة `#F4F5F1`.
- `AL(parent, 'VERTICAL'|'HORIZONTAL', {gap, pad, r, bg, stroke, w, h})` = Column أو Row.
  - `pad` إما رقم، أو `[v,h]`، أو `[top,right,bottom,left]`.
  - `r` = borderRadius.
  - `w:'fill'` أو عدم ذكره داخل عمود = عرض كامل.
- `R(parent, opts, build)` = Row بترتيب RTL: **أول عنصر يُبنى يظهر في أقصى اليمين**. في Flutter استخدم `Row` عاديًا تحت `Directionality.rtl` وبنفس ترتيب البناء.
- `T(parent, text, style, color)` = Text. الـ style اسم من أنماط النص: `Title/26`، `Heading/22`، `Section/18`، `Body/16 Strong`، `Body/16`، `Body/15`، `Label/14`، `Caption/13`. هذه موجودة في `app_text_styles.dart`، وإذا كان style كائنًا `{size, w, lh}` فهو نمط مباشر بخط Cairo.
- `TILE(p, icon, fg, bg, box, iconSize, r)` = مربع أيقونة ملوّن (IconTile).
- `CARD` = بطاقة بيضاء بحد `Line` وزاوية 20 وحشوة 16 افتراضيًا.
- `BTN` = زر ارتفاعه 52 وزاويته 16.
- `FIN(...)` ثم `spacer` = ما بعده يُدفع إلى أسفل الشاشة (Spacer).
- `dashPattern` = حد منقّط.
- لوحة الأرقام في 27 مبنية **LTR عمدًا**: 1 2 3 / 4 5 6 / 7 8 9 / فراغ 0 حذف.

## الألوان
| الاسم | القيمة |
|---|---|
| Teal | #177A63 |
| TealTint | #DCEFE6 |
| Ink | #0F2A2E |
| Card | #FFFFFF |
| Line | #E1E6E2 |
| Soft | #55655F |
| Mute | #E6EAE5 |
| Track | #DDE3DF |
| Disabled | #C9D2CD |
| AmberDark | #8F540A |
| AmberTint | #FCEFD6 |
| Coral | #B94F2A |
| CoralTint | #F8E1D7 |
| Blue | #2F66C9 |
| Purple | #6A4FB3 |

## ألوان الشخصية (لـ ColorMapper)
الشخصية الأصلية لونها teal: الجسم `#177A63` والزاوية المطوية `#7ED3B2`. استبدل هذين اللونين فقط بالقيم التالية:

| اللون | الجسم | الزاوية المطوية | خلفية الأفاتار |
|---|---|---|---|
| teal | #177A63 | #7ED3B2 | #DCEFE6 |
| coral | #B94F2A | #F3B9A3 | #F8E1D7 |
| blue | #2F66C9 | #A9C2F0 | #DEE7F8 |
| purple | #6A4FB3 | #C9BCEB | #E9E3F6 |
| amber | #B07316 | #F1D29C | #FCEFD6 |

حلقة اللون المختار في شاشة 26 هي حد Ink بسماكة 3، والدائرة 56 والنقطة الداخلية 42.

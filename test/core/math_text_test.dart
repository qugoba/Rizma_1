import 'package:flutter_test/flutter_test.dart';
import 'package:rizma/core/widgets/math_text.dart';

const lri = '\u2066';
const pdi = '\u2069';

void main() {
  test('الجملة الإنجليزية تُعزل باتجاهها مع ترقيمها', () {
    expect(
      MathText.isolateLatin('اختر الصحيح: He ____ in Ramallah.'),
      'اختر الصحيح: ${lri}He ____ in Ramallah.$pdi',
    );
    expect(
      MathText.isolateLatin('What do you like doing? اختر الجواب الصحيح'),
      '${lri}What do you like doing?$pdi اختر الجواب الصحيح',
    );
  });

  test('الخانة الفارغة جزء من الجملة الإنجليزية', () {
    expect(
      MathText.isolateLatin('أكمل: She {?} have a sister.'),
      'أكمل: ${lri}She {?} have a sister.$pdi',
    );
  });

  test('كلمة واحدة، وعلامة الاستفهام العربية تبقى خارجها', () {
    expect(
      MathText.isolateLatin('ما معنى كلمة twin؟'),
      'ما معنى كلمة ${lri}twin$pdi؟',
    );
  });

  test('نص إنجليزي كله، أو عربي ورياضيات بلا إنجليزية: كما هو', () {
    expect(
      MathText.isolateLatin('Ben is from Palestine.'),
      'Ben is from Palestine.',
    );
    expect(
      MathText.isolateLatin('ما ناتج {1/2} + {1/4}؟'),
      'ما ناتج {1/2} + {1/4}؟',
    );
  });
}

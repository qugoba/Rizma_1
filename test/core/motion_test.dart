import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rizma/core/widgets/fade_slide_in.dart';
import 'package:rizma/core/widgets/pressable_scale.dart';

void main() {
  group('PressableScale', () {
    testWidgets('يصغّر أثناء الضغط ويعود بعد الرفع', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: GestureDetector(
              onTap: () => taps++,
              child: const SizedBox(width: 100, height: 50, child: Text('x')),
            ).pressable(),
          ),
        ),
      );

      double scale() =>
          tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale;
      expect(scale(), 1);

      final gesture = await tester.startGesture(
        tester.getCenter(find.text('x')),
      );
      await tester.pump();
      expect(scale(), 0.97);

      await gesture.up();
      await tester.pumpAndSettle();
      expect(scale(), 1);
      expect(taps, 1);
    });

    testWidgets('معطّل: لا يتغيّر الحجم', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Center(child: PressableScale(enabled: false, child: Text('x'))),
        ),
      );
      final gesture = await tester.startGesture(
        tester.getCenter(find.text('x')),
      );
      await tester.pump();
      expect(tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale, 1);
      await gesture.up();
    });
  });

  group('FadeSlideIn', () {
    double opacity(WidgetTester tester) =>
        tester.widget<Opacity>(find.byType(Opacity)).opacity;

    testWidgets('يبدأ شفافًا ثم يكتمل ولا يترك مؤقّتات', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: FadeSlideIn(child: Text('x'))),
      );
      expect(opacity(tester), 0);

      await tester.pump(const Duration(milliseconds: 160));
      expect(opacity(tester), inExclusiveRange(0, 1));

      await tester.pumpAndSettle();
      expect(opacity(tester), 1);
    });

    testWidgets('التأخير يبقيه شفافًا حتى يحين دوره', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: const Text('x').fadeIn(4)),
      );
      await tester.pump(const Duration(milliseconds: 120));
      expect(opacity(tester), 0);

      await tester.pumpAndSettle();
      expect(opacity(tester), 1);
    });
  });
}

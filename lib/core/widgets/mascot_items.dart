import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../db/enums.dart';
import '../theme/app_colors.dart';
import 'mascot.dart';

class MascotWithItems extends StatelessWidget {
  const MascotWithItems({
    super.key,
    required this.size,
    this.color = ProfileColor.teal,
    this.items = const {},
  });

  final double size;
  final ProfileColor color;

  final Set<String> items;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Mascot(size: size, color: color),
          if (items.isNotEmpty)
            Positioned.fill(
              child: CustomPaint(painter: AccessoryPainter(items)),
            ),
        ],
      ),
    );
  }
}

class AccessoryPainter extends CustomPainter {
  AccessoryPainter(this.items);

  final Set<String> items;

  static const _ink = AppColors.ink;
  static const _amber = Color(0xFFF2B650);
  static const _red = Color(0xFFB94F2A);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 150, size.height / 150);
    if (items.contains('scarf')) _scarf(canvas);
    if (items.contains('glasses')) _glasses(canvas);
    if (items.contains('star')) _star(canvas);
    if (items.contains('cap')) _cap(canvas);
    canvas.restore();
  }

  void _cap(Canvas canvas) {
    final fill = Paint()..color = _ink;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(48, 18, 44, 16),
        const Radius.circular(5),
      ),
      fill,
    );
    final board = Path()
      ..moveTo(70, 6)
      ..lineTo(112, 19)
      ..lineTo(70, 32)
      ..lineTo(28, 19)
      ..close();
    canvas.drawPath(board, fill);
    canvas.drawPath(
      board,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = const Color(0xFF143C3B),
    );
    final tassel = Paint()
      ..color = _amber
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(104, 21), const Offset(104, 38), tassel);
    canvas.drawCircle(const Offset(104, 40), 3.5, Paint()..color = _amber);
  }

  void _scarf(Canvas canvas) {
    final band = RRect.fromRectAndRadius(
      const Rect.fromLTWH(27, 106, 96, 15),
      const Radius.circular(7),
    );
    canvas.drawRRect(band, Paint()..color = _red);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(94, 114, 16, 24),
        const Radius.circular(5),
      ),
      Paint()..color = const Color(0xFF9A3F20),
    );
    final dot = Paint()..color = _amber;
    for (var x = 38.0; x < 120; x += 14) {
      canvas.drawCircle(Offset(x, 113.5), 2.4, dot);
    }
  }

  void _glasses(Canvas canvas) {
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = _ink;
    canvas.drawCircle(const Offset(63, 77), 14, stroke);
    canvas.drawCircle(const Offset(92, 77), 14, stroke);
    canvas.drawLine(const Offset(77, 76), const Offset(78, 76), stroke);
  }

  void _star(Canvas canvas) {
    const c = Offset(42, 50);
    const outer = 10.0;
    const inner = 4.4;
    final path = Path();
    for (var i = 0; i < 10; i++) {
      final r = i.isEven ? outer : inner;
      final a = -math.pi / 2 + i * math.pi / 5;
      final p = Offset(c.dx + r * math.cos(a), c.dy + r * math.sin(a));
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = _amber);
  }

  @override
  bool shouldRepaint(AccessoryPainter old) => !_same(old.items, items);

  static bool _same(Set<String> a, Set<String> b) =>
      a.length == b.length && a.containsAll(b);
}

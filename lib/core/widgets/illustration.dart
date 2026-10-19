import 'dart:math' as math;

import 'package:flutter/material.dart';

enum IllustrationKind { apple, orange, banana, grapes, lemon, strawberry }

class Illustration extends StatelessWidget {
  const Illustration(this.name, {super.key, this.size = 64});

  final String name;
  final double size;

  static IllustrationKind? kindOf(String name) {
    for (final k in IllustrationKind.values) {
      if (k.name == name) return k;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final kind = kindOf(name);
    return SizedBox(
      width: size,
      height: size,
      child: kind == null
          ? null
          : CustomPaint(painter: _FruitPainter(kind), size: Size(size, size)),
    );
  }
}

class _FruitPainter extends CustomPainter {
  _FruitPainter(this.kind);

  final IllustrationKind kind;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 64, size.height / 64);
    switch (kind) {
      case IllustrationKind.apple:
        _apple(canvas);
      case IllustrationKind.orange:
        _orange(canvas);
      case IllustrationKind.banana:
        _banana(canvas);
      case IllustrationKind.grapes:
        _grapes(canvas);
      case IllustrationKind.lemon:
        _lemon(canvas);
      case IllustrationKind.strawberry:
        _strawberry(canvas);
    }
    canvas.restore();
  }

  Paint _fill(Color c) => Paint()..color = c;

  Paint _stroke(Color c, double w) => Paint()
    ..color = c
    ..style = PaintingStyle.stroke
    ..strokeWidth = w
    ..strokeCap = StrokeCap.round;

  void _apple(Canvas canvas) {
    final body = Path()
      ..moveTo(32, 22)
      ..cubicTo(26, 16, 11, 20, 11, 36)
      ..cubicTo(11, 48, 20, 58, 27, 56)
      ..cubicTo(30, 55, 31, 54, 32, 54)
      ..cubicTo(33, 54, 34, 55, 37, 56)
      ..cubicTo(44, 58, 53, 48, 53, 36)
      ..cubicTo(53, 20, 38, 16, 32, 22)
      ..close();
    canvas.drawPath(body, _fill(const Color(0xFFD2452B)));
    canvas.drawOval(
      const Rect.fromLTWH(16, 28, 6, 14),
      _fill(const Color(0x66FFFFFF)),
    );
    canvas.drawPath(
      Path()
        ..moveTo(32, 22)
        ..quadraticBezierTo(33, 14, 38, 9),
      _stroke(const Color(0xFF5B3A1E), 3),
    );
    canvas.save();
    canvas.translate(37, 13);
    canvas.rotate(-0.5);
    canvas.drawOval(
      const Rect.fromLTWH(0, 0, 13, 6),
      _fill(const Color(0xFF3E9A5B)),
    );
    canvas.restore();
  }

  void _orange(Canvas canvas) {
    canvas.drawCircle(const Offset(32, 36), 21, _fill(const Color(0xFFF28C28)));
    for (final p in const [
      Offset(24, 30),
      Offset(36, 26),
      Offset(40, 38),
      Offset(28, 44),
      Offset(22, 38),
    ]) {
      canvas.drawCircle(p, 1.3, _fill(const Color(0x33B85C00)));
    }
    canvas.drawOval(
      const Rect.fromLTWH(14, 24, 6, 12),
      _fill(const Color(0x55FFFFFF)),
    );
    canvas.save();
    canvas.translate(31, 11);
    canvas.rotate(-0.4);
    canvas.drawOval(
      const Rect.fromLTWH(0, 0, 12, 6),
      _fill(const Color(0xFF3E9A5B)),
    );
    canvas.restore();
    canvas.drawCircle(
      const Offset(32, 15.5),
      2,
      _fill(const Color(0xFF5B3A1E)),
    );
  }

  void _banana(Canvas canvas) {
    final banana = Path()
      ..moveTo(10, 24)
      ..cubicTo(14, 46, 34, 58, 56, 40)
      ..cubicTo(58, 38, 56, 35, 53, 37)
      ..cubicTo(36, 48, 22, 40, 20, 22)
      ..cubicTo(19, 18, 11, 19, 10, 24)
      ..close();
    canvas.drawPath(banana, _fill(const Color(0xFFF2C94C)));
    canvas.drawPath(
      Path()
        ..moveTo(14, 28)
        ..cubicTo(19, 44, 34, 50, 50, 41),
      _stroke(const Color(0x66C79A1B), 1.6),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(8.5, 16, 8, 6),
        const Radius.circular(2),
      ),
      _fill(const Color(0xFF7A5B1E)),
    );
  }

  void _grapes(Canvas canvas) {
    const dots = [
      Offset(20, 28),
      Offset(32, 28),
      Offset(44, 28),
      Offset(26, 38),
      Offset(38, 38),
      Offset(32, 48),
    ];
    for (final p in dots) {
      canvas.drawCircle(p, 7.4, _fill(const Color(0xFF7B4FB3)));
      canvas.drawCircle(
        p.translate(-2.4, -2.4),
        1.8,
        _fill(const Color(0x66FFFFFF)),
      );
    }
    canvas.drawPath(
      Path()
        ..moveTo(32, 20)
        ..quadraticBezierTo(32, 13, 36, 9),
      _stroke(const Color(0xFF5B3A1E), 2.6),
    );
    canvas.save();
    canvas.translate(34, 11);
    canvas.rotate(-math.pi / 9);
    canvas.drawOval(
      const Rect.fromLTWH(0, 0, 14, 6),
      _fill(const Color(0xFF3E9A5B)),
    );
    canvas.restore();
  }

  void _lemon(Canvas canvas) {
    final lemon = Path()
      ..moveTo(8, 34)
      ..cubicTo(8, 22, 20, 14, 32, 14)
      ..cubicTo(44, 14, 56, 22, 56, 34)
      ..cubicTo(56, 46, 44, 54, 32, 54)
      ..cubicTo(20, 54, 8, 46, 8, 34)
      ..close();
    canvas.drawPath(lemon, _fill(const Color(0xFFF4D03F)));
    canvas.drawOval(
      const Rect.fromLTWH(15, 22, 8, 12),
      _fill(const Color(0x55FFFFFF)),
    );
    canvas.drawCircle(const Offset(7, 34), 3.2, _fill(const Color(0xFFE5B800)));
    canvas.drawCircle(
      const Offset(57, 34),
      3.2,
      _fill(const Color(0xFFE5B800)),
    );
    canvas.save();
    canvas.translate(30, 8);
    canvas.rotate(-0.3);
    canvas.drawOval(
      const Rect.fromLTWH(0, 0, 12, 6),
      _fill(const Color(0xFF3E9A5B)),
    );
    canvas.restore();
  }

  void _strawberry(Canvas canvas) {
    final body = Path()
      ..moveTo(32, 54)
      ..cubicTo(14, 46, 10, 30, 14, 24)
      ..cubicTo(20, 18, 28, 22, 32, 24)
      ..cubicTo(36, 22, 44, 18, 50, 24)
      ..cubicTo(54, 30, 50, 46, 32, 54)
      ..close();
    canvas.drawPath(body, _fill(const Color(0xFFE63946)));
    for (final p in const [
      Offset(24, 32),
      Offset(33, 30),
      Offset(41, 34),
      Offset(28, 41),
      Offset(37, 43),
      Offset(32, 49),
    ]) {
      canvas.drawOval(
        Rect.fromCenter(center: p, width: 2.6, height: 3.6),
        _fill(const Color(0xFFFFE08A)),
      );
    }
    for (final d in const [-0.9, -0.3, 0.3, 0.9]) {
      canvas.save();
      canvas.translate(32, 22);
      canvas.rotate(d);
      canvas.drawOval(
        const Rect.fromLTWH(-3, -9, 6, 11),
        _fill(const Color(0xFF3E9A5B)),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_FruitPainter old) => old.kind != kind;
}

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'dashed_border.dart';

class MathText extends StatelessWidget {
  const MathText(
    this.text, {
    super.key,
    this.style,
    this.color,
    this.textAlign,
    this.blankColor = AppColors.blue,
    this.blankBuilder,
  });

  final String text;
  final TextStyle? style;

  final Color? color;
  final TextAlign? textAlign;

  final Color blankColor;

  final Widget Function(bool compact)? blankBuilder;

  static final _token = RegExp(r'\{([^{}]*)\}');
  static final _arabic = RegExp(r'[؀-ۿ]');

  @override
  Widget build(BuildContext context) {
    var base = style ?? DefaultTextStyle.of(context).style;
    if (color != null) base = base.copyWith(color: color);
    final ltr = !_arabic.hasMatch(text);

    final spans = <InlineSpan>[];
    var cursor = 0;
    for (final m in _token.allMatches(text)) {
      if (m.start > cursor) {
        spans.add(TextSpan(text: text.substring(cursor, m.start)));
      }
      final body = m.group(1)!;
      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: _Token(
            body: body,
            style: base,
            blankColor: blankColor,
            blankBuilder: blankBuilder,
          ),
        ),
      );
      cursor = m.end;
    }
    if (cursor < text.length) spans.add(TextSpan(text: text.substring(cursor)));

    return Text.rich(
      TextSpan(children: spans, style: base),
      textAlign: textAlign,
      textDirection: ltr ? TextDirection.ltr : null,
    );
  }
}

class _Token extends StatelessWidget {
  const _Token({
    required this.body,
    required this.style,
    required this.blankColor,
    required this.blankBuilder,
  });

  final String body;
  final TextStyle style;
  final Color blankColor;
  final Widget Function(bool compact)? blankBuilder;

  Widget _blank({bool compact = false}) =>
      blankBuilder?.call(compact) ??
      _Blank(style: style, color: blankColor, compact: compact);

  @override
  Widget build(BuildContext context) {
    final slash = body.indexOf('/');
    if (slash < 0) {
      return body == '?' ? _blank() : Text(body);
    }
    final num = body.substring(0, slash);
    final den = body.substring(slash + 1);
    final size = style.fontSize ?? 16;
    final color = style.color ?? AppColors.ink;

    Widget part(String s) => s == '?'
        ? _blank(compact: true)
        : Text(s, style: style.copyWith(height: 1.1));

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: size * 0.12),
        child: IntrinsicWidth(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              part(num),
              Container(
                height: (size / 9).clamp(1.5, 3.0),
                margin: EdgeInsets.symmetric(vertical: size * 0.05),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              part(den),
            ],
          ),
        ),
      ),
    );
  }
}

class _Blank extends StatelessWidget {
  const _Blank({
    required this.style,
    required this.color,
    this.compact = false,
  });

  final TextStyle style;
  final Color color;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final size = (style.fontSize ?? 16) * (compact ? 1.25 : 1.4);
    return DashedBorderBox(
      color: color,
      radius: 8,
      strokeWidth: 1.6,
      dash: 5,
      gap: 3.5,
      child: Container(
        width: size * 1.1,
        height: size,
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: AppColors.blueTint,
          borderRadius: BorderRadius.circular(7),
        ),
        alignment: Alignment.center,
        child: Text(
          '?',
          style: style.copyWith(
            color: color,
            fontSize: (style.fontSize ?? 16) * 0.85,
            height: 1,
          ),
        ),
      ),
    );
  }
}

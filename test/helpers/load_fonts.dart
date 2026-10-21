import 'package:flutter/services.dart';

Future<void> loadCairoFont() async {
  final loader = FontLoader('Cairo');
  for (final weight in const ['Regular', 'SemiBold', 'Bold', 'ExtraBold']) {
    loader.addFont(rootBundle.load('assets/fonts/Cairo-$weight.ttf'));
  }
  await loader.load();
}

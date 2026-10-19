import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

abstract class SpeechService {
  Future<bool> speak(
    String text, {
    required String language,
    bool slow = false,
  });

  Future<void> stop();
}

class FlutterTtsSpeechService implements SpeechService {
  FlutterTtsSpeechService() : _tts = FlutterTts();

  final FlutterTts _tts;

  @override
  Future<bool> speak(
    String text, {
    required String language,
    bool slow = false,
  }) async {
    try {
      await _tts.stop();
      final available = await _tts.isLanguageAvailable(language);
      if (available == false || available == 0) return false;
      await _tts.setLanguage(language);
      await _tts.setSpeechRate(slow ? 0.25 : 0.45);
      await _tts.setPitch(1.0);
      final result = await _tts.speak(text);
      return result == 1 || result == true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {}
  }
}

final speechServiceProvider = Provider<SpeechService>((ref) {
  return FlutterTtsSpeechService();
});

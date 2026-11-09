import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  TtsService() : _flutterTts = FlutterTts();

  final FlutterTts _flutterTts;

  // Web's speechSynthesis backend drops speak() calls that land while a
  // previous utterance is still playing (and voices/engine warm-up can make
  // that first utterance slow), so without stopping first, countdown ticks
  // can get silently skipped or garbled instead of staying in sync with the
  // number on screen.
  Future<void> speak(String text) async {
    await _flutterTts.stop();
    await _flutterTts.speak(text);
  }

  Future<void> stop() => _flutterTts.stop();
}

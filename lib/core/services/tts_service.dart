import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  TtsService() : _flutterTts = FlutterTts();

  final FlutterTts _flutterTts;

  Future<void> speak(String text) => _flutterTts.speak(text);

  Future<void> stop() => _flutterTts.stop();
}

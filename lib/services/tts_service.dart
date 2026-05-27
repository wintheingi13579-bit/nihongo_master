// =============================================================
// tts_service.dart - Free offline Japanese text-to-speech
// =============================================================
// Uses the Android system TTS engine (free). The user must have
// the Japanese voice installed in Android Settings → System → Languages
// → Text-to-speech. We give a helpful in-app hint if not present.
// =============================================================

import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  TtsService._();
  static final TtsService instance = TtsService._();

  final FlutterTts _tts = FlutterTts();
  bool _ready = false;

  Future<void> _ensure() async {
    if (_ready) return;
    await _tts.setLanguage('ja-JP');
    await _tts.setSpeechRate(0.45);
    await _tts.setPitch(1.0);
    _ready = true;
  }

  Future<void> speak(String text) async {
    await _ensure();
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> stop() => _tts.stop();
}

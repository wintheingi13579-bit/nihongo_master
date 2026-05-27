// =============================================================
// speech_service.dart - Free speech recognition (pronunciation)
// =============================================================
// Uses Android's built-in speech recognizer. No API key needed.
// We compute a simple similarity score against the target text.
// =============================================================

import 'package:speech_to_text/speech_to_text.dart';

class SpeechService {
  SpeechService._();
  static final SpeechService instance = SpeechService._();

  final SpeechToText _stt = SpeechToText();
  bool _available = false;

  Future<bool> init() async {
    _available = await _stt.initialize();
    return _available;
  }

  Future<String> listenOnce({Duration timeout = const Duration(seconds: 6)}) async {
    if (!_available) await init();
    final completer = <String>[];
    await _stt.listen(
      localeId: 'ja_JP',
      listenFor: timeout,
      onResult: (r) => completer.add(r.recognizedWords),
    );
    await Future.delayed(timeout);
    await _stt.stop();
    return completer.isEmpty ? '' : completer.last;
  }

  /// Returns 0..100 similarity score (Levenshtein-based).
  int score(String target, String said) {
    final a = target.replaceAll(' ', '');
    final b = said.replaceAll(' ', '');
    if (a.isEmpty || b.isEmpty) return 0;
    final dist = _lev(a, b);
    final maxLen = a.length > b.length ? a.length : b.length;
    return (100 * (1 - dist / maxLen)).clamp(0, 100).round();
  }

  int _lev(String a, String b) {
    final m = List.generate(a.length + 1, (_) => List<int>.filled(b.length + 1, 0));
    for (var i = 0; i <= a.length; i++) m[i][0] = i;
    for (var j = 0; j <= b.length; j++) m[0][j] = j;
    for (var i = 1; i <= a.length; i++) {
      for (var j = 1; j <= b.length; j++) {
        final c = a[i - 1] == b[j - 1] ? 0 : 1;
        m[i][j] = [m[i - 1][j] + 1, m[i][j - 1] + 1, m[i - 1][j - 1] + c]
            .reduce((x, y) => x < y ? x : y);
      }
    }
    return m[a.length][b.length];
  }
}

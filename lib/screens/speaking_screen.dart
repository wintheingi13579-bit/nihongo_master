// =============================================================
// speaking_screen.dart - Listen → repeat → pronunciation score
// =============================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/database_service.dart';
import '../services/tts_service.dart';
import '../services/speech_service.dart';
import '../services/user_progress_service.dart';

class SpeakingScreen extends StatefulWidget {
  const SpeakingScreen({super.key});
  @override
  State<SpeakingScreen> createState() => _SpeakingScreenState();
}

class _SpeakingScreenState extends State<SpeakingScreen> {
  List<Map<String, dynamic>> _list = [];
  int _i = 0;
  String _said = '';
  int _score = -1;
  bool _listening = false;

  @override
  void initState() {
    super.initState();
    SpeechService.instance.init();
    DatabaseService.instance.getPhrases().then((v) => setState(() => _list = v));
  }

  Future<void> _record() async {
    if (_list.isEmpty) return;
    setState(() {
      _listening = true;
      _said = '';
      _score = -1;
    });
    final heard = await SpeechService.instance.listenOnce();
    final sc = SpeechService.instance.score(_list[_i]['jp'], heard);
    setState(() {
      _listening = false;
      _said = heard;
      _score = sc;
    });
    if (sc >= 70) {
      context.read<UserProgressService>().addXp(5);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_list.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Speaking 🎙️')),
        body: const Center(child: Text('Loading…')),
      );
    }
    final p = _list[_i];
    return Scaffold(
      appBar: AppBar(title: const Text('Speaking 🎙️')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(p['jp'],
                        style: const TextStyle(
                            fontSize: 28, fontWeight: FontWeight.bold)),
                    Text(p['romaji'] ?? '',
                        style: const TextStyle(color: Colors.grey)),
                    Text(p['en'] ?? '',
                        style: const TextStyle(fontStyle: FontStyle.italic)),
                    const SizedBox(height: 12),
                    IconButton(
                      icon: const Icon(Icons.volume_up, size: 40),
                      onPressed: () => TtsService.instance.speak(p['jp']),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: Icon(_listening ? Icons.mic : Icons.mic_none),
              label: Text(_listening ? 'Listening…' : 'Tap to speak'),
              onPressed: _listening ? null : _record,
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(54)),
            ),
            const SizedBox(height: 16),
            if (_said.isNotEmpty) Text('You said: $_said'),
            if (_score >= 0)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Score: $_score / 100  ${_score >= 70 ? "✨" : ""}',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: _score >= 70 ? Colors.green : Colors.orange),
                ),
              ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.chevron_left),
                  label: const Text('Prev'),
                  onPressed: () => setState(() {
                    _i = (_i - 1 + _list.length) % _list.length;
                    _said = '';
                    _score = -1;
                  }),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.chevron_right),
                  label: const Text('Next'),
                  onPressed: () => setState(() {
                    _i = (_i + 1) % _list.length;
                    _said = '';
                    _score = -1;
                  }),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

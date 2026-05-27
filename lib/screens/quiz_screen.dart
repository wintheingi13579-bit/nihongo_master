// =============================================================
// quiz_screen.dart - Daily challenge: multiple choice & typing
// =============================================================
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/database_service.dart';
import '../services/tts_service.dart';
import '../services/user_progress_service.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});
  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  String _mode = 'choice'; // choice | listen | type
  List<Map<String, dynamic>> _pool = [];
  Map<String, dynamic>? _cur;
  final _rng = Random();
  final _typeCtrl = TextEditingController();
  String _feedback = '';
  int _correct = 0, _total = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _pool = await DatabaseService.instance.getVocabByLevel('N5');
    _next();
  }

  void _next() {
    if (_pool.isEmpty) return;
    _cur = _pool[_rng.nextInt(_pool.length)];
    _feedback = '';
    _typeCtrl.clear();
    setState(() {});
    if (_mode == 'listen') {
      Future.delayed(const Duration(milliseconds: 200),
          () => TtsService.instance.speak(_cur!['kana'] ?? ''));
    }
  }

  void _answer(bool ok) {
    _total++;
    if (ok) {
      _correct++;
      _feedback = 'Correct! ✨ +5 XP';
      context.read<UserProgressService>().addXp(5);
    } else {
      _feedback = 'Answer: ${_cur!['meaning']} (${_cur!['kana']})';
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_cur == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final c = _cur!;
    final choices = (List.of(_pool)..shuffle())
        .where((e) => e['id'] != c['id'])
        .take(3)
        .map((e) => e['meaning'] as String)
        .toList()
      ..add(c['meaning'])
      ..shuffle();

    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz $_correct/$_total'),
        actions: [
          PopupMenuButton<String>(
            initialValue: _mode,
            onSelected: (v) {
              _mode = v;
              _next();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'choice', child: Text('Multiple choice')),
              PopupMenuItem(value: 'listen', child: Text('Listening')),
              PopupMenuItem(value: 'type', child: Text('Typing')),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 12),
            if (_mode != 'listen')
              Text(c['kanji'] ?? c['kana'],
                  style: const TextStyle(fontSize: 56, fontWeight: FontWeight.bold)),
            if (_mode == 'listen')
              IconButton(
                  icon: const Icon(Icons.volume_up, size: 80),
                  onPressed: () => TtsService.instance.speak(c['kana'])),
            const SizedBox(height: 24),
            if (_mode == 'choice' || _mode == 'listen')
              ...choices.map(
                (m) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50)),
                    onPressed: () => _answer(m == c['meaning']),
                    child: Text(m),
                  ),
                ),
              ),
            if (_mode == 'type') ...[
              TextField(
                controller: _typeCtrl,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Type the English meaning'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => _answer(_typeCtrl.text.trim().toLowerCase() ==
                    (c['meaning'] as String).toLowerCase()),
                child: const Text('Check'),
              ),
            ],
            const SizedBox(height: 16),
            Text(_feedback,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: _next,
              icon: const Icon(Icons.skip_next),
              label: const Text('Next'),
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
            ),
          ],
        ),
      ),
    );
  }
}

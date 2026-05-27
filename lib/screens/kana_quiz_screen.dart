// =============================================================
// kana_quiz_screen.dart - Multiple choice + typing quiz
// =============================================================
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/database_service.dart';
import '../services/user_progress_service.dart';

class KanaQuizScreen extends StatefulWidget {
  const KanaQuizScreen({super.key});
  @override
  State<KanaQuizScreen> createState() => _KanaQuizScreenState();
}

class _KanaQuizScreenState extends State<KanaQuizScreen> {
  List<Map<String, dynamic>> _pool = [];
  Map<String, dynamic>? _current;
  List<String> _choices = [];
  int _correct = 0, _total = 0;
  final _rng = Random();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final h = await DatabaseService.instance.getAllKana('hiragana');
    final k = await DatabaseService.instance.getAllKana('katakana');
    _pool = [...h, ...k];
    _next();
  }

  void _next() {
    if (_pool.isEmpty) return;
    _current = _pool[_rng.nextInt(_pool.length)];
    final wrong = List.of(_pool)..shuffle();
    _choices = [
      _current!['romaji'],
      ...wrong.where((e) => e['romaji'] != _current!['romaji']).take(3).map((e) => e['romaji']),
    ]..shuffle();
    setState(() {});
  }

  void _answer(String pick) {
    _total++;
    if (pick == _current!['romaji']) {
      _correct++;
      context.read<UserProgressService>().addXp(2);
    }
    _next();
  }

  @override
  Widget build(BuildContext context) {
    if (_current == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: Text('Kana Quiz  $_correct / $_total')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 24),
            Text(_current!['char'],
                style: const TextStyle(
                    fontSize: 140, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            ..._choices.map(
              (c) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(54)),
                  onPressed: () => _answer(c),
                  child: Text(c, style: const TextStyle(fontSize: 18)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

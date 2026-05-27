// =============================================================
// vocab_screen.dart - Flashcards + JLPT level picker + favorites
// =============================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/database_service.dart';
import '../services/tts_service.dart';
import '../services/user_progress_service.dart';

class VocabScreen extends StatefulWidget {
  const VocabScreen({super.key});
  @override
  State<VocabScreen> createState() => _VocabScreenState();
}

class _VocabScreenState extends State<VocabScreen> {
  String _level = 'N5';
  List<Map<String, dynamic>> _list = [];
  int _i = 0;
  bool _flipped = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _list = await DatabaseService.instance.getVocabByLevel(_level);
    _i = 0;
    _flipped = false;
    setState(() {});
  }

  void _next(int grade) {
    if (_list.isEmpty) return;
    DatabaseService.instance.reviewSrs(_list[_i]['id'], grade);
    if (grade >= 3) context.read<UserProgressService>().addXp(3);
    _i = (_i + 1) % _list.length;
    _flipped = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vocabulary 単語'),
        actions: [
          DropdownButton<String>(
            value: _level,
            dropdownColor: Theme.of(context).cardColor,
            underline: const SizedBox(),
            items: const [
              DropdownMenuItem(value: 'N5', child: Text('N5')),
              DropdownMenuItem(value: 'N4', child: Text('N4')),
              DropdownMenuItem(value: 'N3', child: Text('N3')),
              DropdownMenuItem(value: 'N2', child: Text('N2')),
              DropdownMenuItem(value: 'N1', child: Text('N1')),
            ],
            onChanged: (v) {
              if (v == null) return;
              _level = v;
              _load();
            },
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: _list.isEmpty
          ? const Center(child: Text('No vocab for this level yet.'))
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _flipped = !_flipped),
                      child: Card(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: _flipped
                                ? _Back(v: _list[_i])
                                : _Front(v: _list[_i]),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _Grade(label: 'Again', color: Colors.red, onTap: () => _next(0)),
                      _Grade(label: 'Hard', color: Colors.orange, onTap: () => _next(2)),
                      _Grade(label: 'Good', color: Colors.green, onTap: () => _next(4)),
                      _Grade(label: 'Easy', color: Colors.blue, onTap: () => _next(5)),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}

class _Front extends StatelessWidget {
  final Map<String, dynamic> v;
  const _Front({required this.v});
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(v['kanji'] ?? v['kana'],
            style: const TextStyle(fontSize: 56, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Text(v['kana'] ?? '', style: const TextStyle(fontSize: 22)),
        const SizedBox(height: 16),
        IconButton(
          icon: const Icon(Icons.volume_up, size: 36),
          onPressed: () => TtsService.instance.speak(v['kana'] ?? v['kanji']),
        ),
        const SizedBox(height: 8),
        const Text('Tap card to reveal meaning', style: TextStyle(color: Colors.grey)),
      ],
    );
  }
}

class _Back extends StatelessWidget {
  final Map<String, dynamic> v;
  const _Back({required this.v});
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(v['meaning'] ?? '',
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('Romaji: ${v['romaji'] ?? ''}'),
        const Divider(height: 24),
        Text(v['example'] ?? '', style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 6),
        Text(v['example_en'] ?? '',
            style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
      ],
    );
  }
}

class _Grade extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _Grade({required this.label, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: color, minimumSize: const Size.fromHeight(48)),
          onPressed: onTap,
          child: Text(label),
        ),
      ),
    );
  }
}

// =============================================================
// srs_screen.dart - Spaced-repetition review queue
// =============================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/database_service.dart';
import '../services/tts_service.dart';
import '../services/user_progress_service.dart';

class SrsScreen extends StatefulWidget {
  const SrsScreen({super.key});
  @override
  State<SrsScreen> createState() => _SrsScreenState();
}

class _SrsScreenState extends State<SrsScreen> {
  List<Map<String, dynamic>> _due = [];
  bool _flipped = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _due = await DatabaseService.instance.getDueSrs();
    setState(() {});
  }

  void _grade(int q) async {
    if (_due.isEmpty) return;
    await DatabaseService.instance.reviewSrs(_due.first['id'], q);
    if (q >= 3) context.read<UserProgressService>().addXp(2);
    setState(() {
      _due.removeAt(0);
      _flipped = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_due.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('SRS Review 🧠')),
        body: const Center(
            child: Text('🎉 No cards due!\nCome back later.', textAlign: TextAlign.center)),
      );
    }
    final v = _due.first;
    return Scaffold(
      appBar: AppBar(title: Text('SRS  (${_due.length} due)')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _flipped = !_flipped),
                child: Card(
                  child: Center(
                    child: _flipped
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(v['meaning'] ?? '',
                                  style: const TextStyle(
                                      fontSize: 30, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Text(v['kana'] ?? ''),
                              Text(v['romaji'] ?? ''),
                            ],
                          )
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(v['kanji'] ?? v['kana'] ?? '',
                                  style: const TextStyle(
                                      fontSize: 56, fontWeight: FontWeight.bold)),
                              IconButton(
                                  icon: const Icon(Icons.volume_up, size: 30),
                                  onPressed: () =>
                                      TtsService.instance.speak(v['kana'])),
                            ],
                          ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(children: [
              _g('Again', Colors.red, 0),
              _g('Hard', Colors.orange, 2),
              _g('Good', Colors.green, 4),
              _g('Easy', Colors.blue, 5),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _g(String t, Color c, int q) => Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: c, minimumSize: const Size.fromHeight(46)),
            onPressed: () => _grade(q),
            child: Text(t),
          ),
        ),
      );
}

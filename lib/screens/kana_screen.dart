// =============================================================
// kana_screen.dart - Hiragana / Katakana chart + tap-to-hear + quiz
// =============================================================
import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../services/tts_service.dart';
import 'kana_quiz_screen.dart';

class KanaScreen extends StatefulWidget {
  const KanaScreen({super.key});
  @override
  State<KanaScreen> createState() => _KanaScreenState();
}

class _KanaScreenState extends State<KanaScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab = TabController(length: 2, vsync: this);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kana かな'),
        bottom: TabBar(
          controller: _tab,
          tabs: const [Tab(text: 'Hiragana ひらがな'), Tab(text: 'Katakana カタカナ')],
        ),
        actions: [
          IconButton(
            tooltip: 'Quiz',
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const KanaQuizScreen())),
            icon: const Icon(Icons.quiz),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tab,
        children: const [_KanaGrid(type: 'hiragana'), _KanaGrid(type: 'katakana')],
      ),
    );
  }
}

class _KanaGrid extends StatelessWidget {
  final String type;
  const _KanaGrid({required this.type});
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: DatabaseService.instance.getAllKana(type),
      builder: (_, snap) {
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
        final list = snap.data!;
        return GridView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: list.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5, crossAxisSpacing: 8, mainAxisSpacing: 8,
          ),
          itemBuilder: (_, i) {
            final k = list[i];
            return InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => TtsService.instance.speak(k['char']),
              child: Card(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(k['char'],
                        style: const TextStyle(
                            fontSize: 30, fontWeight: FontWeight.bold)),
                    Text(k['romaji'],
                        style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// =============================================================
// anime_screen.dart - Common anime phrases + shadowing practice
// =============================================================
import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../services/tts_service.dart';

class AnimeScreen extends StatefulWidget {
  const AnimeScreen({super.key});
  @override
  State<AnimeScreen> createState() => _AnimeScreenState();
}

class _AnimeScreenState extends State<AnimeScreen> {
  List<Map<String, dynamic>> _list = [];

  @override
  void initState() {
    super.initState();
    DatabaseService.instance.getPhrases().then((v) => setState(() => _list = v));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Anime Mode 🎬')),
      body: _list.isEmpty
          ? const Center(child: Text('No phrases yet.'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _list.length,
              itemBuilder: (_, i) {
                final p = _list[i];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Expanded(
                            child: Text(p['jp'] ?? '',
                                style: const TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.bold)),
                          ),
                          IconButton(
                            icon: const Icon(Icons.volume_up),
                            onPressed: () =>
                                TtsService.instance.speak(p['jp']),
                          ),
                        ]),
                        Text(p['romaji'] ?? '',
                            style: const TextStyle(color: Colors.grey)),
                        const SizedBox(height: 4),
                        Text(p['en'] ?? '',
                            style: const TextStyle(fontStyle: FontStyle.italic)),
                        const SizedBox(height: 4),
                        Chip(label: Text(p['category'] ?? 'anime')),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

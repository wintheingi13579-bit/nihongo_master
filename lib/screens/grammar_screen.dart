// =============================================================
// grammar_screen.dart - Lesson list + detail with interactive Q
// =============================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/database_service.dart';
import '../services/user_progress_service.dart';

class GrammarScreen extends StatefulWidget {
  const GrammarScreen({super.key});
  @override
  State<GrammarScreen> createState() => _GrammarScreenState();
}

class _GrammarScreenState extends State<GrammarScreen> {
  String _level = 'N5';
  List<Map<String, dynamic>> _list = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _list = await DatabaseService.instance.getGrammar(_level);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grammar 文法'),
        actions: [
          DropdownButton<String>(
            value: _level,
            underline: const SizedBox(),
            dropdownColor: Theme.of(context).cardColor,
            items: const ['N5', 'N4', 'N3', 'N2', 'N1']
                .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                .toList(),
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
          ? const Center(child: Text('No grammar for this level yet.'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _list.length,
              itemBuilder: (_, i) {
                final g = _list[i];
                final done = context
                    .watch<UserProgressService>()
                    .completedLessons
                    .contains('grammar_${g['id']}');
                return Card(
                  child: ListTile(
                    leading: Text(done ? '✅' : '📖',
                        style: const TextStyle(fontSize: 28)),
                    title: Text(g['title'] ?? ''),
                    subtitle: Text(g['example'] ?? ''),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => _GrammarDetail(g: g)),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _GrammarDetail extends StatelessWidget {
  final Map<String, dynamic> g;
  const _GrammarDetail({required this.g});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(g['title'] ?? '')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(g['explanation'] ?? '',
                  style: const TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Example:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(g['example'] ?? '', style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 4),
          Text(g['example_en'] ?? '',
              style:
                  const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            icon: const Icon(Icons.check),
            label: const Text('Mark as learned (+10 XP)'),
            onPressed: () {
              context
                  .read<UserProgressService>()
                  .completeLesson('grammar_${g['id']}', xp: 10);
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Great! +10 XP 🎉')));
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

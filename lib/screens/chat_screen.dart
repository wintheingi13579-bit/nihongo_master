// =============================================================
// chat_screen.dart - AI Japanese tutor chat with furigana/romaji
// =============================================================
import 'package:flutter/material.dart';
import '../services/ai_chat_service.dart';
import '../services/tts_service.dart';
import '../theme/app_theme.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _ctrl = TextEditingController();
  final List<ChatMessage> _msgs = [];
  bool _showRomaji = true, _showEn = true, _casual = true, _loading = false;

  Future<void> _send() async {
    final t = _ctrl.text.trim();
    if (t.isEmpty) return;
    _ctrl.clear();
    setState(() {
      _msgs.add(ChatMessage(role: 'user', jp: t));
      _loading = true;
    });
    AiChatService.instance.casual = _casual;
    final r = await AiChatService.instance.reply(t);
    setState(() {
      _msgs.add(r);
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Tutor 🤖'),
        actions: [
          IconButton(
            tooltip: _casual ? 'Casual' : 'Polite',
            icon: Text(_casual ? 'タ' : 'で',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            onPressed: () => setState(() => _casual = !_casual),
          ),
          IconButton(
            tooltip: 'Romaji',
            icon: Icon(_showRomaji ? Icons.abc : Icons.abc_outlined),
            onPressed: () => setState(() => _showRomaji = !_showRomaji),
          ),
          IconButton(
            tooltip: 'Translation',
            icon: Icon(_showEn ? Icons.translate : Icons.translate_outlined),
            onPressed: () => setState(() => _showEn = !_showEn),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _msgs.length + (_loading ? 1 : 0),
              itemBuilder: (_, i) {
                if (_loading && i == _msgs.length) {
                  return const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text('考えてる… 🤔'),
                  );
                }
                final m = _msgs[i];
                final mine = m.role == 'user';
                return Align(
                  alignment:
                      mine ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * .8),
                    decoration: BoxDecoration(
                      color: mine
                          ? AppTheme.sakura
                          : Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Expanded(
                            child: Text(m.jp,
                                style: TextStyle(
                                    fontSize: 18,
                                    color: mine ? Colors.white : null)),
                          ),
                          if (!mine)
                            IconButton(
                              icon: const Icon(Icons.volume_up, size: 20),
                              onPressed: () => TtsService.instance.speak(m.jp),
                            ),
                        ]),
                        if (_showRomaji && m.romaji.isNotEmpty)
                          Text(m.romaji,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: mine ? Colors.white70 : Colors.grey)),
                        if (_showEn && m.en.isNotEmpty)
                          Text(m.en,
                              style: TextStyle(
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                  color: mine ? Colors.white70 : Colors.grey)),
                        if (m.correction != null)
                          Container(
                            margin: const EdgeInsets.only(top: 6),
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                                color: Colors.amber.withOpacity(.25),
                                borderRadius: BorderRadius.circular(6)),
                            child: Text('✏️ ${m.correction}',
                                style: const TextStyle(fontSize: 12)),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      decoration: const InputDecoration(
                        hintText: 'こんにちは… / Type here',
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  IconButton(
                      icon: const Icon(Icons.send, color: AppTheme.sakura),
                      onPressed: _send),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../services/ai_chat_service.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  bool _showRomaji = false;
  bool _isCasual = false;  // local toggle state

  @override
  void initState() {
    super.initState();
    // Sync local state with service (optional)
    _isCasual = AchatService.instance.casual;
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    // Add user message
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: true,
      ));
      _controller.clear();
    });

    // Get AI reply
    try {
      final aiReply = await AchatService.instance.sendMessage(text);
      setState(() {
        _messages.add(aiReply);
      });
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          text: 'Error: $e',
          isUser: false,
        ));
      });
    }
  }

  void _toggleCasualMode(bool value) {
    setState(() {
      _isCasual = value;
      AchatService.instance.casual = value;  // ✅ This fixes the error
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AI Chat'),
        actions: [
          Switch(
            value: _isCasual,
            onChanged: _toggleCasualMode,
          ),
          IconButton(
            icon: Icon(_showRomaji ? Icons.text_fields : Icons.text_snippet),
            onPressed: () {
              setState(() {
                _showRomaji = !_showRomaji;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (ctx, idx) {
                final m = _messages[idx];
                return ListTile(
                  title: Text(m.text),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_showRomaji && (m.romaji?.isNotEmpty ?? false))
                        Text('romaji: ${m.romaji}', style: TextStyle(fontSize: 12)),
                      if (m.correction != null)
                        Text('correction: ${m.correction}', style: TextStyle(fontSize: 12, color: Colors.green)),
                    ],
                  ),
                  trailing: m.isUser ? null : Icon(Icons.smart_toy),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(hintText: 'Type a message...'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

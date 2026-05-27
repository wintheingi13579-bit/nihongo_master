import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/chat_notifier.dart';
import '../services/ai_chat_service.dart'; // Needed for ChatMessage class

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // 🧠 LISTEN TO THE NEW MANAGER
    final chatNotifier = context.watch<ChatNotifier>();

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1E), // Dark Background
      appBar: AppBar(
        title: const Text('AI Tutor 🤖'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // Clear Chat Button
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => context.read<ChatNotifier>().clearChat(),
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. MESSAGES LIST
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: chatNotifier.messages.length,
              itemBuilder: (context, index) {
                final msg = chatNotifier.messages[index];
                final isUser = msg.role == 'user';

                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isUser 
                          ? const Color(0xFFFF5A79) // Pink
                          : const Color(0xFF1E1E32), // Dark Grey
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg.jp,
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        // Only show translation for AI messages
                        if (!isUser && msg.en.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(msg.en, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                        ]
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // 2. LOADING INDICATOR
          if (chatNotifier.isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(color: Color(0xFFFF5A79)),
            ),

          // 3. INPUT BOX
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A2E),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: const Color(0xFFFF5A79)),
                    ),
                    child: TextField(
                      controller: _textController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: TextStyle(color: Colors.white54),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFFFF5A79)),
                  onPressed: () {
                    final text = _textController.text;
                    if (text.isNotEmpty) {
                      // Send to the Manager
                      context.read<ChatNotifier>().sendMessage(text);
                      _textController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


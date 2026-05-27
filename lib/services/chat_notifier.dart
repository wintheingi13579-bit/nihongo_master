import 'package:flutter/material.dart';
import 'ai_chat_service.dart';

class ChatNotifier extends ChangeNotifier {
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    _messages.add(ChatMessage(role: 'user', jp: text));
    _isLoading = true;
    notifyListeners();

    final response = await AiChatService.instance.reply(text);
    _messages.add(response);
    
    _isLoading = false;
    notifyListeners();
  }

  void clearChat() {
    _messages.clear();
    AiChatService.instance.clearMemory();
    notifyListeners();
  }
}


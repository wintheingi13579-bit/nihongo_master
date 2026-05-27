import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ChatMessage {
  final String role;
  final String jp;
  final String en;

  ChatMessage({required this.role, required this.jp, this.en = ''});
}

class AiChatService {
  AiChatService._();
  static final AiChatService instance = AiChatService._();

  // 🧠 THIS IS THE FIX FOR THE LOOP
  final List<Map<String, String>> _history = [];

  Future<ChatMessage> reply(String userText) async {
    final prefs = await SharedPreferences.getInstance();
    final url = prefs.getString('ai_url') ?? '';
    final key = prefs.getString('ai_key') ?? '';

    if (url.isEmpty || key.isEmpty) {
      return ChatMessage(role: 'ai', jp: 'Please set API Key in settings.', en: 'System Error');
    }

    try {
      // 1. Initialize System
      if (_history.isEmpty) {
        _history.add({'role': 'system', 'content': 'You are a Japanese tutor. Reply in JSON: {"jp":"..","en":".."}'});
      }

      // 2. Add User Message
      _history.add({'role': 'user', 'content': userText});

      // 3. Send Request
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $key'},
        body: jsonEncode({'model': 'gpt-3.5-turbo', 'messages': _history, 'response_format': {'type': 'json_object'}}),
      );

      // 4. Process Response
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      final content = data['choices'][0]['message']['content'];
      
      _history.add({'role': 'assistant', 'content': content}); // Save to history
      final j = jsonDecode(content);
      
      return ChatMessage(role: 'ai', jp: j['jp'] ?? '', en: j['en'] ?? '');
    } catch (e) {
      return ChatMessage(role: 'ai', jp: 'Error connecting.', en: e.toString());
    }
  }

  void clearMemory() {
    _history.clear();
  }
}
class AchatService {
  static final AchatService instance = AchatService._internal();
  factory AchatService() => instance;
  AchatService._internal();

  bool _casual = false;

  set casual(bool value) {
    _casual = value;
    // Adjust AI prompt style here if needed
  }

  bool get casual => _casual;
  
  // ... rest of your existing code
}

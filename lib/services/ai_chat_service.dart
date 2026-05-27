import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ChatMessage {
  final String role;
  final String jp;
  final String romaji;
  final String en;
  final String? correction;

  ChatMessage({
    required this.role,
    required this.jp,
    this.romaji = '',
    this.en = '',
    this.correction,
  });
}

class AiChatService {
  AiChatService._();
  static final AiChatService instance = AiChatService._();

  // 🧠 THIS LIST FIXES THE LOOP
  final List<Map<String, String>> _history = [];

  Future<ChatMessage> reply(String userText) async {
    final prefs = await SharedPreferences.getInstance();
    final url = prefs.getString('ai_url') ?? '';
    final key = prefs.getString('ai_key') ?? '';

    if (url.isEmpty || key.isEmpty) return _localFallback();

    try {
      return await _fetchOnline(userText, url, key);
    } catch (e) {
      return _localFallback();
    }
  }

  Future<ChatMessage> _fetchOnline(String text, String url, String key) async {
    // 1. Initialize System (Only once)
    if (_history.isEmpty) {
      _history.add({
        'role': 'system', 
        'content': 'You are a Japanese tutor. Reply in JSON format: {"jp":"..","romaji":"..","en":"..","correction":null}.'
      });
    }

    // 2. Add User Input to History
    _history.add({'role': 'user', 'content': text});

    // 3. Send FULL History
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $key',
      },
      body: jsonEncode({
        'model': 'gpt-3.5-turbo', 
        'messages': _history, // <--- This stops the loop
        'response_format': {'type': 'json_object'},
      }),
    );

    // 4. Save AI Response to History
    final data = jsonDecode(utf8.decode(response.bodyBytes));
    final content = data['choices'][0]['message']['content'];
    _history.add({'role': 'assistant', 'content': content});

    final j = jsonDecode(content);
    return ChatMessage(
      role: 'ai',
      jp: j['jp'] ?? '',
      romaji: j['romaji'] ?? '',
      en: j['en'] ?? '',
      correction: j['correction'],
    );
  }

  void clearMemory() {
    _history.clear();
  }

  ChatMessage _localFallback() {
    return ChatMessage(role: 'ai', jp: 'Please set API Key in settings.', en: 'System Error');
  }
}

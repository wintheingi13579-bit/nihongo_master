import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ChatMessage {
  final String role; // 'user' or 'ai'
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

  bool casual = true;

  // 🧠 This is our continuous memory tracker that fixes the looping bug!
  final List<Map<String, String>> _conversationHistory = [];

  Future<ChatMessage> reply(String userText) async {
    final prefs = await SharedPreferences.getInstance();
    final apiUrl = prefs.getString('ai_url') ?? '';
    final apiKey = prefs.getString('ai_key') ?? '';

    if (apiUrl.isNotEmpty && apiKey.isNotEmpty) {
      try {
        return await _online(userText, apiUrl, apiKey);
      } catch (_) {
        /* fall back to local if online crashes */
      }
    }
    return _local(userText);
  }

  Future<ChatMessage> _online(String text, String url, String key) async {
    final sys = casual
        ? 'You are a friendly Japanese friend. Reply in casual Japanese (タメ口). Include: Japanese, romaji, English, and JSON format.'
        : 'You are a polite Japanese tutor. Reply in丁寧語 polite Japanese. Include: Japanese, romaji, English, and JSON format.';

    // 1. Initialize system rules on the very first message run
    if (_conversationHistory.isEmpty) {
      _conversationHistory.add({'role': 'system', 'content': sys});
    }

    // 2. Add the user's incoming phrase into the memory bank
    _conversationHistory.add({'role': 'user', 'content': text});

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $key',
      },
      body: jsonEncode({
        'model': 'gpt-3.5-turbo', // You can change this to 'gemini-2.0-flash' later
        'messages': _conversationHistory, // 🌟 Sends the whole memory list to the AI!
        'response_format': {'type': 'json_object'},
      }),
    );

    final body = jsonDecode(utf8.decode(response.bodyBytes));
    final content = body['choices'][0]['message']['content'];
    
    // 3. Save the AI's reply to the memory history too
    _conversationHistory.add({'role': 'assistant', 'content': content});

    final j = jsonDecode(content);
    return ChatMessage(
      role: 'ai',
      jp: j['jp'] ?? '',
      romaji: j['romaji'] ?? '',
      en: j['en'] ?? '',
      correction: (j['correction'] ?? '').toString().isEmpty ? null : j['correction'],
    );
  }

  // Clear memory context when changing users or resetting the chat screen
  void resetConversationMemory() {
    _conversationHistory.clear();
  }

  ChatMessage _local(String text) {
    return ChatMessage(
      role: 'ai',
      jp: 'なるほどね！もっと教えて？',
      romaji: 'Naruhodo ne! Motto oshiete?',
      en: 'I see! Tell me more.',
    );
  }
}

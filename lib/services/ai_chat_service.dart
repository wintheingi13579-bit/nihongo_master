// =============================================================
// ai_chat_service.dart - AI Japanese Tutor
// =============================================================
// Two modes:
//   1. LOCAL (default, free, offline-ish): A rule-based tutor that
//      uses a small phrase library + pattern matching. Works on a
//      potato phone with no internet.
//   2. ONLINE (optional): Plug in any free LLM endpoint that follows
//      the OpenAI chat format (e.g. self-hosted Ollama, Groq free
//      tier, etc). Set apiUrl + apiKey in SettingsScreen.
// =============================================================

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ChatMessage {
  final String role; // 'user' | 'ai'
  final String jp;
  final String romaji;
  final String en;
  final String? correction; // grammar fix, if any
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

  bool casual = true; // casual vs polite mode

  Future<ChatMessage> reply(String userText) async {
    final prefs = await SharedPreferences.getInstance();
    final apiUrl = prefs.getString('ai_url') ?? '';
    final apiKey = prefs.getString('ai_key') ?? '';

    if (apiUrl.isNotEmpty && apiKey.isNotEmpty) {
      try {
        return await _online(userText, apiUrl, apiKey);
      } catch (_) {/* fall back to local */}
    }
    return _local(userText);
  }

  // ---------- ONLINE MODE ----------
  Future<ChatMessage> _online(String text, String url, String key) async {
    final sys = casual
        ? 'You are a friendly Japanese friend. Reply in casual Japanese (タメ口). Include: Japanese, romaji, English, and a short grammar correction if the user made a mistake. Respond in JSON with keys jp, romaji, en, correction.'
        : 'You are a polite Japanese tutor. Reply in です/ます polite Japanese. Include: Japanese, romaji, English, and a short grammar correction if the user made a mistake. Respond in JSON with keys jp, romaji, en, correction.';
    final res = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $key'},
      body: jsonEncode({
        'model': 'gpt-3.5-turbo',
        'messages': [
          {'role': 'system', 'content': sys},
          {'role': 'user', 'content': text},
        ],
        'response_format': {'type': 'json_object'},
      }),
    );
    final body = jsonDecode(res.body);
    final content = body['choices'][0]['message']['content'];
    final j = jsonDecode(content);
    return ChatMessage(
      role: 'ai',
      jp: j['jp'] ?? '',
      romaji: j['romaji'] ?? '',
      en: j['en'] ?? '',
      correction: (j['correction'] ?? '').toString().isEmpty ? null : j['correction'],
    );
  }

  // ---------- LOCAL FALLBACK ----------
  ChatMessage _local(String text) {
    final t = text.toLowerCase().trim();
    final replies = <RegExp, ChatMessage>{
      RegExp(r'\b(hi|hello|hey|こんにちは|やあ)\b'): ChatMessage(
        role: 'ai',
        jp: casual ? 'やあ！元気？' : 'こんにちは！お元気ですか？',
        romaji: casual ? 'Yaa! Genki?' : 'Konnichiwa! Ogenki desu ka?',
        en: 'Hi! How are you?',
      ),
      RegExp(r'\b(name|namae|名前)\b'): ChatMessage(
        role: 'ai',
        jp: casual ? '俺はミナトだよ。君は？' : '私はミナトと申します。お名前は？',
        romaji: casual ? 'Ore wa Minato da yo. Kimi wa?' : 'Watashi wa Minato to moushimasu. Onamae wa?',
        en: "I'm Minato. What's your name?",
      ),
      RegExp(r'\b(thanks|thank|arigato|ありがとう)\b'): ChatMessage(
        role: 'ai',
        jp: casual ? 'どういたしまして！' : 'どういたしまして。',
        romaji: 'Dou itashimashite!',
        en: "You're welcome!",
      ),
      RegExp(r'\b(food|eat|tabe|食べ)\b'): ChatMessage(
        role: 'ai',
        jp: casual ? '寿司が大好き！君は？' : '寿司が大好きです。あなたは？',
        romaji: 'Sushi ga daisuki! Kimi wa?',
        en: 'I love sushi! How about you?',
      ),
    };
    for (final e in replies.entries) {
      if (e.key.hasMatch(t)) return e.value;
    }
    return ChatMessage(
      role: 'ai',
      jp: casual ? 'なるほどね！もっと教えて？' : 'なるほど。もう少し教えてください。',
      romaji: 'Naruhodo ne! Motto oshiete?',
      en: 'I see! Tell me more.',
    );
  }
}

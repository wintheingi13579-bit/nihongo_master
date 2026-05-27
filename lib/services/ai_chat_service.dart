import 'dart:convert';
import 'package:http/http.dart' as http;

// ------------------- ChatMessage Model -------------------
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? romaji;      // romaji version of the message (if any)
  final String? correction;  // grammatical correction (if any)

  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
    this.romaji,
    this.correction,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'text': text,
        'isUser': isUser,
        'timestamp': timestamp.toIso8601String(),
        'romaji': romaji,
        'correction': correction,
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        text: json['text'],
        isUser: json['isUser'],
        timestamp: DateTime.parse(json['timestamp']),
        romaji: json['romaji'],
        correction: json['correction'],
      );
}

// ------------------- AchatService -------------------
class AchatService {
  static final AchatService instance = AchatService._internal();
  factory AchatService() => instance;
  AchatService._internal();

  // --- casual mode setter/getter ---
  bool _casual = false;

  set casual(bool value) {
    _casual = value;
    // You can adjust the AI system prompt here if needed
  }

  bool get casual => _casual;

  // --- Other existing properties (keep yours) ---
  // Example: apiKey, model, etc.
  final String _apiKey = 'YOUR_API_KEY'; // Replace with your actual key
  final String _apiUrl = 'https://api.openai.com/v1/chat/completions';

  Future<ChatMessage> sendMessage(String userMessage) async {
    // Build system prompt based on casual/formal
    final systemPrompt = _casual
        ? 'You are a friendly, casual Japanese conversation partner. Use plain forms (da, dazo, jan).'
        : 'You are a polite Japanese tutor. Use desu/masu forms. Correct the user\'s grammar when needed.';

    final response = await http.post(
      Uri.parse(_apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode({
        'model': 'gpt-3.5-turbo',
        'messages': [
          {'role': 'system', 'content': systemPrompt},
          {'role': 'user', 'content': userMessage},
        ],
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final aiText = data['choices'][0]['message']['content'];

      // Simple extraction for romaji and correction (example logic)
      String? romaji = _extractRomaji(aiText);
      String? correction = _extractCorrection(aiText);

      return ChatMessage(
        text: aiText,
        isUser: false,
        romaji: romaji,
        correction: correction,
      );
    } else {
      throw Exception('Failed to get AI response');
    }
  }

  String? _extractRomaji(String text) {
    // Dummy implementation – replace with your own logic
    if (text.contains('romaji:')) {
      return text.split('romaji:')[1].split('\n')[0].trim();
    }
    return null;
  }

  String? _extractCorrection(String text) {
    if (text.contains('correction:')) {
      return text.split('correction:')[1].split('\n')[0].trim();
    }
    return null;
  }
}

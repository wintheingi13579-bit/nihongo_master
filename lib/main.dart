import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/chat_notifier.dart';
import 'screens/chat_screen.dart'; // Make sure this filename matches yours!

void main() {
  runApp(
    MultiProvider(
      providers: [
        // This "turns on" the memory system for the whole app
        ChangeNotifierProvider(create: (_) => ChatNotifier()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nihongo Master',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F0F1E),
        primaryColor: const Color(0xFFFF5A79),
      ),
      home: const ChatScreen(),
    );
  }
}

// =============================================================
// onboarding_screen.dart - Friendly first-run tour
// =============================================================
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';
import '../services/user_progress_service.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  final _nameCtrl = TextEditingController();
  int _page = 0;

  final _slides = const [
    _Slide('🌸', 'ようこそ!', 'Welcome to Nihongo Master — your free, offline Japanese tutor.'),
    _Slide('🎌', 'Kana → Vocab → Grammar', 'Master Hiragana, Katakana, JLPT vocab and grammar step by step.'),
    _Slide('🤖', 'AI Tutor & Anime Mode', 'Chat with an AI friend and learn from anime phrases.'),
    _Slide('🔥', 'Build a streak', 'Daily reminders + XP keep you motivated.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.sakuraGradient),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  onPageChanged: (i) => setState(() => _page = i),
                  itemCount: _slides.length + 1,
                  itemBuilder: (_, i) {
                    if (i < _slides.length) return _slides[i];
                    return _NameStep(nameCtrl: _nameCtrl);
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_slides.length + 1, (i) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.all(4),
                    width: i == _page ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.all(20),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.sakuraDeep,
                  ),
                  onPressed: () async {
                    if (_page < _slides.length) {
                      _controller.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut);
                    } else {
                      final p = await SharedPreferences.getInstance();
                      await p.setBool('onboarded', true);
                      if (!mounted) return;
                      await context
                          .read<UserProgressService>()
                          .setUsername(_nameCtrl.text);
                      if (!mounted) return;
                      Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const HomeScreen()));
                    }
                  },
                  child: Text(_page < _slides.length ? 'Next' : 'はじめる Start'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Slide extends StatelessWidget {
  final String emoji, title, body;
  const _Slide(this.emoji, this.title, this.body);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 96)),
          const SizedBox(height: 16),
          Text(title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(body,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 16)),
        ],
      ),
    );
  }
}

class _NameStep extends StatelessWidget {
  final TextEditingController nameCtrl;
  const _NameStep({required this.nameCtrl});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('👤', style: TextStyle(fontSize: 80)),
          const SizedBox(height: 16),
          const Text('What should we call you?',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          TextField(
            controller: nameCtrl,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 20),
            decoration: const InputDecoration(
              hintText: 'Sensei',
              hintStyle: TextStyle(color: Colors.white70),
              enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white)),
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

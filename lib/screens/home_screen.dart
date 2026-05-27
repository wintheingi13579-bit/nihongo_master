// =============================================================
// home_screen.dart - Main hub with grid of features + XP/streak
// =============================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../theme/app_theme.dart';
import '../services/user_progress_service.dart';
import '../widgets/mascot.dart';
import 'kana_screen.dart';
import 'vocab_screen.dart';
import 'grammar_screen.dart';
import 'chat_screen.dart';
import 'anime_screen.dart';
import 'speaking_screen.dart';
import 'quiz_screen.dart';
import 'profile_screen.dart';
import 'srs_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<UserProgressService>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final features = <_Feat>[
      _Feat('🈁', 'Kana', 'Hiragana & Katakana', () => const KanaScreen()),
      _Feat('📚', 'Vocabulary', 'JLPT N5 → N1', () => const VocabScreen()),
      _Feat('📖', 'Grammar', 'Lessons & particles', () => const GrammarScreen()),
      _Feat('🤖', 'AI Chat', 'Talk in Japanese', () => const ChatScreen()),
      _Feat('🎬', 'Anime Mode', 'Phrases & shadowing', () => const AnimeScreen()),
      _Feat('🎙️', 'Speaking', 'Pronunciation score', () => const SpeakingScreen()),
      _Feat('🧠', 'SRS Review', 'Spaced repetition', () => const SrsScreen()),
      _Feat('🏆', 'Quiz', 'Test yourself', () => const QuizScreen()),
    ];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark ? AppTheme.nightGradient : AppTheme.sakuraGradient,
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _Header(p: p)),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.05,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => _FeatureCard(feat: features[i], index: i),
                    childCount: features.length,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  child: const Mascot(
                    message: '今日も頑張ろう！ Let\'s practice today!',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.sakura,
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const ProfileScreen())),
        icon: const Icon(Icons.person),
        label: Text(p.username),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final UserProgressService p;
  const _Header({required this.p});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Konnichiwa, ${p.username}!',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              _Pill(icon: '⭐', text: 'Lv ${p.level}'),
              const SizedBox(width: 8),
              _Pill(icon: '✨', text: '${p.xp} XP'),
              const SizedBox(width: 8),
              _Pill(icon: '🔥', text: '${p.streakDays}d'),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: p.xpIntoLevel / 100,
              minHeight: 8,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation(AppTheme.goldXP),
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String icon, text;
  const _Pill({required this.icon, required this.text});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text('$icon $text',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
    );
  }
}

class _Feat {
  final String emoji, title, sub;
  final Widget Function() builder;
  _Feat(this.emoji, this.title, this.sub, this.builder);
}

class _FeatureCard extends StatelessWidget {
  final _Feat feat;
  final int index;
  const _FeatureCard({required this.feat, required this.index});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => feat.builder())),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(feat.emoji, style: const TextStyle(fontSize: 38)),
              const Spacer(),
              Text(feat.title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(feat.sub,
                  style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).hintColor)),
            ],
          ),
        ),
      ).animate().fadeIn(delay: (80 * index).ms).slideY(begin: .15),
    );
  }
}

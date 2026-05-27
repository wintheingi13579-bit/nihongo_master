// =============================================================
// splash_screen.dart - Sakura-themed splash + first-run check
// =============================================================
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../theme/app_theme.dart';
import 'onboarding_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _go();
  }

  Future<void> _go() async {
    await Future.delayed(const Duration(seconds: 2));
    final p = await SharedPreferences.getInstance();
    final firstRun = p.getBool('onboarded') != true;
    if (!mounted) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => firstRun ? const OnboardingScreen() : const HomeScreen(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.sakuraGradient),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🌸', style: TextStyle(fontSize: 88))
                  .animate()
                  .scale(duration: 700.ms, curve: Curves.elasticOut),
              const SizedBox(height: 12),
              const Text('日本語マスター',
                      style: TextStyle(
                          fontSize: 36,
                          color: Colors.white,
                          fontWeight: FontWeight.bold))
                  .animate()
                  .fadeIn(delay: 400.ms),
              const SizedBox(height: 6),
              const Text('Nihongo Master',
                      style: TextStyle(fontSize: 20, color: Colors.white))
                  .animate()
                  .fadeIn(delay: 700.ms),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================
// main.dart - Entry point of Nihongo Master
// =============================================================
// This file:
//   1. Starts Flutter
//   2. Initializes the local SQLite database
//   3. Initializes notifications
//   4. Provides app-wide state (theme, user progress) via Provider
//   5. Launches the root widget (NihongoMasterApp)
// =============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'services/database_service.dart';
import 'services/notification_service.dart';
import 'services/user_progress_service.dart';
import 'services/theme_service.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  // Required before any plugin call.
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize local SQLite (runs migrations on first launch).
  await DatabaseService.instance.init();

  // Schedule motivational daily notifications (8 PM by default).
  await NotificationService.instance.init();

  // Load saved progress, XP, streak, theme preference from local storage.
  final progress = UserProgressService();
  await progress.load();

  final themeService = ThemeService();
  await themeService.load();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: progress),
        ChangeNotifierProvider.value(value: themeService),
      ],
      child: const NihongoMasterApp(),
    ),
  );
}

/// Root widget. Listens to ThemeService so the user can flip dark mode
/// without restarting the app.
class NihongoMasterApp extends StatelessWidget {
  const NihongoMasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeService>();
    return MaterialApp(
      title: 'Nihongo Master',
      debugShowCheckedModeBanner: false,
      themeMode: theme.mode,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: const SplashScreen(),
    );
  }
}

// =============================================================
// user_progress_service.dart - XP, level, streak, badges, account
// =============================================================
// Everything is saved with SharedPreferences (a tiny key-value store).
// 100% offline, no Firebase required.
// =============================================================

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProgressService extends ChangeNotifier {
  String _username = 'Sensei';
  int _xp = 0;
  int _streakDays = 0;
  int _lastActiveDay = 0; // days since epoch
  final Set<String> _badges = {};
  final Set<String> _completedLessons = {};

  String get username => _username;
  int get xp => _xp;
  int get level => 1 + (_xp ~/ 100); // every 100 XP = 1 level
  int get xpIntoLevel => _xp % 100;
  int get streakDays => _streakDays;
  Set<String> get badges => _badges;
  Set<String> get completedLessons => _completedLessons;

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    _username = p.getString('username') ?? 'Sensei';
    _xp = p.getInt('xp') ?? 0;
    _streakDays = p.getInt('streak') ?? 0;
    _lastActiveDay = p.getInt('lastDay') ?? 0;
    _badges
      ..clear()
      ..addAll(p.getStringList('badges') ?? []);
    _completedLessons
      ..clear()
      ..addAll(p.getStringList('lessons') ?? []);
    _tickStreak();
    notifyListeners();
  }

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setString('username', _username);
    await p.setInt('xp', _xp);
    await p.setInt('streak', _streakDays);
    await p.setInt('lastDay', _lastActiveDay);
    await p.setStringList('badges', _badges.toList());
    await p.setStringList('lessons', _completedLessons.toList());
  }

  void _tickStreak() {
    final today = DateTime.now()
        .toUtc()
        .difference(DateTime.utc(1970))
        .inDays;
    if (_lastActiveDay == today) return;
    if (_lastActiveDay == today - 1) {
      _streakDays++;
    } else if (_lastActiveDay < today - 1) {
      _streakDays = 1;
    }
    _lastActiveDay = today;
    _save();
  }

  Future<void> setUsername(String name) async {
    _username = name.trim().isEmpty ? 'Sensei' : name.trim();
    await _save();
    notifyListeners();
  }

  Future<void> addXp(int amount, {String? reason}) async {
    _xp += amount;
    // Badge unlocks
    if (_xp >= 100) _badges.add('🌱 Sprout');
    if (_xp >= 500) _badges.add('🌸 Sakura');
    if (_xp >= 1000) _badges.add('🐉 Dragon');
    if (_streakDays >= 7) _badges.add('🔥 Weekly Warrior');
    await _save();
    notifyListeners();
  }

  Future<void> completeLesson(String id, {int xp = 10}) async {
    if (_completedLessons.add(id)) {
      await addXp(xp);
    }
  }
}

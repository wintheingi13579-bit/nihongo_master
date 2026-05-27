// =============================================================
// database_service.dart - Offline SQLite database
// =============================================================
// Tables:
//   - vocab        : JLPT vocabulary (N5..N1)
//   - kana         : hiragana + katakana characters
//   - grammar      : grammar points & lessons
//   - phrases      : anime / common phrases
//   - srs          : spaced-repetition review schedule
//   - favorites    : starred vocab/phrases
// =============================================================

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

class DatabaseService {
  DatabaseService._();
  static final DatabaseService instance = DatabaseService._();

  Database? _db;
  Database get db => _db!;

  Future<void> init() async {
    final dir = await getDatabasesPath();
    final dbPath = join(dir, 'nihongo_master.db');
    _db = await openDatabase(
      dbPath,
      version: 1,
      onCreate: _onCreate,
    );
    await _seedIfEmpty();
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE vocab (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        kanji TEXT, kana TEXT, romaji TEXT,
        meaning TEXT, jlpt TEXT, example TEXT, example_en TEXT
      );
    ''');
    await db.execute('''
      CREATE TABLE kana (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        char TEXT, romaji TEXT, type TEXT, row_group TEXT
      );
    ''');
    await db.execute('''
      CREATE TABLE grammar (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT, jlpt TEXT, explanation TEXT,
        example TEXT, example_en TEXT
      );
    ''');
    await db.execute('''
      CREATE TABLE phrases (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        jp TEXT, romaji TEXT, en TEXT, category TEXT
      );
    ''');
    await db.execute('''
      CREATE TABLE srs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        vocab_id INTEGER UNIQUE,
        ease REAL DEFAULT 2.5,
        interval_days INTEGER DEFAULT 1,
        due_at INTEGER
      );
    ''');
    await db.execute('''
      CREATE TABLE favorites (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        kind TEXT, ref_id INTEGER
      );
    ''');
  }

  /// Load JSON seeds bundled in assets/data/ and insert into tables
  /// the first time the app starts.
  Future<void> _seedIfEmpty() async {
    final c = Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM vocab')) ??
        0;
    if (c > 0) return;

    await _seedTable('assets/data/vocab.json', 'vocab');
    await _seedTable('assets/data/kana.json', 'kana');
    await _seedTable('assets/data/grammar.json', 'grammar');
    await _seedTable('assets/data/phrases.json', 'phrases');
  }

  Future<void> _seedTable(String assetPath, String table) async {
    try {
      final raw = await rootBundle.loadString(assetPath);
      final List list = jsonDecode(raw);
      final batch = db.batch();
      for (final row in list) {
        batch.insert(table, Map<String, dynamic>.from(row));
      }
      await batch.commit(noResult: true);
    } catch (e) {
      // Asset missing → keep table empty. App still runs.
    }
  }

  // ---------- Vocab helpers ----------
  Future<List<Map<String, dynamic>>> getVocabByLevel(String jlpt) =>
      db.query('vocab', where: 'jlpt = ?', whereArgs: [jlpt]);

  Future<List<Map<String, dynamic>>> getAllKana(String type) =>
      db.query('kana', where: 'type = ?', whereArgs: [type]);

  Future<List<Map<String, dynamic>>> getGrammar(String jlpt) =>
      db.query('grammar', where: 'jlpt = ?', whereArgs: [jlpt]);

  Future<List<Map<String, dynamic>>> getPhrases([String? cat]) => cat == null
      ? db.query('phrases')
      : db.query('phrases', where: 'category = ?', whereArgs: [cat]);

  // ---------- SRS helpers ----------
  Future<List<Map<String, dynamic>>> getDueSrs() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    return db.rawQuery('''
      SELECT v.*, s.ease, s.interval_days, s.due_at
      FROM vocab v JOIN srs s ON v.id = s.vocab_id
      WHERE s.due_at <= ? LIMIT 20
    ''', [now]);
  }

  /// SM-2 algorithm (simplified). q = 0..5 grading.
  Future<void> reviewSrs(int vocabId, int q) async {
    final row = await db.query('srs',
        where: 'vocab_id = ?', whereArgs: [vocabId], limit: 1);
    double ease = row.isEmpty ? 2.5 : (row.first['ease'] as num).toDouble();
    int interval =
        row.isEmpty ? 1 : (row.first['interval_days'] as num).toInt();

    if (q < 3) {
      interval = 1;
    } else {
      interval = (interval * ease).round().clamp(1, 365);
      ease = (ease + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02)))
          .clamp(1.3, 2.8);
    }
    final due =
        DateTime.now().add(Duration(days: interval)).millisecondsSinceEpoch;

    await db.insert(
      'srs',
      {
        'vocab_id': vocabId,
        'ease': ease,
        'interval_days': interval,
        'due_at': due,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}

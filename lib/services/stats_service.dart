import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/question_stats.dart';

class StatsService {
  static const _key = 'question_stats_v1';
  Map<int, QuestionStats> _stats = {};

  Map<int, QuestionStats> get all => Map.unmodifiable(_stats);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return;
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    _stats = decoded.map(
      (key, value) => MapEntry(
        int.parse(key),
        QuestionStats.fromJson(value as Map<String, dynamic>),
      ),
    );
  }

  QuestionStats forQuestion(int id) => _stats[id] ?? const QuestionStats();

  Future<void> record(int questionId, bool isCorrect) async {
    _stats[questionId] = forQuestion(questionId).addResult(isCorrect);
    await _save();
  }

  Future<void> recordBatch(Map<int, bool> results) async {
    for (final entry in results.entries) {
      _stats[entry.key] = forQuestion(entry.key).addResult(entry.value);
    }
    await _save();
  }

  Future<void> reset() async {
    _stats = {};
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(
      _stats.map((key, value) => MapEntry(key.toString(), value.toJson())),
    );
    await prefs.setString(_key, encoded);
  }
}

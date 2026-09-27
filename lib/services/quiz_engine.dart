import 'dart:math';
import '../models/question.dart';
import 'stats_service.dart';

enum QuizMode { all, restart, cards, errors, exam }

class QuizEngine {
  final StatsService stats;
  final Random _random = Random();

  QuizEngine(this.stats);

  List<Question> poolForMode(List<Question> questions, QuizMode mode) {
    return switch (mode) {
      QuizMode.all || QuizMode.exam => [...questions],
      QuizMode.restart => questions
          .where((q) => q.type == QuestionType.restart)
          .toList(),
      QuizMode.cards => questions
          .where((q) => q.type == QuestionType.discipline)
          .toList(),
      QuizMode.errors => questions
          .where((q) => stats.forQuestion(q.id).errors > 0)
          .toList(),
    };
  }

  List<Question> buildSession({
    required List<Question> pool,
    required int? count,
    required bool randomOrder,
    bool adaptive = true,
  }) {
    if (pool.isEmpty) return [];

    final target = count == null
        ? pool.length
        : (count < pool.length ? count : pool.length);
    if (!randomOrder) return pool.take(target).toList();

    if (!adaptive) {
      final copy = [...pool]..shuffle(_random);
      return copy.take(target).toList();
    }

    final remaining = [...pool];
    final result = <Question>[];
    while (result.length < target && remaining.isNotEmpty) {
      final chosen = _weightedPick(remaining);
      result.add(chosen);
      remaining.remove(chosen);
    }
    return result;
  }

  Question _weightedPick(List<Question> questions) {
    final weights = questions.map(_weightFor).toList();
    final total = weights.fold<double>(0, (sum, w) => sum + w);
    var roll = _random.nextDouble() * total;
    for (var i = 0; i < questions.length; i++) {
      roll -= weights[i];
      if (roll <= 0) return questions[i];
    }
    return questions.last;
  }

  double _weightFor(Question question) {
    final s = stats.forQuestion(question.id);
    if (s.attempts == 0) return 1.4;
    if (s.errors == 0 && s.correct >= 3) return 0.55;
    final errorRate = s.errors / s.attempts;
    return 1.0 + (errorRate * 2.2) + min(s.errors, 4).toDouble() * 0.25;
  }
}

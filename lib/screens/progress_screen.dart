import 'package:flutter/material.dart';
import '../models/question.dart';
import '../models/question_stats.dart';
import '../services/stats_service.dart';

class ProgressScreen extends StatelessWidget {
  final List<Question> questions;
  final StatsService stats;

  const ProgressScreen({super.key, required this.questions, required this.stats});

  (int attempts, int correct) totalsFor(Iterable<Question> subset) {
    var attempts = 0;
    var correct = 0;
    for (final q in subset) {
      final s = stats.forQuestion(q.id);
      attempts += s.attempts;
      correct += s.correct;
    }
    return (attempts, correct);
  }

  String percent((int, int) totals) {
    if (totals.$1 == 0) return '—';
    return '${(totals.$2 / totals.$1 * 100).round()} %';
  }

  @override
  Widget build(BuildContext context) {
    final global = totalsFor(questions);
    final difficult = questions.where((q) {
      final s = stats.forQuestion(q.id);
      return s.errors >= 2 || (s.attempts >= 2 && s.successRate < 0.6);
    }).toList()
      ..sort((a, b) {
        final sa = stats.forQuestion(a.id);
        final sb = stats.forQuestion(b.id);
        return sb.errors.compareTo(sa.errors);
      });

    return Scaffold(
      appBar: AppBar(title: const Text('Progression')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _ScoreCard(label: 'Score global', value: percent(global)),
          const SizedBox(height: 12),
          _ScoreCard(
            label: 'CFD',
            value: percent(totalsFor(
              questions.where((q) => q.category == AnswerCategory.cfd),
            )),
          ),
          _ScoreCard(
            label: 'CFI',
            value: percent(totalsFor(
              questions.where((q) => q.category == AnswerCategory.cfi),
            )),
          ),
          _ScoreCard(
            label: 'Cartons jaunes',
            value: percent(totalsFor(
              questions.where((q) => q.category == AnswerCategory.cj),
            )),
          ),
          _ScoreCard(
            label: 'Cartons rouges',
            value: percent(totalsFor(
              questions.where((q) => q.category == AnswerCategory.cr),
            )),
          ),
          const SizedBox(height: 28),
          Text('À retravailler', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          if (difficult.isEmpty)
            const Card(
              child: ListTile(
                leading: Icon(Icons.check_circle_outline),
                title: Text('Aucune question difficile détectée pour le moment.'),
              ),
            )
          else
            for (final q in difficult)
              _DifficultTile(question: q, stats: stats.forQuestion(q.id)),
        ],
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  final String label;
  final String value;
  const _ScoreCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Card(
        child: ListTile(
          title: Text(label),
          trailing: Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
        ),
      );
}

class _DifficultTile extends StatelessWidget {
  final Question question;
  final QuestionStats stats;
  const _DifficultTile({required this.question, required this.stats});

  @override
  Widget build(BuildContext context) => Card(
        child: ListTile(
          title: Text(question.motif),
          subtitle: Text(
            '${stats.errors} erreur(s) sur ${stats.attempts} tentative(s) · ${question.shortAnswer}',
          ),
        ),
      );
}

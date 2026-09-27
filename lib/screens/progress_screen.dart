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

  int? percentValue((int, int) totals) {
    if (totals.$1 == 0) return null;
    return (totals.$2 / totals.$1 * 100).round();
  }

  @override
  Widget build(BuildContext context) {
    final global = totalsFor(questions);
    final globalPercent = percentValue(global);
    final difficult = questions.where((q) {
      final s = stats.forQuestion(q.id);
      return s.errors >= 2 || (s.attempts >= 2 && s.successRate < 0.6);
    }).toList()
      ..sort((a, b) {
        final sa = stats.forQuestion(a.id);
        final sb = stats.forQuestion(b.id);
        final rateCompare = sa.successRate.compareTo(sb.successRate);
        return rateCompare != 0 ? rateCompare : sb.errors.compareTo(sa.errors);
      });

    final rows = [
      ('CFD', questions.where((q) => q.category == AnswerCategory.cfd)),
      ('CFI', questions.where((q) => q.category == AnswerCategory.cfi)),
      ('Cartons jaunes', questions.where((q) => q.category == AnswerCategory.cj)),
      ('Cartons rouges', questions.where((q) => q.category == AnswerCategory.cr)),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Progression')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 82,
                        height: 82,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: globalPercent == null ? 0 : globalPercent / 100,
                              strokeWidth: 8,
                              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                            ),
                            Text(
                              globalPercent == null ? '—' : '$globalPercent%',
                              style: const TextStyle(fontWeight: FontWeight.w900),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Score global',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text('${global.$1} réponse(s) enregistrée(s)'),
                            Text('${difficult.length} question(s) à retravailler'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Par catégorie',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              for (final row in rows) ...[
                _ScoreCard(label: row.$1, totals: totalsFor(row.$2)),
                const SizedBox(height: 10),
              ],
              const SizedBox(height: 18),
              Text(
                'À retravailler',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              if (difficult.isEmpty)
                const Card(
                  child: ListTile(
                    leading: Icon(Icons.check_circle_outline_rounded),
                    title: Text('Aucune question difficile détectée pour le moment.'),
                    subtitle: Text('Les motifs ratés plusieurs fois apparaîtront ici.'),
                  ),
                )
              else
                for (final q in difficult) ...[
                  _DifficultTile(question: q, stats: stats.forQuestion(q.id)),
                  const SizedBox(height: 10),
                ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  final String label;
  final (int, int) totals;

  const _ScoreCard({required this.label, required this.totals});

  @override
  Widget build(BuildContext context) {
    final percent = totals.$1 == 0 ? null : (totals.$2 / totals.$1 * 100).round();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 3),
                  Text('${totals.$1} tentative(s)'),
                ],
              ),
            ),
            Text(
              percent == null ? '—' : '$percent %',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }
}

class _DifficultTile extends StatelessWidget {
  final Question question;
  final QuestionStats stats;

  const _DifficultTile({required this.question, required this.stats});

  @override
  Widget build(BuildContext context) {
    final percent = stats.attempts == 0 ? 0 : (stats.successRate * 100).round();
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(question.motif),
        subtitle: Text(
          '${stats.errors} erreur(s) sur ${stats.attempts} tentative(s) · $percent % de réussite',
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(99),
          ),
          child: Text(question.shortAnswer, style: const TextStyle(fontWeight: FontWeight.w900)),
        ),
      ),
    );
  }
}

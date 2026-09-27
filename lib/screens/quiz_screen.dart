import 'package:flutter/material.dart';
import '../models/question.dart';
import '../services/quiz_engine.dart';
import '../services/settings_service.dart';
import '../services/stats_service.dart';
import '../widgets/answer_button.dart';

class QuizScreen extends StatefulWidget {
  final String title;
  final QuizMode mode;
  final List<Question> allQuestions;
  final AppSettings settings;
  final StatsService stats;

  const QuizScreen({
    super.key,
    required this.title,
    required this.mode,
    required this.allQuestions,
    required this.settings,
    required this.stats,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late final QuizEngine _engine;
  late final List<Question> _pool;
  final List<Question> _questions = [];
  int _index = 0;
  AnswerCategory? _selected;
  bool _answered = false;
  int _sessionCorrect = 0;

  bool get _unlimited => widget.settings.questionCount == null;

  @override
  void initState() {
    super.initState();
    _engine = QuizEngine(widget.stats);
    _pool = _engine.poolForMode(widget.allQuestions, widget.mode);
    _appendBatch();
  }

  void _appendBatch() {
    if (_pool.isEmpty) return;
    final count = _unlimited ? _pool.length : widget.settings.questionCount;
    _questions.addAll(
      _engine.buildSession(
        pool: _pool,
        count: count,
        randomOrder: widget.settings.randomOrder,
        adaptive: true,
      ),
    );
  }

  Future<void> _answer(AnswerCategory answer) async {
    if (_answered) return;
    final q = _questions[_index];
    final correct = answer == q.answer;
    await widget.stats.record(q.id, correct);
    if (!mounted) return;
    setState(() {
      _selected = answer;
      _answered = true;
      if (correct) _sessionCorrect++;
    });
  }

  void _next() {
    if (_index == _questions.length - 1) {
      if (_unlimited) {
        setState(() {
          _appendBatch();
          _index++;
          _selected = null;
          _answered = false;
        });
      } else {
        _showSummary();
      }
      return;
    }

    setState(() {
      _index++;
      _selected = null;
      _answered = false;
    });
  }

  Future<void> _showSummary() async {
    final score = (_sessionCorrect / _questions.length * 100).round();
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(score >= 80 ? Icons.emoji_events_rounded : Icons.flag_rounded),
        title: const Text('Session terminée'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$_sessionCorrect / ${_questions.length}',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 4),
            Text('$score % de réussite'),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Retour à l’accueil'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: const Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Aucune question disponible dans ce mode pour le moment. Fais quelques erreurs en révision, puis elles apparaîtront ici.',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      );
    }

    final q = _questions[_index];
    final options = q.type == QuestionType.restart
        ? [AnswerCategory.cfd, AnswerCategory.cfi]
        : [AnswerCategory.cj, AnswerCategory.cr];
    final correct = _selected == q.answer;

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              children: [
                Row(
                  children: [
                    Text(
                      _unlimited
                          ? 'Question ${_index + 1} / ∞'
                          : 'Question ${_index + 1} / ${_questions.length}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const Spacer(),
                    Text(q.season, style: Theme.of(context).textTheme.labelLarge),
                  ],
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  borderRadius: BorderRadius.circular(99),
                  minHeight: 7,
                  value: _unlimited ? null : (_index + 1) / _questions.length,
                ),
                const SizedBox(height: 30),
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      q.typeLabel,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 30),
                    child: Text(
                      q.motif,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            height: 1.25,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                for (final option in options) ...[
                  AnswerButton(
                    label: option.label,
                    onPressed: _answered ? null : () => _answer(option),
                    selected: _selected == option,
                    isCorrect: _answered ? option == q.answer : null,
                    revealAsCorrect: _answered && option == q.answer,
                  ),
                  const SizedBox(height: 12),
                ],
                if (_answered) ...[
                  const SizedBox(height: 8),
                  _CorrectionCard(
                    question: q,
                    correct: correct,
                    showExplanation: widget.settings.explanations,
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _next,
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: Text(
                      !_unlimited && _index == _questions.length - 1
                          ? 'Voir mon résultat'
                          : 'Question suivante',
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CorrectionCard extends StatelessWidget {
  final Question question;
  final bool correct;
  final bool showExplanation;

  const _CorrectionCard({
    required this.question,
    required this.correct,
    required this.showExplanation,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = correct ? Colors.green.shade700 : scheme.error;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: correct
            ? Colors.green.withValues(alpha: .08)
            : scheme.errorContainer.withValues(alpha: .55),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: .35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(correct ? Icons.check_circle_rounded : Icons.cancel_rounded, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  correct ? 'Correct' : 'À revoir · ${question.answerLabel}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ),
            ],
          ),
          if (showExplanation && question.explanation.isNotEmpty) ...[
            const SizedBox(height: 9),
            Text(question.explanation),
          ],
          if (question.source != null && question.source!.isNotEmpty) ...[
            const SizedBox(height: 9),
            Text(
              'Référence : ${question.source}',
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ],
        ],
      ),
    );
  }
}

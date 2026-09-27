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
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Session terminée'),
        content: Text(
          '$_sessionCorrect / ${_questions.length} bonnes réponses '
          '(${(_sessionCorrect / _questions.length * 100).round()} %).',
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(this.context).pop();
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
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Aucune question disponible dans ce mode pour le moment.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final q = _questions[_index];
    final options = q.type == QuestionType.restart
        ? [AnswerCategory.cfd, AnswerCategory.cfi]
        : [AnswerCategory.cj, AnswerCategory.cr];

    String label(AnswerCategory answer) => switch (answer) {
          AnswerCategory.cfd => 'Coup franc direct',
          AnswerCategory.cfi => 'Coup franc indirect',
          AnswerCategory.cj => 'Carton jaune',
          AnswerCategory.cr => 'Carton rouge',
        };

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Text(
                    _unlimited
                        ? 'Question ${_index + 1} / ∞'
                        : 'Question ${_index + 1} / ${_questions.length}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Spacer(),
                  Text(q.season),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: _unlimited ? null : (_index + 1) / _questions.length,
              ),
              const Spacer(),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    q.motif,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ),
              const Spacer(),
              for (final option in options) ...[
                AnswerButton(
                  label: label(option),
                  onPressed: _answered ? null : () => _answer(option),
                  selected: _selected == option,
                  isCorrect: _answered ? option == q.answer : null,
                  revealAsCorrect: _answered && option == q.answer,
                ),
                const SizedBox(height: 12),
              ],
              if (_answered) ...[
                const SizedBox(height: 4),
                Text(
                  _selected == q.answer
                      ? 'Correct'
                      : 'Incorrect — bonne réponse : ${q.answerLabel}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: _selected == q.answer
                            ? Colors.green.shade700
                            : Theme.of(context).colorScheme.error,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                if (widget.settings.explanations && q.explanation.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(q.explanation),
                ],
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _next,
                  icon: const Icon(Icons.arrow_forward),
                  label: Text(
                    !_unlimited && _index == _questions.length - 1
                        ? 'Voir le résultat'
                        : 'Suivant',
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

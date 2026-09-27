import 'package:flutter/material.dart';
import '../models/question.dart';
import '../services/quiz_engine.dart';
import '../services/stats_service.dart';

class ExamScreen extends StatefulWidget {
  final List<Question> allQuestions;
  final StatsService stats;

  const ExamScreen({super.key, required this.allQuestions, required this.stats});

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  late final List<Question> _questions;
  final Map<int, AnswerCategory> _answers = {};
  int _index = 0;

  @override
  void initState() {
    super.initState();
    final engine = QuizEngine(widget.stats);
    final pool = engine.poolForMode(widget.allQuestions, QuizMode.exam);
    _questions = engine.buildSession(
      pool: pool,
      count: 20,
      randomOrder: true,
      adaptive: false,
    );
  }

  void _select(AnswerCategory answer) {
    setState(() => _answers[_questions[_index].id] = answer);
  }

  void _go(int delta) {
    setState(() => _index = (_index + delta).clamp(0, _questions.length - 1).toInt());
  }

  Future<void> _finish() async {
    if (_answers.length < _questions.length) {
      final continueAnyway = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Questions non répondues'),
          content: Text(
            '${_questions.length - _answers.length} question(s) sont encore sans réponse. '
            'Les terminer avant de rendre l’examen ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Rendre quand même'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Continuer'),
            ),
          ],
        ),
      );
      if (continueAnyway != false) return;
    }

    final results = <int, bool>{};
    var correct = 0;
    for (final q in _questions) {
      final isCorrect = _answers[q.id] == q.answer;
      results[q.id] = isCorrect;
      if (isCorrect) correct++;
    }
    await widget.stats.recordBatch(results);
    if (!mounted) return;

    await Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ExamResultScreen(
          correct: correct,
          total: _questions.length,
          questions: _questions,
          answers: _answers,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final q = _questions[_index];
    final options = q.type == QuestionType.restart
        ? [AnswerCategory.cfd, AnswerCategory.cfi]
        : [AnswerCategory.cj, AnswerCategory.cr];
    final selected = _answers[q.id];

    String label(AnswerCategory a) => switch (a) {
          AnswerCategory.cfd => 'Coup franc direct',
          AnswerCategory.cfi => 'Coup franc indirect',
          AnswerCategory.cj => 'Carton jaune',
          AnswerCategory.cr => 'Carton rouge',
        };

    return Scaffold(
      appBar: AppBar(title: const Text('Examen — 20 questions')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Question ${_index + 1} / ${_questions.length}'),
              const SizedBox(height: 8),
              LinearProgressIndicator(value: (_index + 1) / _questions.length),
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
                SizedBox(
                  height: 58,
                  child: OutlinedButton(
                    onPressed: () => _select(option),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: selected == option
                          ? Theme.of(context).colorScheme.primaryContainer
                          : null,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(label(option)),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _index == 0 ? null : () => _go(-1),
                      child: const Text('Précédent'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _index == _questions.length - 1
                          ? _finish
                          : () => _go(1),
                      child: Text(
                        _index == _questions.length - 1 ? 'Terminer' : 'Suivant',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ExamResultScreen extends StatelessWidget {
  final int correct;
  final int total;
  final List<Question> questions;
  final Map<int, AnswerCategory> answers;

  const ExamResultScreen({
    super.key,
    required this.correct,
    required this.total,
    required this.questions,
    required this.answers,
  });

  @override
  Widget build(BuildContext context) {
    final wrong = questions.where((q) => answers[q.id] != q.answer).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Résultat de l’examen')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            '$correct / $total',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          Text(
            '${(correct / total * 100).round()} %',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 24),
          if (wrong.isEmpty)
            const Card(
              child: ListTile(
                leading: Icon(Icons.emoji_events),
                title: Text('Sans faute !'),
              ),
            )
          else ...[
            Text('À revoir', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            for (final q in wrong)
              Card(
                child: ListTile(
                  title: Text(q.motif),
                  subtitle: Text('Bonne réponse : ${q.answerLabel}'),
                ),
              ),
          ],
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Retour à l’accueil'),
          ),
        ],
      ),
    );
  }
}

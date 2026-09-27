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
    final unanswered = _questions.length - _answers.length;
    if (unanswered > 0) {
      final finishAnyway = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Questions non répondues'),
          content: Text(
            '$unanswered question(s) sont encore sans réponse. Tu veux rendre l’examen quand même ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Continuer l’examen'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Rendre'),
            ),
          ],
        ),
      );
      if (finishAnyway != true) return;
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

    return Scaffold(
      appBar: AppBar(title: const Text('Examen · 20 questions')),
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
                      'Question ${_index + 1} / ${_questions.length}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const Spacer(),
                    Text('${_answers.length} répondues'),
                  ],
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: (_index + 1) / _questions.length,
                  minHeight: 7,
                  borderRadius: BorderRadius.circular(99),
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
                    child: Text(q.typeLabel, style: const TextStyle(fontWeight: FontWeight.w800)),
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
                  SizedBox(
                    height: 62,
                    child: OutlinedButton(
                      onPressed: () => _select(option),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: selected == option
                            ? Theme.of(context).colorScheme.primaryContainer
                            : null,
                        side: selected == option
                            ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)
                            : null,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(option.label),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _index == 0 ? null : () => _go(-1),
                        icon: const Icon(Icons.arrow_back_rounded),
                        label: const Text('Précédent'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _index == _questions.length - 1 ? _finish : () => _go(1),
                        icon: Icon(
                          _index == _questions.length - 1
                              ? Icons.flag_rounded
                              : Icons.arrow_forward_rounded,
                        ),
                        label: Text(
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
    final score = (correct / total * 100).round();

    return Scaffold(
      appBar: AppBar(title: const Text('Résultat de l’examen')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(
                        score >= 80 ? Icons.emoji_events_rounded : Icons.flag_rounded,
                        size: 46,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '$correct / $total',
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                      Text(
                        '$score % de réussite',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                wrong.isEmpty ? 'Parfait' : 'À revoir (${wrong.length})',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              if (wrong.isEmpty)
                const Card(
                  child: ListTile(
                    leading: Icon(Icons.check_circle_outline_rounded),
                    title: Text('Sans faute !'),
                    subtitle: Text('Tu as répondu juste aux 20 questions.'),
                  ),
                )
              else
                for (final q in wrong)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Card(
                      child: ListTile(
                        title: Text(q.motif),
                        subtitle: Text('Bonne réponse : ${q.answerLabel}'),
                        trailing: Text(
                          q.shortAnswer,
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                  ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Retour à l’accueil'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../models/question.dart';
import '../services/question_repository.dart';
import '../services/quiz_engine.dart';
import '../services/settings_service.dart';
import '../services/stats_service.dart';
import 'exam_screen.dart';
import 'progress_screen.dart';
import 'quiz_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  final AppSettings settings;
  final SettingsService settingsService;
  final StatsService stats;
  final ValueChanged<AppSettings> onSettingsChanged;

  const HomeScreen({
    super.key,
    required this.settings,
    required this.settingsService,
    required this.stats,
    required this.onSettingsChanged,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Question>> _future;

  @override
  void initState() {
    super.initState();
    _future = QuestionRepository().loadQuestions();
  }

  Future<void> _openQuiz(List<Question> questions, QuizMode mode, String title) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QuizScreen(
          title: title,
          mode: mode,
          allQuestions: questions,
          settings: widget.settings,
          stats: widget.stats,
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Révision Arbitrage'),
        actions: [
          IconButton(
            tooltip: 'Paramètres',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => SettingsScreen(
                  initial: widget.settings,
                  service: widget.settingsService,
                  stats: widget.stats,
                  onChanged: widget.onSettingsChanged,
                ),
              ),
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<Question>>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            if (snapshot.hasError) {
              return Center(child: Text('Erreur : ${snapshot.error}'));
            }
            return const Center(child: CircularProgressIndicator());
          }
          final questions = snapshot.data!;
          final errors = questions
              .where((q) => widget.stats.forQuestion(q.id).errors > 0)
              .length;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Loi 12 · Saison 2026-2027',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                '${questions.length} motifs disponibles · hors ligne',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              _HomeButton(
                icon: Icons.shuffle,
                label: 'Tout réviser',
                onTap: () => _openQuiz(questions, QuizMode.all, 'Tout réviser'),
              ),
              _HomeButton(
                icon: Icons.sports_soccer,
                label: 'CFD / CFI',
                onTap: () => _openQuiz(questions, QuizMode.restart, 'CFD / CFI'),
              ),
              _HomeButton(
                icon: Icons.style,
                label: 'Cartons',
                onTap: () => _openQuiz(questions, QuizMode.cards, 'Cartons'),
              ),
              _HomeButton(
                icon: Icons.replay,
                label: errors == 0 ? 'Mes erreurs' : 'Mes erreurs ($errors)',
                onTap: () => _openQuiz(questions, QuizMode.errors, 'Mes erreurs'),
              ),
              _HomeButton(
                icon: Icons.assignment_outlined,
                label: 'Examen',
                onTap: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ExamScreen(
                      allQuestions: questions,
                        stats: widget.stats,
                      ),
                    ),
                  );
                  if (mounted) setState(() {});
                },
              ),
              _HomeButton(
                icon: Icons.insights,
                label: 'Progression',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ProgressScreen(
                      questions: questions,
                      stats: widget.stats,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.psychology_alt_outlined),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'La révision intelligente favorise les questions ratées et espace celles déjà maîtrisées.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _HomeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _HomeButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: SizedBox(
          height: 64,
          child: FilledButton.tonalIcon(
            onPressed: onTap,
            icon: Icon(icon),
            label: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                label,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
      );
}

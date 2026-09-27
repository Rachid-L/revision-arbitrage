import 'package:flutter/material.dart';
import '../models/question.dart';
import '../services/question_repository.dart';
import '../services/quiz_engine.dart';
import '../services/settings_service.dart';
import '../services/stats_service.dart';
import '../widgets/mode_card.dart';
import 'about_screen.dart';
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

  Future<void> _openSettings() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SettingsScreen(
          initial: widget.settings,
          service: widget.settingsService,
          stats: widget.stats,
          onChanged: widget.onSettingsChanged,
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
            tooltip: 'À propos',
            icon: const Icon(Icons.info_outline_rounded),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AboutScreen()),
            ),
          ),
          IconButton(
            tooltip: 'Paramètres',
            icon: const Icon(Icons.settings_outlined),
            onPressed: _openSettings,
          ),
          const SizedBox(width: 4),
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
          var attempts = 0;
          var correct = 0;
          var errorQuestions = 0;
          for (final q in questions) {
            final stat = widget.stats.forQuestion(q.id);
            attempts += stat.attempts;
            correct += stat.correct;
            if (stat.errors > 0) errorQuestions++;
          }
          final score = attempts == 0 ? null : (correct / attempts * 100).round();

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 920),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                children: [
                  _HeroCard(
                    questionCount: questions.length,
                    attempts: attempts,
                    score: score,
                  ),
                  const SizedBox(height: 26),
                  Text(
                    'Choisis ton mode',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 12),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final twoColumns = constraints.maxWidth >= 700;
                      final width = twoColumns
                          ? (constraints.maxWidth - 12) / 2
                          : constraints.maxWidth;
                      final cards = <Widget>[
                        ModeCard(
                          icon: Icons.shuffle_rounded,
                          title: 'Tout réviser',
                          subtitle: 'CFD, CFI, jaunes et rouges mélangés.',
                          onTap: () => _openQuiz(questions, QuizMode.all, 'Tout réviser'),
                          badge: '${questions.length}',
                        ),
                        ModeCard(
                          icon: Icons.sports_soccer_rounded,
                          title: 'CFD / CFI',
                          subtitle: 'Travaille uniquement la reprise du jeu.',
                          onTap: () => _openQuiz(questions, QuizMode.restart, 'CFD / CFI'),
                        ),
                        ModeCard(
                          icon: Icons.style_rounded,
                          title: 'Cartons',
                          subtitle: 'Choisis entre carton jaune et carton rouge.',
                          onTap: () => _openQuiz(questions, QuizMode.cards, 'Cartons'),
                        ),
                        ModeCard(
                          icon: Icons.replay_rounded,
                          title: 'Mes erreurs',
                          subtitle: 'Rejoue les motifs déjà ratés.',
                          onTap: () => _openQuiz(questions, QuizMode.errors, 'Mes erreurs'),
                          badge: errorQuestions == 0 ? null : '$errorQuestions',
                        ),
                        ModeCard(
                          icon: Icons.fact_check_outlined,
                          title: 'Examen',
                          subtitle: '20 questions, correction uniquement à la fin.',
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
                        ModeCard(
                          icon: Icons.insights_rounded,
                          title: 'Progression',
                          subtitle: 'Scores par catégorie et questions à retravailler.',
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ProgressScreen(
                                questions: questions,
                                stats: widget.stats,
                              ),
                            ),
                          ),
                        ),
                      ];

                      return Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [for (final card in cards) SizedBox(width: width, child: card)],
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.psychology_alt_outlined),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Révision intelligente',
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w800,
                                      ),
                                ),
                                const SizedBox(height: 3),
                                const Text(
                                  'Les questions ratées sont favorisées dans les prochaines sessions, tandis que celles déjà maîtrisées reviennent moins souvent.',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final int questionCount;
  final int attempts;
  final int? score;

  const _HeroCard({required this.questionCount, required this.attempts, required this.score});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          colors: dark
              ? const [Color(0xFF172B50), Color(0xFF101827)]
              : const [Color(0xFFE7EFFF), Color(0xFFF8FAFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface.withValues(alpha: .78),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: const Text(
                        'LOI 12 · SAISON 2026-2027',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Révise les bons réflexes\nd’arbitrage.',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            height: 1.05,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              const _BrandMark(size: 82),
            ],
          ),
          const SizedBox(height: 10),
          Text('$questionCount motifs disponibles · 100 % hors ligne'),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _Metric(label: 'Réponses', value: attempts == 0 ? '—' : '$attempts'),
              _Metric(label: 'Réussite', value: score == null ? '—' : '$score %'),
              const _Metric(label: 'Compte', value: 'Aucun'),
            ],
          ),
        ],
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  final double size;
  const _BrandMark({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF111E34),
        borderRadius: BorderRadius.circular(size * .23),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: size * .18,
            top: size * .16,
            child: Container(
              width: size * .19,
              height: size * .30,
              decoration: BoxDecoration(
                color: const Color(0xFFFACC15),
                borderRadius: BorderRadius.circular(size * .035),
              ),
            ),
          ),
          Positioned(
            right: size * .18,
            top: size * .16,
            child: Container(
              width: size * .19,
              height: size * .30,
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444),
                borderRadius: BorderRadius.circular(size * .035),
              ),
            ),
          ),
          Positioned(
            bottom: size * .14,
            child: Icon(Icons.sports_rounded, color: Colors.white, size: size * .42),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;

  const _Metric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: .82),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text('$label  ·  $value', style: const TextStyle(fontWeight: FontWeight.w800)),
    );
  }
}

enum QuestionType { restart, discipline }

enum AnswerCategory { cfd, cfi, cj, cr }

class Question {
  final int id;
  final QuestionType type;
  final AnswerCategory category;
  final String motif;
  final AnswerCategory answer;
  final String explanation;
  final String? alternative;
  final String season;
  final String? source;

  const Question({
    required this.id,
    required this.type,
    required this.category,
    required this.motif,
    required this.answer,
    required this.explanation,
    required this.season,
    this.alternative,
    this.source,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    AnswerCategory parseAnswer(String value) {
      return AnswerCategory.values.firstWhere(
        (e) => e.name.toUpperCase() == value.toUpperCase(),
      );
    }

    return Question(
      id: json['id'] as int,
      type: (json['type'] as String) == 'reprise'
          ? QuestionType.restart
          : QuestionType.discipline,
      category: parseAnswer(json['category'] as String),
      motif: json['motif'] as String,
      answer: parseAnswer(json['answer'] as String),
      explanation: (json['explanation'] as String?) ?? '',
      alternative: json['alternative'] as String?,
      season: (json['season'] as String?) ?? '2026-2027',
      source: json['source'] as String?,
    );
  }

  String get shortAnswer => answer.name.toUpperCase();
  String get typeLabel => type == QuestionType.restart
      ? 'Reprise du jeu'
      : 'Sanction disciplinaire';

  String get answerLabel => answer.label;
}

extension AnswerCategoryLabel on AnswerCategory {
  String get label => switch (this) {
        AnswerCategory.cfd => 'Coup franc direct',
        AnswerCategory.cfi => 'Coup franc indirect',
        AnswerCategory.cj => 'Carton jaune',
        AnswerCategory.cr => 'Carton rouge',
      };

  String get shortLabel => switch (this) {
        AnswerCategory.cfd => 'CFD',
        AnswerCategory.cfi => 'CFI',
        AnswerCategory.cj => 'CJ',
        AnswerCategory.cr => 'CR',
      };
}

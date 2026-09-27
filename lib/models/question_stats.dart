class QuestionStats {
  final int attempts;
  final int correct;

  const QuestionStats({this.attempts = 0, this.correct = 0});

  int get errors => attempts - correct;
  double get successRate => attempts == 0 ? 0 : correct / attempts;

  QuestionStats addResult(bool isCorrect) => QuestionStats(
        attempts: attempts + 1,
        correct: correct + (isCorrect ? 1 : 0),
      );

  Map<String, dynamic> toJson() => {
        'attempts': attempts,
        'correct': correct,
      };

  factory QuestionStats.fromJson(Map<String, dynamic> json) => QuestionStats(
        attempts: (json['attempts'] as num?)?.toInt() ?? 0,
        correct: (json['correct'] as num?)?.toInt() ?? 0,
      );
}

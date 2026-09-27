import 'package:flutter_test/flutter_test.dart';
import 'package:revision_arbitrage/models/question.dart';

void main() {
  test('parse une question JSON', () {
    final q = Question.fromJson({
      'id': 1,
      'type': 'reprise',
      'category': 'CFI',
      'motif': 'Obstacle sans contact',
      'answer': 'CFI',
      'explanation': 'Sans contact = CFI.',
      'season': '2026-2027',
    });
    expect(q.type, QuestionType.restart);
    expect(q.answer, AnswerCategory.cfi);
  });
}

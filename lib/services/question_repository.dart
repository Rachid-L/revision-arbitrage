import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/question.dart';

class QuestionRepository {
  Future<List<Question>> loadQuestions() async {
    final raw = await rootBundle.loadString('assets/data/questions.json');
    final data = jsonDecode(raw) as List<dynamic>;
    final questions = data
        .map((item) => Question.fromJson(item as Map<String, dynamic>))
        .toList();
    questions.sort((a, b) => a.id.compareTo(b.id));
    return questions;
  }
}

import 'package:json_annotation/json_annotation.dart';

part 'skin_quiz.g.dart';

@JsonSerializable()
class SkinQuiz {
  final String title;
  final String description;
  final List<QuizQuestion> questions;
  final QuizResults results;

  SkinQuiz({
    required this.title,
    required this.description,
    required this.questions,
    required this.results,
  });

  factory SkinQuiz.fromJson(Map<String, dynamic> json) =>
      _$SkinQuizFromJson(json);
  Map<String, dynamic> toJson() => _$SkinQuizToJson(this);
}

@JsonSerializable()
class QuizQuestion {
  final String id;
  final String question;
  final List<QuizOption> options;

  QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) =>
      _$QuizQuestionFromJson(json);
  Map<String, dynamic> toJson() => _$QuizQuestionToJson(this);
}

@JsonSerializable()
class QuizOption {
  final String id;
  final String text;
  final Map<String, int> scoreMap;

  QuizOption({required this.id, required this.text, required this.scoreMap});

  factory QuizOption.fromJson(Map<String, dynamic> json) =>
      _$QuizOptionFromJson(json);
  Map<String, dynamic> toJson() => _$QuizOptionToJson(this);
}

@JsonSerializable()
class QuizResults {
  final List<QuizRule> rules;

  QuizResults({required this.rules});

  factory QuizResults.fromJson(Map<String, dynamic> json) =>
      _$QuizResultsFromJson(json);
  Map<String, dynamic> toJson() => _$QuizResultsToJson(this);
}

@JsonSerializable()
class QuizRule {
  final String condition;
  final String skinType;
  final String description;
  final String icon;
  final String color;

  QuizRule({
    required this.condition,
    required this.skinType,
    required this.description,
    required this.icon,
    required this.color,
  });

  factory QuizRule.fromJson(Map<String, dynamic> json) =>
      _$QuizRuleFromJson(json);
  Map<String, dynamic> toJson() => _$QuizRuleToJson(this);
}

// Quiz durumunu yönetmek için sınıf
class QuizState {
  final int currentQuestionIndex;
  final Map<String, int> scores;
  final Map<String, String> answers;
  final bool isCompleted;

  QuizState({
    this.currentQuestionIndex = 0,
    this.scores = const {},
    this.answers = const {},
    this.isCompleted = false,
  });

  QuizState copyWith({
    int? currentQuestionIndex,
    Map<String, int>? scores,
    Map<String, String>? answers,
    bool? isCompleted,
  }) {
    return QuizState(
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      scores: scores ?? this.scores,
      answers: answers ?? this.answers,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  // Skor hesaplama
  Map<String, int> calculateScores() {
    Map<String, int> totalScores = {};

    for (String answer in answers.values) {
      // Bu kısım quiz widget'ında implement edilecek
    }

    return totalScores;
  }
}

class QuizQuestion {
  final String id;
  final String character;
  final String salt;
  final String correctHash;
  final int level;

  QuizQuestion({
    required this.id,
    required this.character,
    required this.salt,
    required this.correctHash,
    required this.level,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id']?.toString() ?? '',
      character: json['character']?.toString() ?? '',
      salt: json['salt']?.toString() ?? '',
      correctHash: json['hash']?.toString() ?? json['correct_hash']?.toString() ?? '',
      level: int.tryParse(json['level']?.toString() ?? '1') ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'character': character,
      'salt': salt,
      'correct_hash': correctHash,
      'level': level,
    };
  }
}

class QuizSession {
  final String sessionId;
  final int level;
  final List<QuizQuestion> questions;
  final DateTime createdAt;

  QuizSession({
    required this.sessionId,
    required this.level,
    required this.questions,
    required this.createdAt,
  });

  factory QuizSession.fromJson(Map<String, dynamic> json) {
    var list = json['questions'] as List<dynamic>? ?? [];
    List<QuizQuestion> questionsList =
        list.map((i) => QuizQuestion.fromJson(i as Map<String, dynamic>)).toList();

    return QuizSession(
      sessionId: json['session_id'].toString(),
      level: int.tryParse(json['level']?.toString() ?? '1') ?? 1,
      questions: questionsList,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'session_id': sessionId,
      'level': level,
      'questions': questions.map((q) => q.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class UserAnswer {
  final String questionId;
  final String answerText;

  UserAnswer({
    required this.questionId,
    required this.answerText,
  });

  Map<String, dynamic> toJson() {
    return {
      'question_id': questionId,
      'answer_text': answerText,
    };
  }
}

class SessionSubmissionResult {
  final bool isValid;
  final int scoreAdded;
  final int maxScore;

  SessionSubmissionResult({
    required this.isValid,
    required this.scoreAdded,
    required this.maxScore,
  });

  factory SessionSubmissionResult.fromJson(Map<String, dynamic> json) {
    return SessionSubmissionResult(
      isValid: json['is_valid'] as bool? ?? false,
      scoreAdded: json['score_added'] as int? ?? 0,
      maxScore: json['max_score'] as int? ?? 0,
    );
  }
}

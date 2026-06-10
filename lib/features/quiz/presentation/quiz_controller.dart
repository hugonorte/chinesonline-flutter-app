import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/quiz_models.dart';
import '../data/quiz_repository.dart';
import '../../auth/presentation/auth_provider.dart';

part 'quiz_controller.g.dart';

// Definimos o estado da nossa tela de Quiz
class QuizState {
  final QuizSession? session;
  final int currentIndex;
  final List<UserAnswer> userAnswers;
  final bool isChecking;
  final bool isCorrect;
  final bool isFinished;
  final int currentScore;
  final int maxScore;
  final String? error;

  QuizState({
    this.session,
    this.currentIndex = 0,
    this.userAnswers = const [],
    this.isChecking = false,
    this.isCorrect = false,
    this.isFinished = false,
    this.currentScore = 0,
    this.maxScore = 0, // Poderia vir do user profile state
    this.error,
  });

  QuizState copyWith({
    QuizSession? session,
    int? currentIndex,
    List<UserAnswer>? userAnswers,
    bool? isChecking,
    bool? isCorrect,
    bool? isFinished,
    int? currentScore,
    int? maxScore,
    String? error,
  }) {
    return QuizState(
      session: session ?? this.session,
      currentIndex: currentIndex ?? this.currentIndex,
      userAnswers: userAnswers ?? this.userAnswers,
      isChecking: isChecking ?? this.isChecking,
      isCorrect: isCorrect ?? this.isCorrect,
      isFinished: isFinished ?? this.isFinished,
      currentScore: currentScore ?? this.currentScore,
      maxScore: maxScore ?? this.maxScore,
      error: error ?? this.error,
    );
  }

  QuizQuestion? get currentQuestion {
    if (session == null || session!.questions.isEmpty) return null;
    if (currentIndex >= session!.questions.length) return null;
    return session!.questions[currentIndex];
  }
}

@riverpod
class QuizController extends _$QuizController {
  @override
  FutureOr<QuizState> build() async {
    // Pega o estado global do usuário
    final user = await ref.read(userProfileProvider.future);
    final userLevel = user?.level ?? 1;

    // Ao iniciar a tela, carrega a sessão de acordo com o nível
    final session = await ref.read(quizRepositoryProvider).fetchSession(userLevel);

    return QuizState(session: session, maxScore: session.maxScore > 0 ? session.maxScore : (user?.maxScore ?? 0), currentScore: 0);
  }

  // Lógica Anti-Cheat Local
  Future<void> submitAnswer(String rawInputText) async {
    final inputText = rawInputText.trim().toLowerCase();
    final currentState = state.value;
    if (currentState == null || currentState.session == null) return;
    if (currentState.isChecking || currentState.isFinished) return;

    final question = currentState.currentQuestion;
    if (question == null) return;

    // 1. Processamento Anti-Cheat: Validar hash localmente sem texto plano na memória
    final bytes = utf8.encode(inputText + question.salt);
    final hash = sha256.convert(bytes);
    final isCorrect = (hash.toString() == question.correctHash);

    // 2. Gravar resposta do usuário e atualizar tela para "Checking"
    final newAnswers = List<UserAnswer>.from(currentState.userAnswers)
      ..add(UserAnswer(questionId: question.id, answerText: inputText));

    int newScore = currentState.currentScore;
    if (isCorrect) {
      newScore += 20; // Feedback local instantâneo
    }

    state = AsyncData(
      currentState.copyWith(
        isChecking: true,
        isCorrect: isCorrect,
        userAnswers: newAnswers,
        currentScore: newScore,
      ),
    );

    // 3. Aguarda 3 segundos para o usuário ver o feedback verde/vermelho
    await Future.delayed(const Duration(seconds: 3));

    // 4. Avança para a próxima pergunta ou finaliza a sessão
    final nextIndex = currentState.currentIndex + 1;
    if (nextIndex >= currentState.session!.questions.length) {
      await _finishSession(currentState.session!.sessionId, newAnswers);
    } else {
      state = AsyncData(
        state.value!.copyWith(
          currentIndex: nextIndex,
          isChecking: false,
          isCorrect: false,
        ),
      );
    }
  }

  Future<void> _finishSession(
    String sessionId,
    List<UserAnswer> answers,
  ) async {
    state = AsyncData(
      state.value!.copyWith(isFinished: true, isChecking: false),
    );

    try {
      // 5. Validação Server-Side obrigatória para enviar os resultados e checar bots (Time-Spoofing)
      final result = await ref
          .read(quizRepositoryProvider)
          .submitSession(sessionId, answers);

      // Opcional: Atualizar o score com o valor validado pelo servidor
      state = AsyncData(
        state.value!.copyWith(
          currentScore:
              state.value!.currentScore, // ou result.scoreAdded + oldScore
          maxScore: result.maxScore > state.value!.maxScore
              ? result.maxScore
              : state.value!.maxScore,
        ),
      );
    } catch (e, stack) {
      debugPrint('Erro crítico ao submeter a sessão: $e\\n$stack');
      state = AsyncData(
        state.value!.copyWith(
          error: 'Falha ao salvar a pontuação no servidor. Tente novamente mais tarde.',
        ),
      );
    }
  }
}

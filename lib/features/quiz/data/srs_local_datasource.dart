import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'local_ideogram_stat.dart';
import '../domain/quiz_models.dart';

final srsLocalDataSourceProvider = Provider<SrsLocalDataSource>((ref) {
  return SrsLocalDataSource();
});

class SrsLocalDataSource {
  static const String boxName = 'ideogram_stats';

  Box<LocalIdeogramStat> get _box => Hive.box<LocalIdeogramStat>(boxName);

  Future<void> updateStat(int ideogramId, String gameType, bool isCorrect) async {
    final key = '${ideogramId}_$gameType';
    var stat = _box.get(key);

    if (stat == null) {
      stat = LocalIdeogramStat(
        ideogramId: ideogramId,
        gameType: gameType,
        lastReviewed: DateTime.now(),
      );
      await _box.put(key, stat);
    }

    if (isCorrect) {
      stat.correctAttempts++;
    } else {
      stat.wrongAttempts++;
    }
    
    stat.lastReviewed = DateTime.now();
    await stat.save();
  }

  List<QuizQuestion> buildDeck(List<QuizQuestion> backendQuestions, String gameType) {
    // Calcular a prioridade para cada questão com base no histórico local
    final questionsWithPriority = backendQuestions.map((q) {
      final ideogramId = int.tryParse(q.id) ?? 0;
      final key = '${ideogramId}_$gameType';
      final stat = _box.get(key);

      // Se não há histórico, a prioridade é 0 (neutra)
      int priority = 0;
      if (stat != null) {
        priority = (stat.wrongAttempts * 3) - stat.correctAttempts;
      }

      return _QuestionWithPriority(q, priority);
    }).toList();

    // Ordenar da maior prioridade (mais erradas) para a menor
    questionsWithPriority.sort((a, b) => b.priority.compareTo(a.priority));

    final deck = <QuizQuestion>[];
    
    // Regra de espaçamento e preenchimento
    for (final item in questionsWithPriority) {
      if (deck.length >= 10) break; // Limite do lote

      if (item.priority > -5) {
        deck.add(item.question);
      }
    }

    // Se por acaso as prioritárias não baterem 10, preencher com as filtradas (memorizadas)
    if (deck.length < 10) {
      for (final item in questionsWithPriority) {
        if (deck.length >= 10) break;
        if (item.priority <= -5 && !deck.contains(item.question)) {
          deck.add(item.question);
        }
      }
    }

    return deck;
  }
}

class _QuestionWithPriority {
  final QuizQuestion question;
  final int priority;

  _QuestionWithPriority(this.question, this.priority);
}

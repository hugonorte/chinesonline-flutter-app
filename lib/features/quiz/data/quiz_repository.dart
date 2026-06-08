import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../domain/quiz_models.dart';

final quizRepositoryProvider = Provider<QuizRepository>((ref) {
  return QuizRepository(apiClient);
});

class QuizRepository {
  final Dio _dio;

  QuizRepository(this._dio);

  Future<QuizSession> fetchSession(int level) async {
    try {
      final response = await _dio.get(
        '/sessions/new',
        queryParameters: {'level': level},
      );
      print('=== DEBUG JSON RECEBIDO DO BACKEND ===');
      print(response.data);
      print('======================================');
      return QuizSession.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      print('Erro na rede ou backend ao buscar sessão: ${e.response?.data ?? e.message}');
      throw Exception('Failed to fetch quiz session: ${e.message}');
    } catch (e, stack) {
      print('Erro de Parsing ou Inesperado: $e\\n$stack');
      throw Exception('Unexpected error: $e');
    }
  }

  Future<SessionSubmissionResult> submitSession(String sessionId, List<UserAnswer> answers) async {
    try {
      final response = await _dio.post(
        '/sessions/$sessionId/submit',
        data: {
          'answers': { for (var a in answers) a.questionId: a.answerText },
        },
      );
      return SessionSubmissionResult.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      print('Erro na rede ou backend ao submeter sessão: ${e.response?.data ?? e.message}');
      throw Exception('Failed to submit quiz session: ${e.message}');
    } catch (e, stack) {
      print('Erro Inesperado na submissão: $e\\n$stack');
      throw Exception('Unexpected error: $e');
    }
  }
}

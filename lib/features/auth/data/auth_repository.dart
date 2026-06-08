import 'package:chinesonline/core/network/api_client.dart';

class AuthRepository {
  Future<void> syncUser({
    required String name,
    required String email,
    required int country,
    required int accountType,
    required String birthDate,
  }) async {
    try {
      await apiClient.post(
        '/users/sync',
        data: {
          'name': name,
          'email': email,
          'country': country,
          'account_type': accountType,
          'birth_date': birthDate,
        },
      );
    } catch (e) {
      throw Exception('Falha ao sincronizar usuário: $e');
    }
  }

  Future<void> recordLogin(String device) async {
    try {
      await apiClient.post(
        '/auth/login',
        data: {'device': device},
      );
    } catch (e) {
      throw Exception('Falha ao registrar login: $e');
    }
  }
}

final authRepository = AuthRepository();

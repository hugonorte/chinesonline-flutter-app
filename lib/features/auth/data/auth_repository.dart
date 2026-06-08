import 'package:chinesonline/core/network/api_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/user_model.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return authRepository;
});

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

  Future<AppUser> getMe() async {
    try {
      final response = await apiClient.get('/users/me');
      return AppUser.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Falha ao buscar perfil do usuário: $e');
    }
  }
}

final authRepository = AuthRepository();

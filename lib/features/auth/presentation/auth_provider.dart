import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/user_model.dart';
import '../data/auth_repository.dart';

part 'auth_provider.g.dart';

@Riverpod(keepAlive: true)
class AuthState extends _$AuthState {
  @override
  FutureOr<AppUser?> build() async {
    return null;
  }

  Future<void> fetchUser() async {
    state = const AsyncLoading();
    try {
      final user = await ref.read(authRepositoryProvider).getMe();
      state = AsyncData(user);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

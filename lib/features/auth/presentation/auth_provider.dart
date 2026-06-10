import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/user_model.dart';
import '../data/auth_repository.dart';
import '../data/auth_provider.dart' as auth_data;

part 'auth_provider.g.dart';

@Riverpod(keepAlive: true)
class UserProfile extends _$UserProfile {
  @override
  FutureOr<AppUser?> build() async {
    final fbUser = await ref.watch(auth_data.authStateProvider.future);
    if (fbUser == null) return null;
    
    try {
      return await ref.read(authRepositoryProvider).getMe();
    } catch (e) {
      return null;
    }
  }
}

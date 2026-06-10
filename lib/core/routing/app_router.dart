import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/data/auth_provider.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/quiz/presentation/quiz_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final isRegistering = ref.watch(isRegisteringProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      if (authState.isLoading) return '/splash';

      final bool isAuth = authState.value != null;
      final bool isSplash = state.matchedLocation == '/splash';
      final bool isLogin = state.matchedLocation == '/login';
      final bool isRegister = state.matchedLocation == '/register';
      final bool isAuthRoute = isLogin || isRegister;

      if (!isAuth && !isAuthRoute && !isSplash) {
        return '/login';
      }

      if (isAuth && isAuthRoute) {
        if (isRegister && isRegistering) {
          return null;
        }
        return '/quiz';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const QuizScreen(),
      ),
      GoRoute(
        path: '/quiz',
        builder: (context, state) => const QuizScreen(),
      ),
    ],
  );
});

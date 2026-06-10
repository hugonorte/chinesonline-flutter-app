import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

class IsRegisteringNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setState(bool value) {
    state = value;
  }
}

final isRegisteringProvider = NotifierProvider<IsRegisteringNotifier, bool>(() {
  return IsRegisteringNotifier();
});

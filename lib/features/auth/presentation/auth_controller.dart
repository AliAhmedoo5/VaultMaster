import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/auth_repository.dart';

part 'auth_controller.g.dart';

@riverpod
class AuthController extends _$AuthController {
  @override
  FutureOr<void> build() {
    // Initial state is idle (void)
  }

  Future<void> loginWithEmailAndPassword(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      if (kIsWeb) {
        await Future.delayed(const Duration(milliseconds: 600));
        ref.read(sandboxAuthStateProvider.notifier).signIn();
        return;
      }
      await ref.read(authRepositoryProvider).signInWithEmailAndPassword(email, password);
    });
  }

  Future<void> signUpWithEmailAndPassword(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      if (kIsWeb) {
        await Future.delayed(const Duration(milliseconds: 600));
        ref.read(sandboxAuthStateProvider.notifier).signIn();
        return;
      }
      await ref.read(authRepositoryProvider).createUserWithEmailAndPassword(email, password);
    });
  }

  Future<void> loginWithGoogle() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      if (kIsWeb) {
        await Future.delayed(const Duration(milliseconds: 600));
        ref.read(sandboxAuthStateProvider.notifier).signIn();
        return;
      }
      await ref.read(authRepositoryProvider).signInWithGoogle();
    });
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      if (kIsWeb) {
        await Future.delayed(const Duration(milliseconds: 300));
        ref.read(sandboxAuthStateProvider.notifier).signOut();
        return;
      }
      await ref.read(authRepositoryProvider).signOut();
    });
  }
}

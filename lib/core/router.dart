import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/auth/presentation/welcome_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/splash/presentation/splash_screen.dart';
import '../features/vault/presentation/vault_pin_screen.dart';
import '../features/vault/presentation/vault_screen.dart';
import '../features/document/domain/document_model.dart';
import '../features/document/presentation/document_viewer_screen.dart';

part 'router.g.dart';

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen(
      authStateProvider,
      (previous, next) {
        notifyListeners();
      },
    );
  }
}

@riverpod
GoRouter router(RouterRef ref) {
  final authStateVal = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: RouterNotifier(ref),
    redirect: (context, state) {
      if (authStateVal.isLoading) return null;

      final user = authStateVal.valueOrNull;
      final isLoggingIn = state.matchedLocation == '/login';
      final isWelcoming = state.matchedLocation == '/welcome';
      final isSplash = state.matchedLocation == '/splash';

      if (isSplash) return null;

      if (user == null) {
        if (!isLoggingIn && !isWelcoming) {
          return '/welcome';
        }
      } else {
        if (isLoggingIn || isWelcoming) {
          return '/home';
        }
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/vault_pin',
        builder: (context, state) => const VaultPinScreen(),
      ),
      GoRoute(
        path: '/vault',
        builder: (context, state) => const VaultScreen(),
      ),
      GoRoute(
        path: '/document/:id',
        builder: (context, state) {
          final document = state.extra as DocumentModel;
          return DocumentViewerScreen(document: document);
        },
      ),
    ],
  );
}

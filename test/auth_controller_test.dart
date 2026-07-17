import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vaultmaster/features/auth/presentation/auth_controller.dart';

void main() {
  group('AuthController Tests', () {
    test('initial state should be AsyncValue.data(null)', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final authState = container.read(authControllerProvider);
      
      expect(authState, const AsyncValue<void>.data(null));
    });
  });
}

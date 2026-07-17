import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'vault_security_service.g.dart';

class VaultSecurityService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const String _pinKey = 'vault_security_pin';
  
  bool _isUnlocked = false;

  bool get isUnlocked => _isUnlocked;

  Future<bool> hasPin() async {
    final pin = await _storage.read(key: _pinKey);
    return pin != null && pin.isNotEmpty;
  }

  Future<void> setPin(String pin) async {
    await _storage.write(key: _pinKey, value: pin);
    _isUnlocked = true;
  }

  Future<bool> verifyPin(String pin) async {
    final storedPin = await _storage.read(key: _pinKey);
    if (storedPin == pin) {
      _isUnlocked = true;
      return true;
    }
    return false;
  }

  void lockVault() {
    _isUnlocked = false;
  }
}

@Riverpod(keepAlive: true)
VaultSecurityService vaultSecurityService(VaultSecurityServiceRef ref) {
  return VaultSecurityService();
}

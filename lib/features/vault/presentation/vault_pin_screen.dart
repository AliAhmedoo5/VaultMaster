import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import '../data/vault_security_service.dart';

class VaultPinScreen extends ConsumerStatefulWidget {
  const VaultPinScreen({super.key});

  @override
  ConsumerState<VaultPinScreen> createState() => _VaultPinScreenState();
}

class _VaultPinScreenState extends ConsumerState<VaultPinScreen> {
  String _pin = '';
  bool _isLoading = true;
  bool _isSettingUp = false;
  String _errorMsg = '';
  String _confirmPin = '';
  bool _isConfirming = false;

  @override
  void initState() {
    super.initState();
    _checkSetup();
  }

  Future<void> _checkSetup() async {
    final hasPin = await ref.read(vaultSecurityServiceProvider).hasPin();
    setState(() {
      _isSettingUp = !hasPin;
      _isLoading = false;
    });
  }

  void _onDigitPress(String digit) async {
    if (_pin.length < 4) {
      setState(() {
        _pin += digit;
        _errorMsg = '';
      });
    }

    if (_pin.length == 4) {
      if (_isSettingUp) {
        if (!_isConfirming) {
          // First time entry done, now confirm
          setState(() {
            _confirmPin = _pin;
            _pin = '';
            _isConfirming = true;
          });
        } else {
          // Second time entry done
          if (_pin == _confirmPin) {
            await ref.read(vaultSecurityServiceProvider).setPin(_pin);
            if (mounted) context.go('/vault');
          } else {
            setState(() {
              _errorMsg = 'PINs do not match. Try again.';
              _pin = '';
              _confirmPin = '';
              _isConfirming = false;
            });
          }
        }
      } else {
        // Normal auth
        final valid = await ref.read(vaultSecurityServiceProvider).verifyPin(_pin);
        if (valid) {
          if (mounted) context.go('/vault');
        } else {
          setState(() {
            _errorMsg = 'Incorrect PIN';
            _pin = '';
          });
        }
      }
    }
  }

  void _onDeletePress() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F0F13), // Deep dark background
        body: Center(child: CircularProgressIndicator(color: Colors.cyanAccent)),
      );
    }

    String title = 'Enter Vault PIN';
    if (_isSettingUp) {
      title = _isConfirming ? 'Confirm Vault PIN' : 'Create Vault PIN';
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0C),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            const Icon(Icons.lock, color: Colors.cyanAccent, size: 48),
            const SizedBox(height: AppTheme.spacingMd),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: AppTheme.spacingXl),
            // PIN Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                final isFilled = index < _pin.length;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isFilled ? Colors.cyanAccent : Colors.transparent,
                    border: Border.all(
                      color: isFilled ? Colors.cyanAccent : Colors.white38,
                      width: 2,
                    ),
                    boxShadow: isFilled
                        ? [const BoxShadow(color: Colors.cyanAccent, blurRadius: 8, spreadRadius: 1)]
                        : null,
                  ),
                );
              }),
            ),
            const SizedBox(height: AppTheme.spacingLg),
            Text(
              _errorMsg,
              style: const TextStyle(color: Colors.redAccent, fontSize: 14),
            ),
            const Spacer(),
            // Custom Keypad
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              decoration: const BoxDecoration(
                color: Color(0xFF141418),
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildRow(['1', '2', '3']),
                  const SizedBox(height: 16),
                  _buildRow(['4', '5', '6']),
                  const SizedBox(height: 16),
                  _buildRow(['7', '8', '9']),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const SizedBox(width: 72),
                      _buildKey('0'),
                      _buildActionKey(
                        Icons.backspace_outlined,
                        _onDeletePress,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(List<String> digits) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: digits.map((d) => _buildKey(d)).toList(),
    );
  }

  Widget _buildKey(String digit) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onDigitPress(digit),
        splashColor: Colors.cyanAccent.withOpacity(0.3),
        highlightColor: Colors.cyanAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(36),
        child: Container(
          width: 72,
          height: 72,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white12, width: 1),
            color: Colors.white.withOpacity(0.03),
          ),
          child: Text(
            digit,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionKey(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.redAccent.withOpacity(0.3),
        borderRadius: BorderRadius.circular(36),
        child: Container(
          width: 72,
          height: 72,
          alignment: Alignment.center,
          child: Icon(icon, color: Colors.white60, size: 28),
        ),
      ),
    );
  }
}

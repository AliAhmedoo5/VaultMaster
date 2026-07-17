import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme.dart';
import '../../../core/constants.dart';
import 'auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isSignUp = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (_isSignUp) {
      ref.read(authControllerProvider.notifier).signUpWithEmailAndPassword(email, password);
    } else {
      ref.read(authControllerProvider.notifier).loginWithEmailAndPassword(email, password);
    }
  }

  void _submitGoogle() {
    ref.read(authControllerProvider.notifier).loginWithGoogle();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    // Reactively listen to auth state changes to present clean error dialogs
    ref.listen<AsyncValue<void>>(
      authControllerProvider,
      (previous, next) {
        next.whenOrNull(
          error: (err, stack) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  err.toString().replaceAll('Exception: ', ''),
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: AppTheme.error,
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.all(AppConstants.marginMobile),
              ),
            );
          },
        );
      },
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primary),
          onPressed: isLoading ? null : () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.marginMobile),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppConstants.md),
                    
                    // Welcome & Mode Header
                    Text(
                      _isSignUp ? 'Create Account' : 'Welcome Back',
                      style: textTheme.displayLarge?.copyWith(
                        fontSize: 28,
                        color: AppTheme.primary,
                      ),
                    ),
                    const SizedBox(height: AppConstants.xs),
                    Text(
                      _isSignUp 
                          ? 'Sign up to safely vault and synchronize your documents.' 
                          : 'Sign in to access your secure pocket cabinet.',
                      style: textTheme.bodyMedium?.copyWith(color: AppTheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: AppConstants.xl),

                    // EMAIL FIELD
                    Text(
                      'EMAIL ADDRESS',
                      style: textTheme.labelSmall?.copyWith(
                        color: AppTheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppConstants.sm),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      enabled: !isLoading,
                      decoration: const InputDecoration(
                        hintText: 'name@company.com',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your email';
                        }
                        final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                        if (!emailRegex.hasMatch(value.trim())) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppConstants.lg),

                    // PASSWORD FIELD
                    Text(
                      'PASSWORD',
                      style: textTheme.labelSmall?.copyWith(
                        color: AppTheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppConstants.sm),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: _isSignUp ? TextInputAction.next : TextInputAction.done,
                      enabled: !isLoading,
                      onFieldSubmitted: (_) => _isSignUp ? null : _submit(),
                      decoration: InputDecoration(
                        hintText: '••••••••',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: AppTheme.outline,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() => _obscurePassword = !_obscurePassword);
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppConstants.lg),

                    // CONFIRM PASSWORD FIELD (Signup Only)
                    if (_isSignUp) ...[
                      Text(
                        'CONFIRM PASSWORD',
                        style: textTheme.labelSmall?.copyWith(
                          color: AppTheme.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppConstants.sm),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        textInputAction: TextInputAction.done,
                        enabled: !isLoading,
                        onFieldSubmitted: (_) => _submit(),
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: AppTheme.outline,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppConstants.lg),
                    ],

                    const SizedBox(height: AppConstants.md),

                    // Submit Action Button
                    ElevatedButton(
                      onPressed: isLoading ? null : _submit,
                      child: Text(_isSignUp ? 'CREATE VAULT PROFILE' : 'SIGN IN'),
                    ),

                    const SizedBox(height: AppConstants.lg),

                    // Divider Row "OR SIGN IN WITH"
                    Row(
                      children: [
                        const Expanded(child: Divider(color: AppTheme.outlineVariant)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppConstants.md),
                          child: Text(
                            'OR CONTINUE WITH',
                            style: textTheme.labelSmall?.copyWith(color: AppTheme.outline),
                          ),
                        ),
                        const Expanded(child: Divider(color: AppTheme.outlineVariant)),
                      ],
                    ),

                    const SizedBox(height: AppConstants.lg),

                    // Modern Custom Google Sign-In Button
                    OutlinedButton(
                      onPressed: isLoading ? null : _submitGoogle,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.outlineVariant),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Vector Google symbol
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: CustomPaint(
                              painter: _GoogleLogoPainter(),
                            ),
                          ),
                          const SizedBox(width: AppConstants.md),
                          const Text('CONTINUE WITH GOOGLE'),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppConstants.xl),

                    // Toggle Auth Mode text
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _isSignUp ? 'Already have an account? ' : "Don't have an account? ",
                          style: textTheme.bodyMedium,
                        ),
                        GestureDetector(
                          onTap: isLoading
                              ? null
                              : () {
                                  setState(() {
                                    _isSignUp = !_isSignUp;
                                    _formKey.currentState?.reset();
                                    _emailController.clear();
                                    _passwordController.clear();
                                    _confirmPasswordController.clear();
                                  });
                                },
                          child: Text(
                            _isSignUp ? 'Sign In' : 'Sign Up',
                            style: textTheme.bodyMedium?.copyWith(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.lg),
                  ],
                ),
              ),
            ),
          ),

          // Tonal Loading Overlay (Premium Glassmorphism-style design)
          if (isLoading)
            Positioned.fill(
              child: Container(
                color: AppTheme.onSurface.withAlpha((255 * 0.08).toInt()),
                child: const Center(
                  child: Card(
                    elevation: 4.0,
                    shadowColor: Color(0x111A237E),
                    color: Colors.white,
                    child: Padding(
                      padding: EdgeInsets.all(AppConstants.lg),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(
                            color: AppTheme.primary,
                            strokeWidth: 3,
                          ),
                          SizedBox(height: AppConstants.md),
                          Text(
                            'Securing vault channel...',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Custom painter to render Google colored letter G without importing assets
class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // Draw Google segments using paths
    final double radius = size.width / 2;
    final center = Offset(radius, radius);

    // Blue segment
    paint.color = const Color(0xFF4285F4);
    final bluePath = Path()
      ..moveTo(center.dx, center.dy)
      ..relativeMoveTo(0, -radius)
      ..arcTo(rect, -math.pi / 2, math.pi / 2, false)
      ..lineTo(center.dx + radius, center.dy + 2)
      ..lineTo(center.dx + 4, center.dy + 2)
      ..lineTo(center.dx + 4, center.dy - 3)
      ..lineTo(center.dx + radius - 4, center.dy - 3)
      ..close();
    canvas.drawPath(bluePath, paint);

    // Red segment
    paint.color = const Color(0xFFEA4335);
    final redPath = Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(rect, -math.pi, math.pi / 2, false)
      ..lineTo(center.dx, center.dy - radius)
      ..close();
    canvas.drawPath(redPath, paint);

    // Yellow segment
    paint.color = const Color(0xFFFBBC05);
    final yellowPath = Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(rect, -3 * math.pi / 2, math.pi / 2, false)
      ..lineTo(center.dx - radius, center.dy)
      ..close();
    canvas.drawPath(yellowPath, paint);

    // Green segment
    paint.color = const Color(0xFF34A853);
    final greenPath = Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(rect, 0, math.pi / 2, false)
      ..lineTo(center.dx, center.dy + radius)
      ..close();
    canvas.drawPath(greenPath, paint);
    
    // Draw inside cutout to make it a letter 'G'
    paint.color = Colors.white;
    canvas.drawCircle(center, radius - 4.5, paint);
    
    // Fill letter crossbar
    paint.color = const Color(0xFF4285F4);
    canvas.drawRect(
      Rect.fromLTRB(center.dx, center.dy - 2.5, center.dx + radius, center.dy + 2.5),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

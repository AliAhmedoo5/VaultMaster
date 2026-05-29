import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../auth/data/auth_repository.dart';
import '../../../core/theme.dart';
import '../../../core/constants.dart';

class HomePlaceholder extends ConsumerWidget {
  const HomePlaceholder({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final user = ref.watch(authStateProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'VaultMaster',
          style: textTheme.titleLarge?.copyWith(
            color: AppTheme.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined, color: AppTheme.secondary),
            onPressed: () {
              ref.read(authControllerProvider.notifier).logout();
            },
          ),
        ],
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.marginMobile),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppConstants.lg),
              
              // Tonal greeting card
              Container(
                padding: const EdgeInsets.all(AppConstants.lg),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  border: Border.all(color: AppTheme.dividerColor, width: 1.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: AppTheme.primary.withAlpha((255 * 0.08).toInt()),
                          child: const Icon(Icons.person_outline, color: AppTheme.primary, size: 22),
                        ),
                        const SizedBox(width: AppConstants.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Secure Cabinet Active',
                                style: textTheme.labelSmall?.copyWith(color: AppTheme.primary, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                user?.email ?? 'anonymous@vault.com',
                                style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppConstants.xl),

              // Visual overview/state placeholder
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppConstants.xl),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withAlpha((255 * 0.02).toInt()),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.folder_shared_outlined,
                          size: 72,
                          color: AppTheme.outline,
                        ),
                      ),
                      const SizedBox(height: AppConstants.lg),
                      Text(
                        'Your Vault is Empty',
                        style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: AppConstants.sm),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppConstants.xl),
                        child: Text(
                          'Phase 1 successfully deployed! In Phase 2, we will integrate ML Kit to scan and import documents directly into this offline storage.',
                          textAlign: TextAlign.center,
                          style: textTheme.bodyMedium?.copyWith(height: 1.45),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              ElevatedButton.icon(
                onPressed: () {
                  ref.read(authControllerProvider.notifier).logout();
                },
                icon: const Icon(Icons.lock_open, size: 16),
                label: const Text('SECURE LOCKOUT (SIGN OUT)'),
              ),
              const SizedBox(height: AppConstants.lg),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import '../../document/domain/document_model.dart';
import '../../document/presentation/document_controller.dart';
import '../../document/data/document_repository.dart';
import '../data/vault_security_service.dart';
import 'vault_controller.dart';
import 'package:open_filex/open_filex.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class VaultScreen extends ConsumerStatefulWidget {
  const VaultScreen({super.key});

  @override
  ConsumerState<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends ConsumerState<VaultScreen> {
  late final AppLifecycleListener _listener;

  @override
  void initState() {
    super.initState();
    // Aggressive Auto-Lock when app goes to background
    _listener = AppLifecycleListener(
      onInactive: _lockAndExit,
      onPause: _lockAndExit,
      onHide: _lockAndExit,
      onDetach: _lockAndExit,
    );
  }

  void _lockAndExit() {
    ref.read(vaultSecurityServiceProvider).lockVault();
    if (mounted) {
      context.go('/home');
    }
  }

  @override
  void dispose() {
    _listener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Security Check
    final isUnlocked = ref.watch(vaultSecurityServiceProvider).isUnlocked;
    if (!isUnlocked) {
      // Just in case someone navigates here directly, pop them out
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go('/home');
      });
      return const Scaffold(backgroundColor: Colors.black);
    }

    final vaultListState = ref.watch(vaultControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF1A0A0A), // Reddish dark hue
      appBar: AppBar(
        title: const Text('Security Vault', style: TextStyle(color: Colors.redAccent)),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            ref.read(vaultSecurityServiceProvider).lockVault();
            context.go('/home');
          },
        ),
      ),
      body: vaultListState.when(
        data: (documents) {
          if (documents.isEmpty) {
            return const Center(
              child: Text(
                'Vault is empty.\nAdd documents from the dashboard.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            itemCount: documents.length,
            itemBuilder: (context, index) {
              final doc = documents[index];
              return _VaultDocumentCard(document: doc);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: Colors.redAccent)),
        error: (err, stack) => Center(
          child: Text('Error loading vault:\n$err', style: const TextStyle(color: Colors.redAccent)),
        ),
      ),
    );
  }
}

class _VaultDocumentCard extends ConsumerWidget {
  final DocumentModel document;

  const _VaultDocumentCard({required this.document});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingSm),
      decoration: BoxDecoration(
        color: const Color(0xFF261212), // Darker red surface
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: Colors.redAccent.withOpacity(0.3), width: 1),
      ),
      child: ListTile(
        onTap: () async {
          if (['pdf', 'png', 'jpg', 'jpeg'].contains(document.fileType)) {
            context.push('/document/${document.id}', extra: document);
          } else if (kIsWeb) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(document.cloudUrl != null 
                  ? 'Cloud URL: ${document.cloudUrl}' 
                  : 'Encrypted Vault file available in web memory.'),
                backgroundColor: Colors.amber,
              ),
            );
          } else {
            final result = await OpenFilex.open(document.localPath);
            if (result.type == ResultType.noAppToOpen) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('No compatible app installed to open this file type.'),
                    backgroundColor: Colors.redAccent,
                  ),
                 );
              }
            }
          }
        },
        contentPadding: const EdgeInsets.all(AppTheme.spacingMd),
        leading: const Icon(Icons.security, color: Colors.amber),
        title: Text(
          document.name,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${document.categoryId.toUpperCase()} • ${_formatDate(document.createdAt)}',
          style: const TextStyle(color: Colors.white60),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (document.cloudUrl != null)
              const Icon(Icons.cloud_done, color: Colors.green, size: 20)
            else
              const Icon(Icons.cloud_off, color: Colors.grey, size: 20),
            IconButton(
              icon: const Icon(Icons.lock_open, color: Colors.white54),
              tooltip: 'Remove from vault',
              onPressed: () {
                final updated = document.copyWith(isVaulted: false);
                ref.read(documentRepositoryProvider).updateDocument(updated);
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
              onPressed: () {
                ref.read(documentControllerProvider.notifier).deleteDocument(document);
              },
            )
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

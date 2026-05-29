import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/theme.dart';
import '../domain/document_model.dart';
import '../data/document_repository.dart';
import 'document_controller.dart';

class DocumentViewerScreen extends ConsumerStatefulWidget {
  final DocumentModel document;

  const DocumentViewerScreen({super.key, required this.document});

  @override
  ConsumerState<DocumentViewerScreen> createState() => _DocumentViewerScreenState();
}

class _DocumentViewerScreenState extends ConsumerState<DocumentViewerScreen> {
  late DocumentModel _document;

  @override
  void initState() {
    super.initState();
    _document = widget.document;
  }

  void _shareDocument() {
    final file = XFile(_document.localPath);
    Share.shareXFiles([file], text: 'Check out this document: ${_document.name}');
  }

  void _renameDocument() {
    final controller = TextEditingController(text: _document.name);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.surface,
          title: const Text('Rename Document'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newName = controller.text.trim();
                if (newName.isNotEmpty) {
                  Navigator.pop(context);
                  await ref.read(documentControllerProvider.notifier).renameDocument(_document, newName);
                  setState(() {
                    _document = _document.copyWith(name: newName);
                  });
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _deleteDocument() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.surface,
          title: const Text('Delete Document'),
          content: const Text('Are you sure you want to permanently delete this document?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                ref.read(documentControllerProvider.notifier).deleteDocument(_document);
                Navigator.pop(context); // close dialog
                context.pop(); // exit viewer
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _moveToVault() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.surface,
          title: const Text('Add to Vault'),
          content: const Text('Move this document to the Security Vault? It will require a PIN to access.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black),
              onPressed: () async {
                final updated = _document.copyWith(isVaulted: true);
                // We use documentRepository to directly update the document
                await ref.read(documentRepositoryProvider).updateDocument(updated);
                
                if (mounted) {
                  Navigator.pop(context); // Close dialog
                  context.pop(); // Exit viewer (because the document is now hidden from the dashboard)
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Document moved to Security Vault.')),
                  );
                }
              },
              child: const Text('Move to Vault'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPdf = _document.fileType == 'pdf';
    final file = File(_document.localPath);
    final fileExists = file.existsSync();

    return Scaffold(
      backgroundColor: Colors.black, // Immersive dark background
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(_document.name, style: const TextStyle(fontSize: 16)),
        actions: [
          IconButton(
            icon: const Icon(Icons.lock_outline, color: Colors.amber),
            tooltip: 'Move to Vault',
            onPressed: _moveToVault,
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareDocument,
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _renameDocument,
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.redAccent),
            onPressed: _deleteDocument,
          ),
        ],
      ),
      body: !fileExists
          ? const Center(
              child: Text(
                'File not found on device.',
                style: TextStyle(color: Colors.white54),
              ),
            )
          : isPdf
              ? SfPdfViewer.file(
                  file,
                  canShowScrollHead: false,
                  canShowScrollStatus: false,
                  onDocumentLoadFailed: (details) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to load document: ${details.description}')),
                    );
                  },
                )
              : Center(
                  child: InteractiveViewer(
                    child: Image.file(
                      file,
                      errorBuilder: (context, error, stackTrace) {
                        return const Text(
                          'Failed to load image.',
                          style: TextStyle(color: Colors.white54),
                        );
                      },
                    ),
                  ),
                ),
    );
  }
}

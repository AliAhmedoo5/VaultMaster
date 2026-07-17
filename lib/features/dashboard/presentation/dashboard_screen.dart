import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../document/presentation/document_controller.dart';
import '../../document/domain/document_model.dart';
import '../../document/data/document_repository.dart';
import '../../document/data/cloudinary_sync_service.dart';
import '../data/category_service.dart';
import 'package:open_filex/open_filex.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final documentListState = ref.watch(documentControllerProvider);
    final customCategories = ref.watch(categoryServiceProvider);
    final allCategories = ['All', ...customCategories];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nexus Archive'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.lock_outline, color: Colors.amber),
            tooltip: 'Security Vault',
            onPressed: () {
              context.push('/vault_pin');
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authControllerProvider.notifier).logout();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const _StorageUsageCard(),
          const _SearchAndSortBar(),
          const SizedBox(height: AppTheme.spacingSm),
          // Category Filter Bar
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd, vertical: AppTheme.spacingSm),
              itemCount: allCategories.length + 1,
              itemBuilder: (context, index) {
                if (index == allCategories.length) {
                  return Padding(
                    padding: const EdgeInsets.only(right: AppTheme.spacingSm),
                    child: ActionChip(
                      label: const Text('+ Add'),
                      labelPadding: const EdgeInsets.symmetric(horizontal: 8.0),
                      onPressed: () => _showAddCategoryDialog(context, ref),
                      backgroundColor: AppTheme.surface,
                      labelStyle: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold),
                      side: const BorderSide(color: AppTheme.primary, width: 1),
                    ),
                  );
                }
                final category = allCategories[index];
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: AppTheme.spacingSm),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    backgroundColor: AppTheme.surface,
                    selectedColor: AppTheme.primary.withOpacity(0.2),
                    checkmarkColor: AppTheme.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? AppTheme.primary : AppTheme.onSurfaceVariant,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: documentListState.when(
              data: (_) {
                // Get the filtered and sorted docs from the new provider
                var filteredDocs = ref.watch(filteredDocumentsProvider);

                // Filter by category
                if (_selectedCategory != 'All') {
                  filteredDocs = filteredDocs.where((doc) => doc.categoryId.toLowerCase() == _selectedCategory.toLowerCase()).toList();
                }

                if (filteredDocs.isEmpty) {
                  return const Center(
                    child: Text(
                      'No documents found.\nTap + to ingest.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.onSurfaceVariant),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(AppTheme.spacingMd),
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    final doc = filteredDocs[index];
                    return _DocumentCard(document: doc);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primary)),
              error: (err, stack) => Center(
                child: Text('Error loading documents:\n$err', style: const TextStyle(color: AppTheme.error)),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showIngestionMenu(context, ref),
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showIngestionMenu(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusLg)),
      ),
      backgroundColor: AppTheme.surface,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.document_scanner, color: AppTheme.primary),
                title: const Text('Scan Document'),
                onTap: () {
                  Navigator.pop(context);
                  _showCategoryVaultDialog(context, ref, isScan: true);
                },
              ),
              ListTile(
                leading: const Icon(Icons.upload_file, color: AppTheme.secondary),
                title: const Text('Import File'),
                onTap: () {
                  Navigator.pop(context);
                  _showCategoryVaultDialog(context, ref, isScan: false);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddCategoryDialog(BuildContext context, WidgetRef ref) {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('New Category'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(
            labelText: 'Category Name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              ref.read(categoryServiceProvider.notifier).addCategory(textController.text);
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showCategoryVaultDialog(BuildContext context, WidgetRef ref, {required bool isScan}) {
    final customCategories = ref.read(categoryServiceProvider);
    String selectedCat = customCategories.isNotEmpty ? customCategories.first : 'Other';
    bool isVaulted = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppTheme.surface,
              title: const Text('Document Details'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedCat,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    items: customCategories
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => selectedCat = val);
                    },
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                  SwitchListTile(
                    title: const Text('Add to Security Vault'),
                    subtitle: const Text('Requires PIN to view', style: TextStyle(fontSize: 12)),
                    activeColor: Colors.amber,
                    value: isVaulted,
                    onChanged: (val) {
                      setState(() => isVaulted = val);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    if (isScan) {
                      ref.read(documentControllerProvider.notifier).scanDocument(
                        categoryId: selectedCat, 
                        isVaulted: isVaulted,
                      ).catchError((e) {
                        if (context.mounted) {
                           ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                             content: Text(e.toString()),
                             backgroundColor: AppTheme.error,
                           ));
                        }
                      });
                    } else {
                      ref.read(documentControllerProvider.notifier).importFiles(
                        categoryId: selectedCat, 
                        isVaulted: isVaulted,
                      ).catchError((e) {
                        if (context.mounted) {
                           ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                             content: Text(e.toString()),
                             backgroundColor: AppTheme.error,
                           ));
                        }
                      });
                    }
                  },
                  child: const Text('Continue'),
                ),
              ],
            );
          }
        );
      },
    );
  }
}

class _DocumentCard extends ConsumerWidget {
  final DocumentModel document;

  const _DocumentCard({required this.document});

  Color _getSemanticColor(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return Colors.red.shade700;
      case 'doc':
      case 'docx':
      case 'txt':
        return Colors.blue.shade700;
      case 'xls':
      case 'xlsx':
      case 'csv':
        return Colors.green.shade700;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Colors.orange.shade700;
      default:
        return AppTheme.secondary;
    }
  }

  IconData _getFileIcon(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final semanticColor = _getSemanticColor(document.fileType);
    final activeSyncs = ref.watch(cloudinarySyncServiceProvider);
    final isSyncing = activeSyncs.contains(document.id);
    
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingSm),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.dividerColor, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x081A237E),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          onTap: () async {
            if (['pdf', 'png', 'jpg', 'jpeg'].contains(document.fileType)) {
              context.push('/document/${document.id}', extra: document);
            } else if (kIsWeb) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(document.cloudUrl != null 
                    ? 'Cloud URL: ${document.cloudUrl}' 
                    : 'File is available in memory workspace.'),
                  backgroundColor: AppTheme.primary,
                ),
              );
            } else {
              final result = await OpenFilex.open(document.localPath);
              if (result.type == ResultType.noAppToOpen) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('No compatible app installed to open this file type.'),
                      backgroundColor: AppTheme.error,
                    ),
                  );
                }
              }
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            child: Row(
              children: [
                if (['jpg', 'jpeg', 'png'].contains(document.fileType))
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      border: Border.all(color: AppTheme.dividerColor, width: 1),
                      boxShadow: const [
                        BoxShadow(color: Color(0x10000000), blurRadius: 4, spreadRadius: 0) // Subtle shadow simulation
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      child: Image.file(
                        File(document.localPath),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(Icons.image, color: semanticColor),
                      ),
                    ),
                  )
                else
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: semanticColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    ),
                    child: Icon(
                      _getFileIcon(document.fileType),
                      color: semanticColor,
                    ),
                  ),
                const SizedBox(width: AppTheme.spacingMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        document.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_formatDate(document.createdAt)} • ${_formatBytes(document.fileSize)}',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppTheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (document.cloudUrl != null)
                  const Icon(Icons.cloud_done, color: Colors.cyanAccent, size: 20)
                else if (isSyncing)
                  const SizedBox(
                    width: 20, 
                    height: 20, 
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary)
                  )
                else
                  const Icon(Icons.cloud_off, color: Colors.grey, size: 20),
                const SizedBox(width: AppTheme.spacingSm),
                IconButton(
                  icon: const Icon(Icons.lock_outline, color: Colors.amber),
                  tooltip: 'Move to Vault',
                  onPressed: () async {
                    final updated = document.copyWith(isVaulted: true);
                    await ref.read(documentRepositoryProvider).updateDocument(updated);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Moved to Security Vault')),
                      );
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppTheme.outline),
                  onPressed: () {
                    ref.read(documentControllerProvider.notifier).deleteDocument(document);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) return "0 B";
    if (bytes < 1024) return "$bytes B";
    if (bytes < 1024 * 1024) return "${(bytes / 1024).toStringAsFixed(1)} KB";
    return "${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB";
  }
}

class _StorageUsageCard extends ConsumerWidget {
  const _StorageUsageCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storageStream = ref.watch(totalStorageUsedProvider);
    final docListState = ref.watch(documentControllerProvider);
    
    // Calculate breakdown
    final docs = docListState.valueOrNull ?? [];
    final docCount = docs.length;
    int imageCount = 0;
    int pdfCount = 0;
    int otherCount = 0;
    for (var doc in docs) {
      if (['jpg', 'jpeg', 'png'].contains(doc.fileType)) {
        imageCount++;
      } else if (doc.fileType == 'pdf') {
        pdfCount++;
      } else {
        otherCount++;
      }
    }

    return storageStream.when(
      data: (usedBytes) {
        final limitBytes = 1024 * 1024 * 1024; // 1 GB
        final percent = (usedBytes / limitBytes).clamp(0.0, 1.0);
        
        return Container(
          margin: const EdgeInsets.only(
            left: AppTheme.spacingMd, 
            right: AppTheme.spacingMd, 
            top: AppTheme.spacingMd,
            bottom: AppTheme.spacingSm
          ),
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            border: Border.all(color: AppTheme.dividerColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Storage Usage', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.onSurface)),
                        Text(
                          '$docCount Document${docCount == 1 ? '' : 's'}', 
                          style: const TextStyle(color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.bold)
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('${_formatBytes(usedBytes)} / 1.0 GB', style: const TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 12)),
                        Text(
                          'Images: $imageCount • PDFs: $pdfCount • Other: $otherCount', 
                          style: const TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 10),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(height: AppTheme.spacingMd),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: percent,
                  minHeight: 6,
                  backgroundColor: AppTheme.background,
                  valueColor: AlwaysStoppedAnimation<Color>(percent > 0.9 ? Colors.redAccent : Colors.cyanAccent),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) return "0 B";
    if (bytes < 1024) return "$bytes B";
    if (bytes < 1024 * 1024) return "${(bytes / 1024).toStringAsFixed(1)} KB";
    return "${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB";
  }
}

class _SearchAndSortBar extends ConsumerWidget {
  const _SearchAndSortBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sortOption = ref.watch(sortOptionNotifierProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (val) => ref.read(searchQueryProvider.notifier).updateQuery(val),
              style: const TextStyle(color: AppTheme.onSurface),
              decoration: InputDecoration(
                hintText: 'Search documents...',
                hintStyle: const TextStyle(color: AppTheme.onSurfaceVariant),
                prefixIcon: const Icon(Icons.search, color: AppTheme.onSurfaceVariant),
                filled: true,
                fillColor: AppTheme.surface,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppTheme.spacingSm),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingSm),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<SortOption>(
                value: sortOption,
                icon: const Icon(Icons.sort, color: AppTheme.onSurfaceVariant),
                dropdownColor: AppTheme.surface,
                onChanged: (val) {
                  if (val != null) {
                    ref.read(sortOptionNotifierProvider.notifier).updateSort(val);
                  }
                },
                items: const [
                  DropdownMenuItem(value: SortOption.date, child: Text('Date', style: TextStyle(color: AppTheme.onSurface))),
                  DropdownMenuItem(value: SortOption.name, child: Text('Name', style: TextStyle(color: AppTheme.onSurface))),
                  DropdownMenuItem(value: SortOption.size, child: Text('Size', style: TextStyle(color: AppTheme.onSurface))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

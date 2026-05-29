import 'dart:io';
import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:file_picker/file_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/document_model.dart';
import '../data/document_repository.dart';
import '../data/cloudinary_sync_service.dart';

part 'document_controller.g.dart';

enum SortOption { date, name, size }

@riverpod
class SearchQuery extends _$SearchQuery {
  @override
  String build() => '';

  void updateQuery(String query) => state = query;
}

@riverpod
class SortOptionNotifier extends _$SortOptionNotifier {
  @override
  SortOption build() => SortOption.date;

  void updateSort(SortOption option) => state = option;
}

@riverpod
List<DocumentModel> filteredDocuments(FilteredDocumentsRef ref) {
  final docsAsyncValue = ref.watch(documentControllerProvider);
  final searchQuery = ref.watch(searchQueryProvider).toLowerCase();
  final sortOption = ref.watch(sortOptionNotifierProvider);

  if (!docsAsyncValue.hasValue) return [];
  
  var docs = docsAsyncValue.value!.toList();
  
  if (searchQuery.isNotEmpty) {
    docs = docs.where((doc) => doc.name.toLowerCase().contains(searchQuery)).toList();
  }
  
  switch (sortOption) {
    case SortOption.date:
      docs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      break;
    case SortOption.name:
      docs.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      break;
    case SortOption.size:
      docs.sort((a, b) => b.fileSize.compareTo(a.fileSize));
      break;
  }
  
  return docs;
}

@riverpod
Stream<int> totalStorageUsed(TotalStorageUsedRef ref) {
  return ref.watch(documentRepositoryProvider).watchDocuments().map((docs) {
    int total = 0;
    for (var doc in docs) {
      total += doc.fileSize;
    }
    return total;
  });
}

@riverpod
class DocumentController extends _$DocumentController {
  @override
  Stream<List<DocumentModel>> build() {
    return ref.watch(documentRepositoryProvider).watchDocuments().map(
      (docs) => docs.where((doc) => !doc.isVaulted).toList(),
    );
  }

  Future<void> scanDocument({required String categoryId, required bool isVaulted}) async {
    try {
      final List<String>? pictures = await CunningDocumentScanner.getPictures();
      if (pictures != null && pictures.isNotEmpty) {
        final repo = ref.read(documentRepositoryProvider);
        
        // Cunning Document Scanner returns cropped images (usually JPEGs)
        // We will ingest each one.
        for (var i = 0; i < pictures.length; i++) {
          final file = File(pictures[i]);
          final document = await repo.ingestFile(
            file: file,
            name: 'Scanned Document ${i + 1}',
            categoryId: categoryId,
            isVaulted: isVaulted,
          );
          // Trigger asynchronous upload via the smart queue manager
          ref.read(cloudinarySyncServiceProvider.notifier).triggerSync();
        }
      }
    } catch (e) {
      // Handle scanner errors
      print('Error scanning document: $e');
      rethrow;
    }
  }

  Future<void> importFiles({required String categoryId, required bool isVaulted}) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'txt', 'jpg', 'png', 'jpeg'],
      );

      if (result != null) {
        final repo = ref.read(documentRepositoryProvider);
        for (var file in result.files) {
          if (file.path != null) {
            final document = await repo.ingestFile(
              file: File(file.path!),
              name: file.name,
              categoryId: categoryId,
              isVaulted: isVaulted,
            );
            // Trigger asynchronous upload via the smart queue manager
            ref.read(cloudinarySyncServiceProvider.notifier).triggerSync();
          }
        }
      }
    } catch (e) {
      print('Error importing file: $e');
      rethrow;
    }
  }
  
  Future<void> deleteDocument(DocumentModel doc) async {
    try {
      await ref.read(documentRepositoryProvider).deleteDocument(doc);
    } catch (e) {
      print('Error deleting document: $e');
      rethrow;
    }
  }

  Future<void> renameDocument(DocumentModel doc, String newName) async {
    try {
      final updated = doc.copyWith(name: newName);
      await ref.read(documentRepositoryProvider).updateDocument(updated);
    } catch (e) {
      print('Error renaming document: $e');
      rethrow;
    }
  }
}

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../document/domain/document_model.dart';
import '../../document/data/document_repository.dart';

part 'vault_controller.g.dart';

@riverpod
class VaultController extends _$VaultController {
  @override
  Stream<List<DocumentModel>> build() {
    return ref.watch(documentRepositoryProvider).watchDocuments().map(
      (docs) => docs.where((doc) => doc.isVaulted).toList(),
    );
  }
}

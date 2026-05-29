// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$filteredDocumentsHash() => r'c92ae414cccb84a4bd22a5cb72083ccd50b1acf4';

/// See also [filteredDocuments].
@ProviderFor(filteredDocuments)
final filteredDocumentsProvider =
    AutoDisposeProvider<List<DocumentModel>>.internal(
      filteredDocuments,
      name: r'filteredDocumentsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$filteredDocumentsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FilteredDocumentsRef = AutoDisposeProviderRef<List<DocumentModel>>;
String _$totalStorageUsedHash() => r'335a77ebf7ed7e37f93c0b3be7b665119a9f5a1d';

/// See also [totalStorageUsed].
@ProviderFor(totalStorageUsed)
final totalStorageUsedProvider = AutoDisposeStreamProvider<int>.internal(
  totalStorageUsed,
  name: r'totalStorageUsedProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$totalStorageUsedHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TotalStorageUsedRef = AutoDisposeStreamProviderRef<int>;
String _$searchQueryHash() => r'c20c8b67cdf9a8c8820d422de83c580e88655dcd';

/// See also [SearchQuery].
@ProviderFor(SearchQuery)
final searchQueryProvider =
    AutoDisposeNotifierProvider<SearchQuery, String>.internal(
      SearchQuery.new,
      name: r'searchQueryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$searchQueryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SearchQuery = AutoDisposeNotifier<String>;
String _$sortOptionNotifierHash() =>
    r'807b39fe1e02e88ddda913babdad3010d4947dae';

/// See also [SortOptionNotifier].
@ProviderFor(SortOptionNotifier)
final sortOptionNotifierProvider =
    AutoDisposeNotifierProvider<SortOptionNotifier, SortOption>.internal(
      SortOptionNotifier.new,
      name: r'sortOptionNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$sortOptionNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SortOptionNotifier = AutoDisposeNotifier<SortOption>;
String _$documentControllerHash() =>
    r'623e77e4c192492879d13c42766148cbcc59a832';

/// See also [DocumentController].
@ProviderFor(DocumentController)
final documentControllerProvider =
    AutoDisposeStreamNotifierProvider<
      DocumentController,
      List<DocumentModel>
    >.internal(
      DocumentController.new,
      name: r'documentControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$documentControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$DocumentController = AutoDisposeStreamNotifier<List<DocumentModel>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

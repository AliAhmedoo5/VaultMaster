import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'document_repository.dart';

part 'cloudinary_sync_service.g.dart';

@Riverpod(keepAlive: true)
class CloudinarySyncService extends _$CloudinarySyncService with WidgetsBindingObserver {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _isSyncing = false;
  bool _isAppInForeground = true;

  @override
  Set<String> build() {
    WidgetsBinding.instance.addObserver(this);
    
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      if (results.contains(ConnectivityResult.none)) return;
      triggerSync();
    });
    
    ref.onDispose(() {
      _subscription?.cancel();
      WidgetsBinding.instance.removeObserver(this);
    });

    // Initial trigger
    Future.microtask(() => triggerSync());
    
    return {}; // Active sync IDs
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _isAppInForeground = true;
      triggerSync(); // Resume on foreground
    } else {
      _isAppInForeground = false; // Graceful pause handled by loop check
    }
  }

  Future<void> triggerSync() async {
    if (_isSyncing || !_isAppInForeground) return;
    _isSyncing = true;
    
    try {
      final repo = ref.read(documentRepositoryProvider);
      if (repo.currentUser == null) return;
      var unsyncedDocs = await repo.getUnsyncedDocuments();

      while (unsyncedDocs.isNotEmpty && _isAppInForeground) {
        // Grab chunk of up to 3
        final chunk = unsyncedDocs.take(3).toList();
        
        // Update UI state
        state = <String>{...state, ...chunk.map((d) => d.id)};

        await Future.wait(
          chunk.map((doc) async {
            try {
              await repo.syncToCloudinary(doc);
            } catch (e) {
              print('Failed to sync ${doc.id}: $e');
              // Fails gracefully; file remains in DB without cloudUrl
            } finally {
              // Remove from UI state regardless of success/failure to stop spinner
              state = <String>{...state}..remove(doc.id);
            }
          }),
        );

        // Fetch next batch to see if there's more work
        if (!_isAppInForeground) break;
        unsyncedDocs = await repo.getUnsyncedDocuments();
      }
    } catch (e) {
      print('Sync engine error: $e');
    } finally {
      _isSyncing = false;
    }
  }
}

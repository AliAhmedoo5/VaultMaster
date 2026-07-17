# Sync Engine Documentation

## Core Concept
The `SyncEngine` (`lib/features/document/data/sync_engine.dart`) acts as an auto-upload background service that bridges the offline-first local filesystem with Firebase Cloud Storage.

## How it works
1. Provided globally via `syncEngineProvider`, but tightly coupled to the `authStateProvider`. 
2. If `user == null`, it returns `null` and does nothing, preventing `Exception: User is not authenticated` during app startup.
3. Upon authentication, it starts and hooks into `Connectivity().onConnectivityChanged`.
4. When network changes to mobile/wifi/ethernet, it fetches all `DocumentModel` items where `cloudUrl` is null.
5. It uploads the physical file from `localPath` to Firebase Storage.
6. Upon successful upload, it updates the Firestore document with the new `cloudUrl`.

## Bug History
- **Bug**: The app crashed with a red screen `Exception: User is not authenticated` on launch.
- **Fix**: The `SyncEngine` was originally reading the `DocumentRepository` synchronously on boot. It was refactored to watch `authStateProvider` and only instantiate when `user != null`.

## Build Environment Considerations
- **Build Runner**: Because we use `riverpod_generator`, modifying any provider requires running `dart run build_runner build -d`.
- **Gradle Caching**: Windows disk space constraints sometimes corrupt the Kotlin incremental cache. If `assembleDebug` hangs infinitely with `PersistentMapImpl` errors, terminate the process and run `flutter clean` before re-building.

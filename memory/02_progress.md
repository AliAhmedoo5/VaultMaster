# Development Progress

## Phase 1: Auth, Routing, and Base UI [COMPLETED]
- Integrated Firebase Auth with Google Sign-In.
- Set up GoRouter with automatic redirection based on `authStateProvider` (keeps unauthenticated users in `/welcome`).
- Built the `WelcomeScreen`, `LoginScreen`, and base `DashboardScreen`.

## Phase 2: Local Ingestion & Offline Database [COMPLETED]
- Integrated `cunning_document_scanner` for native PDF scanning.
- Used `path_provider` to securely save generated PDFs to the app's local document directory.
- Created `DocumentModel` and `DocumentRepository`.
- Leveraged `cloud_firestore` to save and cache document metadata completely offline without building manual JSON indexes.

## Phase 3: Cloud Storage Sync Engine [COMPLETED]
- Built a global `SyncEngine` (in `sync_engine.dart`) that watches `authStateProvider` and only initializes when a user is authenticated.
- The `SyncEngine` monitors `connectivity_plus` streams.
- It finds unsynced files (`cloudUrl == null`), uploads the physical file from `path_provider` to Firebase Storage, and updates the Firestore document with the download URL.
- Added explicit logic in `DocumentRepository.deleteDocument` to purge the physical file from Firebase Cloud Storage and local storage.

## Phase 4: Organization & Security Vault [COMPLETED]
- Replaced native `local_auth` with `flutter_secure_storage` to build a custom PIN keypad system.
- Created `VaultSecurityService` to manage the vault session state.
- Updated Dashboard to include horizontal Category filter chips.
- Added Ingestion Modal to prompt for category selection and `isVaulted` toggle.
- Built a custom Glassmorphic `VaultPinScreen` with dynamic Create/Confirm/Verify states.
- Implemented `AppLifecycleListener` to aggressively lock the vault (`_lockAndExit`) whenever the app enters a paused/inactive state.
- Updated Firestore rules to match the nested `users/{userId}/documents/{documentId}` structure.

## Phase 5: Export & Polish [COMPLETED]
- Built `DocumentViewerScreen` to handle deep integration with `syncfusion_flutter_pdfviewer` and native Image viewing.
- Connected `share_plus` to a custom Action Bar to allow native exporting.
- Added in-memory Search & Sort to `DashboardScreen` via Riverpod (no network overhead).
- Built a sleek `StorageUsageCard` with a linear neon progress indicator.
- App is 100% feature-complete per the `VaultMasterPlan.md` and the final APK has been compiled.

# Project Architecture & Stack

## Tech Stack
- **Framework**: Flutter (Cross-platform iOS/Android)
- **State Management**: Riverpod (`flutter_riverpod`, `riverpod_annotation`, `riverpod_generator`)
- **Routing**: GoRouter
- **Database / Backend**: Firebase (Firestore, Cloud Storage, Authentication)
- **Authentication**: Google Sign-In (`google_sign_in`) + Firebase Auth
- **Local Storage**: `path_provider` (for saving physical files to device)
- **Document Scanner**: `cunning_document_scanner` (Native Android/iOS multi-page PDF generation)

## Architecture Pattern
The app follows a strict **Repository-Controller-UI** pattern powered by Riverpod:
- **Repositories (`/data`)**: Direct wrappers around Firebase / Local filesystem. (e.g., `AuthRepository`, `DocumentRepository`). These handle the raw data operations.
- **Controllers (`/presentation`)**: Contains business logic linking the UI to the Repositories. Exposes state (`AsyncValue`) to the UI.
- **Domain Models (`/domain`)**: Data classes like `DocumentModel`, `UserModel` with `fromJson`/`toJson` mapping.

## Security Constraints
- **Do not write custom indexing JSON files** for the database. Use Firestore's built-in offline caching instead.
- Documents are explicitly tied to `FirebaseAuth.instance.currentUser?.uid`.

# Firebase Configuration Memory

## Google Sign-In Setup
- **Android Support**: The app uses `google_sign_in` combined with Firebase Auth OAuthCredential mapping.
- **SHA Fingerprints**: To prevent `PlatformException(sign_in_failed, 10)`, the development machine's `debug.keystore` SHA-1 and SHA-256 hashes must be registered in the Firebase Console.
- **OAuth Web Client ID**: Firebase automatically generates the Web Client ID when the "Google" provider is enabled in the Authentication > Sign-in method tab.
- **google-services.json**: Must contain the `oauth_client` array populated with a `client_type: 3` (Web) to successfully generate the `default_web_client_id` string resource used by Android to fetch the ID token.

## Firestore Offline Cache
- Firestore is used extensively for offline caching. We deliberately avoid maintaining local `.json` arrays to track documents, relying entirely on Firestore's native persistent cache.
- Querying for `cloudUrl == null` happens against the local cache when offline, preventing network hangs.

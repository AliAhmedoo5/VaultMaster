# Next Steps: Phase 5 (Export & Polish)

## Objective
The final major milestone for Nexus Archive (VaultMaster) is Phase 5. 

## Planned Features
1. **Native PDF Export & Sharing**: 
   - Integrate `share_plus` to allow users to export their scanned PDFs or imported documents out of the app.
   - Add a "Share" icon on the Document Cards and the eventual Document Detail view.
2. **UI/UX Polish**:
   - Refine empty states (e.g., when a user has no documents in a specific category).
   - Add hero animations between the Dashboard and the Document Detail views.
   - Ensure the Glassmorphic aesthetics are consistent across all menus and bottom sheets.
3. **Performance & Clean Up**:
   - Final pass on Riverpod caching to ensure optimal memory usage when scrolling through large lists of high-res scanned PDFs.
   - Run a final release build (`flutter build apk --release` and AAB for Play Store).

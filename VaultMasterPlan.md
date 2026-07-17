# **Master Blueprint: Smart Document Vault App**

## **1\. Product Requirements Document (PRD)**

**Product Vision:**

A secure, offline-first mobile application that acts as a "pocket filing cabinet." It allows users to smartly scan physical documents, import existing digital files, organize them into categories, protect sensitive files in a biometric vault, and easily share them using native device capabilities.

**Target Audience:**

Freelancers, small business owners, students, and general users who need a centralized, secure, and searchable place to store important documents (receipts, IDs, contracts, homework) without relying on scattered folders across their phone.

**Core Features (v1.0 MVP):**

* **Authentication:** Email/Password and Google Sign-in. Account syncing allows data recovery upon app reinstall.  
* **Smart Document Scanner:** Integrated Google ML Kit for auto-edge detection, perspective correction, and multi-page PDF generation.  
* **File Import:** Import existing PDFs, DOCX, XLSX, TXT, PNG, and JPG files from local storage.  
* **Storage Dashboard:** Visual overview of storage usage and file types.  
* **Categorization:** Custom user-defined folders/tags.  
* **Security Vault:** A specific folder locked behind device biometrics (FaceID/Fingerprint) or PIN.  
* **Native Exporting:** Integration with the OS share sheet to send files to WhatsApp, Email, Drive, etc.  
* **Offline-First:** Files are saved locally for instant access without internet; background syncing pushes them to the cloud when online.

**Out of Scope for v1.0:**

* Optical Character Recognition (OCR) for text searching.  
* Collaborative sharing/editing with other users.

## **2\. App Flow & UI Screens**

**1\. Onboarding & Auth Flow**

* Welcome Screen \-\> Hero image, value proposition.  
* Login/Signup Screen \-\> Email/Password fields, "Sign in with Google" button.

**2\. Main Dashboard (Home)**

* Header: Greeting & User Avatar.  
* Storage Widget: Progress bar showing items saved or estimated space.  
* Quick Access: Horizontal scrolling list of 3-5 "Recent Documents".  
* Categories Grid: Grid view of folders (e.g., "Tax", "IDs", "Medical").  
* Floating Action Button (FAB): Primary "+" button to add a new document.

**3\. Action Menu (Triggered by FAB)**

* Bottom Sheet pops up with two options:  
  1. "Scan with Camera" \-\> Opens Google ML Kit.  
  2. "Import File" \-\> Opens native file browser.

**4\. Category & List View**

* List of documents within a specific category.  
* Sort by: Date added, Name, File size.  
* Search bar to filter by document name.

**5\. Document Viewer**

* Full-screen view of the image or PDF.  
* Top App Bar actions: Delete, Edit (Rename), Share.  
* Tapping "Share" opens the native iOS/Android share sheet.

**6\. The Security Vault**

* When tapping the "Vault" category, an intercept screen appears requiring Biometric/PIN authentication before routing to the Vault's list view.

## **3\. Technical Requirements Document (TRD)**

**Stack Overview:**

* **Frontend & Mobile Framework:** Flutter (Dart).  
* **Backend, Auth, & Database:** Firebase (Cloud Firestore, Firebase Auth, Cloud Storage).  
* **State Management:** Riverpod.  
* **Routing:** GoRouter.

**Critical Packages (pubspec.yaml):**

* google\_mlkit\_document\_scanner: For the smart camera UI and PDF generation.  
* file\_picker: For importing local device files.  
* share\_plus: For native WhatsApp/Drive exporting.  
* local\_auth: For FaceID/TouchID in the Vault.  
* path\_provider: To save files to the device for offline viewing.  
* firebase\_core, firebase\_auth, cloud\_firestore, firebase\_storage.

## **4\. Backend & Database Plan**

We will use **Cloud Firestore** (NoSQL) for metadata and **Firebase Storage** for physical files.

### **Firestore Schema**

**Collection: users**

* uid (String, Document ID)  
* email (String)  
* createdAt (Timestamp)  
* storageUsed (Number, in bytes)

**Collection: categories**

* id (String, Document ID)  
* userId (String, Indexed for querying)  
* name (String, e.g., "Medical")  
* icon (String, optional icon identifier)  
* isVault (Boolean, true if this is the locked vault folder)  
* createdAt (Timestamp)

**Collection: documents**

* id (String, Document ID)  
* userId (String, Indexed)  
* categoryId (String, Foreign Key)  
* name (String, e.g., "Passport\_Scan")  
* fileType (String, e.g., "pdf", "jpg", "docx")  
* fileSize (Number, in bytes)  
* cloudUrl (String, URL from Firebase Storage, nullable if not synced yet)  
* localPath (String, URI to the offline file on the device)  
* createdAt (Timestamp)

### **Firebase Storage Structure**

Physical files should be organized by user ID to enforce strict security rules.

* gs://your-app-bucket.appspot.com/users/{userId}/documents/{documentId}.{extension}

## **5\. Implementation Plan (Execution Roadmap)**

**Phase 1: Setup & Identity**

1. Initialize Flutter project.  
2. Set up Firebase project (Auth, Firestore, Storage) and connect to Flutter.  
3. Build Login/Signup screens.  
4. Implement Riverpod state management for the user session.

**Phase 2: Local Ingestion (The Core Engine)**

1. Integrate google\_mlkit\_document\_scanner and test returning a PDF.  
2. Integrate file\_picker to select local files.  
3. Use path\_provider to copy these files into the app's local application directory.  
4. Build a basic list view to ensure files are saved and retrievable locally.

**Phase 3: Data & Cloud Sync (Offline-First)**

1. Build Firestore logic to save Document metadata (name, local path, size).  
2. Write the upload logic: Take the local file, push to Firebase Storage, get the URL, and update the Firestore document with cloudUrl.  
3. Verify that Firestore caches the metadata offline automatically.

**Phase 4: Organization & Vault**

1. Implement Categories (Create, Read, Delete).  
2. Update UI to show documents organized by Category.  
3. Build the Security Vault UI.  
4. Integrate local\_auth to block access to the Vault category without biometrics.

**Phase 5: Export & Polish**

1. Integrate share\_plus on the Document Viewer screen.  
2. Build the Storage Dashboard (Calculate metrics from Firestore data).  
3. Final UI polish, loading states, and error handling.
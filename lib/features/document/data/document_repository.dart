import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:crypto/crypto.dart';
import '../domain/document_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'document_repository.g.dart';

class DuplicateDocumentException implements Exception {
  final String message;
  DuplicateDocumentException(this.message);
  @override
  String toString() => message;
}

class DocumentRepository {
  final FirebaseFirestore _firestore;
  final String _userId;

  // Injected real credentials
  static const String _cloudinaryCloudName = 'dghqjhbxj';
  static const String _cloudinaryUploadPreset = 'vaultmaster_sync';

  DocumentRepository(this._firestore, this._userId);

  CollectionReference get _userDocumentsRef => 
      _firestore.collection('users').doc(_userId).collection('documents');

  Future<String> _getAppDocumentsDir() async {
    final directory = await getApplicationDocumentsDirectory();
    final documentsPath = p.join(directory.path, 'vault_documents');
    final dir = Directory(documentsPath);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return documentsPath;
  }

  Future<DocumentModel> ingestFile({
    required File file,
    required String name,
    required String categoryId,
    bool isVaulted = false,
  }) async {
    // 1. Generate Byte-Level Hash to check for duplicates
    final bytes = await file.readAsBytes();
    final fileHash = sha256.convert(bytes).toString();

    // Offline-safe check against Firestore cache
    try {
      final duplicateQuery = await _userDocumentsRef
          .where('fileHash', isEqualTo: fileHash)
          .get(const GetOptions(source: Source.cache));
          
      if (duplicateQuery.docs.isNotEmpty) {
        throw DuplicateDocumentException('Document already exists in your vault.');
      }
    } catch (e) {
      if (e is DuplicateDocumentException) rethrow;
      // If cache read fails (e.g., query never run before), we ignore and proceed,
      // or we could fallback to server check. For now, proceeding is safe.
    }

    // Generate unique local filename using Firestore document ID
    final docRef = _userDocumentsRef.doc();

    // 2. Copy file to secure local directory
    final appDocsDir = await _getAppDocumentsDir();
    final fileExtension = p.extension(file.path);
    final fileType = fileExtension.replaceAll('.', '').toLowerCase();
    
    // Generate unique local filename
    final localFilename = '${docRef.id}$fileExtension';
    final secureLocalPath = p.join(appDocsDir, localFilename);
    
    // Copy the physical file
    await file.copy(secureLocalPath);
    
    // Get file size
    final fileSize = await File(secureLocalPath).length();

    // 2. Save metadata to Firestore (Offline-first enabled by default)
    final document = DocumentModel(
      id: docRef.id,
      userId: _userId,
      name: name,
      localPath: secureLocalPath,
      createdAt: DateTime.now(),
      categoryId: categoryId,
      fileType: fileType.isEmpty ? 'pdf' : fileType,
      fileSize: fileSize,
      isVaulted: isVaulted,
      fileHash: fileHash,
    );

    await docRef.set(document.toFirestore());

    return document;
  }

  Stream<List<DocumentModel>> watchDocuments() {
    return _userDocumentsRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DocumentModel.fromFirestore(doc))
            .toList());
  }

  Future<List<DocumentModel>> getUnsyncedDocuments() async {
    final snapshot = await _userDocumentsRef.where('cloudUrl', isNull: true).get();
    return snapshot.docs.map((doc) => DocumentModel.fromFirestore(doc)).toList();
  }

  Future<void> deleteDocument(DocumentModel document) async {
    // 1. Delete physical file locally
    final file = File(document.localPath);
    if (await file.exists()) {
      await file.delete();
    }
    
    // 2. We don't delete from Cloudinary here (unsigned preset is upload only).
    // The user owns their Cloudinary storage, so stale files can be bulk deleted there if needed.

    // 3. Delete Firestore metadata
    await _userDocumentsRef.doc(document.id).delete();
  }

  Future<void> updateDocument(DocumentModel document) async {
    await _userDocumentsRef.doc(document.id).update(document.toFirestore());
  }

  Future<void> syncToCloudinary(DocumentModel document) async {
    if (document.cloudUrl != null) return; // Already synced

    final file = File(document.localPath);
    if (!await file.exists()) return;

    try {
      final uri = Uri.parse('https://api.cloudinary.com/v1_1/$_cloudinaryCloudName/upload');
      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = _cloudinaryUploadPreset
        ..fields['public_id'] = 'vaultmaster/$_userId/${document.id}'
        ..files.add(await http.MultipartFile.fromPath('file', file.path));

      // Add a strict 30-second timeout so a hanging request doesn't freeze the sync engine
      final response = await request.send().timeout(const Duration(seconds: 30));
      if (response.statusCode == 200 || response.statusCode == 201) {
        final respStr = await response.stream.bytesToString();
        final jsonMap = jsonDecode(respStr);
        final secureUrl = jsonMap['secure_url'] as String?;

        if (secureUrl != null) {
          await _userDocumentsRef.doc(document.id).update({
            'cloudUrl': secureUrl,
          });
        }
      } else {
        final error = await response.stream.bytesToString();
        print('Cloudinary upload failed: ${response.statusCode} - $error');
        throw Exception('Upload failed');
      }
    } catch (e) {
      print('Cloudinary Sync Error: $e');
      rethrow; // So the sync service knows it failed
    }
  }
}

@riverpod
DocumentRepository documentRepository(DocumentRepositoryRef ref) {
  final auth = FirebaseAuth.instance;
  final uid = auth.currentUser?.uid;
  if (uid == null) {
    throw Exception('User is not authenticated');
  }
  return DocumentRepository(FirebaseFirestore.instance, uid);
}

import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
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

  static final Map<String, Uint8List> _webBytesCache = {};

  Future<String> _getAppDocumentsDir() async {
    if (kIsWeb) return 'web_vault_documents';
    final directory = await getApplicationDocumentsDirectory();
    final documentsPath = p.join(directory.path, 'vault_documents');
    final dir = Directory(documentsPath);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return documentsPath;
  }

  static final List<DocumentModel> _webSandboxDocs = _getInitialDemoDocs();

  static List<DocumentModel> _getInitialDemoDocs() {
    final now = DateTime.now();
    return [
      DocumentModel(
        id: 'demo-doc-1',
        userId: 'demo-sandbox-uid',
        name: 'Tax_Return_2025_W2.pdf',
        localPath: 'web_cache/demo-doc-1',
        createdAt: now.subtract(const Duration(hours: 2)),
        categoryId: 'Receipts',
        fileType: 'pdf',
        fileSize: 2450000,
        isVaulted: false,
        fileHash: 'demo-hash-1',
        cloudUrl: 'https://res.cloudinary.com/dghqjhbxj/image/upload/v1/demo/tax_return.pdf',
      ),
      DocumentModel(
        id: 'demo-doc-2',
        userId: 'demo-sandbox-uid',
        name: 'Passport_ID_Card_Scan.png',
        localPath: 'web_cache/demo-doc-2',
        createdAt: now.subtract(const Duration(days: 1)),
        categoryId: 'IDs',
        fileType: 'png',
        fileSize: 4120000,
        isVaulted: false,
        fileHash: 'demo-hash-2',
        cloudUrl: 'https://res.cloudinary.com/dghqjhbxj/image/upload/v1/demo/passport.png',
      ),
      DocumentModel(
        id: 'demo-doc-3',
        userId: 'demo-sandbox-uid',
        name: 'Real_Estate_Lease_Contract_2026.pdf',
        localPath: 'web_cache/demo-doc-3',
        createdAt: now.subtract(const Duration(days: 3)),
        categoryId: 'Contracts',
        fileType: 'pdf',
        fileSize: 3850000,
        isVaulted: false,
        fileHash: 'demo-hash-3',
        cloudUrl: 'https://res.cloudinary.com/dghqjhbxj/image/upload/v1/demo/lease.pdf',
      ),
      DocumentModel(
        id: 'demo-doc-4',
        userId: 'demo-sandbox-uid',
        name: 'Hardware_Wallet_Seed_Phrase.txt',
        localPath: 'web_cache/demo-doc-4',
        createdAt: now.subtract(const Duration(minutes: 15)),
        categoryId: 'Other',
        fileType: 'txt',
        fileSize: 1200,
        isVaulted: true,
        fileHash: 'demo-hash-4',
        cloudUrl: 'https://res.cloudinary.com/dghqjhbxj/image/upload/v1/demo/seed.txt',
      ),
      DocumentModel(
        id: 'demo-doc-5',
        userId: 'demo-sandbox-uid',
        name: 'Health_Insurance_Policy_Card.pdf',
        localPath: 'web_cache/demo-doc-5',
        createdAt: now.subtract(const Duration(days: 5)),
        categoryId: 'IDs',
        fileType: 'pdf',
        fileSize: 1890000,
        isVaulted: false,
        fileHash: 'demo-hash-5',
        cloudUrl: 'https://res.cloudinary.com/dghqjhbxj/image/upload/v1/demo/health.pdf',
      ),
      DocumentModel(
        id: 'demo-doc-6',
        userId: 'demo-sandbox-uid',
        name: 'MacBook_Pro_Apple_Receipt.pdf',
        localPath: 'web_cache/demo-doc-6',
        createdAt: now.subtract(const Duration(days: 7)),
        categoryId: 'Receipts',
        fileType: 'pdf',
        fileSize: 980000,
        isVaulted: false,
        fileHash: 'demo-hash-6',
        cloudUrl: 'https://res.cloudinary.com/dghqjhbxj/image/upload/v1/demo/apple_receipt.pdf',
      ),
    ];
  }

  Future<DocumentModel> ingestWebFile({
    required Uint8List bytes,
    required String name,
    required String categoryId,
    bool isVaulted = false,
  }) async {
    final fileHash = sha256.convert(bytes).toString();

    if (kIsWeb || _userId == 'demo-sandbox-uid') {
      final id = 'sandbox-${DateTime.now().millisecondsSinceEpoch}';
      _webBytesCache[id] = bytes;
      final fileExtension = p.extension(name);
      final fileType = fileExtension.replaceAll('.', '').toLowerCase();
      final doc = DocumentModel(
        id: id,
        userId: _userId,
        name: name,
        localPath: 'web_cache/$id',
        createdAt: DateTime.now(),
        categoryId: categoryId,
        fileType: fileType.isEmpty ? 'pdf' : fileType,
        fileSize: bytes.length,
        isVaulted: isVaulted,
        fileHash: fileHash,
        cloudUrl: 'https://res.cloudinary.com/dghqjhbxj/image/upload/v1/demo/uploaded_$id.pdf',
      );
      _webSandboxDocs.insert(0, doc);
      return doc;
    }

    try {
      final duplicateQuery = await _userDocumentsRef
          .where('fileHash', isEqualTo: fileHash)
          .get(const GetOptions(source: Source.cache));
          
      if (duplicateQuery.docs.isNotEmpty) {
        throw DuplicateDocumentException('Document already exists in your vault.');
      }
    } catch (e) {
      if (e is DuplicateDocumentException) rethrow;
    }

    final docRef = _userDocumentsRef.doc();
    final fileExtension = p.extension(name);
    final fileType = fileExtension.replaceAll('.', '').toLowerCase();
    
    final localFilename = '${docRef.id}$fileExtension';
    final secureLocalPath = 'web_cache/$localFilename';
    _webBytesCache[docRef.id] = bytes;

    final document = DocumentModel(
      id: docRef.id,
      userId: _userId,
      name: name,
      localPath: secureLocalPath,
      createdAt: DateTime.now(),
      categoryId: categoryId,
      fileType: fileType.isEmpty ? 'pdf' : fileType,
      fileSize: bytes.length,
      isVaulted: isVaulted,
      fileHash: fileHash,
    );

    await docRef.set(document.toFirestore());
    return document;
  }

  Future<DocumentModel> ingestFile({
    required File file,
    required String name,
    required String categoryId,
    bool isVaulted = false,
  }) async {
    final bytes = await file.readAsBytes();
    final fileHash = sha256.convert(bytes).toString();

    try {
      final duplicateQuery = await _userDocumentsRef
          .where('fileHash', isEqualTo: fileHash)
          .get(const GetOptions(source: Source.cache));
          
      if (duplicateQuery.docs.isNotEmpty) {
        throw DuplicateDocumentException('Document already exists in your vault.');
      }
    } catch (e) {
      if (e is DuplicateDocumentException) rethrow;
    }

    final docRef = _userDocumentsRef.doc();
    final appDocsDir = await _getAppDocumentsDir();
    final fileExtension = p.extension(file.path);
    final fileType = fileExtension.replaceAll('.', '').toLowerCase();
    
    final localFilename = '${docRef.id}$fileExtension';
    final secureLocalPath = p.join(appDocsDir, localFilename);
    
    await file.copy(secureLocalPath);
    final fileSize = await File(secureLocalPath).length();

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
    if (kIsWeb || _userId == 'demo-sandbox-uid') {
      return Stream.value(List.from(_webSandboxDocs));
    }
    return _userDocumentsRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DocumentModel.fromFirestore(doc))
            .toList());
  }

  Future<List<DocumentModel>> getUnsyncedDocuments() async {
    if (kIsWeb || _userId == 'demo-sandbox-uid') {
      return [];
    }
    final snapshot = await _userDocumentsRef.where('cloudUrl', isNull: true).get();
    return snapshot.docs.map((doc) => DocumentModel.fromFirestore(doc)).toList();
  }

  Future<void> deleteDocument(DocumentModel document) async {
    if (kIsWeb || _userId == 'demo-sandbox-uid') {
      _webSandboxDocs.removeWhere((d) => d.id == document.id);
      _webBytesCache.remove(document.id);
      return;
    }
    if (!document.localPath.startsWith('web_cache/')) {
      final file = File(document.localPath);
      if (await file.exists()) {
        await file.delete();
      }
    }
    _webBytesCache.remove(document.id);
    await _userDocumentsRef.doc(document.id).delete();
  }

  Future<void> updateDocument(DocumentModel document) async {
    if (kIsWeb || _userId == 'demo-sandbox-uid') {
      final idx = _webSandboxDocs.indexWhere((d) => d.id == document.id);
      if (idx != -1) {
        _webSandboxDocs[idx] = document;
      }
      return;
    }
    await _userDocumentsRef.doc(document.id).update(document.toFirestore());
  }

  Future<void> syncToCloudinary(DocumentModel document) async {
    if (kIsWeb || _userId == 'demo-sandbox-uid' || document.cloudUrl != null) return;

    http.MultipartFile multipartFile;
    if (document.localPath.startsWith('web_cache/') || _webBytesCache.containsKey(document.id)) {
      final bytes = _webBytesCache[document.id];
      if (bytes == null) return;
      multipartFile = http.MultipartFile.fromBytes('file', bytes, filename: document.name);
    } else {
      final file = File(document.localPath);
      if (!await file.exists()) return;
      multipartFile = await http.MultipartFile.fromPath('file', file.path);
    }

    try {
      final uri = Uri.parse('https://api.cloudinary.com/v1_1/$_cloudinaryCloudName/upload');
      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = _cloudinaryUploadPreset
        ..fields['public_id'] = 'vaultmaster/$_userId/${document.id}'
        ..files.add(multipartFile);

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
      rethrow;
    }
  }
}

@riverpod
DocumentRepository documentRepository(DocumentRepositoryRef ref) {
  if (kIsWeb) {
    return DocumentRepository(FirebaseFirestore.instance, 'demo-sandbox-uid');
  }
  final auth = FirebaseAuth.instance;
  final uid = auth.currentUser?.uid;
  if (uid == null) {
    throw Exception('User is not authenticated');
  }
  return DocumentRepository(FirebaseFirestore.instance, uid);
}

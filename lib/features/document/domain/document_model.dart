import 'package:cloud_firestore/cloud_firestore.dart';

class DocumentModel {
  final String id;
  final String userId;
  final String name;
  final String localPath;
  final DateTime createdAt;
  final String categoryId;
  final String fileType;
  final int fileSize;
  final String? cloudUrl;
  final bool isVaulted;
  final String? fileHash;

  DocumentModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.localPath,
    required this.createdAt,
    required this.categoryId,
    required this.fileType,
    required this.fileSize,
    this.cloudUrl,
    this.isVaulted = false,
    this.fileHash,
  });

  factory DocumentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DocumentModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      localPath: data['localPath'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      categoryId: data['categoryId'] ?? 'uncategorized',
      fileType: data['fileType'] ?? 'pdf',
      fileSize: data['fileSize'] ?? 0,
      cloudUrl: data['cloudUrl'],
      isVaulted: data['isVaulted'] ?? false,
      fileHash: data['fileHash'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'localPath': localPath,
      'createdAt': Timestamp.fromDate(createdAt),
      'categoryId': categoryId,
      'fileType': fileType,
      'fileSize': fileSize,
      'cloudUrl': cloudUrl,
      'isVaulted': isVaulted,
      'fileHash': fileHash,
    };
  }

  DocumentModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? localPath,
    DateTime? createdAt,
    String? categoryId,
    String? fileType,
    int? fileSize,
    String? cloudUrl,
    bool? isVaulted,
    String? fileHash,
  }) {
    return DocumentModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      localPath: localPath ?? this.localPath,
      createdAt: createdAt ?? this.createdAt,
      categoryId: categoryId ?? this.categoryId,
      fileType: fileType ?? this.fileType,
      fileSize: fileSize ?? this.fileSize,
      cloudUrl: cloudUrl ?? this.cloudUrl,
      isVaulted: isVaulted ?? this.isVaulted,
      fileHash: fileHash ?? this.fileHash,
    );
  }
}

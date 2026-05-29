class UserModel {
  final String uid;
  final String email;
  final DateTime createdAt;
  final int storageUsed;

  const UserModel({
    required this.uid,
    required this.email,
    required this.createdAt,
    required this.storageUsed,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, String id) {
    return UserModel(
      uid: id,
      email: json['email'] as String? ?? '',
      createdAt: json['createdAt'] != null 
          ? (json['createdAt'] as dynamic).toDate() as DateTime 
          : DateTime.now(),
      storageUsed: json['storageUsed'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'createdAt': createdAt,
      'storageUsed': storageUsed,
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    DateTime? createdAt,
    int? storageUsed,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      storageUsed: storageUsed ?? this.storageUsed,
    );
  }
}

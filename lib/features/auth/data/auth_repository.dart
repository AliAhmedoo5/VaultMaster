import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/user_model.dart';

part 'auth_repository.g.dart';

class SandboxMockUser implements User {
  @override
  String get uid => 'demo-sandbox-uid';

  @override
  String? get email => 'alex.morgan@vaultmaster.app';

  @override
  String? get displayName => 'Alex Morgan (Demo Vault)';

  @override
  String? get photoURL => null;

  @override
  bool get isAnonymous => false;

  @override
  bool get emailVerified => true;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

@riverpod
class SandboxAuthState extends _$SandboxAuthState {
  @override
  bool build() => false;

  void signIn() => state = true;
  void signOut() => state = false;
}

class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _db;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  AuthRepository({
    required FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
  })  : _auth = firebaseAuth,
        _db = firestore;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser {
    if (kIsWeb) {
      return SandboxMockUser();
    }
    return _auth.currentUser;
  }

  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> createUserWithEmailAndPassword(String email, String password) async {
    final credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    if (credential.user != null) {
      await _syncUserProfile(credential.user!);
    }
    return credential;
  }

  Future<UserCredential?> signInWithGoogle() async {
    if (kIsWeb) {
      final googleProvider = GoogleAuthProvider();
      final userCred = await _auth.signInWithPopup(googleProvider);
      if (userCred.user != null) {
        await _syncUserProfile(userCred.user!);
      }
      return userCred;
    }

    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null; // User cancelled flow

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCred = await _auth.signInWithCredential(credential);
    if (userCred.user != null) {
      await _syncUserProfile(userCred.user!);
    }
    return userCred;
  }

  Future<void> signOut() async {
    if (!kIsWeb) {
      await _googleSignIn.signOut();
    }
    await _auth.signOut();
  }

  Future<UserModel?> getUserProfile(String uid) async {
    if (kIsWeb || uid == 'demo-sandbox-uid') {
      return UserModel(
        uid: 'demo-sandbox-uid',
        email: 'alex.morgan@vaultmaster.app',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        storageUsed: 14200000,
      );
    }
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists || doc.data() == null) return null;
    return UserModel.fromJson(doc.data()!, doc.id);
  }

  Future<void> _syncUserProfile(User user) async {
    final ref = _db.collection('users').doc(user.uid);
    final doc = await ref.get();
    
    if (!doc.exists) {
      final newUser = UserModel(
        uid: user.uid,
        email: user.email ?? '',
        createdAt: DateTime.now(),
        storageUsed: 0,
      );
      await ref.set(newUser.toJson());
    }
  }
}

@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  return AuthRepository(
    firebaseAuth: FirebaseAuth.instance,
    firestore: FirebaseFirestore.instance,
  );
}

@riverpod
Stream<User?> authState(AuthStateRef ref) {
  if (kIsWeb) {
    final isSandboxSignedIn = ref.watch(sandboxAuthStateProvider);
    if (isSandboxSignedIn) {
      return Stream.value(SandboxMockUser());
    }
    return Stream.value(null);
  }
  return ref.watch(authRepositoryProvider).authStateChanges;
}

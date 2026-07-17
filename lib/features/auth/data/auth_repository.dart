import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/user_model.dart';

part 'auth_repository.g.dart';

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

  User? get currentUser => _auth.currentUser;

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
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null; // User cancelled flow

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final credential = OAuthCredential(
      providerId: 'google.com',
      signInMethod: 'google.com',
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
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  Future<UserModel?> getUserProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
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
  return ref.watch(authRepositoryProvider).authStateChanges;
}

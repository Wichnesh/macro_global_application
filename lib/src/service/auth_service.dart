import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:macro_global_test_app/src/service/storage_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> signUpWithEmail(String email, String password, String name, String phone) async {
    try {
      final exists = await isEmailAlreadyRegistered(email);
      if (exists) {
        throw FirebaseAuthException(
          code: 'email-already-exists',
          message: 'This email is already registered via Google Sign-In.',
        );
      }

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore.collection('users').doc(credential.user!.uid).set({
        'name': name,
        'phone': phone,
        'email': email,
        'uid': credential.user!.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await StorageService.setLoginStatus(true);
      return credential.user;
    } on FirebaseAuthException catch (e) {
      print('Email Sign-up error: ${e.message}');
      rethrow;
    } catch (e) {
      print('Unexpected Sign-up error: $e');
      rethrow;
    }
  }

  Future<bool> isEmailAlreadyRegistered(String email) async {
    final query = await _firestore.collection('users').where('email', isEqualTo: email).limit(1).get();
    return query.docs.isNotEmpty;
  }

  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      await StorageService.setLoginStatus(true);
      return credential.user;
    } on FirebaseAuthException catch (e) {
      print('Login error: ${e.message}');
      rethrow;
    } catch (e) {
      print('Unexpected login error: $e');
      rethrow;
    }
  }

  Future<User?> signInWithGoogle() async {
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        final userDoc = _firestore.collection('users').doc(user.uid);

        final docSnapshot = await userDoc.get();
        if (!docSnapshot.exists) {
          final data = {
            'name': user.displayName ?? '',
            'email': user.email ?? '',
            'photoURL': user.photoURL ?? '',
            'uid': user.uid,
            'createdAt': FieldValue.serverTimestamp(),
          };

          if (user.phoneNumber != null && user.phoneNumber!.isNotEmpty) {
            data['phone'] = user.phoneNumber!;
          }

          await userDoc.set(data);
        }
      }
      await StorageService.setLoginStatus(true);
      return user;
    } on FirebaseAuthException catch (e) {
      print('Google Sign-In error: ${e.message}');
      rethrow;
    } catch (e) {
      print('Unexpected Google Sign-In error: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Sign-out error: $e');
      rethrow;
    }
  }

  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).set(data, SetOptions(merge: true));
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserProfile(String uid) {
    return FirebaseFirestore.instance.collection('users').doc(uid).get();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }
}

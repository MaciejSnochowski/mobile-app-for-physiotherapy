import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:physiotherapy/main.dart';
import 'package:physiotherapy/model/user.dart';
import 'package:physiotherapy/services/session/user_session_service.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _sessionService = UserSessionService();

  User? getCurrentUserData() {
    return _auth.currentUser;
  }

  Future<User?> signUpWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return credential.user;
    } catch (e) {
      logger.e("FirebaseAuthException message: ${e.toString()}");
      return null;
    }
  }

  Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return credential.user;
    } catch (e) {
      logger.e("Error message:" + e.toString());
      return null;
    }
  }

  Future<UserModel?> getUserData(String uid) async {
    try {
      // Pobranie dokumentu użytkownika z Firestore na podstawie UID
      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('Users').doc(uid).get();

      if (snapshot.exists) {
        // Konwersja dokumentu na obiekt User
        Map<String, dynamic> userData = snapshot.data()!;
        return UserModel.fromMap(userData);
      } else {
        logger.e('User not found');
        return null;
      }
    } catch (e) {
      logger.e('Error getting user data: $e');
      return null;
    }
  }

  Future<void> updateUserData(
      String uid, Map<String, dynamic> updatedData) async {
    try {
      // Update data
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(uid)
          .update(updatedData);

      //Update current session
      UserModel? updatedUser = await getUserData(uid);
      if (updatedUser != null) {
        convertToUserModell(updatedUser);
        _sessionService.loginUser(convertToUserModell(updatedUser));
      }

      logger.i('User data updated successfully.');
    } catch (e) {
      logger.e('Error updating user data: $e');
    }
  }

  UserModel convertToUserModell(UserModel? user) {
    try {
      return UserModel(
          id: user!.id,
          email: user.email,
          firstName: user.firstName,
          lastName: user.lastName,
          address: user.address,
          phoneNumber: user.phoneNumber,
          firstLogin: user.firstLogin,
          isPhysiotherapist: user.isPhysiotherapist);
    } catch (e) {
      logger.e("firebase_auth_service error unable to convert");
      return UserModel(
        id: '',
        email: '',
        firstName: '',
        lastName: '',
        address: '',
        phoneNumber: '',
        firstLogin: false,
      );
    }
  }

  Future<void> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      _sessionService.logoutUser();
    } catch (e) {
      logger.i("Error during logout: $e");
    }
  }
}

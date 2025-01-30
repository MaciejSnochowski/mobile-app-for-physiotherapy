import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Dodajemy Firestore
import 'package:flutter/material.dart';
import 'package:physiotherapy/main.dart';

class ForgetPasswordViewModel extends ChangeNotifier {
  FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future<void> passwordReset(BuildContext context) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('email', isEqualTo: emailController.text.trim())
          .get();

      if (querySnapshot.docs.isEmpty) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Błąd'),
            content:
                Text('Nie znaleziono użytkownika o podanym adresie email.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          ),
        );
      } else {
        await _auth.sendPasswordResetEmail(email: emailController.text.trim());

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Sukces'),
            content: Text(
                'Link do resetowania hasła został wysłany na podany adres email.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Błąd'),
            content:
                Text('Nie znaleziono użytkownika o podanym adresie email.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          ),
        );
      } else if (e.code == 'invalid-email') {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Błąd'),
            content: Text('Wprowadzony adres email jest niepoprawny.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          ),
        );
      } else {
        logger.e("nieoczekiwany błąd -> $e");

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Błąd'),
            content: Text('Wystąpił nieoczekiwany błąd.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      logger.e("passwordReset error: $e");
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:physiotherapy/main.dart';
import 'package:physiotherapy/services/auth/firebase_auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:physiotherapy/view/auth/login_view.dart';

class SignupViewModel extends ChangeNotifier {
  final FirebaseAuthService _auth = FirebaseAuthService();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _passwordVisible = true;
  bool get passwordVisible => _passwordVisible;

  void togglePasswordVisibility() {
    _passwordVisible = !_passwordVisible;
    notifyListeners();
  }

  String _tempPass = '';

  String? validateEmail(String? value) {
    const pattern = r"(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'"
        r'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-'
        r'\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*'
        r'[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:(2(5[0-5]|[0-4]'
        r'[0-9])|1[0-9][0-9]|[1-9]?[0-9]))\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9]'
        r'[0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\'
        r'x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])';
    final regex = RegExp(pattern);

    return value!.isEmpty || !regex.hasMatch(value)
        ? 'Wprowadź poprawny email'
        : null;
  }

  String? validatePassword(String? value) {
    String errorMessage = '';

    if (value!.length < 6) {
      errorMessage += 'Hasło musi być dłuższe niż 6 znaków.\n';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      errorMessage += 'Brakuje dużej litery.\n';
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      errorMessage += 'Brakuje małej litery.\n';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      errorMessage += 'Brakuje cyfry.\n';
    }
    if (!value.contains(RegExp(r'[!@#%^&*(),.?":{}|<>]'))) {
      errorMessage += 'Brakuje znaku specjalnego.\n';
    }

    if (value.isEmpty || errorMessage.isNotEmpty) {
      return 'Wprowadź poprawne hasło';
    } else {
      _tempPass = value;
      return null;
    }
  }

  String? validateSecondPassword(String? value) {
    value == null ? 'Hasło nie może być puste' : null;
    if (value!.isEmpty) return 'Hasło nie może być puste';
    return _tempPass == value ? null : 'Wprowadź poprawne hasło';
  }

  Future<void> signUp(
      BuildContext context, GlobalKey<FormState> singupFormKey) async {
    if (singupFormKey.currentState!.validate()) {
      String email = emailController.text;
      String password = passwordController.text;

      User? user = await _auth.signUpWithEmailAndPassword(email, password);
      if (user != null) {
        await _firestore
            .collection('Users')
            .doc(user.uid)
            .set({'id': user.uid, 'email': user.email, 'firstLogin': true});
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
          (route) => false,
        );
      } else {
        logger.e("Wystąpił problem podczas rejestracji");
        _showErrorDialog(context, 'Błąd rejestracji',
            'Konto z podanym adresem email już istnieje');
      }
    } else {
      logger.e("Wprowadź poprawne dane");
    }
  }

  void _showErrorDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}

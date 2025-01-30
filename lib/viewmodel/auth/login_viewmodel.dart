import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:physiotherapy/main.dart';
import 'package:physiotherapy/model/user.dart';
import 'package:physiotherapy/services/auth/firebase_auth_service.dart';
import 'package:physiotherapy/services/session/user_session_service.dart';

class LoginViewModel extends ChangeNotifier {
  final FirebaseAuthService _auth = FirebaseAuthService();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _sessionService = UserSessionService();

  bool _passwordVisible = true;
  bool get passwordVisible => _passwordVisible;
  //get GlobalKey<FormState> loginFormKey => _loginFormKey;

  void togglePasswordVisibility() {
    _passwordVisible = !_passwordVisible;
    notifyListeners();
  }

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
      return null;
    }
  }

  // Future<void> signIn(
  //     BuildContext context, GlobalKey<FormState> loginFormKey) async {
  //   if (loginFormKey.currentState!.validate()) {
  //     String email = emailController.text;
  //     String password = passwordController.text;
  //     User? user = await _auth.signInWithEmailAndPassword(email, password);
  //     UserModel? userModel;

  //     if (user != null) {
  //       userModel = await _auth.getUserData(user.uid);
  //       if (userModel != null) {
  //         _sessionService.loginUser(userModel);
  //         if (userModel.firstLogin) {
  //           logger.i("That is first login: ${userModel.firstLogin}");
  //           Navigator.pushNamed(context, '/personal_info');
  //         } else {
  //           logger.i("Route to home page first login: ${userModel.firstLogin}");
  //           Navigator.pushNamed(context, '/home');
  //         }
  //       } else {
  //         logger.e("UseModel is null");
  //       }
  //     } else {
  //       logger.e("User from firebase is null");
  //     }
  //   } else {
  //     logger.e("Invalid data from form or invalid Globalkey");
  //   }
  // }
  Future<void> signIn(
      BuildContext context, GlobalKey<FormState> loginFormKey) async {
    if (loginFormKey.currentState!.validate()) {
      try {
        String email = emailController.text;
        String password = passwordController.text;
        User? user = await _auth.signInWithEmailAndPassword(email, password);
        UserModel? userModel;

        if (user != null) {
          userModel = await _auth.getUserData(user.uid);
          if (userModel != null) {
            _sessionService.loginUser(userModel);
            if (userModel.firstLogin) {
              logger.i("That is first login: ${userModel.firstLogin}");
              clearController;
              Navigator.pushNamed(context, '/personal_info');
            } else {
              logger
                  .i("Route to home page first login: ${userModel.firstLogin}");
              Navigator.pushNamed(context, '/home');
            }
          } else {
            logger.e("UseModel is null");
            _showErrorDialog(
                context, 'Błąd', 'Wystąpił błąd podczas logowania.');
          }
        } else {
          logger.e("User from firebase is null");
          _showErrorDialog(context, 'Błąd podczas logowania',
              'Dane uwierzytelniające są nieprawidłowe lub wygasły.');
        }
      } catch (error) {
        String errorMessage = 'Wystąpił błąd podczas logowania.';

        if (error is FirebaseAuthException) {
          switch (error.code) {
            case 'wrong-password':
              errorMessage = 'Nieprawidłowe hasło. Spróbuj ponownie.';
              break;
            case 'user-not-found':
              errorMessage = 'Nie znaleziono użytkownika z tym adresem email.';
              break;
            case 'invalid-email':
              errorMessage = 'Nieprawidłowy adres email.';
              break;
            case 'user-disabled':
              errorMessage = 'Konto użytkownika zostało wyłączone.';
              break;
            default:
              errorMessage =
                  'Wystąpił nieznany błąd. Spróbuj ponownie później.';
              break;
          }
        }

        logger.e("Error during sign in: $error");
        _showErrorDialog(context, 'Błąd logowania', errorMessage);
      }
    } else {
      logger.e("Invalid data from form or invalid Globalkey");
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

  void clearController() {
    emailController.clear();
    passwordController.clear();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}

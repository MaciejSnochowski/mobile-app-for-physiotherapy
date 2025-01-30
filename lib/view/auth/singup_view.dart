import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:physiotherapy/utils/text_utils.dart';
import 'package:physiotherapy/viewmodel/auth/singup_viewmodel.dart';
import 'package:provider/provider.dart';
import 'login_view.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final GlobalKey<FormState> singupFormKey = new GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final SignupViewModel signupViewModel =
        Provider.of<SignupViewModel>(context);

    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/background.jpg'), fit: BoxFit.fill),
        ),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height * 0.8,
            child: Center(
              child: Container(
                height: 700,
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 30),
                decoration: BoxDecoration(
                  border: Border.all(
                      color: const Color.fromARGB(255, 255, 255, 255)),
                  borderRadius: BorderRadius.circular(15),
                  color: Color.fromARGB(255, 0, 0, 0).withOpacity(0.2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaY: 5, sigmaX: 5),
                    child: Padding(
                      padding: const EdgeInsets.all(25),
                      child: Form(
                        key: singupFormKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),
                            Center(
                              child: TextUtil(
                                text: "Rejestracja",
                                weight: true,
                                size: 30,
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextUtil(text: "Email"),
                            TextFormField(
                              validator: signupViewModel.validateEmail,
                              cursorColor: Colors.white,
                              controller: signupViewModel.emailController,
                              style: const TextStyle(
                                color: Color.fromARGB(255, 255, 255, 255),
                              ),
                              decoration: const InputDecoration(
                                border: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                                suffixIcon: Icon(
                                  Icons.mail,
                                  color: Colors.white,
                                ),
                                fillColor: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 30),
                            TextUtil(text: "Hasło"),
                            TextFormField(
                              validator: signupViewModel.validatePassword,
                              controller: signupViewModel.passwordController,
                              cursorColor: Colors.white,
                              obscureText: signupViewModel.passwordVisible,
                              obscuringCharacter: '*',
                              style: const TextStyle(
                                  color: Color.fromARGB(255, 255, 255, 255)),
                              decoration: InputDecoration(
                                fillColor: Colors.white,
                                border: const UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                                enabledBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                                focusedBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                                suffixIcon: IconButton(
                                  onPressed:
                                      signupViewModel.togglePasswordVisibility,
                                  icon: Icon(
                                    signupViewModel.passwordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),
                            TextUtil(text: "Powtórz hasło"),
                            TextFormField(
                              validator: signupViewModel.validateSecondPassword,
                              cursorColor: Colors.white,
                              obscureText: signupViewModel.passwordVisible,
                              obscuringCharacter: '*',
                              style: const TextStyle(
                                  color: Color.fromARGB(255, 255, 255, 255)),
                              decoration: const InputDecoration(
                                fillColor: Colors.white,
                                border: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            const SizedBox(height: 20),
                            InkWell(
                              onTap: () => signupViewModel.signUp(
                                  context, singupFormKey),
                              child: Container(
                                height: 40,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                alignment: Alignment.center,
                                child: TextUtil(
                                  text: "Zarejestruj się",
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            InkWell(
                              onTap: () {
                                Navigator.pushNamed(context, '/');
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Masz już konto?",
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(width: 5),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                LoginScreen()),
                                        (route) => false,
                                      );
                                    },
                                    child: Text(
                                      "Zaloguj się",
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

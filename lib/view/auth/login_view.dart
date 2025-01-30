import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:physiotherapy/viewmodel/auth/login_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:physiotherapy/utils/text_utils.dart';
import 'singup_view.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final loginViewModel = Provider.of<LoginViewModel>(context);

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
                height: 500,
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
                        key: loginFormKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),
                            Center(
                              child: TextUtil(
                                text: "Logowanie",
                                weight: true,
                                size: 30,
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextUtil(text: "Email"),
                            TextFormField(
                              validator: loginViewModel.validateEmail,
                              controller: loginViewModel.emailController,
                              cursorColor: Colors.white,
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
                              validator: loginViewModel.validatePassword,
                              controller: loginViewModel.passwordController,
                              cursorColor: Colors.white,
                              obscureText: loginViewModel.passwordVisible,
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
                                      loginViewModel.togglePasswordVisibility,
                                  icon: Icon(
                                    loginViewModel.passwordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            //Gesture detector
                            SizedBox(
                              child: GestureDetector(
                                onTap: () => Navigator.pushNamed(
                                    context, '/forget_password'),
                                child: Text(
                                  "Zapomniałeś hasła?",
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // const SizedBox(height: 10),
                            InkWell(
                              onTap: () {
                                loginViewModel.signIn(context, loginFormKey);
                              },
                              child: Container(
                                height: 40,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                alignment: Alignment.center,
                                child: TextUtil(
                                  text: "Zaloguj się",
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            InkWell(
                              onTap: () {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SignupScreen()),
                                  (route) => false,
                                );
                              },
                              child: Container(
                                height: 40,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                alignment: Alignment.center,
                                child: TextUtil(
                                  text: "Rejestracja",
                                  color: Colors.black,
                                ),
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

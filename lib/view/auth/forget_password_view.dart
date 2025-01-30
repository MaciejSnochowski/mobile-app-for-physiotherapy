import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:physiotherapy/utils/text_utils.dart';
import 'package:physiotherapy/viewmodel/auth/forget_password_viewmodel.dart';
import 'package:physiotherapy/viewmodel/auth/login_viewmodel.dart';
import 'package:provider/provider.dart';

class ForgetPasswordView extends StatefulWidget {
  const ForgetPasswordView({super.key});

  @override
  State<ForgetPasswordView> createState() => _ForgetPasswordView();
}

class _ForgetPasswordView extends State<ForgetPasswordView> {
  @override
  Widget build(BuildContext context) {
    final _forgetPasswordViewModel =
        Provider.of<ForgetPasswordViewModel>(context);

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
                      child: Column(
                        mainAxisAlignment:
                            MainAxisAlignment.center, // Wycentrowanie
                        crossAxisAlignment:
                            CrossAxisAlignment.center, // Wycentrowanie
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Wpisz adres email konta którego chcesz odzyskać hasło",
                              textAlign:
                                  TextAlign.center, // Wyśrodkowanie tekstu
                              style: const TextStyle(
                                fontWeight:
                                    FontWeight.bold, // Pogrubienie tekstu
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.0),
                            child: TextField(
                              controller:
                                  _forgetPasswordViewModel.emailController,
                              cursorColor: Colors.white,
                              style: const TextStyle(
                                  color: Color.fromARGB(255, 255, 255, 255)),
                              decoration: InputDecoration(
                                hintText: "Wpisz adres email",
                                hintStyle: TextStyle(color: Colors.white54),
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
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          InkWell(
                            onTap: () {
                              _forgetPasswordViewModel.passwordReset(context);
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
                                text: "Zresetuj hasło",
                                color: Colors.black,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          InkWell(
                            onTap: () => Navigator.pushNamed(context, '/'),
                            child: Container(
                              height: 40,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              alignment: Alignment.center,
                              child: TextUtil(
                                text: "Cofnij do logowania",
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
    );
  }
}

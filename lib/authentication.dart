import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ggits/home_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rive/rive.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen>
    with SingleTickerProviderStateMixin {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Positioned(
            width: MediaQuery.of(context).size.width * 1.7,
            left: 100,
            bottom: 100,
            child: Image.asset(
              "assets/images/Spline.png",
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: const SizedBox(),
            ),
          ),
          const RiveAnimation.asset(
            "assets/images/shapes.riv",
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: const SizedBox(),
            ),
          ),
          AnimatedPositioned(
            top: 0,
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            duration: const Duration(milliseconds: 260),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: size.height / 12,
                  ),
                  SizedBox(
                    width: size.width / 1.2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "Your Ultimate Notes Hub",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: size.height / 16,
                            fontWeight: FontWeight.w700,
                            fontFamily: "Poppins",
                            height: 1.2,
                          ),
                        ),
                        SizedBox(height: size.height / 28),
                        Text(
                          "Access complete handwritten notes from GGITS students with ease.Get high-quality resources to boost your learning now!",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: size.height / 42,
                            fontWeight: FontWeight.w400,
                            fontFamily: "Poppins",
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    flex: 2,
                    child: Container(),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter your email';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: size.height / 56),
                        TextFormField(
                          controller: _passwordController,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: size.height / 22),
                        ElevatedButton(
                          onPressed: () async {
                            try {
                              UserCredential userCredential = await FirebaseAuth
                                  .instance
                                  .signInWithEmailAndPassword(
                                email: _emailController.text.trim(),
                                password: _passwordController.text.trim(),
                              );

                              // User is signed in

                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const HomeScreen()),
                              );
                            } on FirebaseAuthException catch (e) {
                              if (e.code == 'user not found') {
                                if (kDebugMode) {
                                  print('No user found for that email.');
                                }
                              } else if (e.code == 'wrong-password') {
                                if (kDebugMode) {
                                  print(
                                      'Wrong password provided for that user.');
                                }
                              } else {
                                if (kDebugMode) {
                                  print(e.toString());
                                }
                              }
                            } catch (e) {
                              if (kDebugMode) {
                                print(e.toString());
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: const BorderSide(color: Colors.white),
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            width: size.width / 4,
                            height: size.height / 18,
                            child: Text(
                              'Admin Sign In',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: size.height / 56,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: size.height / 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 1,
                        width: size.width / 6,
                        color: Colors.white,
                      ),
                      SizedBox(width: size.width / 18),
                      Text(
                        "OR",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: size.height / 52,
                          fontFamily: "Poppins",
                        ),
                      ),
                      SizedBox(width: size.width / 18),
                      Container(
                        height: 1,
                        width: size.width / 6,
                        color: Colors.white,
                      ),
                    ],
                  ),
                  SizedBox(height: size.height / 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: size.height / 17,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: const BorderSide(color: Colors.white),
                          ),
                          onPressed: () async {
                            try {
                              // Show a loading indicator
                              setState(() {
                                _isLoading = true;
                              });

                              // Start the Google sign-in flow
                              final GoogleSignInAccount? googleUser =
                                  await _googleSignIn.signIn();

                              if (googleUser != null) {
                                // Get the authentication credentials for the signed-in user
                                final GoogleSignInAuthentication googleAuth =
                                    await googleUser.authentication;

                                // Use the credentials to sign in with Firebase
                                final AuthCredential credential =
                                    GoogleAuthProvider.credential(
                                  accessToken: googleAuth.accessToken,
                                  idToken: googleAuth.idToken,
                                );
                                await FirebaseAuth.instance
                                    .signInWithCredential(credential);

                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const HomeScreen()),
                                );
                              }

                              // Hide the loading indicator
                              setState(() {
                                _isLoading = false;
                              });
                            } catch (e) {
                              // Handle any errors that occur during the sign-in flow
                              if (kDebugMode) {
                                print(e.toString());
                              }
                            }
                          },
                          child: Text(
                            "Sign In with Google",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: size.height / 52,
                              fontFamily: "Poppins",
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: size.height / 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.lock_outline_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Secure & private. No spam.",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: size.height / 58,
                          fontFamily: "Poppins",
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: size.height / 26,
                  )
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

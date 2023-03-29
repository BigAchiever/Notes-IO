// ignore_for_file: deprecated_member_use, duplicate_ignore
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ggits/funny_loading_animation.dart';
import 'package:ggits/faq.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ggits/authentication.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({Key? key}) : super(key: key);

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  bool _isAnimationComplete =
      false; // added boolean value to check animation completion

  @override
  void initState() {
    super.initState();
    _startAnimation(); // starting the animation
  }

  void _startAnimation() async {
    await Future.delayed(
        const Duration(milliseconds: 500)); // adding delay for animation
    setState(() {
      _isAnimationComplete =
          true; // setting boolean value to true after animation is complete
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Stack(
      children: [
        Positioned(
          width: MediaQuery.of(context).size.width * 1.7,
          left: 10,
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
        SizedBox(
          width: size.width / 1.4,
          child: Builder(
            builder: (BuildContext context) {
              return Drawer(
                backgroundColor: Colors.black87,
                child: _isAnimationComplete // checking if animation is complete
                    ? Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 16.0),
                                  child: Animate(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                          'assets/images/n.png',
                                          height: size.height / 10,
                                          width: size.width / 8,
                                        )
                                            .animate(
                                                onPlay: (controller) =>
                                                    controller.repeat())
                                            .shimmer(
                                                delay: 4000.ms,
                                                duration: 1800.ms) // shimmer +
                                            .shake(
                                                hz: 4,
                                                curve: Curves.easeInOutCubic),
                                        SizedBox(width: size.width / 24),
                                        const Text(
                                          'Notes.io',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const Text(
                                  'Your Ultimate Notes-Hub',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: size.height / 100),
                          Expanded(
                            child: ListView(
                              physics: const BouncingScrollPhysics(),
                              padding: EdgeInsets.zero,
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.home,
                                          color: Colors.white)
                                      .animate(delay: 400.milliseconds)
                                      .flipH(),
                                  title: const Text('Home',
                                      style: TextStyle(color: Colors.white)),
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                ),
                                ListTile(
                                  leading: SvgPicture.asset(
                                    'assets/images/fire.svg',
                                    height: 24,
                                    // ignore: deprecated_member_use
                                    color: Colors.white,
                                  ).animate(delay: 400.milliseconds).flipH(),
                                  title: const Text(
                                    'Contributions',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  onTap: () {},
                                ),
                                ListTile(
                                  leading: SvgPicture.asset(
                                    'assets/images/contact.svg',
                                    height: 24,
                                    color: Colors.white,
                                  ).animate(delay: 400.milliseconds).flipH(),
                                  title: const Text('Contact',
                                      style: TextStyle(color: Colors.white)),
                                  onTap: () async {
                                    String email = Uri.encodeComponent(
                                        "danishali9575@gmail.com");
                                    String subject = Uri.encodeComponent(
                                        "I wanted to give/ask you a suggestion/Question");
                                    String body =
                                        Uri.encodeComponent("Hello there!");
                                    if (kDebugMode) {
                                      print(subject);
                                    }
                                    Uri mail = Uri.parse(
                                        "mailto:$email?subject=$subject&body=$body");
                                    if (await launchUrl(mail)) {
                                      //email app opened
                                    } else {
                                      //email app is not opened
                                      const Text("Error Occured!");
                                    }
                                  },
                                ),
                                ListTile(
                                  leading: SvgPicture.asset(
                                    'assets/images/info.svg',
                                    height: 24,
                                    // ignore: deprecated_member_use
                                    color: Colors.white,
                                  ).animate(delay: 400.milliseconds).flipH(),
                                  title: const Text('FAQ',
                                      style: TextStyle(color: Colors.white)),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const FAQScreen(),
                                      ),
                                    );
                                  },
                                ),
                                ListTile(
                                  leading: SvgPicture.asset(
                                    'assets/images/admin.svg',
                                    height: 24,
                                    color: Colors.white,
                                  ).animate(delay: 400.milliseconds).flipH(),
                                  title: const Text(
                                    'Request for admin',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  onTap: () async {
                                    const url =
                                        'https://docs.google.com/forms/d/e/1FAIpQLSdBEFT5v-7922qYeG8s40GkTp9WY-FASA_MWFH8zo2mcGFAlQ/viewform?usp=sf_link';
                                    await launch(url);
                                  },
                                ),
                                ListTile(
                                  leading: SvgPicture.asset(
                                    'assets/images/upload.svg',
                                    height: 24,
                                    color: Colors.white,
                                  ).animate(delay: 400.milliseconds).flipH(),
                                  title: const Text(
                                    'Request To upload',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  onTap: () async {
                                    const url =
                                        'https://docs.google.com/forms/d/e/1FAIpQLSeQDB8mJzl5STr_QTOfpZVPNx-jEIAR9MtWrR4GMP-9LGO6Gw/viewform?usp=sf_link';
                                    await launch(url);
                                  },
                                ),
                                Container(
                                  height: size.height / 5.5,
                                ),
                                ListTile(
                                  leading: const Icon(Icons.update)
                                      .animate(delay: 400.milliseconds)
                                      .flipH(),
                                  title: const Text(
                                    'Check for updates',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  onTap: () async {
                                    const url =
                                        'https://drive.google.com/drive/folders/1iKPxfBRycO7Pl_gjBjmOCSbdr7qhJNSZ?usp=share_link';
                                    await launch(url);
                                  },
                                ),
                                ListTile(
                                  leading: SvgPicture.asset(
                                    'assets/images/logout.svg',
                                    height: 24,
                                    color: Colors.white,
                                  ).animate().flipH(delay: 400.milliseconds),
                                  title: const Text('Logout',
                                      style: TextStyle(color: Colors.white)),
                                  onTap: () async {
                                    Navigator.of(context)
                                        .pop(); // close the drawer
                                    await Future.delayed(const Duration(
                                        milliseconds:
                                            300)); // closing drawer with  delay
                                    // ignore: use_build_context_synchronously
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          backgroundColor: Colors.black87,
                                          title: const Text('Confirm Logout'),
                                          content: const Text(
                                              'Are you sure you are prepared for exam? 🙂'),
                                          actions: <Widget>[
                                            TextButton(
                                              child: const Text('CANCEL'),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                            TextButton(
                                              child: const Text('LOGOUT'),
                                              onPressed: () async {
                                                try {
                                                  // sign out from Firebase authentication
                                                  await FirebaseAuth.instance
                                                      .signOut();

                                                  // sign out from Google
                                                  await _googleSignIn.signOut();

                                                  // add a delay before navigating to the login screen
                                                  await Future.delayed(
                                                      const Duration(
                                                          milliseconds: 900));

                                                  // navigate to login page
                                                  Navigator.pushReplacement(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          const SignInScreen(),
                                                    ),
                                                  );

                                                  // Hide the loading indicator
                                                } catch (e) {
                                                  if (kDebugMode) {
                                                    print(e.toString());
                                                  }
                                                }
                                              },
                                            ),
                                          ],
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            side: const BorderSide(
                                              color: Colors.white10,
                                              width: 1.0,
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                                SizedBox(height: size.height / 22),
                                Container(
                                    alignment: Alignment.center,
                                    child: const Text(
                                      'Made with 💙',
                                      style: TextStyle(
                                          color: Colors.cyanAccent,
                                          fontSize: 16),
                                    )),
                              ],
                            ),
                          ),
                        ],
                      )
                    : Center(child: FunnyLoadingIndicator()),
              );
            },
          ),
        ),
      ],
    );
  }
}

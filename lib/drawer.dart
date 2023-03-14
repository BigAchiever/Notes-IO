import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ggits/authentication.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({Key? key}) : super(key: key);

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
          child: Drawer(
            backgroundColor: Colors.black87,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Animate(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
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
                                      curve: Curves.easeInOutCubic), // shake +

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
                    padding: EdgeInsets.zero,
                    children: [
                      Animate(
                        child: ListTile(
                          leading: const Icon(Icons.home, color: Colors.white)
                              .animate()
                              .flipH(delay: 300.ms, duration: 600.ms),
                          title: const Text('Home',
                              style: TextStyle(color: Colors.white)),
                          onTap: () {
                            // navigate to home page
                          },
                        ),
                      ),
                      Animate(
                        child: ListTile(
                          leading:
                              const Icon(Icons.favorite, color: Colors.white)
                                  .animate()
                                  .flipH(delay: 300.ms, duration: 600.ms),
                          title: const Text('Favorite',
                              style: TextStyle(color: Colors.white)),
                          onTap: () {
                            // navigate to home page
                          },
                        ),
                      ),
                      Animate(
                        child: ListTile(
                          leading: SvgPicture.asset(
                            'assets/images/fire.svg',
                            height: 24,
                            color: Colors.white,
                          ).animate().flipH(delay: 300.ms, duration: 600.ms),
                          title: const Text(
                            'Contributions',
                            style: TextStyle(color: Colors.white),
                          ),
                          onTap: () {
                            // navigate to home page
                          },
                        ),
                      ),
                      Animate(
                        child: ListTile(
                          leading: SvgPicture.asset(
                            'assets/images/contact.svg',
                            height: 24,
                            color: Colors.white,
                          ),
                          title: const Text('Contact',
                              style: TextStyle(color: Colors.white)),
                          onTap: () async {
                            String email =
                                Uri.encodeComponent("danishali9575@gmail.com");
                            String subject = Uri.encodeComponent(
                                "I wanted to give/ask you a suggestion/Question");
                            String body = Uri.encodeComponent("Hello there!");
                            print(subject);
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
                      ),
                      Animate(
                        child: ListTile(
                          leading: SvgPicture.asset(
                            'assets/images/info.svg',
                            height: 24,
                            color: Colors.white,
                          ).animate().flipH(delay: 300.ms, duration: 600.ms),
                          title: const Text('FAQ',
                              style: TextStyle(color: Colors.white)),
                          onTap: () {
                            // navigate to home page
                          },
                        ),
                      ),
                      SizedBox(height: size.height / 3.5),
                      Animate(
                        child: ListTile(
                          leading: SvgPicture.asset(
                            'assets/images/logout.svg',
                            height: 24,
                            color: Colors.white,
                          ).animate().flipH(delay: 300.ms, duration: 600.ms),
                          title: const Text('Logout',
                              style: TextStyle(color: Colors.white)),
                          onTap: () async {
                            try {
                              // sign out from Firebase authentication
                              await FirebaseAuth.instance.signOut();
                              // add a delay before navigating to the login screen
                              await Future.delayed(
                                  const Duration(milliseconds: 500));
                              // navigate to login page
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const SignInScreen()),
                              );
                            } catch (e) {
                              if (kDebugMode) {
                                print(e.toString());
                              }
                            }
                          },
                        ),
                      ),
                      SizedBox(height: size.height / 20),
                      Container(
                        alignment: Alignment.center,
                        child: const Text(
                          'Made with 💙',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

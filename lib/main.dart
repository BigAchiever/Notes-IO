import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ggits/no_internet.dart';
import 'package:ggits/authentication.dart';
import 'package:ggits/home_screen.dart';
import 'package:connectivity/connectivity.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, // transparent status bar
  ));

  // Checking if app has been updated
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final int? currentVersion = prefs.getInt('appVersion');
  final GoogleSignIn googleSignIn = GoogleSignIn();
  int newVersion = 1; // Change this to the new version number after each update
  final bool hasUpdated = currentVersion == null || currentVersion < newVersion;
  if (hasUpdated) {
    // Clearing cached data or preferences and sign user out
    await FirebaseAuth.instance.signOut();
    await googleSignIn.signOut();
    await prefs.clear();
    await prefs.setInt('appVersion', newVersion);
  }

  // Checking for internet connectivity
  final ConnectivityResult connectivityResult =
      await Connectivity().checkConnectivity();
  Widget homeScreen;

  if (connectivityResult == ConnectivityResult.none) {
    // Show no internet connection message
    homeScreen = const NoInternetScreen();
  } else {
    // Checking if user is already signed in
    final User? user = FirebaseAuth.instance.currentUser;

    // Routing to appropriate screen based on user authentication
    homeScreen = user == null ? const SignInScreen() : const HomeScreen();
  }

  // Delay the routing of the home screen for 3 seconds
  Future.delayed(const Duration(seconds: 3), () {
    runApp(MyApp(homeScreen: homeScreen));
  });
}

class MyApp extends StatelessWidget {
  final Widget homeScreen;
  const MyApp({Key? key, required this.homeScreen}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Lato',
      ),
      darkTheme: ThemeData.dark(),
      home: homeScreen,
    );
  }
}

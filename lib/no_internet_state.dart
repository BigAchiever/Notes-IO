import 'package:flutter/material.dart';

class NoInternetScreen extends StatelessWidget {
  const NoInternetScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, color: Colors.blue, size: 50),
            const SizedBox(height: 16),
            Text(
              'Wow! You have opened up a wonderful world\nby turning off your internet connection.',
              style: TextStyle(fontSize: 20, color: Colors.green.shade100),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

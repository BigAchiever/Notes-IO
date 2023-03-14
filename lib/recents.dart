import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class RecentsScreen extends StatelessWidget {
  const RecentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: const Text(
        "Coming soon...\nlike that overdue library book you\nthought to return last year.😷",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 20, color: Colors.cyan),
      ).animate().fadeIn(),
    );
  }
}

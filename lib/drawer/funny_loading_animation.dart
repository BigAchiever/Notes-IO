import 'package:flutter/material.dart';
import 'dart:math';

class FunnyLoadingIndicator extends StatefulWidget {
  @override
  _FunnyLoadingIndicatorState createState() => _FunnyLoadingIndicatorState();
}

class _FunnyLoadingIndicatorState extends State<FunnyLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotation;

  final List<String> emojis = [
    '🤪',
    '💀',
    '😜',
    '🙄',
    '🐼',
    '😁',
    '🤢',
    '🥵',
    '🤦‍♂️',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    )..repeat();
    _rotation = Tween(begin: 0.0, end: 2 * pi).animate(_controller);
  }

  @override
  Widget build(BuildContext context) {
    final Random random = Random();
    final int index = random.nextInt(emojis.length);
    final String emoji = emojis[index];

    return AnimatedBuilder(
      animation: _rotation,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 40),
            ),
            const SizedBox(width: 10),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

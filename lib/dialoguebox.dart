import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class CustomDialog extends StatefulWidget {
  final String title;
  final String message;
  final VoidCallback onPressed;

  const CustomDialog({
    Key? key,
    required this.title,
    required this.message,
    required this.onPressed,
  }) : super(key: key);

  @override
  State<CustomDialog> createState() => _CustomDialogState();
}

class _CustomDialogState extends State<CustomDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return ScaleTransition(
      scale: CurvedAnimation(parent: _controller, curve: Curves.bounceInOut),
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SizedBox(
          height: size.height / 1.4,
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.lightBlue.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        widget.title,
                        style: TextStyle(
                          color: Colors.lightBlue.shade100,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: size.height / 26),
                      Text(
                        widget.message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.blueGrey[190],
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(
                        height: size.height / 30,
                      ),
                      Center(
                        child: TextButton(
                          onPressed: widget.onPressed,
                          child: Text(
                            'Understood!',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 20,
                              shadows: [
                                Shadow(
                                  offset: const Offset(2, 3),
                                  blurRadius: 0,
                                  color: Colors.black.withOpacity(0.5),
                                ),
                              ],
                            ),
                          ),
                        )
                            .animate()
                            .scaleXY(duration: 3500.milliseconds)
                            .fadeIn(duration: 3000.milliseconds),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

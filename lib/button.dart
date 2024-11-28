import 'package:flutter/material.dart';

class GradientButton extends StatelessWidget {
  final String text;
  final List<Color> gradientColors;
  final VoidCallback onPressed;
  final double? height;
  final double? width;
  final double? fontSize;

  GradientButton({
    required this.text,
    required this.gradientColors,
    required this.onPressed,
    this.height,
    this.width,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 33,
        width: 75,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontSize: fontSize ?? 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 3),
            Icon(
              Icons.arrow_forward,
              color: Colors.white,
              size: 20, 
            ),
          ],
        ),
      ),
    );
  }
}

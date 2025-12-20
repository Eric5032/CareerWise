import 'package:flutter/material.dart';

class RoundRectButton extends StatelessWidget {
  final String buttonText;
  IconData? buttonIcon;
  Color color;
  VoidCallback? onPressed;
  RoundRectButton({
    super.key,
    required this.buttonText,
    this.buttonIcon,
    this.color = Colors.blue,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 30.0),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: (Colors.blue).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (buttonIcon == null)
                Icon(buttonIcon, color: Colors.white, size: 24),
                if (buttonIcon == null)
                const SizedBox(width: 12),
                Text(
                  buttonText,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

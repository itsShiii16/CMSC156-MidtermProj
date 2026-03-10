import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const ActionButton({super.key, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.navyButton,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 24, color: AppColors.whitePiece),
          ),
          const SizedBox(width: 16),
          const Icon(Icons.play_circle_fill, color: AppColors.whitePiece, size: 28),
        ],
      ),
    );
  }
}
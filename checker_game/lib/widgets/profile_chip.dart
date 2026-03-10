import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ProfileChip extends StatelessWidget {
  final String name;
  final bool isSmall;

  const ProfileChip({super.key, required this.name, this.isSmall = false});

  @override
  Widget build(BuildContext context) {
    if (isSmall) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            const CircleAvatar(
              backgroundColor: AppColors.softGray,
              radius: 12,
              child: Icon(Icons.person, size: 16, color: Colors.white),
            ),
            const SizedBox(width: 8),
            Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          color: Colors.white,
          child: const Icon(Icons.person, size: 40, color: AppColors.softGray),
        ),
        const SizedBox(width: 16),
        Text(name, style: const TextStyle(fontSize: 18)),
      ],
    );
  }
}
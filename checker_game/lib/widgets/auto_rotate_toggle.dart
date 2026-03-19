import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AutoRotateToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const AutoRotateToggle({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 72,
        height: 32,
        decoration: BoxDecoration(
          color: value ? AppColors.greenOn : AppColors.redOff,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            // The ON/OFF Text
            Align(
              alignment: value ? Alignment.centerRight : Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(
                  value ? 'ON' : 'OFF',
                  style: TextStyle(
                    color: value ? Colors.black : Colors.white, // White text reads better on the dark red
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            // The sliding grey circle
            AnimatedAlign(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              alignment: value ? Alignment.centerLeft : Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: Color(0xFFD9D9D9), // Light grey matching your image
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
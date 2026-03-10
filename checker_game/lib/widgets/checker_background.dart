import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'checker_board.dart';

class CheckerBackground extends StatelessWidget {
  const CheckerBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -math.pi / 12, // Tilts the board slightly counter-clockwise
      child: Container(
        width: 240, 
        height: 240,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(8, 8),
            ),
          ],
        ),
        // Reusing your CheckerBoard widget here
        child: const CheckerBoard(interactive: true),
      ),
    );
  }
}
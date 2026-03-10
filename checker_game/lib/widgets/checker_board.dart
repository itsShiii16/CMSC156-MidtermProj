import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CheckerBoard extends StatelessWidget {
  final bool interactive;
  const CheckerBoard({super.key, this.interactive = false});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 8,
      ),
      itemCount: 64,
      itemBuilder: (context, index) {
        int row = index ~/ 8;
        int col = index % 8;
        bool isDark = (row + col) % 2 == 1;
        
        Widget? piece;
        if (interactive) {
           if (isDark && row < 3) {
             piece = const CircleAvatar(backgroundColor: AppColors.blackPiece, radius: 14);
           } else if (isDark && row > 4) {
             piece = const CircleAvatar(backgroundColor: AppColors.whitePiece, radius: 14);
           }
        }

        return Container(
          color: isDark ? AppColors.boardDark : AppColors.boardLight,
          child: Center(child: piece),
        );
      },
    );
  }
}
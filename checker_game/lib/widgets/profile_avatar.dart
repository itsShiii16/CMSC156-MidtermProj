import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class ProfileAvatar extends StatelessWidget {
  final double size;
  final String heroTag;
  final VoidCallback? onTap;

  const ProfileAvatar({
    super.key,
    required this.size,
    required this.heroTag,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFF2E3138), AppColors.gold],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white.withOpacity(0.8), width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.person_rounded,
          size: size * 0.52,
          color: Colors.white,
        ),
      ),
    );

    final hero = Hero(
      tag: heroTag,
      flightShuttleBuilder: (
        flightContext,
        animation,
        flightDirection,
        fromHeroContext,
        toHeroContext,
      ) {
        final shuttle = flightDirection == HeroFlightDirection.push
            ? (toHeroContext.widget as Hero).child
            : (fromHeroContext.widget as Hero).child;

        return AnimatedBuilder(
          animation: animation,
          child: shuttle,
          builder: (context, child) {
            final eased = Curves.easeInOutCubic.transform(animation.value);
            return Transform.scale(
              scale: 0.92 + (0.08 * eased),
              child: child,
            );
          },
        );
      },
      child: avatar,
    );

    if (onTap == null) {
      return hero;
    }

    return Material(
      color: Colors.transparent,
      child: InkResponse(
        onTap: onTap,
        radius: size,
        splashColor: Colors.white24,
        highlightColor: Colors.white10,
        child: hero,
      ),
    );
  }
}
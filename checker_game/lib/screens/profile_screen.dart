import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/profile_avatar.dart';

class ProfileScreen extends StatelessWidget {
  final String heroTag;

  const ProfileScreen({super.key, required this.heroTag});

  static Route<void> route({required String heroTag}) {
    return PageRouteBuilder<void>(
      transitionDuration: const Duration(milliseconds: 520),
      reverseTransitionDuration: const Duration(milliseconds: 420),
      pageBuilder: (context, animation, secondaryAnimation) {
        return ProfileScreen(heroTag: heroTag);
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );

        return FadeTransition(
          opacity: curved,
          child: ClipPath(
            clipper: _RadialRevealClipper(
              progress: curved.value,
              alignment: Alignment.topRight,
            ),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.screenFrame),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Profile',
          style: TextStyle(
            color: AppColors.screenFrame,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.cream, Color(0xFFF7EFE4), AppColors.beige],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),
                Center(
                  child: ProfileAvatar(
                    size: 156,
                    heroTag: heroTag,
                  ),
                ),
                const SizedBox(height: 20),
                const Center(
                  child: Text(
                    'Board Strategist',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: AppColors.screenFrame,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'Pass-and-play profile for the current checkers session.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      color: AppColors.screenFrame.withOpacity(0.72),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                _ProfilePanel(
                  title: 'SESSION',
                  items: const [
                    _ProfileFact(
                      icon: Icons.sports_esports,
                      label: 'Mode',
                      value: 'Local multiplayer',
                    ),
                    _ProfileFact(
                      icon: Icons.grid_on,
                      label: 'Board',
                      value: 'Classic checkers',
                    ),
                    _ProfileFact(
                      icon: Icons.touch_app,
                      label: 'Controls',
                      value: 'Tap to move pieces',
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _ProfilePanel(
                  title: 'FOCUS',
                  items: const [
                    _ProfileFact(
                      icon: Icons.psychology,
                      label: 'Style',
                      value: 'Measured and tactical',
                    ),
                    _ProfileFact(
                      icon: Icons.bolt,
                      label: 'Pace',
                      value: 'Fast turns and clear moves',
                    ),
                    _ProfileFact(
                      icon: Icons.settings,
                      label: 'Settings',
                      value: 'Linked to the home screen',
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Return to home'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.navyButton,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
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

class _ProfilePanel extends StatelessWidget {
  final String title;
  final List<_ProfileFact> items;

  const _ProfilePanel({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.76),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.65)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 22,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.screenFrame.withOpacity(0.62),
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          ...items.expand((item) => [
                item,
                const SizedBox(height: 12),
              ]).toList()
            ..removeLast(),
        ],
      ),
    );
  }
}

class _ProfileFact extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileFact({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F1E8),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.gold.withOpacity(0.22),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.screenFrame),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.screenFrame.withOpacity(0.55),
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.screenFrame,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RadialRevealClipper extends CustomClipper<Path> {
  final double progress;
  final Alignment alignment;

  const _RadialRevealClipper({
    required this.progress,
    required this.alignment,
  });

  @override
  Path getClip(Size size) {
    final center = alignment.alongSize(size);
    final maxRadius = math.sqrt(size.width * size.width + size.height * size.height);
    final radius = maxRadius * progress;

    return Path()..addOval(Rect.fromCircle(center: center, radius: radius));
  }

  @override
  bool shouldReclip(covariant _RadialRevealClipper oldClipper) {
    return oldClipper.progress != progress || oldClipper.alignment != alignment;
  }
}
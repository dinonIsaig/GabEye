import 'package:flutter/material.dart';

// Gabeye Header for Color Vision Profile 
class ProfileHeadingBanner extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;
  final bool showBackButton;

  const ProfileHeadingBanner({
    super.key,
    this.title = 'Color Vision Profile',
    this.onBack,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
        child: SizedBox(
          width: double.infinity,
          height: 140,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset('assets/images/articleHeading.png', fit: BoxFit.cover),
              if (showBackButton || onBack != null)
                Positioned(
                  top: 12,
                  left: 12,
                  child: SafeArea(
                    bottom: false,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: onBack ?? () => Navigator.of(context).maybePop(),
                      tooltip: 'Back',
                    ),
                  ),
                ),
              Positioned(
                left: 20,
                right: 20,
                bottom: 16,
                child: Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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

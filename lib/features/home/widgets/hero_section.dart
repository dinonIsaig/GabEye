import 'package:flutter/material.dart';
import 'package:gabeye/core/theme/app_colors.dart';

class HeroSection extends StatelessWidget {
  final VoidCallback? onKnowMoreTap;

  const HeroSection({super.key, this.onKnowMoreTap});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 260,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Decorative background — real text below carries the message,
            // so this image is excluded from the accessibility tree to avoid
            // a screen reader announcing an unlabeled image on top of the text.
            Image.asset(
              'assets/images/gabeye_hero_header.png',
              fit: BoxFit.cover,
              excludeFromSemantics: true,
              errorBuilder: (context, error, stackTrace) => Image.asset(
                'assets/images/hompage_header.png',
                fit: BoxFit.cover,
                excludeFromSemantics: true,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: AppColors.deepNavy,
                ),
              ),
            ),
            // Scrim: guarantees the white overlay text still meets contrast
            // requirements against the image regardless of its brightness.
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Colors.black54, Colors.transparent],
                  stops: [0.0, 0.7],
                ),
              ),
            ),
            Positioned(
              left: 24,
              top: 0,
              bottom: 0,
              right: 24, // was 140 — only the top title/tagline need to dodge the phone mockup, not the button
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 220),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Semantics(
                          header: true,
                          child: Text(
                            'GabEye',
                            style: Theme.of(context).textTheme.headlineMedium ??
                                const TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 28,
                                  color: Colors.white,
                                ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'A Mobile Application Aid for Color Vision Deficiency (CVD)',
                          style: TextStyle(
                            fontFamily: 'AtkinsonHyperlegible',
                            color: Colors.white,
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Semantics(
                    button: true,
                    label: 'Know more about GabEye',
                    child: IntrinsicWidth(
                      child: InkWell(
                        onTap: onKnowMoreTap ??
                            () => Navigator.pushNamed(context, '/article'),
                        borderRadius: BorderRadius.circular(9999),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(9999),
                            border: Border.all(color: const Color(0xFF323838)),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Know More About GabEye',
                                softWrap: false,
                                overflow: TextOverflow.visible,
                                maxLines: 1,
                                style: TextStyle(
                                  fontFamily: 'AtkinsonHyperlegible',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: AppColors.mutedAccent,
                                ),
                              ),
                              SizedBox(width: 6),
                              Icon(
                                Icons.arrow_forward,
                                size: 16,
                                color: AppColors.mutedAccent,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

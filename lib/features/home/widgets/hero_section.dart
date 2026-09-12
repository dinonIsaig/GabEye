import 'package:flutter/material.dart';
import 'package:gabeye/core/theme/app_colors.dart';
import 'package:gabeye/core/utils/responsive.dart';

class HeroSection extends StatelessWidget {
  final VoidCallback? onKnowMoreTap;

  const HeroSection({super.key, this.onKnowMoreTap});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: Responsive.space(context, base: 270, min: 240, max: 320),
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
              left: Responsive.space(context, base: 24, min: 16, max: 32),
              top: 0,
              bottom: 0,
              right: Responsive.space(context, base: 24, min: 16, max: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 250),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Semantics(
                          header: true,
                          child: Text(
                            'GabEye',
                            style: (Theme.of(context).textTheme.headlineMedium ??
                                    const TextStyle(
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.bold,
                                    ))
                                .copyWith(
                              fontSize: Responsive.font(context, base: 34, min: 26, max: 40),
                              height: 1.2,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(height: Responsive.space(context, base: 6, min: 4, max: 8)),
                        Text(
                          'A Mobile Application Aid for Color Vision Deficiency (CVD)',
                          style: TextStyle(
                            fontFamily: 'AtkinsonHyperlegible',
                            color: Colors.white,
                            fontSize: Responsive.font(context, base: 16, min: 13, max: 18),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: Responsive.space(context, base: 16, min: 10, max: 20)),
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
                          padding: Responsive.symmetricH(context, base: 20, min: 14, max: 24)
                              .copyWith(
                                top: Responsive.space(context, base: 12, min: 8, max: 14),
                                bottom: Responsive.space(context, base: 12, min: 8, max: 14),
                              ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  'Know More About GabEye',
                                  softWrap: false,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontFamily: 'AtkinsonHyperlegible',
                                    fontWeight: FontWeight.bold,
                                    fontSize: Responsive.font(context, base: 16, min: 13, max: 18),
                                    color: AppColors.mutedAccent,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
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

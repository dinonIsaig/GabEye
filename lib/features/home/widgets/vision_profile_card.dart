import 'package:flutter/material.dart';
import 'package:gabeye/core/theme/app_colors.dart';
import 'package:gabeye/core/utils/responsive.dart';

class VisionProfileData {
  final String title;
  final String description;
  final String imageAsset;
  final String ctaLabel;
  final void Function(BuildContext context) onReadMore;

  const VisionProfileData({
    required this.title,
    required this.description,
    required this.imageAsset,
    required this.ctaLabel,
    required this.onReadMore,
  });
}

class VisionProfileCard extends StatelessWidget {
  final VisionProfileData data;

  const VisionProfileCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final imageH = Responsive.space(context, base: 145, min: 130, max: 155);

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder.withValues(alpha: isDark ? 0.4 : 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            child: Image.asset(
              data.imageAsset,
              height: imageH,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: imageH,
                color: isDark ? AppColors.darkSurface : AppColors.altLightSurface,
                alignment: Alignment.center,
                child: Icon(Icons.palette_outlined, size: 48, color: colorScheme.onSurfaceVariant),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        theme.textTheme.headlineSmall?.copyWith(
                          fontSize: Responsive.font(context, base: 22, min: 18, max: 24),
                          fontWeight: FontWeight.bold,
                        ) ??
                        TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.bold,
                          fontSize: Responsive.font(context, base: 22, min: 18, max: 24),
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    data.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style:
                        theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: Responsive.font(context, base: 16, min: 14, max: 18),
                          height: 1.5,
                        ) ??
                        TextStyle(
                          fontFamily: 'Inter',
                          fontSize: Responsive.font(context, base: 16, min: 14, max: 18),
                          color: colorScheme.onSurfaceVariant,
                          height: 1.5,
                        ),
                  ),
                  // Pushes the button to the bottom so CTAs line up across cards
                  // of different description lengths.
                  const Spacer(),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      // The theme's 14px vertical padding leaves too little room for
                      // the label at 44px, clipping it. Use a min height instead of a
                      // fixed one so the button grows with the system font scale.
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(44),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      onPressed: () => data.onReadMore(context),
                      child: Semantics(
                        // Screen readers announce the destination, not just "Read more" —
                        // important when several cards in the same slider share that label.
                        label: '${data.ctaLabel}: ${data.title}',
                        excludeSemantics: true,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              data.ctaLabel,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.arrow_forward, size: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

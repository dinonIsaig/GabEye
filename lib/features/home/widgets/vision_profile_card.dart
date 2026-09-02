import 'package:flutter/material.dart';
import 'package:gabeye/core/theme/app_colors.dart';

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

    return Container(
      width: 291,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.cardBorder.withValues(alpha: isDark ? 0.4 : 0.6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.asset(
              data.imageAsset,
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 160,
                color: isDark ? AppColors.darkSurface : AppColors.altLightSurface,
                alignment: Alignment.center,
                child: Icon(
                  Icons.palette_outlined,
                  size: 48,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.headlineSmall ??
                      const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  data.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.normal,
                      ) ??
                      TextStyle(
                        fontFamily: 'AtkinsonHyperlegible',
                        fontSize: 16,
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: FilledButton(
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
        ],
      ),
    );
  }
}

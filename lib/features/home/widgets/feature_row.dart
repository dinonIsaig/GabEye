import 'package:flutter/material.dart';
import 'package:gabeye/core/theme/app_colors.dart';

class FeatureRowData {
  final IconData icon;
  final String title;
  final List<String> bullets;
  final String ctaLabel;
  final VoidCallback? onCtaPressed;

  const FeatureRowData({
    required this.icon,
    required this.title,
    required this.bullets,
    required this.ctaLabel,
    this.onCtaPressed,
  });
}

class FeatureRow extends StatelessWidget {
  final FeatureRowData data;

  const FeatureRow({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.cardBorder.withValues(alpha: isDark ? 0.4 : 0.6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkPrimaryButton.withValues(alpha: 0.15)
                      : AppColors.iconChipTint,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Icon(
                  data.icon,
                  color: isDark
                      ? AppColors.darkPrimaryButton
                      : AppColors.deepNavy,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  data.title,
                  style: theme.textTheme.titleMedium ??
                      const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...data.bullets.map(
            (b) => Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '•  ',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      b,
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
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: FilledButton(
              onPressed: data.onCtaPressed ?? () {},
              child: Text(
                data.ctaLabel,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

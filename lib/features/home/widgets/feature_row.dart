import 'package:flutter/material.dart';
import 'package:gabeye/core/theme/app_colors.dart';
import 'package:gabeye/core/utils/responsive.dart';

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
      padding: Responsive.all(context, base: 17, min: 12, max: 22),
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: Responsive.space(context, base: 36, min: 30, max: 42),
                height: Responsive.space(context, base: 46, min: 38, max: 52),
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
              SizedBox(width: Responsive.space(context, base: 10, min: 6, max: 14)),
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    data.title,
                    textAlign: TextAlign.left,
                    style: (theme.textTheme.titleMedium ??
                            const TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.bold,
                            ))
                        .copyWith(
                          fontSize: Responsive.font(context, base: 16, min: 14, max: 18),
                        ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: Responsive.space(context, base: 12, min: 8, max: 16)),
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
                      fontSize: Responsive.font(context, base: 16, min: 13, max: 18),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      b,
                      style: (theme.textTheme.bodyLarge ??
                              const TextStyle(
                                fontFamily: 'AtkinsonHyperlegible',
                              ))
                          .copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.normal,
                            fontSize: Responsive.font(context, base: 16, min: 13, max: 18),
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: Responsive.space(context, base: 12, min: 8, max: 16)),
          SizedBox(
            width: double.infinity,
            height: Responsive.space(context, base: 44, min: 40, max: 52),
            child: FilledButton(
              onPressed: data.onCtaPressed ?? () {},
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  data.ctaLabel,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    fontSize: Responsive.font(context, base: 16, min: 14, max: 18),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

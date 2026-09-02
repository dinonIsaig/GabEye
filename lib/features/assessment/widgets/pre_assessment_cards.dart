import 'package:flutter/material.dart';

class PreAssessmentStepCard extends StatelessWidget {
  final int stepNumber;
  final String normalTextBefore;
  final String boldText;
  final String normalTextAfter;

  const PreAssessmentStepCard({
    super.key,
    required this.stepNumber,
    required this.boldText,
    this.normalTextBefore = '',
    this.normalTextAfter = '',
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 44,
                color: Theme.of(context).colorScheme.tertiary,
                alignment: Alignment.center,
                child: Text(
                  '$stepNumber',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.surface,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25,
                    vertical: 14,
                  ),
                  child: Text.rich(
                    TextSpan(
                      style: textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        height: 1.50,
                      ),
                      children: [
                        TextSpan(text: normalTextBefore),
                        TextSpan(
                          text: boldText,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: normalTextAfter),
                      ],
                    ),
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

class PreAssessmentInfoCard extends StatelessWidget {
  final String title;
  final String boldText;
  final String normalTextBefore;
  final String normalTextAfter;
  final Color headerColor;
  final Widget iconWidget;

  const PreAssessmentInfoCard({
    super.key,
    required this.title,
    required this.headerColor,
    required this.iconWidget,
    required this.boldText,
    this.normalTextBefore = '',
    this.normalTextAfter = '',
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: headerColor,
              child: Row(
                children: [
                  iconWidget,
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text.rich(
                TextSpan(
                  style: textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    height: 1.45,
                  ),
                  children: [
                    TextSpan(text: normalTextBefore),
                    TextSpan(
                      text: boldText,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: normalTextAfter),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PreAssessmentArticleCard extends StatelessWidget {
  final String imagePath;
  final String subtitle;
  final String title;
  final String description;
  final VoidCallback? onReadMore;

  const PreAssessmentArticleCard({
    super.key,
    required this.imagePath,
    required this.subtitle,
    required this.title,
    required this.description,
    this.onReadMore,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 150,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Image.asset(
                      imagePath,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Text(
                      subtitle,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.titleLarge?.copyWith(
                      fontFamily: 'Inter',
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    description,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        side: BorderSide(color: colorScheme.outline, width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      onPressed: onReadMore,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Read More',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Icon(
                            Icons.help_outline_rounded,
                            size: 18,
                          ),
                        ],
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
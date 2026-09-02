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
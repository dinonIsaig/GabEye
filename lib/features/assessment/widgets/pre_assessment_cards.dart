import 'package:flutter/material.dart';
import 'package:gabeye/core/utils/responsive.dart';
import 'package:google_fonts/google_fonts.dart';

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
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Text.rich(
                    TextSpan(
                      style: textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
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
              width: double.infinity,
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subtitle,
                    style: GoogleFonts.atkinsonHyperlegibleNext(
                      fontSize: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: Responsive.space(context, base: 4, min: 2, max: 8)),
                  Text(
                    title,
                      style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: Responsive.font(context, base: 16, min: 14, max: 20),
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: GoogleFonts.atkinsonHyperlegibleNext(
                      fontSize: Responsive.font(context, base: 16, min: 14, max: 18),
                      color: colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 16),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        side: BorderSide(
                          color: colorScheme.outline, 
                          width: 1,
                        ),
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
                              fontSize: Responsive.font(context, base: 12, min: 10, max: 16),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Icon(
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
import 'package:flutter/material.dart';
import 'package:gabeye/components/navbar/article_navbar.dart';
import 'package:gabeye/core/theme/app_colors.dart';
import 'package:gabeye/features/assessment/widgets/pre_assessment_hero_header.dart';

import 'gabeye_settings.dart';
import 'help_feedback_screen.dart';

class _StepItem {
  const _StepItem({required this.title, required this.text});

  final String title;
  final String text;
}

class _ModeRow {
  const _ModeRow({
    required this.label,
    required this.realTime,
    required this.static_,
  });

  final String label;
  final String realTime;
  final String static_;
}

class HowToUseGabEyeScreen extends StatelessWidget {
  const HowToUseGabEyeScreen({super.key});

  static const _steps = <_StepItem>[
    _StepItem(
      title: 'Take the Pre-Assessment',
      text:
          'Sort 15 color discs so GabEye can identify your CVD type: Protan, Deutan, or Tritan.',
    ),
    _StepItem(
      title: 'Get Your Personalized Theme',
      text:
          'GabEye applies a Red-Green or Blue-Yellow safe color theme based on your result.',
    ),
    _StepItem(
      title: 'Choose Real-Time or Static Mode',
      text:
          'Point your camera at your surroundings, or import a photo from your gallery.',
    ),
    _StepItem(
      title: 'Listen to Audio Feedback',
      text:
          'GabEye speaks detected colors, objects, and text out loud as it processes.',
    ),
  ];

  static const _modeRows = <_ModeRow>[
    _ModeRow(
      label: 'What it uses',
      realTime: 'Live camera feed',
      static_: 'A photo you import',
    ),
    _ModeRow(
      label: 'Best for',
      realTime: 'Colors right in front of you',
      static_: 'Recoloring and describing saved photos',
    ),
  ];

  static const _tips = <String>[
    'Use good, even lighting when possible.',
    'Hold the camera steady for a few seconds.',
    'Import clear, well-lit photos for the best recoloring.',
    'Update your CVD type anytime from Settings.',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: GabEyeArticleNavbar(
          title: 'How to Use GabEye',
          onBack: () => Navigator.maybePop(context),
          onMenuSelected: (option) {
            if (option.label == 'How to Use GabEye') {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Already on How to Use GabEye')),
              );
            } else if (option.label == 'Settings') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const GabEyeSettingsScreen(),
                ),
              );
            } else if (option.label == 'Help & Feedback') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HelpFeedbackScreen(),
                ),
              );
            } else if (option.label == 'About GabEye') {
              Navigator.pushNamed(context, '/article');
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const PreAssessmentHeroHeader(title: 'How to Use GabEye'),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                ),
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _intro(context),
                        const SizedBox(height: 24),
                        _sectionTitle(context, 'Your Walkthrough'),
                        const SizedBox(height: 12),
                        _WalkthroughCard(steps: _steps),
                        const SizedBox(height: 24),
                        _sectionTitle(
                          context,
                          'Real-Time vs. Static: Which Mode?',
                        ),
                        const SizedBox(height: 12),
                        _ModeCompareTable(rows: _modeRows),
                        const SizedBox(height: 12),
                        Text(
                          'Color correction and audio feedback work offline. Scene descriptions may need a connection.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                fontSize: 16,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                                height: 1.5,
                              ),
                        ),
                        const SizedBox(height: 24),
                        _sectionTitle(context, 'Tips for Best Results'),
                        const SizedBox(height: 12),
                        _TipsCard(tips: _tips),
                        const SizedBox(height: 12),
                        const _NoteCard(
                          title: 'Need a Refresher?',
                          text:
                              'You can retake the pre-assessment anytime from Settings.',
                        ),
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

  Widget _intro(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Getting Started',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : AppColors.primaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        "GabEye adapts to how you see color. Here's how to get set up and start using it.",
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    ],
  );

  Widget _sectionTitle(BuildContext context, String title) => Text(
    title,
    style: Theme.of(context).textTheme.titleMedium?.copyWith(
      color: Theme.of(context).brightness == Brightness.dark
          ? Colors.white
          : AppColors.primaryColor,
      fontWeight: FontWeight.bold,
    ),
  );
}

class _WalkthroughCard extends StatelessWidget {
  const _WalkthroughCard({required this.steps});

  final List<_StepItem> steps;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < steps.length; i++)
          _StepCard(
            stepNumber: i + 1,
            title: steps[i].title,
            text: steps[i].text,
          ),
      ],
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.stepNumber,
    required this.title,
    required this.text,
  });

  final int stepNumber;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.primary.withValues(alpha: .15),
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
                color: colors.tertiary,
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
                    horizontal: 20,
                    vertical: 14,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: textTheme.bodyLarge?.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        text,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colors.onSurface,
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                    ],
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

class _ModeCompareTable extends StatelessWidget {
  const _ModeCompareTable({required this.rows});

  final List<_ModeRow> rows;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final borderColor = colors.primary.withValues(alpha: .15);
    final headerColor = colors.primary.withValues(alpha: .08);

    TableRow buildRow(String label, String real, String stat, {bool header = false}) {
      final style = (Theme.of(context).textTheme.bodyMedium ??
              const TextStyle(
                fontFamily: 'AtkinsonHyperlegible',
                fontSize: 16,
              ))
          .copyWith(
            fontSize: 16,
            color: colors.onSurface,
            fontWeight: header ? FontWeight.bold : FontWeight.normal,
            height: 1.4,
          );

      return TableRow(
        decoration: BoxDecoration(color: header ? headerColor : null),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Text(label, style: style),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Text(real, style: style),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Text(stat, style: style),
          ),
        ],
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Table(
          columnWidths: const {
            0: FlexColumnWidth(0.9),
            1: FlexColumnWidth(1.1),
            2: FlexColumnWidth(1.1),
          },
          border: TableBorder(horizontalInside: BorderSide(color: borderColor)),
          children: [
            buildRow('', 'Real-Time Mode', 'Static Mode', header: true),
            for (final row in rows) buildRow(row.label, row.realTime, row.static_),
          ],
        ),
      ),
    );
  }
}

class _TipsCard extends StatelessWidget {
  const _TipsCard({required this.tips});

  final List<String> tips;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final iconColor = Theme.of(context).brightness == Brightness.dark
        ? AppColors.darkPrimaryButton
        : AppColors.primaryColor;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.primary.withValues(alpha: .15)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          children: tips
              .map(
                (tip) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.check_circle_outline, color: iconColor, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          tip,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colors.onSurface,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({required this.title, required this.text, this.isRed = false});

  final String title;
  final String text;
  final bool isRed;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final useRed = isRed || title.toLowerCase() == 'remember';
    final accent = useRed
        ? (isDark ? const Color(0xFFFFB4AB) : AppColors.errorRed)
        : (isDark ? AppColors.darkPrimaryButton : AppColors.primaryColor);
    final bg = useRed
        ? (isDark
            ? AppColors.errorRed.withValues(alpha: 0.18)
            : AppColors.errorRed.withValues(alpha: 0.08))
        : Theme.of(context).colorScheme.primary.withValues(alpha: .12);
    final border = useRed
        ? Border.all(
            color: isDark
                ? const Color(0xFFFFB4AB).withValues(alpha: 0.35)
                : AppColors.errorRed.withValues(alpha: 0.25),
          )
        : null;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: border,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: accent, size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: isDark && !useRed ? Colors.white : accent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  text,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    height: 1.6,
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
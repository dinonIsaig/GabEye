import 'package:flutter/material.dart';
import 'package:gabeye/components/navbar/article_navbar.dart';
import 'package:gabeye/core/theme/app_colors.dart';
import 'package:gabeye/features/assessment/widgets/pre_assessment_hero_header.dart';

import 'gabeye_settings.dart';
import 'help_feedback_screen.dart';

class RealTimeModeSafetyScreen extends StatelessWidget {
  const RealTimeModeSafetyScreen({super.key});

  static const _doItems = <String>[
    'Sit or stand still while using real-time mode.',
    'Use it in a well-lit space.',
    'Pause the camera before checking results closely.',
  ];

  static const _dontItems = <String>[
    "Don't use real-time mode while walking or driving.",
    "Don't rely on it for traffic lights or crossing roads.",
    "Don't expect accurate colors in very dim or very bright light.",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: GabEyeArticleNavbar(
          title: 'Real-time Mode Safety',
          onBack: () => Navigator.maybePop(context),
          onMenuSelected: (option) {
            if (option.label == 'Real-time Mode Safety') {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Already on Real-time Mode Safety'),
                ),
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
              const PreAssessmentHeroHeader(title: 'Real-time Mode Safety'),
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
                        const _WarningCard(
                          title: 'Built for Stationary Use',
                          text:
                              'GabEye is designed for tasks where you can pause and stay still, not for walking or moving around.',
                        ),
                        const SizedBox(height: 24),
                        _sectionTitle(context, 'Do'),
                        const SizedBox(height: 12),
                        _ChecklistCard(items: _doItems, isPositive: true),
                        const SizedBox(height: 20),
                        _sectionTitle(context, "Don't"),
                        const SizedBox(height: 12),
                        _ChecklistCard(items: _dontItems, isPositive: false),
                        const SizedBox(height: 24),
                        _sectionTitle(context, 'Why Lighting Matters'),
                        const SizedBox(height: 12),
                        Text(
                          'GabEye processes color using HSV, which handles lighting changes better than RGB. Extreme lighting can still reduce accuracy.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                                height: 1.6,
                              ),
                        ),
                        const SizedBox(height: 24),
                        const _NoteCard(
                          title: 'Remember',
                          text:
                              "GabEye assists your color perception. It doesn't replace caution, sighted assistance, or mobility aids when needed.",
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
        'What Is Real-Time Mode?',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : AppColors.primaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        'Real-time mode uses your camera to identify colors and objects around you as you point it.',
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

class _WarningCard extends StatelessWidget {
  const _WarningCard({required this.title, required this.text});

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    const accent = Colors.orange;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: .3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Colors.orange,
            size: 28,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  text,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colors.onSurface,
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

class _ChecklistCard extends StatelessWidget {
  const _ChecklistCard({required this.items, required this.isPositive});

  final List<String> items;
  final bool isPositive;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final accent = isPositive ? Colors.green.shade600 : Colors.red.shade600;
    final icon = isPositive ? Icons.check_circle : Icons.cancel;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.primary.withValues(alpha: .15)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          children: items
              .map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(icon, color: accent, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          item,
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
  const _NoteCard({required this.title, required this.text});

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentRed = isDark ? const Color(0xFFFFB4AB) : AppColors.errorRed;
    final bgRed = isDark
        ? AppColors.errorRed.withValues(alpha: 0.18)
        : AppColors.errorRed.withValues(alpha: 0.08);
    final borderRed = isDark
        ? const Color(0xFFFFB4AB).withValues(alpha: 0.35)
        : AppColors.errorRed.withValues(alpha: 0.25);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: bgRed,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderRed),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: accentRed, size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: accentRed,
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
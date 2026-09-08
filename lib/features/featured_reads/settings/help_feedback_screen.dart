import 'package:flutter/material.dart';
import 'package:gabeye/components/navbar/article_navbar.dart';
import 'package:gabeye/core/constants/app_spacing.dart';
import 'package:gabeye/core/routing/app_routes.dart';
import 'package:gabeye/core/theme/app_colors.dart';
import 'package:gabeye/features/assessment/widgets/pre_assessment_hero_header.dart';

class TroubleshootingItem {
  const TroubleshootingItem({
    required this.title,
    required this.steps,
    this.note,
    this.actionLabel,
  });

  final String title;
  final List<String> steps;
  final String? note;
  final String? actionLabel;
}

class HelpFeedbackScreen extends StatelessWidget {
  const HelpFeedbackScreen({super.key});
  static const _quickHelp = <({IconData icon, String title, String text})>[
    (
      icon: Icons.colorize_outlined,
      title: 'Identify a Color',
      text:
          'Use GabEye to help identify a color that is difficult to distinguish.',
    ),
    (
      icon: Icons.center_focus_strong_outlined,
      title: 'Recognizing Objects',
      text:
          'Use object recognition when you need help understanding what is in front of the camera.',
    ),
    (
      icon: Icons.volume_up_outlined,
      title: 'Spoken Feedback',
      text:
          'Listen to information instead of relying only on what appears on the screen.',
    ),
    (
      icon: Icons.tune_outlined,
      title: 'Color Remapping',
      text:
          'Adjust difficult colors so visual information may be easier to distinguish.',
    ),
  ];

  static const _troubleshooting = <TroubleshootingItem>[
    TroubleshootingItem(
      title: 'Camera is not working',
      steps: [
        'Check that GabEye has permission to use your camera.',
        'Close and reopen the camera feature.',
        'Restart the application if the problem continues.',
      ],
      actionLabel: 'Check Camera Permission',
    ),
    TroubleshootingItem(
      title: 'Object is not being recognized',
      steps: [
        'Keep the entire object visible.',
        'Move distracting objects away if possible.',
        'Try another angle.',
        'Improve the lighting.',
      ],
    ),
    TroubleshootingItem(
      title: 'Spoken feedback cannot be heard',
      steps: [
        'Increase the device volume.',
        'Check whether the phone is muted.',
        'Try spoken feedback again.',
      ],
    ),
    TroubleshootingItem(
      title: 'Color results seem inaccurate',
      steps: [
        'Scan the color under more neutral lighting.',
        'Avoid strong shadows.',
        'Avoid reflections or glare.',
        'Move the camera closer.',
        'Scan the color again.',
      ],
      note:
          'Lighting and camera conditions can affect how colors appear to the application.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: GabEyeArticleNavbar(
          title: 'Help & Feedback',
          onBack: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.home,
                (route) => false,
              );
            }
          },
          onMenuSelected: (option) {
            if (option.label == 'Help & Feedback') {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Already on Help & Feedback')),
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
              const PreAssessmentHeroHeader(title: 'Help & Feedback'),
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
                              const SizedBox(height: AppSpacing.sectionSpacing),
                              _sectionTitle(
                                context,
                                'What do you need help with?',
                              ),
                              const SizedBox(height: AppSpacing.itemSpacing),
                              ..._quickHelp.map(
                                (item) => Padding(
                                  padding: const EdgeInsets.only(bottom: AppSpacing.itemSpacing),
                                  child: _QuickHelpTile(item: item),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sectionSpacing - AppSpacing.itemSpacing),
                              _sectionTitle(context, 'Quick Troubleshooting'),
                              const SizedBox(height: AppSpacing.itemSpacing),
                              ..._troubleshooting.map(
                                (item) => Padding(
                                  padding: const EdgeInsets.only(bottom: AppSpacing.itemSpacing),
                                  child: _TroubleshootingTile(item: item),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sectionSpacing - AppSpacing.itemSpacing),
                              const _ImportantInformationCard(),
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
        'Need help with GabEye?',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : AppColors.primaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        'Find quick answers, fix common problems, or send us feedback about your experience with GabEye.',
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

class _QuickHelpTile extends StatelessWidget {
  const _QuickHelpTile({required this.item});

  final ({IconData icon, String title, String text}) item;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final iconColor = Theme.of(context).brightness == Brightness.dark
        ? AppColors.darkPrimaryButton
        : AppColors.primaryColor;
    final arrowColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : AppColors.primaryColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Semantics(
      button: true,
      label: '${item.title}. ${item.text}',
      child: Material(
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.35)
                : AppColors.primaryNavy.withValues(alpha: 0.45),
            width: 1.2,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => showDialog<void>(
            context: context,
            barrierColor: Colors.black.withValues(alpha: 0.65),
            builder: (dialogContext) {
              final isDark =
                  Theme.of(dialogContext).brightness == Brightness.dark;

              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                icon: Icon(
                  item.icon,
                  color: isDark ? AppColors.darkPrimaryButton : colors.primary,
                  size: 28,
                ),
                title: Text(
                  item.title,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: colors.onSurface,
                  ),
                ),
                content: Text(
                  item.text,
                  style: TextStyle(
                    fontFamily: 'AtkinsonHyperlegible',
                    fontSize: 16,
                    height: 1.5,
                    color: colors.onSurfaceVariant,
                  ),
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark
                          ? AppColors.darkPrimaryButton
                          : AppColors.lightPrimaryButton,
                      foregroundColor:
                          isDark ? AppColors.darkSurface : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      'Done',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(item.icon, color: iconColor, size: 24),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.text,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colors.onSurface,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.arrow_forward_ios, color: arrowColor, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TroubleshootingTile extends StatelessWidget {
  const _TroubleshootingTile({required this.item});

  final TroubleshootingItem item;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final iconColor = Theme.of(context).brightness == Brightness.dark
        ? AppColors.darkPrimaryButton
        : AppColors.primaryColor;
    final arrowColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : AppColors.primaryColor;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Semantics(
      button: true,
      label: item.title,
      child: Material(
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.35)
                : AppColors.primaryNavy.withValues(alpha: 0.45),
            width: 1.2,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => showDialog<void>(
            context: context,
            barrierColor: Colors.black.withValues(alpha: 0.65),
            builder: (dialogContext) {
              final isDark =
                  Theme.of(dialogContext).brightness == Brightness.dark;

              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                icon: Icon(
                  Icons.build_outlined,
                  color: isDark ? AppColors.darkPrimaryButton : colors.primary,
                  size: 28,
                ),
                title: Text(
                  item.title,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: colors.onSurface,
                  ),
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Try this:',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          color: colors.onSurface,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...item.steps.indexed.map(
                        (entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 24,
                                child: Text(
                                  '${entry.$1 + 1}.',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  entry.$2,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: colors.onSurface,
                                        fontSize: 16,
                                        height: 1.5,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (item.note != null) ...[
                        const SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.info_outline, size: 20, color: iconColor),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                item.note!,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: colors.onSurface,
                                      fontSize: 16,
                                      height: 1.5,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                actions: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (item.actionLabel != null) ...[
                        OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(dialogContext);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Open Settings, then allow Camera access for GabEye.',
                                ),
                              ),
                            );
                          },
                          icon: Icon(
                            Icons.settings_outlined,
                            size: 18,
                            color: isDark
                                ? AppColors.darkSurface
                                : AppColors.lightPrimaryButton,
                          ),
                          label: Text(
                            item.actionLabel!,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppColors.darkSurface
                                  : AppColors.lightPrimaryButton,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: isDark
                                ? AppColors.darkSurface
                                : AppColors.lightPrimaryButton,
                            backgroundColor: isDark
                                ? AppColors.darkPrimaryButton
                                : Colors.transparent,
                            side: isDark
                                ? BorderSide.none
                                : const BorderSide(
                                    color: AppColors.lightPrimaryButton,
                                    width: 1.5,
                                  ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      ElevatedButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark
                              ? AppColors.darkPrimaryButton
                              : AppColors.lightPrimaryButton,
                          foregroundColor:
                              isDark ? AppColors.darkSurface : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                        ),
                        child: const Text(
                          'Done',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(Icons.build_outlined, color: iconColor, size: 24),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    item.title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.arrow_forward_ios, color: arrowColor, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ImportantInformationCard extends StatelessWidget {
  const _ImportantInformationCard();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final iconColor = Theme.of(context).brightness == Brightness.dark
        ? AppColors.darkPrimaryButton
        : AppColors.primaryColor;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: iconColor, size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Keep in Mind',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : AppColors.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'GabEye is designed as an assistive tool. Camera conditions, lighting, reflections, and the surrounding environment may affect recognition results.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colors.onSurface,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'For important or safety-related decisions, use labels, text, symbols, or another reliable source in addition to color whenever possible.',
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

class FeedbackFormScreen extends StatefulWidget {
  const FeedbackFormScreen({super.key, required this.initialType});

  final String initialType;

  @override
  State<FeedbackFormScreen> createState() => _FeedbackFormScreenState();
}

class _FeedbackFormScreenState extends State<FeedbackFormScreen> {
  static const _types = [
    'Something is not working',
    'Color identification',
    'Color remapping',
    'Object recognition',
    'Text recognition',
    'Spoken feedback',
    'Pre-assessment',
    'Accessibility',
    'Suggestion',
    'Other',
  ];
  final _formKey = GlobalKey<FormState>();
  final _happenedController = TextEditingController();
  final _expectedController = TextEditingController();
  late String _type;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _type = widget.initialType;
  }

  @override
  void dispose() {
    _happenedController.dispose();
    _expectedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: GabEyeArticleNavbar(
          title: _submitted ? 'Feedback Sent' : 'Send Feedback',
          onBack: () => Navigator.maybePop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 48),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: _submitted ? _confirmation(context) : _form(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _form(BuildContext context) => Form(
    key: _formKey,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'What would you like to tell us?',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 24),
        DropdownButtonFormField<String>(
          initialValue: _type,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Feedback type',
            border: OutlineInputBorder(),
          ),
          items: _types
              .map((type) => DropdownMenuItem(value: type, child: Text(type)))
              .toList(),
          onChanged: (value) => setState(() => _type = value!),
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _happenedController,
          minLines: 4,
          maxLines: 7,
          decoration: const InputDecoration(
            labelText: 'Tell us what happened',
            helperText:
                'Describe what you were trying to do and what happened instead.',
            helperMaxLines: 2,
            alignLabelWithHint: true,
            border: OutlineInputBorder(),
          ),
          validator: (value) => value == null || value.trim().isEmpty
              ? 'Please tell us what happened.'
              : null,
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _expectedController,
          minLines: 3,
          maxLines: 6,
          decoration: const InputDecoration(
            labelText: 'What did you expect to happen?',
            helperText: 'Optional',
            alignLabelWithHint: true,
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 20),
        OutlinedButton.icon(
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Screenshot attachment is optional and is not available in this build.',
              ),
            ),
          ),
          icon: const Icon(Icons.add_photo_alternate_outlined),
          label: const Text('Add Screenshot (Optional)'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(55),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'A screenshot may help us understand the problem.',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 28),
        ElevatedButton.icon(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              setState(() => _submitted = true);
            }
          },
          icon: const Icon(Icons.send_outlined),
          label: const Text('Submit Feedback'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(55),
          ),
        ),
      ],
    ),
  );

  Widget _confirmation(BuildContext context) => Semantics(
    liveRegion: true,
    child: Column(
      children: [
        Icon(
          Icons.check_circle_outline,
          size: 72,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 20),
        Text(
          'Thank you for your feedback',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 10),
        const Text(
          'Your feedback helps us understand how GabEye can be improved.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(55),
            ),
            child: const Text('Done'),
          ),
        ),
      ],
    ),
  );
}

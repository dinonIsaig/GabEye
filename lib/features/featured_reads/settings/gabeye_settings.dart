import 'package:flutter/material.dart';
import 'package:gabeye/components/navbar/article_navbar.dart';
import 'package:gabeye/core/theme/app_colors.dart';
import 'help_feedback_screen.dart';
import 'how_to_use_gabeye.dart';
import 'real_time_mode_safety.dart';
import 'terms_and_conditions_page.dart';

// Models for settings content
class SettingItem {
  final String title;
  final VoidCallback onTap;
  final IconData? icon;

  SettingItem({
    required this.title,
    required this.onTap,
    this.icon,
  });
}

class SettingSection {
  final String? title;
  final List<SettingItem> items;

  SettingSection({this.title, required this.items});
}

class SettingsContent {
  final List<SettingSection> sections;

  SettingsContent({required this.sections});

  // Factory constructor with default content
  factory SettingsContent.defaultContent(BuildContext context) {
    return SettingsContent(
      sections: [
        SettingSection(
          title: 'More About GabEye',
          items: [
            SettingItem(
              title: 'Terms & Conditions',
              icon: Icons.description_outlined,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TermsAndConditionsPage(),
                  ),
                );
              },
            ),
            SettingItem(
              title: 'Help & Feedback',
              icon: Icons.help_outline_rounded,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HelpFeedbackScreen(),
                  ),
                );
              },
            ),
          ],
        ),
        SettingSection(
          title: 'Help & Safety',
          items: [
            SettingItem(
              title: 'How to Use GabEye',
              icon: Icons.menu_book_outlined,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HowToUseGabEyeScreen(),
                  ),
                );
              },
            ),
            SettingItem(
              title: 'Real-time Mode Safety',
              icon: Icons.shield_outlined,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RealTimeModeSafetyScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}

class GabEyeSettingsScreen extends StatelessWidget {
  const GabEyeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsContent = SettingsContent.defaultContent(context);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: GabEyeArticleNavbar(
          title: 'Settings',
          onBack: () => Navigator.maybePop(context),
          onMenuSelected: (option) {
            if (option.label == 'Settings') {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Already on Settings')),
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
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: _buildSettingsSections(
                settingsContent.sections,
                context,
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSettingsSections(
    List<SettingSection> sections,
    BuildContext context,
  ) {
    final widgets = <Widget>[];

    for (int i = 0; i < sections.length; i++) {
      final section = sections[i];

      widgets.add(SettingsSectionWidget(section: section));

      if (i < sections.length - 1) {
        widgets.add(const SizedBox(height: 32));
      }
    }

    return widgets;
  }
}

class SettingsSectionWidget extends StatelessWidget {
  final SettingSection section;

  const SettingsSectionWidget({super.key, required this.section});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (section.title != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              section.title!,
              style: textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ...List.generate(
          section.items.length,
          (index) => Padding(
            padding: EdgeInsets.only(
              bottom: index < section.items.length - 1 ? 12 : 0,
            ),
            child: SettingContainer(item: section.items[index]),
          ),
        ),
      ],
    );
  }
}

class SettingContainer extends StatefulWidget {
  final SettingItem item;

  const SettingContainer({super.key, required this.item});

  @override
  State<SettingContainer> createState() => _SettingContainerState();
}

class _SettingContainerState extends State<SettingContainer> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.item.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: _isHovered
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withValues(alpha: 0.35)
                  : AppColors.primaryNavy.withValues(alpha: 0.45),
              width: 1.2,
            ),
          ),
          child: Row(
            children: [
              if (widget.item.icon != null) ...[
                Icon(
                  widget.item.icon,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : AppColors.primaryNavy,
                  size: 22,
                ),
                const SizedBox(width: 14),
              ],
              Expanded(
                child: Text(
                  widget.item.title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : AppColors.primaryColor,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

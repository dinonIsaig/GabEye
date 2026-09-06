import 'package:flutter/material.dart';

import 'package:gabeye/core/routing/app_routes.dart';
import 'menu_bar.dart';

class MenuButtonOption {
  const MenuButtonOption({required this.label, required this.icon});

  final String label;
  final IconData icon;
}

class MenuButton extends StatelessWidget {
  const MenuButton({
    super.key,
    this.options = defaultOptions,
    this.onPressed,
    this.onSelected,
  });

  static const defaultOptions = [
    MenuButtonOption(label: 'Settings', icon: Icons.settings_outlined),
    MenuButtonOption(label: 'Help & Feedback', icon: Icons.help_outline),
    MenuButtonOption(label: 'About GabEye', icon: Icons.info_outline),
  ];

  final List<MenuButtonOption> options;
  final VoidCallback? onPressed;
  final ValueChanged<MenuButtonOption>? onSelected;

  void _openMenu(BuildContext context) {
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.centerRight,
          child: NavbarMenuPanel(
            items: [
              for (final option in options)
                NavbarMenuItem(icon: option.icon, label: option.label),
            ],
            onClose: () => Navigator.of(dialogContext).pop(),
            onItemTap: (item) {
              Navigator.of(dialogContext).pop();
              final option = options.firstWhere(
                (candidate) => candidate.label == item.label,
              );
              if (onSelected != null) {
                onSelected!(option);
              } else {
                _handleDefaultSelection(context, option);
              }
            },
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final offset = Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));
        return SlideTransition(position: offset, child: child);
      },
    );
  }

  void _handleDefaultSelection(BuildContext context, MenuButtonOption option) {
    switch (option.label) {
      case 'Settings':
        Navigator.of(context).pushNamed(AppRoutes.settings);
        return;
      case 'Help & Feedback':
        Navigator.of(context).pushNamed(AppRoutes.helpFeedback);
        return;
      case 'About GabEye':
        Navigator.of(context).pushNamed(AppRoutes.article);
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return IconButton(
      tooltip: 'Open menu',
      onPressed: onPressed ?? () => _openMenu(context),
      icon: Icon(
        Icons.more_vert,
        size: 20,
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }
}

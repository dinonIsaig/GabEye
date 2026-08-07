import 'package:flutter/material.dart';

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
    MenuButtonOption(label: 'Help and feedback', icon: Icons.help_outline),
    MenuButtonOption(label: 'About GabEye', icon: Icons.info_outline),
  ];

  final List<MenuButtonOption> options;
  final VoidCallback? onPressed;
  final ValueChanged<MenuButtonOption>? onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (onPressed != null) {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Icon(
              Icons.more_vert,
              size: 20,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return PopupMenuButton<MenuButtonOption>(
      tooltip: 'Open menu',
      position: PopupMenuPosition.under,
      offset: const Offset(0, 8),
      onSelected: onSelected,
      itemBuilder: (context) => [
        for (final option in options)
          PopupMenuItem<MenuButtonOption>(
            value: option,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(option.icon, size: 20),
                const SizedBox(width: 12),
                Text(option.label),
              ],
            ),
          ),
      ],
      icon: Icon(
        Icons.more_vert,
        size: 20,
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }
}
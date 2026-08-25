import 'package:flutter/material.dart';
import 'package:gabeye/core/theme/theme_controller.dart';

class NavbarMenuItem {
  const NavbarMenuItem({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

class NavbarMenuPanel extends StatelessWidget {
  const NavbarMenuPanel({
    super.key,
    required this.items,
    required this.onClose,
    required this.onItemTap,
  });

  final List<NavbarMenuItem> items;
  final VoidCallback onClose;
  final ValueChanged<NavbarMenuItem> onItemTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: Material(
        color: colorScheme.surface,
        elevation: 8,
        child: SizedBox(
          width: 280,
          height: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 12, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: onClose,
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          Icons.arrow_forward,
                          size: 20,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              ValueListenableBuilder<ThemeMode>(
                valueListenable: themeController,
                builder: (context, themeMode, child) {
                  final isDarkMode = themeMode == ThemeMode.dark;
                  return Semantics(
                    label: 'Dark Mode',
                    toggled: isDarkMode,
                    child: InkWell(
                      onTap: () => themeController.setDarkMode(!isDarkMode),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.dark_mode_outlined,
                              size: 20,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                'Dark Mode',
                                style: textTheme.bodyLarge?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                            Switch(
                              value: isDarkMode,
                              onChanged: themeController.setDarkMode,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 4),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return InkWell(
                      onTap: () => onItemTap(item),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              item.icon,
                              size: 20,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                item.label,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.bodyLarge?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

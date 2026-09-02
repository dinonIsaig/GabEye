import 'package:flutter/material.dart';
import 'package:gabeye/core/theme/app_colors.dart';

class GabEyeBottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const GabEyeBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  static const _items = [
    (icon: Icons.home, label: 'Home'),
    (icon: Icons.camera_alt, label: 'Camera'),
    (icon: Icons.visibility_outlined, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.borderDark : const Color(0xFF31363D),
            width: 2,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_items.length, (index) {
            final isSelected = index == selectedIndex;
            final item = _items[index];
            return GestureDetector(
              onTap: () => onItemSelected(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 9),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark
                          ? AppColors.darkPrimaryButton
                          : AppColors.primaryNavy)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      item.icon,
                      size: 18,
                      color: isSelected
                          ? (isDark ? AppColors.darkSurface : Colors.white)
                          : colorScheme.onSurface,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.label,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        color: isSelected
                            ? (isDark ? AppColors.darkSurface : Colors.white)
                            : colorScheme.onSurface,
                        fontWeight:
                            isSelected ? FontWeight.w500 : FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

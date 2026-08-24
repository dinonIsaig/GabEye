import 'package:flutter/material.dart';

import '../menu_button.dart';

class GabEyeArticleNavbar extends StatelessWidget {
  const GabEyeArticleNavbar({
    super.key,
    this.title = 'Know More About GabEye',
    this.onBack,
    this.onMenuSelected,
  });

  final String title;
  final VoidCallback? onBack;
  final ValueChanged<MenuButtonOption>? onMenuSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final headerTextColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : colorScheme.onSurfaceVariant;

    return Material(
      color: colorScheme.surfaceContainer,
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(color: colorScheme.surfaceContainer),
        child: SafeArea(
          bottom: false,
          child: SizedBox(
            height: kToolbarHeight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: onBack,
                      borderRadius: BorderRadius.circular(8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.arrow_back,
                            size: 20,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              title,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: headerTextColor,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // No onPressed passed -> renders as PopupMenuButton.
                  MenuButton(onSelected: onMenuSelected),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

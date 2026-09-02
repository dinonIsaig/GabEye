import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gabeye/core/routing/app_routes.dart';

import '../menu_button.dart';

class GabEyeHomeNavbar extends StatelessWidget {
  const GabEyeHomeNavbar({
    super.key,
    this.onBack,
    this.onLogoTap,
    this.onMenuSelected,
  });

  final VoidCallback? onBack;
  final VoidCallback? onLogoTap;
  final ValueChanged<MenuButtonOption>? onMenuSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surfaceContainerHighest,
      elevation: 3,
      shadowColor: Colors.black.withValues(alpha: 0.3),
      surfaceTintColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: SafeArea(
          bottom: false,
          child: SizedBox(
            height: 64,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        if (onLogoTap != null) {
                          onLogoTap!();
                        } else if (ModalRoute.of(context)?.settings.name !=
                            AppRoutes.home) {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            AppRoutes.home,
                            (route) => false,
                          );
                        } else if (onBack != null) {
                          onBack!();
                        }
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        height: 64,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: SvgPicture.asset(
                            'assets/images/gabEyeLogo.svg',
                            fit: BoxFit.contain,
                            width: 120,
                            height: 40,
                            placeholderBuilder: (context) => Container(
                              width: 120,
                              height: 40,
                              color: Colors.grey.shade300,
                              alignment: Alignment.center,
                              child: Text(
                                'LOGO',
                                style: Theme.of(context).textTheme.labelLarge
                                    ?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ),
                          ),
                        ),
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
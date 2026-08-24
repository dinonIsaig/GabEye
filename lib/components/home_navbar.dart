import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'menu_button.dart';

class GabEyeNavbar extends StatelessWidget {
  const GabEyeNavbar({super.key, this.onBack, this.onMenu});

  final VoidCallback? onBack;
  final VoidCallback? onMenu;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surfaceContainerHighest,
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 2,
              offset: const Offset(0, 4),
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
                      onTap: onBack,
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
                  MenuButton(onPressed: onMenu),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

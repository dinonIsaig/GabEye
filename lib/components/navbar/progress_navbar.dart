import 'package:flutter/material.dart';

import '../menu_button.dart';

// This navbar is stateless — it only displays whatever `step` it's given,
// it doesn't track or change it. The Next button does NOT get wired up
// here. Instead:
//   1. The screen that uses this navbar owns the step counter
//      (e.g. `int _step = 1;` in a StatefulWidget).
//   2. That screen defines a `_goNext()` method that calls
//      `setState(() => _step++)`.
//   3. Whoever builds the real Next button sets its onPressed to
//      that screen's `_goNext`.
//   4. This navbar just receives the updated `step` value as a prop
//      on the next rebuild — nothing to connect in this file.

class GabEyeProgressNavbar extends StatelessWidget {
  const GabEyeProgressNavbar({
    super.key,
    required this.step,
    required this.totalSteps,
    this.onBack,
    this.onMenuSelected,
  });

  final int step;
  final int totalSteps;
  final VoidCallback? onBack;
  final ValueChanged<MenuButtonOption>? onMenuSelected;

  double get _progressPercent =>
      totalSteps <= 0 ? 0 : (step / totalSteps).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

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
                children: [
                  InkWell(
                    onTap: onBack,
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Icon(
                        Icons.arrow_back,
                        size: 20,
                        color: onBack == null
                            ? colorScheme.onSurfaceVariant.withValues(
                                alpha: 0.3,
                              )
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      constraints: const BoxConstraints(maxWidth: 203),
                      height: 4,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(9999),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return Align(
                              alignment: Alignment.centerLeft,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                width: constraints.maxWidth * _progressPercent,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: colorScheme.onSurfaceVariant,
                                  borderRadius: BorderRadius.circular(9999),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Text(
                      'Step $step/$totalSteps',
                      textAlign: TextAlign.right,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurfaceVariant,
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
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class GabEyeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showBackButton;
  final bool showLogo;
  final double?progressValue; // Requires a decimal between 0.0 and 1.0 (0.25 for 1/4)
  final String? progressText; // e.g., "Step 4/4"
  final VoidCallback? onMenuPressed;

  const GabEyeAppBar({
    Key? key,
    this.showBackButton = true,
    this.showLogo = false,
    this.progressValue,
    this.progressText,
    this.onMenuPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppBar(
      backgroundColor: colorScheme.surfaceContainer,
      elevation: 0,
      centerTitle: !showLogo,
      automaticallyImplyLeading: false,

      leadingWidth: showBackButton ? 56 : 0,

      leading: showBackButton
          ? Padding(
              padding: const EdgeInsets.only(left: 12),
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
                onPressed: () => Navigator.pop(context),
              ),
            )
          : null,

      title: showLogo
          ? SvgPicture.asset(
              'assets/images/gabEyeLogo.svg',
              height: 40,
              fit: BoxFit.contain,
              
            )
          : progressValue != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(4.0),
                  child: LinearProgressIndicator(
                    value: progressValue,
                    minHeight: 4.0,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                  ),
                )
              : null,

      // 3. ACTIONS (Right Side)
      actions: [
        if (progressText != null)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(
                progressText!,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: IconButton(
            icon: Icon(Icons.more_vert, color: colorScheme.onSurface),
            onPressed:
                onMenuPressed ??
                () {
                  // Default action if none is provided
                  print("Menu clicked");
                },
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

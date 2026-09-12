import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gabeye/components/menu_button.dart';
import 'package:gabeye/core/routing/app_routes.dart';

class GabEyeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showBackButton;
  final bool showLogo;
  // Requires a decimal between 0.0 and 1.0 (0.25 for 1/4).
  final double? progressValue;
  final String? progressText; // e.g., "Step 4/4"
  final VoidCallback? onMenuPressed;
  final VoidCallback? onBackPressed;

  const GabEyeAppBar({
    super.key,
    this.showBackButton = true,
    this.showLogo = false,
    this.progressValue,
    this.progressText,
    this.onMenuPressed,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final headerTextColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : colorScheme.onSurface;

    return Material(
      color: colorScheme.surface,
      elevation: 3,
      shadowColor: Colors.black.withValues(alpha: 0.3),
      surfaceTintColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
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
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: !showLogo,
          automaticallyImplyLeading: false,
          leadingWidth: showBackButton ? 56 : 0,
          leading: showBackButton
              ? Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
                    onPressed: onBackPressed ?? () => Navigator.pop(context),
                  ),
                )
              : null,
          title: showLogo
              ? InkWell(
                  onTap: () {
                    if (ModalRoute.of(context)?.settings.name !=
                        AppRoutes.getStarted) {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.getStarted,
                        (route) => false,
                      );
                    }
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: SvgPicture.asset(
                    'assets/images/gabEyeLogo.svg',
                    height: 40,
                    fit: BoxFit.contain,
                  ),
                )
              : progressValue != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(4.0),
                      child: LinearProgressIndicator(
                        value: progressValue,
                        minHeight: 4.0,
                        backgroundColor: Colors.grey.shade300,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(colorScheme.primary),
                      ),
                    )
                  : null,
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
                      color: headerTextColor,
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: MenuButton(onPressed: onMenuPressed),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

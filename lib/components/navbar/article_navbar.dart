import 'package:flutter/material.dart';

import '../menu_button.dart';

class GabEyeArticleNavbar extends StatefulWidget {
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
  State<GabEyeArticleNavbar> createState() => _GabEyeArticleNavbarState();
}

class _GabEyeArticleNavbarState extends State<GabEyeArticleNavbar> {
  ScrollNotificationObserverState? _scrollNotificationObserver;
  bool _isScrolledUnder = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final observer = ScrollNotificationObserver.maybeOf(context);
    if (observer == _scrollNotificationObserver) return;

    _scrollNotificationObserver?.removeListener(_handleScrollNotification);
    _scrollNotificationObserver = observer;
    _scrollNotificationObserver?.addListener(_handleScrollNotification);
  }

  void _handleScrollNotification(ScrollNotification notification) {
    if (notification.depth != 0 || notification.metrics.axis != Axis.vertical) {
      return;
    }

    final isScrolledUnder = notification.metrics.extentBefore > 0;
    if (isScrolledUnder != _isScrolledUnder && mounted) {
      setState(() => _isScrolledUnder = isScrolledUnder);
    }
  }

  @override
  void dispose() {
    _scrollNotificationObserver?.removeListener(_handleScrollNotification);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final headerTextColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : colorScheme.onSurfaceVariant;

    return Material(
      color: colorScheme.surfaceContainer,
      elevation: 3,
      shadowColor: Colors.black.withValues(alpha: 0.3),
      surfaceTintColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
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
            height: kToolbarHeight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: widget.onBack,
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
                              widget.title,
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
                  MenuButton(onSelected: widget.onMenuSelected),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

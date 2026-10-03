import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:gabeye/core/utils/responsive.dart';
import 'package:gabeye/core/routing/app_routes.dart';
import 'package:gabeye/features/onboarding/widgets/terms_and_conditions_content.dart';

class TermsAndConditionsModal extends StatefulWidget {
  const TermsAndConditionsModal({super.key});

  @override
  State<TermsAndConditionsModal> createState() =>
      _TermsAndConditionsModalState();
}

class _TermsAndConditionsModalState extends State<TermsAndConditionsModal> {
  late ScrollController _scrollController;
  bool _hasScrolledToBottom = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    _scrollController.addListener(() {
      if (_scrollController.offset >=
              _scrollController.position.maxScrollExtent - 50 &&
          !_scrollController.position.outOfRange) {
        if (!_hasScrolledToBottom) {
          setState(() {
            _hasScrolledToBottom = true;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FractionallySizedBox(
        heightFactor: 0.9,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 12.0, bottom: 6.0),
              child: Center(
                child: Container(
                  width: 110,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant
                        .withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        scrollbarTheme: ScrollbarThemeData(
                          thumbColor: WidgetStateProperty.all(
                            Theme.of(context).colorScheme.onPrimary,
                          ),
                          thickness: WidgetStateProperty.all(8),
                          radius: const Radius.circular(8),
                          mainAxisMargin: 20.0,
                        ),
                      ),
                      child: Scrollbar(
                        controller: _scrollController,
                        thumbVisibility: true,
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          padding: Responsive.only(
                            context,
                            left: 24.0,
                            right: 24.0,
                            top: 10.0,
                            bottom: 120.0,
                          ),
                          child: const TermsAndConditionsContent(),
                        ),
                      ),
                    ),
                  ),
                      Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.only(
                      left: 20.0,
                      right: 20.0,
                      top: 14.0,
                      bottom: 40.0,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
                            child: SizedBox(
                              width: double.infinity,
                              height: Responsive.space(context, base: 55, min: 48, max: 64),
                              child: ElevatedButton(
                                onPressed: _hasScrolledToBottom
                                    ? () {
                                        Navigator.pushNamedAndRemoveUntil(
                                          context,
                                          AppRoutes.preAssessmenLearnMoreScreen,
                                          (route) => false,
                                        );
                                      }
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: Theme.of(context).colorScheme.onPrimary,
                                  disabledBackgroundColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.3),
                                  foregroundColor: Theme.of(context).colorScheme.surface,
                                  disabledForegroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
                                  padding: EdgeInsets.zero, 
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                    side: BorderSide(
                                      color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    _hasScrolledToBottom
                                        ? 'I Accept'
                                        : 'Scroll to See More  ↓',
                                    style: TextStyle(
                                      fontSize: Responsive.font(context, base: 18, min: 14, max: 22),
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void showTermsAndConditionsModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: false,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
    ),
    builder: (BuildContext context) {
      return const TermsAndConditionsModal();
    },
  );
}
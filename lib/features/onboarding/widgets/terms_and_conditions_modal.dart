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
  bool _hasAgreed = false;

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

  /// Smoothly scrolls to the end of the terms, where the button turns into "I Accept".
  void _scrollToEnd() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    );
  }

  Widget _buildAcceptanceCheckbox(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => setState(() => _hasAgreed = !_hasAgreed),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: _hasAgreed,
                onChanged: (value) => setState(() => _hasAgreed = value ?? false),
                activeColor: colors.onPrimary,
                checkColor: colors.surface,
                side: BorderSide(color: colors.onSurfaceVariant, width: 1.5),
              ),
              Expanded(
                child: Padding(
                  // Line the first line of text up with the checkbox.
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    TermsAndConditionsContent.acceptanceStatement,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: Responsive.font(context, base: 15, min: 12, max: 17),
                      fontWeight: FontWeight.bold,
                      color: colors.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
                            bottom: 220.0,
                          ),
                          child: const TermsAndConditionsContent(showAcceptanceStatement: false),
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
                        // Acceptance checkbox, revealed once the user reaches the end of the terms.
                        if (_hasScrolledToBottom) ...[
                          SizedBox(
                            width: double.infinity,
                            child: _buildAcceptanceCheckbox(context),
                          ),
                          const SizedBox(height: 12),
                        ],
                        ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
                            child: SizedBox(
                              width: double.infinity,
                              height: Responsive.space(context, base: 55, min: 48, max: 64),
                              child: ElevatedButton(
                                onPressed: _hasScrolledToBottom && _hasAgreed
                                    ? () {
                                        Navigator.pushNamedAndRemoveUntil(
                                          context,
                                          AppRoutes.preAssessmenLearnMoreScreen,
                                          (route) => false,
                                        );
                                      }
                                    // Before the end, tapping scrolls down to the acceptance checkbox.
                                    : (_hasScrolledToBottom ? null : _scrollToEnd),
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
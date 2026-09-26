import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gabeye/core/utils/responsive.dart';
import 'package:gabeye/features/onboarding/widgets/terms_and_conditions_modal.dart';

class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Responsive.constrainWidth(
          context,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isShort = constraints.maxHeight < 650;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: isShort ? 5 : 6,
                    child: Stack(
                      children: [
                        Positioned(
                          top: 0,
                          left: Responsive.space(context, base: -140, min: -180, max: -100),
                          bottom: 0,
                          child: SvgPicture.asset(
                            'assets/images/gabEyeLogo.svg',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 50.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome to',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: Responsive.font(context, base: 16, min: 14, max: 20),
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          SizedBox(height: Responsive.space(context, base: 4, min: 2, max: 8)),
                          Text(
                            'GabEye!',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: Responsive.font(context, base: 40, min: 30, max: 46),
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.onSurface,
                              letterSpacing: -1.0,
                              height: 1.0,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "We don't just show you how colors look different — we shift them to make things easier to see.",
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: Responsive.font(context, base: 16, min: 13, max: 18),
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.justify,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 60.0,
                      right: 60.0,
                      bottom: 40.0,
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        showTermsAndConditionsModal(context);
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 4,
                        shadowColor: Colors.black.withValues(alpha: 0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        minimumSize: Size(
                          double.infinity,
                          Responsive.space(context, base: 55, min: 48, max: 64),
                        ),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Get Started',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: Responsive.font(context, base: 18, min: 14, max: 22),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
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
                    flex: isShort ? 5 : 4,
                    child: Padding(
                      padding: Responsive.symmetricH(context, base: 36, min: 20, max: 48),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Welcome to',
                            style: GoogleFonts.atkinsonHyperlegibleNext(
                              fontSize: Responsive.font(context, base: 16, min: 13, max: 18),
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'GabEye!',
                              style: GoogleFonts.inter(
                                fontSize: Responsive.font(context, base: 40, min: 28, max: 48),
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).colorScheme.onSurface,
                                letterSpacing: -1.0,
                                height: 1.0,
                              ),
                            ),
                          ),
                          SizedBox(height: Responsive.space(context, base: 12, min: 6, max: 18)),
                          Text(
                            "We don't just show you how colors look different — we shift them to make things easier to see.",
                            style: GoogleFonts.atkinsonHyperlegibleNext(
                              fontSize: Responsive.font(context, base: 15, min: 12, max: 18),
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Padding(
                    padding: Responsive.only(
                      context,
                      left: 32,
                      right: 32,
                      bottom: isShort ? 16 : 28,
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
                          Responsive.space(context, base: 52, min: 44, max: 60),
                        ),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Get Started',
                          style: TextStyle(
                            fontSize: Responsive.font(context, base: 18, min: 15, max: 22),
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

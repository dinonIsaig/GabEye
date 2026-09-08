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
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome to',
                        style: GoogleFonts.atkinsonHyperlegibleNext(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        'GabEye!',
                        style: GoogleFonts.inter(
                          fontSize: 40,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.onSurface,
                          letterSpacing: -1.0,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        " We don't just show you how colors look different — we shift them to make things easier to see.",
                        style: GoogleFonts.atkinsonHyperlegibleNext(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          height: 1.5,
                        ),
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
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

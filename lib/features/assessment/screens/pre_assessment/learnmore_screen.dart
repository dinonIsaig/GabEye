import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gabeye/core/utils/responsive.dart';
import 'package:gabeye/core/routing/app_routes.dart';
import 'package:gabeye/core/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class LearnMoreScreen extends StatelessWidget {
  const LearnMoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Responsive.constrainWidth(
            context,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Container(
                              constraints: BoxConstraints(
                                minHeight: Responsive.space(context, base: 220, min: 160, max: 280),
                              ),
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Positioned(
                                    top: Responsive.space(context, base: -120, min: -160, max: -80),
                                    left: Responsive.space(context, base: -140, min: -180, max: -100),
                                    right: Responsive.space(context, base: -140, min: -180, max: -100),
                                    bottom: 0,
                                    child: SvgPicture.asset(
                                      'assets/images/gabEyeLogo.svg',
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0), 
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20.0), 
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'GabEye can help you understand your',
                                        style: GoogleFonts.atkinsonHyperlegible(
                                          fontSize: 16,
                                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      SizedBox(height: Responsive.space(context, base: 4, min: 2, max: 8)),
                                      Text(
                                        'Color Vision',
                                        style: GoogleFonts.inter(
                                          fontSize: Responsive.font(context, base: 40, min: 30, max: 40),
                                          fontWeight: FontWeight.w700,
                                          color: Theme.of(context).colorScheme.onSurface,
                                          letterSpacing: -1.0,
                                          height: 1.0,
                                        ),
                                      ),
                                      SizedBox(height: Responsive.space(context, base: 16, min: 8, max: 16)),
                                      Text(
                                        "With this quick color vision assessment it will help you better understand how you perceive colors. In just a few minutes, you’ll get an initial insight into your color vision and help us tailor the app to suit your needs.",
                                        style: GoogleFonts.atkinsonHyperlegible(
                                          fontSize: Responsive.font(context, base: 16, min: 13, max: 18),
                                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                                          fontWeight: FontWeight.w400,
                                        ),
                                        textAlign: TextAlign.justify,
                                      ),
                                      SizedBox(height: Responsive.space(context, base: 24, min: 12, max: 32)),
                                      Text(
                                        'This is an initial assessment designed for guidance and app personalization. It is not a medical diagnosis or a substitute for professional evaluation.',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.atkinsonHyperlegible(
                                          fontSize: Responsive.font(context, base: 16, min: 12, max: 16),
                                          color: AppColors.disabledText,
                                          fontStyle: FontStyle.italic,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: Responsive.space(context, base: 16, min: 10, max: 20)),
                                SizedBox(
                                  width: double.infinity,
                                  height: Responsive.space(context, base: 55, min: 48, max: 64),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.pushReplacementNamed(context, AppRoutes.preAssessmentIntro);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      elevation: 4,
                                      shadowColor: Colors.black.withValues(alpha: 0.5),
                                      padding: EdgeInsets.zero,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                    ),
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Learn More',
                                            style: TextStyle(
                                              fontFamily: 'Inter',
                                              fontSize: Responsive.font(context, base: 18, min: 14, max: 22),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          const Icon(Icons.arrow_forward_rounded, size: 20),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 40.0), 
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
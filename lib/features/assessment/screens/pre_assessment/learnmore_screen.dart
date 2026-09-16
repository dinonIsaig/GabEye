import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gabeye/core/utils/responsive.dart';
import 'package:gabeye/core/routing/app_routes.dart';

class LearnMoreScreen extends StatelessWidget {
  const LearnMoreScreen({super.key});

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
                  Expanded(
                    flex: 6,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'GabEye can help you understand your',
                            style: TextStyle(
                              fontFamily: 'AtkinsonHyperlegible',
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            'Color Vision',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 40,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.onSurface,
                              letterSpacing: -1.0,
                              height: 1.0,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "With this quick color vision assessment it will help you better understand how you perceive colors. In just a few minutes, you’ll get an initial insight into your color vision and help us tailor the app to suit your needs.",
                            style: TextStyle(
                              fontFamily: 'AtkinsonHyperlegible',
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              height: 1.5,
                            ),
                          ),
                          const Spacer(),
                          
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
                                        fontSize: Responsive.font(context, base: 16, min: 14, max: 20),
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
                          const SizedBox(height: 16),
                          
                          Center(
                            child: Text(
                              'This is an initial assessment designed for guidance and app\npersonalization. It is not a medical diagnosis or a substitute\nfor professional evaluation.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'AtkinsonHyperlegible',
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                                height: 1.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                        ],
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
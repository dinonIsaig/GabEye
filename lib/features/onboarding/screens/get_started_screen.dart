import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // REQUIRED for .svg files!
import 'package:gabeye/core/routing/app_routes.dart';
import 'package:gabeye/features/onboarding/widgets/terms_and_conditions_modal.dart';

class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 8,
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: -140,
                    bottom: 0,
                    child: SvgPicture.asset(
                      'assets/images/gabEyeLogo.svg',
                      fit: BoxFit.contain,
                    ),
                  ),
                ]
              ),
            ),

            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text(
                      'Welcome to',
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF333333),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'GabEye!',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF111827),
                        letterSpacing: -1.0,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      "We don't just show you how colors look different — we shift them to make things easier to see.",
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF4B5563),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.only(left: 32.0, right: 32.0, bottom: 40.0),
              child: ElevatedButton(
                onPressed: () {
                  showTermsAndConditionsModal(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF193B61),
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shadowColor: Colors.black.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  minimumSize: const Size(double.infinity, 60), 
                ),
                child: const Text(
                  'Get Started',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        )
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:gabeye/components/navbar/article_navbar.dart';
import 'package:gabeye/core/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'help_feedback_screen.dart';

class TermsAndConditionsPage extends StatelessWidget {
  const TermsAndConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: GabEyeArticleNavbar(
          title: 'Terms & Conditions',
          onBack: () => Navigator.maybePop(context),
          onMenuSelected: (option) {
            if (option.label == 'Help & Feedback') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HelpFeedbackScreen(),
                ),
              );
            } else if (option.label == 'About GabEye') {
              Navigator.pushNamed(context, '/article');
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                  child: _buildTermsTextContent(context),
                ),
              ),
            ),
    );
  }

  Widget _buildTermsTextContent(BuildContext context) {
    final bodyStyle = GoogleFonts.atkinsonHyperlegibleNext(
      fontSize: 16,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );

    final headingStyle = GoogleFonts.inter(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
      height: 1.5,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Terms and Conditions',
          style: GoogleFonts.inter(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Last Update: July 2026',
          style: GoogleFonts.atkinsonHyperlegibleNext(
            fontSize: 12,
            color: AppColors.disabledText,
          ),
        ),
        const SizedBox(height: 24),
        Text('1. What is GabEye', style: headingStyle),
        const SizedBox(height: 8),
        Text(
          'GabEye is a mobile app that helps people with color vision deficiency (CVD) navigate color-dependent tasks. It does this through a built-in color assessment, real-time and static color remapping, color identification, object recognition, and audio feedback.',
          style: bodyStyle,
          textAlign: TextAlign.justify,
        ),
        const SizedBox(height: 12),
        Text.rich(
          TextSpan(
            children: const [
              TextSpan(
                text: 'GabEye is a personalization and assistive tool. ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text:
                    'It is built to adapt to how you see color and make everyday tasks easier — not to diagnose, treat, or replace professional eye care.',
              ),
            ],
          ),
          style: bodyStyle,
          textAlign: TextAlign.justify,
        ),
        const SizedBox(height: 24),
        Text('2. About the Color Assessment', style: headingStyle),
        const SizedBox(height: 8),
        _buildBulletPoint(
          'GabEye includes a digital version of the Farnsworth D-15 color arrangement test.',
          bodyStyle,
        ),
        _buildBulletPoint(
          'This assessment is for app personalization only. It helps GabEye identify a likely color vision pattern (Protan, Deutan, or Tritan) so it can apply the right visual filters and settings for you.',
          bodyStyle,
        ),
        _buildBulletPoint(
          'This is not a medical diagnosis. Results from this assessment do not confirm, rule out, or replace a clinical evaluation.',
          bodyStyle,
        ),
        _buildBulletPoint(
          'Digital color tests can be affected by things like your screen\'s color accuracy and the lighting in the room. For a confirmed diagnosis, please see a licensed eye care specialist.',
          bodyStyle,
        ),
        _buildBulletPoint(
          'If your results suggest a color vision difference, or if you have any concerns about your vision, we encourage you to consult an eye specialist for a full assessment.',
          bodyStyle,
        ),
        const SizedBox(height: 24),
        Text('3. Using the Camera and Real-Time Features', style: headingStyle),
        const SizedBox(height: 8),
        Text(
          'GabEye\'s real-time mode uses your device\'s camera to identify and remap colors as you move through your environment.',
          style: bodyStyle,
          textAlign: TextAlign.justify,
        ),
        const SizedBox(height: 12),
        _buildBulletPoint(
          'Please remain stationary while using real-time camera features. This ensures accurate processing and helps prevent accidents while you\'re focused on your screen.',
          bodyStyle,
        ),
        _buildBulletPoint(
          'Be mindful of your surroundings when using GabEye outdoors or in unfamiliar spaces. GabEye is a visual aid, not a substitute for careful awareness of your environment.',
          bodyStyle,
        ),
        _buildBulletPoint(
          'Camera access is only used to power color identification, object recognition, and Daltonization while you\'re actively using these features.',
          bodyStyle,
        ),
        const SizedBox(height: 24),
        Text('4. Your Data and Privacy', style: headingStyle),
        const SizedBox(height: 8),
        Text(
          'We built GabEye to keep your information private and under your control.',
          style: bodyStyle,
          textAlign: TextAlign.justify,
        ),
        const SizedBox(height: 12),
        _buildBulletPoint(
          'Your data stays on your device. Your assessment results, color vision profile, and app settings are stored locally, using offline device storage. We do not upload this information to external servers or the cloud.',
          bodyStyle,
        ),
        _buildBulletPoint(
          'Camera and image data are processed on-device. Live camera streams and uploaded images are analyzed locally using on-device tools. This data isn\'t sent anywhere outside your phone.',
          bodyStyle,
        ),
        _buildBulletPoint(
          'We follow the Data Privacy Act of 2012 (Republic Act No. 10173). Because your color vision profile is sensitive personal information, we\'ve designed GabEye\'s architecture specifically to avoid the risks that come with cloud-based storage.',
          bodyStyle,
        ),
        _buildBulletPoint(
          'If you uninstall GabEye or clear its app data, your saved profile and settings will be permanently removed from your device.',
          bodyStyle,
        ),
        const SizedBox(height: 24),
        Text('5. What GabEye Can\'t Do', style: headingStyle),
        const SizedBox(height: 8),
        Text(
          'While we\'ve built GabEye to be genuinely helpful, please keep the following in mind:',
          style: bodyStyle,
          textAlign: TextAlign.justify,
        ),
        const SizedBox(height: 12),
        _buildBulletPoint(
          'Color identification, object recognition, and audio feedback may not always be perfectly accurate, especially in poor lighting or unusual environments.',
          bodyStyle,
        ),
        _buildBulletPoint(
          'GabEye is intended for use in a way where you can pause, look at your screen, and use the app safely — not for tasks that require constant movement or split-second decisions (like driving).',
          bodyStyle,
        ),
        _buildBulletPoint(
          'GabEye does not replace professional advice for health, safety-critical, or occupational decisions that depend on accurate color perception (for example, certain jobs in aviation, electrical work, or transportation).',
          bodyStyle,
        ),
        const SizedBox(height: 20),
        RichText(
          textAlign: TextAlign.justify,
          text: TextSpan(
            style: GoogleFonts.atkinsonHyperlegibleNext(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildBulletPoint(String text, TextStyle style) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('•  ', style: style.copyWith(fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(text, style: style, textAlign: TextAlign.justify),
          ),
        ],
      ),
    );
  }
}

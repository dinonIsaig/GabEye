import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:gabeye/core/theme/app_colors.dart';
import 'package:gabeye/core/utils/responsive.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gabeye/core/routing/app_routes.dart';

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
                    child: _buildTermsTextContent(context),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: Responsive.only(
                  context,
                  left: 36.0,
                  right: 36.0,
                  top: 14.0,
                  bottom: 24.0,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
                        child: ElevatedButton(
                          onPressed: _hasScrolledToBottom
                              ? () {
                                  Navigator.popAndPushNamed(
                                      context, AppRoutes.preAssessmenLearnMoreScreen);
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.onPrimary,
                            disabledBackgroundColor: Theme.of(
                              context,
                            ).colorScheme.surface.withValues(alpha: 0.3),
                            foregroundColor: Theme.of(
                              context,
                            ).colorScheme.surface,
                            disabledForegroundColor: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                              side: BorderSide(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant
                                    .withValues(alpha: 0.6),
                                width: 1.5,
                              ),
                            ),
                            minimumSize: Size(
                              double.infinity,
                              Responsive.space(context, base: 55, min: 48, max: 64),
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
    );
  }

  Widget _buildTermsTextContent(BuildContext context) {
    final bodyStyle = GoogleFonts.atkinsonHyperlegibleNext(
      fontSize: Responsive.font(context, base: 16, min: 13, max: 18),
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );

    final headingStyle = GoogleFonts.inter(
      fontSize: Responsive.font(context, base: 18, min: 15, max: 22),
      fontWeight: FontWeight.bold,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
      height: 1.5,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'GabEye Terms and Conditions',
          style: GoogleFonts.inter(
            fontSize: Responsive.font(context, base: 26, min: 20, max: 32),
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: Responsive.space(context, base: 4, min: 2, max: 8)),
        Text(
          'Last Updated: September 2026',
          style: GoogleFonts.atkinsonHyperlegibleNext(
            fontSize: 16,
            color: AppColors.disabledText,
          ),
        ),
        const SizedBox(height: 16),

        Text(
          'Please read these Terms and Conditions carefully before using GabEye: A Mobile Application Aid for Color Vision Deficiency (CVD). These Terms and Conditions govern your use of the GabEye mobile application and its features.\n\nBy tapping "I Accept," you acknowledge that you have read, understood, and agreed to be bound by these Terms and Conditions.\n\nIf you do not agree with these Terms and Conditions, please do not continue using GabEye.',
          style: bodyStyle,
          textAlign: TextAlign.justify,
        ),
        const SizedBox(height: 24),

        Text('1. About GabEye', style: headingStyle),
        const SizedBox(height: 8),
        Text(
          'GabEye is a cross-platform mobile application designed to assist individuals with Color Vision Deficiency (CVD) with color-dependent and visually assisted tasks.\n\nGabEye is intended to function as a personalized assistive and accessibility tool. Depending on the features available on your device and the application version, GabEye may provide:',
          style: bodyStyle,
          textAlign: TextAlign.justify,
        ),
        const SizedBox(height: 12),
        _buildBulletPoint('A digital Farnsworth D-15 color arrangement assessment;', bodyStyle),
        _buildBulletPoint('Personalized interface settings based on the assessment results;', bodyStyle),
        _buildBulletPoint('Real-time color identification;', bodyStyle),
        _buildBulletPoint('Static-image color identification and processing;', bodyStyle),
        _buildBulletPoint('Real-time and static-image Daltonization or color enhancement;', bodyStyle),
        _buildBulletPoint('Object and scene recognition;', bodyStyle),
        _buildBulletPoint('Text or character recognition;', bodyStyle),
        _buildBulletPoint('Audio or text-to-speech feedback; and', bodyStyle),
        _buildBulletPoint('Educational and awareness information concerning Color Vision Deficiency.', bodyStyle),
        const SizedBox(height: 12),
        Text(
          'GabEye is designed to support individuals with CVD, particularly users whose color vision difficulties fall within the Protan, Deutan, or Tritan categories.',
          style: bodyStyle,
          textAlign: TextAlign.justify,
        ),
        const SizedBox(height: 12),
        _buildRichBulletPoint(
          [
            const TextSpan(
              text: 'GabEye is an assistive technology application only. ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const TextSpan(
              text: 'It is not intended to diagnose, cure, treat, prevent, or medically manage Color Vision Deficiency or any other eye or health condition.',
            ),
          ],
          bodyStyle,
        ),
        _buildRichBulletPoint(
          [
            const TextSpan(
              text: 'GabEye does not replace an optometrist, ophthalmologist, physician, or other qualified healthcare professional.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
          bodyStyle,
        ),
        const SizedBox(height: 24),

        Text('2. Farnsworth D-15 Color Assessment', style: headingStyle),
        const SizedBox(height: 8),
        Text(
          'GabEye includes a digital version of the Farnsworth D-15 color arrangement test.\n\nThe assessment is incorporated into the application to help personalize GabEye\'s interface and color-assistance features. Results may be used to identify a likely color vision pattern and determine appropriate application settings, such as adaptive interface themes and corrective filters.\n\nHowever:',
          style: bodyStyle,
          textAlign: TextAlign.justify,
        ),
        const SizedBox(height: 12),
        _buildRichBulletPoint(
          [
            const TextSpan(
              text: 'The GabEye assessment is not and does not replace a clinical diagnosis.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
          bodyStyle,
        ),
        _buildRichBulletPoint(
          [
            const TextSpan(
              text: 'A GabEye result does not confirm or rule out Color Vision Deficiency.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
          bodyStyle,
        ),
        _buildRichBulletPoint(
          [
            const TextSpan(
              text: 'The assessment must not be used as a substitute for a professional eye examination.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
          bodyStyle,
        ),
        _buildBulletPoint('Results may be affected by factors such as device display characteristics, screen calibration, surrounding lighting, and other environmental conditions.', bodyStyle),
        _buildRichBulletPoint(
          [
            const TextSpan(
              text: 'GabEye\'s assessment is intended primarily for application personalization, Daltonization tweaking improvement, preliminary assessment, and awareness.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
          bodyStyle,
        ),
        const SizedBox(height: 12),
        Text(
          'If you have concerns about your color vision or eyesight, you should consult a qualified eye-care professional for a complete assessment.',
          style: bodyStyle,
          textAlign: TextAlign.justify,
        ),
        const SizedBox(height: 24),

        Text('3. Personalized Assistance', style: headingStyle),
        const SizedBox(height: 8),
        Text(
          'GabEye may adapt certain application settings according to the results of the built-in assessment.\n\nThese adaptations may include changes to:',
          style: bodyStyle,
          textAlign: TextAlign.justify,
        ),
        const SizedBox(height: 12),
        _buildBulletPoint('Interface color themes;', bodyStyle),
        _buildBulletPoint('Color-agnostic navigation;', bodyStyle),
        _buildBulletPoint('Color enhancement or remapping settings;', bodyStyle),
        _buildBulletPoint('Accessibility preferences; and', bodyStyle),
        _buildBulletPoint('Audio or text-to-speech preferences.', bodyStyle),
        const SizedBox(height: 12),
        Text(
          'The purpose of personalization is to make GabEye more suitable for the user\'s reported or assessed color vision characteristics. The personalized settings are not medical prescriptions or clinical recommendations.\n\nYou remain responsible for determining whether a particular visual or audio setting is comfortable and useful for you.',
          style: bodyStyle,
          textAlign: TextAlign.justify,
        ),
        const SizedBox(height: 24),

        Text('4. Camera and Real-Time Features', style: headingStyle),
        const SizedBox(height: 8),
        Text(
          'GabEye may request access to your device\'s camera when you use features that require live visual input.\n\nCamera-based features may be used for purposes such as:',
          style: bodyStyle,
          textAlign: TextAlign.justify,
        ),
        const SizedBox(height: 12),
        _buildBulletPoint('Color identification;', bodyStyle),
        _buildBulletPoint('Object identification;', bodyStyle),
        _buildBulletPoint('Text or character recognition;', bodyStyle),
        _buildBulletPoint('Real-time Daltonization or color enhancement; and', bodyStyle),
        _buildBulletPoint('Other visual-assistance functions supported by the application.', bodyStyle),
        const SizedBox(height: 12),
        Text(
          'GabEye is designed to perform these visual-processing functions on the device using local processing technologies. The application architecture is intended to process live camera streams and visual inputs locally rather than transmitting them to external cloud servers.\n\nSafe Use of the Camera\nYou agree to use GabEye responsibly and safely.\n\nWhen using real-time camera features:',
          style: bodyStyle,
          textAlign: TextAlign.justify,
        ),
        const SizedBox(height: 12),
        _buildRichBulletPoint(
          [
            const TextSpan(
              text: 'Remain stationary whenever possible.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
          bodyStyle,
        ),
        _buildRichBulletPoint(
          [
            const TextSpan(
              text: 'Do not use GabEye while driving, operating machinery, crossing roads, or performing another activity requiring continuous attention.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
          bodyStyle,
        ),
        _buildRichBulletPoint(
          [
            const TextSpan(
              text: 'Do not allow your use of GabEye to interfere with your awareness of your surroundings.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
          bodyStyle,
        ),
        _buildRichBulletPoint(
          [
            const TextSpan(
              text: 'Stop using the application if you feel unsafe, distracted, or physically uncomfortable.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
          bodyStyle,
        ),
        const SizedBox(height: 12),
        Text(
          'GabEye is intended for stationary assistive tasks where the user can safely pause and interact with the application.',
          style: bodyStyle,
          textAlign: TextAlign.justify,
        ),
        const SizedBox(height: 12),
        _buildRichBulletPoint(
          [
            const TextSpan(
              text: 'GabEye must not be relied upon as the sole source of information in emergency, safety-critical, medical, transportation, industrial, or occupational situations.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
          bodyStyle,
        ),
        const SizedBox(height: 24),

        Text('5. Accuracy and Application Limitations', style: headingStyle),
        const SizedBox(height: 8),
        Text(
          'GabEye is designed to provide useful assistance, but no automated recognition or color-processing system can guarantee perfect results in every situation.\n\nThe accuracy of GabEye\'s features may be affected by:',
          style: bodyStyle,
          textAlign: TextAlign.justify,
        ),
        const SizedBox(height: 12),
        _buildBulletPoint('Poor, excessive, or unusual lighting;', bodyStyle),
        _buildBulletPoint('Camera quality;', bodyStyle),
        _buildBulletPoint('Device hardware and processing capability;', bodyStyle),
        _buildBulletPoint('Display characteristics;', bodyStyle),
        _buildBulletPoint('Environmental conditions;', bodyStyle),
        _buildBulletPoint('Similar or overlapping colors;', bodyStyle),
        _buildBulletPoint('Image quality;', bodyStyle),
        _buildBulletPoint('Objects that are partially hidden or visually obstructed; and', bodyStyle),
        _buildBulletPoint('Limitations of the application\'s recognition algorithms.', bodyStyle),
        const SizedBox(height: 12),
        Text(
          'In particular, extreme environmental lighting may affect color thresholding and color-recognition accuracy.',
          style: bodyStyle,
          textAlign: TextAlign.justify,
        ),
        const SizedBox(height: 24),

        Text('6. Safety-Critical and Professional Use', style: headingStyle),
        const SizedBox(height: 8),
        Text(
          'GabEye is not designed to replace professional judgment or safety procedures.\n\nYou must not rely solely on GabEye for decisions involving:',
          style: bodyStyle,
          textAlign: TextAlign.justify,
        ),
        const SizedBox(height: 12),
        _buildBulletPoint('Driving or road safety;', bodyStyle),
        _buildBulletPoint('Traffic signals;', bodyStyle),
        _buildBulletPoint('Aviation;', bodyStyle),
        _buildBulletPoint('Electrical work;', bodyStyle),
        _buildBulletPoint('Transportation;', bodyStyle),
        _buildBulletPoint('Medical or healthcare decisions;', bodyStyle),
        _buildBulletPoint('Workplace safety;', bodyStyle),
        _buildBulletPoint('Occupational color requirements;', bodyStyle),
        _buildBulletPoint('Emergency situations; or', bodyStyle),
        _buildBulletPoint('Any other activity where an incorrect visual interpretation could cause injury, property damage, or serious consequences.', bodyStyle),
        const SizedBox(height: 12),
        Text(
          'The application is designed as an assistive tool for everyday color-dependent activities and should be treated as a supplementary aid rather than a safety-critical system.',
          style: bodyStyle,
          textAlign: TextAlign.justify,
        ),
        const SizedBox(height: 24),

        Text('7. Privacy and Your Data', style: headingStyle),
        const SizedBox(height: 8),
        Text(
          'GabEye is designed with an offline-first and privacy-oriented architecture.\n\nDepending on the application\'s implemented version and features used:',
          style: bodyStyle,
          textAlign: TextAlign.justify,
        ),
        const SizedBox(height: 12),
        _buildBulletPoint('Your Farnsworth D-15 assessment results may be stored locally on your device.', bodyStyle),
        _buildBulletPoint('Your CVD-related profile and personalized interface settings may be stored locally.', bodyStyle),
        _buildBulletPoint('Accessibility preferences may be stored locally.', bodyStyle),
        _buildBulletPoint('Live camera processing is performed on the device.', bodyStyle),
        _buildBulletPoint('Static images used with GabEye\'s image-processing features are intended to be processed locally.', bodyStyle),
        _buildBulletPoint('The application is designed not to transmit these visual inputs or CVD profile information to external cloud servers as part of its core assistive processing.', bodyStyle),
        const SizedBox(height: 12),
        Text(
          'The researchers\' system architecture specifically avoids cloud-based storage for sensitive assessment information and uses local storage for user profiles and assessment-related information.\n\nGabEye\'s handling of information is intended to comply with the Philippine Data Privacy Act of 2012 (Republic Act No. 10173).\n\nYou should review the GabEye Privacy Notice/Privacy Policy, where applicable, for additional information regarding what information is collected, how it is processed, and your applicable privacy rights.',
          style: bodyStyle,
          textAlign: TextAlign.justify,
        ),
        const SizedBox(height: 24),

        Text('8. Device Permissions', style: headingStyle),
        const SizedBox(height: 8),
        Text(
          'GabEye may request certain permissions necessary for specific features.\n\nThese may include access to:',
          style: bodyStyle,
          textAlign: TextAlign.justify,
        ),
        const SizedBox(height: 12),
        _buildBulletPoint('Camera;', bodyStyle),
        _buildBulletPoint('Photos or images;', bodyStyle),
        _buildBulletPoint('Audio output; and', bodyStyle),
        _buildBulletPoint('Other device functions required to operate supported accessibility features.', bodyStyle),
        const SizedBox(height: 12),
        Text(
          'You may deny permission. However, denying a required permission may prevent the corresponding feature from functioning properly.\n\nFor example, camera-based features cannot operate without camera access.\n\nGabEye will only request permissions necessary for the operation of supported application functions.',
          style: bodyStyle,
          textAlign: TextAlign.justify,
        ),
        const SizedBox(height: 24),

        Text('9. Audio and Text-to-Speech Features', style: headingStyle),
        const SizedBox(height: 8),
        Text(
          'GabEye may convert recognized visual information into spoken feedback using text-to-speech technology.\n\nAudio feedback may be generated for information such as:',
          style: bodyStyle,
          textAlign: TextAlign.justify,
        ),
        const SizedBox(height: 12),
        _buildBulletPoint('Identified colors;', bodyStyle),
        _buildBulletPoint('Recognized objects;', bodyStyle),
        _buildBulletPoint('Recognized text;', bodyStyle),
        _buildBulletPoint('Scene descriptions; and', bodyStyle),
        _buildBulletPoint('Other information supported by the application.', bodyStyle),
        const SizedBox(height: 12),
        Text(
          'Audio output may vary depending on your device, operating system, installed voice services, language settings, and application configuration.\n\nYou remain responsible for confirming important information when accuracy is critical.',
          style: bodyStyle,
          textAlign: TextAlign.justify,
        ),
        const SizedBox(height: 24),

        Text('10. User Responsibilities', style: headingStyle),
        const SizedBox(height: 8),
        Text('By using GabEye, you agree to:', style: bodyStyle),
        const SizedBox(height: 12),
        _buildBulletPoint('Use the application only for lawful and responsible purposes;', bodyStyle),
        _buildBulletPoint('Use GabEye in accordance with these Terms and Conditions;', bodyStyle),
        _buildBulletPoint('Follow all safety instructions provided within the application;', bodyStyle),
        _buildBulletPoint('Remain stationary when using real-time camera assistance;', bodyStyle),
        _buildBulletPoint('Avoid relying solely on GabEye for safety-critical decisions;', bodyStyle),
        _buildBulletPoint('Provide truthful information when information is requested for application personalization;', bodyStyle),
        _buildBulletPoint('Keep your device secure;', bodyStyle),
        _buildBulletPoint('Maintain control over who can access your device and application data; and', bodyStyle),
        _buildBulletPoint('Use professional medical or technical services when a situation requires professional judgment.', bodyStyle),
        const SizedBox(height: 12),
        Text(
          'You are responsible for how you interpret and act upon information provided by GabEye.',
          style: bodyStyle,
          textAlign: TextAlign.justify,
        ),
        const SizedBox(height: 24),

        Text('11. Educational and Informational Content', style: headingStyle),
        const SizedBox(height: 8),
        Text(
          'GabEye may provide educational or informational materials concerning Color Vision Deficiency, including information about CVD types, severity, assessment, and accessibility.\n\nSuch content is provided for general educational and awareness purposes only.\n\nEducational information within GabEye should not be interpreted as personalized medical advice, diagnosis, treatment, or professional consultation.',
          style: bodyStyle,
          textAlign: TextAlign.justify,
        ),
        const SizedBox(height: 24),

        Text('12. Intellectual Property', style: headingStyle),
        const SizedBox(height: 8),
        Text(
          'GabEye, including its application interface, software logic, visual designs, original content, and other materials developed specifically for the application, is protected by applicable intellectual-property laws.\n\nExcept where permitted by law or expressly authorized by the application owner or researchers, you may not:',
          style: bodyStyle,
          textAlign: TextAlign.justify,
        ),
        const SizedBox(height: 12),
        _buildBulletPoint('Copy or reproduce GabEye\'s proprietary materials;', bodyStyle),
        _buildBulletPoint('Modify, reverse engineer, decompile, or attempt to extract the application\'s source code;', bodyStyle),
        _buildBulletPoint('Redistribute or commercially exploit the application or its proprietary components; or', bodyStyle),
        _buildBulletPoint('Use GabEye\'s content in a manner that infringes the rights of the application owner or other rights holders.', bodyStyle),
        const SizedBox(height: 12),
        Text(
          'Third-party libraries, frameworks, and technologies incorporated into GabEye remain subject to their respective licenses and terms.',
          style: bodyStyle,
          textAlign: TextAlign.justify,
        ),
        const SizedBox(height: 24),

        Text('13. Third-Party Technologies', style: headingStyle),
        const SizedBox(height: 8),
        Text(
          'GabEye relies on software technologies and libraries to provide certain functions, including Flutter, Google ML Kit, GLSL-based processing, and text-to-speech functionality.\n\nThese technologies may operate subject to their own technical limitations and applicable licenses.\n\nGabEye is not responsible for failures caused solely by third-party operating systems, hardware, device limitations, or services outside the application\'s control.',
          style: bodyStyle,
          textAlign: TextAlign.justify,
        ),
        const SizedBox(height: 24),

        Text('14. Application Availability and Performance', style: headingStyle),
        const SizedBox(height: 8),
        Text(
          'GabEye is developed to operate across supported Android and iOS devices using the Flutter framework. However, application performance may vary depending on device hardware, operating-system version, GPU capability, camera quality, available storage, and other technical conditions.\n\nSome advanced visual-processing functions may require sufficient device processing capability.\n\nGabEye does not guarantee that every feature will work identically or with identical performance on every device.\n\nThe application may be updated, modified, improved, suspended, or discontinued as part of ongoing development, testing, maintenance, or security improvements.',
          style: bodyStyle,
          textAlign: TextAlign.justify,
        ),
        const SizedBox(height: 24),

        Text('15. No Guarantee of Results', style: headingStyle),
        const SizedBox(height: 8),
        Text(
          'GabEye is intended to provide assistive support, but the application does not guarantee:',
          style: bodyStyle,
          textAlign: TextAlign.justify,
        ),
        const SizedBox(height: 12),
        _buildBulletPoint('Accurate identification of every color or object;', bodyStyle),
        _buildBulletPoint('Correct recognition of every image or text input;', bodyStyle),
        _buildBulletPoint('Accurate assessment of every user\'s CVD characteristics;', bodyStyle),
        _buildBulletPoint('Improved vision or visual perception;', bodyStyle),
        _buildBulletPoint('Prevention of mistakes;', bodyStyle),
        _buildBulletPoint('Suitability for every user or environment; or', bodyStyle),
        _buildBulletPoint('Successful performance on every device.', bodyStyle),
        const SizedBox(height: 12),
        Text(
          'The application is designed to support the user\'s visual interpretation, not replace it.',
          style: bodyStyle,
          textAlign: TextAlign.justify,
        ),
        const SizedBox(height: 24),

        Text('16. Limitation of Responsibility', style: headingStyle),
        const SizedBox(height: 8),
        Text(
          'To the extent permitted by applicable law, the developers and researchers of GabEye shall not be responsible for harm, loss, injury, or damage resulting from:',
          style: bodyStyle,
          textAlign: TextAlign.justify,
        ),
        const SizedBox(height: 12),
        _buildBulletPoint('Reliance on an incorrect or incomplete application result;', bodyStyle),
        _buildBulletPoint('Use of GabEye in unsafe or prohibited situations;', bodyStyle),
        _buildBulletPoint('Failure to follow safety instructions;', bodyStyle),
        _buildBulletPoint('Device malfunction or limitations;', bodyStyle),
        _buildBulletPoint('Environmental conditions that affect recognition or color processing; or', bodyStyle),
        _buildBulletPoint('Use of GabEye as a substitute for professional medical, occupational, transportation, or safety-related judgment.', bodyStyle),
        const SizedBox(height: 12),
        Text(
          'Nothing in these Terms and Conditions is intended to remove rights or protections that cannot legally be excluded.',
          style: bodyStyle,
          textAlign: TextAlign.justify,
        ),
        const SizedBox(height: 24),

        Text('17. Changes to These Terms', style: headingStyle),
        const SizedBox(height: 8),
        Text(
          'These Terms and Conditions may be updated when necessary to reflect changes to GabEye, its features, security practices, applicable requirements, or other aspects of the application.\n\nWhen material changes are made, the updated Terms and Conditions may be presented within the application.\n\nYour continued use of GabEye after an updated version becomes effective constitutes acceptance of the revised Terms and Conditions, to the extent permitted by applicable law.',
          style: bodyStyle,
          textAlign: TextAlign.justify,
        ),
        const SizedBox(height: 24),

        Text('18. Termination or Discontinuation', style: headingStyle),
        const SizedBox(height: 8),
        Text(
          'You may stop using GabEye at any time.\n\nYou may also uninstall the application or clear its application data through your device settings.\n\nBecause GabEye is designed to store certain profile and personalization information locally, uninstalling the application or clearing its stored application data may result in the permanent loss of locally stored assessment results, preferences, and profile information.\n\nThe developers may suspend or discontinue access to all or part of the application when reasonably necessary for maintenance, development, safety, security, or other legitimate purposes.',
          style: bodyStyle,
          textAlign: TextAlign.justify,
        ),
        const SizedBox(height: 24),

        Text('19. Acceptance of These Terms', style: headingStyle),
        const SizedBox(height: 8),
        Text(
          'By selecting "I Accept," "Agree," or the equivalent acceptance option, you confirm that:',
          style: bodyStyle,
          textAlign: TextAlign.justify,
        ),
        const SizedBox(height: 12),
        _buildBulletPoint('1. You have read and understood these Terms and Conditions;', bodyStyle, overrideBullet: false),
        _buildBulletPoint('2. You understand that GabEye is an assistive application and not a medical diagnostic or treatment tool;', bodyStyle, overrideBullet: false),
        _buildBulletPoint('3. You understand the limitations of the digital Farnsworth D-15 assessment;', bodyStyle, overrideBullet: false),
        _buildBulletPoint('4. You agree to use the application safely and responsibly;', bodyStyle, overrideBullet: false),
        _buildBulletPoint('5. You understand that automated color, object, text, and audio-assistance features may occasionally produce inaccurate results;', bodyStyle, overrideBullet: false),
        _buildBulletPoint('6. You understand that GabEye should not be used as the sole basis for safety-critical, medical, or professional decisions; and', bodyStyle, overrideBullet: false),
        _buildBulletPoint('7. You agree to comply with these Terms and Conditions while using GabEye.', bodyStyle, overrideBullet: false),
        const SizedBox(height: 12),
        Text(
          'By continuing to use GabEye, you acknowledge and accept these Terms and Conditions.',
          style: bodyStyle,
          textAlign: TextAlign.justify,
        ),
        const SizedBox(height: 24),

        Text('Important Reminder', style: headingStyle),
        const SizedBox(height: 8),
        RichText(
          textAlign: TextAlign.justify,
          text: TextSpan(
            style: GoogleFonts.atkinsonHyperlegibleNext(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
            children: const [
              TextSpan(
                text: 'GabEye is an assistive tool—',
              ),
              TextSpan(
                text: 'not a substitute for professional eye care, medical advice, or safe judgment.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text: ' When accuracy matters, always verify important information through an appropriate professional or reliable alternative source.',
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildBulletPoint(String text, TextStyle style, {bool overrideBullet = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (overrideBullet) Text('•  ', style: style.copyWith(fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(text, style: style, textAlign: TextAlign.justify),
          ),
        ],
      ),
    );
  }

  Widget _buildRichBulletPoint(
    List<InlineSpan> children,
    TextStyle style,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '•  ',
            style: style.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: RichText(
              textAlign: TextAlign.justify,
              text: TextSpan(
                style: style,
                children: children,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void showTermsAndConditionsModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
    ),
    builder: (BuildContext context) {
      return const TermsAndConditionsModal();
    },
  );
}
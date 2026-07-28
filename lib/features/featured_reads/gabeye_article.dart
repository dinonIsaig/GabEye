import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gabeye/components/article_navbar.dart';
import 'package:gabeye/core/theme/app_colors.dart';

class GabEyeArticleScreen extends StatelessWidget {
  const GabEyeArticleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            GabEyeNavbar(
              onBack: () => Navigator.maybePop(context),
              onMenu: () {},
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: const [
                    ArticleHeadingImage(),
                    MainContent(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ArticleHeadingImage extends StatelessWidget {
  const ArticleHeadingImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: SvgPicture.asset(
        'assets/images/articleHeading.svg',
        height: 120,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholderBuilder: (context) {
          return Container(
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.circular(24),
            ),
            alignment: Alignment.center,
            child: const Text(
              'Heading image placeholder',
              style: TextStyle(color: Colors.white),
            ),
          );
        },
      ),
    );
  }
}

class MainContent extends StatelessWidget {
  const MainContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -24),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            _BrandHeader(),
            SizedBox(height: 24),
            _Disclaimer(),
            SizedBox(height: 24),
            ImageRow(),
            SizedBox(height: 24),
            _Disclaimer(),
            SizedBox(height: 24),
            ImageRow(),
          ],
        ),
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'GabEye',
          style: textTheme.titleLarge?.copyWith(
            color: AppColors.primaryColor,
          ),
        ),
        Text(
          'Mobile Application Aid for Color Vision Deficiency',
          style: textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _Disclaimer extends StatelessWidget {
  const _Disclaimer();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final boldDisclaimerStyle = textTheme.bodyMedium?.copyWith(
      color: Theme.of(context).colorScheme.onSurface,
      fontWeight: FontWeight.bold,
    );

    return RichText(
      text: TextSpan(
        style: textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
        ),
        children: [
          const TextSpan(
            text: 'This assessment is for informational and digital '
                'optimization purposes only. ',
          ),
          TextSpan(
            text: 'It does not constitute a medical diagnosis. ',
            style: boldDisclaimerStyle,
          ),
          const TextSpan(
            text: 'For official vision certification, please consult a '
                'licensed optometrist.',
          ),
        ],
      ),
    );
  }
}

class ImageRow extends StatelessWidget {
  const ImageRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          'Article image placeholder',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}
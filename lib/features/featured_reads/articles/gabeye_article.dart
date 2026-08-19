import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gabeye/components/navbar/article_navbar.dart';
import 'package:gabeye/core/theme/app_colors.dart';
import '../settings/help_feedback_screen.dart';
import '../settings/gabeye_settings.dart';

// Models for article content
class FeatureItem {
  final String title;
  final VoidCallback onTap;

  FeatureItem({required this.title, required this.onTap});
}

class ArticleSection {
  final String? title;
  final String? description;
  final bool showImage;
  final String imageLabel;
  final List<FeatureItem>? features;

  ArticleSection({
    this.title,
    this.description,
    this.showImage = false,
    this.imageLabel = 'Article image placeholder',
    this.features,
  });
}

class ArticleContent {
  final String brandName;
  final String brandTagline;
  final List<ArticleSection> sections;

  ArticleContent({
    required this.brandName,
    required this.brandTagline,
    required this.sections,
  });

  factory ArticleContent.defaultContent(BuildContext context) {
    return ArticleContent(
      brandName: 'GabEye',
      brandTagline: 'Mobile Application Aid for Color Vision Deficiency',
      sections: [
        ArticleSection(
          title: 'About GabEye',
          description:
              'Color Vision Deficiency, or CVD, changes how a person distinguishes certain colors. '
              'Most people with CVD still see color, but some colors can look very similar.',
          showImage: true,
          imageLabel: 'GabEye and color vision deficiency image',
        ),
        ArticleSection(
          description:
              'GabEye is designed to help individuals with color vision deficiency navigate the world more easily. '
              "GabEye includes a digital Farnsworth D-15 pre-assessment. It helps identify whether the user's color difficulty is Protan, Deutan, or Tritan.",
          showImage: true,
          imageLabel: 'GabEye pre-assessment image',
        ),
        ArticleSection(
          title: 'Learn About CVD Types',
          description:
              'Learn how Protan, Deutan, and Tritan can affect color perception and how GabEye personalizes its assistance for each type.',
          showImage: true,
          imageLabel: 'CVD type comparison image',
          features: [
            FeatureItem(
              title: 'What is Protan?',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProtanArticleScreen(),
                  ),
                );
              },
            ),
            FeatureItem(
              title: 'What is Deutan?',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DeutanArticleScreen(),
                  ),
                );
              },
            ),
            FeatureItem(
              title: 'What is Tritan?',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TritanArticleScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  factory ArticleContent.protanContent() {
    return ArticleContent(
      brandName: 'Protan',
      brandTagline: 'Understanding Red-Green Color Vision Deficiency',
      sections: [
        ArticleSection(
          title: 'What is Protan?',
          description:
              'Protan is a type of red-green Color Vision Deficiency. It involves the L-cones, which are associated with sensitivity to red light.',
          showImage: true,
          imageLabel: 'Protan color comparison image',
        ),
        ArticleSection(
          title: 'What You Might Notice',
          description:
              'People with Protan have reduced or absent sensitivity to red. In more severe cases, red may appear very dark or almost black. '
              'Some colors can also become harder to separate from one another. This can affect color-dependent information in everyday situations.',
          showImage: true,
          imageLabel: 'Everyday Protan example image',
        ),
        ArticleSection(
          title: 'How Does GabEye Help You?',
          description:
              'GabEye is designed to recognize Protan as one of its supported CVD categories. '
              "The app can then personalize its visual assistance for that result based on the user's CVD profile.",
        ),
        ArticleSection(
          title: 'Remember',
          description:
              "GabEye's assessment helps personalize the application. It does not replace a professional eye examination or clinical diagnosis.",
        ),
      ],
    );
  }

  factory ArticleContent.deutanContent() {
    return ArticleContent(
      brandName: 'Deutan',
      brandTagline: 'Understanding Red-Green Color Vision Deficiency',
      sections: [
        ArticleSection(
          title: 'What is Deutan?',
          description:
              'Deutan is another type of red-green Color Vision Deficiency. It involves the M-cones, which are associated with sensitivity to green light.',
          showImage: true,
          imageLabel: 'Deutan color comparison image',
        ),
        ArticleSection(
          title: 'What You Might Notice',
          description:
              'People with Deutan may have difficulty separating red, orange, yellow, and green. Greens may sometimes appear muted, beige, or gray. '
              'The level of difficulty can vary between users. This makes personalized color assistance important for everyday tasks.',
          showImage: true,
          imageLabel: 'Everyday Deutan example image',
        ),
        ArticleSection(
          title: 'How Does GabEye Help You?',
          description:
              'GabEye can identify a Deutan result through its pre-assessment. '
              "It can then apply visual assistance based on the user's CVD profile.",
        ),
        ArticleSection(
          title: 'Remember',
          description:
              "GabEye's assessment helps personalize the application. It does not replace a professional eye examination or clinical diagnosis.",
        ),
      ],
    );
  }

  factory ArticleContent.tritanContent() {
    return ArticleContent(
      brandName: 'Tritan',
      brandTagline: 'Understanding Blue-Yellow Color Vision Deficiency',
      sections: [
        ArticleSection(
          title: 'What is Tritan?',
          description:
              'Tritan is a rarer type of Color Vision Deficiency. It affects the S-cones, which are associated with sensitivity to blue light.',
          showImage: true,
          imageLabel: 'Tritan color comparison image',
        ),
        ArticleSection(
          title: 'What You Might Notice',
          description:
              'A person with Tritan may have difficulty separating blue from green or yellow from violet. '
              "Blue may sometimes appear greenish. Yellow may appear gray or light purple, depending on the person's deficiency.",
          showImage: true,
          imageLabel: 'Everyday Tritan example image',
        ),
        ArticleSection(
          title: 'How Does GabEye Help You?',
          description:
              'GabEye supports Tritan alongside Protan and Deutan. '
              "Its personalized assistance can adapt according to the user's identified CVD type.",
        ),
        ArticleSection(
          title: 'Remember',
          description:
              "GabEye's assessment helps personalize the application. It does not replace a professional eye examination or clinical diagnosis.",
        ),
      ],
    );
  }
}

class GabEyeArticleScreen extends StatelessWidget {
  const GabEyeArticleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ArticleScreenLayout(
      navbarTitle: 'Know More About GabEye',
      content: ArticleContent.defaultContent(context),
    );
  }
}

class ProtanArticleScreen extends StatelessWidget {
  const ProtanArticleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ArticleScreenLayout(
      navbarTitle: 'About Protan',
      content: ArticleContent.protanContent(),
    );
  }
}

class DeutanArticleScreen extends StatelessWidget {
  const DeutanArticleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ArticleScreenLayout(
      navbarTitle: 'About Deutan',
      content: ArticleContent.deutanContent(),
    );
  }
}

class TritanArticleScreen extends StatelessWidget {
  const TritanArticleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ArticleScreenLayout(
      navbarTitle: 'About Tritan',
      content: ArticleContent.tritanContent(),
    );
  }
}

class ArticleScreenLayout extends StatelessWidget {
  final String navbarTitle;
  final ArticleContent content;

  const ArticleScreenLayout({
    super.key,
    required this.navbarTitle,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            GabEyeArticleNavbar(
              title: navbarTitle,
              onBack: () => Navigator.maybePop(context),
              onMenuSelected: (option) {
                if (option.label == 'Settings') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GabEyeSettingsScreen(),
                    ),
                  );
                } else if (option.label == 'Help & Feedback') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HelpFeedbackScreen(),
                    ),
                  );
                } else if (option.label == 'About GabEye') {
                  if (content.brandName == 'GabEye') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Already on About GabEye')),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GabEyeArticleScreen(),
                      ),
                    );
                  }
                }
              },
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const ArticleHeadingImage(),
                    MainContent(content: content),
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
  final ArticleContent content;

  const MainContent({super.key, required this.content});

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
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _BrandHeader(
              brandName: content.brandName,
              tagline: content.brandTagline,
            ),
            const SizedBox(height: 24),
            ..._buildSectionList(content.sections),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSectionList(List<ArticleSection> sections) {
    final widgets = <Widget>[];

    for (int i = 0; i < sections.length; i++) {
      widgets.add(ArticleSectionWidget(section: sections[i]));

      if (i < sections.length - 1) {
        widgets.add(const SizedBox(height: 24));
      }
    }

    return widgets;
  }
}

class _BrandHeader extends StatelessWidget {
  final String brandName;
  final String tagline;

  const _BrandHeader({required this.brandName, required this.tagline});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          brandName,
          style: textTheme.titleLarge?.copyWith(
            color: AppColors.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          tagline,
          style: textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class ArticleSectionWidget extends StatelessWidget {
  final ArticleSection section;

  const ArticleSectionWidget({super.key, required this.section});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (section.title != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              section.title!,
              style: textTheme.titleMedium?.copyWith(
                color: AppColors.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        if (section.description != null)
          Text(
            section.description!,
            style: textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              height: 1.6,
            ),
          ),
        if (section.showImage) ...[
          const SizedBox(height: 24),
          if (section.features != null && section.features!.isNotEmpty)
            FeatureContainerGroup(features: section.features!)
          else
            ImageRow(label: section.imageLabel),
        ],
      ],
    );
  }
}

class FeatureContainerGroup extends StatelessWidget {
  final List<FeatureItem> features;

  const FeatureContainerGroup({super.key, required this.features});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        features.length,
        (index) => Padding(
          padding: EdgeInsets.only(
            bottom: index < features.length - 1 ? 12 : 0,
          ),
          child: FeatureContainer(feature: features[index]),
        ),
      ),
    );
  }
}

class FeatureContainer extends StatefulWidget {
  final FeatureItem feature;

  const FeatureContainer({super.key, required this.feature});

  @override
  State<FeatureContainer> createState() => _FeatureContainerState();
}

class _FeatureContainerState extends State<FeatureContainer> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.feature.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: _isHovered
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.15),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.feature.title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.arrow_forward_ios,
                color: AppColors.primaryColor,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ImageRow extends StatelessWidget {
  final String label;

  const ImageRow({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}

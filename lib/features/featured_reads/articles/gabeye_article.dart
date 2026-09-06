import 'package:flutter/material.dart';
import 'package:gabeye/components/navbar/article_navbar.dart';
import 'package:gabeye/core/routing/app_routes.dart';
import 'package:gabeye/core/theme/app_colors.dart';
import 'package:gabeye/features/assessment/widgets/pre_assessment_hero_header.dart';
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
  final String? imagePath;
  final List<FeatureItem>? features;
  final ComparisonTable? table;

  ArticleSection({
    this.title,
    this.description,
    this.showImage = false,
    this.imageLabel = 'Article image placeholder',
    this.imagePath,
    this.features,
    this.table,
  });
}

// Simple row/column comparison table (e.g. Ishihara vs. D-15).
class ComparisonTable {
  final List<String> columnHeaders; // e.g. ['', 'Ishihara (dot test)', 'This test (D-15)']
  final List<List<String>> rows; // each row: [rowLabel, col1Value, col2Value]

  ComparisonTable({required this.columnHeaders, required this.rows});
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
          imagePath: 'assets/images/cvd_cover.png',
        ),
        ArticleSection(
          description:
              'GabEye is designed to help individuals with color vision deficiency navigate the world more easily. '
              "GabEye includes a digital Farnsworth D-15 pre-assessment. It helps identify whether the user's color difficulty is Protan, Deutan, or Tritan.",
          showImage: true,
          imageLabel: 'GabEye pre-assessment image',
          imagePath: 'assets/images/gabeye_cover.png',
        ),
        ArticleSection(
          title: 'Learn About Your Assessment',
          description:
              'Before GabEye personalizes itself for you, it asks you to sort a few colors. Learn how this works and what your results mean.',
          showImage: true,
          imageLabel: 'Farnsworth D-15 assessment image',
          features: [
            FeatureItem(
              title: 'What is the Farnsworth D-15 Test?',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FarnsworthD15ArticleScreen(),
                  ),
                );
              },
            ),
          ],
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
          imagePath: 'assets/images/nv_protan.png',
        ),
        ArticleSection(
          title: 'What You Might Notice',
          description:
              'People with Protan have reduced or absent sensitivity to red. In more severe cases, red may appear very dark or almost black. '
              'Some colors can also become harder to separate from one another. This can affect color-dependent information in everyday situations.',
          showImage: true,
          imageLabel: 'Everyday Protan example image',
          imagePath: 'assets/images/ev_protan.png',
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
          imagePath: 'assets/images/nv_deutan.png',
        ),
        ArticleSection(
          title: 'What You Might Notice',
          description:
              'People with Deutan may have difficulty separating red, orange, yellow, and green. Greens may sometimes appear muted, beige, or gray. '
              'The level of difficulty can vary between users. This makes personalized color assistance important for everyday tasks.',
          showImage: true,
          imageLabel: 'Everyday Deutan example image',
          imagePath: 'assets/images/ev_deutan.png',
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
          imagePath: 'assets/images/nv_tritan.png',
        ),
        ArticleSection(
          title: 'What You Might Notice',
          description:
              'A person with Tritan may have difficulty separating blue from green or yellow from violet. '
              "Blue may sometimes appear greenish. Yellow may appear gray or light purple, depending on the person's deficiency.",
          showImage: true,
          imageLabel: 'Everyday Tritan example image',
          imagePath: 'assets/images/ev_tritan.png',
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

  factory ArticleContent.farnsworthD15Content() {
    return ArticleContent(
      brandName: 'Farnsworth D-15',
      brandTagline: 'Understanding Your Pre-Assessment',
      sections: [
        ArticleSection(
          title: 'What is the Farnsworth D-15 Test?',
          description:
              "It's a simple color sorting test. You arrange 15 colored discs in order, "
              'from one color to the next.',
          showImage: true,
          imageLabel: 'Farnsworth D-15 color discs image',
          imagePath: 'assets/images/farnsworth_cover.jpg',
        ),
        ArticleSection(
          description:
              'No numbers to spot, no letters to squint at. Just sort the colors.',
        ),
        ArticleSection(
          title: 'How Does It Figure Out My CVD Type?',
          description:
              'Everyone\'s eyes see color differently. Sorting reveals which colors are hardest for you to tell apart. This pattern shows whether you have Protanopia (red), Deuteranopia (green), or Tritanopia (blue-yellow).',
        ),
        ArticleSection(
          title: 'How Is It Different From Other Tests?',
          description:
              'You may have taken the Ishihara test before, the one with colored dots hiding a number inside.',
          table: ComparisonTable(
            columnHeaders: const ['', 'Ishihara (dot test)', 'Farnsworth (D-15)'],
            rows: const [
              [
                'What it catches',
                'Mostly red green issues',
                'Red green and blue yellow issues',
              ],
              ['What you do', 'Spot a number', 'Sort discs by color'],
            ],
          ),
        ),
        ArticleSection(
          title: 'Remember',
          description:
              "GabEye's assessment helps personalize the application. It does not replace a professional eye exam or diagnosis For an official diagnosis, see an eye doctor. For using the app, your results here are enough..",
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
      heroTitle: 'About GabEye',
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
      heroTitle: 'About Protan',
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
      heroTitle: 'About Deutan',
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
      heroTitle: 'About Tritan',
      content: ArticleContent.tritanContent(),
    );
  }
}

class FarnsworthD15ArticleScreen extends StatelessWidget {
  const FarnsworthD15ArticleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ArticleScreenLayout(
      navbarTitle: 'About the D-15 Test',
      heroTitle: 'About the Farnsworth D-15',
      content: ArticleContent.farnsworthD15Content(),
      actionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: ElevatedButton(
          onPressed: () =>
              Navigator.pushNamed(context, AppRoutes.preAssessmentHowItWorks),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 55),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          child: const Text(
            'Take Assessment',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

class ArticleScreenLayout extends StatelessWidget {
  final String navbarTitle;
  final String heroTitle;
  final ArticleContent content;
  final Widget? actionButton;

  const ArticleScreenLayout({
    super.key,
    required this.navbarTitle,
    required this.heroTitle,
    required this.content,
    this.actionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: GabEyeArticleNavbar(
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
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PreAssessmentHeroHeader(title: heroTitle),
              MainContent(content: content, overlapHeading: false),
              ?actionButton,
            ],
          ),
        ),
      ),
    );
  }
}

class MainContent extends StatelessWidget {
  final ArticleContent content;
  final bool overlapHeading;

  const MainContent({
    super.key,
    required this.content,
    this.overlapHeading = true,
  });

  @override
  Widget build(BuildContext context) {
    final contentContainer = Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: overlapHeading
            ? const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              )
            : null,
        boxShadow: overlapHeading
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                ),
              ]
            : null,
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
    );

    if (!overlapHeading) {
      return contentContainer;
    }

    return Transform.translate(
      offset: const Offset(0, -24),
      child: contentContainer,
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
          style: (textTheme.titleLarge ??
                  const TextStyle(fontFamily: 'Inter'))
              .copyWith(
            fontFamily: 'Inter',
            fontSize: 32,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : AppColors.primaryColor,
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
    if (section.title?.toLowerCase() == 'remember') {
      return RememberCard(
        title: section.title!,
        text: section.description ?? '',
      );
    }

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
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : AppColors.primaryColor,
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
        if (section.table != null) ...[
          const SizedBox(height: 16),
          ComparisonTableWidget(table: section.table!),
        ],
        if (section.showImage) ...[
          const SizedBox(height: 24),
          if (section.features != null && section.features!.isNotEmpty)
            FeatureContainerGroup(features: section.features!)
          else
            ImageRow(label: section.imageLabel, imagePath: section.imagePath),
        ],
      ],
    );
  }
}

class RememberCard extends StatelessWidget {
  final String title;
  final String text;

  const RememberCard({super.key, required this.title, required this.text});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentRed = isDark ? const Color(0xFFFFB4AB) : AppColors.errorRed;
    final bgRed = isDark
        ? AppColors.errorRed.withValues(alpha: 0.18)
        : AppColors.errorRed.withValues(alpha: 0.08);
    final borderRed = isDark
        ? const Color(0xFFFFB4AB).withValues(alpha: 0.35)
        : AppColors.errorRed.withValues(alpha: 0.25);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: bgRed,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderRed),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: accentRed, size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: accentRed,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (text.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    text,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      height: 1.6,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
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
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withValues(alpha: 0.35)
                  : AppColors.primaryNavy.withValues(alpha: 0.45),
              width: 1.2,
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
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : AppColors.primaryColor,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ComparisonTableWidget extends StatelessWidget {
  final ComparisonTable table;

  const ComparisonTableWidget({super.key, required this.table});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final borderColor = Theme.of(
      context,
    ).colorScheme.outlineVariant.withValues(alpha: 0.6);

    TableRow buildRow(List<String> cells, {bool isHeader = false}) {
      return TableRow(
        decoration: BoxDecoration(
          color: isHeader
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.08)
              : Colors.transparent,
        ),
        children: cells
            .asMap()
            .entries
            .map(
              (entry) {
                final index = entry.key;
                final cell = entry.value;
                final isFirstColumn = index == 0;
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  child: Text(
                    cell,
                    style: (textTheme.bodyMedium ??
                            const TextStyle(
                              fontFamily: 'AtkinsonHyperlegible',
                              fontSize: 16,
                            ))
                        .copyWith(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: (isHeader || isFirstColumn)
                          ? FontWeight.bold
                          : FontWeight.normal,
                      height: 1.4,
                    ),
                  ),
                );
              },
            )
            .toList(),
      );
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(0.9),
          1: FlexColumnWidth(1.1),
          2: FlexColumnWidth(1.1),
        },
        border: TableBorder(
          horizontalInside: BorderSide(color: borderColor),
        ),
        children: [
          buildRow(table.columnHeaders, isHeader: true),
          for (final row in table.rows) buildRow(row),
        ],
      ),
    );
  }
}

class ImageRow extends StatelessWidget {
  final String label;
  final String? imagePath;

  const ImageRow({super.key, required this.label, this.imagePath});

  @override
  Widget build(BuildContext context) {
    if (imagePath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(
          imagePath!,
          height: 120,
          width: double.infinity,
          fit: BoxFit.cover,
          semanticLabel: label,
        ),
      );
    }

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
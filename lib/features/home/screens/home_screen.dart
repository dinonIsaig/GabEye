import 'package:flutter/material.dart';
import 'package:gabeye/components/navbar/home_navbar.dart';
import 'package:gabeye/core/routing/app_routes.dart';
import 'package:gabeye/core/utils/responsive.dart';
import 'package:gabeye/features/assessment/screens/color_vision_profile_lookback_screen.dart';
import 'package:gabeye/features/assessment/services/assessment_controller.dart';
import 'package:gabeye/features/featured_reads/articles/gabeye_article.dart';
import 'package:gabeye/features/home/widgets/feature_row.dart';
import 'package:gabeye/features/home/widgets/featured_reads_section.dart';
import 'package:gabeye/features/home/widgets/gabeye_bottom_nav.dart';
import 'package:gabeye/features/home/widgets/hero_section.dart';
import 'package:gabeye/features/home/widgets/vision_profile_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  List<FeatureRowData> _getFeatures(BuildContext context) {
    return [
      FeatureRowData(
        icon: Icons.videocam_outlined,
        title: 'Real-Time and Static Visual Processing',
        bullets: const [
          'Live camera feeds',
          'Uploaded images',
          'Color remapping and identification',
        ],
        ctaLabel: 'Try Using Camera',
        onCtaPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Live Camera Visual Processing coming soon!'),
            ),
          );
        },
      ),
      FeatureRowData(
        icon: Icons.tune,
        title: 'Personalized Accessibility',
        bullets: const [
          'UI themes',
          'Color filters',
          'Accessibility settings',
        ],
        ctaLabel: 'Configure in Settings',
        onCtaPressed: () {
          Navigator.pushNamed(context, AppRoutes.settings);
        },
      ),
      FeatureRowData(
        icon: Icons.science_outlined,
        title: 'Color Diagnostic Assessment',
        bullets: const [
          'Farnsworth D-15 test',
          'Deficiency type detection',
          'Saved vision profile',
        ],
        ctaLabel: 'View Vision Profile',
        onCtaPressed: () {
          _onBottomNavTapped(2);
        },
      ),
      FeatureRowData(
        icon: Icons.volume_up_outlined,
        title: 'Audio & Contextual Feedback',
        bullets: const [
          'Spoken color names',
          'Haptic cues',
          'Context-aware alerts',
        ],
        ctaLabel: 'Learn More',
        onCtaPressed: () {
          Navigator.pushNamed(context, AppRoutes.article);
        },
      ),
    ];
  }

  List<VisionProfileData> _getReads(BuildContext context) {
    return [
      VisionProfileData(
        title: 'Farnsworth D-15',
        description:
            'The Farnsworth D-15 is a quick color arrangement test designed to screen for moderate to severe color vision deficiencies.',
        imageAsset: 'assets/images/farnsworth_cover.jpg',
        ctaLabel: 'Read more',
        onReadMore: (ctx) => Navigator.push(
          ctx,
          MaterialPageRoute(
            builder: (_) => const FarnsworthD15ArticleScreen(),
          ),
        ),
      ),
      VisionProfileData(
        title: 'Protan',
        description:
            'Also known as red-blindness, Protanopia is a deficiency where the long-wavelength (red) cone photoreceptors are absent.',
        imageAsset: 'assets/images/ev_protan.png',
        ctaLabel: 'Read more',
        onReadMore: (ctx) => Navigator.push(
          ctx,
          MaterialPageRoute(
            builder: (_) => const ProtanArticleScreen(),
          ),
        ),
      ),
      VisionProfileData(
        title: 'Deutan',
        description:
            'Deutan (green-blindness) affects the medium-wavelength cones responsible for perceiving green light.',
        imageAsset: 'assets/images/ev_deutan.png',
        ctaLabel: 'Read more',
        onReadMore: (ctx) => Navigator.push(
          ctx,
          MaterialPageRoute(
            builder: (_) => const DeutanArticleScreen(),
          ),
        ),
      ),
      VisionProfileData(
        title: 'Tritan',
        description:
            'Tritan (blue-yellow deficiency) is a rarer condition affecting the short-wavelength cone photoreceptors.',
        imageAsset: 'assets/images/ev_tritan.png',
        ctaLabel: 'Read more',
        onReadMore: (ctx) => Navigator.push(
          ctx,
          MaterialPageRoute(
            builder: (_) => const TritanArticleScreen(),
          ),
        ),
      ),
    ];
  }

  void _onBottomNavTapped(int index) {
    if (index == 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Camera feature coming soon!'),
        ),
      );
      return;
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final features = _getFeatures(context);
    final reads = _getReads(context);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: GabEyeHomeNavbar(
          onBack: () {
            if (_selectedIndex != 0) {
              setState(() {
                _selectedIndex = 0;
              });
            } else if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
          onLogoTap: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.getStarted,
              (route) => false,
            );
          },
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          SafeArea(
            child: ListView(
              padding: Responsive.symmetricH(context, base: 16, min: 12, max: 24)
                  .copyWith(top: 20, bottom: 20),
              children: [
                HeroSection(
                  onKnowMoreTap: () {
                    Navigator.pushNamed(context, AppRoutes.article);
                  },
                ),
                SizedBox(height: Responsive.space(context, base: 32, min: 20, max: 40)),
                Text(
                  'Core Features',
                  style: (theme.textTheme.headlineSmall ??
                          const TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.bold,
                          ))
                      .copyWith(
                        fontSize: Responsive.font(context, base: 24, min: 18, max: 28),
                      ),
                ),
                SizedBox(height: Responsive.space(context, base: 16, min: 12, max: 22)),
                ...features.map(
                  (f) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: FeatureRow(data: f),
                  ),
                ),
                SizedBox(height: Responsive.space(context, base: 32, min: 20, max: 40)),
                FeaturedReadsSection(reads: reads),
                SizedBox(height: Responsive.space(context, base: 20, min: 14, max: 28)),
              ],
            ),
          ),
          const SizedBox.shrink(),
          ValueListenableBuilder<List<int>>(
            valueListenable: assessmentController,
            builder: (context, arrangedCaps, _) => SafeArea(
              child: ColorVisionProfileLookbackContent(
                arrangedCaps: arrangedCaps,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: GabEyeBottomNav(
        selectedIndex: _selectedIndex,
        onItemSelected: _onBottomNavTapped,
      ),
    );
  }
}

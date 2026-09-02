import 'package:flutter/material.dart';
import 'package:gabeye/components/navbar/home_navbar.dart';
import 'package:gabeye/core/routing/app_routes.dart';
import 'package:gabeye/features/home/screens/home_dashboard_screen.dart';
import 'package:gabeye/features/home/screens/profile_screen.dart';
import 'package:gabeye/features/home/screens/vision_lens_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 1; // 0: Home (Dashboard), 1: Vision Lens (Camera), 2: Profile

  void _onLaunchCamera() {
    setState(() {
      _currentIndex = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top Header Bar
            GabEyeHomeNavbar(
              onBack: () {
                setState(() {
                  _currentIndex = 0; // Redirect to Home tab overview
                });
              },
              onMenuSelected: (option) {
                switch (option.label) {
                  case 'Settings':
                    Navigator.pushNamed(context, AppRoutes.settings);
                    break;
                  case 'Help & Feedback':
                    Navigator.pushNamed(context, AppRoutes.helpFeedback);
                    break;
                  case 'About GabEye':
                    Navigator.pushNamed(context, AppRoutes.article);
                    break;
                }
              },
            ),

            // Main Active Screen Viewport (Home Dashboard, Vision Lens, or Profile)
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: [
                  HomeDashboardScreen(onLaunchCamera: _onLaunchCamera),
                  const VisionLensScreen(),
                  const ProfileScreen(),
                ],
              ),
            ),

            // Bottom Navigation Bar Widget
            _buildBottomNavigationBar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              index: 0,
              icon: Icons.home_outlined,
              activeIcon: Icons.home_rounded,
              label: 'Home',
              colors: colors,
            ),
            _buildNavItem(
              index: 1,
              icon: Icons.camera_alt_outlined,
              activeIcon: Icons.camera_alt_rounded,
              label: 'Vision Lens',
              colors: colors,
            ),
            _buildNavItem(
              index: 2,
              icon: Icons.person_outline_rounded,
              activeIcon: Icons.person_rounded,
              label: 'Profile',
              colors: colors,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required ColorScheme colors,
  }) {
    final isSelected = _currentIndex == index;

    if (isSelected) {
      return GestureDetector(
        onTap: () => setState(() => _currentIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: colors.primary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                activeIcon,
                size: 20,
                color: colors.onPrimary,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: colors.onPrimary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: colors.onSurfaceVariant,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:math' as math;
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gabeye/core/routing/app_routes.dart';
import 'package:gabeye/components/navbar/home_navbar.dart';
import 'package:gabeye/core/theme/app_colors.dart';
import 'package:gabeye/core/theme/gabeye_theme.dart';
import 'package:gabeye/features/assessment/models/cap.dart';
import 'package:gabeye/features/assessment/screens/assessment_summary_screen.dart';
import 'package:gabeye/features/assessment/screens/results_screen.dart';
import 'package:gabeye/features/assessment/services/assessment_controller.dart';
import 'package:gabeye/features/assessment/widgets/assessment_intro_modal.dart';
import 'package:gabeye/features/assessment/widgets/debug_test_panel_modal.dart';
import 'package:gabeye/features/featured_reads/articles/gabeye_article.dart';
import 'package:gabeye/features/featured_reads/settings/gabeye_settings.dart';
import 'package:gabeye/features/featured_reads/settings/help_feedback_screen.dart';

class CapDragData {
  final int capNum;
  final int? sourceSlotIdx; // null if coming from the pool
  const CapDragData({required this.capNum, this.sourceSlotIdx});
}

class AssessmentScreen extends StatefulWidget {
  const AssessmentScreen({super.key});

  @override
  State<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen> {
  late List<int?> _arrangedCaps; // 15 slots: indices 0-14 map to grid slots 1-15
  late List<int> _poolCaps; // Remaining unplaced caps, shown in "Select Next Color"

  @override
  void initState() {
    super.initState();
    _resetTest();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showAssessmentIntroModal(context);
    });
  }

  void _resetTest() {
    setState(() {
      _arrangedCaps = List<int?>.filled(15, null);

      _poolCaps = List<int>.generate(15, (i) => i + 1);

      // Shuffle the pool (Fisher-Yates shuffle)
      final random = math.Random();
      for (int i = _poolCaps.length - 1; i > 0; i--) {
        final j = random.nextInt(i + 1);
        final temp = _poolCaps[i];
        _poolCaps[i] = _poolCaps[j];
        _poolCaps[j] = temp;
      }
    });
  }

// Debugging/Testing. Wired to the floating testing-panel button below.
void _applyDebugProfile(List<int> caps) {
  setState(() {
    _arrangedCaps = List<int?>.from(caps);
    _poolCaps = [];
  });
}

// Tapping a cap in the pool
  void _placeNextCap(int capNum) {
    // Find the first empty slot in the tray
    final firstEmptyIdx = _arrangedCaps.indexOf(null);

    // If all 15 slots are full, do nothing
    if (firstEmptyIdx == -1) return;

    setState(() {
      _poolCaps.remove(capNum);
      _arrangedCaps[firstEmptyIdx] = capNum;
    });
  }

// Tapping a cap in the tray
  void _removeCapFromSlot(int slotIdx, int capNum) {
    setState(() {
      _poolCaps.add(capNum);
      _arrangedCaps[slotIdx] = null;
    });
  }

// Drag & drop logic
  void _handleDrop(CapDragData dragData, int targetIdx) {
    setState(() {
      final draggedCapNum = dragData.capNum;
      final sourceIdx = dragData.sourceSlotIdx;
      final existingTargetCap = _arrangedCaps[targetIdx];

      if (sourceIdx == null) {
        // Dragged from Pool to Tray
        _poolCaps.remove(draggedCapNum);
        if (existingTargetCap != null) {
          // If slot was occupied, send the old cap back to the pool
          _poolCaps.add(existingTargetCap);
        }
        _arrangedCaps[targetIdx] = draggedCapNum;
      } else {
        // Dragged from Tray to Tray (Swap mechanism)
        _arrangedCaps[sourceIdx] = existingTargetCap; // can be null
        _arrangedCaps[targetIdx] = draggedCapNum;
      }
    });
  }

  bool get _isTestComplete => !_arrangedCaps.contains(null);

@override
  Widget build(BuildContext context) {
    // wraps screen to make assessment in dark mode
    return Theme(
      data: GabEyeTheme.darkTheme,
      child: Builder(
        builder: (context) {
          final colors = Theme.of(context).colorScheme;
          final textTheme = Theme.of(context).textTheme; 

          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(64),
              child: GabEyeHomeNavbar(
                onBack: () => Navigator.pop(context),
              ),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHowItWorksPill(colors),
                    const SizedBox(height: 20),
                    _buildAssessmentCard(colors, textTheme),
                    const SizedBox(height: 20),
                    _buildFooterButtons(colors),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
              floatingActionButton: kDebugMode
                  ? FloatingActionButton(
                    onPressed: () => showDebugTestPanel(context, onProfileSelected: _applyDebugProfile),
                    child: const Icon(Icons.bug_report),
                  )
              : null,
          );
        },
      ),
    );
  }

  Widget _buildTopBar(ColorScheme colors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          customBorder: const CircleBorder(),
          onTap: () => Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.getStarted,
            (route) => false,
          ),
          child: CircleAvatar(
            radius: 20,
            backgroundColor: Colors.transparent,
            child: SvgPicture.asset('assets/images/gabEyeLogo.svg', fit: BoxFit.contain),
          ),
        ),
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: colors.onSurface),
          color: colors.surface, 
          onSelected: (String value) {
            if (value == 'Settings') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const GabEyeSettingsScreen(),
                ),
              );
            } else if (value == 'Help & Feedback') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HelpFeedbackScreen(),
                ),
              );
            } else if (value == 'About GabEye') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const GabEyeArticleScreen(),
                ),
              );
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'Settings',
              child: Text('Settings'),
            ),
            const PopupMenuItem<String>(
              value: 'Help & Feedback',
              child: Text('Help & Feedback'),
            ),
            const PopupMenuItem<String>(
              value: 'About GabEye',
              child: Text('About GabEye'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStartHeader(ColorScheme colors, TextTheme textTheme) {
    return Row(
      children: [
        const Spacer(),
        const SizedBox(width: 10),
        Expanded(
          child: Center(
            child: Text(
              'Start',
              style: textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        const Spacer(),
        const SizedBox(width: 10),
        const Spacer(),
      ],
    );
  }

  Widget _buildHowItWorksPill(ColorScheme colors) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return OutlinedButton.icon(
      onPressed: () {Navigator.popAndPushNamed(context, AppRoutes.preAssessmentIntro);}, 
      icon: const Icon(Icons.help_outline, size: 16),
      label: const Text('How it works?', style: TextStyle(fontWeight: FontWeight.bold)),
      style: OutlinedButton.styleFrom(
        foregroundColor: isDark ? AppColors.darkSurface : colors.onSurface,
        backgroundColor: isDark ? AppColors.darkPrimaryButton : Colors.transparent,
        side: isDark ? BorderSide.none : BorderSide(color: colors.onSurfaceVariant.withOpacity(0.3)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
    );
  }

  Widget _buildAssessmentCard(ColorScheme colors, TextTheme textTheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          _buildStartHeader(colors, textTheme),
          const SizedBox(height: 16),
          _buildStartGrid(colors),
          const SizedBox(height: 20),
          Divider(
            color: colors.onSurfaceVariant.withOpacity(0.15),
            height: 1,
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Select Next Color',
              style: textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildPoolGrid(colors, textTheme),
        ],
      ),
    );
  }

  Widget _buildStartGrid(ColorScheme colors) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 16, // 1 fixed pilot cell + 15 arrangement slots
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildPilotCell(colors);
        }
        final slotIdx = index - 1;
        return _buildTargetSlotCell(slotIdx, colors);
      },
    );
  }

  Widget _buildPilotCell(ColorScheme colors) {
    return Container(
      decoration: BoxDecoration(
        color: ColorCap.getVisualColor(0),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white, width: 2),
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: const FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          'FIXED',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

Widget _buildTargetSlotCell(int slotIdx, ColorScheme colors) {
    return DragTarget<CapDragData>(
      onAcceptWithDetails: (details) => _handleDrop(details.data, slotIdx),
      builder: (context, candidateData, rejectedData) {
        final isHovered = candidateData.isNotEmpty;
        final capNum = _arrangedCaps[slotIdx];

        // Empty slot placeholder
        if (capNum == null) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: isHovered
                  ? colors.primary.withOpacity(0.2) // Highlight on drag hover
                  : colors.onSurfaceVariant.withOpacity(0.05),
              border: Border.all(
                color: isHovered
                    ? colors.primary
                    : Colors.white,
                width: isHovered ? 2 : 1,
              ),
            ),
            alignment: Alignment.center,
            child: Icon(Icons.add, size: 18, color: colors.onSurfaceVariant.withOpacity(0.4)),
          );
        }

        // Occupied Slot -> Allow dragging out, or tapping to remove
        return Draggable<CapDragData>(
          data: CapDragData(capNum: capNum, sourceSlotIdx: slotIdx),
          feedback: Material(
            color: Colors.transparent,
            child: _buildVisualCap(capNum, size: 65),
          ),
          childWhenDragging: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: colors.onSurfaceVariant.withOpacity(0.05),
              border: Border.all(color: colors.onSurfaceVariant.withOpacity(0.3)),
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => _removeCapFromSlot(slotIdx, capNum),
            child: _buildVisualCap(capNum),
          ),
        );
      },
    );
  }

  Widget _buildPoolGrid(ColorScheme colors, TextTheme textTheme) {
    if (_poolCaps.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Text(
          'All caps placed — ready to finish!',
          style: textTheme.bodyMedium?.copyWith(
            color: colors.onSurfaceVariant,
            fontFamily: 'Inter',
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _poolCaps.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        final capNum = _poolCaps[index];

        return Draggable<CapDragData>(
          data: CapDragData(capNum: capNum, sourceSlotIdx: null),
          feedback: Material(
            color: Colors.transparent,
            child: _buildVisualCap(capNum, size: 65, isPool: true),
          ),
          childWhenDragging: Opacity(
            opacity: 0.3,
            child: _buildVisualCap(capNum, isPool: true),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => _placeNextCap(capNum),
            child: _buildVisualCap(capNum, isPool: true),
          ),
        );
      },
    );
  }

  // Helper widget to render the actual colored square uniformly
  Widget _buildVisualCap(int capNum, {double? size, bool isPool = false}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: ColorCap.getVisualColor(capNum),
        borderRadius: BorderRadius.circular(14),
        border: isPool ? Border.all(color: Colors.white) : null,
      ),
      alignment: Alignment.center,
      child: isPool ? const Icon(Icons.open_with, size: 14, color: Colors.white70) : null,
    );
  }

  Widget _buildFooterButtons(ColorScheme colors) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        ElevatedButton(
          onPressed: _isTestComplete
          ? () {
              final caps = _arrangedCaps.cast<int>();
              assessmentController.setArrangedCaps(caps);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AssessmentSummaryScreen(
                    arrangedCaps: caps,
                  ),
                ),
              );
            }
          : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: isDark ? AppColors.darkPrimaryButton : AppColors.lightPrimaryButton,
            foregroundColor: isDark ? AppColors.darkSurface : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            minimumSize: const Size(double.infinity, 55),
            elevation: _isTestComplete ? 4 : 0,
          ),
          child: const Text(
            'Finish Assessment', 
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Inter'),
          ),
        ),
        const SizedBox(height: 10),
        OutlinedButton(
          onPressed: _resetTest,
          style: OutlinedButton.styleFrom(
            foregroundColor: isDark ? AppColors.darkSurface : colors.onSurface,
            backgroundColor: isDark ? AppColors.darkPrimaryButton : Colors.transparent,
            side: isDark ? BorderSide.none : BorderSide(color: colors.onSurfaceVariant.withOpacity(0.3)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            minimumSize: const Size(double.infinity, 55),
          ),
          child: const Text(
            'Start Over', 
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Inter'), 
          ),
        ),
        
      ],
    );
  }
}
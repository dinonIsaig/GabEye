import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gabeye/features/assessment/models/cap.dart';
import 'package:gabeye/features/assessment/screens/results_screen.dart';
import 'package:gabeye/core/theme/gabeye_theme.dart';
import 'package:gabeye/features/assessment/widgets/assessment_intro_modal.dart';
import 'package:gabeye/features/assessment/screens/assessment_summary_screen.dart';


// --- Data class to track the dragged cap's origin ---
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
    // Wait until the first frame is fully built, then show modal
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

// Tapping a cap in the pool
  void _placeNextCap(int capNum) {
    setState(() {
      final firstEmptyIdx = _arrangedCaps.indexOf(null);
      if (firstEmptyIdx != -1) {
        _arrangedCaps[firstEmptyIdx] = capNum;
        _poolCaps.remove(capNum);
      }
    });
  }

// Tapping a cap in the tray
  void _removeCapFromSlot(int slotIdx, int capNum) {
    setState(() {
      _poolCaps.add(capNum);
      _arrangedCaps[slotIdx] = null;
    });
  }

// --- Drag & Drop Logic ---
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

          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTopBar(colors),
                    const SizedBox(height: 16),
                    _buildHowItWorksPill(colors),
                    const SizedBox(height: 20),
                    _buildAssessmentCard(colors),
                    const SizedBox(height: 20),
                    _buildFooterButtons(colors),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

// To be replaced with alr made nav bar
  Widget _buildTopBar(ColorScheme colors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: Colors.transparent,
          child:  SvgPicture.asset('assets/images/gabEyeLogo.svg',fit: BoxFit.contain,),
        ),
        IconButton(
          icon: Icon(Icons.more_vert, color: colors.onSurface),
          onPressed: () {
            // TODO: options menu
          },
        ),
      ],
    );
  }

  Widget _buildStartHeader(ColorScheme colors) {
    return Row(
      children: [
        const Spacer(),
        const SizedBox(width: 10),
        Expanded(
          child: Center(
            child: Text(
              'Start',
              style: TextStyle(
                fontSize: 13,
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
    return OutlinedButton.icon(
      onPressed: () => showAssessmentIntroModal(context),
      icon: const Icon(Icons.help_outline, size: 16),
      label: const Text('How it works?'),
      style: OutlinedButton.styleFrom(
        foregroundColor: colors.onSurface,
        side: BorderSide(color: colors.onSurfaceVariant.withOpacity(0.3)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
    );
  }

  Widget _buildAssessmentCard(ColorScheme colors) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          _buildStartHeader(colors),
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
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildPoolGrid(colors),
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
      child: const Text(
        'FIXED',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
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

  Widget _buildPoolGrid(ColorScheme colors) {
    if (_poolCaps.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Text(
          'All caps placed — ready to finish!',
          style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13),
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
    return Column(
      children: [
        ElevatedButton(
          onPressed: _isTestComplete
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AssessmentSummaryScreen(
                    arrangedCaps: _arrangedCaps.cast<int>(),
                  ),
                ),
              );
            }
          : null,
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            minimumSize: const Size(double.infinity, 50),
            elevation: _isTestComplete ? 4 : 0,
          ),
          child: const Text('Finish Assessment', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 10),
        OutlinedButton(
          onPressed: _resetTest,
          style: OutlinedButton.styleFrom(
            foregroundColor: colors.onSurface,
            side: BorderSide(color: colors.onSurfaceVariant.withOpacity(0.3)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            minimumSize: const Size(double.infinity, 50),
          ),
          child: const Text('Start Over', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        
      ],
    );
  }

}


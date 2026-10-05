import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:gabeye/core/theme/app_colors.dart';

/// Practice discs for the preview. Deliberately unlike the D-15 caps so the
/// demo teaches the interaction without hinting at the real answer.
/// Index 0 is the fixed reference disc; 1-5 are the discs to arrange, in order.
const List<Color> _demoColors = [
  Color(0xFFE53935), // red (fixed)
  Color(0xFFFB8C00), // orange
  Color(0xFFFDD835), // yellow
  Color(0xFF43A047), // green
  Color(0xFF00ACC1), // teal
  Color(0xFF1E88E5), // blue
];

/// Shuffled pool order (disc numbers 1-5), as the discs appear before arranging.
const List<int> _poolOrder = [4, 1, 5, 2, 3];

/// What one looping preview shows.
class _DemoScript {
  /// Discs already in the tray when the loop starts.
  final int prePlaced;

  /// Discs moved from the pool into the tray during the loop.
  final int moves;
  final bool showFinger;
  final bool highlightFixed;
  final bool showFinishButton;
  final Duration duration;

  const _DemoScript({
    required this.prePlaced,
    required this.moves,
    required this.duration,
    this.showFinger = false,
    this.highlightFixed = false,
    this.showFinishButton = false,
  });
}

class _HowItWorksStep {
  final String title;
  final String description;
  final String demoLabel;
  final _DemoScript script;

  const _HowItWorksStep({
    required this.title,
    required this.description,
    required this.demoLabel,
    required this.script,
  });
}

const List<_HowItWorksStep> _steps = [
  _HowItWorksStep(
    title: 'Arrange the discs by hue',
    description: 'You get a set of color discs. Put them in order so each color flows smoothly into the next.',
    demoLabel: 'Animation: shuffled discs move one by one into a smooth row of colors.',
    script: _DemoScript(prePlaced: 0, moves: 5, duration: Duration(milliseconds: 7000)),
  ),
  _HowItWorksStep(
    title: 'Start from the fixed disc',
    description: 'The first disc is fixed. Find the color closest to it and place it in the next slot, then keep going to the end.',
    demoLabel: 'Animation: the fixed disc is highlighted and the closest colors are placed next to it.',
    script: _DemoScript(
      prePlaced: 0,
      moves: 2,
      highlightFixed: true,
      duration: Duration(milliseconds: 4500),
    ),
  ),
  _HowItWorksStep(
    title: 'Hold, then drag',
    description: 'Press and hold a disc, then drag it into the slot where you think it belongs. You can also tap a disc to drop it in the next empty slot, or tap a placed disc to send it back.',
    demoLabel: 'Animation: a finger holds a disc and drags it into the next slot.',
    script: _DemoScript(
      prePlaced: 1,
      moves: 2,
      showFinger: true,
      duration: Duration(milliseconds: 5500),
    ),
  ),
  _HowItWorksStep(
    title: 'Finish the assessment',
    description: 'When every slot is filled, tap Finish Assessment, then wait for your color assessment result.',
    demoLabel: 'Animation: the last disc is placed and the Finish Assessment button is tapped.',
    script: _DemoScript(
      prePlaced: 4,
      moves: 1,
      showFinger: true,
      showFinishButton: true,
      duration: Duration(milliseconds: 5000),
    ),
  ),
];

/// Step-by-step "How it works?" walkthrough with a looping preview of arranging discs.
class HowItWorksModal extends StatefulWidget {
  const HowItWorksModal({super.key});

  @override
  State<HowItWorksModal> createState() => _HowItWorksModalState();
}

class _HowItWorksModalState extends State<HowItWorksModal> {
  int _stepIndex = 0;

  bool get _isLastStep => _stepIndex == _steps.length - 1;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final step = _steps[_stepIndex];

    return Dialog(
      backgroundColor: colors.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.0),
        side: BorderSide(color: colors.onSurfaceVariant.withValues(alpha: 0.3)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 12, 12, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: title, step counter and close
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      Text(
                        'How it works?',
                        style: textTheme.titleMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                          fontSize: 24,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Step ${_stepIndex + 1} of ${_steps.length}',
                        style: textTheme.labelMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                  tooltip: 'Close',
                  color: colors.onSurfaceVariant,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  _buildProgressDots(colors),
                  const SizedBox(height: 18),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Column(
                      key: ValueKey(_stepIndex),
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step.title,
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          step.description,
                          style: textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
                        ),
                        const SizedBox(height: 16),
                        // The assessment itself runs in dark mode, so the preview does too.
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.darkSurface,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Semantics(
                            label: step.demoLabel,
                            child: ExcludeSemantics(
                              child: _DiscArrangeDemo(script: step.script),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Example discs for practice only. The real test uses different colors.',
                          style: textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildControls(colors, isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressDots(ColorScheme colors) {
    return Row(
      children: [
        for (int i = 0; i < _steps.length; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(right: 6),
            width: i == _stepIndex ? 22 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: i <= _stepIndex ? colors.primary : colors.onSurfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
      ],
    );
  }

  Widget _buildControls(ColorScheme colors, bool isDark) {
    final outlineColor = isDark ? Colors.white : colors.onSurface;
    return Row(
      children: [
        if (_stepIndex > 0) ...[
          Expanded(
            child: OutlinedButton(
              onPressed: () => setState(() => _stepIndex--),
              style: OutlinedButton.styleFrom(
                foregroundColor: outlineColor,
                side: BorderSide(
                  color: isDark ? Colors.white : colors.onSurfaceVariant.withValues(alpha: 0.4),
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                minimumSize: const Size(0, 52),
              ),
              child: const FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.arrow_back_rounded, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Back',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Inter'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              if (_isLastStep) {
                Navigator.pop(context);
              } else {
                setState(() => _stepIndex++);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? AppColors.darkPrimaryButton : AppColors.lightPrimaryButton,
              foregroundColor: isDark ? AppColors.darkSurface : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              minimumSize: const Size(0, 52),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _isLastStep ? 'Got it' : 'Next',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Inter'),
                  ),
                  const SizedBox(width: 8),
                  Icon(_isLastStep ? Icons.check_rounded : Icons.arrow_forward_rounded, size: 20),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Looping preview of the tray (fixed disc + 5 slots) and the pool of discs below it.
class _DiscArrangeDemo extends StatefulWidget {
  final _DemoScript script;

  const _DiscArrangeDemo({required this.script});

  @override
  State<_DiscArrangeDemo> createState() => _DiscArrangeDemoState();
}

class _DiscArrangeDemoState extends State<_DiscArrangeDemo> with SingleTickerProviderStateMixin {
  static const double _gap = 8;
  static const double _lead = 0.08;

  late final AnimationController _controller =
      AnimationController(vsync: this, duration: widget.script.duration);
  bool _reduceMotion = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Respect the system "remove animations" setting: show the finished state instead of looping.
    _reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (_reduceMotion) {
      _controller
        ..stop()
        ..value = 1.0;
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double get _tail => widget.script.showFinishButton ? 0.4 : 0.22;
  double get _moveSpan => (1 - _lead - _tail) / widget.script.moves;

  /// Progress (0-1) of move [m] at time [t].
  double _moveProgress(int m, double t) => ((t - _lead - m * _moveSpan) / _moveSpan).clamp(0.0, 1.0);

  /// How far a disc has travelled from pool to tray, given its move progress.
  double _travel(double p) {
    if (!widget.script.showFinger) return Curves.easeInOut.transform(p);
    // With a finger: reach the disc, press, drag, then release.
    if (p < 0.35) return 0;
    if (p > 0.85) return 1;
    return Curves.easeInOut.transform((p - 0.35) / 0.5);
  }

  /// Slight lift while a disc is being moved.
  double _lift(double p) {
    if (!widget.script.showFinger) return 1 + 0.08 * math.sin(math.pi * p);
    if (p < 0.25 || p > 1) return 1;
    if (p < 0.35) return 1 + 0.1 * ((p - 0.25) / 0.1);
    if (p < 0.85) return 1.1;
    return 1.1 - 0.1 * ((p - 0.85) / 0.15);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final double cell = math.min(52.0, (width - _gap * 5) / 6);
        final double gridWidth = cell * 6 + _gap * 5;
        final double left = (width - gridWidth) / 2;
        final double poolY = cell + 34;
        final double buttonY = poolY + cell + 16;
        final double height = widget.script.showFinishButton ? buttonY + 44 : poolY + cell;

        Offset slot(int i) => Offset(left + i * (cell + _gap), 0);
        Offset pool(int disc) => Offset(left + _poolOrder.indexOf(disc) * (cell + _gap), poolY);
        final Offset buttonCenter = Offset(width / 2, buttonY + 22);
        final Offset fingerRest = Offset(left + gridWidth - cell * 0.4, poolY + cell * 0.9);

        return SizedBox(
          height: height,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final double t = _controller.value;
              final script = widget.script;

              // Discs in the tray (by drop), and the disc currently moving.
              int placed = script.prePlaced;
              for (int m = 0; m < script.moves; m++) {
                if (_travel(_moveProgress(m, t)) >= 1) placed++;
              }

              final List<Widget> slots = [
                for (int i = 1; i <= 5; i++)
                  Positioned(
                    left: slot(i).dx,
                    top: 0,
                    child: _EmptySlot(size: cell, showArrow: i == placed + 1),
                  ),
              ];

              final List<Widget> discs = [];
              Widget? movingDisc;
              Offset? fingerAt;
              double fingerPress = 0;

              for (int disc = 1; disc <= 5; disc++) {
                final int m = disc - script.prePlaced - 1;
                if (disc <= script.prePlaced) {
                  discs.add(_positioned(slot(disc), cell, _Disc(color: _demoColors[disc], size: cell)));
                } else if (m < script.moves) {
                  final double p = _moveProgress(m, t);
                  final double travel = _travel(p);
                  final Offset at = Offset.lerp(pool(disc), slot(disc), travel)!;
                  final widgetDisc = _positioned(
                    at,
                    cell,
                    Transform.scale(
                      scale: _lift(p),
                      child: _Disc(color: _demoColors[disc], size: cell, inPool: travel < 1),
                    ),
                  );
                  if (p > 0 && p < 1) {
                    movingDisc = widgetDisc;
                  } else {
                    discs.add(widgetDisc);
                  }

                  if (script.showFinger && p > 0 && p <= 1) {
                    final Offset from = m == 0 ? fingerRest : _center(slot(disc - 1), cell);
                    final Offset target = _center(at, cell);
                    fingerAt = p < 0.25 ? Offset.lerp(from, target, Curves.easeOut.transform(p / 0.25))! : target;
                    fingerPress = (p >= 0.25 && p <= 0.85) ? 1 : 0;
                  }
                } else {
                  discs.add(_positioned(pool(disc), cell, _Disc(color: _demoColors[disc], size: cell, inPool: true)));
                }
              }

              // Finish step: after the last drop the finger moves to the button and taps it.
              double buttonPress = 0;
              final double tailStart = 1 - _tail;
              if (script.showFinishButton && t > tailStart) {
                final double q = ((t - tailStart) / _tail).clamp(0.0, 1.0);
                final Offset lastDrop = _center(slot(script.prePlaced + script.moves), cell);
                fingerAt = Offset.lerp(lastDrop, buttonCenter, Curves.easeInOut.transform((q / 0.4).clamp(0.0, 1.0)));
                if (q > 0.45 && q < 0.75) {
                  buttonPress = 1;
                  fingerPress = 1;
                }
              } else if (script.showFinger && fingerAt == null) {
                fingerAt = t <= _lead ? fingerRest : _center(slot(script.prePlaced + script.moves), cell);
              }

              final double fade = _reduceMotion ? 1 : math.min(1.0, math.min(t / 0.04, (1 - t) / 0.04));
              final double pulse = 0.5 + 0.5 * math.sin(2 * math.pi * t * 3);

              return Opacity(
                opacity: fade.clamp(0.0, 1.0),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Fixed reference disc
                    Positioned(
                      left: slot(0).dx,
                      top: 0,
                      child: _FixedDisc(
                        size: cell,
                        glow: script.highlightFixed ? (_reduceMotion ? 1 : pulse) : 0,
                      ),
                    ),
                    ...slots,
                    Positioned(
                      left: left,
                      top: cell + 12,
                      child: const Text(
                        'Select Next Color',
                        style: TextStyle(
                          color: AppColors.darkTextSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ...discs,
                    if (script.showFinishButton)
                      Positioned(
                        left: left,
                        top: buttonY,
                        child: _FinishButton(
                          width: gridWidth,
                          enabled: placed == 5,
                          pressed: buttonPress > 0,
                        ),
                      ),
                    ?movingDisc,
                    if (script.showFinger && fingerAt != null && !_reduceMotion)
                      Positioned(
                        left: fingerAt.dx - 6,
                        top: fingerAt.dy - 2,
                        child: Transform.scale(
                          scale: fingerPress > 0 ? 0.88 : 1,
                          child: const Icon(
                            Icons.touch_app_rounded,
                            size: 34,
                            color: Colors.white,
                            shadows: [Shadow(color: Colors.black54, blurRadius: 6)],
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  static Offset _center(Offset topLeft, double cell) => topLeft + Offset(cell / 2, cell / 2);

  static Widget _positioned(Offset at, double cell, Widget child) =>
      Positioned(left: at.dx, top: at.dy, width: cell, height: cell, child: child);
}

class _Disc extends StatelessWidget {
  final Color color;
  final double size;
  final bool inPool;

  const _Disc({required this.color, required this.size, this.inPool = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size * 0.27),
        border: inPool ? Border.all(color: Colors.white) : null,
      ),
      alignment: Alignment.center,
      child: inPool ? const Icon(Icons.open_with, size: 12, color: Colors.white70) : null,
    );
  }
}

class _FixedDisc extends StatelessWidget {
  final double size;

  /// 0-1 strength of the highlight ring.
  final double glow;

  const _FixedDisc({required this.size, required this.glow});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _demoColors[0],
        borderRadius: BorderRadius.circular(size * 0.27),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          if (glow > 0)
            BoxShadow(
              color: AppColors.darkPrimaryButton.withValues(alpha: 0.35 + 0.5 * glow),
              blurRadius: 4 + 8 * glow,
              spreadRadius: 1 + 3 * glow,
            ),
        ],
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: const FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          'FIXED',
          style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.5),
        ),
      ),
    );
  }
}

class _EmptySlot extends StatelessWidget {
  final double size;
  final bool showArrow;

  const _EmptySlot({required this.size, required this.showArrow});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(size * 0.27),
        border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
      ),
      alignment: Alignment.center,
      child: showArrow
          ? Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.darkTextSecondary.withValues(alpha: 0.8))
          : null,
    );
  }
}

class _FinishButton extends StatelessWidget {
  final double width;
  final bool enabled;
  final bool pressed;

  const _FinishButton({required this.width, required this.enabled, required this.pressed});

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: pressed ? 0.95 : 1,
      duration: const Duration(milliseconds: 120),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: width,
        height: 44,
        decoration: BoxDecoration(
          color: enabled
              ? (pressed ? Colors.white : AppColors.darkPrimaryButton)
              : Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          'Finish Assessment',
          style: TextStyle(
            color: enabled ? AppColors.darkSurface : Colors.white.withValues(alpha: 0.4),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

void showHowItWorksModal(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) => const HowItWorksModal(),
  );
}

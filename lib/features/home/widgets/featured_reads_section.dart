import 'package:flutter/material.dart';
import 'package:gabeye/core/theme/app_colors.dart';
import 'vision_profile_card.dart';

class FeaturedReadsSection extends StatefulWidget {
  final List<VisionProfileData> reads;
  const FeaturedReadsSection({super.key, required this.reads});

  @override
  State<FeaturedReadsSection> createState() => _FeaturedReadsSectionState();
}

class _FeaturedReadsSectionState extends State<FeaturedReadsSection> {
  static const _cardWidth = 291.0;
  static const _cardSpacing = 24.0;

  final _controller = ScrollController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goTo(int index) {
    final clamped = index.clamp(0, widget.reads.length - 1);
    _controller.animateTo(
      clamped * (_cardWidth + _cardSpacing),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
    setState(() => _currentIndex = clamped);
  }

  @override
  Widget build(BuildContext context) {
    final atStart = _currentIndex == 0;
    final atEnd = _currentIndex == widget.reads.length - 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Featured Reads',
              style: Theme.of(context).textTheme.headlineSmall ??
                  const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
            ),
            Row(
              children: [
                _NavArrow(
                  icon: Icons.arrow_back,
                  label: 'Previous article',
                  enabled: !atStart,
                  onTap: () => _goTo(_currentIndex - 1),
                ),
                const SizedBox(width: 8),
                _NavArrow(
                  icon: Icons.arrow_forward,
                  label: 'Next article',
                  enabled: !atEnd,
                  onTap: () => _goTo(_currentIndex + 1),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 380,
          child: ListView.separated(
            controller: _controller,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: widget.reads.length,
            separatorBuilder: (_, index) => const SizedBox(width: _cardSpacing),
            itemBuilder: (context, i) => SizedBox(
              width: _cardWidth,
              child: VisionProfileCard(data: widget.reads[i]),
            ),
          ),
        ),
      ],
    );
  }
}

class _NavArrow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback onTap;

  const _NavArrow({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      enabled: enabled,
      child: SizedBox(
        // 44x44 minimum touch target for reliable tapping —
        // important for users with low vision or reduced motor precision.
        width: 44,
        height: 44,
        child: Material(
          color: enabled ? AppColors.primaryNavy : const Color(0xFFE0E0E0),
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: enabled ? onTap : null,
            child: Icon(
              icon,
              size: 20,
              color: enabled ? Colors.white : const Color(0xFF9E9E9E),
            ),
          ),
        ),
      ),
    );
  }
}

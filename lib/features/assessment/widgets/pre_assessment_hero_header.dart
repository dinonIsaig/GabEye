import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PreAssessmentHeroHeader extends StatelessWidget {
  final String title;

  const PreAssessmentHeroHeader({
    super.key,
    this.title = 'Color Vision Assessment',
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.bottomLeft,
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(24),
              ),
              child: SvgPicture.asset(
                'assets/images/articleHeading.svg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            left: 20,
            bottom: 18,
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
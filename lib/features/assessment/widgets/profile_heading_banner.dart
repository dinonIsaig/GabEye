import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// Gabeye Header for Color Vision Profile 
class ProfileHeadingBanner extends StatelessWidget {
  final String title;

  const ProfileHeadingBanner({super.key, this.title = 'Color Vision Profile'});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
      child: Container(
        width: double.infinity,
        height: 170,
        color: colors.surface,
        child: Stack(
          fit: StackFit.expand,
          children: [
            SvgPicture.asset('assets/images/articleHeading.svg', fit: BoxFit.cover),
            Positioned(
              left: 20,
              right: 20,
              bottom: 16,
              child: Text(
                title,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

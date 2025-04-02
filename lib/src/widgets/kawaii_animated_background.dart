import 'package:flutter/material.dart';
import 'package:particles_flutter/particles_flutter.dart'; // Import particles_flutter
import 'dart:math';

// Creates a background with floating circular particles
class KawaiiStaticBackground extends StatelessWidget {
  final Widget child;

  const KawaiiStaticBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final baseColor = Theme.of(context).scaffoldBackgroundColor;
    // Use hintColor (Light Pink) with decent opacity for particles
    final particleColor = Theme.of(context).hintColor.withOpacity(0.6);

    return Stack(
      children: [
        // Static base background color
        Positioned.fill(
          child: Container(color: baseColor),
        ),
        // Animated Particles from particles_flutter
        Positioned.fill(
          child: CircularParticle(
            key: UniqueKey(), // Add key to help Flutter update if needed
            awayRadius: 80,
            numberOfParticles: 150, // Original particle count
            speedOfParticles: 0.8, // Slightly slower speed
            height: screenHeight,
            width: screenWidth,
            onTapAnimation: false, // Keep tap animation off
            particleColor: Colors.transparent, // Use randColorList instead
            awayAnimationDuration: const Duration(milliseconds: 600),
            maxParticleSize: 5, // Slightly larger max size
            isRandSize: true, // Keep random size
            isRandomColor: true, // Use random colors from the list
            randColorList: [ // Shades of red/pink for "rose" colors
               Colors.red.shade200.withOpacity(0.5),
               Colors.pink.shade100.withOpacity(0.6),
               Colors.red.shade300.withOpacity(0.5),
               Colors.pink.shade200.withOpacity(0.6),
               Theme.of(context).hintColor.withOpacity(0.5), // Original Light Pink
            ],
            awayAnimationCurve: Curves.easeInOutBack,
            enableHover: false,
            hoverColor: Colors.white,
            hoverRadius: 90,
            connectDots: false, // Keep dots disconnected
          ),
        ),
        // Original content on top
        Positioned.fill(
          child: child,
        ),
      ],
    );
  }
}

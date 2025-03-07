import 'package:flutter/material.dart';

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 50);
    path.quadraticBezierTo(
        size.width * 0.25, size.height, size.width * 0.5, size.height - 40);
    path.quadraticBezierTo(
        size.width * 0.75, size.height - 80, size.width, size.height - 50);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

class WaveBackground extends StatelessWidget {
  final double height;

  const WaveBackground({super.key, required this.height});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: WaveClipper(),
      child: Container(
        height: height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 0x5B, 0x98, 0xD5),
              Color.fromARGB(255, 0x42, 0x70, 0x9A),
              Color.fromARGB(255, 0x36, 0x5B, 0x7D),
              Color.fromARGB(255, 0x29, 0x45, 0x5F),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
    );
  }
}
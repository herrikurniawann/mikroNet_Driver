import 'package:flutter/material.dart';

class BackgroundWidget extends StatelessWidget {
  final Widget child;

  const BackgroundWidget({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 0x5B, 0x98, 0xD5),
            Color.fromARGB(255, 0x42, 0x70, 0x9A),
            Color.fromARGB(255, 0x36, 0x5B, 0x7D),
            Color.fromARGB(255, 0x29, 0x45, 0x5F),
            Color.fromARGB(255, 0x16, 0x25, 0x32),
            Color.fromARGB(255, 0x07, 0x0C, 0x11),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter, 
        ),
      ),
      child: child,
    );
  }
}
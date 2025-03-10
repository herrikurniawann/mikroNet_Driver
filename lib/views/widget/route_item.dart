import 'package:flutter/material.dart';

Widget buildRouteItem(String route) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      children: [
        const Icon(Icons.directions_bus, color: Color(0xFF4678A5), size: 26),
        const SizedBox(width: 12),
        Text(
          route,
          style: const TextStyle(
              fontSize: 14, color: Colors.black87, fontFamily: 'Poppins'),
        ),
      ],
    ),
  );
}

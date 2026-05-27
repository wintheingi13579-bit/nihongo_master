// =============================================================
// mascot.dart - Manga-style assistant ("Mina-chan")
// =============================================================
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class Mascot extends StatelessWidget {
  final String message;
  const Mascot({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.18),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        children: [
          const Text('🌸', style: TextStyle(fontSize: 44))
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(duration: 1500.ms, begin: const Offset(1, 1), end: const Offset(1.1, 1.1)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}

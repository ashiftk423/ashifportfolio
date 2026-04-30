import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class CustomLoader extends StatelessWidget {
  final String text;

  const CustomLoader({super.key, this.text = "Loading amazing things..."});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // A cool glowing orb loader
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
                  blurRadius: 30,
                  spreadRadius: 10,
                )
              ],
            ),
            child: Center(
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ).animate(onPlay: (controller) => controller.repeat())
               .scale(duration: 1.seconds, curve: Curves.easeInOutSine, begin: const Offset(0.5, 0.5), end: const Offset(1.5, 1.5))
               .fadeOut(duration: 1.seconds, curve: Curves.easeOut),
            ),
          )
          .animate(onPlay: (controller) => controller.repeat(reverse: true))
          .scale(duration: 1.5.seconds, begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1)),
          
          const SizedBox(height: 30),
          
          Text(
            text,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              letterSpacing: 2.0,
            ),
          ).animate(onPlay: (controller) => controller.repeat())
           .shimmer(duration: 2.seconds, color: Colors.white),
        ],
      ),
    );
  }
}

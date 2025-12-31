// lib/widgets/gradient_card.dart
import 'package:flutter/material.dart';

class GradientCard extends StatelessWidget {
  final Gradient gradient;
  final Widget child;
  final VoidCallback? onTap;

  const GradientCard({
    super.key,
    required this.gradient,
    required this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
            )
          ],
        ),
        child: child,
      ),
    );
  }
}
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:bite_balance/core/constants/app_theme.dart';

/// A frosted glass card with backdrop blur, semi-transparent fill,
/// and a subtle neon edge glow.
class GlassCard extends StatelessWidget {
  final Widget child;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final List<BoxShadow>? boxShadow;
  final double blur;
  final double opacity;
  final Color? borderColor;
  final double borderWidth;
  final Gradient? gradient;

  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
    this.padding,
    this.margin,
    this.boxShadow,
    this.blur = 20,
    this.opacity = 0.6,
    this.borderColor,
    this.borderWidth = 1,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: boxShadow ?? AppTheme.softShadow,
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: AppTheme.surface.withValues(alpha: opacity),
              borderRadius: borderRadius,
              border: Border.all(
                color: borderColor ?? Colors.white.withValues(alpha: 0.08),
                width: borderWidth,
              ),
              gradient: gradient,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

/// Responsive breakpoints for web layout
class Responsive {
  Responsive._();

  /// Mobile: < 600px — existing mobile layout
  static const double mobile = 600;

  /// Tablet: 600px - 1024px — wider cards, 2-column grid
  static const double tablet = 1024;

  /// Maximum content width for desktop
  static const double maxContentWidth = 1200;

  /// Sidebar width on desktop
  static const double sidebarWidth = 260;

  /// Returns true if width < 600 (mobile)
  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < mobile;

  /// Returns true if width >= 600 && < 1024 (tablet)
  static bool isTablet(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return w >= mobile && w < tablet;
  }

  /// Returns true if width >= 1024 (desktop)
  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= tablet;

  /// Returns true if width >= 600 (tablet or desktop)
  static bool isWide(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= mobile;

  /// Horizontal padding based on screen size
  static double horizontalPadding(BuildContext context) {
    if (isDesktop(context)) return 32;
    if (isTablet(context)) return 24;
    return 16;
  }

  /// Content padding for pages
  static EdgeInsets pagePadding(BuildContext context) {
    final h = horizontalPadding(context);
    return EdgeInsets.symmetric(horizontal: h, vertical: 16);
  }
}

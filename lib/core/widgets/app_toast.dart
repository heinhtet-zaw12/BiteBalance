import 'package:flutter/material.dart';
import 'package:bite_balance/core/constants/app_theme.dart';
import 'package:bite_balance/core/utils/responsive.dart';

/// Responsive notification utility.
/// - Mobile (< 600px): standard SnackBar
/// - Tablet/Desktop (≥ 600px): floating Toast in the top-right corner
class AppToast {
  AppToast._();

  /// Show a notification. Wraps [ScaffoldMessenger.showSnackBar] on mobile,
  /// and an [OverlayEntry] toast on wider screens.
  static void show(
    BuildContext context, {
    required String message,
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 3),
  }) {
    if (Responsive.isWide(context)) {
      _showOverlayToast(
        context,
        message: message,
        backgroundColor: backgroundColor,
        duration: duration,
      );
    } else {
      _showSnackBar(
        context,
        message: message,
        backgroundColor: backgroundColor,
        duration: duration,
      );
    }
  }

  // ── Mobile: standard SnackBar ────────────────────────────────────────

  static void _showSnackBar(
    BuildContext context, {
    required String message,
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: duration,
      ),
    );
  }

  // ── Tablet/Desktop: overlay Toast ────────────────────────────────────

  static void _showOverlayToast(
    BuildContext context, {
    required String message,
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 3),
  }) {
    final overlay = Overlay.of(context);
    final bgColor = backgroundColor ?? AppTheme.snackbar;

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _ToastWidget(
        message: message,
        backgroundColor: bgColor,
        onDismissed: () => entry.remove(),
        duration: duration,
      ),
    );

    overlay.insert(entry);
  }
}

// ── Toast widget ──────────────────────────────────────────────────────

class _ToastWidget extends StatefulWidget {
  final String message;
  final Color backgroundColor;
  final VoidCallback onDismissed;
  final Duration duration;

  const _ToastWidget({
    required this.message,
    required this.backgroundColor,
    required this.onDismissed,
    required this.duration,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1, 0), // slide in from right
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();

    // Auto-dismiss after duration
    Future.delayed(widget.duration, () {
      if (mounted) _dismiss();
    });
  }

  Future<void> _dismiss() async {
    await _controller.reverse();
    widget.onDismissed();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.paddingOf(context).top + 16,
      right: 16,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: _dismiss,
              child: Container(
                width: 320,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: widget.backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      widget.backgroundColor == AppTheme.error
                          ? Icons.error_outline_rounded
                          : widget.backgroundColor == AppTheme.success
                              ? Icons.check_circle_outline_rounded
                              : Icons.info_outline_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.message,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

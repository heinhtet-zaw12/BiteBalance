import 'dart:js' as js;

/// Simple GoatCounter tracker for Flutter web SPA.
///
/// Requires the GoatCounter script and the `trackGoatCounter` JS helper
/// to be loaded in `web/index.html`.
class GoatCounterTracker {
  /// Track a page view. Call this on every route change.
  static void trackPageView(String path) {
    try {
      js.context.callMethod('trackGoatCounter', [path]);
    } catch (_) {
      // GoatCounter not loaded yet — skip silently.
    }
  }
}

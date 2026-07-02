import 'url_strategy_stub.dart'
    if (dart.library.html) 'url_strategy_web.dart';

/// Calls `usePathUrlStrategy()` on web; no-op on mobile.
void configurePathUrlStrategy() => configurePathUrlStrategyImpl();

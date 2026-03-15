/// Simple analytics service abstraction for Zid integrations.
abstract interface class AnalyticsService {
  Future<void> logPageView(String pageName);
}

class ConsoleAnalyticsService implements AnalyticsService {
  @override
  Future<void> logPageView(String pageName) async {
    if (pageName.trim().isEmpty) return;
    // In a real integration this would send the event to Lableb.
    // We intentionally swallow all errors to avoid crashing host apps.
  }
}


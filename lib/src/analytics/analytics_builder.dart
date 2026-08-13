import 'package:get_it/get_it.dart';

import 'analytics_service.dart';

abstract interface class PageRouteTrackingBuilderStart {
  PageRouteTrackingBuilderReady forPage(String pageName);
}

abstract interface class PageRouteTrackingBuilderReady {
  PageRouteTrackingBuilderReady fromUser({String? id});

  Future<void> send();
}

class PageRouteTrackingBuilder
    implements PageRouteTrackingBuilderStart, PageRouteTrackingBuilderReady {
  String? _pageName;

  @override
  PageRouteTrackingBuilderReady forPage(String pageName) {
    assert(pageName.trim().isNotEmpty, 'pageName is required');
    _pageName = pageName;
    return this;
  }

  @override
  PageRouteTrackingBuilderReady fromUser({String? id}) {
    // Reserved for future enrichment (user-scoped analytics).
    return this;
  }

  @override
  Future<void> send() async {
    final page = _pageName;
    assert(page != null && page.trim().isNotEmpty, 'pageName is required');

    try {
      final service = GetIt.instance<AnalyticsService>();
      await service.logPageView(page!);
    } catch (_) {
      // Swallow analytics failures to avoid crashing merchant apps.
    }
  }
}


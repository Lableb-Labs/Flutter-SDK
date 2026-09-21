// This example prints its results so it reads as a runnable script; `print` is
// the output medium here, not a debugging leftover.
// ignore_for_file: avoid_print

import 'package:lableb_flutter_sdk/lableb_flutter_sdk.dart';

/// Example usage of the Lableb Flutter SDK.
///
/// This mirrors the Quick Start in README.md: initialization, search,
/// autocomplete, recommendations, feedback, and error handling.
///
/// Replace `platformName`, `indexName`, the API key and the handler with your
/// own project's values before running.
void main() async {
  // ============================================
  // 1. SDK INITIALIZATION
  // ============================================
  print('=== Initializing SDK ===');

  // platformName and indexName are required: they become the
  // /v2/projects/{platformName}/indices/{indexName}/... path segments, and
  // search, autocomplete and feedback all throw ValidationException without
  // platformName.
  final sdk = LablebSDK(
    baseUrl: 'https://api.lableb.com',
    apiKey: 'your-api-key',
    platformName: 'your-platform-name',
    indexName: 'your-index-name',
    enableLogging: true, // Optional: for debugging
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  );

  // Every search and autocomplete request runs against a *handler* configured
  // on your project's Lableb dashboard. The SDK defaults to 'default', and a
  // project not provisioned with that handler returns HTTP 404 — so pass the
  // one your project actually has.
  const handler = 'suggest';

  print('SDK initialized successfully!\n');

  // ============================================
  // 2. SEARCH
  // ============================================
  print('=== Performing Search ===');

  try {
    final result = await sdk
        .searchRequest()
        .forQuery('product')
        .withHandler(handler)
        .paginate(page: 1, pageSize: 10)
        .send();

    print('Found ${result.results.length} of ${result.totalResults} results');
    print('Page ${result.pagination.currentPage} of '
        '${result.pagination.totalPages}');

    for (final item in result.results) {
      // Keys come from your index schema — 'name' here, not 'title'.
      print('  - ${item.id}: ${item.data['name']} (score: ${item.score})');
    }
    print('');

    // The same builder with filters and sorting.
    final filtered = await sdk
        .searchRequest()
        .forQuery('product')
        .withHandler(handler)
        .withFilters({'category': 'electronics'})
        .sortBy('price', direction: 'asc')
        .paginate(page: 1, pageSize: 5)
        .send();

    print('Filtered search: ${filtered.totalResults} results\n');
  } catch (e) {
    print('Error performing search: $e\n');
  }

  // ============================================
  // 3. AUTOCOMPLETE
  // ============================================
  print('=== Getting Autocomplete Suggestions ===');

  try {
    final suggestions = await sdk.autocomplete.getSuggestions(
      query: 'prod',
      limit: 5,
      handler: handler,
    );

    for (final suggestion in suggestions) {
      print('  - ${suggestion.text} (score: ${suggestion.score})');
    }
    print('');
  } catch (e) {
    print('Error getting autocomplete: $e\n');
  }

  // ============================================
  // 4. RECOMMENDATIONS
  // ============================================
  print('=== Getting Recommendations ===');

  try {
    // Item-based recommendations.
    final itemRecommendations =
        await sdk.recommendations().forItem('item-1').limit(10).send();

    for (final recommendation in itemRecommendations) {
      print('  - ${recommendation.id}: ${recommendation.data['name']} '
          '(score: ${recommendation.score})');
    }
    print('');

    // User-based, with extra context.
    final userRecommendations = await sdk
        .recommendations()
        .fromUser('user-123')
        .withContext({'category': 'electronics'})
        .limit(5)
        .send();

    print('User recommendations: ${userRecommendations.length}\n');
  } catch (e) {
    print('Error getting recommendations: $e\n');
  }

  // ============================================
  // 5. FEEDBACK SUBMISSION
  // ============================================
  print('=== Submitting Feedback ===');

  try {
    // Search feedback: what the user did with a search result.
    await sdk
        .searchFeedbackEvent()
        .forQuery('product')
        .event(SearchFeedbackEventType.click)
        .forItem(id: 'item-1', order: 1, price: 95.5, quantity: 1)
        .withHandler(handler)
        .withUrl('http://mysite.com/posts/lableb-post')
        .withCart('CART_98765')
        .withRequestSource('mobile')
        .fromUser(
          id: 'user-123',
          sessionId: '1c4Hb23',
          ip: '192.111.24.21',
          country: 'DE',
        )
        .send();
    print('Search feedback event submitted successfully');

    // Autocomplete feedback: which suggestion the user took.
    await sdk
        .autocompleteFeedback()
        .forQuery('samsu')
        .event(SearchFeedbackEventType.click)
        .forItem(id: '153-ar', order: 4)
        .withHandler(handler)
        .fromUser(id: '2313', sessionId: '1c4CqE')
        .send();
    print('Autocomplete feedback submitted successfully');

    // Recommendation feedback: source item -> recommended target item.
    // Note: .event() is optional per API spec
    await sdk
        .recommenderFeedback()
        .forRecommendation(sourceId: '153-en', targetId: '154-ar')
        .event(SearchFeedbackEventType.click)
        .atOrder(2)
        .withHandler(handler)
        .send();
    print('Recommender feedback submitted successfully\n');
  } catch (e) {
    print('Error submitting feedback: $e\n');
  }

  // ============================================
  // 6. ERROR HANDLING
  // ============================================
  print('=== Error Handling ===');

  try {
    await sdk.searchRequest().forQuery('example').withHandler(handler).send();
    print('Search completed without error');
  } on NetworkException catch (e) {
    print('Network error: ${e.message}');
  } on UnauthorizedException catch (e) {
    print('Unauthorized: ${e.message}');
  } on ForbiddenException catch (e) {
    print('Forbidden: ${e.message}');
  } on NotFoundException catch (e) {
    print('Not found: ${e.message}');
  } on ValidationException catch (e) {
    print('Validation error: ${e.message}');
  } on ServerException catch (e) {
    print('Server error: ${e.message}');
  } on TimeoutException catch (e) {
    print('Request timed out: ${e.message}');
  } on LablebException catch (e) {
    print('Lableb error: ${e.message}');
  }

  // ============================================
  // 7. ADVANCED CONFIGURATION
  // ============================================
  print('\n=== Advanced Configuration ===');

  // Custom timeouts and default headers are constructor options.
  final customSdk = LablebSDK(
    baseUrl: 'https://api.lableb.com',
    apiKey: 'your-api-key',
    platformName: 'your-platform-name',
    indexName: 'your-index-name',
    connectTimeout: const Duration(seconds: 60),
    receiveTimeout: const Duration(seconds: 60),
    sendTimeout: const Duration(seconds: 60),
    defaultHeaders: {
      'X-Custom-Header': 'value',
    },
  );
  print('Configured ${customSdk.runtimeType} with custom timeouts and headers');

  print('\n=== Example completed ===');
}

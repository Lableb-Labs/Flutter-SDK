import 'package:lableb_flutter_sdk/lableb_flutter_sdk.dart';

/// Example usage of the Lableb Flutter SDK.
///
/// This file demonstrates how to use all the main features of the SDK
/// including initialization, indexing, searching, autocomplete,
/// recommendations, and feedback submission.
void main() async {
  // ============================================
  // 1. SDK INITIALIZATION
  // ============================================
  print('=== Initializing SDK ===');

  final sdk = LablebSDK(
    baseUrl: 'https://api.lableb.com', // Replace with your actual base URL
    apiKeyIndex: 'your-index-api-key', // Replace with your actual API key
    apiKeySearch: 'your-search-api-key', // Replace with your actual API key
    projectId: 'your-project-id', // Replace with your actual API key
    indexName: 'your-index-name',
    enableLogging: true, // Enable logging for debugging
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  );

  print('SDK initialized successfully!\n');

  // // ============================================
  // // 2. INDEXING DATA
  // // ============================================
  print('=== Indexing Data ===');

  try {
    List<Map<String, dynamic>> documents = [
      {
        "id": 1111111,
        "title": "Lableb is awesome",
        "description": "example content goes here",
        "image": "https://mysite.com/static/images/lableb.png",
        "url": "https://mysite.com/index/lableb-is-awesome",
        "category": ["Search", "Cloud"],
        "date": "2011-07-01T10:50:23Z"
      }
    ];

    await sdk.index.uploadDocuments(documents);
    print('Item indexed');

    await sdk.index.removeDocuments(["1111111"]);
    print('Item deleted');
  } catch (e) {
    print('Error indexing data: $e\n');
  }

  // ============================================
  // 3. SEARCH OPERATIONS
  // ============================================
  print('=== Performing Search ===');

  try {
    // Basic search
    final searchResult = await sdk.search.search(
        query: '*',
        page: 1,
        pageSize: 10,
        userId: 'test', // Optional
        userIp: '192.168.1.1', // Optional
        userCountry: 'uae', // Optional
        requestSource: 'web', // Optional
        sessionId: 'test-111' // Optional
        );

    print('Search Results:');
    print('Total results: ${searchResult.totalResults}\n');

    print('');

    // Search with filters
    final filteredSearch = await sdk.search.search(
      query: '*',
      filters: {
        'category': 'electronics',
        'tags': 'مقاولات وتعهدات',
        'price': {'from': 50, 'to': 200},
      },
      page: 1,
      pageSize: 5,
    );

    print('Filtered Search Results:');
    print('Total results: ${filteredSearch.totalResults}\n');
  } catch (e) {
    if (e is NetworkException) {
      print('Network error: ${e.message}');
    } else if (e is UnauthorizedException) {
      print('Unauthorized: ${e.message}');
    } else if (e is ServerException) {
      print('Server error: ${e.message}');
    } else {
      print('Error performing search: $e');
    }
    print('');
  }

  // ============================================
  // 4. AUTOCOMPLETE OPERATIONS
  // ============================================
  print('=== Getting Autocomplete Suggestions ===');

  try {
    final suggestions = await sdk.autocomplete.getSuggestions(
        query: '*',
        filters: {
          // 'category': 'electronics',
          'tags': 'مقاولات وتعهدات',
          'price': {'gte': 50, 'lte': 200},
        },
        limit: 5,
        userId: 'test', // Optional
        userIp: '192.168.1.1', // Optional
        userCountry: 'uae', // Optional
        requestSource: 'web', // Optional
        sessionId: 'test-111' // Optional
        );

    print('Autocomplete Suggestions:');
    print('Total results: ${suggestions.totalResults}\n');
    print('');
  } catch (e) {
    print('Error getting autocomplete: $e\n');
  }

  // ============================================
  // 5. RECOMMENDATION OPERATIONS
  // ============================================
  print('=== Getting Recommendations ===');

  try {
    // recommendations
    final recommendations = await sdk.recommender.getRecommendations(
        itemId: '101',
        limit: 10,
        userId: 'test', // Optional
        userIp: '192.168.1.1', // Optional
        userCountry: 'uae', // Optional
        requestSource: 'web', // Optional
        sessionId: 'test-111' // Optional
        );

    print('Recommendations:');
    print('Total results: ${recommendations.totalResults}\n');
    print('');
  } catch (e) {
    print('Error getting recommendations: $e\n');
  }

  // ============================================
  // 6. FEEDBACK SUBMISSION
  // ============================================
  print('=== Submitting Feedback ===');

  try {
    // Submit search feedback event (NEW API: click/add_to_cart/purchase)
    await sdk.feedback.submitSearchFeedbackEvent(new SearchFeedbackEvent(
      query: 'product',
      eventType: FeedbackEventType.click,
      itemId: 'item-1',
      itemOrder: '1',
      itemPrice: '95.5',
      url: 'http://mysite.com/posts/lableb-post',
      sessionId: '1c4Hb23',
      userId: 'user-123',
      country: 'DE',
      userIp: '192.111.24.21',
    ));
    print('Search feedback event submitted successfully');

    // Submit autocomplete feedback
    await sdk.feedback
        .submitAutocompleteFeedbackEvent(new AutocompleteFeedbackEvent(
      query: 'product',
      eventType: FeedbackEventType.click,
      itemId: 'item-1',
      itemOrder: '1',
      itemPrice: '95.5',
      url: 'http://mysite.com/posts/lableb-post',
      sessionId: '1c4Hb23',
      userId: 'user-123',
      userIp: '192.111.24.21',
      country: 'DE',
    ));
    print('Autocomplete feedback submitted successfully');

    // Submit recommender feedback
    await sdk.feedback.submitRecommendFeedbackEvent(new RecommendFeedbackEvent(
      eventType: FeedbackEventType.addToCart,
      sourceId: 'item-1',
      sourceUrl: 'http://mysite.com/posts/lableb-post',
      sourceTitle: "test item 1",
      targetId: 'item-2',
      targetUrl: 'http://mysite.com/posts/lableb-post2',
      targetTitle: "test item 2",
      itemOrder: '1',
      itemPrice: '95.5',
      sessionId: '1c4Hb23',
      userId: 'user-123',
      userIp: '192.111.24.21',
      country: 'DE',
      cartId: 'cart-456',
    ));
    print('Recommender feedback submitted successfully\n');
  } catch (e) {
    print('Error submitting feedback: $e\n');
  }
}

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
    apiKey: 'your-api-key-here', // Replace with your actual API key
    enableLogging: true, // Enable logging for debugging
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  );

  print('SDK initialized successfully!\n');

  // ============================================
  // 2. INDEXING DATA
  // ============================================
  print('=== Indexing Data ===');
  
  try {
    // Index a single item
    final item = IndexEntity(
      id: 'item-1',
      data: {
        'title': 'Example Product',
        'description': 'This is an example product description',
        'price': 99.99,
        'category': 'electronics',
      },
    );

    final indexedItem = await sdk.index.indexItem(item);
    print('Item indexed: ${indexedItem.id}');

    // Index multiple items in batch
    final batchItems = [
      IndexEntity(
        id: 'item-2',
        data: {
          'title': 'Another Product',
          'description': 'Another product description',
          'price': 149.99,
          'category': 'electronics',
        },
      ),
      IndexEntity(
        id: 'item-3',
        data: {
          'title': 'Third Product',
          'description': 'Third product description',
          'price': 79.99,
          'category': 'clothing',
        },
      ),
    ];

    final indexedItems = await sdk.index.indexBatch(batchItems);
    print('Batch indexed: ${indexedItems.length} items\n');
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
      query: 'product',
      page: 1,
      pageSize: 10,
    );

    print('Search Results:');
    print('Total results: ${searchResult.totalResults}');
    print('Current page: ${searchResult.pagination.currentPage}');
    print('Total pages: ${searchResult.pagination.totalPages}');
    
    for (final result in searchResult.results) {
      print('  - ${result.id}: ${result.data['title']} (score: ${result.score})');
    }
    print('');

    // Search with filters
    final filteredSearch = await sdk.search.search(
      query: 'product',
      filters: {
        'category': 'electronics',
        'price': {'gte': 50, 'lte': 200},
      },
      sort: {'price': 'asc'},
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
      query: 'prod',
      limit: 5,
    );

    print('Autocomplete Suggestions:');
    for (final suggestion in suggestions) {
      print('  - ${suggestion.text} (score: ${suggestion.score})');
    }
    print('');
  } catch (e) {
    print('Error getting autocomplete: $e\n');
  }

  // ============================================
  // 5. RECOMMENDATION OPERATIONS
  // ============================================
  print('=== Getting Recommendations ===');
  
  try {
    // User-based recommendations
    final userRecommendations = await sdk.recommender.getRecommendations(
      userId: 'user-123',
      limit: 10,
      context: {
        'category': 'electronics',
      },
    );

    print('User Recommendations:');
    for (final recommendation in userRecommendations) {
      print('  - ${recommendation.id}: ${recommendation.data['title']} '
          '(score: ${recommendation.score})');
    }
    print('');

    // Item-based recommendations
    final itemRecommendations = await sdk.recommender.getRecommendations(
      itemId: 'item-1',
      limit: 5,
    );

    print('Item-based Recommendations:');
    for (final recommendation in itemRecommendations) {
      print('  - ${recommendation.id}: ${recommendation.data['title']}');
    }
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
    await sdk.feedback.submitSearchFeedbackEvent(
      project: 'wptest',
      collection: 'posts',
      handler: 'default',
      query: 'product',
      eventType: SearchFeedbackEventType.click,
      itemId: 'item-1',
      itemOrder: 1,
      itemPrice: 95.5,
      url: 'http://mysite.com/posts/lableb-post',
      sessionId: '1c4Hb23',
      userId: 'user-123',
      userIp: '192.111.24.21',
      userCountry: 'DE',
    );
    print('Search feedback event submitted successfully');

    // Submit autocomplete feedback
    await sdk.feedback.submitAutocompleteFeedback(
      query: 'prod',
      suggestion: 'product',
      feedbackValue: 'clicked',
    );
    print('Autocomplete feedback submitted successfully');

    // Submit recommender feedback
    await sdk.feedback.submitRecommenderFeedback(
      recommendationId: 'item-2',
      feedbackValue: 'positive',
      userId: 'user-123',
      metadata: {
        'purchased': true,
      },
    );
    print('Recommender feedback submitted successfully\n');
  } catch (e) {
    print('Error submitting feedback: $e\n');
  }

  // ============================================
  // 7. ERROR HANDLING EXAMPLES
  // ============================================
  print('=== Error Handling Examples ===');
  
  try {
    // This will likely fail if the item doesn't exist
    await sdk.index.deleteItem('non-existent-item');
  } on NotFoundException catch (e) {
    print('Item not found: ${e.message}');
  } on UnauthorizedException catch (e) {
    print('Unauthorized access: ${e.message}');
  } on NetworkException catch (e) {
    print('Network error: ${e.message}');
  } on TimeoutException catch (e) {
    print('Request timed out: ${e.message}');
  } on ValidationException catch (e) {
    print('Validation error: ${e.message}');
  } on ServerException catch (e) {
    print('Server error: ${e.message}');
  } on LablebException catch (e) {
    print('Lableb error: ${e.message}');
  } catch (e) {
    print('Unexpected error: $e');
  }

  // ============================================
  // 8. UPDATE AND DELETE OPERATIONS
  // ============================================
  print('\n=== Update and Delete Operations ===');
  
  try {
    // Update an existing item
    final updatedItem = IndexEntity(
      id: 'item-1',
      data: {
        'title': 'Updated Product',
        'description': 'Updated description',
        'price': 89.99,
        'category': 'electronics',
      },
    );

    final result = await sdk.index.updateItem(updatedItem);
    print('Item updated: ${result.id}');

    // Delete an item
    await sdk.index.deleteItem('item-3');
    print('Item deleted successfully');
  } catch (e) {
    print('Error in update/delete operations: $e');
  }

  print('\n=== Example completed ===');
}


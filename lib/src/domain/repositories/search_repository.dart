import '../../exceptions/exceptions.dart';
import '../../data/responses/matching_response.dart';
import 'package:dio/dio.dart';

/// Abstract repository interface for search operations.
///
/// This defines the contract for performing searches in the Lableb system.
abstract class SearchRepository {
  /// Performs a search query.
  ///
  /// [query] - The search query string.
  /// [filters] - Optional filters to apply to the search.
  /// [sort] - Optional sort parameter (e.g., "price asc", "date desc").
  /// [page] - Page number for pagination (default: 1).
  /// [pageSize] - Number of results per page (default: 10).
  /// [sessionId] - Optional session identifier for analytics.
  /// [userId] - Optional user identifier for analytics.
  /// [userIp] - Optional user IP address for analytics.
  /// [userCountry] - Optional user country for analytics.
  /// [requestSource] - Optional request source for analytics.
  ///
  /// Returns a list of search results and pagination info.
  /// Throws [LablebException] if search fails.
  Future<MatchingResponse> search({
    String? handler,
    required String query,
    Map<String, dynamic>? filters,
    String? sort,
    int page = 1,
    int pageSize = 10,
    String? sessionId,
    String? userId,
    String? userIp,
    String? userCountry,
    String? requestSource,
    CancelToken? cancelToken,
  });
}

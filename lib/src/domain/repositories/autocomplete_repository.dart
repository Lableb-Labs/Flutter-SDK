import '../../exceptions/exceptions.dart';
import '../../data/responses/matching_response.dart';

/// Abstract repository interface for autocomplete operations.
///
/// This defines the contract for getting autocomplete suggestions.
abstract class AutocompleteRepository {
  /// Gets autocomplete suggestions for a given query.
  ///
  /// [query] - The partial query string.
  /// [limit] - Maximum number of suggestions to return (default: 10).
  /// [filters] - Optional filters to apply.
  /// [sessionId] - Optional session identifier for analytics.
  /// [userId] - Optional user identifier for analytics.
  /// [userIp] - Optional user IP address for analytics.
  /// [userCountry] - Optional user country for analytics.
  /// [requestSource] - Optional request source for analytics.
  ///
  /// Returns a unified autocomplete response.
  /// Throws [LablebException] if the request fails.
  Future<MatchingResponse> getSuggestions({
    String? handler,
    required String query,
    int limit = 10,
    Map<String, dynamic>? filters,
    String? sessionId,
    String? userId,
    String? userIp,
    String? userCountry,
    String? requestSource,
  });
}

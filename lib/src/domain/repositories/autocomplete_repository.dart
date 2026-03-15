import '../entities/autocomplete_entity.dart';
import '../../exceptions/exceptions.dart';

/// Abstract repository interface for autocomplete operations.
/// 
/// This defines the contract for getting autocomplete suggestions.
abstract class AutocompleteRepository {
  /// Gets autocomplete suggestions for a given query.
  /// 
  /// [query] - The partial query string.
  /// [limit] - Maximum number of suggestions to return (default: 10).
  /// [filters] - Optional filters to apply.
  /// 
  /// Returns a list of autocomplete suggestions.
  /// Throws [LablebException] if the request fails.
  Future<List<AutocompleteEntity>> getSuggestions({
    required String query,
    int limit = 10,
    Map<String, dynamic>? filters,
  });
}


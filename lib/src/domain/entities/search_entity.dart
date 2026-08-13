/// Domain entity representing a search result.
/// 
/// This entity represents a single result returned from a search query.
class SearchEntity {
  /// Unique identifier of the result.
  final String id;
  
  /// The result content/data.
  final Map<String, dynamic> data;
  
  /// Relevance score for this result.
  final double? score;
  
  /// Highlighted snippets from the search query.
  final Map<String, List<String>>? highlights;

  SearchEntity({
    required this.id,
    required this.data,
    this.score,
    this.highlights,
  });
}


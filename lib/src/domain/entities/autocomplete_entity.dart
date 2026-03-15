/// Domain entity representing an autocomplete suggestion.
/// 
/// This entity represents a single autocomplete suggestion returned
/// by the autocomplete API.
class AutocompleteEntity {
  /// The suggested text.
  final String text;
  
  /// Optional metadata associated with the suggestion.
  final Map<String, dynamic>? metadata;
  
  /// Relevance score for this suggestion.
  final double? score;

  AutocompleteEntity({
    required this.text,
    this.metadata,
    this.score,
  });
}


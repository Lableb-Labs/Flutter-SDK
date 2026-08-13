import '../../domain/entities/autocomplete_entity.dart';

/// Data model representing an autocomplete suggestion.
/// 
/// This model is used for serialization/deserialization when
/// communicating with the API.
class AutocompleteModel {
  /// The suggested text.
  final String text;
  
  /// Optional metadata associated with the suggestion.
  final Map<String, dynamic>? metadata;
  
  /// Relevance score for this suggestion.
  final double? score;

  AutocompleteModel({
    required this.text,
    this.metadata,
    this.score,
  });

  /// Creates an [AutocompleteModel] from a JSON map.
  ///
  /// Lableb's real suggestion items are flat product documents with no
  /// `text` field — `name` is used as the suggestion text, and the whole
  /// item (minus text/score) becomes [metadata] when no explicit
  /// `metadata` key is present.
  factory AutocompleteModel.fromJson(Map<String, dynamic> json) {
    final metadata = json['metadata'] is Map<String, dynamic>
        ? json['metadata'] as Map<String, dynamic>
        : (Map<String, dynamic>.from(json)
          ..remove('text')
          ..remove('name')
          ..remove('score'));

    return AutocompleteModel(
      text: json['text'] as String? ??
          json['name'] as String? ??
          json['title'] as String? ??
          '',
      metadata: metadata,
      score: json['score'] != null ? (json['score'] as num).toDouble() : null,
    );
  }

  /// Converts the [AutocompleteModel] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      if (metadata != null) 'metadata': metadata,
      if (score != null) 'score': score,
    };
  }

  /// Converts the model to a domain entity.
  AutocompleteEntity toEntity() {
    return AutocompleteEntity(
      text: text,
      metadata: metadata,
      score: score,
    );
  }

  /// Creates a model from a domain entity.
  factory AutocompleteModel.fromEntity(AutocompleteEntity entity) {
    return AutocompleteModel(
      text: entity.text,
      metadata: entity.metadata,
      score: entity.score,
    );
  }
}


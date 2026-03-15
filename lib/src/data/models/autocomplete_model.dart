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
  factory AutocompleteModel.fromJson(Map<String, dynamic> json) {
    return AutocompleteModel(
      text: json['text'] as String,
      metadata: json['metadata'] != null
          ? json['metadata'] as Map<String, dynamic>
          : null,
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


import '../../domain/entities/search_entity.dart';

/// Data model representing a search result.
/// 
/// This model is used for serialization/deserialization when
/// communicating with the API.
class SearchModel {
  /// Unique identifier of the result.
  final String id;
  
  /// The result content/data.
  final Map<String, dynamic> data;
  
  /// Relevance score for this result.
  final double? score;
  
  /// Highlighted snippets from the search query.
  final Map<String, List<String>>? highlights;

  SearchModel({
    required this.id,
    required this.data,
    this.score,
    this.highlights,
  });

  /// Creates a [SearchModel] from a JSON map.
  factory SearchModel.fromJson(Map<String, dynamic> json) {
    return SearchModel(
      id: json['id'] as String,
      data: json['data'] as Map<String, dynamic>,
      score: json['score'] != null ? (json['score'] as num).toDouble() : null,
      highlights: json['highlights'] != null
          ? Map<String, List<String>>.from(
              (json['highlights'] as Map).map(
                (key, value) => MapEntry(
                  key as String,
                  List<String>.from(value as List),
                ),
              ),
            )
          : null,
    );
  }

  /// Converts the [SearchModel] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'data': data,
      if (score != null) 'score': score,
      if (highlights != null) 'highlights': highlights,
    };
  }

  /// Converts the model to a domain entity.
  SearchEntity toEntity() {
    return SearchEntity(
      id: id,
      data: data,
      score: score,
      highlights: highlights,
    );
  }

  /// Creates a model from a domain entity.
  factory SearchModel.fromEntity(SearchEntity entity) {
    return SearchModel(
      id: entity.id,
      data: entity.data,
      score: entity.score,
      highlights: entity.highlights,
    );
  }
}


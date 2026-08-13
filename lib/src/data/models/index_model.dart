import '../../domain/entities/index_entity.dart';

/// Data model representing indexed data.
/// 
/// This model is used for serialization/deserialization when
/// communicating with the API.
class IndexModel {
  /// Unique identifier for the indexed item.
  final String id;
  
  /// The indexed data content.
  final Map<String, dynamic> data;
  
  /// Timestamp when the item was indexed.
  final DateTime? indexedAt;
  
  /// Status of the indexing operation.
  final String? status;

  IndexModel({
    required this.id,
    required this.data,
    this.indexedAt,
    this.status,
  });

  /// Creates an [IndexModel] from a JSON map.
  factory IndexModel.fromJson(Map<String, dynamic> json) {
    return IndexModel(
      id: json['id'] as String,
      data: json['data'] as Map<String, dynamic>,
      indexedAt: json['indexed_at'] != null
          ? DateTime.parse(json['indexed_at'] as String)
          : null,
      status: json['status'] as String?,
    );
  }

  /// Converts the [IndexModel] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'data': data,
      if (indexedAt != null) 'indexed_at': indexedAt!.toIso8601String(),
      if (status != null) 'status': status,
    };
  }

  /// Converts the model to a domain entity.
  IndexEntity toEntity() {
    return IndexEntity(
      id: id,
      data: data,
      indexedAt: indexedAt,
      status: status,
    );
  }

  /// Creates a model from a domain entity.
  factory IndexModel.fromEntity(IndexEntity entity) {
    return IndexModel(
      id: entity.id,
      data: entity.data,
      indexedAt: entity.indexedAt,
      status: entity.status,
    );
  }
}


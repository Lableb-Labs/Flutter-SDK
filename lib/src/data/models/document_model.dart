import '../../domain/entities/document_entity.dart';

/// Data model representing a search result.
///
/// This model is used for serialization/deserialization when
/// communicating with the API.
class DocumentModel {
  /// Unique identifier of the result.
  final String id;

  /// The result content/data.
  final Map<String, dynamic> data;

  DocumentModel({required this.id, required this.data});

  /// Creates a [DocumentModel] from a JSON map.
  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    final id = json['id']?.toString() ??
        json['base_id']?.toString() ??
        json['_id']?.toString() ??
        '';

    final data = json.containsKey('data') &&
            json['data'] is Map<String, dynamic>
        ? Map<String, dynamic>.from(json['data'] as Map)
        : Map<String, dynamic>.from(json)
      ..remove('id');

    return DocumentModel(id: id, data: data);
  }

  /// Converts the [DocumentModel] to a JSON map.
  Map<String, dynamic> toJson() {
    return {'id': id, 'data': data};
  }

  /// Converts the model to a domain entity.
  DocumentEntity toEntity() {
    return DocumentEntity(id: id, data: data);
  }

  /// Creates a model from a domain entity.
  factory DocumentModel.fromEntity(DocumentEntity entity) {
    return DocumentModel(id: entity.id, data: entity.data);
  }
}

/// Domain entity representing a search result.
///
/// This entity represents a single result returned from a search query.
class DocumentEntity {
  /// Unique identifier of the result.
  final String id;

  /// The result content/data.
  final Map<String, dynamic> data;

  DocumentEntity({required this.id, required this.data});
}

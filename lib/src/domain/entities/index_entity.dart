/// Domain entity representing indexed data.
/// 
/// This entity represents data that has been indexed in the Lableb system.
/// It is part of the domain layer and is independent of data source implementation.
class IndexEntity {
  /// Unique identifier for the indexed item.
  final String id;
  
  /// The indexed data content.
  final Map<String, dynamic> data;
  
  /// Timestamp when the item was indexed.
  final DateTime? indexedAt;
  
  /// Status of the indexing operation.
  final String? status;

  IndexEntity({
    required this.id,
    required this.data,
    this.indexedAt,
    this.status,
  });
}


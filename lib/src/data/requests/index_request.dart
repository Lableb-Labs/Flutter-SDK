import '../models/index_model.dart';

/// Request model for indexing data.
/// 
/// This model is used to structure the request body when
/// sending data to the index endpoint.
class IndexRequest {
  /// List of items to index.
  final List<IndexModel> items;
  
  /// Optional index name or collection.
  final String? index;
  
  /// Optional operation type (index, update, delete).
  final String? operation;

  IndexRequest({
    required this.items,
    this.index,
    this.operation,
  });

  /// Converts the [IndexRequest] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      if (index != null) 'index': index,
      if (operation != null) 'operation': operation,
    };
  }
}


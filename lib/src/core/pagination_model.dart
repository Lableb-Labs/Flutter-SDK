/// Model representing pagination information in API responses.
/// 
/// This model is used to handle paginated responses from the Lableb API,
/// providing information about the current page, total pages, and total items.
class PaginationModel {
  /// Current page number (1-indexed).
  final int currentPage;
  
  /// Total number of pages available.
  final int totalPages;
  
  /// Total number of items across all pages.
  final int totalItems;
  
  /// Number of items per page.
  final int? itemsPerPage;
  
  /// Whether there is a next page available.
  final bool? hasNextPage;
  
  /// Whether there is a previous page available.
  final bool? hasPreviousPage;

  PaginationModel({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    this.itemsPerPage,
    this.hasNextPage,
    this.hasPreviousPage,
  });

  /// Creates a [PaginationModel] from a JSON map.
  /// 
  /// Handles various JSON formats that might be returned by the API.
  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      currentPage: json['current_page'] ?? json['currentPage'] ?? json['page'] ?? 1,
      totalPages: json['total_pages'] ?? json['totalPages'] ?? json['pages'] ?? 1,
      totalItems: json['total_items'] ?? json['totalItems'] ?? json['total'] ?? 0,
      itemsPerPage: json['items_per_page'] ?? json['itemsPerPage'] ?? json['perPage'],
      hasNextPage: json['has_next_page'] ?? json['hasNextPage'] ?? json['hasNext'],
      hasPreviousPage: json['has_previous_page'] ?? json['hasPreviousPage'] ?? json['hasPrevious'],
    );
  }

  /// Converts the [PaginationModel] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'total_pages': totalPages,
      'total_items': totalItems,
      if (itemsPerPage != null) 'items_per_page': itemsPerPage,
      if (hasNextPage != null) 'has_next_page': hasNextPage,
      if (hasPreviousPage != null) 'has_previous_page': hasPreviousPage,
    };
  }

  /// Returns true if there is a next page available.
  bool get canGoNext => hasNextPage ?? (currentPage < totalPages);

  /// Returns true if there is a previous page available.
  bool get canGoPrevious => hasPreviousPage ?? (currentPage > 1);
}


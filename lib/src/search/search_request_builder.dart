import 'package:get_it/get_it.dart';

import '../domain/repositories/search_repository.dart';

/// Entry step for building a search request.
abstract interface class SearchRequestBuilderStart {
  /// Sets the required search query.
  SearchRequestBuilderOptions forQuery(String query);
}

/// Options step for enriching the search request.
abstract interface class SearchRequestBuilderOptions {
  /// Adds filters to the search request.
  SearchRequestBuilderOptions withFilters(Map<String, dynamic> filters);

  /// Adds sort parameters to the search request.
  ///
  /// Example: `withSort({'price': 'asc'})`.
  SearchRequestBuilderOptions withSort(Map<String, String> sort);

  /// Convenience for sorting by a single field.
  SearchRequestBuilderOptions sortBy(
    String field, {
    String direction,
  });

  /// Sets pagination.
  SearchRequestBuilderOptions paginate({
    int page,
    int pageSize,
  });

  /// Executes the search through the locator-resolved repository.
  Future<SearchResult> send();
}

class SearchRequestBuilder
    implements SearchRequestBuilderStart, SearchRequestBuilderOptions {
  String? _query;
  Map<String, dynamic>? _filters;
  Map<String, String>? _sort;
  int _page = 1;
  int _pageSize = 10;

  @override
  SearchRequestBuilderOptions forQuery(String query) {
    assert(query.trim().isNotEmpty, 'query is required');
    _query = query;
    return this;
  }

  @override
  SearchRequestBuilderOptions withFilters(Map<String, dynamic> filters) {
    _filters = Map<String, dynamic>.from(filters);
    return this;
  }

  @override
  SearchRequestBuilderOptions withSort(Map<String, String> sort) {
    _sort = Map<String, String>.from(sort);
    return this;
  }

  @override
  SearchRequestBuilderOptions sortBy(
    String field, {
    String direction = 'asc',
  }) {
    assert(field.trim().isNotEmpty, 'sort field cannot be empty');
    assert(direction == 'asc' || direction == 'desc', 'direction must be asc/desc');
    _sort = <String, String>{field: direction};
    return this;
  }

  @override
  SearchRequestBuilderOptions paginate({
    int page = 1,
    int pageSize = 10,
  }) {
    assert(page >= 1, 'page must be >= 1');
    assert(pageSize >= 1, 'pageSize must be >= 1');
    _page = page;
    _pageSize = pageSize;
    return this;
  }

  @override
  Future<SearchResult> send() async {
    final query = _query;
    assert(query != null && query.trim().isNotEmpty, 'query is required');

    final repo = GetIt.instance<SearchRepository>();
    // ignore: deprecated_member_use_from_same_package
    return repo.search(
      query: query!,
      filters: _filters,
      sort: _sort,
      page: _page,
      pageSize: _pageSize,
    );
  }
}


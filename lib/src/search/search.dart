import '../di/locator.dart';
import '../sdk_initializer.dart';
import 'search_request_builder.dart';

/// Fluent builders for Search API calls.
extension SearchModule on LablebSDK {
  /// Starts a fluent builder for search requests.
  ///
  /// Example:
  /// ```dart
  /// final result = await sdk
  ///     .searchRequest()
  ///     .forQuery('laptop')
  ///     .withFilters({'brand': 'Dell'})
  ///     .sortBy('price', direction: 'asc')
  ///     .paginate(page: 1, pageSize: 10)
  ///     .send();
  /// ```
  SearchRequestBuilderStart searchRequest() => locator<SearchRequestBuilderStart>();
}


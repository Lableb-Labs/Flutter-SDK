import '../../api/api_client.dart';
import '../../domain/repositories/index_repository.dart';
import 'dart:convert';

/// Implementation of [IndexRepository] for data indexing operations.
///
/// This repository handles all communication with the index API endpoints.
class IndexRepositoryImpl implements IndexRepository {
  /// The API client for making HTTP requests.
  final ApiClientBase _apiClient;

  IndexRepositoryImpl(this._apiClient);

  @override
  Future<void> uploadDocuments(List<Map<String, dynamic>> documents) async {
    try {
      await _apiClient.post(
        '/documents',
        data: jsonEncode(documents),
        queryParameters: {'apikey': _apiClient.apiKeyIndex},
      );

      // Assuming success if no exception
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> removeDocuments(List<String> documentIds) async {
    try {
      await _apiClient.delete(
        '/documents',
        data: jsonEncode(documentIds),
        queryParameters: {'apikey': _apiClient.apiKeyIndex},
      );
    } catch (e) {
      rethrow;
    }
  }
}

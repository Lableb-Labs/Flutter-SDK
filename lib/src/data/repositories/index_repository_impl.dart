import '../../api/api_client.dart';
import '../../domain/entities/index_entity.dart';
import '../../domain/repositories/index_repository.dart';
import '../models/index_model.dart';
import '../requests/index_request.dart';
import '../responses/index_response.dart';

/// Implementation of [IndexRepository] for data indexing operations.
/// 
/// This repository handles all communication with the index API endpoints.
class IndexRepositoryImpl implements IndexRepository {
  /// The API client for making HTTP requests.
  final ApiClientBase _apiClient;

  IndexRepositoryImpl(this._apiClient);

  @override
  Future<IndexEntity> indexItem(IndexEntity item) async {
    try {
      final model = IndexModel.fromEntity(item);
      final request = IndexRequest(items: [model]);
      
      final response = await _apiClient.post(
        '/index',
        data: request.toJson(),
      );

      final indexResponse = IndexResponse.fromJson(
        response.data as Map<String, dynamic>,
      );

      if (!indexResponse.success) {
        throw Exception(indexResponse.message);
      }

      if (indexResponse.items != null && indexResponse.items!.isNotEmpty) {
        return indexResponse.items!.first.toEntity();
      }

      return item;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<IndexEntity>> indexBatch(List<IndexEntity> items) async {
    try {
      final models = items.map((item) => IndexModel.fromEntity(item)).toList();
      final request = IndexRequest(items: models);
      
      final response = await _apiClient.post(
        '/index/batch',
        data: request.toJson(),
      );

      final indexResponse = IndexResponse.fromJson(
        response.data as Map<String, dynamic>,
      );

      if (!indexResponse.success) {
        throw Exception(indexResponse.message);
      }

      if (indexResponse.items != null) {
        return indexResponse.items!.map((item) => item.toEntity()).toList();
      }

      return items;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<IndexEntity> updateItem(IndexEntity item) async {
    try {
      final model = IndexModel.fromEntity(item);
      final request = IndexRequest(
        items: [model],
        operation: 'update',
      );
      
      final response = await _apiClient.put(
        '/index/${item.id}',
        data: request.toJson(),
      );

      final indexResponse = IndexResponse.fromJson(
        response.data as Map<String, dynamic>,
      );

      if (!indexResponse.success) {
        throw Exception(indexResponse.message);
      }

      if (indexResponse.items != null && indexResponse.items!.isNotEmpty) {
        return indexResponse.items!.first.toEntity();
      }

      return item;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteItem(String id) async {
    try {
      await _apiClient.delete('/index/$id');
    } catch (e) {
      rethrow;
    }
  }
}


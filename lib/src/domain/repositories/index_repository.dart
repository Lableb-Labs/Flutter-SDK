import '../entities/index_entity.dart';
import '../../exceptions/exceptions.dart';

/// Abstract repository interface for index operations.
/// 
/// This defines the contract for indexing data into the Lableb system.
/// Implementations should be in the data layer.
abstract class IndexRepository {
  /// Indexes a single item into the system.
  /// 
  /// [item] - The item to index.
  /// 
  /// Returns the indexed entity.
  /// Throws [LablebException] if indexing fails.
  Future<IndexEntity> indexItem(IndexEntity item);

  /// Indexes multiple items in a batch operation.
  /// 
  /// [items] - List of items to index.
  /// 
  /// Returns list of indexed entities.
  /// Throws [LablebException] if indexing fails.
  Future<List<IndexEntity>> indexBatch(List<IndexEntity> items);

  /// Updates an existing indexed item.
  /// 
  /// [item] - The item with updated data.
  /// 
  /// Returns the updated entity.
  /// Throws [LablebException] if update fails.
  Future<IndexEntity> updateItem(IndexEntity item);

  /// Deletes an indexed item.
  /// 
  /// [id] - The ID of the item to delete.
  /// 
  /// Throws [LablebException] if deletion fails.
  Future<void> deleteItem(String id);
}


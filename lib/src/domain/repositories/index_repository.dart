import '../../exceptions/exceptions.dart';

/// Abstract repository interface for index operations.
///
/// This defines the contract for indexing data into the Lableb system.
/// Implementations should be in the data layer.
abstract class IndexRepository {
  /// Uploads documents to the index.
  ///
  /// [documents] - List of document maps to upload.
  ///
  /// Throws [LablebException] if upload fails.
  Future<void> uploadDocuments(List<Map<String, dynamic>> documents);

  /// Removes documents from the index.
  ///
  /// [documentIds] - List of document IDs to remove.
  ///
  /// Throws [LablebException] if removal fails.
  Future<void> removeDocuments(List<String> documentIds);
}

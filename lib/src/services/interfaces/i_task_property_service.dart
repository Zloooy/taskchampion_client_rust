import '../../models/models.dart';

/// Abstract interface for task property retrieval operations.
abstract interface class ITaskPropertyService {
  /// Retrieve distinct values for a given task property.
  Future<List<String>> getPropertyValues({
    required String property,
    TaskFilter? filter,
    TaskSort? sort,
  });

  /// Retrieve distinct property values stored in the database
  /// with typed conversion.
  Future<List<T>> getStoredPropertyValues<T>({
    required String property,
    TaskFilter? filter,
    TaskSort? sort,
  });

  /// Retrieve all possible enum values for a given type.
  Future<List<T>> getAllPropertyValues<T>();
}

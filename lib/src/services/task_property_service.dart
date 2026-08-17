import '../core/core.dart';
import '../models/models.dart';
import '../storage/task_storage.dart';
import 'interfaces/i_task_property_service.dart';
import 'property_type_registry.dart';

/// Service for retrieving distinct values of task properties.
///
/// Provides access to the property values (descriptions, projects, etc.)
/// that exist across tasks in the database.
class TaskPropertyService implements ITaskPropertyService {
  /// Underlying storage implementation.
  final TaskStorage _storage;

  /// Logger for this service.
  final Logger _logger;

  /// Registry mapping Dart types to [PropertyReturnType].
  final PropertyTypeRegistry _propertyRegistry = PropertyTypeRegistry();

  /// Registry for enum-only lookups.
  final EnumPropertyTypeRegistry _enumRegistry = EnumPropertyTypeRegistry();

  /// Create a new TaskPropertyService instance.
  TaskPropertyService(this._storage, {Logger? logger})
    : _logger = logger ?? const DebugPrintLogger();

  @override
  Future<List<String>> getPropertyValues({
    required String property,
    TaskFilter? filter,
    TaskSort? sort,
  }) async {
    try {
      final propertyValues = await _storage.getTaskPropertyValues(property, filter, sort);
      return propertyValues;
    } catch (e, st) {
      _logger.error(
        'Failed to get property values for $property',
        error: e,
        stackTrace: st,
      );
      return [];
    }
  }

  @override
  Future<List<T>> getStoredPropertyValues<T>({
    required String property,
    TaskFilter? filter,
    TaskSort? sort,
  }) async {
    final returnType = _propertyRegistry.resolve<T>();

    try {
      final values = await _storage.getTaskPropertyValuesTyped(
        property,
        returnType,
        filter,
        sort,
      );
      return values.cast<T>();
    } catch (e, st) {
      _logger.error(
        'Failed to get typed property values for $property',
        error: e,
        stackTrace: st,
      );
      return [];
    }
  }

  @override
  Future<List<T>> getAllPropertyValues<T>() async {
    final returnType = _enumRegistry.resolve<T>();

    try {
      final values = await _storage.getAllEnumValues(returnType);
      return values.cast<T>();
    } catch (e, st) {
      _logger.error('Failed to get all enum values', error: e, stackTrace: st);
      rethrow;
    }
  }
}

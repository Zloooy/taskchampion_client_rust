import '../models/models.dart';
import '../rust_bridge/properties.dart';

/// Registry that maps Dart [Type] objects to their corresponding
/// [PropertyReturnType] values.
///
/// Enables OCP-compliant addition of new typed properties without
/// modifying existing service code.
class PropertyTypeRegistry {
  final Map<Type, PropertyReturnType> _registry = {};

  /// Create a registry pre-populated with the standard types.
  PropertyTypeRegistry() {
    register<String>(PropertyReturnType.string);
    register<DateTime>(PropertyReturnType.dateTime);
    register<TaskStatus>(PropertyReturnType.enumStatus);
    register<TaskPriority>(PropertyReturnType.enumPriority);
  }

  /// Register a mapping for type [T].
  void register<T>(PropertyReturnType returnType) {
    _registry[T] = returnType;
  }

  /// Resolve the [PropertyReturnType] for type [T].
  ///
  /// Throws [ArgumentError] if the type has not been registered.
  PropertyReturnType resolve<T>() {
    final result = _registry[T];
    if (result == null) {
      throw ArgumentError(
        'Unsupported generic type $T. '
        'Supported types: ${_registry.keys.join(', ')}',
      );
    }
    return result;
  }

  /// Check whether type [T] has been registered.
  bool supports<T>() => _registry.containsKey(T);
}

/// Registry restricted to enum-only types.
class EnumPropertyTypeRegistry {
  final Map<Type, PropertyReturnType> _registry = {};

  /// Create a registry pre-populated with the standard enum types.
  EnumPropertyTypeRegistry() {
    register<TaskStatus>(PropertyReturnType.enumStatus);
    register<TaskPriority>(PropertyReturnType.enumPriority);
  }

  /// Register a mapping for type [T].
  void register<T>(PropertyReturnType returnType) {
    _registry[T] = returnType;
  }

  /// Resolve the [PropertyReturnType] for enum type [T].
  ///
  /// Throws [ArgumentError] if the type has not been registered.
  PropertyReturnType resolve<T>() {
    final result = _registry[T];
    if (result == null) {
      throw ArgumentError(
        'Unsupported generic type $T for enum lookup. '
        'Supported types: ${_registry.keys.join(', ')}',
      );
    }
    return result;
  }

  /// Check whether type [T] has been registered.
  bool supports<T>() => _registry.containsKey(T);
}

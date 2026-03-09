import 'task_property_ref.dart';

/// Sort direction enum
enum SortDirection {
  /// Ascending order (A-Z, 0-9, oldest-first)
  ascending,

  /// Descending order (Z-A, 9-0, newest-first)
  descending,
}

/// Reference to a task property for type-safe sorting
sealed class TaskSort {
  /// Property name for sorting
  final String propertyName;

  /// Sort direction
  final SortDirection direction;

  const TaskSort(this.propertyName, [this.direction = SortDirection.ascending]);

  /// Create JSON representation for Rust FFI
  Map<String, dynamic> toJson() => {
        'property': {'name': propertyName},
        'direction': direction.name,
      };
}

/// Sort by string property (e.g., description, project)
final class StringPropertySort extends TaskSort {
  const StringPropertySort(super.propertyName, [super.direction = SortDirection.ascending]);
}

/// Sort by DateTime property (e.g., due, entry, modified)
final class DateTimePropertySort extends TaskSort {
  const DateTimePropertySort(super.propertyName, [super.direction = SortDirection.ascending]);
}

/// Sort by integer property (e.g., id)
final class IntPropertySort extends TaskSort {
  const IntPropertySort(super.propertyName, [super.direction = SortDirection.ascending]);
}

/// Sort by double property (e.g., urgency)
final class DoublePropertySort extends TaskSort {
  const DoublePropertySort(super.propertyName, [super.direction = SortDirection.ascending]);
}

/// Extension methods for creating common sorts from property refs
extension TaskSortExtensions on TaskPropertyRef {
  /// Sort by this property in ascending order
  TaskSort asc() => _createSort(this, SortDirection.ascending);

  /// Sort by this property in descending order
  TaskSort desc() => _createSort(this, SortDirection.descending);
}

/// Helper function to create the appropriate sort type based on property ref type
TaskSort _createSort<T>(TaskPropertyRef<T> property, SortDirection direction) {
  if (property is StringPropertyRef) {
    return StringPropertySort(property.name, direction);
  } else if (property is DateTimePropertyRef) {
    return DateTimePropertySort(property.name, direction);
  } else if (property is IntPropertyRef) {
    return IntPropertySort(property.name, direction);
  } else if (property is DoublePropertyRef) {
    return DoublePropertySort(property.name, direction);
  }
  // Default to string sort
  return StringPropertySort(property.name, direction);
}

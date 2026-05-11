import 'package:flutter_test/flutter_test.dart';
import 'package:taskchampion_client_rust/src/rust_bridge/properties.dart';
import 'package:taskchampion_client_rust/src/models/models.dart';

void main() {
  group('PropertyReturnType enum', () {
    test('has all expected variants', () {
      expect(PropertyReturnType.values.length, equals(4));
      expect(PropertyReturnType.values, contains(PropertyReturnType.string));
      expect(PropertyReturnType.values, contains(PropertyReturnType.dateTime));
      expect(
        PropertyReturnType.values,
        contains(PropertyReturnType.enumStatus),
      );
      expect(
        PropertyReturnType.values,
        contains(PropertyReturnType.enumPriority),
      );
    });
  });

  group('getStoredPropertyValues generic', () {
    test('throws ArgumentError for unsupported type', () {
      final service = _TestPropertyService();

      expect(
        () => service.getStoredPropertyValues<bool>(property: 'test'),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('getAllPropertyValues generic', () {
    test('throws ArgumentError for unsupported type', () {
      final service = _TestPropertyService();

      expect(
        () => service.getAllPropertyValues<String>(),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}

/// Minimal test double that only exercises the type-mapping logic,
/// avoiding any Rust FFI calls.
class _TestPropertyService {
  Future<List<T>> getStoredPropertyValues<T>({
    required String property,
    Object? filter,
    Object? sort,
  }) async {
    _mapTypeToPropertyReturnType<T>();
    return <T>[];
  }

  Future<List<T>> getAllPropertyValues<T>() async {
    _mapTypeToEnumPropertyReturnType<T>();
    return <T>[];
  }

  PropertyReturnType _mapTypeToPropertyReturnType<T>() {
    if (T == String) return PropertyReturnType.string;
    if (T == DateTime) return PropertyReturnType.dateTime;
    if (T == TaskStatus) return PropertyReturnType.enumStatus;
    if (T == TaskPriority) return PropertyReturnType.enumPriority;

    throw ArgumentError(
      'Unsupported generic type $T. Supported types: String, DateTime, TaskStatus, TaskPriority',
    );
  }

  PropertyReturnType _mapTypeToEnumPropertyReturnType<T>() {
    if (T == TaskStatus) return PropertyReturnType.enumStatus;
    if (T == TaskPriority) return PropertyReturnType.enumPriority;

    throw ArgumentError(
      'Unsupported generic type $T for getAllPropertyValues. Supported types: TaskStatus, TaskPriority',
    );
  }
}

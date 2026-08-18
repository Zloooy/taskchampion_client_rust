import 'package:equatable/equatable.dart';

/// Reference to a task property for type-safe filtering.
sealed class TaskPropertyRef extends Equatable {
  final String name;
  const TaskPropertyRef(this.name);

  Map<String, dynamic> toJson() => {'name': name};

  factory TaskPropertyRef.fromJson(Map<String, dynamic> json) {
    return StringPropertyRef(json['name'] as String);
  }

  @override
  List<Object?> get props => [runtimeType, name];
}

/// Reference to a string task property
final class StringPropertyRef extends TaskPropertyRef {
  const StringPropertyRef(super.name);

  @override
  List<Object?> get props => [runtimeType, name];
}

/// Reference to a DateTime task property
final class DateTimePropertyRef extends TaskPropertyRef {
  const DateTimePropertyRef(super.name);

  @override
  List<Object?> get props => [runtimeType, name];
}

/// Reference to an integer task property (e.g., id)
final class IntPropertyRef extends TaskPropertyRef {
  const IntPropertyRef(super.name);

  @override
  List<Object?> get props => [runtimeType, name];
}

/// Reference to a double task property (e.g., urgency)
final class DoublePropertyRef extends TaskPropertyRef {
  const DoublePropertyRef(super.name);

  @override
  List<Object?> get props => [runtimeType, name];
}

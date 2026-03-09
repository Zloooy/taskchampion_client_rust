/// Reference to a task property for type-safe filtering
sealed class TaskPropertyRef<T> {
  final String name;
  const TaskPropertyRef(this.name);

  Map<String, dynamic> toJson() => {'name': name};
}

/// Reference to a string task property
final class StringPropertyRef extends TaskPropertyRef<String> {
  const StringPropertyRef(super.name);
}

/// Reference to a DateTime task property
final class DateTimePropertyRef extends TaskPropertyRef<DateTime> {
  const DateTimePropertyRef(super.name);
}

/// Reference to an integer task property (e.g., id)
final class IntPropertyRef extends TaskPropertyRef<int> {
  const IntPropertyRef(super.name);
}

/// Reference to a double task property (e.g., urgency)
final class DoublePropertyRef extends TaskPropertyRef<double> {
  const DoublePropertyRef(super.name);
}
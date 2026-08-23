import 'package:freezed_annotation/freezed_annotation.dart';

part 'annotation.freezed.dart';
part 'annotation.g.dart';

/// A single annotation attached to a task.
///
/// Annotations are timestamped free-form notes recorded against a task.
/// [Task.annotations] is ordered oldest-first.
@freezed
abstract class Annotation with _$Annotation {
  const factory Annotation({
    /// Timestamp of when the annotation was added (UTC).
    required DateTime entry,

    /// The free-form annotation text.
    required String description,
  }) = _Annotation;

  /// Create an Annotation from a JSON map.
  factory Annotation.fromJson(Map<String, dynamic> json) =>
      _$AnnotationFromJson(json);
}

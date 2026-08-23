import 'annotation.dart';
import 'task.dart';

/// Responsible for parsing raw JSON maps from Rust FFI into [Task] instances.
///
/// This class encapsulates the complex mapping logic that transforms the flat
/// JSON structure (where UDAs are returned as top-level keys) into the typed
/// [Task] model.  The parsing is broken into focused private methods so that
/// each step can be understood and tested in isolation.
class TaskParser {
  /// Known task properties that should be extracted from raw JSON.
  static const _knownKeys = <String>{
    'uuid',
    'description',
    'status',
    'priority',
    'project',
    'tags',
    'due',
    'wait',
    'scheduled',
    'until',
    'entry',
    'modified',
    'end',
    'urgency',
    'parent',
    'depends',
    'annotations',
  };

  /// Properties that are stored as UDAs in TaskChampion but also exposed as
  /// first-class [Task] fields.
  static const _udaPropertyKeys = <String>{
    'project',
    'scheduled',
    'until',
    'parent',
    'urgency',
  };

  /// Parse a raw JSON map into a [Task].
  Task parse(Map<String, dynamic> json) {
    final knownProps = _extractKnownProperties(json);
    final annotations = _extractAnnotations(json);
    final udas = _extractUdas(json, knownProps);

    _applyTypeConversions(knownProps);
    _mergeUdaProperties(knownProps, udas);

    // `Task.fromJson` deserializes the list element-wise from maps, so hand
    // it plain JSON-shaped values (not already-constructed [Annotation]s).
    if (annotations.isNotEmpty) {
      knownProps['annotations'] = [
        for (final a in annotations)
          {'entry': a.entry.toIso8601String(), 'description': a.description},
      ];
    }

    final task = Task.fromJson(knownProps);

    return udas.isNotEmpty
        ? task.copyWith(udas: {...task.udas, ...udas})
        : task;
  }

  // ============================================================================
  // Private parsing steps
  // ============================================================================

  /// Extract known standard properties from the raw JSON map.
  Map<String, dynamic> _extractKnownProperties(Map<String, dynamic> json) {
    final knownProps = <String, dynamic>{};

    for (final entry in json.entries) {
      final key = entry.key;
      final value = entry.value;

      if (key.startsWith('annotation_')) {
        // Annotations are collected separately by [_extractAnnotations].
        continue;
      }

      if (_udaPropertyKeys.contains(key) && value != null) {
        knownProps[key] = value;
      } else if (_knownKeys.contains(key)) {
        knownProps[key] = value;
      }
    }

    return knownProps;
  }

  /// Collect the `annotation_<unixSeconds>` keys into [Annotation] values,
  /// sorted ascending by entry timestamp.
  ///
  /// The Rust read path (`task_to_map`) emits one flat key per annotation:
  /// `annotation_{entry.timestamp()}` mapping to the description string.
  /// Keys whose trailing integer cannot be parsed are skipped defensively.
  List<Annotation> _extractAnnotations(Map<String, dynamic> json) {
    final annotations = <Annotation>[];

    for (final entry in json.entries) {
      final key = entry.key;

      if (!key.startsWith('annotation_') || entry.value is! String) {
        continue;
      }

      final ts = int.tryParse(key.substring('annotation_'.length));
      if (ts == null) {
        continue;
      }

      annotations.add(
        Annotation(
          entry: DateTime.fromMillisecondsSinceEpoch(ts * 1000).toUtc(),
          description: entry.value as String,
        ),
      );
    }

    annotations.sort((a, b) => a.entry.compareTo(b.entry));
    return annotations;
  }

  /// Extract everything that is *not* a known property as a UDA.
  Map<String, String> _extractUdas(
    Map<String, dynamic> json,
    Map<String, dynamic> knownProps,
  ) {
    final udas = <String, String>{};

    for (final entry in json.entries) {
      final key = entry.key;

      if (key.startsWith('annotation_')) {
        continue;
      }
      if (_knownKeys.contains(key) && !_udaPropertyKeys.contains(key)) {
        continue;
      }
      if (entry.value is! String) {
        continue;
      }

      udas[key] = entry.value as String;
    }

    return udas;
  }

  /// Apply type conversions to known properties in-place.
  void _applyTypeConversions(Map<String, dynamic> props) {
    _convertDateTime(props, 'scheduled');
    _convertDateTime(props, 'until');
    _convertDouble(props, 'urgency');
    _convertStringList(props, 'tags');
    _convertStringList(props, 'depends');
    _ensureDefaultPriority(props);
  }

  /// Convert a property to a validated ISO-8601 string, or remove it.
  void _convertDateTime(Map<String, dynamic> props, String key) {
    final value = props[key];

    if (value is DateTime) {
      props[key] = value.toIso8601String();
    } else if (value is String) {
      try {
        DateTime.parse(value);
      } catch (_) {
        props.remove(key);
      }
    }
  }

  /// Parse a string property into a double, or remove it.
  void _convertDouble(Map<String, dynamic> props, String key) {
    final value = props[key];

    if (value is String) {
      try {
        props[key] = double.parse(value);
      } catch (_) {
        props.remove(key);
      }
    }
  }

  /// Split a space-separated string into a list of non-empty strings.
  void _convertStringList(Map<String, dynamic> props, String key) {
    final value = props[key];

    if (value is String) {
      props[key] = value.split(' ').where((s) => s.isNotEmpty).toList();
    }
  }

  /// Ensure a missing or null priority defaults to 'none'.
  void _ensureDefaultPriority(Map<String, dynamic> props) {
    if (!props.containsKey('priority') || props['priority'] == null) {
      props['priority'] = 'none';
    }
  }

  /// Merge special UDA properties into the UDA map so they are preserved
  /// when round-tripped through the Rust layer.
  void _mergeUdaProperties(
    Map<String, dynamic> knownProps,
    Map<String, String> udas,
  ) {
    void putIfString(String key) {
      final value = knownProps[key];
      if (value is String) {
        udas[key] = value;
      }
    }

    void putIfDateTime(String key) {
      final value = knownProps[key];
      if (value is DateTime) {
        udas[key] = value.toIso8601String();
      } else if (value is String) {
        udas[key] = value;
      }
    }

    void putIfAny(String key) {
      final value = knownProps[key];
      if (value != null) {
        udas[key] = value.toString();
      }
    }

    putIfString('project');
    putIfDateTime('scheduled');
    putIfDateTime('until');
    putIfString('parent');
    putIfAny('urgency');
  }
}

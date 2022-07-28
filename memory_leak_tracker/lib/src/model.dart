// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:collection/collection.dart';

typedef ObjectDetailsProvider = String? Function(Object object);

const int cyclesToDeclareLeakIfNotGCed = 2;

const Duration delayToDeclareLeakIfNotGCed = Duration(seconds: 1);

enum LeakType {
  notDisposed,
  notGCed,
  gcedLate,
}

LeakType _parseLeakType(String source) =>
    LeakType.values.firstWhere((e) => e.toString() == source);

/// Statistical information about found leaks.
class LeakSummary {
  LeakSummary(this.totals);

  factory LeakSummary.fromJson(Map<String, dynamic> json) => LeakSummary(
        json.map(
          (key, value) => MapEntry(_parseLeakType(key), int.parse(value)),
        ),
      );

  final Map<LeakType, int> totals;

  bool get isEmpty => totals.values.sum == 0;

  String toMessage() {
    return '${totals.values.sum} memory leak(s): '
        'not disposed: ${totals[LeakType.notDisposed]}, '
        'not GCed: ${totals[LeakType.notGCed]}, '
        'GCed late: ${totals[LeakType.gcedLate]}';
  }

  bool equals(LeakSummary? other) {
    if (other == null) return false;
    return const MapEquality().equals(totals, other.totals);
  }

  Map<String, dynamic> toJson() =>
      totals.map((key, value) => MapEntry(key.toString(), value.toString()));
}

/// Detailed information about found leaks.
class Leaks {
  Leaks(this.byType);

  factory Leaks.fromJson(Map<String, dynamic> json) => Leaks(
        json.map(
          (key, value) => MapEntry(
            _parseLeakType(key),
            (value as List)
                .cast<Map<String, dynamic>>()
                .map((e) => LeakReport.fromJson(e))
                .toList(growable: false),
          ),
        ),
      );
  final Map<LeakType, List<LeakReport>> byType;

  List<LeakReport> get notGCed => byType[LeakType.notGCed] ?? [];
  List<LeakReport> get notDisposed => byType[LeakType.notDisposed] ?? [];
  List<LeakReport> get gcedLate => byType[LeakType.gcedLate] ?? [];

  Map<String, dynamic> toJson() => byType.map(
        (key, value) =>
            MapEntry(key.toString(), value.map((e) => e.toJson()).toList()),
      );
}

/// Names for json fields.
class _JsonFields {
  static const String type = 'type';
  static const String details = 'details';
  static const String code = 'code';
}

/// Leak information, passed from application to DevTools and than extended by
/// DevTools after deeper analysis.
class LeakReport {
  LeakReport({
    required this.type,
    required this.details,
    required this.code,
  });

  factory LeakReport.fromJson(Map<String, dynamic> json) => LeakReport(
        type: json[_JsonFields.type],
        details:
            (json[_JsonFields.details] as List<dynamic>? ?? []).cast<String>(),
        code: json[_JsonFields.code],
      );

  final String type;
  final List<String> details;
  final int code;

  // The fields below do not need serialization as they are populated after.
  String? retainingPath;
  List<String>? detailedPath;

  Map<String, dynamic> toJson() => {
        _JsonFields.type: type,
        _JsonFields.details: details,
        _JsonFields.code: code,
      };

  static String iterableToYaml(
    String title,
    Iterable<LeakReport>? leaks, {
    String indent = '',
  }) {
    if (leaks == null || leaks.isEmpty) return '';

    return '''$title:
$indent  total: ${leaks.length}
$indent  objects:
${leaks.map((e) => e.toYaml('$indent    ')).join()}
''';
  }

  String toYaml(String indent) {
    final result = StringBuffer();
    result.writeln('$indent$type:');
    result.writeln('$indent  identityHashCode: $code');
    if (details.isNotEmpty) {
      result.writeln('$indent  details: $details');
    }

    if (detailedPath != null) {
      result.writeln('$indent  retainingPath:');
      result.writeln(detailedPath!.map((s) => '$indent    - $s').join('\n'));
    } else if (retainingPath != null) {
      result.writeln('$indent  retainingPath: $retainingPath');
    }
    return result.toString();
  }

  static String _indentNewLines(String text, String indent) {
    return text.replaceAll('\n', '\n$indent').trimRight();
  }
}

/// Information about an object that is should be tracked for leaks.
class TrackedObjectInfo {
  TrackedObjectInfo(
    Object object,
    this.details,
  )   : type = object.runtimeType,
        code = identityHashCode(object);

  final Type type;
  final List<String> details;
  final int code;

  DateTime? _disposedTime;
  int? _disposedGcTime;

  void setDisposed(int gcTime) {
    if (_disposedGcTime != null) throw 'The object $code was disposed twice.';
    if (_gcedGcTime != null)
      throw 'The object $code should not be disposed after being GCed.';
    _disposedGcTime = gcTime;
    _disposedTime = DateTime.now();
  }

  DateTime? _gcedTime;
  int? _gcedGcTime;
  void setGCed(int gcTime) {
    if (_gcedGcTime != null) throw 'The object $code GCed twice.';
    _gcedGcTime = gcTime;
    _gcedTime = DateTime.now();
  }

  bool get isGCed => _gcedGcTime != null;
  bool get isDisposed => _disposedGcTime != null;

  bool get isGCedLateLeak {
    if (_disposedGcTime == null || _gcedGcTime == null) return false;
    assert(_gcedTime != null);
    return _shouldDeclareGCLeak(
        _disposedGcTime, _disposedTime, _gcedGcTime!, _gcedTime!);
  }

  bool isNotGCedLeak(int gcTime) {
    if (_gcedGcTime != null) return false;
    return _shouldDeclareGCLeak(
        _disposedGcTime, _disposedTime, gcTime, DateTime.now());
  }

  static bool _shouldDeclareGCLeak(
    int? disposedGcTime,
    DateTime? disposedTime,
    int gcedGcTime,
    DateTime gcedTime,
  ) {
    assert((disposedGcTime == null) == (disposedTime == null));
    if (disposedGcTime == null || disposedTime == null) return false;

    return gcedGcTime - disposedGcTime >= cyclesToDeclareLeakIfNotGCed &&
        gcedTime.difference(disposedTime) >= delayToDeclareLeakIfNotGCed;
  }

  bool get isNotDisposedLeak {
    return isGCed && !isDisposed;
  }

  LeakReport toLeakReport() => LeakReport(
        type: type.toString(),
        details: details,
        code: code,
      );
}

typedef LeakListener = void Function(LeakSummary);

class LeakTrackingConfiguration {
  /// Period to check for leaks.
  ///
  /// If null, there is no periodic checking.
  final Duration? checkPeriod;

  /// Set of object families, enabled for tracking.
  ///
  /// If an object does not belong to any family, it is always tracked.
  /// Otherwise it is tracked if its family belongs to this set.
  final Set<Object> enabledFamilies;

  /// We use String, because some types are private and thus not accessible.
  final Set<String> typesToCollectStackTraceOnTrackingStart;

  /// If true, the tool will output the leaks to console.
  ///
  /// TODO: add option for logger and stderr.
  final bool stdoutLeaks;

  final LeakListener? leakListener;

  LeakTrackingConfiguration({
    this.leakListener,
    this.stdoutLeaks = true,
    this.checkPeriod = const Duration(seconds: 1),
    this.enabledFamilies = const {},
    this.typesToCollectStackTraceOnTrackingStart = const {},
  });
}

import 'package:memory_tools/model.dart';
import 'package:memory_tools/src/_gc_time.dart';

import 'package:collection/collection.dart';

typedef GCDuration = int;
typedef GCMoment = int;

// Theoretically it should be 2, but practically 2 gives false positives.
const GCDuration cyclesToDeclareLeakIfNotGCed = 3;
const Duration timeToDeclareLeakIfNotGCed = Duration(seconds: 1);

enum LeakType {
  notDisposed,
  notGCed,
  gcedLate,
}

_parseLeakType(String source) =>
    LeakType.values.firstWhere((e) => e.toString() == source);

class LeakSummary {
  final Map<LeakType, int> totals;

  LeakSummary(this.totals);

  bool get isEmpty => totals.values.sum == 0;

  String toMessage() {
    return 'Not disposed: ${totals[LeakType.notDisposed]}, '
        'not GCed: ${totals[LeakType.notGCed]}, '
        'GCed late: ${totals[LeakType.gcedLate]}, '
        'total: ${totals.values.sum}.';
  }

  bool equals(LeakSummary? other) {
    if (other == null) return false;
    return MapEquality().equals(this.totals, other.totals);
  }

  factory LeakSummary.fromJson(Map<String, dynamic> json) => LeakSummary(json
      .map((key, value) => MapEntry(_parseLeakType(key), int.parse(value))));

  Map<String, dynamic> toJson() =>
      totals.map((key, value) => MapEntry(key.toString(), value.toString()));
}

class Leaks {
  final Map<LeakType, List<ObjectReport>> leaks;

  Leaks(this.leaks);

  factory Leaks.fromJson(Map<String, dynamic> json) =>
      Leaks(json.map((key, value) => MapEntry(
          _parseLeakType(key),
          (value as List)
              .cast<Map<String, dynamic>>()
              .map((e) => ObjectReport.fromJson(e))
              .toList(growable: false))));

  Map<String, dynamic> toJson() => leaks.map(
        (key, value) =>
            MapEntry(key.toString(), value.map((e) => e.toJson()).toList()),
      );
}

class ObjectReport {
  final String token;
  final String type;
  final String creationLocation;
  final int theIdentityHashCode;
  String? retainingPath;

  ObjectReport({
    required this.token,
    required this.type,
    required this.creationLocation,
    required this.theIdentityHashCode,
    this.retainingPath,
  });

  factory ObjectReport.fromJson(Map<String, dynamic> json) => ObjectReport(
        token: json['token'],
        type: json['type'],
        creationLocation: json['creationLocation'],
        theIdentityHashCode: json['theIdentityHashCode'],
        retainingPath: json['retainingPath'],
      );

  Map<String, dynamic> toJson() => {
        'token': token,
        'type': type,
        'creationLocation': creationLocation,
        'theIdentityHashCode': theIdentityHashCode,
        'retainingPath': retainingPath,
      };

  static String iterableToYaml(
    String title,
    Iterable<ObjectReport>? leaks, {
    String indent = '',
  }) {
    if (leaks == null || leaks.length == 0) return '';

    return '''$title:
$indent  total: ${leaks.length}
$indent  objects:
${leaks.map((e) => e.toYaml('$indent    ')).join()}
''';
  }

  String toYaml(String indent) {
    return '''$indent${type}:
$indent  token: ${token}
$indent  type: ${type}
$indent  creationLocation: ${creationLocation}
$indent  identityHashCode: ${theIdentityHashCode}
$indent  retainingPath: ${retainingPath}
''';
  }
}

class ObjectInfo {
  final Object token;
  final Type type;
  final String creationLocation;
  final int theIdentityHashCode;
  final WeakReference weakReference;

  DateTime? _disposedTime;
  GCMoment? _disposed;
  void setDisposed(GCMoment value) {
    if (_disposed != null) throw 'The object $token disposed twice.';
    if (_gced != null)
      throw 'The object $token should not be disposed after being GCed.';
    _disposed = value;
    _disposedTime = DateTime.now();
  }

  DateTime? _gcedTime;
  GCMoment? _gced;
  void setGCed(GCMoment value) {
    if (_gced != null) throw 'The object $token GCed twice.';
    _gced = value;
    _gcedTime = DateTime.now();
  }

  bool get isGCed => _gced != null;
  bool get isDisposed => _disposed != null;

  bool get isGCedLateLeak {
    if (_disposed == null || _gced == null) return false;
    assert(_gcedTime != null);
    return _shouldDeclareGCLeak(_disposed, _disposedTime, _gced!, _gcedTime!);
  }

  bool isNotGCedLeak(GCMoment now) {
    if (_gced != null) return false;
    return _shouldDeclareGCLeak(_disposed, _disposedTime, now, DateTime.now());
  }

  static bool _shouldDeclareGCLeak(
    GCMoment? disposed,
    DateTime? disposedTime,
    GCMoment gced,
    DateTime gcedTime,
  ) {
    assert((disposed == null) == (disposedTime == null));
    if (disposed == null || disposedTime == null) return false;

    return gced - disposed >= cyclesToDeclareLeakIfNotGCed &&
        gcedTime.difference(disposedTime) >= timeToDeclareLeakIfNotGCed;
  }

  bool get isNotDisposedLeak {
    return isGCed && !isDisposed;
  }

  ObjectInfo(
    this.token,
    this.creationLocation,
    Object object,
  )   : this.type = object.runtimeType,
        this.theIdentityHashCode = identityHashCode(object),
        this.weakReference = WeakReference(object);

  ObjectReport toObjectReport() => ObjectReport(
      token: token.toString(),
      type: type.toString(),
      creationLocation: creationLocation,
      theIdentityHashCode: theIdentityHashCode);
}

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
  final Map<LeakType, List<ObjectReport>> byType;

  Leaks(this.byType);

  List<ObjectReport> get notGCed => byType[LeakType.notGCed] ?? [];
  List<ObjectReport> get notDisposed => byType[LeakType.notDisposed] ?? [];
  List<ObjectReport> get gcedLate => byType[LeakType.gcedLate] ?? [];

  factory Leaks.fromJson(Map<String, dynamic> json) =>
      Leaks(json.map((key, value) => MapEntry(
          _parseLeakType(key),
          (value as List)
              .cast<Map<String, dynamic>>()
              .map((e) => ObjectReport.fromJson(e))
              .toList(growable: false))));

  Map<String, dynamic> toJson() => byType.map(
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
  List<String>? detailedPath;
  Map<String, dynamic>? retainers;

  ObjectReport({
    required this.token,
    required this.type,
    required this.creationLocation,
    required this.theIdentityHashCode,
    this.retainingPath,
    this.retainers,
  });

  factory ObjectReport.fromJson(Map<String, dynamic> json) => ObjectReport(
        token: json['token'],
        type: json['type'],
        creationLocation: json['creationLocation'],
        theIdentityHashCode: json['theIdentityHashCode'],
        retainingPath: json['retainingPath'],
        retainers: json['retainers'],
      );

  Map<String, dynamic> toJson() => {
        'token': token,
        'type': type,
        'creationLocation': creationLocation,
        'theIdentityHashCode': theIdentityHashCode,
        'retainingPath': retainingPath,
        'retainers': retainers,
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
    final result = StringBuffer();
    result.writeln('$indent${type}:');
    result.writeln('$indent  token: ${token}');
    result.writeln('$indent  type: ${type}');
    result.writeln('$indent  creationLocation: ${creationLocation}');
    result.writeln('$indent  identityHashCode: ${theIdentityHashCode}');

    if (detailedPath != null) {
      result.writeln('$indent  retainingPath:');
      result.writeln(detailedPath!.map((s) => '$indent    - $s').join('\n'));
    } else if (retainingPath != null) {
      result.writeln('$indent  retainingPath: ${retainingPath}');
    } else if (retainers?.isNotEmpty ?? false) {
      String retainersYaml = _retainersToYaml(retainers, '$indent    ');
      result.writeln('$indent  retainers: $retainersYaml');
    }
    return result.toString();
  }

  static String _retainersToYaml(
      Map<String, dynamic>? theRetainers, String indent) {
    if (theRetainers == null || theRetainers.isEmpty) return ' null';
    return theRetainers.keys
        .map((e) =>
            '\n$indent$e:${_retainersToYaml(theRetainers[e], '$indent  ')}')
        .join();
  }
}

class ObjectInfo {
  final Object token;
  final Type type;
  final String creationLocation;
  final int theIdentityHashCode;

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
        this.theIdentityHashCode = identityHashCode(object);

  ObjectReport toObjectReport() => ObjectReport(
      token: token.toString(),
      type: type.toString(),
      creationLocation: creationLocation,
      theIdentityHashCode: theIdentityHashCode);
}

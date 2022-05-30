import 'package:memory_tools/src/_gc_time.dart';

import 'package:collection/collection.dart';

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
  final List<ObjectInfo> notGCed;
  final List<ObjectInfo> notDisposed;
  final List<ObjectInfo> gcedLate;

  Leaks({
    required this.notDisposed,
    required this.notGCed,
    required this.gcedLate,
  });

  bool get isEmpty =>
      notGCed.isEmpty && notDisposed.isEmpty && gcedLate.isEmpty;

  bool sameSize(Leaks? previous) {
    if (previous == null) return false;
    return previous.gcedLate.length == gcedLate.length &&
        previous.notGCed.length == notGCed.length &&
        previous.notDisposed.length == notDisposed.length;
  }
}

class ObjectInfo {
  final Object token;
  final Type type;
  final String creationLocation;
  final int theIdentityHashCode;
  final WeakReference weakReference;

  GCMoment? _disposed;
  GCMoment? get disposed => _disposed;
  void setDisposed(GCMoment value) {
    if (_disposed != null) throw 'The object $token disposed twice.';
    if (_gced != null)
      throw 'The object $token should not be disposed after being GCed.';
    _disposed = value;
  }

  GCMoment? _gced;
  GCMoment? get gced => _gced;
  void setGCed(GCMoment value) {
    if (_gced != null) throw 'The object $token GCed twice.';
    _gced = value;
  }

  bool get isGCed => _gced != null;
  bool get isDisposed => _disposed != null;

  bool get isGCedLateLeak {
    if (_disposed == null || _gced == null) return false;
    return _gced! - _disposed! >= cyclesToDeclareLeakIfNotGCed;
  }

  bool isNotGCedLeak(GCMoment now) {
    if (_disposed == null) return false;
    if (_gced != null) return false;
    return now - _disposed! >= cyclesToDeclareLeakIfNotGCed;
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
}

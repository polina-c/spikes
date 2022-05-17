import '_globals.dart';

class Leaks {
  final List<ObjectInfo> notGCed;
  final List<ObjectInfo> notDisposed;
  final List<ObjectInfo> gcedLate;

  Leaks(this.notGCed, this.notDisposed, this.gcedLate);

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

  final DateTime registration;

  final String creationLocation;

  Duration? _disposed;
  Duration? get disposed => _disposed;
  void setDisposedNow() {
    if (_disposed != null) throw 'The object $token disposed twice.';
    if (_gced != null)
      throw 'The object $token should not be disposed after being GCed.';
    _disposed = DateTime.now().difference(registration);
  }

  Duration? _gced;
  Duration? get gced => _gced;
  void setGCedNow() {
    if (_gced != null) throw 'The object $token GCed twice.';
    _gced = DateTime.now().difference(registration);
  }

  bool get isGCed => _gced != null;
  bool get isDisposed => _disposed != null;

  bool get isGCedLateLeak {
    if (_disposed == null || _gced == null) return false;
    return (_gced! - _disposed!).compareTo(timeToGC) > 0;
  }

  bool get isNotGCedLeak {
    if (_disposed == null) return false;
    if (_gced != null) return false;
    final timeSinceDisposal =
        DateTime.now().difference(registration) - _disposed!;
    return timeSinceDisposal.compareTo(timeToGC) > 0;
  }

  bool get isNotDisposedLeak {
    return isGCed && !isDisposed;
  }

  ObjectInfo(
    this.token,
    this.registration,
    this.creationLocation,
  );
}

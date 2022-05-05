class Leaks {
  final List<ObjectInfo> notGCed;
  final List<ObjectInfo> notDisposed;
  final List<Object> falsePositives;

  Leaks(this.notGCed, this.notDisposed, this.falsePositives);

  bool get isEmpty =>
      notGCed.isEmpty && notDisposed.isEmpty && falsePositives.isEmpty;
}

class ObjectInfo {
  final Object token;

  final DateTime registrationTime;

  final String creationLocation;

  final String registrationCallStack;

  String? disposalCallStack;

  Duration? _disposedAfter;
  Duration? get disposedAfter => _disposedAfter;
  void setDisposedNow() {
    if (_disposedAfter != null) throw 'The object $token disposed twice.';
    if (_gcedAfter != null)
      throw 'The object $token should not be disposed after being GCed.';
    _disposedAfter = DateTime.now().difference(registrationTime);
  }

  Duration? _gcedAfter;
  Duration? get gcedAfter => _gcedAfter;
  void setGCedNow() {
    if (_gcedAfter != null) throw 'The object $token GCed twice.';
    _gcedAfter = DateTime.now().difference(registrationTime);
  }

  bool get isGCed => _gcedAfter != null;
  bool get isDisposed => _disposedAfter != null;

  ObjectInfo(
    this.token,
    this.registrationTime,
    this.creationLocation,
    this.registrationCallStack,
  );
}

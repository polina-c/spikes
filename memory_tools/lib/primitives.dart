class NotDisposedLeak {
  final Object token;
  NotDisposedLeak(this.token);
}

class NotGCedLeak {
  final Object token;
  NotGCedLeak(this.token);
}

class Leaks {
  final List<NotGCedLeak> notGCed;
  final List<NotDisposedLeak> notDisposed;

  Leaks(this.notGCed, this.notDisposed);

  bool get isEmpty {
    return notGCed.isEmpty && notDisposed.isEmpty;
  }
}

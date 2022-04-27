class NotDisposedLeak {
  final Object token;
  NotDisposedLeak(this.token);
}

class NotGCedLeak {
  final Object token;
  NotGCedLeak(this.token);
}

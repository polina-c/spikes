import 'package:indent/indent.dart';

class Leak {
  final Object token;
  final ObjectInfo info;
  Leak(this.token, this.info);
}

class Leaks {
  final List<Leak> notGCed;
  final List<Leak> notDisposed;

  Leaks(this.notGCed, this.notDisposed);

  bool get isEmpty => notGCed.isEmpty && notDisposed.isEmpty;
}

class ObjectInfo {
  final DateTime registrationTime;
  final String creationLocation;
  final String registrationCallStack;

  String? disposalCallStack;
  Duration? disposedAfter;
  Duration? gcedAfter;

  ObjectInfo(
      this.registrationTime, this.creationLocation, this.registrationCallStack);
}

void heavyCompute(Duration duration) {
  final startTime = DateTime.now();
  while (DateTime.now().difference(startTime).compareTo(duration) > 0) {}
}

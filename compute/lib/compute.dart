void heavyCompute(Duration duration) {
  final startTime = DateTime.now();
  print('starttime: $startTime');
  while (true) {
    final now = DateTime.now();
    // print('now: $now');
    final compare = now.difference(startTime).compareTo(duration);
    // print('compare: $compare');
    if (compare > 0) {
      print('exiting');
      return;
    }
  }
}

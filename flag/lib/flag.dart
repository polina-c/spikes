const bool _kFlag = bool.fromEnvironment('my.flag');

/// To enable flag
/// `--dart-define=flutter.memory_allocations=true`.
int calculate() {
  print('$_kFlag');
  return 6 * 7;
}

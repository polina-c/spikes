enum EventType {
  created,
  disposed,
  passed,
}

class Event {
  final EventType eventType;
  final String description;
  late final StackTrace stackTrace;

  Event(this.eventType, [this.description = '']) {
    this.stackTrace = StackTrace.current;
  }
}

class LeakDetector {
  LeakDetector(Object object, [String objectToken = '']) {
    _events.add(Event(EventType.created));
  }

  final _events = <Event>[];

  void registerPass(String description) {
    _events.add(Event(EventType.passed, description));
  }

  void registerDisposal() {
    _events.add(Event(EventType.disposed));
  }
}

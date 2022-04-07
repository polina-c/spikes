import 'package:uuid/uuid.dart';

var uuid = Uuid();

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
  late Object _token;
  final _events = <Event>[];

  LeakDetector(Object object, [Object? token]) {
    _events.add(Event(EventType.created));
    _token = token ?? uuid.v1();
  }

  void registerPass(String description) {
    _events.add(Event(EventType.passed, description));
  }

  void registerDisposal() {
    _events.add(Event(EventType.disposed));
  }
}

abstract class LeakTrackingEvent {
  // ...
}

class RegisterObjectForLeakTracking extends LeakTrackingEvent {
  // ...
}

class RegisterObjectDetails extends LeakTrackingEvent {
  // ...
}

class RegisterObjectDisposal extends LeakTrackingEvent {
  // ...
}

typedef LeakTrackingEventListener = void Function(LeakTrackingEvent);

void registerLeakTrackingEvent(LeakTrackingEvent event) {
  // ...
}

void addLeakTrackingEventListener(LeakTrackingEventListener listener) {
  // ...
}

void removeLeakTrackingEventListener(LeakTrackingEventListener listener) {
  // ...
}

// class LeakTrackingEvent {
//   /// Type of the event.
//   final LeakTrackingEventType eventType;
//
//   /// Object that is tracked for leaks.
//   ///
//   /// Should not be null for the type [LeakTrackingEventType.startTracking]
//   /// and if a token is not provided.
//   final Object? object;
//
//   /// Token to identify the object.
//   ///
//   /// If not specified, [identityHashCode] will be used, with very small risk to
//   /// get duplicates and thus get the tracking dropped for the duplicated
//   /// objects.
//   final Object? token;
//
//   /// Details to help with troubleshooting.
//   final List<Object>? details;
//
//   LeakTrackingEvent({
//     required this.eventType,
//     required this.object,
//     this.token,
//     this.details,
//   });
// }

abstract class LeakTrackedObjectEvent {}

class RegisterObjectForLeakTracking extends LeakTrackedObjectEvent {}

class RegisterObjectDetails extends LeakTrackedObjectEvent {}

class RegisterObjectDisposal extends LeakTrackedObjectEvent {}

typedef LeakTrackedObjectEventListener = void Function(LeakTrackedObjectEvent);

void registerLeakTrackedObjectEvent(LeakTrackedObjectEvent event) {}

void addLeakTrackedObjectEventListener(
    LeakTrackedObjectEventListener listener) {}

void removeLeakTrackedObjectEventListener(
    LeakTrackedObjectEventListener listener) {}

const String memoryLeakTrackingExtension = 'ext.dart.memoryLeakTracking';

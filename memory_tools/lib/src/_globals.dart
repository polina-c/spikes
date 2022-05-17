import 'package:logging/logging.dart';

bool leakTrackingEnabled = false;
final logger = Logger('leak-detector');
Duration timeToGC = Duration(seconds: 30);
late String Function(Object object) objectLocationGetter;

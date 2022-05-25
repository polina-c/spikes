import 'package:logging/logging.dart';

bool leakTrackingEnabled = false;
final logger = Logger('leak-detector');
late String Function(Object object) objectLocationGetter;

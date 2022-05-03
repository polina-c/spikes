import 'package:logging/logging.dart';

final logger = Logger('leak-detector');

Duration timeToGC = Duration(seconds: 5);
bool detailedOutput = false;

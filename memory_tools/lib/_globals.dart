import 'package:logging/logging.dart';

final logger = Logger('leak-detector');
Duration timeToGC = Duration(seconds: 30);
String reportFileName = 'detected_leaks.yaml';

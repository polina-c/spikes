import 'package:intl/intl.dart';

final DateFormat _formatter = DateFormat.Hms();
void printWithTime(String text) {
  print('${_formatter.format(DateTime.now())} $text');
}

String justTime(DateTime date) {
  return '${_formatter.format(date)}';
}

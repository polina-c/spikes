import 'package:flutter/material.dart';

Widget __dynMain(Map<String, dynamic>? data) {
  Object? convertedData = convertDynamic(data);

  if (convertedData is! List<Map<String, Object?>>?) {
    return const Center(child: Text('No calendar events.'));
  }

  List<Map<String, Object?>> events = convertedData ?? [];

  if (events.isEmpty) {
    return const Center(child: Text('No calendar events.'));
  }

  return AnimatedDataList(
    items: events,
    keyForItem: (item) => item['start_time'] as String? ?? 'default_key',
    itemBuilder: (context, item) {
      String title = item['title'] as String? ?? 'No Title';
      String startTime = item['start_time'] as String? ?? 'No Start Time';
      String endTime = item['end_time'] as String? ?? 'No End Time';

      return AnimatedListTile(
        title: Text(title),
        subtitle: Text('$startTime - $endTime'),
        onTap: () {
          // You could add logic here to navigate to a detailed view of the event.
          // For example: Navigator.push(...);
        },
      );
    },
  );
}

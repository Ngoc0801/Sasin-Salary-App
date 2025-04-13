import 'package:flutter/material.dart';
import '../models/time_entry.dart';

class SalaryDetailDialog extends StatelessWidget {
  final DateTime selectedDay;
  final List<TimeEntry> entries;

  const SalaryDetailDialog({
    required this.selectedDay,
    required this.entries,
  });

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return AlertDialog(
        title: Text('No Work on ${selectedDay.day}/${selectedDay.month}/${selectedDay.year}'),
        content: Text('You did not work on this day.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
        ],
      );
    }

    return AlertDialog(
      title: Text('Work Details on ${selectedDay.day}/${selectedDay.month}/${selectedDay.year}'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: entries.map((entry) {
            final hours = entry.checkOut.difference(entry.checkIn).inMinutes / 60.0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Check-In: ${entry.checkIn.hour}:${entry.checkIn.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    'Check-Out: ${entry.checkOut.hour}:${entry.checkOut.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    'Working Hours: ${hours.toStringAsFixed(1)} hours',
                    style: TextStyle(fontSize: 16),
                  ),
                  Divider(),
                ],
              ),
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Close'),
        ),
      ],
    );
  }
}
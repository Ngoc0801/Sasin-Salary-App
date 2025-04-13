import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../viewmodels/calendar_viewmodel.dart';
import '../viewmodels/time_entry_viewmodel.dart';
import '../models/time_entry.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime? _selectedDay;
  List<TimeEntry> _selectedEntries = [];

  @override
  Widget build(BuildContext context) {
    final calendarViewModel = Provider.of<CalendarViewModel>(context);
    final workedDays = calendarViewModel.getWorkedDays();

    return Scaffold(
      appBar: null,
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime(2020),
            lastDay: DateTime(2030),
            focusedDay: calendarViewModel.selectedMonth,
            calendarFormat: CalendarFormat.month,
            onPageChanged: (focusedDay) {
              calendarViewModel.setSelectedMonth(focusedDay);
            },
            selectedDayPredicate: (day) {
              return _selectedDay != null &&
                  day.year == _selectedDay!.year &&
                  day.month == _selectedDay!.month &&
                  day.day == _selectedDay!.day;
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _selectedEntries = calendarViewModel.timeEntryViewModel.timeEntries
                    .where((entry) =>
                        entry.date.year == selectedDay.year &&
                        entry.date.month == selectedDay.month &&
                        entry.date.day == selectedDay.day)
                    .toList();
              });
            },
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                if (workedDays.any((d) =>
                    d.year == date.year && d.month == date.month && d.day == date.day)) {
                  return Positioned(
                    right: 1,
                    bottom: 1,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _selectedDay == null
                ? const Center(child: Text('Chọn một ngày để xem chi tiết'))
                : _selectedEntries.isEmpty
                    ? Center(
                        child: Text(
                          'Không làm việc vào ngày ${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}',
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _selectedEntries.length,
                        itemBuilder: (context, index) {
                          final entry = _selectedEntries[index];
                          final hours = entry.checkOut.difference(entry.checkIn).inMinutes / 60.0;
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Ca ${index + 1}',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Check-In: ${entry.checkIn.hour}:${entry.checkIn.minute.toString().padLeft(2, '0')}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  Text(
                                    'Check-Out: ${entry.checkOut.hour}:${entry.checkOut.minute.toString().padLeft(2, '0')}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  Text(
                                    'Số Giờ Làm Việc: ${hours.toStringAsFixed(1)} giờ',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
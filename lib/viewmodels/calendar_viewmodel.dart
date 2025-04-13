import 'package:flutter/material.dart';
import 'time_entry_viewmodel.dart'; // Thêm import này
import '../models/time_entry.dart';

class CalendarViewModel extends ChangeNotifier {
  final TimeEntryViewModel timeEntryViewModel;
  DateTime _selectedMonth = DateTime.now();

  CalendarViewModel(this.timeEntryViewModel);

  DateTime get selectedMonth => _selectedMonth;

  List<DateTime> getWorkedDays() {
    return timeEntryViewModel.timeEntries.map((entry) => entry.date).toList();
  }

  void setSelectedMonth(DateTime month) {
    _selectedMonth = month;
    notifyListeners();
  }
}
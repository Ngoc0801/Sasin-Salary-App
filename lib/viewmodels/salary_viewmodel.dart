import 'package:flutter/material.dart';
import 'time_entry_viewmodel.dart';
import '../models/time_entry.dart';
import '../utils/number_formatter.dart';

enum Position { kitchen, waiter, custom } // Thêm Position.custom

class SalaryViewModel extends ChangeNotifier {
  final TimeEntryViewModel timeEntryViewModel;
  Position _selectedPosition = Position.kitchen;
  DateTime _selectedMonth = DateTime.now();
  double? _customSalary; // Thêm thuộc tính mới để lưu mức lương tùy chỉnh

  SalaryViewModel(this.timeEntryViewModel);

  Position get selectedPosition => _selectedPosition;
  DateTime get selectedMonth => _selectedMonth;
  double? get customSalary => _customSalary;

  void setPosition(Position position) {
    _selectedPosition = position;
    notifyListeners();
  }

  void setSelectedMonth(DateTime month) {
    _selectedMonth = DateTime(month.year, month.month, 1);
    notifyListeners();
  }

  void setCustomSalary(double? salary) {
    _customSalary = salary;
    notifyListeners();
  }

  // Lấy khoảng thời gian từ ngày 1 của tháng hiện tại đến ngày cuối của tháng
  DateTime _getStartDate() {
    return DateTime(_selectedMonth.year, _selectedMonth.month, 1);
  }

  DateTime _getEndDate() {
    return DateTime(_selectedMonth.year, _selectedMonth.month + 1, 1)
        .subtract(const Duration(days: 1));
  }

  List<TimeEntry> _getEntriesForMonth() {
    final startDate = _getStartDate();
    final endDate = _getEndDate();
    return timeEntryViewModel.timeEntries.where((entry) {
      return !entry.date.isBefore(startDate) && !entry.date.isAfter(endDate);
    }).toList();
  }

  double calculateTotalSalary() {
    double totalSalary = 0;
    for (var entry in _getEntriesForMonth()) {
      totalSalary += _calculateEntrySalary(entry);
    }
    return totalSalary;
  }

  String getFormattedTotalSalary([double? customValue]) {
    return formatNumber(customValue ?? calculateTotalSalary());
  }

  double getTotalHours() {
    double totalHours = 0;
    for (var entry in _getEntriesForMonth()) {
      totalHours += _calculateHours(entry);
    }
    return totalHours;
  }

  String getFormattedTotalHours() {
    return formatNumber(getTotalHours());
  }

  int getTotalDays() {
    final uniqueDays = _getEntriesForMonth()
        .map((entry) => DateTime(entry.date.year, entry.date.month, entry.date.day))
        .toSet();
    return uniqueDays.length;
  }

  double _calculateHours(TimeEntry entry) {
    return entry.checkOut.difference(entry.checkIn).inMinutes / 60.0;
  }

  String getFormattedHours(TimeEntry entry) {
    return formatNumber(_calculateHours(entry));
  }

  String formatValue(double value) {
    return formatNumber(value);
  }

  double _calculateEntrySalary(TimeEntry entry) {
    double salaryForEntry = 0;
    double baseHourlyRate;

    // Sử dụng customSalary nếu Position là custom và customSalary có giá trị
    if (_selectedPosition == Position.custom && _customSalary != null) {
      baseHourlyRate = _customSalary!;
    } else {
      baseHourlyRate = _selectedPosition == Position.kitchen ? 27000 : 25000;
    }

    DateTime current = entry.checkIn;
    while (current.isBefore(entry.checkOut)) {
      DateTime nextHour = DateTime(
        current.year,
        current.month,
        current.day,
        current.hour + 1,
      );
      if (nextHour.isAfter(entry.checkOut)) {
        nextHour = entry.checkOut;
      }

      double hourFraction = nextHour.difference(current).inMinutes / 60.0;
      double hourlyRate = baseHourlyRate;
      if (current.hour >= 22 && current.hour < 23) {
        hourlyRate *= 1.3;
      }
      if (entry.isHoliday) {
        hourlyRate *= 3;
      }
      salaryForEntry += hourlyRate * hourFraction;
      current = nextHour;
    }

    return salaryForEntry;
  }

  List<Map<String, dynamic>> getSalaryDetails() {
    List<Map<String, dynamic>> details = [];
    for (var entry in _getEntriesForMonth()) {
      double hours = _calculateHours(entry);
      double baseHourlyRate;

      // Sử dụng customSalary nếu Position là custom và customSalary có giá trị
      if (_selectedPosition == Position.custom && _customSalary != null) {
        baseHourlyRate = _customSalary!;
      } else {
        baseHourlyRate = _selectedPosition == Position.kitchen ? 27000 : 25000;
      }

      double baseSalary = hours * baseHourlyRate;
      double overtimeSalary = 0;
      double holidaySalary = 0;

      DateTime current = entry.checkIn;
      while (current.isBefore(entry.checkOut)) {
        DateTime nextHour = DateTime(
          current.year,
          current.month,
          current.day,
          current.hour + 1,
        );
        if (nextHour.isAfter(entry.checkOut)) {
          nextHour = entry.checkOut;
        }

        double hourFraction = nextHour.difference(current).inMinutes / 60.0;
        double hourlyRate = baseHourlyRate;
        if (current.hour >= 22 && current.hour < 23) {
          overtimeSalary += baseHourlyRate * 0.3 * hourFraction;
        }
        if (entry.isHoliday) {
          holidaySalary += baseHourlyRate * 2 * hourFraction;
        }
        current = nextHour;
      }

      details.add({
        'date': entry.date,
        'hours': hours,
        'baseSalary': baseSalary,
        'overtimeSalary': overtimeSalary,
        'holidaySalary': holidaySalary,
        'totalSalary': _calculateEntrySalary(entry),
      });
    }
    return details;
  }
}
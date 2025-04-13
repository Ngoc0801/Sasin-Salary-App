import 'package:flutter/material.dart';
import '../models/time_entry.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TimeEntryViewModel extends ChangeNotifier {
  List<TimeEntry> _timeEntries = [];

  List<TimeEntry> get timeEntries => _timeEntries;

  TimeEntryViewModel() {
    _loadTimeEntries();
  }

  Future<void> _loadTimeEntries() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? entriesString = prefs.getString('timeEntries');
    if (entriesString != null) {
      List<dynamic> entriesJson = jsonDecode(entriesString);
      _timeEntries = entriesJson.map((json) => TimeEntry.fromMap(json)).toList();
    }
    notifyListeners();
  }

  Future<void> addTimeEntry(DateTime date, DateTime checkIn, DateTime checkOut, {bool isHoliday = false}) async {
    final entry = TimeEntry(
      date: date,
      checkIn: checkIn,
      checkOut: checkOut,
      isHoliday: isHoliday,
    );
    _timeEntries.add(entry);
    await _saveTimeEntries();
    notifyListeners();
  }

  Future<void> deleteTimeEntry(TimeEntry entry) async {
    _timeEntries.removeWhere((e) => 
      e.date == entry.date &&
      e.checkIn == entry.checkIn &&
      e.checkOut == entry.checkOut &&
      e.isHoliday == entry.isHoliday
    );
    await _saveTimeEntries();
    notifyListeners();
  }

  Future<void> _saveTimeEntries() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('timeEntries', jsonEncode(_timeEntries.map((e) => e.toMap()).toList()));
  }
}
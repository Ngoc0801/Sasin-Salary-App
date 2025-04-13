class TimeEntry {
  final DateTime date;
  final DateTime checkIn;
  final DateTime checkOut;
  final bool isHoliday; // Thêm thuộc tính isHoliday

  TimeEntry({
    required this.date,
    required this.checkIn,
    required this.checkOut,
    this.isHoliday = false, // Mặc định là false
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'checkIn': checkIn.toIso8601String(),
      'checkOut': checkOut.toIso8601String(),
      'isHoliday': isHoliday, // Lưu isHoliday
    };
  }

  static TimeEntry fromMap(Map<String, dynamic> map) {
    return TimeEntry(
      date: DateTime.parse(map['date']),
      checkIn: DateTime.parse(map['checkIn']),
      checkOut: DateTime.parse(map['checkOut']),
      isHoliday: map['isHoliday'] ?? false, // Đọc isHoliday
    );
  }
}
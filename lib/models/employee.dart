class Employee {
  String name;
  String email;
  String? profileImagePath;
  String employeeId; // Thêm mã nhân viên
  DateTime? dateOfBirth; // Thêm ngày tháng năm sinh

  String jobType; // 'kitchen' or 'service'

  Employee({
    required this.name,
    required this.email,
    this.profileImagePath,
    this.employeeId = '', // Giá trị mặc định
    this.dateOfBirth, // Giá trị mặc định là null
    this.jobType = 'kitchen', // Mặc định là bếp
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'profileImagePath': profileImagePath,
      'employeeId': employeeId,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'jobType': jobType,
    };
  }

  factory Employee.fromMap(Map<String, dynamic> map) {
    return Employee(
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      profileImagePath: map['profileImagePath'],
      employeeId: map['employeeId'] ?? '',
      dateOfBirth: map['dateOfBirth'] != null ? DateTime.parse(map['dateOfBirth']) : null,
      jobType: map['jobType'] ?? 'kitchen', // Mặc định là bếp nếu không có giá trị
    );
  }
}
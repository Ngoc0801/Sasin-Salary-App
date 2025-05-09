class Employee {
  String name;
  String email;
  String? profileImagePath;
  String employeeId;
  DateTime? dateOfBirth;
  String jobType;
  bool customSalaryEnabled; // Thêm trạng thái bật/tắt tùy chỉnh
  double? customSalary; // Thêm mức lương tùy chỉnh

  Employee({
    required this.name,
    required this.email,
    this.profileImagePath,
    this.employeeId = '',
    this.dateOfBirth,
    this.jobType = 'kitchen',
    this.customSalaryEnabled = false, // Mặc định là tắt
    this.customSalary, // Mặc định là null
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'profileImagePath': profileImagePath,
      'employeeId': employeeId,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'jobType': jobType,
      'customSalaryEnabled': customSalaryEnabled, // Lưu trạng thái
      'customSalary': customSalary, // Lưu mức lương
    };
  }

  factory Employee.fromMap(Map<String, dynamic> map) {
    return Employee(
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      profileImagePath: map['profileImagePath'],
      employeeId: map['employeeId'] ?? '',
      dateOfBirth: map['dateOfBirth'] != null
          ? DateTime.parse(map['dateOfBirth'])
          : null,
      jobType: map['jobType'] ?? 'kitchen',
      customSalaryEnabled: map['customSalaryEnabled'] ?? false, // Mặc định
      customSalary: map['customSalary']?.toDouble(), // Chuyển sang double
    );
  }
}
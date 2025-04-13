import 'package:flutter/material.dart';
import '../models/employee.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

enum ThemeModeOption { dark, white, sasin, custom, red }

class CustomTheme {
  final String name;
  final Color primaryColor;
  final Color accentColor;
  final Color backgroundColor;

  CustomTheme({
    required this.name,
    required this.primaryColor,
    required this.accentColor,
    required this.backgroundColor,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'primaryColor': primaryColor.value,
      'accentColor': accentColor.value,
      'backgroundColor': backgroundColor.value,
    };
  }

  factory CustomTheme.fromMap(Map<String, dynamic> map) {
    return CustomTheme(
      name: map['name'],
      primaryColor: Color(map['primaryColor']),
      accentColor: Color(map['accentColor']),
      backgroundColor: Color(map['backgroundColor']),
    );
  }
}

class SettingsViewModel extends ChangeNotifier {
  Employee _employee = Employee(
    name: 'Nguyễn Phạm Hùng',
    email: 'hungnp1272@ut.edu.vn',
    employeeId: '0224',
    dateOfBirth: DateTime(2004, 1, 1),
  );
  ThemeModeOption _themeMode = ThemeModeOption.sasin;
  final List<CustomTheme> _customThemes = [];
  CustomTheme? _selectedCustomTheme;
  Color _primaryColor = Colors.blue;
  Color _accentColor = Colors.blueAccent;
  Color _backgroundColor = Colors.white;

  Employee get employee => _employee;
  ThemeModeOption get themeMode => _themeMode;
  List<CustomTheme> get customThemes => _customThemes;
  CustomTheme? get selectedCustomTheme => _selectedCustomTheme;

  String _adminPassword = '787878';

  String get adminPassword => _adminPassword;

  SettingsViewModel() {
    _loadSettings();
  }

  Future<void> setAdminPassword(String newPassword) async {
    _adminPassword = newPassword;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('adminPassword', newPassword);
    // Load admin password
    String? savedPassword = prefs.getString('adminPassword');
    if (savedPassword != null) {
      _adminPassword = savedPassword;
    }
    
    notifyListeners();
  }

  Future<bool> verifyAdminPassword(String password) async {
    if (_adminPassword.isEmpty) {
      await _loadSettings();
    }
    return password == _adminPassword;
  }

  Future<void> _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    // Load employee data
    String? employeeString = prefs.getString('employee');
    if (employeeString != null) {
      _employee = Employee.fromMap(jsonDecode(employeeString));
    }
    
    // Load theme mode
    String? themeString = prefs.getString('themeMode');
    if (themeString != null) {
      _themeMode = ThemeModeOption.values.firstWhere(
        (e) => e.toString() == themeString,
        orElse: () => ThemeModeOption.white
      );
    }
    
    // Load custom themes
    String? customThemesString = prefs.getString('customThemes');
    if (customThemesString != null) {
      List<dynamic> themesList = jsonDecode(customThemesString);
      _customThemes.addAll(themesList.map((e) => CustomTheme.fromMap(e)));
      
      // Remove pink theme if it exists
      _customThemes.removeWhere((theme) => theme.name.toLowerCase().contains('pink'));
    }
    
    // Load selected custom theme
    String? selectedThemeString = prefs.getString('selectedCustomTheme');
    if (selectedThemeString != null) {
      _selectedCustomTheme = CustomTheme.fromMap(jsonDecode(selectedThemeString));
      // Reset to default theme if selected theme is pink
      if (_selectedCustomTheme!.name.toLowerCase().contains('pink')) {
        _selectedCustomTheme = null;
        _themeMode = ThemeModeOption.white;
        await prefs.remove('selectedCustomTheme');
        await prefs.setString('themeMode', ThemeModeOption.white.toString());
      } else {
        _primaryColor = _selectedCustomTheme!.primaryColor;
        _accentColor = _selectedCustomTheme!.accentColor;
        _backgroundColor = _selectedCustomTheme!.backgroundColor;
      }
    }
    
    notifyListeners();
  }

  Future<void> addCustomTheme(CustomTheme theme) async {
    // Validate theme trước khi thêm
    if (theme.name.isEmpty || 
        theme.name.toLowerCase().contains('pink') ||
        theme.primaryColor == Colors.transparent ||
        theme.accentColor == Colors.transparent ||
        theme.backgroundColor == Colors.transparent) {
      throw Exception('Theme không hợp lệ');
    }

    // Kiểm tra trùng tên
    if (_customThemes.any((t) => t.name == theme.name)) {
      throw Exception('Tên theme đã tồn tại');
    }

    _customThemes.add(theme);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'customThemes',
      jsonEncode(_customThemes.map((e) => e.toMap()).toList())
    );
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeModeOption mode, {CustomTheme? customTheme}) async {
    if (mode == ThemeModeOption.custom) {
      if (customTheme == null && _customThemes.isEmpty) {
        return; // Không có theme tùy chỉnh nào
      }
      customTheme ??= _customThemes.first;
      _selectedCustomTheme = customTheme;
      _primaryColor = customTheme.primaryColor;
      _accentColor = customTheme.accentColor;
      _backgroundColor = customTheme.backgroundColor;
    } else {
      _selectedCustomTheme = null;
    }

    _themeMode = mode;
    
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', mode.toString());
    if (mode == ThemeModeOption.custom && customTheme != null) {
      await prefs.setString('selectedCustomTheme', jsonEncode(customTheme.toMap()));
    } else {
      await prefs.remove('selectedCustomTheme');
    }
    
    notifyListeners();
  }

  // Các phương thức còn lại...
  Future<void> updateEmployee({
    String? name,
    String? email,
    String? profileImagePath,
    String? employeeId,
    DateTime? dateOfBirth,
    String? jobType,
  }) async {
    if (name != null) _employee.name = name;
    if (email != null) _employee.email = email;
    if (profileImagePath != null) _employee.profileImagePath = profileImagePath;
    if (employeeId != null) _employee.employeeId = employeeId;
    if (dateOfBirth != null) _employee.dateOfBirth = dateOfBirth;
    if (jobType != null) _employee.jobType = jobType;
    
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('employee', jsonEncode(_employee.toMap()));
    notifyListeners();
  }

  Future<void> updateJobType(String jobType) async {
    _employee.jobType = jobType;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('employee', jsonEncode(_employee.toMap()));
    notifyListeners();
  }

  ThemeData getThemeData() {
    debugPrint('Đang tạo theme với chế độ: $_themeMode');
    try {
      switch (_themeMode) {
        case ThemeModeOption.dark:
          return ThemeData.dark().copyWith(
            primaryColor: Colors.blueGrey,
            scaffoldBackgroundColor: Colors.grey[900],
          );
        case ThemeModeOption.sasin:
          return ThemeData.light().copyWith(
            primaryColor: Colors.deepOrange,
            scaffoldBackgroundColor: Colors.deepOrange[50],
            cardColor: Colors.deepOrange[100],
          );
        case ThemeModeOption.custom:
          // Fallback nếu màu nền không hợp lệ
          final bgColor = _backgroundColor.computeLuminance() > 0.1 
              ? _backgroundColor 
              : Colors.white;
              
          return ThemeData.light().copyWith(
            primaryColor: _primaryColor,
            colorScheme: ColorScheme.light(
              primary: _primaryColor,
              secondary: _accentColor,
              background: bgColor,
              surface: bgColor,
              onBackground: bgColor.computeLuminance() > 0.5 
                  ? Colors.black 
                  : Colors.white,
            ),
            scaffoldBackgroundColor: bgColor,
            cardColor: bgColor.withOpacity(0.9),
            dialogBackgroundColor: bgColor.withOpacity(0.95),
            textTheme: ThemeData.light().textTheme.apply(
              bodyColor: bgColor.computeLuminance() > 0.5 
                  ? Colors.black 
                  : Colors.white,
              displayColor: bgColor.computeLuminance() > 0.5 
                  ? Colors.black 
                  : Colors.white,
            ),
          );
        case ThemeModeOption.red:
          return ThemeData.light().copyWith(
            primaryColor: Colors.red[800],
            colorScheme: ColorScheme.light(
              primary: Colors.red[800]!,
              secondary: Colors.red[700]!,
              background: Color(0xFFFFEBEE),
              surface: Color(0xFFFFEBEE),
            ),
            scaffoldBackgroundColor: Color(0xFFFFEBEE),
            cardColor: Colors.white,
            dialogBackgroundColor: Colors.white,
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[800],
                foregroundColor: Colors.white,
              ),
            ),
            bottomNavigationBarTheme: BottomNavigationBarThemeData(
              backgroundColor: Colors.white,
              selectedItemColor: Colors.red[800],
              unselectedItemColor: Colors.grey,
            ),
          );
        case ThemeModeOption.white:
        default:
          return ThemeData.light().copyWith(
            primaryColor: Colors.blue,
            colorScheme: ColorScheme.light(
              primary: Colors.blue,
              secondary: Colors.blueAccent,
              background: Color(0xFFE1F5FE), // Màu xanh pastel nhạt
              surface: Color(0xFFE1F5FE),
            ),
            scaffoldBackgroundColor: Color(0xFFE1F5FE),
            cardColor: Colors.white,
            dialogBackgroundColor: Colors.white,
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
            bottomNavigationBarTheme: BottomNavigationBarThemeData(
              backgroundColor: Colors.white, // Màu nền trắng
              selectedItemColor: Colors.blue, // Màu khi được chọn
              unselectedItemColor: Colors.grey, // Màu khi không được chọn
            ),
          );
      }
    } catch (e) {
      debugPrint('Lỗi khi tạo ThemeData: $e');
      return ThemeData.light(); // Fallback mặc định nếu có lỗi
    }
  }
}

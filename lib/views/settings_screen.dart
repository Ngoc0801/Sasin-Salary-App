import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/settings_viewmodel.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import './custom_theme_dialog.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _employeeIdController = TextEditingController();
  DateTime? _selectedDateOfBirth;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _employeeIdController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(SettingsViewModel settingsViewModel) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      settingsViewModel.updateEmployee(profileImagePath: pickedFile.path);
    }
  }

  Future<void> _selectDateOfBirth(BuildContext context) async {
    final settingsViewModel = Provider.of<SettingsViewModel>(
      context,
      listen: false,
    );
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateOfBirth ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDateOfBirth = picked;
      });
      settingsViewModel.updateEmployee(dateOfBirth: picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsViewModel = Provider.of<SettingsViewModel>(context);

    // Cập nhật giá trị ban đầu cho TextField
    _nameController.text = settingsViewModel.employee.name;
    _emailController.text = settingsViewModel.employee.email;
    _employeeIdController.text = settingsViewModel.employee.employeeId;
    _selectedDateOfBirth = settingsViewModel.employee.dateOfBirth;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Hồ Sơ',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              // Hiển thị ảnh đại diện
              Center(
                child: GestureDetector(
                  onTap: () => _pickImage(settingsViewModel),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage:
                        settingsViewModel.employee.profileImagePath != null
                            ? FileImage(
                              File(
                                settingsViewModel.employee.profileImagePath!,
                              ),
                            )
                            : null,
                    child:
                        settingsViewModel.employee.profileImagePath == null
                            ? const Icon(Icons.person, size: 50)
                            : null,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Tên
              const Text('Tên', style: TextStyle(fontSize: 16)),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'Nhập tên của bạn',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              // Email
              const Text('Email', style: TextStyle(fontSize: 16)),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  hintText: 'Nhập email của bạn',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              // Mã nhân viên
              const Text('Mã Nhân Viên', style: TextStyle(fontSize: 16)),
              TextField(
                controller: _employeeIdController,
                decoration: const InputDecoration(
                  hintText: 'Nhập mã nhân viên',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              // Ngày tháng năm sinh
              const Text('Ngày Tháng Năm Sinh', style: TextStyle(fontSize: 16)),
              GestureDetector(
                onTap: () => _selectDateOfBirth(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    _selectedDateOfBirth != null
                        ? '${_selectedDateOfBirth!.day}/${_selectedDateOfBirth!.month}/${_selectedDateOfBirth!.year}'
                        : 'Chọn ngày sinh',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Loại công việc
              const Text('Loại Công Việc', style: TextStyle(fontSize: 16)),
              Column(
                children: [
                  RadioListTile<String>(
                    title: const Text('Bếp'),
                    value: 'kitchen',
                    groupValue: settingsViewModel.employee.jobType,
                    onChanged: (value) {
                      if (value != null) {
                        settingsViewModel.updateJobType(value);
                      }
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Phục vụ'),
                    value: 'service',
                    groupValue: settingsViewModel.employee.jobType,
                    onChanged: (value) {
                      if (value != null) {
                        settingsViewModel.updateJobType(value);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Nút lưu thông tin
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    settingsViewModel.updateEmployee(
                      name: _nameController.text,
                      email: _emailController.text,
                      employeeId: _employeeIdController.text,
                      dateOfBirth: _selectedDateOfBirth,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đã cập nhật thông tin')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    minimumSize: const Size(200, 50),
                  ),
                  child: const Text(
                    'Lưu',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Chọn giao diện
              Row(
                children: [
                  const Text(
                    'Theme: ',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: DropdownButton<ThemeModeOption>(
                      value: settingsViewModel.themeMode,
                      onChanged: (value) {
                        if (value != null) {
                          settingsViewModel.setThemeMode(value);
                        }
                      },
                      underline: Container(),
                      isDense: true,
                      items: [
                        ...ThemeModeOption.values
                            .where((mode) => mode != ThemeModeOption.custom)
                            .map(
                              (mode) => DropdownMenuItem(
                                value: mode,
                                child: Text(
                                  mode == ThemeModeOption.dark
                                      ? 'Tối'
                                      : mode == ThemeModeOption.white
                                      ? 'Sáng'
                                      : 'Sasin Theme',
                                ),
                              ),
                            ),
                        ...settingsViewModel.customThemes.map(
                          (theme) => DropdownMenuItem(
                            value: ThemeModeOption.custom,
                            child: Text(theme.name),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Nút tạo theme tùy chỉnh
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    // Show password dialog first
                    final passwordController = TextEditingController();
                    final password = await showDialog<String>(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: const Text('Nhập mật khẩu quản trị'),
                            content: TextField(
                              obscureText: true,
                              decoration: const InputDecoration(
                                hintText: 'Nhập mật khẩu',
                              ),
                              controller: passwordController,
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Hủy'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(
                                    context,
                                  ).pop(passwordController.text);
                                },
                                child: const Text('Gửi'),
                              ),
                            ],
                          ),
                    );

                    if (password == null || password.isEmpty) return;

                    // Verify password
                    final isValid = await Provider.of<SettingsViewModel>(
                      context,
                      listen: false,
                    ).verifyAdminPassword(password);
                    if (!isValid) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Mật khẩu không đúng')),
                      );
                      return;
                    }

                    // Proceed to open the custom theme dialog
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => const CustomThemeDialog(
                              currentPrimary: Colors.blue,
                              currentAccent: Colors.blueAccent,
                              currentBackground: Colors.white,
                            ),
                      ),
                    );

                    if (result != null) {
                      final settingsViewModel = Provider.of<SettingsViewModel>(
                        context,
                        listen: false,
                      );
                      settingsViewModel.addCustomTheme(
                        CustomTheme(
                          name: result['name'],
                          primaryColor: result['primary'],
                          accentColor: result['accent'],
                          backgroundColor: result['background'],
                        ),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Đã lưu theme ${result['name']}'),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    minimumSize: const Size(200, 50),
                  ),
                  child: const Text(
                    'Tạo Theme Tùy Chỉnh',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Footer information
              Padding(
                padding: const EdgeInsets.only(top: 40, left: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tên ứng dụng: Sasin Salary',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    Text(
                      'Phiên bản: 1.0.0',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    Text(
                      'Tác giả: Nguyễn Phạm Hùng, Nguyễn Thị Ánh Ngọc',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    Text(
                      'Email: hungnp1272@ut.edu.vn',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

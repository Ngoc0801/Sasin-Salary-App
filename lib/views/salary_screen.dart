import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/salary_viewmodel.dart';
import '../viewmodels/time_entry_viewmodel.dart';
import '../viewmodels/settings_viewmodel.dart';

class SalaryScreen extends StatelessWidget {
  const SalaryScreen({super.key});

  Future<void> _selectMonth(
    BuildContext context,
    SalaryViewModel salaryViewModel,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: salaryViewModel.selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDatePickerMode: DatePickerMode.year,
    );
    if (picked != null) {
      salaryViewModel.setSelectedMonth(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final salaryViewModel = Provider.of<SalaryViewModel>(context);
    final settingsViewModel = Provider.of<SettingsViewModel>(context);

    // Đồng bộ vị trí và mức lương tùy chỉnh từ settings
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (settingsViewModel.employee.jobType == 'kitchen') {
        salaryViewModel.setPosition(Position.kitchen);
        salaryViewModel.setCustomSalary(null); // Xóa custom salary nếu có
      } else if (settingsViewModel.employee.jobType == 'service') {
        salaryViewModel.setPosition(Position.waiter);
        salaryViewModel.setCustomSalary(null); // Xóa custom salary nếu có
      } else if (settingsViewModel.employee.jobType == 'custom' &&
          settingsViewModel.employee.customSalaryEnabled &&
          settingsViewModel.employee.customSalary != null) {
        salaryViewModel.setPosition(Position.custom);
        salaryViewModel.setCustomSalary(settingsViewModel.employee.customSalary);
      }
    });

    return Scaffold(
      appBar: null,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    onPressed: () {
                      final prevMonth = DateTime(
                        salaryViewModel.selectedMonth.year,
                        salaryViewModel.selectedMonth.month - 1,
                        1,
                      );
                      salaryViewModel.setSelectedMonth(prevMonth);
                    },
                  ),
                  GestureDetector(
                    onTap: () => _selectMonth(context, salaryViewModel),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 24,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        'Tháng ${salaryViewModel.selectedMonth.month}/${salaryViewModel.selectedMonth.year}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios),
                    onPressed: () {
                      final nextMonth = DateTime(
                        salaryViewModel.selectedMonth.year,
                        salaryViewModel.selectedMonth.month + 1,
                        1,
                      );
                      salaryViewModel.setSelectedMonth(nextMonth);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text(
                      'Chọn Vị Trí: ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    DropdownButton<Position>(
                      value: salaryViewModel.selectedPosition,
                      onChanged: (value) {
                        if (value != null) {
                          salaryViewModel.setPosition(value);
                          if (value != Position.custom) {
                            salaryViewModel.setCustomSalary(null); // Xóa custom salary khi chọn vị trí khác
                          } else if (settingsViewModel.employee.customSalaryEnabled &&
                              settingsViewModel.employee.customSalary != null) {
                            salaryViewModel.setCustomSalary(settingsViewModel.employee.customSalary);
                          }
                        }
                      },
                      items: Position.values
                          .map(
                            (position) => DropdownMenuItem(
                              value: position,
                              child: Text(
                                position == Position.kitchen
                                    ? 'Bếp'
                                    : position == Position.waiter
                                        ? 'Phục vụ'
                                        : 'Tùy chỉnh',
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tổng Lương',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${salaryViewModel.getFormattedTotalSalary()} VNĐ',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Tổng Số Giờ:',
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          '${salaryViewModel.getFormattedTotalHours()} giờ',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Tổng Số Ngày:',
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          '${salaryViewModel.getTotalDays()} ngày',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    if (salaryViewModel.selectedPosition == Position.custom &&
                        settingsViewModel.employee.customSalaryEnabled &&
                        settingsViewModel.employee.customSalary != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Mức lương tùy chỉnh:',
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            '${settingsViewModel.employee.customSalary?.toInt()} VNĐ/giờ',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Chi Tiết Lương',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: salaryViewModel.getSalaryDetails().length,
                itemBuilder: (context, index) {
                  final detail = salaryViewModel.getSalaryDetails()[index];
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ngày: ${detail['date'].day}/${detail['date'].month}/${detail['date'].year}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text('Số Giờ: ${detail['hours']} giờ'),
                          Text(
                            'Lương Cơ Bản: ${detail['baseSalary'].toInt()} VNĐ',
                          ),
                          if (detail['overtimeSalary'] > 0)
                            Text(
                              'Tăng Ca (22h-23h): ${detail['overtimeSalary'].toInt()} VNĐ',
                            ),
                          if (detail['holidaySalary'] > 0)
                            Text(
                              'Ngày lễ: ${detail['holidaySalary'].toInt()} VNĐ',
                            ),
                          const Divider(),
                          Text(
                            'Tổng: ${detail['totalSalary'].toInt()} VNĐ',
                            style: const TextStyle(fontWeight: FontWeight.bold),
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
      ),
    );
  }
}
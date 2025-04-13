import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'views/splash_screen.dart';
import 'viewmodels/time_entry_viewmodel.dart';
import 'viewmodels/calendar_viewmodel.dart';
import 'viewmodels/settings_viewmodel.dart';
import 'viewmodels/salary_viewmodel.dart';
import 'views/main_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TimeEntryViewModel()),
        ChangeNotifierProvider(create: (_) => SettingsViewModel()),
        ChangeNotifierProxyProvider<TimeEntryViewModel, CalendarViewModel>(
          create: (context) => CalendarViewModel(
            Provider.of<TimeEntryViewModel>(context, listen: false),
          ),
          update: (context, timeEntryViewModel, calendarViewModel) =>
              CalendarViewModel(timeEntryViewModel),
        ),
        ChangeNotifierProxyProvider<TimeEntryViewModel, SalaryViewModel>(
          create: (context) => SalaryViewModel(
            Provider.of<TimeEntryViewModel>(context, listen: false),
          ),
          update: (context, timeEntryViewModel, salaryViewModel) =>
              SalaryViewModel(timeEntryViewModel),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsViewModel>(
      builder: (context, settingsViewModel, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: settingsViewModel.getThemeData(),
          home: SplashScreen(),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:ostad_assignment_flutter_4/pages/home_page.dart';
import 'package:ostad_assignment_flutter_4/utils/theme/theme.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: TAppTheme.lightTheme,
      darkTheme: TAppTheme.darkTheme,
      themeMode: ThemeMode.system,
      title: 'Exam Week 3 - Assignment',
      home: const HomeScreen(),
    );
  }
}

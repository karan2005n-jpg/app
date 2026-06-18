import 'package:flutter/material.dart';
import 'screens/auth/login_page.dart';
import 'screens/auth/dashboard.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),

      onGenerateRoute: (settings) {
        if (settings.name == '/dashboard') {
          final userName = settings.arguments as String? ?? "User";

          return MaterialPageRoute(
            builder: (context) =>
                DashboardPage(userName: userName, successMessage: ""),
          );
        }
        return null;
      },
    );
  }
}

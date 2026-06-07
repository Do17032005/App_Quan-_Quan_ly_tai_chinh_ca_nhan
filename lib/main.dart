import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/finance_provider.dart';
import 'views/dashboard/dashboard_screen.dart';

void main() {
  runApp(
    // Sử dụng ChangeNotifierProvider để quản lý state toàn app
    ChangeNotifierProvider(
      create: (context) => FinanceProvider()..loadData(), // Gọi loadData ngay khi khởi chạy
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Finance Manager',
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: Colors.blue,
        scaffoldBackgroundColor: Colors.grey.shade100,
      ),
      home: const DashboardScreen(),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core
import 'package:provider/provider.dart';
import 'firebase_options.dart'; // File này sẽ tự động sinh ra sau khi bạn chạy FlutterFire CLI
import 'providers/finance_provider.dart';
import 'views/dashboard/dashboard_screen.dart';

void main() async {
  // Bắt buộc phải có dòng này khi sử dụng async trong hàm main
  WidgetsFlutterBinding.ensureInitialized();
  
  // Khởi tạo Firebase với cấu hình của hệ điều hành tương ứng
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    ChangeNotifierProvider(
      // Khởi tạo Provider và nạp dữ liệu từ Firebase về
      create: (context) => FinanceProvider()..listenToTransactions(),
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
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey.shade100,
      ),
      home: const DashboardScreen(),
    );
  }
}
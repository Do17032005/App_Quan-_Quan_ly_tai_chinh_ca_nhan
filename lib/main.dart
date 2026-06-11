import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart'; // Import AuthProvider
import 'providers/finance_provider.dart';
import 'views/dashboard/dashboard_screen.dart';
import 'views/auth/login_screen.dart'; // File giao diện chúng ta sẽ tạo ở bước sau

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(
          create: (context) => FinanceProvider()
            ..listenToTransactions()
            ..listenToCategories(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Kiểm tra xem người dùng đã đăng nhập chưa để điều hướng màn hình lúc mở App
    final authProvider = Provider.of<AuthProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Finance Manager',
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey.shade100,
      ),
      // Nếu đã đăng nhập -> Vào thẳng Dashboard, nếu chưa -> Vào màn hình Login
      home: authProvider.isAuthenticated
          ? const DashboardScreen()
          : const LoginScreen(),
    );
  }
}

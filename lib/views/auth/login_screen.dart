import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/finance_provider.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscureText = true; // Ẩn/hiện mật khẩu

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Icon ứng dụng lớn ở trên cùng
                Icon(
                  Icons.account_balance_wallet,
                  size: 80,
                  color: Colors.blue.shade600,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Chào Mừng Trở Lại',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Đăng nhập để tiếp tục quản lý thu chi',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 32),

                // Ô nhập Email
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập Email';
                    }
                    if (!RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    ).hasMatch(value)) {
                      return 'Định dạng Email không hợp lệ';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Ô nhập Mật khẩu
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscureText,
                  decoration: InputDecoration(
                    labelText: 'Mật khẩu',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () =>
                          setState(() => _obscureText = !_obscureText),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập mật khẩu';
                    }
                    if (value.length < 6) {
                      return 'Mật khẩu phải từ 6 ký tự trở lên';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Nút bấm Đăng Nhập
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () async {
                            if (_formKey.currentState!.validate()) {
                              setState(() => _isLoading = true);

                              final messenger = ScaffoldMessenger.of(context);
                              final finance = Provider.of<FinanceProvider>(context, listen: false);

                              // Gọi hàm đăng nhập và hứng chuỗi lỗi trả về
                              String? error = await authProvider.loginWithEmail(
                                _emailController.text.trim(),
                                _passwordController.text.trim(),
                              );

                              if (!mounted) return;
                              setState(() => _isLoading = false);

                              if (error != null) {
                                // BẮN THÔNG BÁO LỖI TIẾNG VIỆT LÊN MÀN HÌNH (Sai mật khẩu, chưa có tài khoản...)
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        const Icon(
                                          Icons.error_outline,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(child: Text(error)),
                                      ],
                                    ),
                                    backgroundColor: Colors.red.shade700,
                                    behavior: SnackBarBehavior.floating, // Hiển thị dạng bong bóng nổi đẹp mắt
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                );
                              } else {
                                // Nếu không có lỗi -> Thành công
                                messenger.showSnackBar(
                                  const SnackBar(
                                    content: Text('Đăng nhập thành công!'),
                                    backgroundColor: Colors.green,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                                finance.listenToTransactions();
                                finance.listenToCategories();
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'ĐĂNG NHẬP',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),

                // Dòng chuyển hướng sang màn hình Đăng ký
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Chưa có tài khoản? '),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Đăng ký ngay',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

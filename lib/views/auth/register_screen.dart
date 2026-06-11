import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, foregroundColor: Colors.black),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Tạo Tài Khoản',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Bắt đầu hành trình quản lý tài chính thông minh',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 32),

                // Ô nhập Email đăng ký
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Vui lòng nhập Email';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Ô nhập Mật khẩu
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Mật khẩu',
                    prefixIcon: const Icon(Icons.lock),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Vui lòng nhập mật khẩu';
                    if (value.length < 6) return 'Mật khẩu phải từ 6 ký tự trở lên';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Ô nhập lại Mật khẩu
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Xác nhận mật khẩu',
                    prefixIcon: const Icon(Icons.lock_clock),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (value) {
                    if (value != _passwordController.text) return 'Mật khẩu xác nhận không khớp';
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Nút Đăng ký
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : () async {
                      if (_formKey.currentState!.validate()) {
                        setState(() => _isLoading = true);

                        String? error = await authProvider.registerWithEmail(
                          _emailController.text.trim(),
                          _passwordController.text.trim(),
                        );

                        setState(() => _isLoading = false);

                        if (error != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(error), backgroundColor: Colors.red),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Đăng ký thành công!'), backgroundColor: Colors.green),
                          );
                          Navigator.pop(context); // Quay về lại màn hình Login
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('ĐĂNG KÝ NGAY', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
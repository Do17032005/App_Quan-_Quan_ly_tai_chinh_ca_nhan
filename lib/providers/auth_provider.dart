import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

  AuthProvider() {
    // Lắng nghe trạng thái thay đổi của tài khoản (Đã đăng nhập hay đăng xuất)
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  User? get user => _user;
  bool get isAuthenticated => _user != null;

  // HÀM ĐĂNG KÝ TÀI KHOẢN MỚI
  Future<String?> registerWithEmail(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null; // Trả về null nghĩa là không có lỗi -> Thành công
    } on FirebaseAuthException catch (e) {
      return _handleAuthError(e);
    }
  }

  // HÀM ĐĂNG NHẬP
  Future<String?> loginWithEmail(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null; // Không có lỗi -> Thành công
    } on FirebaseAuthException catch (e) {
      return _handleAuthError(e);
    }
  }

  // HÀM ĐĂNG XUẤT
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Dịch mã lỗi Firebase sang tiếng Việt cho thân thiện
  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'Mật khẩu quá yếu, cần tối thiểu 6 ký tự.';
      case 'email-already-in-use':
        return 'Email này đã được đăng ký bởi tài khoản khác.';
      case 'invalid-email':
        return 'Định dạng email không hợp lệ.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email hoặc mật khẩu không chính xác.';
      case 'too-many-requests':
        return 'Bạn đã thử quá nhiều lần. Vui lòng thử lại sau.';
      case 'network-request-failed':
        return 'Không thể kết nối mạng. Vui lòng kiểm tra lại Internet.';
      default:
        return 'Đăng nhập thất bại. Vui lòng thử lại.';
    }
  }
}

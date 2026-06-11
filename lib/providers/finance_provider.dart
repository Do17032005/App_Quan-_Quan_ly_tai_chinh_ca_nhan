import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import thêm FirebaseAuth
import '../data/models/category_model.dart';
import '../data/models/transaction_model.dart';

class FinanceProvider with ChangeNotifier {
  // Kết nối đến Collection 'transactions' trên Firebase
  final CollectionReference _transactionCollection = FirebaseFirestore.instance
      .collection('transactions');

  List<TransactionModel> _transactions = [];

  // Danh mục cố định dùng chung cho mọi tài khoản
  final List<CategoryModel> _categories = [
    CategoryModel(
      id: 1,
      name: 'Ăn uống',
      type: 'expense',
      iconName: 'utensils',
    ),
    CategoryModel(id: 2, name: 'Di chuyển', type: 'expense', iconName: 'car'),
    CategoryModel(
      id: 3,
      name: 'Mua sắm',
      type: 'expense',
      iconName: 'shopping-bag',
    ),
    CategoryModel(
      id: 4,
      name: 'Giải trí',
      type: 'expense',
      iconName: 'gamepad',
    ),
    CategoryModel(
      id: 5,
      name: 'Tiền lương',
      type: 'income',
      iconName: 'money-bill',
    ),
    CategoryModel(id: 6, name: 'Thưởng', type: 'income', iconName: 'gift'),
  ];

  List<TransactionModel> get transactions => _transactions;
  List<CategoryModel> get categories => _categories;

  double get totalIncome => _transactions
      .where((tx) => tx.type == 'income')
      .fold(0.0, (sum, item) => sum + item.amount);

  double get totalExpense => _transactions
      .where((tx) => tx.type == 'expense')
      .fold(0.0, (sum, item) => sum + item.amount);

  double get currentBalance => totalIncome - totalExpense;

  // LẮNG NGHE DỮ LIỆU REALTIME THEO TỪNG TÀI KHOẢN (ĐÃ PHÂN QUYỀN)
  void listenToTransactions() {
    // 1. Lấy thông tin người dùng hiện tại đang đăng nhập
    final User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      // Nếu chưa đăng nhập hoặc đã đăng xuất -> Xóa sạch danh sách hiển thị trên màn hình
      _transactions = [];
      notifyListeners();
      return;
    }

    // 2. Sử dụng lệnh .where() để LỌC dữ liệu trên server: chỉ lấy các document có 'user_id' trùng với UID của người này
    _transactionCollection
        .where('user_id', isEqualTo: currentUser.uid)
        .orderBy('date', descending: true)
        .snapshots()
        .listen((snapshot) {
          _transactions = snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return TransactionModel(
              id: doc.id.hashCode,
              documentId: doc.id,
              amount: (data['amount'] as num).toDouble(),
              type: data['type'],
              categoryId: data['category_id'],
              date: DateTime.parse(data['date']),
              note: data['note'] ?? '',
            );
          }).toList();

          notifyListeners(); // Cập nhật lại giao diện Dashboard thật
        });
  }

  // HÀM THÊM GIAO DỊCH LÊN FIREBASE (GẮN THÊM USER_ID)
  Future<void> addTransaction(TransactionModel transaction) async {
    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      // Chuyển object Map của transaction ra và ép thêm trường 'user_id' vào trước khi đẩy lên mây
      final Map<String, dynamic> txMap = transaction.toMap();
      txMap['user_id'] = currentUser.uid;

      await _transactionCollection.add(txMap);
    } catch (e) {
      print("Lỗi khi thêm dữ liệu phân quyền lên Firebase: $e");
    }
  }

  // HÀM XÓA GIAO DỊCH
  Future<void> deleteTransaction(String documentId) async {
    try {
      await _transactionCollection.doc(documentId).delete();
      // Không cần gọi notifyListeners() vì listenToTransactions() đang lắng nghe realtime sẽ tự cập nhật
    } catch (e) {
      print("Lỗi khi xóa giao dịch: $e");
    }
  }

  // HÀM SỬA GIAO DỊCH
  Future<void> updateTransaction(
    String documentId,
    TransactionModel updatedTx,
  ) async {
    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      final Map<String, dynamic> txMap = updatedTx.toMap();
      txMap['user_id'] = currentUser.uid;

      await _transactionCollection.doc(documentId).update(txMap);
    } catch (e) {
      print("Lỗi khi cập nhật giao dịch: $e");
    }
  }
}

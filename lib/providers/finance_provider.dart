import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import '../data/models/category_model.dart';
import '../data/models/transaction_model.dart';

class FinanceProvider with ChangeNotifier {
  // Kết nối đến Collection có tên là 'transactions' trên Firebase
  final CollectionReference _transactionCollection = 
      FirebaseFirestore.instance.collection('transactions');

  List<TransactionModel> _transactions = [];
  
  // Tạm thời giữ danh mục cố định (Sau này có thể đưa lên Firebase nốt nếu muốn)
  final List<CategoryModel> _categories = [
    CategoryModel(id: 1, name: 'Ăn uống', type: 'expense', iconName: 'utensils'),
    CategoryModel(id: 2, name: 'Di chuyển', type: 'expense', iconName: 'car'),
    CategoryModel(id: 3, name: 'Mua sắm', type: 'expense', iconName: 'shopping-bag'),
    CategoryModel(id: 4, name: 'Giải trí', type: 'expense', iconName: 'gamepad'),
    CategoryModel(id: 5, name: 'Tiền lương', type: 'income', iconName: 'money-bill'),
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

  // LẮNG NGHE DỮ LIỆU REALTIME TỪ FIREBASE
  void listenToTransactions() {
    // Luôn luôn lắng nghe biến động trên Firebase, cứ có thay đổi là tự cập nhật UI
    _transactionCollection.orderBy('date', descending: true).snapshots().listen((snapshot) {
      _transactions = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return TransactionModel(
          id: doc.id.hashCode, // Lấy ID của document trên Firebase làm ID tạm thời
          amount: (data['amount'] as num).toDouble(),
          type: data['type'],
          categoryId: data['category_id'],
          date: DateTime.parse(data['date']),
          note: data['note'] ?? '',
        );
      }).toList();
      
      notifyListeners(); // Báo cho giao diện Dashboard vẽ lại dữ liệu mới
    });
  }

  // HÀM THÊM GIA GIAO DỊCH LÊN FIREBASE
  Future<void> addTransaction(TransactionModel transaction) async {
    try {
      // Đẩy object Map của transaction lên thẳng server Firebase
      await _transactionCollection.add(transaction.toMap());
    } catch (e) {
      print("Lỗi khi thêm dữ liệu lên Firebase: $e");
    }
  }
}
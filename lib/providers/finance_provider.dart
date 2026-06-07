import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/category_model.dart';
import '../models/transaction_model.dart';

class FinanceProvider with ChangeNotifier {
  List<TransactionModel> _transactions = [];
  List<CategoryModel> _categories = [];

  List<TransactionModel> get transactions => _transactions;
  List<CategoryModel> get categories => _categories;

  double get totalIncome => _transactions
      .where((tx) => tx.type == 'income')
      .fold(0.0, (sum, item) => sum + item.amount);

  double get totalExpense => _transactions
      .where((tx) => tx.type == 'expense')
      .fold(0.0, (sum, item) => sum + item.amount);

  double get currentBalance => totalIncome - totalExpense;

  // Tải toàn bộ dữ liệu từ DB lên State
  Future<void> loadData() async {
    _categories = await DatabaseHelper.instance.getAllCategories();
    _transactions = await DatabaseHelper.instance.getAllTransactions();
    notifyListeners(); // Thông báo cho UI cập nhật lại giao diện
  }

  // Hàm thêm giao dịch và cập nhật lại danh sách ngay lập tức
  Future<void> addTransaction(TransactionModel transaction) async {
    await DatabaseHelper.instance.insertTransaction(transaction);
    await loadData(); // Tải lại dữ liệu mới sau khi chèn thành công
  }
}
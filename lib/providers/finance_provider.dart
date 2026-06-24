import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import thêm FirebaseAuth
import '../data/models/category_model.dart';
import '../data/models/transaction_model.dart';

class FinanceProvider with ChangeNotifier {
  // Kết nối đến Collection 'transactions' trên Firebase
  final CollectionReference _transactionCollection = FirebaseFirestore.instance
      .collection('transactions');

  final CollectionReference _categoryCollection = FirebaseFirestore.instance
      .collection('categories');

  static final List<CategoryModel> _defaultCategories = [
    CategoryModel(
      id: '1',
      name: 'Ăn uống',
      type: 'expense',
      iconName: 'utensils',
      colorValue: 0xFFFF9800, // Orange
    ),
    CategoryModel(
      id: '2',
      name: 'Di chuyển',
      type: 'expense',
      iconName: 'car',
      colorValue: 0xFF2196F3, // Blue
    ),
    CategoryModel(
      id: '3',
      name: 'Mua sắm',
      type: 'expense',
      iconName: 'shopping-bag',
      colorValue: 0xFFE91E63, // Pink
    ),
    CategoryModel(
      id: '4',
      name: 'Giải trí',
      type: 'expense',
      iconName: 'gamepad',
      colorValue: 0xFF9C27B0, // Purple
    ),
    CategoryModel(
      id: '5',
      name: 'Tiền lương',
      type: 'income',
      iconName: 'money-bill',
      colorValue: 0xFF4CAF50, // Green
    ),
    CategoryModel(
      id: '6',
      name: 'Thưởng',
      type: 'income',
      iconName: 'gift',
      colorValue: 0xFFFFC107, // Amber
    ),
    CategoryModel(
      id: '7',
      name: 'Tiền làm thêm',
      type: 'income',
      iconName: 'laptop-code',
      colorValue: 0xFF009688, // Teal
    ),
  ];

  List<TransactionModel> _transactions = [];
  List<CategoryModel> _customCategories = [];
  StreamSubscription<QuerySnapshot>? _transactionSubscription;
  StreamSubscription<QuerySnapshot>? _categorySubscription;

  List<CategoryModel> _dedupeCustomCategories(List<CategoryModel> categories) {
    final seen = <String>{};
    return categories.where((category) {
      final key =
          '${category.userId ?? ''}|${category.type}|${category.name.trim().toLowerCase()}';
      if (seen.contains(key)) return false;
      seen.add(key);
      return true;
    }).toList();
  }

  List<TransactionModel> get transactions => _transactions;
  List<CategoryModel> get categories => [
    ..._defaultCategories,
    ..._customCategories,
  ];

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
      _transactionSubscription?.cancel();
      _transactionSubscription = null;
      // Nếu chưa đăng nhập hoặc đã đăng xuất -> Xóa sạch danh sách hiển thị trên màn hình
      _transactions = [];
      notifyListeners();
      return;
    }

    // 2. Sử dụng lệnh .where() để LỌC dữ liệu trên server: chỉ lấy các document có 'user_id' trùng với UID của người này
    _transactionSubscription?.cancel();
    _transactionSubscription = _transactionCollection
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
              categoryId: (data['category_id'] ?? '').toString(),
              date: DateTime.parse(data['date']),
              note: data['note'] ?? '',
            );
          }).toList();

          notifyListeners(); // Cập nhật lại giao diện Dashboard thật
        });
  }

  // LẮNG NGHE DANH MỤC THÀNH PHẦN (Gọi hàm này chạy song song lúc đăng nhập)
  void listenToCategories() {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      _categorySubscription?.cancel();
      _categorySubscription = null;
      _customCategories = [];
      notifyListeners();
      return;
    }

    _categorySubscription?.cancel();
    _categorySubscription = _categoryCollection
        .where('user_id', isEqualTo: currentUser.uid)
        .snapshots()
        .listen((snapshot) {
      _customCategories = snapshot.docs.map((doc) {
        return CategoryModel.fromMap(
          doc.id,
          doc.data() as Map<String, dynamic>,
        );
      }).toList();
      _customCategories = _dedupeCustomCategories(_customCategories);
      notifyListeners();
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

  // HÀM USER TỰ THÊM DANH MỤC MỚI
  Future<void> addCustomCategory({
    required String name,
    required String type,
    required String iconName,
    required int colorValue,
  }) async {
    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      final newCat = CategoryModel(
        name: name,
        type: type,
        iconName: iconName,
        colorValue: colorValue,
        userId: currentUser.uid,
      );

      await _categoryCollection.add(newCat.toMap());
    } catch (e) {
      print("Lỗi thêm danh mục: $e");
    }
  }

  // HÀM USER CẬP NHẬT DANH MỤC TỰ TẠO
  Future<void> updateCustomCategory(CategoryModel category) async {
    try {
      if (category.id == null) return;
      await _categoryCollection.doc(category.id).update(category.toMap());
    } catch (e) {
      print("Lỗi cập nhật danh mục: $e");
    }
  }

  // HÀM USER XÓA DANH MỤC TỰ TẠO
  Future<void> deleteCustomCategory(String catId) async {
    try {
      await _categoryCollection.doc(catId).delete();
      _customCategories = _customCategories
          .where((category) => category.id != catId)
          .toList();
      notifyListeners();
    } catch (e) {
      print("Lỗi xóa danh mục: $e");
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

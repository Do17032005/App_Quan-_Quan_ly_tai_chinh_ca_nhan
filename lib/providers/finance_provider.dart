import 'dart:developer' as developer;
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
  List<TransactionModel> _statsTransactions = []; // Riêng cho Thống kê (có thể load toàn bộ)
  Map<String, List<TransactionModel>> _groupedTransactions = {};
  List<CategoryModel> _customCategories = [];
  double _totalIncome = 0;
  double _totalExpense = 0;
  StreamSubscription<QuerySnapshot>? _transactionSubscription;
  StreamSubscription<QuerySnapshot>? _categorySubscription;

  // Pagination states
  DocumentSnapshot? _lastDocument;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  final int _pageSize = 20;

  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;

  void _updateGroupedTransactions() {
    _groupedTransactions = {};
    // Cập nhật grouping cho toàn bộ danh sách hiện có
    for (var tx in _transactions) {
      final key = "${tx.date.year}-${tx.date.month}-${tx.date.day}";
      if (_groupedTransactions[key] == null) {
        _groupedTransactions[key] = [];
      }
      _groupedTransactions[key]!.add(tx);
    }
  }

  // Tính toán lại tổng thu chi (có thể tối ưu bằng cách tính khi load/add/delete)
  void _calculateTotals() {
    _totalIncome = 0;
    _totalExpense = 0;
    for (var tx in _transactions) {
      if (tx.type == 'income') {
        _totalIncome += tx.amount;
      } else {
        _totalExpense += tx.amount;
      }
    }
  }

  List<TransactionModel> getTransactionsByDay(DateTime date) {
    final key = "${date.year}-${date.month}-${date.day}";
    return _groupedTransactions[key] ?? [];
  }

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
  List<TransactionModel> get statsTransactions => _statsTransactions.isNotEmpty ? _statsTransactions : _transactions;

  // Tải TOÀN BỘ giao dịch cho Thống kê (Dùng khi cần chính xác tuyệt đối các biểu đồ)
  Future<void> fetchAllTransactionsForStats() async {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    try {
      final snapshot = await _transactionCollection
          .where('user_id', isEqualTo: currentUser.uid)
          .orderBy('date', descending: true)
          .get();

      _statsTransactions = snapshot.docs.map((doc) {
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
      notifyListeners();
    } catch (e) {
      developer.log("Lỗi khi tải toàn bộ giao dịch", error: e);
    }
  }

  // TỐI ƯU: Lấy giao dịch theo tháng/năm
  List<TransactionModel> getTransactionsByMonth(DateTime date) {
    final source = statsTransactions;
    return source.where((tx) =>
      tx.date.year == date.year && tx.date.month == date.month
    ).toList();
  }

  // TỐI ƯU: Lấy giao dịch theo năm
  List<TransactionModel> getTransactionsByYear(int year) {
    final source = statsTransactions;
    return source.where((tx) => tx.date.year == year).toList();
  }

  List<CategoryModel> get categories => [
    ..._defaultCategories,
    ..._customCategories,
  ];

  double get totalIncome => _totalIncome;

  double get totalExpense => _totalExpense;

  double get currentBalance => _totalIncome - _totalExpense;

  // LẮNG NGHE DỮ LIỆU REALTIME THEO TỪNG TÀI KHOẢN (Với Pagination)
  void listenToTransactions() {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      _transactionSubscription?.cancel();
      _transactionSubscription = null;
      _transactions = [];
      _lastDocument = null;
      _hasMore = true;
      notifyListeners();
      return;
    }

    _transactionSubscription?.cancel();
    // Lắng nghe realtime nhưng giới hạn số lượng để tiết kiệm tài nguyên
    // Khi có thay đổi ở bất kỳ record nào, snapshot này sẽ trigger
    _transactionSubscription = _transactionCollection
        .where('user_id', isEqualTo: currentUser.uid)
        .orderBy('date', descending: true)
        .limit(_pageSize)
        .snapshots()
        .listen((snapshot) {
          if (snapshot.docs.isNotEmpty) {
            _lastDocument = snapshot.docs.last;
            // Nếu snapshot trả về ít hơn page size, nghĩa là hết dữ liệu
            _hasMore = snapshot.docs.length == _pageSize;
          } else {
            _hasMore = false;
          }

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

          _updateGroupedTransactions();
          _calculateTotals();
          notifyListeners();
        });
  }

  // Tải thêm giao dịch khi cuộn xuống (Infinite Scroll)
  Future<void> loadMoreTransactions() async {
    if (_isLoadingMore || !_hasMore || _lastDocument == null) return;

    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final snapshot = await _transactionCollection
          .where('user_id', isEqualTo: currentUser.uid)
          .orderBy('date', descending: true)
          .startAfterDocument(_lastDocument!)
          .limit(_pageSize)
          .get();

      if (snapshot.docs.isNotEmpty) {
        _lastDocument = snapshot.docs.last;
        _hasMore = snapshot.docs.length == _pageSize;

        final newTransactions = snapshot.docs.map((doc) {
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

        _transactions.addAll(newTransactions);
        _updateGroupedTransactions();
        _calculateTotals();
      } else {
        _hasMore = false;
      }
    } catch (e) {
      developer.log("Lỗi khi tải thêm giao dịch", error: e);
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
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

      final docRef = await _transactionCollection.add(txMap);

      // Cập nhật statsTransactions nếu đã được load để StatisticsScreen cập nhật tức thì
      if (_statsTransactions.isNotEmpty) {
        final newTx = TransactionModel(
          id: docRef.id.hashCode,
          documentId: docRef.id,
          amount: transaction.amount,
          type: transaction.type,
          categoryId: transaction.categoryId,
          date: transaction.date,
          note: transaction.note,
        );
        final newList = List<TransactionModel>.from(_statsTransactions);
        newList.insert(0, newTx);
        newList.sort((a, b) => b.date.compareTo(a.date));
        _statsTransactions = newList;
        notifyListeners();
      }
    } catch (e) {
      developer.log("Lỗi khi thêm dữ liệu phân quyền lên Firebase", error: e);
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
      developer.log("Lỗi thêm danh mục", error: e);
    }
  }

  // HÀM USER CẬP NHẬT DANH MỤC TỰ TẠO
  Future<void> updateCustomCategory(CategoryModel category) async {
    try {
      if (category.id == null) return;
      await _categoryCollection.doc(category.id).update(category.toMap());
    } catch (e) {
      developer.log("Lỗi cập nhật danh mục", error: e);
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
      developer.log("Lỗi xóa danh mục", error: e);
    }
  }

  // HÀM XÓA GIAO DỊCH
  Future<void> deleteTransaction(String documentId) async {
    try {
      await _transactionCollection.doc(documentId).delete();
      // Cập nhật statsTransactions nếu đã được load
      if (_statsTransactions.isNotEmpty) {
        final newList = List<TransactionModel>.from(_statsTransactions);
        newList.removeWhere((tx) => tx.documentId == documentId);
        _statsTransactions = newList;
        notifyListeners();
      }
    } catch (e) {
      developer.log("Lỗi khi xóa giao dịch", error: e);
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

      // Cập nhật statsTransactions nếu đã được load
      if (_statsTransactions.isNotEmpty) {
        final newList = List<TransactionModel>.from(_statsTransactions);
        final index = newList.indexWhere((tx) => tx.documentId == documentId);
        if (index != -1) {
          newList[index] = updatedTx;
          // Có thể ngày đã thay đổi nên cần sort lại
          newList.sort((a, b) => b.date.compareTo(a.date));
          _statsTransactions = newList;
          notifyListeners();
        }
      }
    } catch (e) {
      developer.log("Lỗi khi cập nhật giao dịch", error: e);
    }
  }
}

import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/category_model.dart';
import '../models/transaction_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('finance.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    // 1. Tạo bảng Danh mục (Categories)
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        icon_name TEXT NOT NULL
      )
    ''');

    // 2. Tạo bảng Giao dịch (Transactions)
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        category_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        note TEXT,
        FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE CASCADE
      )
    ''');

    // 3. Chèn sẵn dữ liệu danh mục mặc định cho người dùng
    final defaultCategories = [
      // Chi tiêu (expense)
      {'name': 'Ăn uống', 'type': 'expense', 'icon_name': 'utensils'},
      {'name': 'Di chuyển', 'type': 'expense', 'icon_name': 'car'},
      {'name': 'Mua sắm', 'type': 'expense', 'icon_name': 'shopping-bag'},
      {'name': 'Giải trí', 'type': 'expense', 'icon_name': 'gamepad'},
      // Thu nhập (income)
      {'name': 'Tiền lương', 'type': 'income', 'icon_name': 'money-bill'},
      {'name': 'Thưởng', 'type': 'income', 'icon_name': 'gift'},
      {'name': 'Tiền làm thêm', 'type': 'income', 'icon_name': 'laptop-code'},
    ];

    for (var cat in defaultCategories) {
      await db.insert('categories', cat);
    }
  }

  // ==================== CÁC HÀM XỬ LÝ GIAO DỊCH (CRUD) ====================

  // Thêm giao dịch mới
  Future<int> insertTransaction(TransactionModel transaction) async {
    final db = await instance.database;
    return await db.insert('transactions', transaction.toMap());
  }

  // Lấy toàn bộ danh sách giao dịch (Sắp xếp theo ngày mới nhất)
  Future<List<TransactionModel>> getAllTransactions() async {
    final db = await instance.database;
    final result = await db.query('transactions', orderBy: 'date DESC');
    return result.map((json) => TransactionModel.fromMap(json)).toList();
  }

  // ==================== CÁC HÀM XỬ LÝ DANH MỤC ====================

  // Lấy danh sách danh mục
  Future<List<CategoryModel>> getAllCategories() async {
    final db = await instance.database;
    final result = await db.query('categories');
    return result
        .map((json) => CategoryModel.fromMap(json['id'].toString(), json))
        .toList();
  }

  // Đóng database khi không dùng
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}

class TransactionModel {
  final int? id;
  final double amount;
  final String type; // 'income' hoặc 'expense'
  final int categoryId; // Khóa ngoại liên kết với Danh mục
  final DateTime date;
  final String note;

  TransactionModel({
    this.id,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.date,
    required this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'type': type,
      'category_id': categoryId,
      'date': date.toIso8601String(), // Lưu dạng String ISO8601 để SQLite hiểu
      'note': note,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      amount: map['amount'],
      type: map['type'],
      categoryId: map['category_id'],
      date: DateTime.parse(map['date']),
      note: map['note'],
    );
  }
}
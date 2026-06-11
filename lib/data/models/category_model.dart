class CategoryModel {
  final String? id; // Chuyển sang String để hứng Document ID của Firebase
  final String name;
  final String type; // 'income' hoặc 'expense'
  final String iconName;
  final String?
  userId; // Đính kèm UID để phân quyền danh mục của ai người nấy dùng

  CategoryModel({
    this.id,
    required this.name,
    required this.type,
    required this.iconName,
    this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
      'icon_name': iconName,
      'user_id': userId,
    };
  }

  factory CategoryModel.fromMap(String docId, Map<String, dynamic> map) {
    return CategoryModel(
      id: docId,
      name: map['name'] ?? '',
      type: map['type'] ?? 'expense',
      iconName: map['icon_name'] ?? 'category',
      userId: map['user_id'],
    );
  }
}

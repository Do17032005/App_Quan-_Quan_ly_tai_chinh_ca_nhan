class CategoryModel {
  final String? id; 
  final String name;
  final String type; // 'income' hoặc 'expense'
  final String iconName;
  final int colorValue; // Lưu giá trị màu sắc (ARGB)
  final String? userId; 

  CategoryModel({
    this.id,
    required this.name,
    required this.type,
    required this.iconName,
    required this.colorValue,
    this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
      'icon_name': iconName,
      'color_value': colorValue,
      'user_id': userId,
    };
  }

  factory CategoryModel.fromMap(String docId, Map<String, dynamic> map) {
    return CategoryModel(
      id: docId,
      name: map['name'] ?? '',
      type: map['type'] ?? 'expense',
      iconName: map['icon_name'] ?? 'category',
      colorValue: map['color_value'] ?? 0xFF9E9E9E, // Mặc định là màu xám nếu không có
      userId: map['user_id'],
    );
  }
}

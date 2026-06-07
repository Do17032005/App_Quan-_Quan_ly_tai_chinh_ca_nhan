class CategoryModel {
  final int? id;
  final String name;
  final String type; // 'income' (Thu) hoặc 'expense' (Chi)
  final String iconName; // Tên icon để map với FontAwesomeIcons

  CategoryModel({
    this.id,
    required this.name,
    required this.type,
    required this.iconName,
  });

  // Chuyển đối tượng thành Map để lưu vào SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'icon_name': iconName,
    };
  }

  // Chuyển Map từ SQLite ngược lại thành đối tượng Dart
  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'],
      name: map['name'],
      type: map['type'],
      iconName: map['icon_name'],
    );
  }
}
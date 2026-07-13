import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../data/models/category_model.dart';
import '../../providers/finance_provider.dart';
import '../../utils/icon_utils.dart';

class EditCategoryScreen extends StatefulWidget {
  final CategoryModel? category;
  final String initialType;

  const EditCategoryScreen({super.key, this.category, required this.initialType});

  @override
  State<EditCategoryScreen> createState() => _EditCategoryScreenState();
}

class _EditCategoryScreenState extends State<EditCategoryScreen> {
  late TextEditingController _nameController;
  late String _selectedIcon;
  late int _selectedColor;

  final List<String> _icons = [
    'utensils', 'car', 'shopping-bag', 'gamepad', 'money-bill', 'gift', 'laptop-code',
    'shopping_cart', 'local_taxi', 'flight', 'fastfood', 'cake', 'icecream', 'rice_bowl', 'breakfast_dining',
    'directions_boat', 'donut_large', 'videocam', 'coffee', 'star', 'checkroom', 'straighten', 'wine_bar'
  ];

  final List<int> _colors = [
    0xFFFFEB3B, 0xFFFFCCBC, 0xFFFF8A80, 0xFFF8BBD0, 0xFFFCE4EC,
    0xFFFF9800, 0xFFFF0000, 0xFFE91E63, 0xFFD81B60, 0xFFC2185B, 0xFFAD1457, 0xFF880E4F,
    0xFFB26500, 0xFF8D6E63, 0xFF6D4C41, 0xFF5D4037, 0xFF4E342E, 0xFF3E2723,
    0xFFFFF59D, 0xFFE6EE9C, 0xFFDCEDC8, 0xFFC8E6C9, 0xFFB2DFDB, 0xFFB2EBF2, 0xFFB3E5FC,
    0xFFFBC02D, 0xFFAFB42B, 0xFF7CB342, 0xFF43A047, 0xFF00897B, 0xFF00ACC1, 0xFF039BE5,
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _selectedIcon = widget.category?.iconName ?? _icons[0];
    _selectedColor = widget.category?.colorValue ?? _colors[0];
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.category == null ? 'Tạo mới' : 'Chỉnh sửa'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('Tên', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 20),
                      Expanded(
                        child: TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            hintText: 'Vui lòng nhập vào tên đề mục',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 16),
                  const Text('Biểu tượng', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Expanded(
                    flex: 3,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Scrollbar(
                        thumbVisibility: true,
                        child: GridView.builder(
                          padding: const EdgeInsets.all(12),
                          physics: const BouncingScrollPhysics(),
                          itemCount: _icons.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                          ),
                          itemBuilder: (context, index) {
                            final icon = _icons[index];
                            final isSelected = _selectedIcon == icon;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedIcon = icon),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isSelected ? Color(_selectedColor).withOpacity(0.2) : Colors.white,
                                  border: Border.all(
                                    color: isSelected ? Color(_selectedColor) : Colors.grey.shade300,
                                    width: isSelected ? 2 : 1,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                alignment: Alignment.center,
                                child: FaIcon(
                                  IconUtils.getIconData(icon),
                                  color: isSelected ? Color(_selectedColor) : Colors.grey,
                                  size: 20,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('Màu sắc', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Expanded(
                    flex: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Scrollbar(
                        thumbVisibility: true,
                        child: GridView.builder(
                          padding: const EdgeInsets.all(12),
                          physics: const BouncingScrollPhysics(),
                          itemCount: _colors.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 6,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                          ),
                          itemBuilder: (context, index) {
                            final color = _colors[index];
                            final isSelected = _selectedColor == color;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedColor = color),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Color(color),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: isSelected ? [
                                    BoxShadow(
                                      color: Color(color).withOpacity(0.4),
                                      blurRadius: 4,
                                      spreadRadius: 2,
                                    )
                                  ] : null,
                                  border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
                                ),
                                child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 20) : null,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  final name = _nameController.text.trim();
                  final messenger = ScaffoldMessenger.of(context);
                  final navigator = Navigator.of(context);
                  
                  if (name.isEmpty) {
                    messenger.showSnackBar(
                      SnackBar(
                        content: const Text('Vui lòng nhập tên danh mục'),
                        backgroundColor: Colors.orangeAccent,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                    return;
                  }

                  final financeProvider = Provider.of<FinanceProvider>(context, listen: false);
                  
                  // Kiểm tra trùng tên (không phân biệt hoa thường)
                  final existingCategory = financeProvider.categories.where((c) => 
                    c.type == widget.initialType && 
                    c.name.toLowerCase() == name.toLowerCase() &&
                    c.id != widget.category?.id
                  ).toList();

                  if (existingCategory.isNotEmpty) {
                    messenger.showSnackBar(
                      SnackBar(
                        content: const Text('Tên danh mục này đã tồn tại'),
                        backgroundColor: Colors.redAccent,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                    return;
                  }

                  if (widget.category == null) {
                    await financeProvider.addCustomCategory(
                      name: name,
                      type: widget.initialType,
                      iconName: _selectedIcon,
                      colorValue: _selectedColor,
                    );
                    messenger.showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.check_circle_outline, color: Colors.white),
                            const SizedBox(width: 12),
                            Text('Đã thêm danh mục "$name"'),
                          ],
                        ),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  } else {
                    final updated = CategoryModel(
                      id: widget.category!.id,
                      name: name,
                      type: widget.category!.type,
                      iconName: _selectedIcon,
                      colorValue: _selectedColor,
                      userId: widget.category!.userId,
                    );
                    await financeProvider.updateCustomCategory(updated);
                    messenger.showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.edit_note, color: Colors.white),
                            const SizedBox(width: 12),
                            Text('Đã cập nhật danh mục "$name"'),
                          ],
                        ),
                        backgroundColor: Colors.blueAccent,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  }
                  
                  navigator.pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlueAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                ),
                child: const Text('Lưu', style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

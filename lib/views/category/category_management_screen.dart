import 'package:app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../providers/finance_provider.dart';
import '../../data/models/category_model.dart';
import '../../utils/icon_utils.dart';
import 'edit_category_screen.dart';

class CategoryManagementScreen extends StatefulWidget {
  final String initialType;
  const CategoryManagementScreen({super.key, this.initialType = 'expense'});

  @override
  State<CategoryManagementScreen> createState() => _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  late String _currentType;

  // Tìm kiếm
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _currentType = widget.initialType;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FinanceProvider>(context);
    final l10n = AppLocalizations.of(context)!;
    
    // Lọc danh mục theo loại và tìm kiếm
    final categories = provider.categories.where((c) {
      final isCorrectType = c.type == _currentType;
      if (!_isSearching || _searchQuery.isEmpty) return isCorrectType;
      
      final nameMatch = c.name.toLowerCase().contains(_searchQuery.toLowerCase());
      return isCorrectType && nameMatch;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: _isSearching
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.lightBlueAccent),
                onPressed: () {
                  setState(() {
                    _isSearching = false;
                    _searchQuery = '';
                    _searchController.clear();
                  });
                },
              )
            : IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.lightBlueAccent),
                onPressed: () => Navigator.pop(context),
              ),
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: l10n.searchHint,
                  border: InputBorder.none,
                ),
                style: const TextStyle(fontSize: 16),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              )
            : Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTypeTab(l10n.expense, 'expense'),
                    _buildTypeTab(l10n.income, 'income'),
                  ],
                ),
              ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search, color: Colors.lightBlueAccent),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _searchQuery = '';
                  _searchController.clear();
                  _isSearching = false;
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (!_isSearching) ...[
            const SizedBox(height: 16),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.add, color: Colors.grey),
                title: Text(l10n.addCategory, style: const TextStyle(color: Colors.grey)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditCategoryScreen(initialType: _currentType),
                    ),
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListView.separated(
                itemCount: categories.length,
                separatorBuilder: (context, index) => const Divider(height: 1, indent: 56),
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  final isCustom = cat.userId != null;
                  return ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Color(cat.colorValue).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: FaIcon(
                        IconUtils.getIconData(cat.iconName),
                        color: Color(cat.colorValue),
                        size: 18,
                      ),
                    ),
                    title: Text(cat.name),
                    trailing: isCustom 
                      ? IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                          onPressed: () => _showDeleteConfirmation(context, provider, cat),
                        )
                      : null, // Danh mục mặc định
                    onTap: () {
                      if (isCustom) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditCategoryScreen(category: cat, initialType: _currentType),
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, FinanceProvider provider, CategoryModel category) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n?.confirmDelete ?? 'Xác nhận xóa'),
        content: Text(l10n?.confirmDeleteCategory(category.name) ?? 'Bạn có chắc chắn muốn xóa danh mục "${category.name}" không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n?.cancel ?? 'Hủy'),
          ),
          TextButton(
            onPressed: () async {
              if (category.id != null) {
                final navigator = Navigator.of(context);
                final messenger = ScaffoldMessenger.of(context);
                await provider.deleteCustomCategory(category.id!);
                if (mounted) {
                  navigator.pop();
                  messenger.showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.delete_sweep, color: Colors.white),
                          const SizedBox(width: 12),
                          Text(l10n?.categoryDeleted(category.name) ?? 'Đã xóa danh mục ${category.name}'),
                        ],
                      ),
                      backgroundColor: Colors.redAccent,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              }
            },
            child: Text(l10n?.delete ?? 'Xóa', style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeTab(String label, String type) {
    bool isSelected = _currentType == type;
    return GestureDetector(
      onTap: () => setState(() => _currentType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.lightBlueAccent : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

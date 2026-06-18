import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../data/models/category_model.dart';
import '../../data/models/transaction_model.dart';
import '../../providers/finance_provider.dart';
import '../../main.dart'; // Thêm import này

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({Key? key}) : super(key: key);

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  String _transactionType = 'expense'; // Mặc định là Chi tiêu
  String? _selectedCategoryId;
  DateTime _selectedDate = DateTime.now();

  CategoryModel? _findCategoryById(
    List<CategoryModel> categories,
    String? categoryId,
  ) {
    if (categoryId == null) return null;
    for (final category in categories) {
      if (category.id == categoryId) {
        return category;
      }
    }
    return null;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _showManageCategoriesBottomSheet(BuildContext context) async {
    final financeProvider = Provider.of<FinanceProvider>(
      context,
      listen: false,
    );
    final catNameController = TextEditingController();
    String selectedType = 'expense';
    bool isSubmitting = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 20,
            left: 20,
            right: 20,
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Quản Lý Danh Mục',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: catNameController,
                  decoration: const InputDecoration(
                    labelText: 'Tên danh mục mới',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ChoiceChip(
                      label: const Text('Khoản chi'),
                      selected: selectedType == 'expense',
                      onSelected: (_) =>
                          setModalState(() => selectedType = 'expense'),
                    ),
                    const SizedBox(width: 12),
                    ChoiceChip(
                      label: const Text('Khoản thu'),
                      selected: selectedType == 'income',
                      onSelected: (_) =>
                          setModalState(() => selectedType = 'income'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      if (isSubmitting) return;
                      final name = catNameController.text.trim();
                      if (name.isEmpty) return;

                      setModalState(() => isSubmitting = true);
                      bool success = false;
                      try {
                        await financeProvider.addCustomCategory(
                          name,
                          selectedType,
                        );
                        success = true;
                        catNameController.clear();
                      } catch (e) {
                        // Lỗi đã được xử lý trong provider
                      }

                      // Chỉ cập nhật state nếu widget còn mounted
                      if (!context.mounted) return;

                      if (success) {
                        Navigator.pop(context);
                        // Sử dụng key toàn cục để tránh lỗi context
                        scaffoldMessengerKey.currentState?.showSnackBar(
                          const SnackBar(
                            content: Text('Đã thêm danh mục mới!'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      } else {
                        setModalState(() => isSubmitting = false);
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: Text(
                      isSubmitting ? 'ĐANG THÊM...' : 'THÊM DANH MỤC',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Danh mục hiện có',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: Consumer<FinanceProvider>(
                    builder: (context, provider, child) {
                      final categories = provider.categories;
                      final systemCategories = categories
                          .where((category) => category.userId == null)
                          .toList();
                      final customCategories = categories
                          .where((category) => category.userId != null)
                          .toList();

                      Widget buildCategoryList(List<CategoryModel> items) {
                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: items.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final category = items[index];
                            final isSystemCategory = category.userId == null;

                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(category.name),
                              subtitle: Text(
                                category.type == 'expense'
                                    ? 'Khoản chi'
                                    : 'Khoản thu',
                              ),
                              trailing: isSystemCategory
                                  ? const Icon(
                                      Icons.lock_outline,
                                      size: 20,
                                      color: Colors.grey,
                                    )
                                  : IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: Colors.red,
                                      ),
                                      onPressed: () async {
                                        if (category.id == null) return;
                                        await financeProvider
                                            .deleteCustomCategory(category.id!);
                                      },
                                    ),
                            );
                          },
                        );
                      }

                      if (categories.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Text('Chưa có danh mục nào.'),
                        );
                      }

                      return SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (systemCategories.isNotEmpty) ...[
                              const Text(
                                'Danh mục hệ thống',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 8),
                              buildCategoryList(systemCategories),
                              const SizedBox(height: 16),
                            ],
                            if (customCategories.isNotEmpty) ...[
                              const Text(
                                'Danh mục của bạn',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 8),
                              buildCategoryList(customCategories),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );

    catNameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Gọi danh mục thực tế được tải lên từ Database thông qua Provider
    final financeProvider = Provider.of<FinanceProvider>(context);

    // Lọc danh mục theo loại Thu nhập hoặc Chi tiêu tương ứng
    List<CategoryModel> filteredCategories = financeProvider.categories
        .where((cat) => cat.type == _transactionType)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Thêm Giao Dịch',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Quản lý danh mục',
            icon: const Icon(Icons.category_outlined),
            onPressed: () => _showManageCategoriesBottomSheet(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Tab Chọn Loại Giao Dịch (Thu nhập / Chi tiêu)
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('Chi tiêu')),
                      selected: _transactionType == 'expense',
                      selectedColor: Colors.red.shade100,
                      labelStyle: TextStyle(
                        color: _transactionType == 'expense'
                            ? Colors.red
                            : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _transactionType = 'expense';
                            _selectedCategoryId =
                                null; // Reset lại danh mục đã chọn
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('Thu nhập')),
                      selected: _transactionType == 'income',
                      selectedColor: Colors.green.shade100,
                      labelStyle: TextStyle(
                        color: _transactionType == 'income'
                            ? Colors.green
                            : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _transactionType = 'income';
                            _selectedCategoryId =
                                null; // Reset lại danh mục đã chọn
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 2. Ô Nhập Số Tiền
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  labelText: 'Số tiền',
                  hintText: '0',
                  prefixIcon: const Icon(
                    Icons.monetization_on,
                    color: Colors.orange,
                  ),
                  suffixText: 'đ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập số tiền';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Số tiền nhập vào phải lớn hơn 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // 3. Dropdown Chọn Danh Mục thực tế từ SQLite
              DropdownButtonFormField<CategoryModel>(
                value: _findCategoryById(
                  filteredCategories,
                  _selectedCategoryId,
                ),
                hint: const Text('Chọn danh mục chi tiêu/thu nhập'),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.category, color: Colors.blue),
                ),
                items: filteredCategories.map((CategoryModel category) {
                  return DropdownMenuItem<CategoryModel>(
                    value: category,
                    child: Text(category.name),
                  );
                }).toList(),
                onChanged: (CategoryModel? newValue) {
                  setState(() {
                    _selectedCategoryId = newValue?.id;
                  });
                },
                validator: (_) => _selectedCategoryId == null
                    ? 'Vui lòng chọn danh mục'
                    : null,
              ),
              const SizedBox(height: 20),

              // 4. Ô Chọn Ngày (DatePicker)
              InkWell(
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _selectedDate = pickedDate;
                    });
                  }
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Ngày giao dịch',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(
                      Icons.calendar_today,
                      color: Colors.teal,
                    ),
                  ),
                  child: Text(
                    DateFormat('dd/MM/yyyy').format(_selectedDate),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 5. Ô Nhập Ghi Chú
              TextFormField(
                controller: _noteController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Ghi chú (Không bắt buộc)',
                  hintText: 'Ví dụ: Mua giáo trình, Đi ăn cưới...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.edit_note, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 32),

              // 6. Nút Lưu Giao Dịch thực tế vào Database
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      // 1. Tạo đối tượng Transaction từ dữ liệu form
                      final newTx = TransactionModel(
                        amount: double.parse(_amountController.text),
                        type: _transactionType,
                        categoryId: _selectedCategoryId!,
                        date: _selectedDate,
                        note: _noteController.text.trim(),
                      );

                      // 2. Gọi Provider để ghi dữ liệu lên Cloud Firebase
                      await financeProvider.addTransaction(newTx);

                      if (mounted) {
                        // Sử dụng key toàn cục để tránh lỗi
                        scaffoldMessengerKey.currentState?.showSnackBar(
                          SnackBar(
                            content: const Row(
                              children: [
                                Icon(
                                  Icons.check_circle_outline,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Đã lưu giao dịch thành công lên Đám mây!',
                                ),
                              ],
                            ),
                            backgroundColor: Colors.green.shade600,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );

                        // 4. XOÁ TRẮNG DỮ LIỆU TRÊN FORM (CLEAN FORM)
                        _formKey.currentState!
                            .reset(); // Reset trạng thái validation của Form
                        _amountController.clear(); // Xóa chữ trong ô nhập tiền
                        _noteController.clear(); // Xóa chữ trong ô ghi chú
                        setState(() {
                          _transactionType =
                              'expense'; // Đưa loại về mặc định: Chi tiêu
                          _selectedCategoryId = null; // Xóa danh mục đã chọn
                          _selectedDate = DateTime.now(); // Đưa ngày về hôm nay
                        });

                        // 5. Quay lại màn hình chính Dashboard
                        Navigator.pop(context);
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    'Lưu Giao Dịch',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

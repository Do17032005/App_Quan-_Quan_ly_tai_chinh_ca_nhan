import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../data/models/category_model.dart';
import '../../data/models/transaction_model.dart';
import '../../providers/finance_provider.dart';

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
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.8,
              child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 50,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),

                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: [
                        Colors.blue.shade700,
                        Colors.blue.shade400,
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.white24,
                        child: Icon(
                          Icons.category,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Quản lý danh mục",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Thêm hoặc xoá danh mục",
                            style: TextStyle(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                TextField(
                  controller: catNameController,
                  decoration: InputDecoration(
                    hintText: "Nhập tên danh mục...",
                    prefixIcon: const Icon(Icons.edit_outlined),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        showCheckmark: false,
                        avatar: const Icon(
                          Icons.arrow_upward,
                          color: Colors.red,
                          size: 18,
                        ),
                        label: const Text("Khoản chi"),
                        selected: selectedType == 'expense',
                        selectedColor: Colors.red.shade100,
                        onSelected: (_) {
                          setModalState(() {
                            selectedType = 'expense';
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ChoiceChip(
                        showCheckmark: false,
                        avatar: const Icon(
                          Icons.arrow_downward,
                          color: Colors.green,
                          size: 18,
                        ),
                        label: const Text("Khoản thu"),
                        selected: selectedType == 'income',
                        selectedColor: Colors.green.shade100,
                        onSelected: (_) {
                          setModalState(() {
                            selectedType = 'income';
                          });
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: Text(
                      isSubmitting
                          ? "ĐANG THÊM..."
                          : "THÊM DANH MỤC",
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () async {
                      if (isSubmitting) return;

                      final name = catNameController.text.trim();

                      if (name.isEmpty) return;

                      setModalState(() {
                        isSubmitting = true;
                      });

                      try {
                        await financeProvider.addCustomCategory(
                          name,
                          selectedType,
                        );

                        catNameController.clear();

                        if (context.mounted) {
                          Navigator.pop(context);

                          ScaffoldMessenger.of(this.context)
                              .showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.green,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(12),
                              ),
                              content: const Row(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    'Đã thêm danh mục mới!',
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                      } finally {
                        if (context.mounted) {
                          setModalState(() {
                            isSubmitting = false;
                          });
                        }
                      }
                    },
                  ),
                ),

                const SizedBox(height: 24),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Danh mục hiện có",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Expanded(
                  child: Consumer<FinanceProvider>(
                    builder: (context, provider, child) {
                      final categories = provider.categories;

                      if (categories.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Text(
                              "Chưa có danh mục nào",
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.only(bottom: 20),
                        shrinkWrap: true,
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          final isSystem =
                              category.userId == null;

                          return Card(
                            elevation: 1,
                            margin:
                            const EdgeInsets.only(bottom: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(14),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor:
                                category.type == 'expense'
                                    ? Colors.red.shade50
                                    : Colors.green.shade50,
                                child: Icon(
                                  category.type == 'expense'
                                      ? Icons.arrow_upward
                                      : Icons.arrow_downward,
                                  color:
                                  category.type == 'expense'
                                      ? Colors.red
                                      : Colors.green,
                                ),
                              ),
                              title: Text(
                                category.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                category.type == 'expense'
                                    ? 'Khoản chi'
                                    : 'Khoản thu',
                              ),
                              trailing: isSystem
                                  ? const Icon(
                                Icons.lock_outline,
                                color: Colors.grey,
                              )
                                  : IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                ),
                                onPressed: () async {
                                  if (category.id == null)
                                    return;

                                  await financeProvider
                                      .deleteCustomCategory(
                                    category.id!,
                                  );
                                },
                              ),
                            ),
                          );
                        },
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
        backgroundColor: Colors.lightBlueAccent,
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
                        // 3. HIỂN THỊ THÔNG BÁO NỔI (SnackBar) THÀNH CÔNG ĐẸP MẮT
                        ScaffoldMessenger.of(context).showSnackBar(
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
                            duration: const Duration(
                              seconds: 2,
                            ), // Biến mất sau 2 giây
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

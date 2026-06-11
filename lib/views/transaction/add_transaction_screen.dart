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
  CategoryModel? _selectedCategory;
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
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
        title: const Text('Thêm Giao Dịch', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
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
                        color: _transactionType == 'expense' ? Colors.red : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _transactionType = 'expense';
                            _selectedCategory = null; // Reset lại danh mục đã chọn
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
                        color: _transactionType == 'income' ? Colors.green : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _transactionType = 'income';
                            _selectedCategory = null; // Reset lại danh mục đã chọn
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
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  labelText: 'Số tiền',
                  hintText: '0',
                  prefixIcon: const Icon(Icons.monetization_on, color: Colors.orange),
                  suffixText: 'đ',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                value: _selectedCategory,
                hint: const Text('Chọn danh mục chi tiêu/thu nhập'),
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                    _selectedCategory = newValue;
                  });
                },
                validator: (value) => value == null ? 'Vui lòng chọn danh mục' : null,
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
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.calendar_today, color: Colors.teal),
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
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                      // Tạo đối tượng Transaction từ dữ liệu form nhập vào
                      final newTx = TransactionModel(
                        amount: double.parse(_amountController.text),
                        type: _transactionType,
                        categoryId: _selectedCategory!.id!,
                        date: _selectedDate,
                        note: _noteController.text.trim(),
                      );

                      // Gọi Provider để ghi trực tiếp xuống SQLite
                      await financeProvider.addTransaction(newTx);

                      // Hiển thị thông báo thành công và quay lại màn hình chính
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Đã lưu giao dịch thành công!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        Navigator.pop(context);
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                  ),
                  child: const Text('Lưu Giao Dịch', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
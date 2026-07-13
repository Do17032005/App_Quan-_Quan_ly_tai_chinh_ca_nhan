import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../data/models/category_model.dart';
import '../../data/models/transaction_model.dart';
import '../../providers/finance_provider.dart';
import '../../utils/icon_utils.dart';
import '../../main.dart';
import '../../providers/settings_provider.dart';
import '../category/category_management_screen.dart'; // Import màn hình quản lý danh mục
import 'widgets/numeric_calculator_keyboard.dart';

class AddTransactionScreen extends StatefulWidget {
  final TransactionModel? initialTransaction;
  const AddTransactionScreen({Key? key, this.initialTransaction}) : super(key: key);

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  late String _transactionType;
  String? _selectedCategoryId;
  String? _categoryError;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    if (widget.initialTransaction != null) {
      _transactionType = widget.initialTransaction!.type;
      _amountController.text = widget.initialTransaction!.amount.toInt().toString();
      _noteController.text = widget.initialTransaction!.note;
      _selectedCategoryId = widget.initialTransaction!.categoryId;
      _selectedDate = DateTime.now(); // Copy thường dùng cho ngày hiện tại
    } else {
      _transactionType = 'expense';
      _amountController.text = '0';
      _selectedDate = DateTime.now();
    }
    _amountController.addListener(_onAmountChanged);
  }

  void _onAmountChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _amountController.removeListener(_onAmountChanged);
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _showNumericKeyboard() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => NumericCalculatorKeyboard(
        controller: _amountController,
        onOk: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final financeProvider = Provider.of<FinanceProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    List<CategoryModel> filteredCategories = financeProvider.categories
        .where((cat) => cat.type == _transactionType)
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.grey),
          onPressed: () => Navigator.pop(context),
        ),
        title: Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTypeTab('Tiền chi', 'expense'),
              _buildTypeTab('Tiền thu', 'income'),
            ],
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.lightBlueAccent),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CategoryManagementScreen(initialType: _transactionType),
                ),
              );
            },
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
              // Ngày
              Row(
                children: [
                  const Text('Ngày', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left, color: Colors.blue),
                            onPressed: () {
                              setState(() {
                                _selectedDate = _selectedDate.subtract(const Duration(days: 1));
                              });
                            },
                          ),
                          GestureDetector(
                            onTap: () async {
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: _selectedDate,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2030),
                              );
                              if (pickedDate != null) {
                                setState(() => _selectedDate = pickedDate);
                              }
                            },
                            child: Text(
                              "${DateFormat('dd/MM/yyyy').format(_selectedDate)} (${_getWeekdayName(_selectedDate)})",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_right, color: Colors.blue),
                            onPressed: () {
                              setState(() {
                                _selectedDate = _selectedDate.add(const Duration(days: 1));
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Ghi chú
              Row(
                children: [
                  const Icon(Icons.notes, color: Colors.grey, size: 20),
                  const SizedBox(width: 12),
                  const Text('Ghi chú', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _noteController,
                      decoration: InputDecoration(
                        hintText: _transactionType == 'expense' 
                          ? 'Nhập ghi chú cho khoản chi này...' 
                          : 'Nhập ghi chú cho khoản thu này...',
                        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(),
              // Tiền chi/thu
              Row(
                children: [
                  Text(_transactionType == 'expense' ? 'Tiền chi' : 'Tiền thu', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: _showNumericKeyboard,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Text(
                              _formatAmount(_amountController.text),
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: _transactionType == 'expense' ? Colors.red : Colors.green,
                              ),
                            ),
                            const Spacer(),
                            Text(settingsProvider.currency == 'USD' ? '\$' : 'đ', style: const TextStyle(fontSize: 16)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text('Danh mục', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.2,
                ),
                itemCount: filteredCategories.length + 1,
                itemBuilder: (context, index) {
                  if (index == filteredCategories.length) {
                    return _buildCategoryItem(
                      icon: Icons.chevron_right,
                      label: 'Chỉnh sửa',
                      color: Colors.grey,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CategoryManagementScreen(initialType: _transactionType),
                          ),
                        );
                      },
                    );
                  }
                  final cat = filteredCategories[index];
                  final isSelected = _selectedCategoryId == cat.id;
                  return _buildCategoryItem(
                    icon: IconUtils.getIconData(cat.iconName),
                    label: cat.name,
                    color: Color(cat.colorValue),
                    isSelected: isSelected,
                    onTap: () => setState(() => _selectedCategoryId = cat.id),
                  );
                },
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveTransaction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlueAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  child: Text(
                    _transactionType == 'expense' ? 'Nhập khoản chi' : 'Nhập khoản thu',
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeTab(String label, String type) {
    bool isSelected = _transactionType == type;
    return GestureDetector(
      onTap: () => setState(() {
        _transactionType = type;
        _selectedCategoryId = null;
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
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

  Widget _buildCategoryItem({
    required IconData icon,
    required String label,
    required Color color,
    bool isSelected = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: isSelected ? color : Colors.grey.shade200),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: isSelected ? color : Colors.black),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  String _getWeekdayName(DateTime date) {
    switch (date.weekday) {
      case 1: return 'Thứ Hai';
      case 2: return 'Thứ Ba';
      case 3: return 'Thứ Tư';
      case 4: return 'Thứ Năm';
      case 5: return 'Thứ Sáu';
      case 6: return 'Thứ Bảy';
      case 7: return 'Chủ Nhật';
      default: return '';
    }
  }

  String _formatAmount(String text) {
    if (text.isEmpty) return '0';
    try {
      final number = double.parse(text);
      final formatter = NumberFormat('#,###', 'vi_VN');
      return formatter.format(number);
    } catch (e) {
      return text;
    }
  }

  Future<void> _saveTransaction() async {
    if (_amountController.text.isEmpty || _amountController.text == '0') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập số tiền')),
      );
      return;
    }
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn danh mục')),
      );
      return;
    }

    final financeProvider = Provider.of<FinanceProvider>(context, listen: false);
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    
    // Đảm bảo số tiền luôn dương trong DB, logic âm/dương sẽ do field 'type' quyết định
    double amount = double.tryParse(_amountController.text) ?? 0;
    if (amount < 0) amount = amount.abs();

    if (_transactionType == 'expense' && settingsProvider.isBudgetAlertEnabled && settingsProvider.budgetLimit > 0) {
      final totalExpense = financeProvider.totalExpense;
      if (totalExpense + amount > settingsProvider.budgetLimit) {
        bool? confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Cảnh báo ngân sách', style: TextStyle(color: Colors.red)),
            content: Text('Khoản chi này sẽ làm tổng chi tiêu vượt hạn mức (${settingsProvider.currencyFormat.format(settingsProvider.budgetLimit)}). Bạn có chắc chắn muốn tiếp tục?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Tiếp tục', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
        if (confirm != true) return;
      }
    }

    final newTx = TransactionModel(
      amount: amount,
      type: _transactionType,
      categoryId: _selectedCategoryId!,
      date: _selectedDate,
      note: _noteController.text.trim(),
    );

    await financeProvider.addTransaction(newTx);
    if (mounted) Navigator.pop(context);
  }
}

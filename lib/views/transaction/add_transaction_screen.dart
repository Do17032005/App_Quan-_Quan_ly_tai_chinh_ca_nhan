import 'package:app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../data/models/category_model.dart';
import '../../data/models/transaction_model.dart';
import '../../providers/finance_provider.dart';
import '../../utils/icon_utils.dart';
import '../../providers/settings_provider.dart';
import '../category/category_management_screen.dart'; // Import màn hình quản lý danh mục
import 'widgets/numeric_calculator_keyboard.dart';

class AddTransactionScreen extends StatefulWidget {
  final TransactionModel? initialTransaction;
  const AddTransactionScreen({super.key, this.initialTransaction});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  late String _transactionType;
  String? _selectedCategoryId;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settings = Provider.of<SettingsProvider>(context, listen: false);
      if (widget.initialTransaction != null) {
        setState(() {
          _amountController.text = settings.convertToDisplay(widget.initialTransaction!.amount).toInt().toString();
        });
      }
    });
    if (widget.initialTransaction != null) {
      _transactionType = widget.initialTransaction!.type;
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
              _buildTypeTab(AppLocalizations.of(context)?.expense ?? 'Chi tiêu', 'expense'),
              _buildTypeTab(AppLocalizations.of(context)?.income ?? 'Thu nhập', 'income'),
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
                  Text(AppLocalizations.of(context)?.date ?? 'Ngày', style: const TextStyle(fontSize: 16)),
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
                              "${DateFormat.yMd(Localizations.localeOf(context).toString()).format(_selectedDate)} (${_getWeekdayName(_selectedDate)})",
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
                  Text(AppLocalizations.of(context)?.note ?? 'Ghi chú', style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _noteController,
                      decoration: InputDecoration(
                        hintText: _transactionType == 'expense' 
                          ? (AppLocalizations.of(context)?.noteHintExpense ?? 'Nhập ghi chú cho khoản chi này...') 
                          : (AppLocalizations.of(context)?.noteHintIncome ?? 'Nhập ghi chú cho khoản thu này...'),
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
                  Text(_transactionType == 'expense' 
                    ? (AppLocalizations.of(context)?.expense ?? 'Chi tiêu') 
                    : (AppLocalizations.of(context)?.income ?? 'Thu nhập'), 
                    style: const TextStyle(fontSize: 16)),
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
                            Text(settingsProvider.currencyFormat.currencySymbol, style: const TextStyle(fontSize: 16)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(AppLocalizations.of(context)?.category ?? 'Danh mục', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                      icon: FontAwesomeIcons.chevronRight,
                      label: AppLocalizations.of(context)?.edit ?? 'Chỉnh sửa',
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
                    _transactionType == 'expense' 
                      ? (AppLocalizations.of(context)?.enterExpense ?? 'Nhập khoản chi') 
                      : (AppLocalizations.of(context)?.enterIncome ?? 'Nhập khoản thu'),
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
    required dynamic icon,
    required String label,
    required Color color,
    bool isSelected = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          border: Border.all(color: isSelected ? color : Colors.grey.shade200),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon is FaIconData 
              ? FaIcon(icon, color: color, size: 24)
              : (icon is IconData ? Icon(icon, color: color, size: 24) : const SizedBox()),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? color : Colors.black,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
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
    return DateFormat.EEEE(Localizations.localeOf(context).toString()).format(date);
  }

  String _formatAmount(String text) {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    if (_amountController.text.isEmpty || _amountController.text == '0') {
      return settings.formatAmount(0);
    }
    double amount = double.tryParse(_amountController.text) ?? 0;
    return settings.formatAmount(settings.convertToVND(amount));
  }

  Future<void> _saveTransaction() async {
    final l10n = AppLocalizations.of(context);
    if (_amountController.text.isEmpty || _amountController.text == '0') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n?.pleaseEnterAmount ?? 'Vui lòng nhập số tiền')),
      );
      return;
    }
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n?.pleaseSelectCategory ?? 'Vui lòng chọn danh mục')),
      );
      return;
    }

    final financeProvider = Provider.of<FinanceProvider>(context, listen: false);
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    
    // Đảm bảo số tiền luôn dương trong DB, logic âm/dương sẽ do field 'type' quyết định
    double amount = double.tryParse(_amountController.text) ?? 0;
    if (amount < 0) amount = amount.abs();
    amount = settingsProvider.convertToVND(amount);

    if (_transactionType == 'expense' && settingsProvider.isBudgetAlertEnabled && settingsProvider.budgetLimit > 0) {
      final totalExpense = financeProvider.totalExpense;
      if (totalExpense + amount > settingsProvider.budgetLimit) {
        bool? confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n?.budgetWarning ?? 'Cảnh báo ngân sách', style: const TextStyle(color: Colors.red)),
            content: Text(l10n?.budgetWarningDesc(settingsProvider.formatAmount(settingsProvider.budgetLimit)) ?? 'Khoản chi này sẽ làm tổng chi tiêu vượt hạn mức (${settingsProvider.formatAmount(settingsProvider.budgetLimit)}). Bạn có chắc chắn muốn tiếp tục?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l10n?.cancel ?? 'Hủy'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(l10n?.continueText ?? 'Tiếp tục', style: const TextStyle(color: Colors.red)),
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
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.white),
              const SizedBox(width: 12),
              Text(l10n?.transactionAdded ?? 'Đã thêm dữ liệu'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      Navigator.pop(context);
    }
  }
}

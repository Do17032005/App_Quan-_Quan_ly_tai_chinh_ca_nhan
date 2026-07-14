import 'package:app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../data/models/category_model.dart';
import '../../data/models/transaction_model.dart';
import '../../providers/finance_provider.dart';
import '../../providers/settings_provider.dart';
import '../../utils/icon_utils.dart';
import 'add_transaction_screen.dart';
import 'widgets/numeric_calculator_keyboard.dart';

class EditTransactionScreen extends StatefulWidget {
  final TransactionModel transaction;
  const EditTransactionScreen({super.key, required this.transaction});

  @override
  State<EditTransactionScreen> createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
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
      setState(() {
        _amountController.text = settings.convertToDisplay(widget.transaction.amount).toInt().toString();
      });
    });
    _transactionType = widget.transaction.type;
    _noteController.text = widget.transaction.note;
    _selectedCategoryId = widget.transaction.categoryId;
    _selectedDate = widget.transaction.date;
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
    final l10n = AppLocalizations.of(context)!;
    final financeProvider = Provider.of<FinanceProvider>(context);
    final settings = Provider.of<SettingsProvider>(context);
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
        title: Text(
          _transactionType == 'expense' ? l10n.editExpense : l10n.editIncome,
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.copy, color: Colors.blue),
            onPressed: _copyTransaction,
            tooltip: l10n.copy,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: _confirmDelete,
            tooltip: l10n.delete,
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
                  Text(l10n.date, style: const TextStyle(fontSize: 16)),
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
                              "${DateFormat.yMd(Localizations.localeOf(context).toString()).format(_selectedDate)} (${_getWeekdayName(_selectedDate, l10n)})",
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
                  Text(l10n.note, style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _noteController,
                      decoration: InputDecoration(
                        hintText: _transactionType == 'expense' 
                          ? l10n.noteHintExpense 
                          : l10n.noteHintIncome,
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
                  Text(_transactionType == 'expense' ? l10n.expense : l10n.income, style: const TextStyle(fontSize: 16)),
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
                            Text(settings.currencyFormat.currencySymbol, style: const TextStyle(fontSize: 16)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(l10n.category, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                itemCount: filteredCategories.length,
                itemBuilder: (context, index) {
                  final cat = filteredCategories[index];
                  final isSelected = _selectedCategoryId == cat.id;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategoryId = cat.id),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? Color(cat.colorValue).withOpacity(0.1) : Colors.transparent,
                        border: Border.all(color: isSelected ? Color(cat.colorValue) : Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FaIcon(
                            IconUtils.getIconData(cat.iconName),
                            color: Color(cat.colorValue),
                            size: 24,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            cat.name,
                            style: TextStyle(
                              fontSize: 12,
                              color: isSelected ? Color(cat.colorValue) : Colors.black,
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
                },
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _updateTransaction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  child: Text(
                    l10n.saveChanges,
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

  String _getWeekdayName(DateTime date, AppLocalizations l10n) {
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

  Future<void> _updateTransaction() async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    if (_amountController.text.isEmpty || _amountController.text == '0') {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.pleaseEnterAmount)),
      );
      return;
    }
    if (_selectedCategoryId == null) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.pleaseSelectCategory)),
      );
      return;
    }

    final financeProvider = Provider.of<FinanceProvider>(context, listen: false);
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    double amount = double.tryParse(_amountController.text) ?? 0;
    amount = settingsProvider.convertToVND(amount);
    
    final updatedTx = TransactionModel(
      id: widget.transaction.id,
      documentId: widget.transaction.documentId,
      amount: amount.abs(),
      type: _transactionType,
      categoryId: _selectedCategoryId!,
      date: _selectedDate,
      note: _noteController.text.trim(),
    );

    if (widget.transaction.documentId != null) {
      await financeProvider.updateTransaction(widget.transaction.documentId!, updatedTx);
    }

    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 12),
            Text(l10n.transactionUpdated),
          ],
        ),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
    
    navigator.pop();
  }

  void _confirmDelete() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmDelete),
        content: Text(l10n.confirmDeleteTransaction),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);
              final financeProvider = Provider.of<FinanceProvider>(context, listen: false);
              if (widget.transaction.documentId != null) {
                await financeProvider.deleteTransaction(widget.transaction.documentId!);
              }

              messenger.showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.delete_sweep, color: Colors.white),
                      const SizedBox(width: 12),
                      Text(l10n.transactionDeleted),
                    ],
                  ),
                  backgroundColor: Colors.redAccent,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );

              navigator.pop(); // Đóng dialog
              navigator.pop(); // Quay lại màn hình trước đó
            },
            child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _copyTransaction() {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTransactionScreen(
          initialTransaction: TransactionModel(
            amount: settingsProvider.convertToVND(double.tryParse(_amountController.text) ?? 0),
            type: _transactionType,
            categoryId: _selectedCategoryId!,
            date: DateTime.now(),
            note: _noteController.text.trim(),
          ),
        ),
      ),
    );
  }
}

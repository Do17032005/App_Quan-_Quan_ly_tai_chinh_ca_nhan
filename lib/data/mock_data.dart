import 'models/category_model.dart';
import 'models/transaction_model.dart';

// Danh mục giả lập
final List<CategoryModel> mockCategories = [
  CategoryModel(
    id: '1',
    name: 'Ăn uống',
    type: 'expense',
    iconName: 'utensils',
  ),
  CategoryModel(id: '2', name: 'Di chuyển', type: 'expense', iconName: 'car'),
  CategoryModel(id: '3', name: 'Lương', type: 'income', iconName: 'money-bill'),
  CategoryModel(
    id: '4',
    name: 'Mua sắm',
    type: 'expense',
    iconName: 'shopping-bag',
  ),
];

// Giao dịch giả lập
final List<TransactionModel> mockTransactions = [
  TransactionModel(
    id: 1,
    amount: 5000000,
    type: 'income',
    categoryId: '3',
    date: DateTime.now(),
    note: 'Lương tháng này',
  ),
  TransactionModel(
    id: 2,
    amount: 50000,
    type: 'expense',
    categoryId: '1',
    date: DateTime.now(),
    note: 'Ăn phở sáng',
  ),
  TransactionModel(
    id: 3,
    amount: 120000,
    type: 'expense',
    categoryId: '4',
    date: DateTime.now().subtract(Duration(days: 1)),
    note: 'Mua áo thun',
  ),
  TransactionModel(
    id: 4,
    amount: 30000,
    type: 'expense',
    categoryId: '2',
    date: DateTime.now().subtract(Duration(days: 1)),
    note: 'Đổ xăng',
  ),
];

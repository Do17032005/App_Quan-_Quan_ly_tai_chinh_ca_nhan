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
  CategoryModel(
    id: '3',
    name: 'Mua sắm',
    type: 'expense',
    iconName: 'shopping-bag',
  ),
  CategoryModel(
    id: '4',
    name: 'Giải trí',
    type: 'expense',
    iconName: 'gamepad',
  ),
  CategoryModel(
    id: '5',
    name: 'Tiền lương',
    type: 'income',
    iconName: 'money-bill',
  ),
  CategoryModel(id: '6', name: 'Thưởng', type: 'income', iconName: 'gift'),
  CategoryModel(
    id: '7',
    name: 'Tiền làm thêm',
    type: 'income',
    iconName: 'laptop-code',
  ),
];

// Giao dịch giả lập
final List<TransactionModel> mockTransactions = [
  TransactionModel(
    id: 1,
    amount: 5000000,
    type: 'income',
    categoryId: '5',
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
    categoryId: '3',
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

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../data/models/category_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/finance_provider.dart';
import '../../utils/icon_utils.dart';
import '../calendar/calendar_screen.dart';
import '../transaction/all_transactions_screen.dart';
import '../transaction/add_transaction_screen.dart';
import '../transaction/edit_transaction_screen.dart';
import '../statistics/statistics_screen.dart';
import '../settings/settings_screen.dart';
import '../../providers/settings_provider.dart';
import 'package:app/l10n/app_localizations.dart';
import 'widgets/balance_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      DashboardHomeContent(onSeeAll: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AllTransactionsScreen()),
        );
      }),
      const StatisticsScreen(),
      const CalendarScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: screens[_currentIndex],

      // Nút tròn nổi (+) chỉ hiển thị nếu không phải màn hình Cài đặt (index 3)
      floatingActionButton: _currentIndex == 3
          ? null
          : FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddTransactionScreen(),
                  ),
                );
              },
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
              shape: const CircleBorder(),
              child: const Icon(Icons.add, size: 28),
            ),

      // Đặt nút nổi ở giữa nhưng nhấc lên khỏi thanh điều hướng để tránh sát tab Thống kê
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed, // Giữ style cũ khi có >3 items
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Colors.blue.shade700,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.home), label: AppLocalizations.of(context)?.dashboard ?? 'Trang chủ'),
          BottomNavigationBarItem(
            icon: const Icon(Icons.pie_chart),
            label: AppLocalizations.of(context)?.statistics ?? 'Thống kê',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Lịch', // Có thể thêm vào arb sau
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: AppLocalizations.of(context)?.settings ?? 'Cài đặt',
          ),
        ],
      ),
    );
  }
}

class DashboardHomeContent extends StatelessWidget {
  final VoidCallback? onSeeAll;
  const DashboardHomeContent({super.key, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final isHidden = settings.isBalanceHidden;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)?.appTitle ?? 'Quản Lý Thu Chi',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      // Sử dụng Consumer để tự động cập nhật UI khi dữ liệu trong FinanceProvider thay đổi
      body: Consumer<FinanceProvider>(
        builder: (context, financeProvider, child) {
          // Lấy 5 giao dịch gần nhất
          final recentTransactions = financeProvider.transactions.length > 5 
              ? financeProvider.transactions.sublist(0, 5) 
              : financeProvider.transactions;
          
          // Sử dụng memoization đơn giản cho categoryMap nếu danh sách categories không đổi
          final categoryMap = {
            for (var cat in financeProvider.categories) cat.id: cat
          };

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Thẻ số dư hiển thị dữ liệu thật từ Provider
                BalanceCard(
                  totalIncome: financeProvider.totalIncome,
                  totalExpense: financeProvider.totalExpense,
                ),
                const SizedBox(height: 24),

                // Tiêu đề danh sách với nút Xem tất cả
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context)?.recentTransactions ?? 'Giao dịch gần đây',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: onSeeAll,
                      child: Text(AppLocalizations.of(context)?.viewAll ?? 'Xem tất cả'),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // 2. Danh sách giao dịch (Sử dụng ListView.separated để UI sạch sẽ hơn)
                Expanded(
                  child: recentTransactions.isEmpty
                      ? Center(
                          child: Text(
                            AppLocalizations.of(context)?.noTransactions ?? 'Chưa có giao dịch nào.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: recentTransactions.length,
                          itemBuilder: (context, index) {
                            final tx = recentTransactions[index];
                            final category = categoryMap[tx.categoryId] ?? CategoryModel(
                                id: '0',
                                name: 'Khác',
                                type: 'expense',
                                iconName: 'help',
                                colorValue: 0xFF9E9E9E,
                              );
                            final isIncome = tx.type == 'income';

                            return Dismissible(
                              key: Key(tx.documentId ?? tx.id.toString()),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                ),
                              ),
                              confirmDismiss: (direction) async {
                                return await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Xác nhận xóa'),
                                    content: const Text(
                                      'Bạn có chắc chắn muốn xóa giao dịch này không?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(false),
                                        child: const Text('Hủy'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(true),
                                        child: const Text(
                                          'Xóa',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              onDismissed: (direction) async {
                                if (tx.documentId != null) {
                                  await financeProvider.deleteTransaction(
                                    tx.documentId!,
                                  );
                                }

                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: [
                                          const Icon(Icons.delete_sweep, color: Colors.white),
                                          const SizedBox(width: 12),
                                          const Text('Đã xóa giao dịch'),
                                        ],
                                      ),
                                      backgroundColor: Colors.redAccent,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                }
                              },
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          EditTransactionScreen(
                                            transaction: tx,
                                          ),
                                    ),
                                  );
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 6,
                                  ),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.1),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: Color(
                                          category.colorValue,
                                        ).withOpacity(0.1),
                                        child: FaIcon(
                                          IconUtils.getIconData(
                                            category.iconName,
                                          ),
                                          color: Color(category.colorValue),
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      // Phần thân: Tên danh mục và Ghi chú
                                      Expanded(
                                        flex: 3,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              category.name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            if (tx.note.isNotEmpty)
                                              Text(
                                                tx.note,
                                                style: TextStyle(
                                                  color: Colors.grey.shade600,
                                                  fontSize: 13,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                          ],
                                        ),
                                      ),
                                      // Phần đuôi: Số tiền và Ngày tháng
                                      const SizedBox(width: 8),
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              isHidden ? '******' : '${isIncome ? '+' : '-'}${settings.formatAmount(tx.amount)}',
                                              style: TextStyle(
                                                color: isIncome
                                                    ? Colors.green
                                                    : Colors.red,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            Text(
                                              DateFormat(
                                                'dd/MM HH:mm',
                                              ).format(tx.date),
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

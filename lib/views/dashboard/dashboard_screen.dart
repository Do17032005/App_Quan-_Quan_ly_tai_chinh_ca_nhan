import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../data/models/category_model.dart';
import '../../providers/finance_provider.dart';
import '../transaction/add_transaction_screen.dart';
import 'widgets/balance_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản Lý Thu Chi', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      // Sử dụng Consumer để tự động cập nhật UI khi dữ liệu trong FinanceProvider thay đổi
      body: Consumer<FinanceProvider>(
        builder: (context, financeProvider, child) {
          final transactions = financeProvider.transactions;
          final categories = financeProvider.categories;

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
                
                // Tiêu đề danh sách
                const Text(
                  'Giao dịch gần đây',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                // 2. Danh sách giao dịch thật từ SQLite
                Expanded(
                  child: transactions.isEmpty
                      ? const Center(
                          child: Text(
                            'Chưa có giao dịch nào.\nẤn nút + để thêm giao dịch đầu tiên!',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          itemCount: transactions.length,
                          itemBuilder: (context, index) {
                            final tx = transactions[index];
                            
                            // Tìm danh mục tương ứng từ DB để lấy tên danh mục hiển thị
                            final category = categories.firstWhere(
                              (cat) => cat.id == tx.categoryId,
                              orElse: () => CategoryModel(id: 0, name: 'Khác', type: 'expense', iconName: 'help'),
                            );
                            
                            final isIncome = tx.type == 'income';

                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              elevation: 1,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: isIncome ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                                  child: Icon(
                                    isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                                    color: isIncome ? Colors.green : Colors.red,
                                  ),
                                ),
                                title: Text(
                                  tx.note.isEmpty ? category.name : tx.note,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(DateFormat('dd/MM/yyyy HH:mm').format(tx.date)),
                                trailing: Text(
                                  '${isIncome ? '+' : '-'}${currencyFormat.format(tx.amount)}',
                                  style: TextStyle(
                                    color: isIncome ? Colors.green : Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
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
      // 3. Nút chuyển sang màn hình thêm giao dịch
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTransactionScreen()),
          );
        },
        backgroundColor: Colors.blue.shade600,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
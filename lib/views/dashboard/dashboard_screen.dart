import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/mock_data.dart';
import 'widgets/balance_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Tính toán sơ bộ từ mock data
    double totalIncome = 5000000;
    double totalExpense = 200000;
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản Lý Thu Chi', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thẻ số dư
            BalanceCard(totalIncome: totalIncome, totalExpense: totalExpense),
            const SizedBox(height: 24),
            
            // Tiêu đề danh sách
            const Text(
              'Giao dịch gần đây',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Danh sách giao dịch
            Expanded(
              child: ListView.builder(
                itemCount: mockTransactions.length,
                itemBuilder: (context, index) {
                  final tx = mockTransactions[index];
                  // Tìm danh mục tương ứng để lấy tên
                  final category = mockCategories.firstWhere((cat) => cat.id == tx.categoryId);
                  final isIncome = tx.type == 'income';

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isIncome ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                        child: Icon(
                          isIncome ? Icons.account_balance_wallet : Icons.shopping_bag,
                          color: isIncome ? Colors.green : Colors.red,
                        ),
                      ),
                      title: Text(tx.note.isEmpty ? category.name : tx.note, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(DateFormat('dd/MM/yyyy').format(tx.date)),
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
      ),
      // Nút thêm giao dịch nhanh
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Xử lý chuyển sang màn hình thêm giao dịch sau
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.blue.shade600,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
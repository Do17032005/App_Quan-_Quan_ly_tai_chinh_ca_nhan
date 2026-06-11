import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/finance_provider.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  // Hàm phụ trách gán màu sắc ngẫu nhiên cho các nhóm danh mục chi tiêu
  Color _getCategoryColor(String categoryId) {
    switch (categoryId) {
      case '1':
        return Colors.orange; // Ăn uống
      case '2':
        return Colors.blue; // Di chuyển
      case '3':
        return Colors.pink; // Mua sắm
      case '4':
        return Colors.purple; // Giải trí
      case '5':
        return Colors.green; // Tiền lương
      case '6':
        return Colors.amber; // Thưởng
      case '7':
        return Colors.teal; // Tiền làm thêm
      default:
        return Colors.grey;
    }
  }

  String _getCategoryName(FinanceProvider financeProvider, String categoryId) {
    for (final category in financeProvider.categories) {
      if (category.id == categoryId) {
        return category.name;
      }
    }
    return 'Khác';
  }

  @override
  Widget build(BuildContext context) {
    final financeProvider = Provider.of<FinanceProvider>(context);

    // Lọc ra danh sách các giao dịch CHI TIÊU (Expense) của tài khoản này
    final expenses = financeProvider.transactions
        .where((tx) => tx.type == 'expense')
        .toList();
    final totalExpense = financeProvider.totalExpense;

    // Thuật toán: Gom nhóm tổng số tiền theo từng Category ID
    Map<String, double> categorySums = {};
    for (var tx in expenses) {
      categorySums[tx.categoryId] =
          (categorySums[tx.categoryId] ?? 0.0) + tx.amount;
    }

    // Chuyển đổi dữ liệu đã gom nhóm thành các lát cắt của Biểu đồ tròn (PieChartSectionData)
    List<PieChartSectionData> showingSections() {
      if (categorySums.isEmpty) {
        return [
          PieChartSectionData(
            color: Colors.grey.shade300,
            value: 1,
            title: 'Trống',
            radius: 50,
            titleStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
        ];
      }

      return categorySums.entries.map((entry) {
        final categoryId = entry.key;
        final amount = entry.value;
        // Tính tỷ lệ phần trăm chi tiêu của danh mục này
        final percentage = totalExpense > 0
            ? (amount / totalExpense * 100)
            : 0.0;

        // Tìm tên danh mục tương ứng từ danh sách trong Provider
        return PieChartSectionData(
          color: _getCategoryColor(categoryId),
          value: amount,
          title: '${percentage.toStringAsFixed(1)}%', // Hiển thị % trên biểu đồ
          radius: 60,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        );
      }).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Phân Tích Chi Tiêu',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: expenses.isEmpty
          ? const Center(
              child: Text('Chưa có dữ liệu chi tiêu để lập biểu đồ.'),
            )
          : Column(
              children: [
                const SizedBox(height: 20),
                // Khu vực hiển thị Biểu đồ tròn (Pie Chart)
                SizedBox(
                  height: 220,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2, // Khoảng cách giữa các lát cắt
                      centerSpaceRadius: 40, // Độ rỗng ở giữa hình tròn
                      sections: showingSections(),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Khu vực hiển thị chú thích danh sách chi tiết ở phía dưới
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: categorySums.entries.map((entry) {
                      final categoryId = entry.key;
                      final amount = entry.value;
                      final categoryName = _getCategoryName(
                        financeProvider,
                        categoryId,
                      );

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          leading: Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: _getCategoryColor(categoryId),
                              shape: BoxShape.circle,
                            ),
                          ),
                          title: Text(
                            categoryName,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          trailing: Text(
                            '-${amount.toStringAsFixed(0)} đ',
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
    );
  }
}

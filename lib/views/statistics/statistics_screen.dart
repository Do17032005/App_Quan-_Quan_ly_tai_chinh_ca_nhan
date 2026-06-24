import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../providers/finance_provider.dart';
import '../../data/models/category_model.dart';
import '../../utils/icon_utils.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  bool _isMonthly = true; // true: Hàng tháng, false: Hàng năm
  DateTime _selectedDate = DateTime.now();
  String _chartType = 'expense'; // 'expense' hoặc 'income'

  // Bộ lọc chi tiết
  String _selectedCategory = 'Tất cả';
  double? _minAmount;
  double? _maxAmount;

  // Hàm lấy màu từ model, nếu không có thì dùng màu mặc định
  Color _getCategoryColor(FinanceProvider provider, String categoryId) {
    final category = provider.categories.firstWhere(
      (cat) => cat.id == categoryId,
      orElse: () => CategoryModel(
        name: 'Khác',
        type: 'expense',
        iconName: 'category',
        colorValue: 0xFF9E9E9E,
      ),
    );
    return Color(category.colorValue);
  }

  void _previousPeriod() {
    setState(() {
      if (_isMonthly) {
        _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1);
      } else {
        _selectedDate = DateTime(_selectedDate.year - 1);
      }
    });
  }

  void _nextPeriod() {
    setState(() {
      if (_isMonthly) {
        _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1);
      } else {
        _selectedDate = DateTime(_selectedDate.year + 1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final financeProvider = Provider.of<FinanceProvider>(context);

    // 1. Lọc giao dịch theo thời gian được chọn và các bộ lọc bổ sung
    final filteredTransactions = financeProvider.transactions.where((tx) {
      // Lọc theo thời gian
      bool timeMatch;
      if (_isMonthly) {
        timeMatch = tx.date.year == _selectedDate.year &&
            tx.date.month == _selectedDate.month;
      } else {
        timeMatch = tx.date.year == _selectedDate.year;
      }
      if (!timeMatch) return false;

      // Lọc theo danh mục
      if (_selectedCategory != 'Tất cả' &&
          _getCategoryName(financeProvider, tx.categoryId) !=
              _selectedCategory) {
        return false;
      }

      // Lọc theo số tiền
      if (_minAmount != null && tx.amount < _minAmount!) return false;
      if (_maxAmount != null && tx.amount > _maxAmount!) return false;

      return true;
    }).toList();

    // 2. Tính toán các chỉ số tóm tắt
    double periodIncome = 0;
    double periodExpense = 0;
    for (var tx in filteredTransactions) {
      if (tx.type == 'income') {
        periodIncome += tx.amount;
      } else {
        periodExpense += tx.amount;
      }
    }
    double periodNet = periodIncome - periodExpense;

    // 3. Dữ liệu cho biểu đồ tròn (Pie Chart)
    final chartDataTransactions = filteredTransactions
        .where((tx) => tx.type == _chartType)
        .toList();

    Map<String, double> categorySums = {};
    for (var tx in chartDataTransactions) {
      categorySums[tx.categoryId] =
          (categorySums[tx.categoryId] ?? 0.0) + tx.amount;
    }

    var sortedEntries = categorySums.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    double totalForChart = _chartType == 'income' ? periodIncome : periodExpense;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTopTab('Hàng Tháng', _isMonthly, () => setState(() => _isMonthly = true)),
            _buildTopTab('Hàng Năm', !_isMonthly, () => setState(() => _isMonthly = false)),
          ],
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.camera_alt_outlined, color: Colors.blue),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.blue),
            onPressed: () => _showFilterDialog(financeProvider),
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.blue),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Bộ chọn thời gian (Tháng/Năm)
          Container(
            color: Colors.blue.shade50.withOpacity(0.3),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: _previousPeriod,
                  icon: const Icon(Icons.arrow_back_ios, size: 16),
                ),
                Column(
                  children: [
                    Text(
                      _isMonthly
                          ? DateFormat('MM / yyyy').format(_selectedDate)
                          : DateFormat('yyyy').format(_selectedDate),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    if (_isMonthly)
                      Text(
                        "(01/${_selectedDate.month.toString().padLeft(2, '0')} - ${DateTime(_selectedDate.year, _selectedDate.month + 1, 0).day}/${_selectedDate.month.toString().padLeft(2, '0')})",
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                  ],
                ),
                IconButton(
                  onPressed: _nextPeriod,
                  icon: const Icon(Icons.arrow_forward_ios, size: 16),
                ),
              ],
            ),
          ),

          // Bảng tóm tắt Thu/Chi (Giống hình ảnh)
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      _buildSummaryItem('Chi tiêu', periodExpense, Colors.red, isNegative: true),
                      Container(width: 1, height: 40, color: Colors.grey.shade200),
                      _buildSummaryItem('Thu nhập', periodIncome, Colors.blue),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Thu chi', style: TextStyle(color: Colors.grey)),
                      Text(
                        '${periodNet >= 0 ? '+' : ''}${NumberFormat('#,###').format(periodNet)}đ',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Tabs chuyển đổi Chi tiêu / Thu nhập
          Row(
            children: [
              _buildChartTypeTab('Chi tiêu', _chartType == 'expense', () => setState(() => _chartType = 'expense')),
              _buildChartTypeTab('Thu nhập', _chartType == 'income', () => setState(() => _chartType = 'income')),
            ],
          ),

          // Biểu đồ Donut và Danh sách
          Expanded(
            child: chartDataTransactions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.pie_chart_outline, size: 80, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text('Không có dữ liệu ${_chartType == 'expense' ? 'chi tiêu' : 'thu nhập'}',
                            style: TextStyle(color: Colors.grey.shade500)),
                      ],
                    ),
                  )
                : ListView(
                    children: [
                      const SizedBox(height: 20),
                      // Biểu đồ tròn
                      SizedBox(
                        height: 220,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            PieChart(
                              PieChartData(
                                sectionsSpace: 0,
                                centerSpaceRadius: 70,
                                startDegreeOffset: -90,
                                sections: sortedEntries.map((entry) {
                                  return PieChartSectionData(
                                    color: _getCategoryColor(financeProvider, entry.key),
                                    value: entry.value,
                                    title: '',
                                    radius: 50,
                                  );
                                }).toList(),
                              ),
                            ),
                            // Text ở giữa biểu đồ
                            if (sortedEntries.isNotEmpty)
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _getCategoryName(financeProvider, sortedEntries.first.key),
                                    style: TextStyle(
                                      color: _getCategoryColor(financeProvider, sortedEntries.first.key),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Danh sách phân tích
                      ...sortedEntries.map((entry) {
                        final categoryId = entry.key;
                        final amount = entry.value;
                        final percentage = totalForChart > 0 ? (amount / totalForChart * 100) : 0;
                        final category = financeProvider.categories.firstWhere(
                          (cat) => cat.id == categoryId,
                          orElse: () => CategoryModel(
                            name: 'Khác',
                            type: _chartType,
                            iconName: 'category',
                            colorValue: 0xFF9E9E9E,
                          ),
                        );

                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: _getCategoryColor(financeProvider, categoryId).withOpacity(0.1),
                                child: Icon(IconUtils.getIconData(category.iconName), color: _getCategoryColor(financeProvider, categoryId), size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  category.name,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${NumberFormat('#,###').format(amount)}đ',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                  Text(
                                    '${percentage.toStringAsFixed(1)} %',
                                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopTab(String title, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.blue),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.blue,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, double amount, Color color, {bool isNegative = false}) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 4),
          Text(
            '${isNegative ? '-' : '+'}${NumberFormat('#,###').format(amount)}đ',
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildChartTypeTab(String title, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.blue : Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              height: 2,
              color: isSelected ? Colors.blue : Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }

  String _getCategoryName(FinanceProvider financeProvider, String categoryId) {
    for (final category in financeProvider.categories) {
      if (category.id == categoryId) {
        return category.name;
      }
    }
    return 'Khác';
  }

  void _showFilterDialog(FinanceProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 20,
              right: 20,
              top: 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Bộ lọc chi tiết',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedCategory = 'Tất cả';
                          _minAmount = null;
                          _maxAmount = null;
                        });
                        Navigator.pop(context);
                      },
                      child: const Text('Đặt lại'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text('Danh mục',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                DropdownButton<String>(
                  isExpanded: true,
                  value: _selectedCategory,
                  items: [
                    'Tất cả',
                    ...provider.categories.map((e) => e.name).toSet()
                  ].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setModalState(() => _selectedCategory = val);
                    }
                  },
                ),
                const SizedBox(height: 20),
                const Text('Khoảng giá (đ)',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(hintText: 'Từ'),
                        keyboardType: TextInputType.number,
                        onChanged: (val) => _minAmount = double.tryParse(val),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(hintText: 'Đến'),
                        keyboardType: TextInputType.number,
                        onChanged: (val) => _maxAmount = double.tryParse(val),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {});
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: const Text('Áp dụng',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        });
      },
    );
  }
}

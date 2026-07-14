import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:app/l10n/app_localizations.dart';
import '../../providers/finance_provider.dart';
import '../../providers/settings_provider.dart';
import '../../data/models/category_model.dart';
import '../../utils/icon_utils.dart';
import '../transaction/edit_transaction_screen.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  bool _isMonthly = true; // true: Hàng tháng, false: Hàng năm
  DateTime _selectedDate = DateTime.now();
  String _chartType = 'expense'; // 'expense' hoặc 'income'

  // Tìm kiếm
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Bộ lọc chi tiết
  String _selectedCategory = 'Tất cả';
  double? _minAmount;
  double? _maxAmount;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FinanceProvider>(context, listen: false).fetchAllTransactionsForStats();
    });
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
    final settings = Provider.of<SettingsProvider>(context);

    final l10n = AppLocalizations.of(context)!;

    // 1. Lọc giao dịch theo thời gian được chọn và các bộ lọc bổ sung
    final Map<String, CategoryModel> categoryMap = {
      for (var cat in financeProvider.categories) cat.id ?? '': cat
    };

    // 1. Lọc giao dịch
    final filteredTransactions = (_isSearching && _searchQuery.isNotEmpty)
        ? financeProvider.statsTransactions.where((tx) {
            final noteMatch = tx.note.toLowerCase().contains(_searchQuery.toLowerCase());
            final catMatch = (categoryMap[tx.categoryId]?.name ?? l10n.other)
                .toLowerCase()
                .contains(_searchQuery.toLowerCase());
            return noteMatch || catMatch;
          }).toList()
        : (_isMonthly 
            ? financeProvider.getTransactionsByMonth(_selectedDate)
            : financeProvider.getTransactionsByYear(_selectedDate.year))
          .where((tx) {
            // Lọc theo danh mục
            if (_selectedCategory != 'Tất cả' && _selectedCategory != l10n.all &&
                (categoryMap[tx.categoryId]?.name ?? l10n.other) != _selectedCategory) {
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
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: l10n.searchHint,
                  border: InputBorder.none,
                ),
                style: const TextStyle(fontSize: 16),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTopTab(l10n.monthly, _isMonthly, () => setState(() => _isMonthly = true)),
                  _buildTopTab(l10n.yearly, !_isMonthly, () => setState(() => _isMonthly = false)),
                ],
              ),
        centerTitle: true,
        leading: _isSearching
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.blue),
                onPressed: () {
                  setState(() {
                    _isSearching = false;
                    _searchQuery = '';
                    _searchController.clear();
                  });
                },
              )
            : null,
        actions: [
          if (!_isSearching)
            IconButton(
              icon: const Icon(Icons.filter_list, color: Colors.blue),
              onPressed: () => _showFilterDialog(financeProvider),
            ),
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search, color: Colors.blue),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _searchQuery = '';
                  _searchController.clear();
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
        ],
      ),
      body: _isSearching && _searchQuery.isNotEmpty
          ? _buildSearchResults(filteredTransactions, categoryMap, settings, l10n)
          : TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: Column(
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
                            ? DateFormat.yM(Localizations.localeOf(context).toString()).format(_selectedDate)
                            : DateFormat.y(Localizations.localeOf(context).toString()).format(_selectedDate),
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

            // Bảng tóm tắt Thu/Chi
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
                        _buildSummaryItem(l10n.expense, periodExpense, Colors.red, settings, isNegative: true),
                        Container(width: 1, height: 40, color: Colors.grey.shade200),
                        _buildSummaryItem(l10n.income, periodIncome, Colors.blue, settings),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(l10n.netBalance, style: const TextStyle(color: Colors.grey)),
                        Text(
                          '${periodNet >= 0 ? '+' : ''}${settings.formatAmount(periodNet)}',
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
                _buildChartTypeTab(l10n.expense, _chartType == 'expense', () => setState(() => _chartType = 'expense')),
                _buildChartTypeTab(l10n.income, _chartType == 'income', () => setState(() => _chartType = 'income')),
              ],
            ),

            // Biểu đồ Donut và Danh sách (Thêm AnimatedSwitcher để chuyển đổi mượt mà)
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.0, 0.02),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: chartDataTransactions.isEmpty
                  ? Center(
                      key: ValueKey('empty_$_chartType'),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.pie_chart_outline, size: 80, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          Text(l10n.noData(_chartType == 'expense' ? l10n.expense.toLowerCase() : l10n.income.toLowerCase()),
                              style: TextStyle(color: Colors.grey.shade500)),
                        ],
                      ),
                    )
                  : CustomScrollView(
                      key: ValueKey('${_chartType}_${_isMonthly}_${_selectedDate.toIso8601String()}'),
                      slivers: [
                        SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                                          final categoryId = entry.key;
                                          final cat = categoryMap[categoryId] ??
                                              CategoryModel(
                                                name: l10n.other,
                                                type: 'expense',
                                                iconName: 'category',
                                                colorValue: 0xFF9E9E9E,
                                              );
                                          return PieChartSectionData(
                                            color: Color(cat.colorValue),
                                            value: entry.value,
                                            title: '',
                                            radius: 50,
                                          );
                                        }).toList(),
                                      ),
                                      swapAnimationDuration: const Duration(milliseconds: 600),
                                      swapAnimationCurve: Curves.easeInOutBack,
                                    ),
                                  ],
                                ),
                              ),
                            const SizedBox(height: 20),
                            // 1. Danh sách phân tích theo phần trăm (Category Breakdown)
                            ...sortedEntries.map((entry) {
                              final categoryId = entry.key;
                              final amount = entry.value;
                              final percentage = totalForChart > 0 ? (amount / totalForChart * 100) : 0;
                              final category = categoryMap[categoryId] ??
                                  CategoryModel(
                                    name: l10n.other,
                                    type: _chartType,
                                    iconName: 'category',
                                    colorValue: 0xFF9E9E9E,
                                  );

                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: Color(category.colorValue),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(category.name, style: const TextStyle(fontSize: 14)),
                                    ),
                                    Text(
                                      '${percentage.toStringAsFixed(1)}%',
                                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      settings.formatAmount(amount),
                                      style: const TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              );
                            }),

                            const Divider(height: 40, thickness: 8, color: Color(0xFFF5F5F5)),

                            // 2. Tiêu đề phần chi tiết giao dịch
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Text(
                                l10n.detailedTransactions,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // 3. Danh sách giao dịch chi tiết (Sử dụng SliverList để tối ưu hiệu năng)
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final tx = filteredTransactions[index];
                            final category = categoryMap[tx.categoryId] ??
                                CategoryModel(
                                  name: l10n.other,
                                  type: tx.type,
                                  iconName: 'category',
                                  colorValue: 0xFF9E9E9E,
                                );
                            final isIncome = tx.type == 'income';

                            return GestureDetector(
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditTransactionScreen(transaction: tx),
                                  ),
                                );
                                if (mounted) {
                                  Provider.of<FinanceProvider>(context, listen: false).fetchAllTransactionsForStats();
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Color(category.colorValue).withOpacity(0.1),
                                      radius: 18,
                                      child: FaIcon(
                                        IconUtils.getIconData(category.iconName),
                                        color: Color(category.colorValue),
                                        size: 16,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      flex: 3,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            category.name,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                          ),
                                          if (tx.note.isNotEmpty)
                                            Text(
                                              tx.note,
                                              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            '${isIncome ? '+' : '-'}${settings.formatAmount(tx.amount)}',
                                            style: TextStyle(
                                              color: isIncome ? Colors.green : Colors.red,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          Text(
                                            DateFormat.MMMd(Localizations.localeOf(context).toString()).format(tx.date),
                                            style: const TextStyle(color: Colors.grey, fontSize: 11),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          childCount: filteredTransactions.length,
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 80)),
                    ],
                  ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults(List<dynamic> transactions, Map<String, CategoryModel> categoryMap, SettingsProvider settings, AppLocalizations l10n) {
    final l10n = AppLocalizations.of(context)!;
    if (transactions.isEmpty) {
      return Center(child: Text(l10n.noResults));
    }

    // Nhóm giao dịch theo ngày
    Map<String, List<dynamic>> grouped = {};
    for (var tx in transactions) {
      String dateStr = DateFormat.yMd(Localizations.localeOf(context).toString()).format(tx.date);
      if (grouped[dateStr] == null) grouped[dateStr] = [];
      grouped[dateStr]!.add(tx);
    }

    var sortedDates = grouped.keys.toList()
      ..sort((a, b) => DateFormat.yMd(Localizations.localeOf(context).toString()).parse(b).compareTo(DateFormat.yMd(Localizations.localeOf(context).toString()).parse(a)));

    return ListView.builder(
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        String date = sortedDates[index];
        List<dynamic> txs = grouped[date]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.grey.shade100,
              child: Text(
                date,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                  fontSize: 13,
                ),
              ),
            ),
            ...txs.map((tx) => _buildTransactionItem(tx, categoryMap, settings, l10n)),
          ],
        );
      },
    );
  }

  Widget _buildTransactionItem(dynamic tx, Map<String, CategoryModel> categoryMap, SettingsProvider settings, AppLocalizations l10n) {
    final category = categoryMap[tx.categoryId] ??
        CategoryModel(
          name: l10n.other,
          type: tx.type,
          iconName: 'category',
          colorValue: 0xFF9E9E9E,
        );
    final isIncome = tx.type == 'income';

    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditTransactionScreen(transaction: tx),
          ),
        );
        if (mounted) {
          Provider.of<FinanceProvider>(context, listen: false).fetchAllTransactionsForStats();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Color(category.colorValue).withOpacity(0.1),
              radius: 18,
              child: FaIcon(
                IconUtils.getIconData(category.iconName),
                color: Color(category.colorValue),
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  if (tx.note.isNotEmpty)
                    Text(
                      tx.note,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                '${isIncome ? '+' : '-'}${settings.formatAmount(tx.amount)}',
                textAlign: TextAlign.end,
                style: TextStyle(
                  color: isIncome ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
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

  Widget _buildSummaryItem(String label, double amount, Color color, SettingsProvider settings, {bool isNegative = false}) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 4),
          Text(
            '${isNegative ? '-' : '+'}${settings.formatAmount(amount)}',
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

  void _showFilterDialog(FinanceProvider provider) {
    final l10n = AppLocalizations.of(context)!;
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
                    Text(l10n.filterDetails,
                        style: const TextStyle(
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
                      child: Text(l10n.reset),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(l10n.category,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  isExpanded: true,
                  value: _selectedCategory == 'Tất cả' ? l10n.all : _selectedCategory,
                  items: [
                    l10n.all,
                    ...provider.categories.map((e) => e.name).toSet()
                  ].map((String value) {
                    // Tìm category để lấy icon và màu sắc
                    final category = value == l10n.all 
                      ? CategoryModel(
                          id: 'all',
                          name: l10n.all,
                          type: 'all',
                          iconName: 'list',
                          colorValue: 0xFF2196F3,
                        )
                      : provider.categories.firstWhere(
                          (c) => c.name == value,
                          orElse: () => CategoryModel(
                            id: 'other',
                            name: l10n.other,
                            type: 'other',
                            iconName: 'category',
                            colorValue: 0xFF9E9E9E,
                          ),
                        );

                    return DropdownMenuItem<String>(
                      value: value,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Color(category.colorValue).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: value == l10n.all
                                ? const Icon(Icons.apps, color: Colors.blue, size: 18)
                                : FaIcon(
                                    IconUtils.getIconData(category.iconName),
                                    color: Color(category.colorValue),
                                    size: 16,
                                  ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            value,
                            style: const TextStyle(fontSize: 15),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setModalState(() => _selectedCategory = val);
                    }
                  },
                ),
                const SizedBox(height: 25),
                Text(l10n.amountRange,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: l10n.from,
                          prefixIcon: const Icon(Icons.remove_circle_outline, size: 18),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (val) => _minAmount = double.tryParse(val),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text('—', style: TextStyle(color: Colors.grey)),
                    ),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: l10n.to,
                          prefixIcon: const Icon(Icons.add_circle_outline, size: 18),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
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
                    child: Text(l10n.apply,
                        style: const TextStyle(color: Colors.white)),
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

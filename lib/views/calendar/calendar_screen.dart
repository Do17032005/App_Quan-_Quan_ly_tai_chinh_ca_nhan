import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../providers/finance_provider.dart';
import '../../providers/settings_provider.dart';
import '../../data/models/transaction_model.dart';
import '../../data/models/category_model.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/icon_utils.dart';
import '../transaction/edit_transaction_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Tìm kiếm
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    // Đảm bảo có đủ dữ liệu cho việc hiển thị marker và tìm kiếm
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FinanceProvider>(context, listen: false).fetchAllTransactionsForStats();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final financeProvider = Provider.of<FinanceProvider>(context);
    final settings = Provider.of<SettingsProvider>(context);
    final l10n = AppLocalizations.of(context)!;
    // Sử dụng statsTransactions để có đầy đủ dữ liệu cho markers và tìm kiếm
    final allTransactions = financeProvider.statsTransactions;

    final categoryMap = {
      for (var cat in financeProvider.categories) cat.id ?? '': cat
    };

    // Lọc giao dịch nếu đang tìm kiếm
    final List<TransactionModel> filteredTransactions = (_isSearching && _searchQuery.isNotEmpty)
        ? allTransactions.where((tx) {
            final noteMatch = tx.note.toLowerCase().contains(_searchQuery.toLowerCase());
            final catMatch = (categoryMap[tx.categoryId]?.name ?? l10n.other)
                .toLowerCase()
                .contains(_searchQuery.toLowerCase());
            return noteMatch || catMatch;
          }).toList()
        : <TransactionModel>[];

    // --- LOGIC LỌC DỮ LIỆU THEO THÁNG ĐANG XEM ---
    final currentMonthTxs = allTransactions.where((tx) {
      return tx.date.year == _focusedDay.year &&
          tx.date.month == _focusedDay.month;
    }).toList();

    // Tính tổng Thu nhập và Chi tiêu trong tháng hiện tại của lịch
    double monthlyIncome = 0;
    double monthlyExpense = 0;
    for (var tx in currentMonthTxs) {
      if (tx.type == 'income') {
        monthlyIncome += tx.amount;
      } else {
        monthlyExpense += tx.amount;
      }
    }
    double monthlyTotal = monthlyIncome - monthlyExpense;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
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
            : Text(
                l10n.calendar,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        foregroundColor: Colors.black,
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
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search, color: Colors.blue),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _searchQuery = '';
                  _searchController.clear();
                  _isSearching = false;
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
          : Column(
              children: [
          // 1. KHU VỰC BẢNG LỊCH (TABLE CALENDAR)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.only(bottom: 10),
            child: TableCalendar<TransactionModel>(
              firstDay: DateTime(2020, 1, 1),
              lastDay: DateTime(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              eventLoader: (day) {
                return allTransactions
                    .where((tx) => isSameDay(tx.date, day))
                    .toList();
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onPageChanged: (focusedDay) {
                setState(() {
                  _focusedDay = focusedDay;
                });
              },
              locale: settings.locale.languageCode == 'vi' ? 'vi_VN' : 'en_US',
              startingDayOfWeek: StartingDayOfWeek.monday,
              headerStyle: HeaderStyle(
                titleCentered: true,
                formatButtonVisible: false,
                titleTextFormatter: (date, locale) =>
            DateFormat.yMMMM(locale).format(date),
                titleTextStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                ),
                leftChevronIcon: const Icon(
                  Icons.chevron_left,
                  color: Colors.grey,
                ),
                rightChevronIcon: const Icon(
                  Icons.chevron_right,
                  color: Colors.grey,
                ),
              ),
              calendarStyle: CalendarStyle(
                outsideDaysVisible: true,
                defaultTextStyle: const TextStyle(fontWeight: FontWeight.w500),
                weekendTextStyle: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
                todayDecoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(4),
                ),
                todayTextStyle: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.blue.shade600,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(4),
                ),
                markerDecoration: const BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),
                markersMaxCount: 3,
                defaultDecoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(4),
                ),
                weekendDecoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(4),
                ),
                outsideDecoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              daysOfWeekStyle: const DaysOfWeekStyle(
                weekdayStyle: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
                weekendStyle: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),

          const Divider(height: 1, thickness: 1),

          // 2. KHU VỰC KHỐI THỐNG KÊ DOANH SỐ THEO THÁNG
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryColumn(l10n.income, monthlyIncome, Colors.blue, settings),
                _buildSummaryColumn(
                  l10n.expense,
                  monthlyExpense,
                  Colors.orange.shade800,
                  settings,
                ),
                _buildSummaryColumn(
                  l10n.total,
                  monthlyTotal,
                  monthlyTotal >= 0 ? Colors.green : Colors.red,
                  settings,
                  isTotal: true,
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // 3. DANH SÁCH CHI TIẾT CÁC GIAO DỊCH CỦA NGÀY ĐANG ĐƯỢC CHỌN
          Expanded(child: _buildDayTransactionsList(allTransactions, settings, financeProvider, l10n)),
        ],
      ),
    );
  }

  Widget _buildSummaryColumn(
    String label,
    double amount,
    Color color,
    SettingsProvider settings, {
    bool isTotal = false,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${isTotal && amount > 0 ? '+' : ''}${settings.formatAmount(amount).replaceAll(',00', '')}',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResults(List<TransactionModel> transactions, Map<String, CategoryModel> categoryMap, SettingsProvider settings, AppLocalizations l10n) {
    if (transactions.isEmpty) {
      return Center(child: Text(l10n.noResults));
    }

    // Nhóm giao dịch theo ngày
    Map<String, List<TransactionModel>> grouped = {};
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
        List<TransactionModel> txs = grouped[date]!;

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

  Widget _buildTransactionItem(TransactionModel tx, Map<String, CategoryModel> categoryMap, SettingsProvider settings, AppLocalizations l10n) {
    final category = categoryMap[tx.categoryId] ??
        CategoryModel(
          id: 'other',
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
        // Cập nhật lại dữ liệu sau khi chỉnh sửa
        if (mounted) {
          Provider.of<FinanceProvider>(context, listen: false).fetchAllTransactionsForStats();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
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

  Widget _buildDayTransactionsList(
      List<TransactionModel> allTransactions, 
      SettingsProvider settings, 
      FinanceProvider financeProvider,
      AppLocalizations l10n) {
    // TỐI ƯU: Sử dụng hàm getTransactionsByDay từ Provider thay vì .where toàn bộ list
    final dayTxs = financeProvider.getTransactionsByDay(_selectedDay ?? _focusedDay);

    if (dayTxs.isEmpty) {
      return Center(
        child: Text(
          l10n.noTransactions,
          style: const TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: dayTxs.length,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      itemBuilder: (context, index) {
        final tx = dayTxs[index];
        final isIncome = tx.type == 'income';

        final category = financeProvider.categories.firstWhere(
          (cat) => cat.id == tx.categoryId,
          orElse: () => CategoryModel(
            id: '',
            name: l10n.other,
            type: tx.type,
            iconName: 'question',
            colorValue: 0xFF9E9E9E,
          ),
        );

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditTransactionScreen(transaction: tx),
              ),
            );
          },
          child: Card(
            elevation: 0,
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Color(category.colorValue).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: FaIcon(
                  IconUtils.getIconData(category.iconName),
                  color: Color(category.colorValue),
                  size: 20,
                ),
              ),
              title: Text(
                category.name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              subtitle: tx.note.isNotEmpty
                  ? Text(
                      tx.note,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  : null,
              trailing: Text(
                '${isIncome ? '+' : '-'}${settings.formatAmount(tx.amount).replaceAll(',00', '')}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isIncome ? Colors.blue : Colors.orange.shade800,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

}

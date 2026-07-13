import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../providers/finance_provider.dart';
import '../../providers/settings_provider.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    final financeProvider = Provider.of<FinanceProvider>(context);
    final settings = Provider.of<SettingsProvider>(context);
    final allTransactions = financeProvider.transactions;

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
        title: const Text(
          'Lịch',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        foregroundColor: Colors.black,
        actions: [],
      ),
      body: Column(
        children: [
          // 1. KHU VỰC BẢNG LỊCH (TABLE CALENDAR)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.only(bottom: 10),
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay =
                      focusedDay; // Cập nhật focusedDay để đổi tháng khi kích vào ngày tháng khác
                });
              },
              onPageChanged: (focusedDay) {
                setState(() {
                  _focusedDay =
                      focusedDay; // Tự động tính lại tiền khi người dùng bấm mũi tên chuyển tháng
                });
              },
              // Việt hóa tiêu đề thứ tự trong tuần giống ảnh mẫu
              locale: 'vi_VN',
              startingDayOfWeek:
                  StartingDayOfWeek.monday, // Bắt đầu tuần từ Thứ 2 (T2)
              // Tùy chỉnh giao diện thanh Header điều hướng Tháng/Năm
              headerStyle: HeaderStyle(
                titleCentered: true,
                formatButtonVisible:
                    false, // Ẩn nút đổi chế độ tuần/tháng rườm rà
                titleTextFormatter: (date, locale) =>
                    'Tháng ${DateFormat('MM/yyyy').format(date)}',
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

              // Cấu hình các ô ngày thường, ngày cuối tuần, ngày được chọn
              calendarStyle: CalendarStyle(
                outsideDaysVisible:
                    true, // Hiển thị mờ các ngày của tháng trước/sau
                defaultTextStyle: const TextStyle(fontWeight: FontWeight.w500),
                weekendTextStyle: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ), // Chủ nhật màu đỏ
                // Ngày hiện tại (Hôm nay)
                todayDecoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(4),
                ),
                todayTextStyle: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),

                // Ngày đang được người dùng click chọn
                selectedDecoration: BoxDecoration(
                  color: Colors.blue.shade600,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(4),
                ),

                // Định dạng ô vuông bo góc nhẹ giống ảnh 14d2cf4c-5b13-4aa0-9960-bd6bd72effdc.jpg
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

              // Hiển thị tên các Thứ ngắn gọn (T2, T3, T4...)
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

          // 2. KHU VỰC KHỐI THỐNG KÊ DOANH SỐ THEO THÁNG (GIỐNG ẢNH MẪU)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryColumn('Thu nhập', monthlyIncome, Colors.blue, settings),
                _buildSummaryColumn(
                  'Chi tiêu',
                  monthlyExpense,
                  Colors.orange.shade800,
                  settings,
                ),
                _buildSummaryColumn(
                  'Tổng',
                  monthlyTotal,
                  monthlyTotal >= 0 ? Colors.green : Colors.red,
                  settings,
                  isTotal: true,
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // 3. DANH SÁCH CHI TIẾT CÁC GIAO DỊCH CỦA NGÀY ĐANG ĐƯỢC CHỌN (NẾU CÓ)
          Expanded(child: _buildDayTransactionsList(allTransactions, settings)),
        ],
      ),
    );
  }

  // Widget con vẽ từng cột Thu nhập / Chi tiêu
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

  // Widget hiển thị danh sách các giao dịch phát sinh trong riêng ngày được click chọn
  Widget _buildDayTransactionsList(List<dynamic> allTransactions, SettingsProvider settings) {
    final dayTxs = allTransactions
        .where((tx) => isSameDay(tx.date, _selectedDay))
        .toList();

    if (dayTxs.isEmpty) {
      return const Center(
        child: Text(
          'Không có giao dịch nào trong ngày này.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: dayTxs.length,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      itemBuilder: (context, index) {
        final tx = dayTxs[index];
        final isIncome = tx.type == 'income';

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: Icon(
              isIncome ? Icons.arrow_downward : Icons.arrow_upward,
              color: isIncome ? Colors.blue : Colors.orange,
            ),
            title: Text(
              tx.note.isNotEmpty ? tx.note : 'Giao dịch không có ghi chú',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            trailing: Text(
              '${isIncome ? '+' : '-'}${settings.formatAmount(tx.amount).replaceAll(',00', '')}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isIncome ? Colors.blue : Colors.orange.shade800,
              ),
            ),
          ),
        );
      },
    );
  }
}

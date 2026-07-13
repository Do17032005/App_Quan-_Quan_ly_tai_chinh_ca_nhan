import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            children: [
              // --- GIAO DIỆN & TRẢI NGHIỆM ---
              const _SectionHeader(title: 'Giao diện & Trải nghiệm'),
              SwitchListTile(
                title: const Text('Chế độ Tối (Dark Mode)'),
                secondary: const Icon(Icons.dark_mode),
                value: settings.isDarkMode,
                onChanged: (value) => settings.toggleDarkMode(value),
              ),
              SwitchListTile(
                title: const Text('Ẩn số dư trên màn hình chính'),
                secondary: const Icon(Icons.visibility_off),
                value: settings.isBalanceHidden,
                onChanged: (value) => settings.toggleBalanceHidden(value),
              ),
              const Divider(),

              // --- TÀI CHÍNH ---
              const _SectionHeader(title: 'Tài chính'),
              ListTile(
                leading: const Icon(Icons.attach_money),
                title: const Text('Đơn vị tiền tệ'),
                trailing: DropdownButton<String>(
                  value: settings.currency,
                  items: const [
                    DropdownMenuItem(value: 'VNĐ', child: Text('VNĐ (₫)')),
                    DropdownMenuItem(value: 'USD', child: Text('USD (\$)' )),
                  ],
                  onChanged: (value) {
                    if (value != null) settings.setCurrency(value);
                  },
                ),
              ),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Ngày bắt đầu tháng'),
                trailing: DropdownButton<int>(
                  value: settings.startOfMonth,
                  items: List.generate(28, (index) {
                    return DropdownMenuItem(
                      value: index + 1,
                      child: Text('Ngày ${index + 1}'),
                    );
                  }),
                  onChanged: (value) {
                    if (value != null) settings.setStartOfMonth(value);
                  },
                ),
              ),
              ListTile(
                leading: const Icon(Icons.account_balance_wallet),
                title: const Text('Hạn mức chi tiêu tháng'),
                subtitle: Text(settings.budgetLimit > 0 
                  ? 'Đang bật: ${settings.budgetLimit.toStringAsFixed(0)} ${settings.currency}' 
                  : 'Không giới hạn'),
                trailing: const Icon(Icons.edit, size: 18),
                onTap: () {
                  _showBudgetDialog(context, settings);
                },
              ),
              const Divider(),

              // --- THÔNG BÁO ---
              const _SectionHeader(title: 'Thông báo'),
              SwitchListTile(
                title: const Text('Nhắc nhở nhập liệu hàng ngày'),
                subtitle: Text('Lúc ${settings.reminderTime.format(context)}'),
                secondary: const Icon(Icons.notifications_active),
                value: settings.isReminderEnabled,
                onChanged: (value) async {
                  await settings.toggleReminder(value);
                  if (value && context.mounted) {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: settings.reminderTime,
                    );
                    if (time != null) {
                      settings.setReminderTime(time);
                    }
                  }
                },
              ),
              SwitchListTile(
                title: const Text('Cảnh báo vượt hạn mức'),
                subtitle: const Text('Thông báo khi chi tiêu vượt ngân sách'),
                secondary: const Icon(Icons.warning_amber),
                value: settings.isBudgetAlertEnabled,
                onChanged: (value) => settings.toggleBudgetAlert(value),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showBudgetDialog(BuildContext context, SettingsProvider settings) {
    final TextEditingController controller = TextEditingController(
      text: settings.budgetLimit > 0 ? settings.budgetLimit.toStringAsFixed(0) : '',
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thiết lập hạn mức chi tiêu'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Nhập số tiền (ví dụ: 10000000)',
            suffixText: settings.currency,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              final val = double.tryParse(controller.text) ?? 0.0;
              settings.setBudgetLimit(val);
              Navigator.pop(context);
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}

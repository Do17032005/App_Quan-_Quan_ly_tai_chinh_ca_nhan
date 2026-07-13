import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/l10n/app_localizations.dart';
import '../../providers/settings_provider.dart';
import '../../providers/auth_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.settings,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            children: [
              // --- GIAO DIỆN & TRẢI NGHIỆM ---
              _SectionHeader(title: l10n.appearance),
              SwitchListTile(
                title: Text(l10n.darkMode),
                secondary: Icon(Icons.dark_mode, color: Colors.blue.shade600),
                value: settings.isDarkMode,
                onChanged: (value) => settings.toggleDarkMode(value),
              ),
              SwitchListTile(
                title: Text(l10n.hideBalance),
                secondary: Icon(Icons.visibility_off, color: Colors.blue.shade600),
                value: settings.isBalanceHidden,
                onChanged: (value) => settings.toggleBalanceHidden(value),
              ),
              ListTile(
                leading: Icon(Icons.language, color: Colors.blue.shade600),
                title: Text(l10n.language),
                trailing: DropdownButton<String>(
                  value: settings.locale.languageCode,
                  items: const [
                    DropdownMenuItem(value: 'vi', child: Text('Tiếng Việt')),
                    DropdownMenuItem(value: 'en', child: Text('English')),
                  ],
                  onChanged: (value) {
                    if (value != null) settings.setLanguage(value);
                  },
                ),
              ),
              const Divider(),

              // --- TÀI CHÍNH ---
              _SectionHeader(title: l10n.finance),
              ListTile(
                leading: Icon(Icons.attach_money, color: Colors.blue.shade600),
                title: Text(l10n.currency),
                trailing: DropdownButton<String>(
                  value: settings.currency,
                  items: const [
                    DropdownMenuItem(value: 'VNĐ', child: Text('VNĐ (₫)')),
                    DropdownMenuItem(value: 'USD', child: Text('USD (\$)')),
                  ],
                  onChanged: (value) {
                    if (value != null) settings.setCurrency(value);
                  },
                ),
              ),
              ListTile(
                leading: Icon(Icons.calendar_today, color: Colors.blue.shade600),
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
                leading: Icon(Icons.account_balance_wallet, color: Colors.blue.shade600),
                title: Text(l10n.budgetLimit),
                subtitle: Text(
                  settings.budgetLimit > 0
                      ? 'Đang bật: ${settings.formatAmount(settings.budgetLimit)}'
                      : 'Không giới hạn',
                ),
                trailing: const Icon(Icons.edit, size: 18),
                onTap: () {
                  _showBudgetDialog(context, settings);
                },
              ),
              const Divider(),

              // --- THÔNG BÁO ---
              _SectionHeader(title: l10n.notifications),
              SwitchListTile(
                title: Text(l10n.dailyReminder),
                subtitle: Text('Lúc ${settings.reminderTime.format(context)}'),
                secondary: Icon(Icons.notifications_active, color: Colors.blue.shade600),
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
                secondary: Icon(Icons.warning_amber, color: Colors.blue.shade600),
                value: settings.isBudgetAlertEnabled,
                onChanged: (value) => settings.toggleBudgetAlert(value),
              ),
              const Divider(),

              // --- TÀI KHOẢN ---
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  'Đăng xuất',
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
                onTap: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Đăng xuất'),
                      content: const Text('Bạn có chắc chắn muốn đăng xuất không?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Hủy'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true && context.mounted) {
                    await Provider.of<AuthProvider>(context, listen: false).logout();
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }

  void _showBudgetDialog(BuildContext context, SettingsProvider settings) {
    final TextEditingController controller = TextEditingController(
      text: settings.budgetLimit > 0
          ? settings.convertToDisplay(settings.budgetLimit).toInt().toString()
          : '',
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
              settings.setBudgetLimit(settings.convertToVND(val));
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
  const _SectionHeader({required this.title});

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

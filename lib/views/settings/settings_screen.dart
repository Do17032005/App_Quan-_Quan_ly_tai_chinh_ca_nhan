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
                title: Text(l10n.startOfMonth),
                trailing: DropdownButton<int>(
                  value: settings.startOfMonth,
                  items: List.generate(28, (index) {
                    return DropdownMenuItem(
                      value: index + 1,
                      child: Text('${l10n.dayPrefix} ${index + 1}'),
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
                      ? '${l10n.active}: ${settings.formatAmount(settings.budgetLimit)}'
                      : l10n.unlimited,
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
                subtitle: Text(l10n.atTime(settings.reminderTime.format(context))),
                secondary: Icon(Icons.notifications_active, color: Colors.blue.shade600),
                value: settings.isReminderEnabled,
                onChanged: (value) async {
                  if (value) {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: settings.reminderTime,
                    );
                    if (time != null) {
                      await settings.setReminderTime(time);
                      await settings.toggleReminder(true);
                    }
                  } else {
                    await settings.toggleReminder(false);
                  }
                },
              ),
              SwitchListTile(
                title: Text(l10n.budgetAlert),
                subtitle: Text(l10n.budgetAlertDesc),
                secondary: Icon(Icons.warning_amber, color: Colors.blue.shade600),
                value: settings.isBudgetAlertEnabled,
                onChanged: (value) => settings.toggleBudgetAlert(value),
              ),
              const Divider(),

              // --- TÀI KHOẢN ---
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: Text(
                  l10n.logout,
                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
                onTap: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(l10n.logout),
                      content: Text(l10n.logoutConfirm),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text(l10n.cancel),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text(l10n.logout, style: const TextStyle(color: Colors.red)),
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
    final l10n = AppLocalizations.of(context)!;
    final TextEditingController controller = TextEditingController(
      text: settings.budgetLimit > 0
          ? settings.convertToDisplay(settings.budgetLimit).toInt().toString()
          : '',
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.setBudgetLimit),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: l10n.enterAmount,
            suffixText: settings.currency,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              final val = double.tryParse(controller.text) ?? 0.0;
              settings.setBudgetLimit(settings.convertToVND(val));
              Navigator.pop(context);
            },
            child: Text(l10n.save),
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

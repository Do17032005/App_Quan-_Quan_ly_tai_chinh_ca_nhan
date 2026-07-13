import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../services/notification_service.dart';

class SettingsProvider with ChangeNotifier {
  // === TRẠNG THÁI (STATE) ===
  // 1. Giao diện
  bool _isDarkMode = false;
  bool _isBalanceHidden = false;

  // 2. Tài chính
  String _currency = 'VNĐ';
  int _startOfMonth = 1;
  double _budgetLimit = 0.0; // 0.0 nghĩa là không giới hạn

  // 3. Thông báo
  bool _isReminderEnabled = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 20, minute: 0);
  bool _isBudgetAlertEnabled = false;

  // === GETTERS ===
  bool get isDarkMode => _isDarkMode;
  bool get isBalanceHidden => _isBalanceHidden;
  String get currency => _currency;
  int get startOfMonth => _startOfMonth;
  double get budgetLimit => _budgetLimit;
  bool get isReminderEnabled => _isReminderEnabled;
  TimeOfDay get reminderTime => _reminderTime;
  bool get isBudgetAlertEnabled => _isBudgetAlertEnabled;

  NumberFormat get currencyFormat {
    if (_currency == 'USD') {
      return NumberFormat.currency(locale: 'en_US', symbol: '\$');
    }
    return NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
  }

  // === KHỞI TẠO ===
  SettingsProvider() {
    _loadSettings();
  }

  // Load cài đặt từ SharedPreferences
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _isBalanceHidden = prefs.getBool('isBalanceHidden') ?? false;
    
    _currency = prefs.getString('currency') ?? 'VNĐ';
    _startOfMonth = prefs.getInt('startOfMonth') ?? 1;
    _budgetLimit = prefs.getDouble('budgetLimit') ?? 0.0;
    
    _isReminderEnabled = prefs.getBool('isReminderEnabled') ?? false;
    final hour = prefs.getInt('reminderHour') ?? 20;
    final minute = prefs.getInt('reminderMinute') ?? 0;
    _reminderTime = TimeOfDay(hour: hour, minute: minute);
    
    _isBudgetAlertEnabled = prefs.getBool('isBudgetAlertEnabled') ?? false;

    notifyListeners();
  }

  // === SETTERS (CẬP NHẬT & LƯU LẠI) ===
  
  Future<void> toggleDarkMode(bool value) async {
    _isDarkMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
    notifyListeners();
  }

  Future<void> toggleBalanceHidden(bool value) async {
    _isBalanceHidden = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isBalanceHidden', value);
    notifyListeners();
  }

  Future<void> setCurrency(String value) async {
    _currency = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currency', value);
    notifyListeners();
  }

  Future<void> setStartOfMonth(int value) async {
    _startOfMonth = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('startOfMonth', value);
    notifyListeners();
  }

  Future<void> setBudgetLimit(double value) async {
    _budgetLimit = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('budgetLimit', value);
    notifyListeners();
  }

  Future<void> toggleReminder(bool value) async {
    _isReminderEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isReminderEnabled', value);
    
    if (value) {
      await NotificationService().scheduleDailyReminder(_reminderTime);
    } else {
      await NotificationService().cancelAllNotifications();
    }
    notifyListeners();
  }

  Future<void> setReminderTime(TimeOfDay value) async {
    _reminderTime = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('reminderHour', value.hour);
    await prefs.setInt('reminderMinute', value.minute);
    
    if (_isReminderEnabled) {
      await NotificationService().scheduleDailyReminder(_reminderTime);
    }
    notifyListeners();
  }

  Future<void> toggleBudgetAlert(bool value) async {
    _isBudgetAlertEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isBudgetAlertEnabled', value);
    notifyListeners();
  }
}

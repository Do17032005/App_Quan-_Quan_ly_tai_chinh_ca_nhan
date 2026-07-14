// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Finance Manager';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get transactions => 'Transactions';

  @override
  String get statistics => 'Statistics';

  @override
  String get settings => 'Settings';

  @override
  String get addTransaction => 'Add Transaction';

  @override
  String get income => 'Income';

  @override
  String get expense => 'Expense';

  @override
  String get totalBalance => 'Total Balance';

  @override
  String get recentTransactions => 'Recent Transactions';

  @override
  String get viewAll => 'View All';

  @override
  String get noTransactions => 'No transactions yet.';

  @override
  String get appearance => 'Appearance';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get hideBalance => 'Hide Balance';

  @override
  String get finance => 'Finance';

  @override
  String get currency => 'Currency';

  @override
  String get budgetLimit => 'Budget Limit';

  @override
  String get notifications => 'Notifications';

  @override
  String get dailyReminder => 'Daily Reminder';

  @override
  String get language => 'Language';

  @override
  String get calendar => 'Calendar';

  @override
  String get total => 'Total';

  @override
  String get startOfMonth => 'Start of month';

  @override
  String get dayPrefix => 'Day';

  @override
  String get detailedTransactions => 'Detailed transactions';

  @override
  String get monthly => 'Monthly';

  @override
  String get yearly => 'Yearly';

  @override
  String get searchHint => 'Search notes, categories...';

  @override
  String get netBalance => 'Net Balance';

  @override
  String noData(String type) {
    return 'No $type data';
  }

  @override
  String get other => 'Other';

  @override
  String get noResults => 'No transactions found';

  @override
  String get filterDetails => 'Filter Details';

  @override
  String get reset => 'Reset';

  @override
  String get category => 'Category';

  @override
  String get all => 'All';

  @override
  String get amountRange => 'Amount Range';

  @override
  String get from => 'From';

  @override
  String get to => 'To';

  @override
  String get apply => 'Apply';

  @override
  String get budgetAlert => 'Budget Limit Warning';

  @override
  String get budgetAlertDesc => 'Notify when spending exceeds budget';

  @override
  String get logout => 'Logout';

  @override
  String get logoutConfirm => 'Are you sure you want to logout?';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get setBudgetLimit => 'Set Budget Limit';

  @override
  String get enterAmount => 'Enter amount (e.g., 10000000)';

  @override
  String get active => 'Active';

  @override
  String get unlimited => 'Unlimited';

  @override
  String get editExpense => 'Edit Expense';

  @override
  String get editIncome => 'Edit Income';

  @override
  String get copy => 'Copy';

  @override
  String get confirmDeleteTransaction =>
      'Are you sure you want to delete this transaction?';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get enterNote => 'Enter note';

  @override
  String get date => 'Date';

  @override
  String get note => 'Note';

  @override
  String get noteHintExpense => 'Enter note for this expense...';

  @override
  String get noteHintIncome => 'Enter note for this income...';

  @override
  String get enterExpense => 'Enter Expense';

  @override
  String get enterIncome => 'Enter Income';

  @override
  String get pleaseEnterAmount => 'Please enter amount';

  @override
  String get pleaseSelectCategory => 'Please select category';

  @override
  String get budgetWarning => 'Budget Warning';

  @override
  String budgetWarningDesc(String limit) {
    return 'This expense will exceed the budget limit ($limit). Are you sure you want to continue?';
  }

  @override
  String get continueText => 'Continue';

  @override
  String get addCategory => 'Add Category';

  @override
  String get confirmDelete => 'Confirm Delete';

  @override
  String confirmDeleteCategory(String name) {
    return 'Are you sure you want to delete category \"$name\"?';
  }

  @override
  String get delete => 'Delete';

  @override
  String categoryDeleted(String name) {
    return 'Category \"$name\" deleted';
  }

  @override
  String get createNew => 'Create New';

  @override
  String get editCategory => 'Edit Category';

  @override
  String get name => 'Name';

  @override
  String get enterCategoryName => 'Please enter category name';

  @override
  String get icons => 'Icons';

  @override
  String get colors => 'Colors';

  @override
  String get categoryExists => 'This category name already exists';

  @override
  String categoryAdded(String name) {
    return 'Category \"$name\" added';
  }

  @override
  String categoryUpdated(String name) {
    return 'Category \"$name\" updated';
  }

  @override
  String get monday => 'Monday';

  @override
  String get tuesday => 'Tuesday';

  @override
  String get wednesday => 'Wednesday';

  @override
  String get thursday => 'Thursday';

  @override
  String get friday => 'Friday';

  @override
  String get saturday => 'Saturday';

  @override
  String get sunday => 'Sunday';

  @override
  String get transactionDeleted => 'Data deleted';

  @override
  String get transactionUpdated => 'Data updated';

  @override
  String get transactionAdded => 'Data added';

  @override
  String get password => 'Password';

  @override
  String get edit => 'Edit';

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get loginSubtitle => 'Login to continue managing finances';

  @override
  String get login => 'Login';

  @override
  String get noAccount => 'Don\'t have an account? ';

  @override
  String get registerNow => 'Register now';

  @override
  String get pleaseEnterEmail => 'Please enter email';

  @override
  String get invalidEmail => 'Invalid email format';

  @override
  String get pleaseEnterPassword => 'Please enter password';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters';

  @override
  String get loginSuccess => 'Login successful!';

  @override
  String get register => 'Register';

  @override
  String get createAccount => 'Create Account';

  @override
  String get registerSubtitle => 'Start managing your finances today';

  @override
  String get fullName => 'Full Name';

  @override
  String get pleaseEnterFullName => 'Please enter full name';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get pleaseConfirmPassword => 'Please confirm password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get alreadyHaveAccount => 'Already have an account? ';

  @override
  String get loginNow => 'Login now';

  @override
  String get registerSuccess => 'Registration successful!';

  @override
  String atTime(Object time) {
    return 'At $time';
  }
}

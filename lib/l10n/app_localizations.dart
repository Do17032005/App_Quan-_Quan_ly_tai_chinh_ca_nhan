import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In vi, this message translates to:
  /// **'Quản lý tài chính'**
  String get appTitle;

  /// No description provided for @dashboard.
  ///
  /// In vi, this message translates to:
  /// **'Tổng quan'**
  String get dashboard;

  /// No description provided for @transactions.
  ///
  /// In vi, this message translates to:
  /// **'Giao dịch'**
  String get transactions;

  /// No description provided for @statistics.
  ///
  /// In vi, this message translates to:
  /// **'Thống kê'**
  String get statistics;

  /// No description provided for @settings.
  ///
  /// In vi, this message translates to:
  /// **'Cài đặt'**
  String get settings;

  /// No description provided for @addTransaction.
  ///
  /// In vi, this message translates to:
  /// **'Thêm giao dịch'**
  String get addTransaction;

  /// No description provided for @income.
  ///
  /// In vi, this message translates to:
  /// **'Thu nhập'**
  String get income;

  /// No description provided for @expense.
  ///
  /// In vi, this message translates to:
  /// **'Chi tiêu'**
  String get expense;

  /// No description provided for @totalBalance.
  ///
  /// In vi, this message translates to:
  /// **'Tổng số dư'**
  String get totalBalance;

  /// No description provided for @recentTransactions.
  ///
  /// In vi, this message translates to:
  /// **'Giao dịch gần đây'**
  String get recentTransactions;

  /// No description provided for @viewAll.
  ///
  /// In vi, this message translates to:
  /// **'Xem tất cả'**
  String get viewAll;

  /// No description provided for @noTransactions.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có giao dịch nào.'**
  String get noTransactions;

  /// No description provided for @appearance.
  ///
  /// In vi, this message translates to:
  /// **'Giao diện'**
  String get appearance;

  /// No description provided for @darkMode.
  ///
  /// In vi, this message translates to:
  /// **'Chế độ tối'**
  String get darkMode;

  /// No description provided for @hideBalance.
  ///
  /// In vi, this message translates to:
  /// **'Ẩn số dư'**
  String get hideBalance;

  /// No description provided for @finance.
  ///
  /// In vi, this message translates to:
  /// **'Tài chính'**
  String get finance;

  /// No description provided for @currency.
  ///
  /// In vi, this message translates to:
  /// **'Tiền tệ'**
  String get currency;

  /// No description provided for @budgetLimit.
  ///
  /// In vi, this message translates to:
  /// **'Hạn mức ngân sách'**
  String get budgetLimit;

  /// No description provided for @notifications.
  ///
  /// In vi, this message translates to:
  /// **'Thông báo'**
  String get notifications;

  /// No description provided for @dailyReminder.
  ///
  /// In vi, this message translates to:
  /// **'Nhắc nhở hàng ngày'**
  String get dailyReminder;

  /// No description provided for @language.
  ///
  /// In vi, this message translates to:
  /// **'Ngôn ngữ'**
  String get language;

  /// No description provided for @calendar.
  ///
  /// In vi, this message translates to:
  /// **'Lịch'**
  String get calendar;

  /// No description provided for @total.
  ///
  /// In vi, this message translates to:
  /// **'Tổng cộng'**
  String get total;

  /// No description provided for @startOfMonth.
  ///
  /// In vi, this message translates to:
  /// **'Ngày bắt đầu tháng'**
  String get startOfMonth;

  /// No description provided for @dayPrefix.
  ///
  /// In vi, this message translates to:
  /// **'Ngày'**
  String get dayPrefix;

  /// No description provided for @detailedTransactions.
  ///
  /// In vi, this message translates to:
  /// **'Giao dịch chi tiết'**
  String get detailedTransactions;

  /// No description provided for @monthly.
  ///
  /// In vi, this message translates to:
  /// **'Hàng Tháng'**
  String get monthly;

  /// No description provided for @yearly.
  ///
  /// In vi, this message translates to:
  /// **'Hàng Năm'**
  String get yearly;

  /// No description provided for @searchHint.
  ///
  /// In vi, this message translates to:
  /// **'Tìm kiếm ghi chú, danh mục...'**
  String get searchHint;

  /// No description provided for @netBalance.
  ///
  /// In vi, this message translates to:
  /// **'Thu chi'**
  String get netBalance;

  /// No description provided for @noData.
  ///
  /// In vi, this message translates to:
  /// **'Không có dữ liệu {type}'**
  String noData(String type);

  /// No description provided for @other.
  ///
  /// In vi, this message translates to:
  /// **'Khác'**
  String get other;

  /// No description provided for @noResults.
  ///
  /// In vi, this message translates to:
  /// **'Không tìm thấy giao dịch nào'**
  String get noResults;

  /// No description provided for @filterDetails.
  ///
  /// In vi, this message translates to:
  /// **'Bộ lọc chi tiết'**
  String get filterDetails;

  /// No description provided for @reset.
  ///
  /// In vi, this message translates to:
  /// **'Đặt lại'**
  String get reset;

  /// No description provided for @category.
  ///
  /// In vi, this message translates to:
  /// **'Danh mục'**
  String get category;

  /// No description provided for @all.
  ///
  /// In vi, this message translates to:
  /// **'Tất cả'**
  String get all;

  /// No description provided for @amountRange.
  ///
  /// In vi, this message translates to:
  /// **'Khoảng giá'**
  String get amountRange;

  /// No description provided for @from.
  ///
  /// In vi, this message translates to:
  /// **'Từ'**
  String get from;

  /// No description provided for @to.
  ///
  /// In vi, this message translates to:
  /// **'Đến'**
  String get to;

  /// No description provided for @apply.
  ///
  /// In vi, this message translates to:
  /// **'Áp dụng'**
  String get apply;

  /// No description provided for @budgetAlert.
  ///
  /// In vi, this message translates to:
  /// **'Cảnh báo vượt hạn mức'**
  String get budgetAlert;

  /// No description provided for @budgetAlertDesc.
  ///
  /// In vi, this message translates to:
  /// **'Thông báo khi chi tiêu vượt ngân sách'**
  String get budgetAlertDesc;

  /// No description provided for @logout.
  ///
  /// In vi, this message translates to:
  /// **'Đăng xuất'**
  String get logout;

  /// No description provided for @logoutConfirm.
  ///
  /// In vi, this message translates to:
  /// **'Bạn có chắc chắn muốn đăng xuất không?'**
  String get logoutConfirm;

  /// No description provided for @cancel.
  ///
  /// In vi, this message translates to:
  /// **'Hủy'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In vi, this message translates to:
  /// **'Lưu'**
  String get save;

  /// No description provided for @setBudgetLimit.
  ///
  /// In vi, this message translates to:
  /// **'Thiết lập hạn mức chi tiêu'**
  String get setBudgetLimit;

  /// No description provided for @enterAmount.
  ///
  /// In vi, this message translates to:
  /// **'Nhập số tiền (ví dụ: 10000000)'**
  String get enterAmount;

  /// No description provided for @active.
  ///
  /// In vi, this message translates to:
  /// **'Đang bật'**
  String get active;

  /// No description provided for @unlimited.
  ///
  /// In vi, this message translates to:
  /// **'Không giới hạn'**
  String get unlimited;

  /// No description provided for @editExpense.
  ///
  /// In vi, this message translates to:
  /// **'Sửa khoản chi'**
  String get editExpense;

  /// No description provided for @editIncome.
  ///
  /// In vi, this message translates to:
  /// **'Sửa khoản thu'**
  String get editIncome;

  /// No description provided for @copy.
  ///
  /// In vi, this message translates to:
  /// **'Sao chép'**
  String get copy;

  /// No description provided for @confirmDeleteTransaction.
  ///
  /// In vi, this message translates to:
  /// **'Bạn có chắc chắn muốn xóa giao dịch này không?'**
  String get confirmDeleteTransaction;

  /// No description provided for @saveChanges.
  ///
  /// In vi, this message translates to:
  /// **'Lưu thay đổi'**
  String get saveChanges;

  /// No description provided for @enterNote.
  ///
  /// In vi, this message translates to:
  /// **'Nhập ghi chú'**
  String get enterNote;

  /// No description provided for @date.
  ///
  /// In vi, this message translates to:
  /// **'Ngày'**
  String get date;

  /// No description provided for @note.
  ///
  /// In vi, this message translates to:
  /// **'Ghi chú'**
  String get note;

  /// No description provided for @noteHintExpense.
  ///
  /// In vi, this message translates to:
  /// **'Nhập ghi chú cho khoản chi này...'**
  String get noteHintExpense;

  /// No description provided for @noteHintIncome.
  ///
  /// In vi, this message translates to:
  /// **'Nhập ghi chú cho khoản thu này...'**
  String get noteHintIncome;

  /// No description provided for @enterExpense.
  ///
  /// In vi, this message translates to:
  /// **'Nhập khoản chi'**
  String get enterExpense;

  /// No description provided for @enterIncome.
  ///
  /// In vi, this message translates to:
  /// **'Nhập khoản thu'**
  String get enterIncome;

  /// No description provided for @pleaseEnterAmount.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập số tiền'**
  String get pleaseEnterAmount;

  /// No description provided for @pleaseSelectCategory.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng chọn danh mục'**
  String get pleaseSelectCategory;

  /// No description provided for @budgetWarning.
  ///
  /// In vi, this message translates to:
  /// **'Cảnh báo ngân sách'**
  String get budgetWarning;

  /// No description provided for @budgetWarningDesc.
  ///
  /// In vi, this message translates to:
  /// **'Khoản chi này sẽ làm tổng chi tiêu vượt hạn mức ({limit}). Bạn có chắc chắn muốn tiếp tục?'**
  String budgetWarningDesc(String limit);

  /// No description provided for @continueText.
  ///
  /// In vi, this message translates to:
  /// **'Tiếp tục'**
  String get continueText;

  /// No description provided for @addCategory.
  ///
  /// In vi, this message translates to:
  /// **'Thêm danh mục'**
  String get addCategory;

  /// No description provided for @confirmDelete.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận xóa'**
  String get confirmDelete;

  /// No description provided for @confirmDeleteCategory.
  ///
  /// In vi, this message translates to:
  /// **'Bạn có chắc chắn muốn xóa danh mục \"{name}\" không?'**
  String confirmDeleteCategory(String name);

  /// No description provided for @delete.
  ///
  /// In vi, this message translates to:
  /// **'Xóa'**
  String get delete;

  /// No description provided for @categoryDeleted.
  ///
  /// In vi, this message translates to:
  /// **'Đã xóa danh mục \"{name}\"'**
  String categoryDeleted(String name);

  /// No description provided for @createNew.
  ///
  /// In vi, this message translates to:
  /// **'Tạo mới'**
  String get createNew;

  /// No description provided for @editCategory.
  ///
  /// In vi, this message translates to:
  /// **'Chỉnh sửa danh mục'**
  String get editCategory;

  /// No description provided for @name.
  ///
  /// In vi, this message translates to:
  /// **'Tên'**
  String get name;

  /// No description provided for @enterCategoryName.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập vào tên đề mục'**
  String get enterCategoryName;

  /// No description provided for @icons.
  ///
  /// In vi, this message translates to:
  /// **'Biểu tượng'**
  String get icons;

  /// No description provided for @colors.
  ///
  /// In vi, this message translates to:
  /// **'Màu sắc'**
  String get colors;

  /// No description provided for @categoryExists.
  ///
  /// In vi, this message translates to:
  /// **'Tên danh mục này đã tồn tại'**
  String get categoryExists;

  /// No description provided for @categoryAdded.
  ///
  /// In vi, this message translates to:
  /// **'Đã thêm danh mục \"{name}\"'**
  String categoryAdded(String name);

  /// No description provided for @categoryUpdated.
  ///
  /// In vi, this message translates to:
  /// **'Đã cập nhật danh mục \"{name}\"'**
  String categoryUpdated(String name);

  /// No description provided for @monday.
  ///
  /// In vi, this message translates to:
  /// **'Thứ Hai'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In vi, this message translates to:
  /// **'Thứ Ba'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In vi, this message translates to:
  /// **'Thứ Tư'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In vi, this message translates to:
  /// **'Thứ Năm'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In vi, this message translates to:
  /// **'Thứ Sáu'**
  String get friday;

  /// No description provided for @saturday.
  ///
  /// In vi, this message translates to:
  /// **'Thứ Bảy'**
  String get saturday;

  /// No description provided for @sunday.
  ///
  /// In vi, this message translates to:
  /// **'Chủ Nhật'**
  String get sunday;

  /// No description provided for @transactionDeleted.
  ///
  /// In vi, this message translates to:
  /// **'Đã xóa dữ liệu'**
  String get transactionDeleted;

  /// No description provided for @transactionUpdated.
  ///
  /// In vi, this message translates to:
  /// **'Đã chỉnh sửa dữ liệu'**
  String get transactionUpdated;

  /// No description provided for @transactionAdded.
  ///
  /// In vi, this message translates to:
  /// **'Đã thêm dữ liệu'**
  String get transactionAdded;

  /// No description provided for @password.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu'**
  String get password;

  /// No description provided for @edit.
  ///
  /// In vi, this message translates to:
  /// **'Chỉnh sửa'**
  String get edit;

  /// No description provided for @welcomeBack.
  ///
  /// In vi, this message translates to:
  /// **'Chào Mừng Trở Lại'**
  String get welcomeBack;

  /// No description provided for @loginSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập để tiếp tục quản lý thu chi'**
  String get loginSubtitle;

  /// No description provided for @login.
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập'**
  String get login;

  /// No description provided for @noAccount.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có tài khoản? '**
  String get noAccount;

  /// No description provided for @registerNow.
  ///
  /// In vi, this message translates to:
  /// **'Đăng ký ngay'**
  String get registerNow;

  /// No description provided for @pleaseEnterEmail.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập Email'**
  String get pleaseEnterEmail;

  /// No description provided for @invalidEmail.
  ///
  /// In vi, this message translates to:
  /// **'Định dạng Email không hợp lệ'**
  String get invalidEmail;

  /// No description provided for @pleaseEnterPassword.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập mật khẩu'**
  String get pleaseEnterPassword;

  /// No description provided for @passwordTooShort.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu phải từ 6 ký tự trở lên'**
  String get passwordTooShort;

  /// No description provided for @loginSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập thành công!'**
  String get loginSuccess;

  /// No description provided for @register.
  ///
  /// In vi, this message translates to:
  /// **'Đăng ký'**
  String get register;

  /// No description provided for @createAccount.
  ///
  /// In vi, this message translates to:
  /// **'Tạo tài khoản'**
  String get createAccount;

  /// No description provided for @registerSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Bắt đầu quản lý tài chính ngay hôm nay'**
  String get registerSubtitle;

  /// No description provided for @fullName.
  ///
  /// In vi, this message translates to:
  /// **'Họ và tên'**
  String get fullName;

  /// No description provided for @pleaseEnterFullName.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập họ tên'**
  String get pleaseEnterFullName;

  /// No description provided for @confirmPassword.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận mật khẩu'**
  String get confirmPassword;

  /// No description provided for @pleaseConfirmPassword.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng xác nhận mật khẩu'**
  String get pleaseConfirmPassword;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu không khớp'**
  String get passwordsDoNotMatch;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In vi, this message translates to:
  /// **'Đã có tài khoản? '**
  String get alreadyHaveAccount;

  /// No description provided for @loginNow.
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập ngay'**
  String get loginNow;

  /// No description provided for @registerSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Đăng ký thành công!'**
  String get registerSuccess;

  /// No description provided for @atTime.
  ///
  /// In vi, this message translates to:
  /// **'Lúc {time}'**
  String atTime(Object time);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

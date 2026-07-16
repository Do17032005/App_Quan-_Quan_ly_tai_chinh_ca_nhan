// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'Quản lý tài chính';

  @override
  String get dashboard => 'Tổng quan';

  @override
  String get transactions => 'Giao dịch';

  @override
  String get statistics => 'Thống kê';

  @override
  String get settings => 'Cài đặt';

  @override
  String get addTransaction => 'Thêm giao dịch';

  @override
  String get income => 'Thu nhập';

  @override
  String get expense => 'Chi tiêu';

  @override
  String get totalBalance => 'Tổng số dư';

  @override
  String get recentTransactions => 'Giao dịch gần đây';

  @override
  String get viewAll => 'Xem tất cả';

  @override
  String get noTransactions => 'Chưa có giao dịch nào.';

  @override
  String get appearance => 'Giao diện';

  @override
  String get darkMode => 'Chế độ tối';

  @override
  String get hideBalance => 'Ẩn số dư';

  @override
  String get finance => 'Tài chính';

  @override
  String get currency => 'Tiền tệ';

  @override
  String get budgetLimit => 'Hạn mức ngân sách';

  @override
  String get notifications => 'Thông báo';

  @override
  String get dailyReminder => 'Nhắc nhở hàng ngày';

  @override
  String get language => 'Ngôn ngữ';

  @override
  String get calendar => 'Lịch';

  @override
  String get total => 'Tổng cộng';

  @override
  String get startOfMonth => 'Ngày bắt đầu tháng';

  @override
  String get dayPrefix => 'Ngày';

  @override
  String get detailedTransactions => 'Giao dịch chi tiết';

  @override
  String get monthly => 'Hàng Tháng';

  @override
  String get yearly => 'Hàng Năm';

  @override
  String get searchHint => 'Tìm kiếm ghi chú, danh mục...';

  @override
  String get netBalance => 'Thu chi';

  @override
  String noData(String type) {
    return 'Không có dữ liệu $type';
  }

  @override
  String get other => 'Khác';

  @override
  String get noResults => 'Không tìm thấy giao dịch nào';

  @override
  String get filterDetails => 'Bộ lọc chi tiết';

  @override
  String get reset => 'Đặt lại';

  @override
  String get category => 'Danh mục';

  @override
  String get all => 'Tất cả';

  @override
  String get amountRange => 'Khoảng giá';

  @override
  String get from => 'Từ';

  @override
  String get to => 'Đến';

  @override
  String get apply => 'Áp dụng';

  @override
  String get budgetAlert => 'Cảnh báo vượt hạn mức';

  @override
  String get budgetAlertDesc => 'Thông báo khi chi tiêu vượt ngân sách';

  @override
  String get logout => 'Đăng xuất';

  @override
  String get logoutConfirm => 'Bạn có chắc chắn muốn đăng xuất không?';

  @override
  String get cancel => 'Hủy';

  @override
  String get save => 'Lưu';

  @override
  String get setBudgetLimit => 'Thiết lập hạn mức chi tiêu';

  @override
  String get enterAmount => 'Nhập số tiền (ví dụ: 10000000)';

  @override
  String get active => 'Đang bật';

  @override
  String get unlimited => 'Không giới hạn';

  @override
  String get editExpense => 'Sửa khoản chi';

  @override
  String get editIncome => 'Sửa khoản thu';

  @override
  String get copy => 'Sao chép';

  @override
  String get confirmDeleteTransaction =>
      'Bạn có chắc chắn muốn xóa giao dịch này không?';

  @override
  String get saveChanges => 'Lưu thay đổi';

  @override
  String get enterNote => 'Nhập ghi chú';

  @override
  String get date => 'Ngày';

  @override
  String get note => 'Ghi chú';

  @override
  String get noteHintExpense => 'Nhập ghi chú cho khoản chi này...';

  @override
  String get noteHintIncome => 'Nhập ghi chú cho khoản thu này...';

  @override
  String get enterExpense => 'Nhập khoản chi';

  @override
  String get enterIncome => 'Nhập khoản thu';

  @override
  String get pleaseEnterAmount => 'Vui lòng nhập số tiền';

  @override
  String get pleaseSelectCategory => 'Vui lòng chọn danh mục';

  @override
  String get budgetWarning => 'Cảnh báo ngân sách';

  @override
  String budgetWarningDesc(String limit) {
    return 'Khoản chi này sẽ làm tổng chi tiêu vượt hạn mức ($limit). Bạn có chắc chắn muốn tiếp tục?';
  }

  @override
  String get continueText => 'Tiếp tục';

  @override
  String get addCategory => 'Thêm danh mục';

  @override
  String get confirmDelete => 'Xác nhận xóa';

  @override
  String confirmDeleteCategory(String name) {
    return 'Bạn có chắc chắn muốn xóa danh mục \"$name\" không?';
  }

  @override
  String get delete => 'Xóa';

  @override
  String categoryDeleted(String name) {
    return 'Đã xóa danh mục \"$name\"';
  }

  @override
  String get createNew => 'Tạo mới';

  @override
  String get editCategory => 'Chỉnh sửa danh mục';

  @override
  String get name => 'Tên';

  @override
  String get enterCategoryName => 'Vui lòng nhập vào tên đề mục';

  @override
  String get icons => 'Biểu tượng';

  @override
  String get colors => 'Màu sắc';

  @override
  String get categoryExists => 'Tên danh mục này đã tồn tại';

  @override
  String categoryAdded(String name) {
    return 'Đã thêm danh mục \"$name\"';
  }

  @override
  String categoryUpdated(String name) {
    return 'Đã cập nhật danh mục \"$name\"';
  }

  @override
  String get monday => 'Thứ Hai';

  @override
  String get tuesday => 'Thứ Ba';

  @override
  String get wednesday => 'Thứ Tư';

  @override
  String get thursday => 'Thứ Năm';

  @override
  String get friday => 'Thứ Sáu';

  @override
  String get saturday => 'Thứ Bảy';

  @override
  String get sunday => 'Chủ Nhật';

  @override
  String get transactionDeleted => 'Đã xóa dữ liệu';

  @override
  String get transactionUpdated => 'Đã chỉnh sửa dữ liệu';

  @override
  String get transactionAdded => 'Đã thêm dữ liệu';

  @override
  String get password => 'Mật khẩu';

  @override
  String get edit => 'Chỉnh sửa';

  @override
  String get welcomeBack => 'Chào Mừng Trở Lại';

  @override
  String get loginSubtitle => 'Đăng nhập để tiếp tục quản lý thu chi';

  @override
  String get login => 'Đăng nhập';

  @override
  String get noAccount => 'Chưa có tài khoản? ';

  @override
  String get registerNow => 'Đăng ký ngay';

  @override
  String get pleaseEnterEmail => 'Vui lòng nhập Email';

  @override
  String get invalidEmail => 'Định dạng Email không hợp lệ';

  @override
  String get pleaseEnterPassword => 'Vui lòng nhập mật khẩu';

  @override
  String get passwordTooShort => 'Mật khẩu phải từ 6 ký tự trở lên';

  @override
  String get loginSuccess => 'Đăng nhập thành công!';

  @override
  String get register => 'Đăng ký';

  @override
  String get createAccount => 'Tạo tài khoản';

  @override
  String get registerSubtitle => 'Bắt đầu quản lý tài chính ngay hôm nay';

  @override
  String get fullName => 'Họ và tên';

  @override
  String get pleaseEnterFullName => 'Vui lòng nhập họ tên';

  @override
  String get confirmPassword => 'Xác nhận mật khẩu';

  @override
  String get pleaseConfirmPassword => 'Vui lòng xác nhận mật khẩu';

  @override
  String get passwordsDoNotMatch => 'Mật khẩu không khớp';

  @override
  String get alreadyHaveAccount => 'Đã có tài khoản? ';

  @override
  String get loginNow => 'Đăng nhập ngay';

  @override
  String get registerSuccess => 'Đăng ký thành công!';

  @override
  String atTime(Object time) {
    return 'Lúc $time';
  }
}

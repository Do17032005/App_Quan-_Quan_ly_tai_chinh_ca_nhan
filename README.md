# Quản Lý Tài Chính Cá Nhân (Personal Finance App)

Ứng dụng quản lý tài chính cá nhân được phát triển bằng **Flutter**, giúp người dùng theo dõi thu chi, quản lý ngân sách và phân tích tình hình tài chính một cách trực quan và hiệu quả.

## 🚀 Tính Năng Nổi Bật

- **Quản lý thu chi:** Ghi chép và phân loại các khoản thu nhập, chi tiêu hàng ngày.
- **Biểu đồ thống kê:** Trực quan hóa dữ liệu tài chính với các biểu đồ sinh động (sử dụng `fl_chart`).
- **Quản lý ngân sách:** Đặt hạn mức chi tiêu cho các danh mục.
- **Lịch giao dịch:** Xem lại lịch sử giao dịch theo ngày tháng trên lịch (sử dụng `table_calendar`).
- **Đồng bộ dữ liệu (Cloud):** Lưu trữ và đồng bộ hóa dữ liệu trực tuyến với Firebase (Firestore & Authentication).
- **Lưu trữ cục bộ:** Hỗ trợ hoạt động offline với SQLite.
- **Nhắc nhở:** Thông báo nhắc nhở nhập liệu hàng ngày (sử dụng `flutter_local_notifications`).
- **Bàn phím máy tính:** Tích hợp máy tính mini để nhập liệu nhanh chóng.
- **Đa nền tảng:** Hỗ trợ giao diện sáng/tối (Light/Dark Mode) và đa ngôn ngữ.

## 🛠 Công Nghệ Sử Dụng

- **Framework:** Flutter (Dart)
- **State Management:** Provider
- **Database Local:** SQLite (`sqflite`)
- **Database Cloud & Auth:** Firebase (`firebase_core`, `cloud_firestore`, `firebase_auth`)
- **UI/UX Components:** 
  - `fl_chart`: Biểu đồ thống kê
  - `table_calendar`: Hiển thị lịch
  - `font_awesome_flutter` & `cupertino_icons`: Hệ thống icon đa dạng
- **Tiện ích khác:**
  - `intl`: Định dạng tiền tệ và thời gian
  - `shared_preferences`: Lưu trữ cấu hình ứng dụng
  - `math_expressions`: Tính toán biểu thức số học

## 📂 Cấu Trúc Thư Mục

Dự án áp dụng kiến trúc chuẩn giúp dễ dàng mở rộng và bảo trì:

```text
lib/
│
├── core/                  # Các cấu hình dùng chung toàn app
│   ├── constants/         # Màu sắc, font chữ, kích thước cố định
│   └── theme/             # Cấu hình Dark/Light Mode
│
├── data/                  # Nơi xử lý dữ liệu (Local & Remote)
│   ├── database/          # Cài đặt SQLite (Database helper)
│   └── models/            # Các lớp thực thể (Transaction, Category, User...)
│
├── providers/             # Quản lý trạng thái (State Management)
│   ├── finance_provider.dart
│   ├── theme_provider.dart
│   └── settings_provider.dart
│
├── views/                 # Nơi chứa giao diện (UI)
│   ├── dashboard/         # Màn hình chính (Tổng quan số dư, thu chi)
│   ├── transaction/       # Màn hình thêm/sửa giao dịch
│   ├── statistics/        # Màn hình biểu đồ thống kê & phân tích
│   ├── settings/          # Màn hình cài đặt (Theme, Ngôn ngữ, Sync...)
│   └── widgets/           # Các widget dùng chung (Custom Button, Card...)
│
└── main.dart              # Điểm khởi chạy ứng dụng
```

## 💻 Hướng Dẫn Cài Đặt

1. **Yêu cầu hệ thống:** Đảm bảo bạn đã cài đặt [Flutter SDK](https://docs.flutter.dev/get-started/install) (phiên bản ^3.11.4).
2. **Clone repository:**
   ```bash
   git clone <repository_url>
   cd App_Quan-_Quan_ly_tai_chinh_ca_nhan
   ```
3. **Cài đặt các packages:**
   ```bash
   flutter pub get
   ```
4. **Cấu hình Firebase (Nếu có):**
   - Đảm bảo bạn đã thêm các file cấu hình `google-services.json` (Android) và `GoogleService-Info.plist` (iOS) từ Firebase Console vào thư mục tương ứng nếu sử dụng tính năng đồng bộ đám mây.
5. **Chạy ứng dụng:**
   ```bash
   flutter run
   ```


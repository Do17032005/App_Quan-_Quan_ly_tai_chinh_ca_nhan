# app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


lib/
│
├── core/                  # Các cấu hình dùng chung toàn app
│   ├── constants/         # Màu sắc, font chữ, kích thước cố định
│   └── theme/             # Cấu hình Dark/Light Mode
│
├── data/                  # Nơi xử lý dữ liệu thô
│   ├── database/          # Cài đặt SQLite (Database helper)
│   └── models/            # Các lớp thực thể (Transaction, Category)
│
├── providers/             # Quản lý trạng thái (State Management)
│   ├── finance_provider.dart
│   └── theme_provider.dart
│
├── views/                 # Nơi chứa giao diện (UI)
│   ├── dashboard/         # Màn hình chính (Tổng quan)
│   ├── transaction/       # Màn hình thêm/sửa giao dịch
│   ├── analytics/         # Màn hình biểu đồ thống kê
│   └── widgets/           # Các widget dùng chung (Custom Button, Card...)
│
└── main.dart              # Điểm khởi chạy ứng dụng
# SplitMate Frontend

SplitMate là ứng dụng mobile hỗ trợ chia tiền trong nhóm một cách rõ ràng, dễ theo dõi và thuận tiện khi tổng hợp chi tiêu. Project này là frontend Flutter của hệ thống SplitMate, được xây để kết nối với backend hiện có và tiến tới khả năng build, kiểm thử, và phát hành trên Google Play và App Store.

## Mục tiêu của dự án

- Xây dựng ứng dụng mobile cho bài toán chia tiền nhóm.
- Kết nối với backend SplitMate để đồng bộ đăng nhập, nhóm, chi tiêu và thanh toán.
- Tạo nền tảng code rõ ràng để backend developer vẫn có thể tiếp tục phát triển frontend theo từng bước.

## Ứng dụng dùng để làm gì

- Đăng nhập và quản lý phiên làm việc người dùng.
- Xem và quản lý các nhóm chi tiêu.
- Tạo khoản chi, chia tiền cho thành viên trong nhóm.
- Theo dõi ai đã trả, ai còn nợ, và số tiền cần thanh toán.
- Mở rộng dần sang thông báo, cài đặt và hoàn thiện trải nghiệm dùng app.

## Tính năng dự kiến

- Đăng ký tài khoản nội bộ bằng `email + password`.
- Đăng nhập bằng tài khoản nội bộ.
- Đăng nhập bằng Google.
- Quản lý session và token.
- Hồ sơ người dùng.
- Danh sách nhóm.
- Chi tiết nhóm và thành viên.
- Danh sách khoản chi.
- Tạo và cập nhật khoản chi.
- Chia tiền theo dữ liệu backend trả về.
- Theo dõi settlement.
- Nhận và xử lý notification.
- Cài đặt ứng dụng.

## Công nghệ hiện tại

- Flutter
- Dart
- Backend tích hợp: NestJS, TypeORM, PostgreSQL, Redis, JWT

Lưu ý: project hiện đã qua giai đoạn foundation ban đầu và đã hoàn thành auth flow cơ bản, nhưng UI nghiệp vụ chính vẫn đang ở mức khung và placeholder.

## Tài liệu trong repo

- `README.md`: mô tả tổng quan dự án.
- `AGENT.md`: quy tắc làm việc cho AI/code agent trong repo.
- `CODEX.md`: ngữ cảnh để Codex hoặc AI khác tiếp tục hỗ trợ đúng hướng.
- `ARCHITECTURE.md`: kiến trúc Flutter dự kiến của app.
- `PROCESS_PROJECT.md`: roadmap và trạng thái triển khai theo phase.

## Trạng thái hiện tại

- Backend đã có Auth và Group Management.
- Frontend Flutter đã xong:
  - `Phase 0 - Documentation & Direction`
  - `Phase 1 - Flutter Foundation Setup`
  - `Phase 2 - Dependencies Setup`
  - `Phase 3 - Auth UI & Session Flow`
- Auth hiện hỗ trợ:
  - local register bằng `email + password`
  - local login bằng `email + password`
  - Google sign-in
  - secure storage cho token
  - bootstrap session khi mở lại app
- Phase hiện tại: chuẩn bị sang `Phase 4 - Main Layout & Navigation`.

## Hướng phát triển tiếp theo

Sau khi chốt auth flow ở Phase 3, bước tiếp theo là làm `Phase 4 - Main Layout & Navigation`: tạo shell sau login, bảo vệ route, và chuẩn hóa điều hướng giữa khu vực public và authenticated.

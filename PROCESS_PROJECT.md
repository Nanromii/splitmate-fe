# PROCESS_PROJECT.md

## A. Trạng thái hiện tại

- Backend: Auth đã xong, Group Management đã xong.
- Frontend Flutter: mới khởi tạo project.
- Trạng thái hiện tại của Flutter: `Phase 0 - Documentation & Direction`.
- Bước đang làm: tạo tài liệu nền tảng cho AI/dev.
- Bước tiếp theo sau khi xong docs: setup foundation Flutter project.

## B. Nguyên tắc làm dự án

- Làm theo từng phase nhỏ.
- Mỗi phase phải có output rõ ràng.
- Không nhảy ngay vào UI phức tạp khi chưa có foundation.
- Với người chưa mạnh Flutter, mỗi phase phải ghi rõ:
  - Mục tiêu
  - Việc cần làm
  - File/folder sẽ đụng tới
  - Kết quả mong đợi
  - Cách kiểm tra
  - Commit message gợi ý

## C. Roadmap tổng thể

### Phase 0 - Documentation & Direction

Mục tiêu:

- Tạo `AGENT.md`, `CODEX.md`, `ARCHITECTURE.md`, `PROCESS_PROJECT.md`.

Checklist:

- [x] Tạo `AGENT.md`
- [x] Tạo `CODEX.md`
- [x] Tạo `ARCHITECTURE.md`
- [x] Tạo `PROCESS_PROJECT.md`
- [x] Review lại docs
- [ ] Commit docs

Done khi:

- Có đủ 4 file MD.
- Tài liệu đủ rõ để AI/dev biết bước tiếp theo.

Commit gợi ý:
`docs: add flutter project direction documents`

### Phase 1 - Flutter Foundation Setup

Mục tiêu:

- Setup nền móng app trước khi làm feature.

Việc cần làm:

- Chuẩn hóa cấu trúc thư mục `lib/`.
- Tạo `app/app.dart`.
- Tạo theme cơ bản.
- Tạo router cơ bản.
- Tạo config môi trường dev.
- Tạo màn hình splash hoặc placeholder.
- Đảm bảo app chạy được không lỗi.

File/folder sẽ đụng tới:

- `lib/main.dart`
- `lib/app/`
- `lib/core/`
- `lib/shared/`
- `lib/features/`

Kết quả mong đợi:

- App có bộ khung rõ ràng để bắt đầu phát triển feature.

Cách kiểm tra:

- Chạy app thành công.
- Chạy `flutter analyze`.

Checklist:

- [ ] Chuẩn hóa cấu trúc thư mục `lib/`
- [ ] Tạo `app/app.dart`
- [ ] Tạo theme cơ bản
- [ ] Tạo router cơ bản
- [ ] Tạo config môi trường dev
- [ ] Tạo màn hình splash hoặc placeholder
- [ ] Chạy được app không lỗi
- [ ] Chạy `flutter analyze`

Done khi:

- App chạy được.
- Có route ban đầu.
- Có theme cơ bản.
- Cấu trúc folder đúng với `ARCHITECTURE.md`.

Commit gợi ý:
`chore: setup flutter app foundation`

### Phase 2 - Dependencies Setup

Mục tiêu:

- Thêm package cần thiết một cách có kiểm soát.

Việc cần làm:

- Chọn package navigation.
- Chọn package state management.
- Chọn package HTTP client.
- Chọn package secure storage.
- Chọn package env/config nếu cần.

File/folder sẽ đụng tới:

- `pubspec.yaml`
- `pubspec.lock`
- Có thể cập nhật `ARCHITECTURE.md` hoặc `CODEX.md` nếu định hướng thay đổi

Kết quả mong đợi:

- Dependency được thêm có lý do và dùng được ngay.

Cách kiểm tra:

- Chạy `flutter pub get`.
- Chạy app.
- Chạy `flutter analyze`.

Checklist:

- [ ] Thêm navigation package
- [ ] Thêm state management package
- [ ] Thêm HTTP client package
- [ ] Thêm secure storage package
- [ ] Thêm env/config package nếu cần
- [ ] Kiểm tra app vẫn chạy
- [ ] Cập nhật docs nếu dependency thay đổi kiến trúc

Done khi:

- Dependency được thêm có lý do.
- Không thêm package thừa.
- App vẫn chạy ổn.

Commit gợi ý:
`chore: add core flutter dependencies`

### Phase 3 - Auth UI & Session Flow

Mục tiêu:

- Làm luồng đăng nhập Google và quản lý session phía mobile.

Việc cần làm:

- Đọc API contract Auth từ Swagger hoặc BE docs.
- Tạo model, API layer, state cho auth.
- Tạo login screen.
- Tích hợp Google sign-in theo đúng contract backend.
- Lưu token an toàn.
- Xử lý login, logout, token expired.

File/folder sẽ đụng tới:

- `lib/features/auth/`
- `lib/core/network/`
- `lib/core/storage/`
- `lib/app/router/`

Kết quả mong đợi:

- User đăng nhập được và app nhớ session.

Cách kiểm tra:

- Test login/logout thủ công.
- Kiểm tra mở lại app vẫn giữ session nếu token còn hiệu lực.

Checklist:

- [ ] Đọc API contract Auth từ Swagger/BE docs
- [ ] Tạo auth models
- [ ] Tạo auth API client/repository
- [ ] Tạo auth provider/state
- [ ] Tạo login screen
- [ ] Tích hợp Google sign-in theo contract backend
- [ ] Lưu access token/refresh token an toàn
- [ ] Tự điều hướng sau login
- [ ] Xử lý logout
- [ ] Xử lý token expired nếu backend đã có refresh token
- [ ] Test login/logout thủ công

Done khi:

- User login được bằng Google.
- Token được lưu.
- App nhớ session sau khi mở lại.
- Logout xóa session.

Commit gợi ý:
`feat(auth): implement google login flow`

### Phase 4 - Main Layout & Navigation

Mục tiêu:

- Tạo layout chính sau khi đăng nhập.

Việc cần làm:

- Tạo shell hoặc main navigation.
- Tạo placeholder cho các màn chính.
- Bảo vệ route cần login.

File/folder sẽ đụng tới:

- `lib/app/router/`
- `lib/features/`
- `lib/shared/widgets/`

Kết quả mong đợi:

- Có khung app chính và flow điều hướng rõ ràng.

Cách kiểm tra:

- Test điều hướng giữa login và khu vực chính.

Checklist:

- [ ] Tạo main shell/navigation
- [ ] Tạo tabs hoặc bottom navigation nếu phù hợp
- [ ] Tạo placeholder các màn chính
- [ ] Bảo vệ route cần login
- [ ] Điều hướng logout/login hợp lý

Done khi:

- Có khung app chính.
- User chưa login không vào được màn chính.
- User login vào đúng home.

Commit gợi ý:
`feat(app): add authenticated main navigation`

### Phase 5 - Groups

Mục tiêu:

- Tích hợp Group Management từ backend.

Việc cần làm:

- Đọc API group.
- Tạo models, API layer, provider/state.
- Tạo group list, group detail, member list.
- Tạo create/update group flow nếu backend hỗ trợ.

File/folder sẽ đụng tới:

- `lib/features/groups/`
- `lib/app/router/`
- `lib/shared/widgets/`

Kết quả mong đợi:

- Quản lý group được từ app mobile.

Cách kiểm tra:

- Test xem danh sách, xem chi tiết, tạo group.

Checklist:

- [ ] Đọc API group từ Swagger/BE docs
- [ ] Tạo group models
- [ ] Tạo group API/repository
- [ ] Tạo group list screen
- [ ] Tạo group detail screen
- [ ] Tạo create group flow
- [ ] Tạo update group flow nếu backend có
- [ ] Tạo member list
- [ ] Xử lý loading/error/empty state
- [ ] Pull to refresh nếu phù hợp

Done khi:

- Xem được danh sách group.
- Tạo được group.
- Xem được chi tiết group.
- Xem được member.

Commit gợi ý:
`feat(groups): implement group management screens`

### Phase 6 - Expenses

Mục tiêu:

- Làm chức năng chi tiêu trong nhóm.

Việc cần làm:

- Đọc API expense.
- Tạo model, API layer, provider/state.
- Tạo list, detail, create/update expense.
- Tạo split input UI và validate form.

File/folder sẽ đụng tới:

- `lib/features/expenses/`
- `lib/features/groups/`
- `lib/shared/widgets/`

Kết quả mong đợi:

- Tạo và hiển thị expense đúng theo dữ liệu backend.

Cách kiểm tra:

- Test tạo expense và xem detail thủ công.

Checklist:

- [ ] Đọc API expense từ Swagger/BE docs
- [ ] Tạo expense models
- [ ] Tạo expense API/repository
- [ ] Tạo expense list trong group detail
- [ ] Tạo create expense screen
- [ ] Tạo split input UI
- [ ] Validate form phía UI
- [ ] Xử lý payer/member/split amount
- [ ] Xem chi tiết expense
- [ ] Update/delete nếu backend hỗ trợ

Done khi:

- Tạo được expense.
- Xem được danh sách expense.
- Xem được chi tiết expense.
- Split hiển thị đúng theo dữ liệu backend.

Commit gợi ý:
`feat(expenses): implement expense flow`

### Phase 7 - Settlements

Mục tiêu:

- Hiển thị và xử lý thanh toán hoặc bù trừ.

Việc cần làm:

- Đọc API settlement.
- Tạo model, API layer, state.
- Tạo summary và detail nếu cần.

File/folder sẽ đụng tới:

- `lib/features/settlements/`
- `lib/shared/widgets/`

Kết quả mong đợi:

- Người dùng hiểu được ai nợ ai và số tiền tương ứng.

Cách kiểm tra:

- Test xem dữ liệu settlement và luồng thao tác liên quan.

Checklist:

- [ ] Đọc API settlement từ Swagger/BE docs
- [ ] Tạo settlement models
- [ ] Tạo settlement API/repository
- [ ] Tạo settlement summary screen
- [ ] Tạo settlement detail nếu cần
- [ ] Mark as settled nếu backend hỗ trợ
- [ ] Hiển thị ai nợ ai, bao nhiêu tiền

Done khi:

- User xem được tổng kết nợ.
- Settlement hiển thị dễ hiểu.

Commit gợi ý:
`feat(settlements): implement settlement summary`

### Phase 8 - Notifications

Mục tiêu:

- Tích hợp thông báo nếu backend hỗ trợ.

Việc cần làm:

- Đọc API notification hoặc device token.
- Tạo model và màn hình liên quan.
- Tích hợp push notification khi cần.

File/folder sẽ đụng tới:

- `lib/features/notifications/`
- `lib/core/storage/`
- `lib/core/network/`

Kết quả mong đợi:

- App quản lý được notification và device token đúng hướng.

Cách kiểm tra:

- Test nhận notification hoặc flow gửi device token tùy backend hỗ trợ tới đâu.

Checklist:

- [ ] Đọc API notification/device token từ Swagger/BE docs
- [ ] Tạo notification models
- [ ] Tạo notification screen
- [ ] Tích hợp Firebase Messaging nếu cần
- [ ] Gửi device token lên backend
- [ ] Xử lý notification click
- [ ] Xử lý logout thì xóa/unregister device token nếu backend hỗ trợ

Done khi:

- App nhận hoặc hiển thị được notification theo khả năng backend.
- Device token được quản lý đúng.

Commit gợi ý:
`feat(notifications): add notification flow`

### Phase 9 - Polish UX

Mục tiêu:

- Làm app dễ dùng hơn.

Việc cần làm:

- Chuẩn hóa loading, error, empty state.
- Chuẩn hóa format tiền tệ và ngày giờ.
- Thêm confirm dialog, snackbar hoặc toast hợp lý.
- Kiểm tra responsive cơ bản.

File/folder sẽ đụng tới:

- `lib/shared/`
- `lib/app/theme/`
- Các feature liên quan

Kết quả mong đợi:

- Trải nghiệm dùng app mượt và nhất quán hơn.

Cách kiểm tra:

- Review thủ công trên các màn hình chính.

Checklist:

- [ ] Chuẩn hóa loading
- [ ] Chuẩn hóa error message
- [ ] Chuẩn hóa empty state
- [ ] Format tiền tệ
- [ ] Format ngày giờ
- [ ] Confirm dialog cho hành động nguy hiểm
- [ ] Snackbar/toast cho kết quả thao tác
- [ ] Kiểm tra responsive cơ bản

Done khi:

- App dùng mượt hơn.
- Không còn UI placeholder quan trọng.

Commit gợi ý:
`chore(ui): polish common user experience`

### Phase 10 - Testing & Release Preparation

Mục tiêu:

- Chuẩn bị build thật và phát hành nội bộ.

Việc cần làm:

- Analyze, test, build.
- Setup icon, splash, app name.
- Setup environment production.
- Kiểm tra permission và release config.

File/folder sẽ đụng tới:

- `pubspec.yaml`
- `android/`
- `ios/`
- `lib/`

Kết quả mong đợi:

- App build được bản release để test nội bộ.

Cách kiểm tra:

- Chạy build Android.
- Kiểm tra iOS khi có môi trường phù hợp.

Checklist:

- [ ] Chạy `flutter analyze`
- [ ] Chạy test nếu có
- [ ] Kiểm tra Android build
- [ ] Kiểm tra iOS build sau này nếu có Mac
- [ ] Setup app icon
- [ ] Setup splash screen
- [ ] Setup app name
- [ ] Setup environment production
- [ ] Kiểm tra permission
- [ ] Kiểm tra release config

Done khi:

- App build được bản release.
- Sẵn sàng test nội bộ.

Commit gợi ý:
`chore: prepare mobile release build`

## D. Bước hiện tại và bước tiếp theo

```txt
Current phase: Phase 0 - Documentation & Direction
Current task: Create foundational project documentation
Next task: Setup Flutter foundation structure
```

## E. Template cập nhật tiến độ

```md
## Progress Log

### YYYY-MM-DD
- Done:
- Changed files:
- Notes:
- Next:
```

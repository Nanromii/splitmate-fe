# CODEX.md

## Vai trò khi làm việc trong repo này

AI/Codex đang đóng vai trò Flutter mobile developer hỗ trợ xây dựng ứng dụng SplitMate. Mục tiêu là giúp project đi từ nền tảng ban đầu tới app mobile có thể build, test và publish về sau.

## Bối cảnh cần luôn ghi nhớ

- Chủ project là backend developer.
- Khi tạo code hoặc hướng dẫn, cần giải thích rõ các khái niệm Flutter/FE.
- Ngôn ngữ giao tiếp chính là tiếng Việt.
- Tên biến, class, method, file phải dùng tiếng Anh.
- Comment chỉ thêm khi thật sự cần để làm rõ logic khó hiểu.

## SplitMate là ứng dụng gì

SplitMate là ứng dụng hỗ trợ chia tiền trong nhóm. App mobile sẽ là nơi người dùng đăng nhập, quản lý nhóm, tạo khoản chi, theo dõi chia tiền và xem nghĩa vụ thanh toán.

## Các module dự kiến của app

- Auth bằng local account và Google
- Session/token
- User profile
- Group list
- Group detail
- Group member
- Expense list
- Create/update expense
- Expense split
- Settlement
- Notification
- Settings

## Nguyên tắc khi làm việc với backend

- Backend là nguồn sự thật cho business logic.
- Frontend không tự quyết định rule khác với backend.
- Khi thiếu API contract, phải ghi rõ cần lấy từ Swagger hoặc BE docs.
- Không đoán request/response schema.
- Nếu field hoặc flow chưa rõ, ưu tiên đánh dấu chỗ cần xác nhận.

## Nguồn API contract

- Ưu tiên lấy từ Swagger do backend expose.
- Nếu Swagger chưa đủ, dùng tài liệu backend hoặc hỏi rõ BE.
- Không xem mock UI là nguồn sự thật cho business data.

## Phong cách hỗ trợ chủ project

Khi trả lời hoặc hướng dẫn, cần:

- Giải thích từng bước.
- Có thứ tự thực hiện rõ ràng.
- Có lệnh terminal khi cần.
- Có file path rõ ràng.
- Có lý do ngắn gọn vì sao làm vậy.
- Tránh nói quá chung chung hoặc bỏ qua các bước nền tảng.

## Cách viết prompt tiếp theo cho Codex

Để làm việc hiệu quả hơn, prompt tiếp theo nên có:

- Mục tiêu cụ thể.
- Scope rõ ràng: chỉ docs, chỉ phân tích, hay được phép sửa code.
- File hoặc module liên quan.
- Kết quả mong muốn.
- Nếu có, đính kèm API contract hoặc ảnh UI.

Ví dụ prompt tốt:

```md
Hãy tạo foundation cho Flutter app theo ARCHITECTURE.md.
Chỉ sửa trong lib/.
Chưa thêm package mới.
Sau khi làm xong hãy nêu file nào đã tạo và bước tiếp theo.
```

## Điều cần tránh

- Không tự mở rộng scope khi chưa được giao.
- Không thêm dependency chỉ vì “sẽ có thể cần”.
- Không áp dụng kiến trúc quá nặng khi project còn nhỏ.
- Không trả lời kiểu FE mặc định mà bỏ qua bối cảnh backend-first của project.

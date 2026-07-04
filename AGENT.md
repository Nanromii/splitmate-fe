# AGENT.md

## Vai trò của AI agent

AI agent trong repo này là người hỗ trợ phát triển Flutter frontend cho ứng dụng SplitMate theo từng bước nhỏ, dễ review, dễ tiếp tục. Agent phải ưu tiên tính rõ ràng, tính kiểm soát và giải thích dễ hiểu cho chủ project là backend developer.

## Những việc agent được phép làm

- Đọc tài liệu và source code hiện có để hiểu bối cảnh trước khi sửa.
- Tạo hoặc cập nhật file tài liệu trong phạm vi task được giao.
- Sửa code trong phạm vi feature hoặc bug được yêu cầu rõ ràng.
- Đề xuất cấu trúc folder, flow màn hình, state, navigation phù hợp với định hướng repo.
- Chạy format, analyze, test khi cần và khi môi trường cho phép.
- Cập nhật `PROCESS_PROJECT.md` nếu task làm thay đổi trạng thái tiến độ dự án.

## Những việc agent không được tự ý làm

- Không tự thêm package vào `pubspec.yaml` nếu chưa có lý do rõ ràng và chưa nêu tác động.
- Không tự refactor diện rộng khi user chỉ yêu cầu một thay đổi nhỏ.
- Không tự đổi kiến trúc đang dùng nếu chưa phân tích và chưa được đồng ý.
- Không tự đoán API contract khi chưa có Swagger hoặc backend docs.
- Không tự tạo quá nhiều abstraction, helper, base class nếu chưa cần thật sự.
- Không sửa file ngoài phạm vi task nếu không bắt buộc.

## Quy tắc trước khi sửa code

1. Đọc `CODEX.md`.
2. Đọc `ARCHITECTURE.md`.
3. Đọc `PROCESS_PROJECT.md`.
4. Xác định task đang thuộc phase nào.
5. Tìm đúng file liên quan trước khi sửa.
6. Chỉ sửa phạm vi cần thiết để giải quyết task.
7. Sau khi sửa, chạy format/analyze/test nếu có thể.
8. Nếu task làm thay đổi tiến độ dự án, cập nhật `PROCESS_PROJECT.md`.

## Quy tắc khi thêm package Flutter

- Chỉ thêm package khi feature thật sự cần.
- Trước khi thêm phải nêu rõ:
  - Package dùng để làm gì.
  - Vì sao package hiện có hoặc Flutter core chưa đủ.
  - Ảnh hưởng tới kiến trúc và bảo trì sau này.
- Ưu tiên package phổ biến, ổn định, cộng đồng dùng nhiều.
- Không thêm nhiều package cùng lúc nếu chưa sử dụng ngay.
- Sau khi thêm package phải cập nhật tài liệu liên quan nếu nó ảnh hưởng cấu trúc dự án.

## Quy tắc khi tạo màn hình mới

- Chỉ tạo màn hình khi đã xác định rõ nó thuộc feature nào.
- Mỗi màn hình phải đặt đúng chỗ trong `features/<feature>/screens/`.
- Không nhét quá nhiều UI logic, API logic và state logic vào một file screen.
- Widget dùng lại được thì tách vào `widgets/` của feature hoặc `shared/widgets/` nếu thật sự dùng chung.
- Màn hình mới nên có trạng thái loading, error, empty rõ ràng nếu có dữ liệu từ API.

## Quy tắc khi gọi API backend

- Không tự suy diễn request/response nếu chưa có contract.
- Nguồn ưu tiên của contract là Swagger hoặc tài liệu backend.
- Mapping request/response phải bám sát field từ backend.
- Business rule phía frontend không được mâu thuẫn với backend.
- Nếu contract còn thiếu hoặc chưa rõ, phải ghi rõ chỗ cần xác nhận thay vì đoán.

## Quy tắc về state management

- Ưu tiên state management đơn giản, dễ đọc, dễ giải thích.
- Mặc định theo định hướng của repo là `flutter_riverpod`.
- State chỉ nên giữ những gì UI cần để render hoặc trigger hành động.
- Không để network call rải rác trong widget tree nếu đã có provider/state phụ trách.
- Không tạo tầng state quá phức tạp khi feature còn nhỏ.

## Quy tắc về navigation

- Navigation nên tập trung và có cấu trúc, không hardcode điều hướng khắp nơi nếu có thể gom lại.
- Theo định hướng repo, navigation sẽ đi qua router tập trung trong `app/router/`.
- Route cần đặt tên dễ hiểu, bám theo flow nghiệp vụ.
- Route cần bảo vệ đăng nhập phải được xử lý nhất quán.

## Quy tắc về error/loading/empty state

- Mọi màn hình dữ liệu đều phải nghĩ tới 3 trạng thái: loading, error, empty.
- Không chỉ xử lý happy path.
- Thông báo lỗi nên dễ hiểu, không lộ chi tiết kỹ thuật nếu không cần.
- Empty state nên nói rõ người dùng cần làm gì tiếp theo.
- Loading UI nên nhất quán trong toàn app.

## Quy tắc về naming convention

- Tên file, class, variable, method dùng tiếng Anh.
- Tên phải mô tả đúng vai trò.
- Screen đặt tên theo màn hình, ví dụ `group_list_screen.dart`.
- Provider đặt tên theo state hoặc use case, ví dụ `auth_session_provider.dart`.
- Widget tái sử dụng đặt tên theo UI purpose, ví dụ `expense_item_card.dart`.
- Không viết tắt khó hiểu nếu không phải từ quá phổ biến.

## Quy tắc commit message

- Commit ngắn, rõ, bám đúng phạm vi thay đổi.
- Ưu tiên format như:
  - `docs: ...`
  - `chore: ...`
  - `feat(auth): ...`
  - `feat(groups): ...`
  - `fix(expenses): ...`
- Không gộp quá nhiều loại thay đổi khác nhau vào một commit nếu có thể tách.

## Quy tắc không làm quá tay

- Nếu task là một sửa đổi nhỏ, chỉ sửa phần phục vụ trực tiếp cho task đó.
- Không mở rộng thành refactor toàn feature nếu user chưa yêu cầu.
- Không thay đổi naming, cấu trúc folder, state pattern hàng loạt chỉ vì “thấy hợp lý hơn”.
- Nếu phát hiện vấn đề lớn ngoài scope, ghi chú lại như một đề xuất riêng thay vì tự ý sửa lan rộng.

## Quy trình chuẩn khi nhận task mới

1. Đọc `CODEX.md`.
2. Đọc `ARCHITECTURE.md`.
3. Đọc `PROCESS_PROJECT.md`.
4. Xác định task thuộc phase nào.
5. Chỉ sửa file liên quan.
6. Chạy format/analyze/test nếu có thể.
7. Cập nhật `PROCESS_PROJECT.md` nếu task làm thay đổi tiến độ.

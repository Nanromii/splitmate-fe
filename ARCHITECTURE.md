# ARCHITECTURE.md

## Mục tiêu kiến trúc

Kiến trúc của project Flutter SplitMate nên đủ rõ để backend developer vẫn có thể đọc, tiếp tục làm, và review được. Vì vậy, định hướng phù hợp là `feature-first` kết hợp `core/shared`, tránh dùng Clean Architecture quá nặng ở giai đoạn đầu.

## Định hướng tổng thể

- Tổ chức code theo feature để dễ mở rộng theo nghiệp vụ.
- Gom phần dùng chung toàn app vào `core/` và `shared/`.
- Tránh tạo quá nhiều tầng abstraction khi số lượng feature còn ít.
- Ưu tiên cấu trúc dễ tìm file, dễ sửa, dễ onboarding.

## Cấu trúc thư mục dự kiến

```txt
lib/
  main.dart
  app/
    app.dart
    router/
    theme/
  core/
    constants/
    config/
    network/
    storage/
    errors/
    utils/
  shared/
    widgets/
    models/
    extensions/
  features/
    auth/
      data/
      models/
      providers/
      screens/
      widgets/
    groups/
      data/
      models/
      providers/
      screens/
      widgets/
    expenses/
      data/
      models/
      providers/
      screens/
      widgets/
    settlements/
      data/
      models/
      providers/
      screens/
      widgets/
    notifications/
      data/
      models/
      providers/
      screens/
      widgets/
```

## Giải thích từng khu vực

### `app/`

Chứa cấu hình cấp ứng dụng:

- `app.dart`: điểm tập trung khởi tạo `MaterialApp` hoặc `MaterialApp.router`.
- `router/`: định nghĩa route, redirect, guard, shell navigation.
- `theme/`: màu sắc, typography, component theme, style dùng toàn app.

`app/` là nơi gom những gì mang tính “khung ứng dụng”, không thuộc riêng feature nào.

### `core/`

Chứa phần hạ tầng dùng xuyên suốt toàn app:

- `constants/`: hằng số toàn cục.
- `config/`: môi trường, base URL, app config.
- `network/`: HTTP client, interceptor, request setup.
- `storage/`: local storage, secure storage, token persistence.
- `errors/`: app exception, failure mapping, error helper.
- `utils/`: helper nhỏ có tính dùng lại cao.

`core/` dành cho phần nền kỹ thuật, không chứa UI của nghiệp vụ.

### `shared/`

Chứa thành phần dùng chung nhưng không phải hạ tầng kỹ thuật:

- `widgets/`: widget tái sử dụng ở nhiều feature.
- `models/`: model dùng chung giữa nhiều feature nếu thật sự cần.
- `extensions/`: extension dùng lại cho UI hoặc data formatting.

Nếu một widget chỉ dùng trong một feature, không đưa lên `shared/`.

### `features/`

Đây là nơi chứa nghiệp vụ chính của app. Mỗi feature có thư mục riêng để dễ cô lập phạm vi sửa đổi.

Ví dụ:

- `features/auth/`
- `features/groups/`
- `features/expenses/`
- `features/settlements/`
- `features/notifications/`

Mỗi feature nên tự chứa phần data, model, provider/state, screen và widget phụ trợ của nó.

## Khi nào tạo folder mới

- Khi xuất hiện feature nghiệp vụ mới đủ lớn để quản lý riêng.
- Khi một nhóm file có trách nhiệm rõ ràng và sẽ còn mở rộng.
- Khi phần dùng chung thật sự được dùng từ nhiều nơi.

## Khi nào không nên tạo folder mới

- Khi chỉ có 1 file nhỏ và chưa có dấu hiệu mở rộng.
- Khi việc tách folder chỉ làm tăng độ rối mà không tăng độ rõ ràng.
- Khi một widget/helper chỉ dùng nội bộ cho một file ngắn.

## Data layer gồm gì

Trong mỗi feature, `data/` nên chứa:

- API service hoặc remote data source.
- Repository đơn giản nếu cần gom logic gọi API.
- Mapper chuyển dữ liệu thô sang model dùng trong app.

Không nên nhét widget logic hoặc navigation vào data layer.

## Model dùng để làm gì

`models/` dùng để biểu diễn dữ liệu của feature:

- Request model nếu cần gửi dữ liệu có cấu trúc.
- Response model nhận từ backend.
- UI-friendly model nếu thật sự cần tách riêng.

Model phải bám sát backend contract, không tự thêm rule nghiệp vụ trái backend.

## Provider/state dùng để làm gì

`providers/` là nơi quản lý state và orchestration cho UI:

- Giữ loading/data/error state.
- Gọi data layer để lấy hoặc gửi dữ liệu.
- Xử lý event từ UI theo cách dễ test, dễ đọc.

Theo định hướng hiện tại, state management nên dùng `flutter_riverpod`.

## Screen khác widget như thế nào

- `screens/` là màn hình hoàn chỉnh gắn với route hoặc flow người dùng.
- `widgets/` là thành phần UI con hỗ trợ cho screen.

Ví dụ:

- `group_list_screen.dart` là screen.
- `group_card.dart` hoặc `group_empty_state.dart` là widget.

## API client đặt ở đâu

API client tổng quát nên đặt trong `core/network/`.

Ví dụ các phần có thể nằm ở đó:

- `dio` client setup
- interceptor
- auth header injection
- logging cơ bản
- timeout config

Feature chỉ nên dùng lại network client này, không tự dựng client mới tùy tiện.

Quy ước hiện tại:

- `dioProvider` tạo một Dio client dùng chung cho public và protected API.
- Public auth routes gồm register, login, Google login và refresh không bị tự gắn bearer token.
- Protected API tự đọc access token từ secure storage và gắn `Authorization: Bearer <accessToken>` trong interceptor.
- Khi protected API trả `401` hoặc `403`, interceptor dùng refresh token trong secure storage để gọi `/auth/refresh`, lưu token pair mới và retry request cũ một lần.
- Nếu refresh thất bại, interceptor clear session local và phát tín hiệu để `AuthController` chuyển app về trạng thái unauthenticated.
- Các refresh đồng thời dùng chung một refresh Future để tránh rotate refresh token nhiều lần cùng lúc.

## Token storage đặt ở đâu

Token storage nên đặt trong `core/storage/`.

Về sau có thể dùng secure storage để lưu:

- access token
- refresh token
- session metadata nếu cần

Hiện app đã lưu access token và refresh token trong secure storage. Session metadata chi tiết như `sessionId` và `expiresIn` vẫn lấy từ auth response khi login/register/refresh, chưa có persistence riêng.

Không nên lưu token rải rác ở nhiều feature.

## Error handling đặt ở đâu

Phần hạ tầng error nên đặt trong `core/errors/`.

Bao gồm:

- app exception
- network error mapping
- helper chuyển lỗi kỹ thuật thành message phù hợp với UI

Mỗi feature có thể bổ sung cách diễn giải lỗi riêng, nhưng nền chung nên thống nhất.

## Quy ước loading, empty, error state

- Loading phải có kiểu hiển thị nhất quán.
- Empty state phải mô tả rõ vì sao chưa có dữ liệu và người dùng nên làm gì tiếp.
- Error state phải có thông điệp dễ hiểu và nút thử lại nếu hợp lý.
- Không để mỗi màn hình tự xử lý hoàn toàn khác nhau nếu có thể tái dùng pattern chung.

## Navigation nên tập trung ở đâu

Navigation nên tập trung trong `app/router/`.

Lý do:

- Dễ theo dõi flow toàn app.
- Dễ xử lý guard theo trạng thái đăng nhập.
- Dễ mở rộng shell navigation khi app có nhiều tab hoặc khu vực chính.

Theo định hướng hiện tại, package phù hợp là `go_router`.

Quy ước hiện tại:

- Public routes gồm splash và login.
- Authenticated area dùng `StatefulShellRoute` trong `app/router/`.
- Các branch chính hiện có: Home, Groups, Activity và Settings.
- Screen nghiệp vụ đặt trong feature tương ứng, không để main app placeholder trong `features/auth`.

## Theme nên tập trung ở đâu

Theme nên tập trung trong `app/theme/`.

Nơi đây có thể quản lý:

- color palette
- text theme
- spacing rule nếu cần
- button/input style

Theme tập trung giúp UI đồng nhất và giảm hardcode style trong screen.

## Công nghệ dự kiến

- Flutter
- Dart
- `go_router` cho navigation
- `dio` cho HTTP client
- `flutter_riverpod` cho state management
- `freezed` hoặc `json_serializable` có thể bổ sung sau khi model bắt đầu nhiều và lặp lại
- Secure storage cho token về sau
- Firebase Messaging cho push notification về sau nếu backend hỗ trợ FCM

## Lý do chọn hướng này

- Dễ tiếp cận với backend developer mới làm Flutter.
- Không quá nặng như Clean Architecture đầy đủ.
- Đủ rõ để mở rộng từ Auth sang Groups, Expenses, Settlements.
- Dễ kiểm soát phạm vi sửa file theo từng feature.

## Lưu ý quan trọng

- Tài liệu này chỉ mô tả kiến trúc dự kiến.
- Không thêm dependency ngay trong task hiện tại.
- Không khóa version package trong tài liệu.
- Khi project lớn hơn, có thể nâng cấp dần cách tổ chức nhưng chỉ khi có nhu cầu thực tế.

# SplitMate Frontend Learning Guide

Tài liệu này giải thích project Flutter hiện tại cho người mới học Flutter nhưng đã quen backend, API, auth và token. Nội dung bên dưới bám vào source hiện tại, không mô tả lý thuyết Flutter chung chung.

## 1. Tổng quan project

SplitMate là app mobile để chia tiền trong nhóm. Frontend hiện đã có:

- Đăng ký, đăng nhập bằng email/password và đăng nhập Google.
- Lưu access token / refresh token trong secure storage.
- Bootstrap session khi mở app.
- Authenticated shell với các tab Home, Groups, Activity, Settings.
- Quản lý nhóm: list, create, detail, edit, delete, add member, leave group, transfer owner.
- Quản lý khoản chi trong group: list, create, detail, edit, delete, split type hiện là `EQUAL`.

Công nghệ chính đang dùng:

- Flutter + Dart: toàn bộ app mobile.
- Riverpod: dependency injection và state management, qua `Provider`, `StateNotifierProvider`, `StateNotifierProvider.family`.
- go_router: routing, redirect auth, nested routes.
- Dio: HTTP client.
- flutter_secure_storage: lưu token local.
- flutter_dotenv: đọc `.env.development.local`.
- google_sign_in: Google login flow.

Sơ đồ thư mục cấp cao:

```text
lib/
  main.dart
  app/
    app.dart
    router/
    theme/
  core/
    config/
    network/
    storage/
  features/
    auth/
    groups/
    expenses/
    main/
    settings/
  shared/
    widgets/
```

Ý nghĩa nhanh:

- `lib/main.dart`: điểm chạy đầu tiên của app, load env, tạo config, bọc app bằng `ProviderScope`.
- `lib/app/`: cấu hình app-level như `MaterialApp.router`, route, theme.
- `lib/core/`: phần dùng chung cấp nền tảng như config, Dio, secure storage.
- `lib/features/`: từng module nghiệp vụ. Hiện có auth, groups, expenses, main shell, settings.
- `lib/shared/`: widget dùng chung. Hiện mới thấy `PlaceholderScreen`.

## 2. Các nhóm file quan trọng

### App entrypoint

File nên đọc trước:

- `lib/main.dart`
- `lib/app/app.dart`

`lib/main.dart` làm 4 việc chính:

1. Gọi `WidgetsFlutterBinding.ensureInitialized()`.
2. Load `.env.development.local` bằng `dotenv.load(...)`.
3. Tạo `AppConfig.fromDotEnv()`.
4. Chạy `SplitMateApp` trong `ProviderScope`, override `appConfigProvider`.

`lib/app/app.dart` là nơi tạo `MaterialApp.router`. File này đọc `authControllerProvider`, rồi truyền `authState` vào `AppRouter.build(authState)`. Vì vậy khi auth state thay đổi, router cũng được build lại để redirect đúng login/home.

### Config/env/constants

File nên đọc:

- `lib/core/config/app_config.dart`
- `lib/core/config/app_confg_provider.dart`
- `.env.development.local`
- `pubspec.yaml`

`AppConfig` hiện có `appName`, `apiBaseUrl`, `environment`, `googleServerClientId`.

`AppConfig.fromDotEnv()` đọc:

- `API_BASE_URL`
- `ENVIRONMENT`
- `APP_NAME`
- `GOOGLE_SERVER_CLIENT_ID`

Nếu `API_BASE_URL` thiếu thì app throw exception. Nếu `GOOGLE_SERVER_CLIENT_ID` thiếu trong dot env thì source hiện fallback sang chuỗi placeholder `replace-with-google-client-id.apps.googleusercontent.com`. Khi build nghiêm túc, nên kiểm tra giá trị env thật.

Lưu ý nhỏ: tên file hiện là `lib/core/config/app_confg_provider.dart`, thiếu chữ `i` trong `config`. Đây là tên thật trong source hiện tại, khi import phải dùng đúng tên file này.

### Router/navigation

File nên đọc:

- `lib/app/router/app_router.dart`
- `lib/app/router/app_routes.dart`
- `lib/features/main/screens/main_shell_screen.dart`

Router dùng `go_router`. Các route chính:

- `/`: splash, render `SplashScreen`.
- `/login`: login/register, render `LoginScreen`.
- `/home`: dashboard.
- `/groups`: danh sách nhóm.
- `/groups/create`: tạo nhóm.
- `/groups/:groupId`: chi tiết nhóm.
- `/groups/:groupId/edit`: sửa nhóm.
- `/groups/:groupId/expenses/create`: tạo khoản chi.
- `/groups/:groupId/expenses/:expenseId`: chi tiết khoản chi.
- `/groups/:groupId/expenses/:expenseId/edit`: sửa khoản chi.
- `/activity`: activity placeholder.
- `/settings`: settings/logout.

Authenticated area dùng `StatefulShellRoute.indexedStack`, được bọc bởi `MainShellScreen`. Bottom navigation nằm trong `lib/features/main/screens/main_shell_screen.dart`, gồm Home, Groups, Activity, Settings.

Redirect auth nằm trực tiếp trong `AppRouter.build(...)`:

- `AuthStatus.initial` hoặc `AuthStatus.loading`: ép về splash `/`.
- Chưa authenticated: ép về `/login`.
- Đã authenticated mà đang ở splash/login: chuyển sang `/home`.

### Theme/design system

File nên đọc:

- `lib/app/theme/app_theme.dart`

Theme hiện dùng Material 3, seed color `0xFF2563EB`, background `0xFFF8FAFC`, style chung cho `AppBar`, `InputDecoration`, `ElevatedButton`.

Chưa thấy implement trong source hiện tại: design system riêng kiểu token package, typography file riêng, color palette file riêng.

### Network/API client

File nên đọc:

- `lib/core/network/dio.provider.dart`
- `lib/core/network/dio_client.dart`

`dioProvider` lấy `AppConfig` từ `appConfigProvider`, rồi gọi `DioClient.create(config)`.

`DioClient.create` build `Dio` với:

- `baseUrl: config.apiBaseUrl`
- timeout 15 giây cho connect/receive/send
- header mặc định `Content-Type: application/json`, `Accept: application/json`
- `LogInterceptor` để log request/response body

Chưa thấy implement trong source hiện tại: interceptor tự động đọc access token và tự gắn `Authorization` cho mọi request. Các API cần token đang tự truyền header trong từng method API.

### Storage/session/token

File nên đọc:

- `lib/core/storage/secure_storage_provider.dart`
- `lib/core/storage/secure_storage_service.dart`

`secureStorageProvider` tạo `FlutterSecureStorage`, rồi bọc bằng `SecureStorageService`.

`SecureStorageService` hiện lưu:

- `access_token`
- `refresh_token`

Các hàm chính:

- `saveAccessToken`
- `getAccessToken`
- `saveRefreshToken`
- `getRefreshToken`
- `clearSession`

### Auth feature

File nên đọc theo thứ tự:

1. `lib/features/auth/providers/auth_state.dart`
2. `lib/features/auth/providers/auth_providers.dart`
3. `lib/features/auth/providers/auth_controller.dart`
4. `lib/features/auth/data/auth_api.dart`
5. `lib/features/auth/data/auth_repository.dart`
6. `lib/features/auth/screens/login_screen.dart`
7. `lib/features/auth/screens/splash_screen.dart`
8. `lib/features/auth/models/auth_session.dart`
9. `lib/features/auth/models/auth_user.dart`

Vai trò từng tầng:

- Screen: nhận input, hiển thị loading/error, gọi controller.
- Controller: giữ `AuthState`, gọi repository, lưu/xóa token, xử lý bootstrap/refresh/logout.
- Repository: chuyển tham số nghiệp vụ thành request model, parse response thành model.
- API: gọi endpoint thật bằng Dio.
- Model: map JSON từ backend sang object Dart.

Endpoint auth đang gọi trong `AuthApi`:

- `POST /auth/register`
- `POST /auth/login`
- `POST /auth/google/login`
- `POST /auth/refresh`
- `GET /auth/me`
- `POST /auth/logout`

Các request body nằm trong:

- `lib/features/auth/models/register_request.dart`
- `lib/features/auth/models/login_request.dart`
- `lib/features/auth/models/google_login_request.dart`
- `lib/features/auth/models/refresh_token_request.dart`

### Groups feature

File nên đọc theo thứ tự:

1. `lib/features/groups/providers/groups_state.dart`
2. `lib/features/groups/providers/groups_providers.dart`
3. `lib/features/groups/providers/groups_controllers.dart`
4. `lib/features/groups/data/groups_api.dart`
5. `lib/features/groups/data/groups_repository.dart`
6. `lib/features/groups/screens/groups_screen.dart`
7. `lib/features/groups/screens/group_detail_screen.dart`
8. `lib/features/groups/screens/create_group_screen.dart`
9. `lib/features/groups/widgets/group_form.dart`
10. `lib/features/groups/models/group.dart`
11. `lib/features/groups/models/group_requests.dart`

Groups có 2 controller chính:

- `GroupListController`: load danh sách nhóm, tạo nhóm.
- `GroupDetailController`: load group detail + members, update/delete/leave/add member/transfer owner.

Endpoint groups đang gọi:

- `GET /groups`
- `POST /groups`
- `GET /groups/:groupId`
- `PATCH /groups/:groupId`
- `DELETE /groups/:groupId`
- `POST /groups/:groupId/leave`
- `GET /groups/:groupId/members`
- `POST /groups/:groupId/members`
- `POST /groups/:groupId/transfer-owner`

### Expenses feature

File nên đọc theo thứ tự:

1. `lib/features/expenses/providers/expenses_state.dart`
2. `lib/features/expenses/providers/expenses_providers.dart`
3. `lib/features/expenses/providers/expenses_controllers.dart`
4. `lib/features/expenses/data/expenses_api.dart`
5. `lib/features/expenses/data/expenses_repository.dart`
6. `lib/features/expenses/widgets/expense_list_section.dart`
7. `lib/features/expenses/screens/create_expense_screen.dart`
8. `lib/features/expenses/screens/expense_detail_screen.dart`
9. `lib/features/expenses/widgets/expense_form.dart`
10. `lib/features/expenses/models/expense.dart`
11. `lib/features/expenses/models/expense_requests.dart`

Expenses có 2 controller chính:

- `ExpenseListController`: load danh sách khoản chi trong group, tạo khoản chi.
- `ExpenseDetailController`: load chi tiết, update, delete khoản chi.

Endpoint expenses đang gọi:

- `GET /groups/:groupId/expenses`
- `POST /groups/:groupId/expenses`
- `GET /groups/:groupId/expenses/:expenseId`
- `PATCH /groups/:groupId/expenses/:expenseId`
- `DELETE /groups/:groupId/expenses/:expenseId`

Trong `ExpenseForm`, split type đang cố định là `EQUAL`. Chưa thấy implement trong source hiện tại cho split theo phần trăm, số tiền tùy chỉnh hoặc settlement.

### Main/settings/shared

File nên đọc:

- `lib/features/main/screens/main_shell_screen.dart`
- `lib/features/main/screens/dashboard_screen.dart`
- `lib/features/main/screens/activity_screen.dart`
- `lib/features/settings/screens/settings_screen.dart`
- `lib/shared/widgets/placeholder_screen.dart`

`MainShellScreen` là shell sau login, giữ `NavigationBar`. `SettingsScreen` đọc user từ `authControllerProvider` và gọi `authControllerProvider.notifier.logout()` khi bấm Logout.

Chưa thấy implement trong source hiện tại: profile detail screen thật, settlement screen, notification screen.

## 3. Luồng chạy của app từ lúc mở app

1. App bắt đầu ở `lib/main.dart`.
2. Flutter binding được init bằng `WidgetsFlutterBinding.ensureInitialized()`.
3. App load `.env.development.local`.
4. `AppConfig.fromDotEnv()` tạo config, đặc biệt là `apiBaseUrl`.
5. `runApp` chạy `ProviderScope`, override `appConfigProvider` bằng config vừa đọc.
6. `SplitMateApp` trong `lib/app/app.dart` watch `authControllerProvider`.
7. Khi `authControllerProvider` được tạo, constructor của `AuthController` gọi `Future<void>.microtask(bootstrap)`.
8. `bootstrap()` trong `lib/features/auth/providers/auth_controller.dart` đọc access token và refresh token từ `SecureStorageService`.
9. Nếu không có token: clear local session, state thành unauthenticated.
10. Nếu có token: gọi `AuthRepository.getMe`, cuối cùng là `GET /auth/me`.
11. Nếu `/auth/me` thành công: state thành authenticated.
12. Nếu `/auth/me` trả 401/403: controller gọi refresh bằng `POST /auth/refresh`, lưu token mới, rồi gọi lại `GET /auth/me`.
13. `AppRouter.build(authState)` quyết định màn hình:
    - đang initial/loading: ở splash `/`;
    - chưa login: `/login`;
    - đã login: `/home`.

## 4. Luồng authentication

### Login/register bằng email/password

UI nằm ở `lib/features/auth/screens/login_screen.dart`.

Người dùng chọn mode bằng `SegmentedButton`: đăng nhập hoặc đăng ký. Khi bấm nút submit:

- Login gọi `_submit()` rồi `AuthController.loginWithPassword(...)`.
- Register gọi `_submit()` rồi `AuthController.registerWithPassword(...)`.

Luồng login:

```text
LoginScreen._submit
-> AuthController.loginWithPassword
-> AuthRepository.login
-> AuthApi.login
-> POST /auth/login
-> AuthSession.fromJson
-> SecureStorageService.saveAccessToken/saveRefreshToken
-> AuthState.authenticated
-> Router redirect về /home
```

Luồng register tương tự, nhưng gọi `POST /auth/register`.

### Google login

Google login bắt đầu từ nút `Tiếp tục với Google` trong `lib/features/auth/screens/login_screen.dart`.

Luồng:

```text
LoginScreen Google button
-> AuthController.signInWithGoogle
-> GoogleSignIn.initialize(serverClientId)
-> GoogleSignIn.authenticate()
-> lấy idToken
-> AuthRepository.loginWithGoogle
-> AuthApi.loginWithGoogle
-> POST /auth/google/login
-> lưu accessToken/refreshToken
-> AuthState.authenticated
```

`googleServerClientId` lấy từ `AppConfig`, được tạo từ `.env.development.local`.

### App biết user đã login bằng cách nào?

App không lưu riêng cờ `isLoggedIn`. Nó dựa vào `AuthState`:

- `AuthStatus.authenticated` và `session != null` nghĩa là đã đăng nhập.
- `session.user` lấy từ response login/register/google hoặc từ `GET /auth/me` khi bootstrap.

### Token/session được lưu ở đâu?

Token được lưu trong `SecureStorageService`:

- access token: key `access_token`
- refresh token: key `refresh_token`

File: `lib/core/storage/secure_storage_service.dart`.

### Refresh token

Refresh token có implement trong `AuthController._tryRefresh`.

Khi bootstrap có access token và refresh token, nhưng `GET /auth/me` trả 401/403:

1. Gọi `AuthRepository.refresh(refreshToken: refreshToken)`.
2. `AuthApi.refresh` gọi `POST /auth/refresh`.
3. Lưu session mới vào secure storage.
4. Gọi `GET /auth/me` bằng access token mới.
5. Set `AuthState.authenticated`.

Chưa thấy implement trong source hiện tại: tự động refresh khi bất kỳ API groups/expenses trả 401/403 trong lúc user đang dùng app. Hiện refresh chỉ thấy trong auth bootstrap.

### Logout

Logout nằm ở `lib/features/settings/screens/settings_screen.dart`.

Khi bấm Logout:

```text
SettingsScreen ListTile
-> AuthController.logout
-> nếu có accessToken thì AuthRepository.logout
-> AuthApi.logout
-> POST /auth/logout với Authorization: Bearer token
-> clearSession local
-> GoogleSignIn.signOut()
-> AuthState.unauthenticated
-> Router redirect /login
```

Nếu backend logout lỗi, source vẫn clear session local trong `finally`.

## 5. Cách frontend gọi API

API layer có pattern khá đều:

```text
UI screen/widget
-> Controller/StateNotifier
-> Repository
-> Api class
-> Dio request
-> JSON response
-> Model.fromJson
-> State copyWith
-> UI ref.watch rebuild
```

Base URL được build trong `DioClient.create(config)` tại `lib/core/network/dio_client.dart`. `config.apiBaseUrl` lấy từ `.env.development.local` qua `AppConfig.fromDotEnv()`.

Cách gửi request:

- `AuthApi`: dùng `_dio.post`, `_dio.get`.
- `GroupsApi`: dùng `_dio.get`, `_dio.post`, `_dio.patch`, `_dio.delete`.
- `ExpensesApi`: dùng `_dio.get`, `_dio.post`, `_dio.patch`, `_dio.delete`.

Request body được tạo ở các model request:

- Auth: `lib/features/auth/models/*_request.dart`
- Groups: `lib/features/groups/models/group_requests.dart`
- Expenses: `lib/features/expenses/models/expense_requests.dart`

Response được parse ở repository/model:

- `AuthRepository` parse `AuthSession.fromJson`, `AuthUser.fromJson`.
- `GroupsRepository` parse `GroupListResponse.fromJson`, `Group.fromJson`, `GroupMember.fromJson`.
- `ExpensesRepository` parse `Expense.fromJson`.

Error handling:

- Auth dùng `_readableMessage` trong `lib/features/auth/providers/auth_controller.dart`.
- Groups dùng `_readableMessage` trong `lib/features/groups/providers/groups_controllers.dart`.
- Expenses dùng `_readableMessage` trong `lib/features/expenses/providers/expenses_controllers.dart`.
- Nếu Dio response có `data['message']`, UI sẽ ưu tiên hiện message đó.

Loading/error/success đi lên UI qua state:

- Auth: `AuthState.status`, `AuthState.errorMessage`.
- Groups: `GroupListState.isLoading/isRefreshing/errorMessage`, `GroupDetailState.isLoading/isSaving/errorMessage/actionMessage`.
- Expenses: `ExpenseListState.isLoading/isRefreshing/isSaving/errorMessage/actionMessage`, `ExpenseDetailState.isLoading/isSaving/errorMessage/actionMessage`.

Ví dụ thật: tạo group.

```text
User bấm FloatingActionButton "Tạo nhóm"
-> lib/features/groups/screens/groups_screen.dart
-> context.push(AppRoutes.groupCreate)
-> lib/features/groups/screens/create_group_screen.dart
-> GroupForm.onSubmit
-> GroupListController.createGroup
-> GroupsRepository.createGroup
-> GroupsApi.createGroup
-> POST /groups, body từ CreateGroupRequest.toJson()
-> Group.fromJson(response)
-> controller load(refresh: true)
-> CreateGroupScreen context.go(AppRoutes.groupDetail(group.id))
```

Ví dụ thật: tạo expense trong group.

```text
User ở GroupDetailScreen bấm "Thêm" trong ExpenseListSection
-> context.push(AppRoutes.expenseCreate(groupId))
-> CreateExpenseScreen load group detail để lấy members/currency
-> ExpenseForm validate title, amount, payer, participants
-> ExpenseListController.createExpense
-> ExpensesRepository.createExpense
-> ExpensesApi.createExpense
-> POST /groups/:groupId/expenses
-> body từ CreateExpenseRequest.toJson(), splitType mặc định EQUAL
-> Expense.fromJson(response)
-> controller load(refresh: true)
-> màn hình pop về group detail, list expenses refresh
```

## 6. Cách bảo vệ API ở phía frontend

Frontend không thật sự "bảo vệ" API. Backend mới là nơi enforce quyền bằng token, guard, permission, owner/member role. Frontend trong project này làm các việc sau:

- Lưu token sau login/register/google.
- Gửi access token trong header `Authorization: Bearer ...` cho API cần auth.
- Điều hướng user chưa login về `/login`.
- Ẩn/hiện một số UI theo dữ liệu backend trả về, ví dụ `Group.isOwner`.

API cần access token:

- `GET /auth/me`, `POST /auth/logout` trong `AuthApi`.
- Tất cả API groups trong `GroupsApi`.
- Tất cả API expenses trong `ExpensesApi`.

Token được gắn ở đâu?

- `AuthApi.me` và `AuthApi.logout` tự tạo `Options(headers: {'Authorization': 'Bearer $accessToken'})`.
- `GroupsApi` có helper `_authOptions(accessToken)`.
- `ExpensesApi` có helper `_authOptions(accessToken)`.

Chưa thấy implement trong source hiện tại:

- Interceptor tự động gắn token cho mọi request.
- Interceptor tự động refresh token khi API bất kỳ trả 401.
- Global handler ép logout khi groups/expenses trả 401/403.

Hiện tại khi groups/expenses thiếu token, controller báo lỗi kiểu "Bạn cần đăng nhập lại...". Khi backend trả lỗi, controller lấy `data['message']` nếu có và đưa lên UI.

## 7. State management

Project dùng Riverpod.

Các dạng provider chính:

- `Provider`: inject dependency, ví dụ `dioProvider`, `secureStorageProvider`, `authRepositoryProvider`.
- `StateNotifierProvider`: state có mutation qua controller, ví dụ `authControllerProvider`, `groupListControllerProvider`.
- `StateNotifierProvider.family`: state theo tham số, ví dụ `groupDetailControllerProvider(groupId)`, `expenseDetailControllerProvider(params)`.

UI subscribe state bằng:

- `ref.watch(provider)` để rebuild khi state đổi.
- `ref.read(provider.notifier)` để gọi action.
- `ref.listen(provider, ...)` để hiện SnackBar hoặc side effect khi error/actionMessage đổi.

Ví dụ groups:

```text
GroupsScreen.initState
-> ref.read(groupListControllerProvider.notifier).load()
-> state.isLoading = true
-> API trả response
-> state.groups = result.items, isLoading = false
-> GroupsScreen ref.watch rebuild ListView
```

Ví dụ auth:

```text
LoginScreen ref.watch(authControllerProvider)
-> nếu isLoading thì disable form/button
-> nếu AuthStatus.failure thì hiện errorMessage
-> khi authenticated, router tự redirect sang /home
```

## 8. Navigation/routing

Router được định nghĩa ở:

- `lib/app/router/app_router.dart`
- `lib/app/router/app_routes.dart`

Public routes:

- `/`
- `/login`

Routes cần auth:

- `/home`
- `/groups`
- `/groups/...`
- `/activity`
- `/settings`

Guard/redirect logic nằm trong `redirect` của `GoRouter` ở `AppRouter.build`.

Cách thêm màn hình mới:

1. Tạo screen trong đúng feature folder, ví dụ `lib/features/settlements/screens/settlements_screen.dart`.
2. Thêm constant/path helper vào `lib/app/router/app_routes.dart` nếu cần.
3. Import screen vào `lib/app/router/app_router.dart`.
4. Thêm `GoRoute` hoặc thêm branch mới trong `StatefulShellRoute`.
5. Nếu route thuộc authenticated area, để redirect hiện tại bảo vệ bằng `authState.isAuthenticated`.
6. Nếu cần tab mới, cập nhật `MainShellScreen` trong `lib/features/main/screens/main_shell_screen.dart`.

## 9. Đọc code theo luồng thực tế

### Flow 1: login bằng email/password

Bước 1: User nhập email/password và bấm `Đăng nhập`.

- File: `lib/features/auth/screens/login_screen.dart`
- Hàm: `_LoginScreenState._submit()`

Bước 2: UI gọi controller.

- File: `lib/features/auth/providers/auth_controller.dart`
- Hàm: `loginWithPassword(email, password)`

Bước 3: Controller gọi repository.

- File: `lib/features/auth/data/auth_repository.dart`
- Hàm: `login(...)`
- Repository tạo `LoginRequest`.

Bước 4: API gọi backend.

- File: `lib/features/auth/data/auth_api.dart`
- Hàm: `login(LoginRequest request)`
- Endpoint: `POST /auth/login`

Bước 5: Response quay về UI.

- `AuthSession.fromJson` parse response.
- `AuthController._persistSession` lưu token.
- `state = AuthState.authenticated(session)`.
- `SplitMateApp` watch auth state, router redirect từ `/login` sang `/home`.

### Flow 2: mở danh sách group

Bước 1: User vào tab Groups.

- File: `lib/features/main/screens/main_shell_screen.dart`
- Bottom navigation branch index 1 là Groups.

Bước 2: `GroupsScreen` tự load khi init.

- File: `lib/features/groups/screens/groups_screen.dart`
- Hàm: `initState`, gọi `groupListControllerProvider.notifier.load()`.

Bước 3: Controller lấy access token từ auth state.

- File: `lib/features/groups/providers/groups_providers.dart`
- `groupListControllerProvider` đọc `authControllerProvider`, truyền `authState.session?.accessToken`.

Bước 4: Controller gọi repository/API.

- File: `lib/features/groups/providers/groups_controllers.dart`
- Hàm: `GroupListController.load`
- File: `lib/features/groups/data/groups_repository.dart`
- Hàm: `listGroups`
- File: `lib/features/groups/data/groups_api.dart`
- Endpoint: `GET /groups?page=1&limit=20`

Bước 5: UI update.

- `GroupListResponse.fromJson` parse response.
- `GroupListState.groups` được cập nhật.
- `GroupsScreen` dùng `ref.watch(groupListControllerProvider)` để render loading/error/empty/list.

### Flow 3: tạo khoản chi equal split

Bước 1: User ở group detail bấm `Thêm` trong section Expenses.

- File: `lib/features/expenses/widgets/expense_list_section.dart`
- Hàm: `context.push(AppRoutes.expenseCreate(widget.groupId))`

Bước 2: Màn hình tạo expense load group detail để lấy member list.

- File: `lib/features/expenses/screens/create_expense_screen.dart`
- Gọi `groupDetailControllerProvider(widget.groupId).notifier.load()`

Bước 3: User submit form.

- File: `lib/features/expenses/widgets/expense_form.dart`
- Hàm: `_submit()`
- Validate title, amount, payer, participants.

Bước 4: Controller xử lý.

- File: `lib/features/expenses/providers/expenses_controllers.dart`
- Hàm: `ExpenseListController.createExpense`

Bước 5: API gọi backend.

- File: `lib/features/expenses/data/expenses_api.dart`
- Endpoint: `POST /groups/:groupId/expenses`
- Body từ `CreateExpenseRequest.toJson()` trong `lib/features/expenses/models/expense_requests.dart`
- `splitType` mặc định là `EQUAL`.

Bước 6: Response quay về UI.

- `Expense.fromJson` parse response.
- Controller refresh list expenses.
- `CreateExpenseScreen` pop về màn hình trước.
- `ExpenseListSection` reload nếu `changed == true`.

## 10. Những điểm người mới nên chú ý

File nên đọc đầu tiên:

1. `lib/main.dart`
2. `lib/app/app.dart`
3. `lib/app/router/app_router.dart`
4. `lib/features/auth/providers/auth_controller.dart`
5. `lib/core/network/dio_client.dart`
6. `lib/features/groups/screens/groups_screen.dart`
7. `lib/features/groups/providers/groups_controllers.dart`
8. `lib/features/groups/data/groups_api.dart`

Pattern chính của project:

- Mỗi feature tách thành `screens`, `widgets`, `providers`, `data`, `models`.
- UI không gọi Dio trực tiếp.
- API class chỉ gọi HTTP và chuẩn hóa JSON raw.
- Repository map request/model.
- Controller giữ state, xử lý loading/error/action.
- UI dùng `ref.watch` để render state và `ref.read(...notifier)` để gọi action.

Lỗi dễ gặp khi sửa code:

- Quên truyền access token vào API protected.
- Nghĩ Dio đã có interceptor token toàn cục, nhưng source hiện tại chưa có.
- Thêm route mới nhưng quên thêm helper ở `AppRoutes`.
- Gọi provider family sai key, ví dụ detail cần đúng `groupId` hoặc `ExpenseDetailParams`.
- Parse JSON quá tin backend: source hiện có nhiều helper `_asMap`, `_asInt`, `_asMapList` để tránh crash khi format không đúng.
- Quên refresh list sau create/update/delete, khiến UI không cập nhật.
- Quên xử lý `context.mounted` sau `await` khi navigation.

Khi thêm API mới:

1. Tạo request/response model trong `lib/features/<feature>/models/`.
2. Thêm method HTTP trong `lib/features/<feature>/data/<feature>_api.dart`.
3. Thêm method nghiệp vụ trong repository.
4. Thêm state/controller trong `providers/`.
5. UI gọi controller, không gọi API trực tiếp.
6. Nếu API cần auth, lấy token qua auth state giống groups/expenses hiện tại.

Khi thêm màn hình mới:

1. Tạo screen trong `lib/features/<feature>/screens/`.
2. Nếu có form, tách widget form vào `widgets/`.
3. Thêm route vào `lib/app/router/app_router.dart`.
4. Thêm path/helper vào `lib/app/router/app_routes.dart`.
5. Nếu màn hình thuộc tab shell, cập nhật `MainShellScreen` nếu cần.
6. Dùng `ref.watch` để render loading/error/success từ controller.

## 11. Checklist học project

- [ ] Đọc `lib/main.dart`.
- [ ] Đọc `lib/app/app.dart`.
- [ ] Đọc `lib/app/router/app_router.dart`.
- [ ] Đọc `lib/app/router/app_routes.dart`.
- [ ] Đọc `lib/features/auth/providers/auth_controller.dart`.
- [ ] Đọc `lib/features/auth/data/auth_api.dart`.
- [ ] Đọc `lib/core/network/dio_client.dart`.
- [ ] Đọc `lib/core/storage/secure_storage_service.dart`.
- [ ] Trace login từ `LoginScreen` đến `POST /auth/login`.
- [ ] Trace bootstrap session từ `AuthController.bootstrap` đến `GET /auth/me`.
- [ ] Trace danh sách group từ `GroupsScreen` đến `GET /groups`.
- [ ] Trace tạo group từ `GroupForm` đến `POST /groups`.
- [ ] Trace tạo expense từ `ExpenseForm` đến `POST /groups/:groupId/expenses`.
- [ ] Thêm thử một API nhỏ theo pattern API -> repository -> controller -> UI.
- [ ] Thêm thử một màn hình nhỏ và khai báo route trong `app_router.dart`.

## 12. Các phần chưa xác minh hoặc chưa thấy implement

- Chưa thấy implement trong source hiện tại: Dio interceptor tự gắn access token.
- Chưa thấy implement trong source hiện tại: tự refresh token toàn cục khi groups/expenses trả 401/403.
- Chưa thấy implement trong source hiện tại: settlements feature.
- Chưa thấy implement trong source hiện tại: notification feature.
- Chưa thấy implement trong source hiện tại: profile screen thật, `SettingsScreen` mới có item Profile nhưng `onTap` đang rỗng.
- Chưa thấy implement trong source hiện tại: split type khác `EQUAL`.
- Chưa xác minh backend live có trả đúng toàn bộ response shape như model đang parse hay không; tài liệu này chỉ dựa trên frontend source hiện tại.

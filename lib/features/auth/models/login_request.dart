class LoginRequest {
  const LoginRequest({
    required this.email,
    required this.password,
    this.deviceId,
    this.deviceName,
  });

  final String email;
  final String password;
  final String? deviceId;
  final String? deviceName;

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      if (deviceId != null && deviceId!.isNotEmpty) 'deviceId': deviceId,
      if (deviceName != null && deviceName!.isNotEmpty) 'deviceName': deviceName,
    };
  }
}

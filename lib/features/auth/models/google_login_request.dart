class GoogleLoginRequest {
  const GoogleLoginRequest({
    required this.idToken,
    this.deviceId,
    this.deviceName,
  });

  final String idToken;
  final String? deviceId;
  final String? deviceName;

  Map<String, dynamic> toJson() {
    return {
      'idToken': idToken,
      if (deviceId != null && deviceId!.isNotEmpty) 'deviceId': deviceId,
      if (deviceName != null && deviceName!.isNotEmpty) 'deviceName': deviceName,
    };
  }
}
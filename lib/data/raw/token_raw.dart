class TokenRaw {
  final int id;
  final String accessToken;
  final String refreshToken;

  TokenRaw(
      {required this.id,
        required this.accessToken,
        required this.refreshToken});

  factory TokenRaw.fromJson(Map<String, dynamic> json) {
    return TokenRaw(
      id: json['id'],
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
    );
  }
}
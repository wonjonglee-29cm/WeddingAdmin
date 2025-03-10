class GreetingRaw {
  final String userName;
  final String message;

  GreetingRaw({required this.userName, required this.message});

  Map<String, dynamic> toJson() => {
        'userName': userName,
        'message': message,
      };

  // 단일 객체 파싱을 위한 팩토리 메서드
  factory GreetingRaw.fromJson(Map<String, dynamic> json) {
    return GreetingRaw(
      userName: json['userName'],
      message: json['message'],
    );
  }

  // 리스트 파싱을 위한 정적 메서드
  static List<GreetingRaw> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => GreetingRaw.fromJson(json)).toList();
  }
}

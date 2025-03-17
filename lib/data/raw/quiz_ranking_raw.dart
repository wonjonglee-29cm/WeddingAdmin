import 'package:wedding/data/raw/user_info_raw.dart';

class QuizRankingRaw {
  final UserInfoRaw user;
  final int correctCount;

  QuizRankingRaw({
    required this.user,
    required this.correctCount,
  });

  factory QuizRankingRaw.fromJson(Map<String, dynamic> json) {
    return QuizRankingRaw(
      user: UserInfoRaw.fromJson(json['user']),
      correctCount: json['correctCount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'correctCount': correctCount,
    };
  }

  static List<QuizRankingRaw> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => QuizRankingRaw.fromJson(json)).toList();
  }
}

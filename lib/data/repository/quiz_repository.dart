import 'package:shared_preferences/shared_preferences.dart';
import 'package:wedding/data/raw/quiz_ranking_raw.dart';
import 'package:wedding/data/remote/api.dart';

class QuizRepository {
  final SharedPreferences _prefs;

  QuizRepository(this._prefs);

  Future<List<QuizRankingRaw>> getQuizRanking() async {
    try {
      final response = await Api.getQuizRanking();
      final data = QuizRankingRaw.fromJsonList(response.data);
      return data;
    } catch (e) {
      // 에러 처리
      print('퀴즈 랭킹 조회 실패: $e');
      return [];
    }
  }

  Future<int> getUserRankPosition(int userId) async {
    try {
      final rankings = await getQuizRanking();

      // 점수 내림차순으로 정렬
      rankings.sort((a, b) => b.correctCount.compareTo(a.correctCount));

      // 사용자 위치 찾기
      for (int i = 0; i < rankings.length; i++) {
        if (rankings[i].user.id == userId) {
          return i + 1; // 인덱스는 0부터 시작하므로 1을 더함
        }
      }

      return -1; // 사용자를 찾지 못한 경우
    } catch (e) {
      print('랭킹 위치 조회 실패: $e');
      return -1;
    }
  }

  Future<List<QuizRankingRaw>> getSortedRankings() async {
    final rankings = await getQuizRanking();
    rankings.sort((a, b) => b.correctCount.compareTo(a.correctCount));
    return rankings;
  }
}
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wedding/data/raw/quiz_ranking_raw.dart';
import 'package:wedding/data/repository/quiz_repository.dart';

class QuizRankingState {
  final bool isLoading;
  final List<QuizRankingRaw> rankings;
  final String? errorMessage;

  const QuizRankingState({
    required this.isLoading,
    required this.rankings,
    this.errorMessage,
  });

  // 초기 상태
  factory QuizRankingState.initial() {
    return const QuizRankingState(
      isLoading: true,
      rankings: [],
      errorMessage: null,
    );
  }

  // 로딩 상태
  factory QuizRankingState.loading() {
    return const QuizRankingState(
      isLoading: true,
      rankings: [],
      errorMessage: null,
    );
  }

  // 데이터 로딩 성공 상태
  factory QuizRankingState.success(List<QuizRankingRaw> rankings) {
    return QuizRankingState(
      isLoading: false,
      rankings: rankings,
      errorMessage: null,
    );
  }

  // 오류 상태
  factory QuizRankingState.error(String message) {
    return QuizRankingState(
      isLoading: false,
      rankings: [],
      errorMessage: message,
    );
  }

  // 상태 복사 메서드
  QuizRankingState copyWith({
    bool? isLoading,
    List<QuizRankingRaw>? rankings,
    String? errorMessage,
  }) {
    return QuizRankingState(
      isLoading: isLoading ?? this.isLoading,
      rankings: rankings ?? this.rankings,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class QuizRankingViewModel extends StateNotifier<QuizRankingState> {
  final QuizRepository _repository;

  QuizRankingViewModel(this._repository) : super(QuizRankingState.initial()) {
    // 초기화시 자동으로 데이터 로드
    loadRankings();
  }

  // 랭킹 데이터 로드 메서드
  Future<void> loadRankings() async {
    state = QuizRankingState.loading();

    try {
      final rankings = await _repository.getSortedRankings();
      state = QuizRankingState.success(rankings);
    } catch (e) {
      state = QuizRankingState.error('랭킹을 불러오는 중 오류가 발생했습니다: $e');
    }
  }

  // 특정 사용자의 랭킹 위치 로드 메서드
  Future<int> getUserRankPosition(int userId) async {
    try {
      return await _repository.getUserRankPosition(userId);
    } catch (e) {
      print('사용자 랭킹 위치 조회 실패: $e');
      return -1;
    }
  }
}

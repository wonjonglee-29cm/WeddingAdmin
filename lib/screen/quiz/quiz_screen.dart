import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

// Quiz 모델
class QuizModel {
  final int id;
  final String question;
  final List<String> options;
  final int correctAnswer;

  QuizModel({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswer,
  });
}

// Quiz 상태 클래스
class QuizState {
  final bool isLoading;
  final List<QuizModel> quizzes;
  final int currentQuizIndex;
  final List<int?> userAnswers;
  final bool isCompleted;
  final String? errorMessage;

  QuizState({
    this.isLoading = false,
    this.quizzes = const [],
    this.currentQuizIndex = 0,
    this.userAnswers = const [],
    this.isCompleted = false,
    this.errorMessage,
  });

  QuizState copyWith({
    bool? isLoading,
    List<QuizModel>? quizzes,
    int? currentQuizIndex,
    List<int?>? userAnswers,
    bool? isCompleted,
    String? errorMessage,
  }) {
    return QuizState(
      isLoading: isLoading ?? this.isLoading,
      quizzes: quizzes ?? this.quizzes,
      currentQuizIndex: currentQuizIndex ?? this.currentQuizIndex,
      userAnswers: userAnswers ?? this.userAnswers,
      isCompleted: isCompleted ?? this.isCompleted,
      errorMessage: errorMessage,
    );
  }

  // 현재 퀴즈
  QuizModel? get currentQuiz => quizzes.isNotEmpty && currentQuizIndex < quizzes.length
      ? quizzes[currentQuizIndex]
      : null;

  // 정답 개수
  int get correctCount => userAnswers
      .asMap()
      .entries
      .where((entry) =>
  entry.value != null &&
      entry.key < quizzes.length &&
      entry.value == quizzes[entry.key].correctAnswer)
      .length;
}

// Quiz ViewModel
class QuizViewModel extends StateNotifier<QuizState> {
  QuizViewModel() : super(QuizState()) {
    fetchQuizzes();
  }

  Future<void> fetchQuizzes() async {
    try {
      state = state.copyWith(
        isLoading: true,
        errorMessage: null,
        isCompleted: false,
        currentQuizIndex: 0,
      );

      // 실제 API 호출을 시뮬레이션
      await Future.delayed(const Duration(seconds: 1));

      // 샘플 퀴즈 데이터
      final sampleQuizzes = [
        QuizModel(
          id: 1,
          question: "신랑과 신부는 어디서 처음 만났나요?",
          options: ["학교", "직장", "소개팅", "우연히"],
          correctAnswer: 2,
        ),
        QuizModel(
          id: 2,
          question: "신랑의 생일은 언제인가요?",
          options: ["1월 1일", "5월 5일", "8월 15일", "12월 25일"],
          correctAnswer: 1,
        ),
        QuizModel(
          id: 3,
          question: "신부가 가장 좋아하는 음식은?",
          options: ["피자", "파스타", "초밥", "불고기"],
          correctAnswer: 3,
        ),
      ];

      state = state.copyWith(
        isLoading: false,
        quizzes: sampleQuizzes,
        userAnswers: List.filled(sampleQuizzes.length, null),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '퀴즈를 불러오는데 실패했습니다: ${e.toString()}',
      );
    }
  }

  void answerQuestion(int optionIndex) {
    if (state.isCompleted || state.currentQuiz == null) return;

    final newAnswers = List<int?>.from(state.userAnswers);
    newAnswers[state.currentQuizIndex] = optionIndex;

    state = state.copyWith(userAnswers: newAnswers);

    // 마지막 퀴즈인지 확인
    if (state.currentQuizIndex == state.quizzes.length - 1) {
      state = state.copyWith(isCompleted: true);
    } else {
      // 다음 퀴즈로 이동
      state = state.copyWith(currentQuizIndex: state.currentQuizIndex + 1);
    }
  }

  void restart() {
    state = state.copyWith(
      currentQuizIndex: 0,
      userAnswers: List.filled(state.quizzes.length, null),
      isCompleted: false,
    );
  }
}

// Quiz Provider
final quizProvider = StateNotifierProvider<QuizViewModel, QuizState>((ref) {
  return QuizViewModel();
});

// Quiz 화면
class QuizScreen extends HookConsumerWidget {
  const QuizScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizState = ref.watch(quizProvider);
    final viewModel = ref.read(quizProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('퀴즈'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => viewModel.fetchQuizzes(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: quizState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : quizState.errorMessage != null
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                quizState.errorMessage!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => viewModel.fetchQuizzes(),
                child: const Text('다시 시도'),
              ),
            ],
          ),
        )
            : quizState.isCompleted
            ? _buildResultScreen(context, quizState, viewModel)
            : _buildQuizScreen(context, quizState, viewModel),
      ),
    );
  }

  Widget _buildQuizScreen(BuildContext context, QuizState state, QuizViewModel viewModel) {
    final currentQuiz = state.currentQuiz;
    if (currentQuiz == null) return const Center(child: Text('퀴즈가 없습니다.'));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 진행 상황
        LinearProgressIndicator(
          value: (state.currentQuizIndex + 1) / state.quizzes.length,
        ),
        const SizedBox(height: 16),

        // 문제 번호
        Text(
          '문제 ${state.currentQuizIndex + 1}/${state.quizzes.length}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 32),

        // 문제
        Text(
          currentQuiz.question,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 32),

        // 선택지
        ...List.generate(currentQuiz.options.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: ElevatedButton(
              onPressed: () => viewModel.answerQuestion(index),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                alignment: Alignment.centerLeft,
              ),
              child: Text(
                currentQuiz.options[index],
                style: const TextStyle(fontSize: 18),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildResultScreen(BuildContext context, QuizState state, QuizViewModel viewModel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '퀴즈 결과',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          Text(
            '${state.correctCount}/${state.quizzes.length} 정답',
            style: const TextStyle(fontSize: 22),
          ),
          const SizedBox(height: 16),
          Text(
            '정답률: ${(state.correctCount / state.quizzes.length * 100).toStringAsFixed(1)}%',
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 48),
          ElevatedButton(
            onPressed: () => viewModel.restart(),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
            ),
            child: const Text('다시 풀기'),
          ),
        ],
      ),
    );
  }
}
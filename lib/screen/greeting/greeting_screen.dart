import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

// Greeting 모델
class GreetingModel {
  final int id;
  final String message;

  GreetingModel({
    required this.id,
    required this.message,
  });

  factory GreetingModel.fromJson(Map<String, dynamic> json) {
    return GreetingModel(
      id: json['id'],
      message: json['message'],
    );
  }
}

// Greeting 상태 클래스
class GreetingState {
  final bool isLoading;
  final List<GreetingModel> greetings;
  final String? errorMessage;

  GreetingState({
    this.isLoading = false,
    this.greetings = const [],
    this.errorMessage,
  });

  GreetingState copyWith({
    bool? isLoading,
    List<GreetingModel>? greetings,
    String? errorMessage,
  }) {
    return GreetingState(
      isLoading: isLoading ?? this.isLoading,
      greetings: greetings ?? this.greetings,
      errorMessage: errorMessage,
    );
  }
}

// Greeting ViewModel
class GreetingViewModel extends StateNotifier<GreetingState> {
  GreetingViewModel() : super(GreetingState()) {
    fetchGreetings();
  }

  Future<void> fetchGreetings() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      // 실제 API 호출을 시뮬레이션
      await Future.delayed(const Duration(seconds: 1));

      // 샘플 데이터
      final sampleGreetings = [
        GreetingModel(id: 1, message: "안녕하세요! 환영합니다."),
        GreetingModel(id: 2, message: "결혼식에 초대해 주셔서 감사합니다."),
        GreetingModel(id: 3, message: "축하의 마음을 전합니다."),
      ];

      state = state.copyWith(
        isLoading: false,
        greetings: sampleGreetings,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '인사말을 불러오는데 실패했습니다: ${e.toString()}',
      );
    }
  }
}

// Greeting Provider
final greetingProvider = StateNotifierProvider<GreetingViewModel, GreetingState>((ref) {
  return GreetingViewModel();
});

// Greeting 화면
class GreetingScreen extends HookConsumerWidget {
  const GreetingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final greetingState = ref.watch(greetingProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('인사말'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(greetingProvider.notifier).fetchGreetings(),
          ),
        ],
      ),
      body: greetingState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : greetingState.errorMessage != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              greetingState.errorMessage!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(greetingProvider.notifier).fetchGreetings(),
              child: const Text('다시 시도'),
            ),
          ],
        ),
      )
          : greetingState.greetings.isEmpty
          ? const Center(child: Text('인사말이 없습니다.'))
          : ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: greetingState.greetings.length,
        itemBuilder: (context, index) {
          final greeting = greetingState.greetings[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                greeting.message,
                style: const TextStyle(fontSize: 18.0),
              ),
            ),
          );
        },
      ),
    );
  }
}
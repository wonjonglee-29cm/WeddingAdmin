import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wedding/data/raw/greeting_raw.dart';
import 'package:wedding/data/repository/greeting_repository.dart';

class GreetingState {
  final bool isLoading;
  final List<GreetingRaw> greetings;
  final String? errorMessage;
  final Set<int> expandedItems; // 펼쳐진 아이템을 추적하는 Set

  GreetingState({
    this.isLoading = false,
    this.greetings = const [],
    this.errorMessage,
    this.expandedItems = const {},
  });

  GreetingState copyWith({
    bool? isLoading,
    List<GreetingRaw>? greetings,
    String? errorMessage,
    Set<int>? expandedItems,
  }) {
    return GreetingState(
      isLoading: isLoading ?? this.isLoading,
      greetings: greetings ?? this.greetings,
      errorMessage: errorMessage,
      expandedItems: expandedItems ?? this.expandedItems,
    );
  }
}

class GreetingViewModel extends StateNotifier<GreetingState> {
  final GreetingRepository _repository;

  GreetingViewModel(this._repository) : super(GreetingState()) {
    fetchGreetings();
  }

  Future<void> fetchGreetings() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final greetings = await _repository.getAll();

      // 모든 아이템을 초기에 펼친 상태로 설정
      final expandedItems = Set<int>.from(
          List.generate(greetings.length, (index) => index)
      );

      state = state.copyWith(
        isLoading: false,
        greetings: greetings,
        expandedItems: expandedItems, // 모든 인덱스가 펼쳐진 상태로 설정
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  // 특정 아이템의 펼침 상태를 토글하는 메서드
  void toggleExpanded(int index) {
    final currentExpandedItems = Set<int>.from(state.expandedItems);

    if (currentExpandedItems.contains(index)) {
      currentExpandedItems.remove(index);
    } else {
      currentExpandedItems.add(index);
    }

    state = state.copyWith(expandedItems: currentExpandedItems);
  }

  // 모든 아이템을 펼치는 메서드
  void expandAll() {
    final allIndices = Set<int>.from(
        List.generate(state.greetings.length, (index) => index)
    );

    state = state.copyWith(expandedItems: allIndices);
  }

  // 모든 아이템을 접는 메서드
  void collapseAll() {
    state = state.copyWith(expandedItems: {});
  }
}
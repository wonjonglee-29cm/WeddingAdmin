import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wedding/data/raw/greeting_raw.dart';
import 'package:wedding/data/repository/greeting_repository.dart';

class GreetingState {
  final bool isLoading;
  final List<GreetingRaw> greetings;
  final String? errorMessage;

  GreetingState({
    this.isLoading = false,
    this.greetings = const [],
    this.errorMessage,
  });

  GreetingState copyWith({
    bool? isLoading,
    List<GreetingRaw>? greetings,
    String? errorMessage,
  }) {
    return GreetingState(
      isLoading: isLoading ?? this.isLoading,
      greetings: greetings ?? this.greetings,
      errorMessage: errorMessage,
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

      state = state.copyWith(
        isLoading: false,
        greetings: greetings,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }
}

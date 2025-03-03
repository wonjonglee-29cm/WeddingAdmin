import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainState {
  final int currentIndex;

  MainState({
    this.currentIndex = 0,
  });

  MainState copyWith({
    int? currentIndex,
  }) {
    return MainState(
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }
}

class MainViewModel extends StateNotifier<MainState> {
  MainViewModel([MainState? state]) : super(state ?? MainState());

  void updateIndex(int index) {
    state = state.copyWith(currentIndex: index);
  }
}

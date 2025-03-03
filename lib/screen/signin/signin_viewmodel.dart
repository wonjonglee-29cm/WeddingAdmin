import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wedding/data/raw/signin_raw.dart';
import 'package:wedding/data/raw/user_info_raw.dart';
import 'package:wedding/data/repository/member_repository.dart';

class SignInState {
  final bool isLoading;
  final String? error;
  final bool isSignedIn;

  SignInState({
    this.isLoading = false,
    this.error,
    this.isSignedIn = false,
  });

  SignInState copyWith({
    bool? isLoading,
    String? error,
    bool? isSignedIn,
  }) {
    return SignInState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isSignedIn: isSignedIn ?? this.isSignedIn,
    );
  }
}

class SignInViewModel extends StateNotifier<SignInState> {
  final MemberRepository _repository;

  SignInViewModel(this._repository) : super(SignInState());

  Future<void> signIn(String name, String phoneNumber) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.signIn(
        SignInRaw(name: name, phoneNumber: phoneNumber),
      );
      state = state.copyWith(isLoading: false, isSignedIn: true);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '너 누구니? 정체를 밝히렴^^',
        isSignedIn: false,
      );
    }
  }
}

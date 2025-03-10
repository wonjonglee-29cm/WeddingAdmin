import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wedding/data/raw/signin_raw.dart';
import 'package:wedding/data/repository/member_repository.dart';

class SignUpState {
  final bool isLoading;
  final String? errorMessage;
  final bool isGroom;

  SignUpState({
    this.isLoading = false,
    this.errorMessage,
    required this.isGroom,
  });

  SignUpState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isGroom,
  }) {
    return SignUpState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isGroom: isGroom ?? this.isGroom,
    );
  }
}

class SignUpViewModel extends StateNotifier<SignUpState> {
  final MemberRepository _repository;

  SignUpViewModel(this._repository) : super(SignUpState(isGroom: true));

  void startLoading() {
    state = state.copyWith(isLoading: true, errorMessage: null);
  }

  void stopLoading() {
    state = state.copyWith(isLoading: false);
  }

  void setError(String message) {
    state = state.copyWith(errorMessage: message, isLoading: false);
  }

  void setIsGroom(bool isGroom) {
    state = state.copyWith(isGroom: isGroom);
  }

  Future<bool> signUp({
    required String name,
  }) async {
    try {
      startLoading();

      // 선택된 역할에 따라 전화번호 설정
      final String phoneNumber = state.isGroom ? '7322' : '0239';

      // 회원가입 요청
      final result = await _repository.signUp(
        SignInRaw(name: name, phoneNumber: phoneNumber),
      );

      stopLoading();
      return result;
    } catch (e) {
      setError(e.toString());
      return false;
    }
  }
}

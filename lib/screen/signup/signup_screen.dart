import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

// SignUp 상태 클래스
class SignUpState {
  final bool isLoading;
  final String? errorMessage;

  SignUpState({
    this.isLoading = false,
    this.errorMessage,
  });

  SignUpState copyWith({
    bool? isLoading,
    String? errorMessage,
  }) {
    return SignUpState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

// SignUp ViewModel
class SignUpViewModel extends StateNotifier<SignUpState> {
  SignUpViewModel() : super(SignUpState());

  void startLoading() {
    state = state.copyWith(isLoading: true, errorMessage: null);
  }

  void stopLoading() {
    state = state.copyWith(isLoading: false);
  }

  void setError(String message) {
    state = state.copyWith(errorMessage: message, isLoading: false);
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      startLoading();
      // 실제 회원가입 로직 구현
      await Future.delayed(const Duration(seconds: 2)); // 회원가입 API 호출 시뮬레이션
      stopLoading();
    } catch (e) {
      setError(e.toString());
    }
  }
}

// SignUp Provider
final signUpProvider = StateNotifierProvider<SignUpViewModel, SignUpState>((ref) {
  return SignUpViewModel();
});

// SignUp 화면
class SignUpScreen extends HookConsumerWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signUpState = ref.watch(signUpProvider);
    final viewModel = ref.read(signUpProvider.notifier);

    // 텍스트 컨트롤러 생성
    final nameController = useTextEditingController();
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('회원가입'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '회원가입 화면',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),

            // 에러 메시지가 있으면 표시
            if (signUpState.errorMessage != null)
              Container(
                padding: const EdgeInsets.all(8),
                color: Colors.red[100],
                child: Text(
                  signUpState.errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),

            const SizedBox(height: 16),

            // 폼 필드들
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: '이름',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: '이메일',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: '비밀번호',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 32),

            // 회원가입 버튼
            ElevatedButton(
              onPressed: signUpState.isLoading
                  ? null
                  : () {
                viewModel.signUp(
                  name: nameController.text,
                  email: emailController.text,
                  password: passwordController.text,
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              child: signUpState.isLoading
                  ? const CircularProgressIndicator()
                  : const Text('회원가입'),
            ),
          ],
        ),
      ),
    );
  }
}
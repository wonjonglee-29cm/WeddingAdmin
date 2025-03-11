import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wedding/design/component/ds_appbar.dart';
import 'package:wedding/design/component/ds_bottom_button.dart';
import 'package:wedding/design/component/ds_selection_button.dart';
import 'package:wedding/design/component/ds_textfield.dart';
import 'package:wedding/design/ds_foundation.dart';
import 'package:wedding/screen/di_viewmodel.dart';

// SignUp 화면
class SignUpScreen extends HookConsumerWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signUpState = ref.watch(signUpViewModelProvider);
    final viewModel = ref.read(signUpViewModelProvider.notifier);

    // 텍스트 컨트롤러 생성
    final nameController = useTextEditingController();

    // 회원가입 함수
    Future<void> handleSignUp() async {
      if (nameController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('이름을 입력해주세요.')),
        );
        return;
      }

      final result = await viewModel.signUp(name: nameController.text);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result ? '회원가입이 완료되었습니다.' : '회원가입이 실패하였습니다.'),
          ),
        );
      }
    }

    return Scaffold(
      appBar: normalAppBar('회원가입'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFieldWidget(
                    controller: nameController,
                    decoration: defaultDecor(hint: '하객 이름을 입력해주세요', labelText: '초대할 하객의 이름을 입력해주세요.'),
                    maxLength: 6,
                    validator: (value) {
                      if (value?.isEmpty ?? true) return '하객 이름이 없습니다.';
                      return null;
                    },
                  ).animate().fadeIn().slideY(begin: 1, end: 0),

                  itemsGap,

                  buildSelectionButtons(
                    '신랑측/신부측 선택',
                    {true: '신랑', false: '신부'},
                    signUpState.isGroom,
                        (value) => viewModel.setIsGroom(value == true),
                  ),
                  itemsGap,

                  // 에러 메시지가 있으면 표시
                  if (signUpState.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        color: Colors.red[100],
                        child: Text(
                          signUpState.errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    )
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: bottomButtonWidget(
              onPressed: signUpState.isLoading ? null : handleSignUp,
              text: '확인',
              isEnabled: !signUpState.isLoading,
            ),
          ),
          itemsGap,
          itemsGap,
        ],
      ),
    );
  }
}

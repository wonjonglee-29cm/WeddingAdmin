import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wedding/design/component/ds_bottom_button.dart';
import 'package:wedding/design/ds_foundation.dart';
import 'package:wedding/screen/di_viewmodel.dart';
import 'package:wedding/screen/main/main_screen.dart';
import 'package:wedding/screen/signin/signin_viewmodel.dart';

import '../../design/component/ds_textfield.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignScreenState();
}

class _SignScreenState extends ConsumerState<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(signInViewModelProvider);

    ref.listen<SignInState>(signInViewModelProvider, (prev, next) {
      if (next.isSignedIn) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFieldWidget(
                      controller: _idController,
                      decoration: defaultDecor(hint: '반가워용', labelText: 'id'),
                      maxLength: 6,
                      validator: (value) {
                        if (value?.isEmpty ?? true) return '아이고 저런 너 누구니?';
                        return null;
                      },
                    ).animate().fadeIn().slideY(begin: 1, end: 0),
                    itemsGap,
                    TextFieldWidget(
                      controller: _passwordController,
                      decoration: defaultDecor(hint: 'hello world!', labelText: 'password'),
                      keyboardType: TextInputType.number,
                      maxLength: 30,
                      obscureText: true,
                    ).animate().fadeIn().slideY(begin: 1, end: 0, delay: const Duration(milliseconds: 200)),
                  ],
                ),
              ),
              itemsGap,
              SizedBox(
                height: 40,
                child: Text(
                  state.error ?? '',
                  style: bodyStyle2.copyWith(color: Colors.red),
                ),
              ),
              const Spacer(),
              bottomButtonWidget(
                      onPressed: state.isLoading
                          ? null
                          : () async {
                              if (_formKey.currentState?.validate() ?? false) {
                                await ref.read(signInViewModelProvider.notifier).signIn(_idController.text, _passwordController.text);
                              }
                            },
                      text: '로그인',
                      padding: EdgeInsets.zero)
                  .animate()
                  .fadeIn()
                  .slideY(begin: 1, end: 0, delay: const Duration(milliseconds: 400)),
            ],
          ),
        ),
      ),
    );
  }
}

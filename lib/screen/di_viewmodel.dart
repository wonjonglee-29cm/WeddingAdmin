import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wedding/data/di_repository.dart';
import 'package:wedding/screen/greeting/greeting_viewmodel.dart';
import 'package:wedding/screen/main/main_viewmodel.dart';
import 'package:wedding/screen/quiz/quiz_ranking_viewmodel.dart';
import 'package:wedding/screen/signin/signin_viewmodel.dart';
import 'package:wedding/screen/signup/signup_viewmodel.dart';

final signInViewModelProvider = StateNotifierProvider<SignInViewModel, SignInState>((ref) {
  return SignInViewModel(ref.watch(memberRepositoryProvider));
});

final mainViewModelProvider = StateNotifierProvider<MainViewModel, MainState>((ref) {
  return MainViewModel();
});

final signUpViewModelProvider = StateNotifierProvider<SignUpViewModel, SignUpState>((ref) {
  final repository = ref.watch(memberRepositoryProvider);
  return SignUpViewModel(repository);
});

final greetingViewModelProvider = StateNotifierProvider.autoDispose<GreetingViewModel, GreetingState>((ref) {
  final repository = ref.watch(greetingRepositoryProvider);
  return GreetingViewModel(repository);
});

final quizRankingViewModelProvider = StateNotifierProvider.autoDispose<QuizRankingViewModel, QuizRankingState>((ref) {
  final repository = ref.watch(quizRepositoryProvider);
  return QuizRankingViewModel(repository);
});

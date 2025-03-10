import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wedding/design/ds_foundation.dart';
import 'package:wedding/screen/di_viewmodel.dart';

import '../attendees/attendees_screen.dart';
import '../greeting/greeting_screen.dart';
import '../quiz/quiz_ranking_screen.dart';
import '../signup/signup_screen.dart';

class MainScreen extends HookConsumerWidget {
  final int? initialTab;
  static DateTime? _lastPressed;

  const MainScreen({this.initialTab, super.key});

  static final List<Widget> _screens = [
    const SignUpScreen(),
    const GreetingScreen(),
    const QuizRankingScreen(),
    const AttendeesScreen(),
  ];
  static const List<BottomNavigationBarItem> _navigationItems = [
    BottomNavigationBarItem(icon: Icon(Icons.account_circle_outlined, size: 20), label: '회원가입'),
    BottomNavigationBarItem(icon: Icon(Icons.event_note_outlined, size: 20), label: '방명록 조회'),
    BottomNavigationBarItem(icon: Icon(Icons.emoji_events_outlined, size: 20), label: '퀴즈 순위 조회'),
    BottomNavigationBarItem(icon: Icon(Icons.celebration_outlined, size: 20), label: '참석자 조회'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mainViewModelProvider);

    useEffect(() {
      if (initialTab != null) {
        ref.read(mainViewModelProvider.notifier).updateIndex(initialTab!);
      }
      return null;
    }, []);

    final currentIndex = state.currentIndex;

    return WillPopScope(
      onWillPop: () async {
        final now = DateTime.now();

        if (_lastPressed == null || now.difference(_lastPressed!) > const Duration(seconds: 2)) {
          _lastPressed = now;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('뒤로가기를 한번 더 누르면 종료됩니다.'),
              duration: Duration(seconds: 2),
            ),
          );
          return false;
        }
        return true;
      },
      child: Scaffold(
        body: SafeArea(
            child: IndexedStack(
          index: currentIndex,
          children: _screens,
        )),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          selectedIconTheme: const IconThemeData(
            size: 24,
          ),
          unselectedIconTheme: const IconThemeData(
            size: 20,
          ),
          selectedFontSize: 14,
          unselectedFontSize: 12,
          selectedItemColor: primaryColor,
          unselectedItemColor: Colors.black,
          backgroundColor: Colors.white,
          elevation: 10,
          currentIndex: currentIndex,
          onTap: (index) => ref.read(mainViewModelProvider.notifier).updateIndex(index),
          items: _navigationItems,
        ),
      ),
    );
  }
}

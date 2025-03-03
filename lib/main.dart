import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wedding/data/di_preference.dart';
import 'package:wedding/design/component/ds_appbar.dart';
import 'package:wedding/screen/signin/signin_screen.dart';

import 'design/ds_foundation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: bgColor,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.dark,
    ),
  );

  final container = ProviderContainer();
  await container.read(sharedPreferencesProvider.future);

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const WeddingApp(),
    ),
  );
}

class WeddingApp extends StatelessWidget {
  const WeddingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '내가 짱이야 아임킹',
      initialRoute: '/',
      theme: ThemeData(
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: mainMaterialColor,
            brightness: Brightness.light,
          ),
          fontFamily: 'NotoSans',
          appBarTheme: AppBarTheme(systemOverlayStyle: systemStyle)
      ),
      home: const SignInScreen(),
    );
  }
}

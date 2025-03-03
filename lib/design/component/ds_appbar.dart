import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wedding/design/ds_foundation.dart';

AppBar backAppBar(String title) => AppBar(
      backgroundColor: bgColor,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      title: Text(title, style: appBarStyle),
      systemOverlayStyle: systemStyle,
    );

AppBar closeAppBar(BuildContext context, String title, {VoidCallback? onPressed}) =>
    AppBar(backgroundColor: bgColor, scrolledUnderElevation: 0, surfaceTintColor: Colors.transparent, systemOverlayStyle: systemStyle, automaticallyImplyLeading: false, centerTitle: true, title: Text(title, style: appBarStyle), actions: [
      IconButton(
        icon: const Icon(Icons.close),
        onPressed: onPressed ?? () => Navigator.pop(context),
      ),
    ]);

AppBar normalAppBar(String title) => AppBar(
      backgroundColor: bgColor,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      title: Text(title, style: appBarStyle),
    );

SystemUiOverlayStyle systemStyle = const SystemUiOverlayStyle(
  statusBarColor: bgColor,
  statusBarIconBrightness: Brightness.dark,
  statusBarBrightness: Brightness.light,
);

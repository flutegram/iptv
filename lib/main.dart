// Copyright 2024. Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed
// by a BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'common/shared_preference.dart';
import 'provider/channel_provider.dart';
import 'provider/settings_provider.dart';
import 'ui/page/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  sharedPreferences = await SharedPreferences.getInstance();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) => MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ChannelProvider()),
      ChangeNotifierProvider(create: (_) => SettingsProvider()),
    ],
    builder: (context, child) {
      final seedColor = context.select((SettingsProvider value) => value.seedColor);
      return MaterialApp(
        title: 'IPTV Player',
        themeMode: ThemeMode.dark,
        theme: ThemeData(
          iconButtonTheme: IconButtonThemeData(
            style: ButtonStyle(
                overlayColor: MaterialStateProperty.all(Colors.grey)
            )
          ),
          filledButtonTheme: FilledButtonThemeData(
            style: ButtonStyle(
                overlayColor: MaterialStateProperty.all(const Color(0x66000000))
            )
          ),
          colorScheme: ColorScheme.fromSeed(
              seedColor: seedColor, brightness: Brightness.dark),
          useMaterial3: true,
        ),
        home: const HomePage(),
      );
    },
  );
}

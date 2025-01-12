// Copyright 2024. Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed
// by a BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'common/shared_preference.dart';
import 'heritage/channel.dart';
import 'heritage/setting.dart';
import 'ui/page/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  sharedPreferences = await SharedPreferences.getInstance();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => ChannelAncestor(
    child: SettingAncestor(
      child: Builder(
        builder: (context) => MaterialApp(
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
              seedColor: InheritedSetting.of(context).seedColor,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
          ),
          home: const HomePage(),
        ),
      ),
    ),
  );
}

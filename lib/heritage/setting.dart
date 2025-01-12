// Copyright 2024. Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed
// by a BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import '../common/shared_preference.dart';

final class InheritedSetting extends InheritedWidget {
  const InheritedSetting._({
    required super.child,
    required this.seedColor,
    required this.setSeedColor,
  });

  final Color seedColor;
  final void Function(Color) setSeedColor;

  static InheritedSetting of(BuildContext context) {
    final result = context.dependOnInheritedWidgetOfExactType<InheritedSetting>();
    assert(result != null, 'No InheritedSetting found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(covariant InheritedSetting oldWidget) =>
    seedColor != oldWidget.seedColor;
}

class SettingAncestor extends StatefulWidget {
  const SettingAncestor({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<SettingAncestor> createState() => _SettingAncestorState();
}

class _SettingAncestorState extends State<SettingAncestor> {
  static const seedColorKey = 'seedColorKey';

  late Color _seedColor;

  @override
  void initState() {
    super.initState();
    final savedColorValue =
      sharedPreferences.getInt(seedColorKey) ?? Colors.deepPurple.value;
    _seedColor = Color(savedColorValue);
  }

  void _setSeedColor(Color color) {
    setState(() {
      _seedColor = color;
      sharedPreferences.setInt(seedColorKey, color.value);
    });
  }

  @override
  Widget build(BuildContext context) => InheritedSetting._(
    seedColor: _seedColor,
    setSeedColor: _setSeedColor,
    child: widget.child,
  );
}

import 'package:flutter/material.dart';

import '../../heritage/setting.dart';

const seedColorMap = {
  'deepPurple': Colors.deepPurple,
  'indigo': Colors.indigo,
  'blue': Colors.blue,
  'green': Colors.green,
  'lime': Colors.lime,
  'red': Colors.red,
  'pink': Colors.pink,
  'orange': Colors.orange,
  'cyan': Colors.cyan,
  'teal': Colors.teal,
};

class SelectSeedColorPage extends StatelessWidget {
  const SelectSeedColorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final seedColor = InheritedSetting.of(context).seedColor;
    final colors = seedColorMap.entries.toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Select Theme Color')),
      body: ListView.builder(
        itemBuilder: (_, index) {
          final color = colors[index];
          return RadioListTile<int>(
              title: Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: color.value,
                    ),
                  ),
                  const SizedBox(width: 10,),
                  Text(color.key.toUpperCase()),
                ],
              ),
              value: color.value.value,
              groupValue: seedColor.value,
              autofocus: seedColor.value == color.value.value,
              onChanged: (value) {
                if (value != null) {
                  InheritedSetting.of(context).setSeedColor(Color(value));
                }
              });
        },
        itemCount: colors.length,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../heritage/channel.dart';

class GlobalLoadingWidget extends StatelessWidget {
  final Widget child;

  const GlobalLoadingWidget({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isLoading = InheritedChannel.of(context).loading;

    return Stack(
      children: [
        child,
        isLoading
            ? Container(
                color: Colors.black26, // 半透明背景
                child: Center(
                  child: LoadingAnimationWidget.beat(
                    color: Theme.of(context).colorScheme.primary,
                    size: 60,
                  ),
                ),
              )
            : const SizedBox.shrink(),
      ],
    );
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iptv/model/channel.dart';

import '../../heritage/channel.dart';
import '../page/video_page.dart';

class ChannelListTile extends StatefulWidget {
  const ChannelListTile({
    super.key,
    required this.item,
  });

  final Channel item;

  @override
  State<ChannelListTile> createState() => _ChannelListTileState();
}

class _ChannelListTileState extends State<ChannelListTile> {
  bool? isAvailable;

  @override
  void initState() {
    super.initState();
    // if (widget.item.url != null) {
    //   isM3U8Playable(widget.item.url!).then((value) {
    //     if (mounted) {
    //       setState(() {
    //         isAvailable = value;
    //       });
    //     }
    //   });
    // }
  }

  @override
  Widget build(BuildContext context) {
    final isFavorite = widget.item.isFavorite;
    final url = widget.item.url;
    return InkWell(
      focusColor: Colors.transparent,
      onTap: () {
        InheritedChannel.of(context).setCurrentChannel(widget.item);
        if (url == null || url.isEmpty) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text("This channel can't be played now")));
        } else {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const VideoPage()));
        }
      },
      onLongPress: () {
        InheritedChannel.of(context).setFavorite(widget.item.id, !isFavorite);
      },
      child: Builder(builder: (context) {
        final hasFocus = Focus.of(context).hasFocus;
        final List<Color> gradient;
        if (url == null) {
          gradient = [Colors.grey, Colors.grey];
        } else if (hasFocus) {
          gradient = [
            Theme.of(context).colorScheme.primary.withAlpha(150),
            Theme.of(context).colorScheme.tertiary.withAlpha(150)
          ];
        } else {
          gradient = [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.tertiary
          ];
        }
        return Container(
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              gradient: LinearGradient(
                  colors: gradient,
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter)),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    bottom: 20, top: 10, left: 40, right: 40),
                child: CachedNetworkImage(
                  width: double.infinity,
                  height: double.infinity,
                  imageUrl: widget.item.logo ?? '',
                  errorWidget: (_, __, ___) => Icon(
                    Icons.tv,
                    size: 24,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
              Align(
                alignment: const Alignment(0, 0.9),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(widget.item.name,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary)),
                  ),
                ),
              ),
              Align(
                alignment: const Alignment(0.9, -0.9),
                child: InkWell(
                  canRequestFocus: false,
                  onTap: () {
                    InheritedChannel.of(context).setFavorite(widget.item.id, !isFavorite);
                  },
                  child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        isFavorite ? Icons.star : Icons.star_border,
                        color: Theme.of(context).colorScheme.onSecondary,
                        size: 24,
                      )),
                ),
              ),
              Align(
                alignment: const Alignment(-0.8, -0.9),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Image.asset(
                    'assets/images/flags/${widget.item.country?.toLowerCase()}.png',
                    height: 12,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
              )
            ],
          ),
        );
      }),
    );
  }
}

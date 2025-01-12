import 'package:flutter/material.dart';
import 'package:iptv/ui/page/country_page.dart';
import 'package:iptv/ui/page/settings_page.dart';
import 'package:iptv/ui/widget/channel_search_delegate.dart';
import 'package:iptv/ui/widget/global_loading_widget.dart';

import '../../heritage/channel.dart';
import '../widget/channel_list_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ScrollController scrollController = ScrollController();
  ChannelSearchDelegate delegate = ChannelSearchDelegate();
  Null Function()? tabListener;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      InheritedChannel.of(context).getChannels();
    });
  }

  @override
  Widget build(BuildContext context) {
    final channels = InheritedChannel.of(context).channels;
    final loading = InheritedChannel.of(context).loading;
    final allChannels = InheritedChannel.of(context).allChannels;
    final allCategories = InheritedChannel.of(context).allCategories;
    final category = InheritedChannel.of(context).category;
    final country = InheritedChannel.of(context).country;

    return GlobalLoadingWidget(
      child: OrientationBuilder(
        builder: (context, orientation) {
          if (orientation == Orientation.portrait) {
            return DefaultTabController(
              length: allCategories.length,
              initialIndex: allCategories.indexOf(category),
              child: Scaffold(
                appBar: AppBar(
                  leading: Image.asset('assets/images/ic_banner.png', width: 120, height: 60,),
                  leadingWidth: 120,
                  actions: [
                    IconButton(
                        onPressed: () {
                          Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const CountryPage()));
                        },
                        icon: Builder(
                            builder: (context) {
                              Widget icon;
                              if (country == 'all') {
                                icon = const Icon(Icons.language);
                              } else if (country == 'uncategorized') {
                                icon = const Icon(Icons.question_mark);
                              } else {
                                icon = Image.asset('assets/images/flags/${country.toLowerCase()}.png', height: 24,);
                              }
                              return icon;
                            }
                        )
                    ),
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {
                        showSearch(
                          context: context,
                          delegate: delegate,
                        );
                      },
                    ),
                    IconButton(
                        onPressed: () {
                          Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const SettingsPage()));
                        },
                        icon: const Icon(Icons.settings,)
                    ),
                  ],
                  bottom: TabBar(
                    isScrollable:true,
                    tabs: allCategories.map((e) => Tab(text: e.toUpperCase(),)).toList(),
                  ),
                ),
                body: Builder(
                  builder: (context) {
                    final tabController = DefaultTabController.of(context);
                    if (tabListener != null) {
                      tabController.removeListener(tabListener!);
                    }
                    tabListener = () {
                      if(tabController.indexIsChanging) {
                        InheritedChannel.of(context)
                            .selectCategory(allCategories[tabController.index]);
                        scrollController.jumpTo(0);
                      }
                    };
                     tabController.addListener(tabListener!);
                    return Column(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Expanded(
                                child: Visibility(
                                  visible: loading || allChannels.isNotEmpty,
                                  replacement: Center(
                                    child: FilledButton(
                                      onPressed: () {
                                        InheritedChannel.of(context).getChannels();
                                      },
                                      child: const Text('Try Again'),
                                    ),
                                  ),
                                  child: Scrollbar(
                                    child: GridView.builder(
                                      padding: const EdgeInsets.only(top: 10),
                                      controller: scrollController,
                                      itemBuilder: (context, index) {
                                        final item = channels[index];
                                        return ChannelListTile(item: item);
                                      },
                                      itemCount: channels.length,
                                      gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                          mainAxisSpacing: 5,
                                          crossAxisSpacing: 5,
                                          crossAxisCount: 3,
                                          childAspectRatio: 1.2),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    );
                  }
                ), // This trailing comma makes auto-formatting nicer for build methods.
              ),
            );
          }
          return Scaffold(
            appBar: AppBar(
              leading: Image.asset('assets/images/ic_banner.png', width: 120, height: 60,),
              leadingWidth: 120,
              actions: [
                IconButton(
                    onPressed: () {
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const CountryPage()));
                    },
                    icon: Builder(
                        builder: (context) {
                          Widget icon;
                          if (country == 'all') {
                            icon = const Icon(Icons.language);
                          } else if (country == 'uncategorized') {
                            icon = const Icon(Icons.question_mark);
                          } else {
                            icon = Image.asset('assets/images/flags/${country.toLowerCase()}.png', height: 24,);
                          }
                          return icon;
                        }
                    )
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    showSearch(
                      context: context,
                      delegate: delegate,
                    );
                  },
                ),
                IconButton(
                    onPressed: () {
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const SettingsPage()));
                    },
                    icon: const Icon(Icons.settings,)
                ),
              ],
            ),
            body: Row(
              children: [
                SizedBox(
                  width: 180,
                  height: double.infinity,
                  child: ListView.builder(
                    itemBuilder: (_, index) {
                      final item = allCategories[index];
                      return ListTile(
                        autofocus: category == item,
                        title: Text(item.toUpperCase()),
                        selected: category == item,
                        selectedTileColor: Theme.of(context).colorScheme.onPrimary,
                        selectedColor: Theme.of(context).colorScheme.primary,
                        onTap: () {
                          InheritedChannel.of(context).selectCategory(item);
                          scrollController.jumpTo(0);
                        },
                      );
                    },
                    itemCount: allCategories.length,
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: Visibility(
                          visible: loading || allChannels.isNotEmpty,
                          replacement: Center(
                            child: FilledButton(
                              onPressed: () {
                                InheritedChannel.of(context).getChannels();
                              },
                              child: const Text('Try Again'),
                            ),
                          ),
                          child: Scrollbar(
                            child: GridView.builder(
                              controller: scrollController,
                              itemBuilder: (context, index) {
                                final item = channels[index];
                                return ChannelListTile(item: item);
                              },
                              itemCount: channels.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                      mainAxisSpacing: 5,
                                      crossAxisSpacing: 5,
                                      crossAxisCount: 4,
                                      childAspectRatio: 1.2),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ), // This trailing comma makes auto-formatting nicer for build methods.
          );
        }
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }
}

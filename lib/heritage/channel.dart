// Copyright 2024. Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed
// by a BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../common/data.dart';
import '../common/logger.dart';
import '../common/shared_dio.dart';
import '../common/shared_preference.dart';
import '../model/channel.dart';
import '../model/m3u8_entry.dart';

final class InheritedChannel extends InheritedWidget {
  const InheritedChannel._({
    required super.child,
    required this.channels,
    required this.allChannels,
    required this.searchResultChannels,
    required this.favoriteList,
    required this.m3u8UrlList,
    required this.allCategories,
    required this.allCountries,
    required this.currentChannel,
    required this.currentUrl,
    required this.category,
    required this.country,
    required this.loading,
    required this.resetM3UContent,
    required this.importFromUrl,
    required this.deleteM3u8Url,
    required this.getChannels,
    required this.selectCategory,
    required this.resetFilter,
    required this.selectCountry,
    required this.setFavorite,
    required this.setCurrentChannel,
    required this.previousChannel,
    required this.nextChannel,
  });

  final List<Channel> channels;
  final List<Channel> allChannels;
  final List<Channel> searchResultChannels;
  final List<String> favoriteList;
  final List<String> m3u8UrlList;
  final List<String> allCategories;
  final List<String> allCountries;
  final Channel? currentChannel;
  final String? currentUrl;
  final String category;
  final String country;
  final bool loading;

  final Future<void> Function() resetM3UContent;
  final Future<bool> Function(String) importFromUrl;
  final void Function(String) deleteM3u8Url;
  final Future<bool> Function() getChannels;
  final void Function(String) selectCategory;
  final Future<void> Function() resetFilter;
  final void Function(String) selectCountry;
  final void Function(String, bool) setFavorite;
  final void Function(Channel?) setCurrentChannel;
  final bool Function() previousChannel;
  final bool Function() nextChannel;

  static InheritedChannel of(BuildContext context) {
    final result =
      context.dependOnInheritedWidgetOfExactType<InheritedChannel>();
    assert(result != null, 'No InheritedChannel found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(InheritedChannel oldWidget) =>
    channels != oldWidget.channels ||
    allChannels != oldWidget.allChannels ||
    searchResultChannels != oldWidget.searchResultChannels ||
    favoriteList != oldWidget.favoriteList ||
    m3u8UrlList != oldWidget.m3u8UrlList ||
    allCategories != oldWidget.allCategories ||
    allCountries != oldWidget.allCountries ||
    currentChannel != oldWidget.currentChannel ||
    currentUrl != oldWidget.currentUrl ||
    category != oldWidget.category ||
    country != oldWidget.country ||
    loading != oldWidget.loading;
}

class ChannelAncestor extends StatefulWidget {
  const ChannelAncestor({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<ChannelAncestor> createState() => _ChannelAncestorState();
}

class _ChannelAncestorState extends State<ChannelAncestor> {
  List<Channel> channels = [];
  List<Channel> allChannels = [];
  List<Channel> searchResultChannels = [];
  List<String> favoriteList = [];
  List<String> m3u8UrlList = [];
  List<String> allCategories = ['favorite', 'all'];
  List<String> allCountries = ['all'];
  Channel? currentChannel;
  String? currentUrl;
  String category = 'all';
  String country = 'all';
  bool loading = false;

  static const favoriteListKey = 'favoriteListKey';
  static const countryKey = 'countryKey';
  static const m3u8UrlKey = 'm3u8UrlKey';
  static const m3u8UrlListKey = 'm3u8UrlListKey';

  Future<void> resetM3UContent() async {
    await importFromUrl(defaultM3u8Url);
  }

  Future<bool> importFromUrl(String url) async {
    sharedPreferences.setString(m3u8UrlKey, url);
    final result = await getChannels();
    if (result) {
      resetFilter();
      if (!m3u8UrlList.contains(url)) {
        m3u8UrlList.add(url);
        sharedPreferences.setStringList(m3u8UrlListKey, m3u8UrlList);
        setState(() {});
      }
    } else {
      sharedPreferences.setString(m3u8UrlKey, currentUrl ?? defaultM3u8Url);
    }
    return result;
  }

  void deleteM3u8Url(String url) {
    final copiedList = m3u8UrlList.toList();
    if (copiedList.remove(url)) {
      m3u8UrlList = copiedList;
      sharedPreferences.setStringList(m3u8UrlListKey, copiedList);
      setState(() {});
    }
  }

  Future<bool> getChannels() async {
    var result = true;
    loading = true;
    setState(() {});
    favoriteList = sharedPreferences.getStringList(favoriteListKey) ?? [];
    country = sharedPreferences.getString(countryKey) ?? 'all';
    m3u8UrlList = sharedPreferences.getStringList(m3u8UrlListKey) ?? [defaultM3u8Url];
    try {
      final url = sharedPreferences.getString(m3u8UrlKey) ?? defaultM3u8Url;
      final response = await sharedDio.get(url);
      String m3uContent = response.data.toString();
      await _parseChannels(m3uContent);
      currentUrl = url;
    } catch (e) {
      logger.e('getChannels failed', error: e);
      result = false;
    }
    loading = false;
    setState(() {});
    return result;
  }

  Future<void> _parseChannels(String m3uContent) async {
    final m3u8List = parseM3U8(m3uContent);
    logger.i('_parseChannels ${m3u8List.length}');
    final channelsContent = await rootBundle.loadString(
        'assets/files/channels.json');
    final channelMap = Map.fromEntries((jsonDecode(channelsContent) as List).map((e) {
      final channel = Channel.fromJson(e);
      return MapEntry(channel.id, channel);
    }));

    Set<String> categorySet = {};
    Set<String> countrySet = {};
    for (final entry in m3u8List) {
      var channel = channelMap[entry.tvgId];
      if (channel == null) {
        channel = entry.toChannel();
        channelMap[channel.id] = channel;
      }
      channel.isFavorite = favoriteList.contains(channel.id);
      channel.url = entry.url;
      categorySet.addAll(channel.categories);
      countrySet.add(channel.country ?? 'uncategorized');
    }
    final categoryList = categorySet.toList();
    categoryList.sort();
    allCategories = ['favorite', 'all'] + categoryList;
    final countryList = countrySet.toList();
    countryList.sort();
    allCountries = ['all'] + countryList;
    allChannels = channelMap.values.where((element) => element.url != null).toList();
    channels = await _filterChannel();
  }

  void selectCategory(String category) async {
    this.category = category;
    var channelList = await _filterChannel();
    channels = channelList;
    setState(() {});
  }

  Future<List<Channel>> _filterChannel() async{
    List<Channel> channelList = allChannels.toList();
    final isFavorite = category == 'favorite';
    if (isFavorite) {
      channelList = channelList.where((element) => element.isFavorite).toList();
    } else if (category != 'all') {
      channelList = channelList
          .where((element) => element.categories.contains(category))
          .toList();
    }
    if (country != 'all' && !isFavorite) {
      channelList = channelList
          .where((element) => element.country == country)
          .toList();
    }
    return channelList;
  }

  Future<void> resetFilter() async {
    const all = 'all';
    sharedPreferences.setString(countryKey, all);
    country = all;
    category = all;
    var channelList = _filterChannel();
    channels = await channelList;
    setState(() {});
  }

  void selectCountry(String country) async {
    sharedPreferences.setString(countryKey, country);
    this.country = country;
    var channelList = _filterChannel();
    channels = await channelList;
    setState(() {});
  }

  void setFavorite(String id, bool isFavorite) async {
    if (isFavorite) {
      if (!favoriteList.contains(id)) {
        favoriteList.add(id);
      }
    } else {
      favoriteList.remove(id);
    }
        () {
      final index = allChannels.indexWhere((element) => element.id == id);
      if (index >= 0) {
        final copiedChannelList = allChannels.toList();
        final channel = copiedChannelList[index].copyWith(isFavorite: isFavorite);
        copiedChannelList[index] = channel;
        allChannels = copiedChannelList;
        if (currentChannel != null && currentChannel!.id == channel.id) {
          currentChannel = channel;
        }
        setState(() {});
      }
    }();
        () {
      final index = channels.indexWhere((element) => element.id == id);
      if (index >= 0) {
        final copiedChannelList = channels.toList();
        final channel = copiedChannelList[index].copyWith(isFavorite: isFavorite);
        copiedChannelList[index] = channel;
        channels = copiedChannelList;
        if (currentChannel != null && currentChannel!.id == channel.id) {
          currentChannel = channel;
        }
        setState(() {});
      }
    }();
    sharedPreferences.setStringList(favoriteListKey, favoriteList);
  }

  void setCurrentChannel(Channel? channel) {
    setState(() {
      currentChannel = channel;
    });
  }

  bool previousChannel() {
    if (currentChannel != null) {
      final index = channels.indexOf(currentChannel!);
      if (index > 0 && index < channels.length) {
        setCurrentChannel(channels[index - 1]);
        return true;
      }
    }
    return false;
  }

  bool nextChannel() {
    if (currentChannel != null) {
      final index = channels.indexOf(currentChannel!);
      if (index >= 0 && index < channels.length - 1) {
        setCurrentChannel(channels[index + 1]);
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) => InheritedChannel._(
    channels: channels,
    allChannels: allChannels,
    searchResultChannels: searchResultChannels,
    favoriteList: favoriteList,
    m3u8UrlList: m3u8UrlList,
    allCategories: allCategories,
    allCountries: allCountries,
    currentChannel: currentChannel,
    currentUrl: currentUrl,
    category: category,
    country: country,
    loading: loading,
    resetM3UContent: resetM3UContent,
    importFromUrl: importFromUrl,
    deleteM3u8Url: deleteM3u8Url,
    getChannels: getChannels,
    selectCategory: selectCategory,
    resetFilter: resetFilter,
    selectCountry: selectCountry,
    setFavorite: setFavorite,
    setCurrentChannel: setCurrentChannel,
    previousChannel: previousChannel,
    nextChannel: nextChannel,
    child: widget.child,
  );
}

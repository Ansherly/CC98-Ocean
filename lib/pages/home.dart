import 'package:cc98_ocean/controls/app_shell.dart';
import 'package:cc98_ocean/pages/boards.dart';
import 'package:cc98_ocean/pages/favorite.dart';
import 'package:cc98_ocean/pages/discover.dart';
import 'package:cc98_ocean/pages/focus.dart';
import 'package:cc98_ocean/pages/index.dart';
import 'package:cc98_ocean/pages/profile.dart';
import 'package:cc98_ocean/pages/settings.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // 移动端底栏使用的本地索引；桌面端由 AppShell 侧栏驱动
  int selectedIndex = 0;

  bool get _isDesktop => AppShell.isDesktop;

  @override
  void initState() {
    super.initState();
    if (_isDesktop) {
      // 由 Login 推入 Home 时恢复侧栏显示
      AppShell.sidebarVisible.value = true;
      AppShell.selectedIndex.addListener(_onShellIndexChanged);
    }
  }

  void _onShellIndexChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    if (_isDesktop) {
      AppShell.selectedIndex.removeListener(_onShellIndexChanged);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isDesktop) {
      // 桌面端：侧栏在 AppShell 壳内常驻，这里只负责内容区切换
      return Scaffold(
        body: SafeArea(child: buildPage(AppShell.selectedIndex.value)),
      );
    }

    // 移动端 / Web：底栏导航
    return Scaffold(
      body: SafeArea(child: buildPage(selectedIndex)),
      bottomNavigationBar: buildBottomNavigationBar(),
    );
  }

  /// 按索引返回内容页。
  /// 桌面侧栏：0 首页 / 1 动态 / 2 收藏 / 3 发现 / 4 版块 / footer 5 我 / 6 设置。
  /// 移动底栏：0 首页 / 1 动态 / 2 发现 / 3 版面 / 4 我的。
  Widget buildPage(int index) {
    switch (index) {
      case 0:
        return const Index();
      case 1:
        return const Moments();
      case 2:
        return _isDesktop ? const FavoritesPage() : const Discover();
      case 3:
        return _isDesktop ? const Discover() : const Boards();
      case 4:
        return _isDesktop
            ? const Boards()
            : const Profile();
      case 5:
        return _isDesktop
            ? const Profile()
            : const Index();
      case 6:
        return _isDesktop ? const Settings() : const Index();
      default:
        return const Index();
    }
  }

  Widget buildBottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      onTap: (i) => setState(() {
        selectedIndex = i;
      }),
      currentIndex: selectedIndex.clamp(0, 4),
      items: const [
        BottomNavigationBarItem(icon: Icon(FluentIcons.design_ideas_16_regular), label: '首页',),
        BottomNavigationBarItem(icon: Icon(FluentIcons.animal_paw_print_16_regular), label: '动态'),
        BottomNavigationBarItem(icon: Icon(FluentIcons.leaf_one_16_regular), label: '发现'),
        BottomNavigationBarItem(icon: Icon(FluentIcons.board_16_regular), label: '版面'),
        BottomNavigationBarItem(icon: Icon(FluentIcons.person_16_regular), label: '我的'),
      ],
    );
  }
}

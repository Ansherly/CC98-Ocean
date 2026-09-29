import 'dart:io';

import 'package:cc98_ocean/core/constants/color_tokens.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sidebarx/sidebarx.dart';
import 'package:window_manager/window_manager.dart';

/// 桌面端应用壳：自定义标题栏 + 左侧导航。
///
/// 通过 [MaterialApp.builder] 挂载在 Navigator 之外，
/// 因此 push 任何二级页面（帖子/聊天/搜索等）时标题栏与侧栏始终保持可见，
/// 二级页面渲染在侧栏右侧的内容区中。移动端 / Web 直接透传 child。
class AppShell extends StatefulWidget {
  final Widget child;

  /// 应用启动时是否已登录（决定侧栏初始可见性）。
  final bool initiallyLoggedIn;

  const AppShell({
    super.key,
    required this.child,
    required this.initiallyLoggedIn,
  });

  /// 侧栏可见性：登录页隐藏，主页内容显示。
  /// 由 [Login] / [Home] 的生命周期维护。
  static final ValueNotifier<bool> sidebarVisible = ValueNotifier(true);

  /// 当前选中的导航索引（桌面侧栏与页面内容共享）。
  static final ValueNotifier<int> selectedIndex = ValueNotifier(0);

  /// 侧栏控制器（桌面端持有，供壳与页面联动）。
  static final SidebarXController sidebarController =
      SidebarXController(selectedIndex: 0, extended: false);

  /// 根导航器，用于侧栏切换时清除压入的二级页面。
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static bool get isDesktop =>
      !kIsWeb &&
      (Platform.isWindows || Platform.isLinux || Platform.isMacOS);

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  @override
  void initState() {
    super.initState();
    AppShell.sidebarVisible.value = widget.initiallyLoggedIn;
    AppShell.sidebarController.addListener(_onSidebarChanged);
  }

  /// 侧栏切换：同步索引，并弹出压在内容区上的二级页面。
  void _onSidebarChanged() {
    final index = AppShell.sidebarController.selectedIndex;
    if (AppShell.selectedIndex.value == index) return;
    AppShell.selectedIndex.value = index;
    final navigator = AppShell.navigatorKey.currentState;
    if (navigator != null && navigator.canPop()) {
      navigator.popUntil((route) => route.isFirst);
    }
  }

  @override
  void dispose() {
    AppShell.sidebarController.removeListener(_onSidebarChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!AppShell.isDesktop) return widget.child;

    final scaffoldColor = Theme.of(context).scaffoldBackgroundColor;
    // 壳内包含侧栏 InkWell 等需要 Material 祖先的组件，整体包一层 Material
    return Material(
      color: scaffoldColor,
      child: Column(
        children: [
          // 标题栏始终存在：拖动窗口 + 最小化/最大化/关闭
          buildTitleBar(),
          Expanded(
            child: Row(
              children: [
                // 左侧导航始终存在（登录页除外）
                ValueListenableBuilder<bool>(
                  valueListenable: AppShell.sidebarVisible,
                  builder: (context, visible, _) =>
                      visible ? buildSideBar() : const SizedBox.shrink(),
                ),
                Expanded(child: widget.child),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── 标题栏 ──────────────────────────────────────────

  Widget buildTitleBar() {
    return SizedBox(
      height: 48.0,
      child: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                // 使标题栏可拖动
                behavior: HitTestBehavior.translucent,
                onPanStart: (details) {
                  windowManager.startDragging();
                },
                onDoubleTap: () async {
                  // 双击标题栏切换最大化
                  if (await windowManager.isMaximized()) {
                    windowManager.unmaximize();
                  } else {
                    windowManager.maximize();
                  }
                },
                child: const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Text('CC98 Ocean'),
                ),
              ),
            ),
            Row(
              children: [
                buildWindowOperation(
                    FluentIcons.arrow_minimize_16_regular, windowManager.minimize),
                buildWindowOperation(
                    FluentIcons.maximize_16_regular, windowManager.maximize),
                buildWindowOperation(
                    FluentIcons.dismiss_16_regular, windowManager.close),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── 左侧导航（自 home.dart 迁移，常驻于壳内） ────────

  Widget buildSideBar() {
    return SafeArea(
      child: SidebarX(
        controller: AppShell.sidebarController,
        items: const [
          SidebarXItem(icon: FluentIcons.design_ideas_16_regular, label: '首页'),
          SidebarXItem(icon: FluentIcons.animal_paw_print_16_regular, label: '收藏'),
          SidebarXItem(icon: FluentIcons.leaf_one_16_regular, label: '发现'),
          SidebarXItem(icon: FluentIcons.board_16_regular, label: '版块'),
        ],
        extendIcon: FluentIcons.chevron_right_16_regular,
        collapseIcon: FluentIcons.chevron_left_16_regular,
        showToggleButton: MediaQuery.of(context).size.width > 600,
        footerItems: const [
          SidebarXItem(icon: FluentIcons.mail_all_read_20_regular, label: '我'),
          SidebarXItem(icon: FluentIcons.star_settings_20_regular, label: '设置'),
        ],
        // 展开时的主题
        extendedTheme: SidebarXTheme(
          width: 200,
          itemTextPadding: const EdgeInsets.only(left: 16),
          textStyle: const TextStyle(color: ColorTokens.softPurple),
          selectedTextStyle: const TextStyle(color: ColorTokens.softOrange),
          selectedItemDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey.withOpacity(0.12),
          ),
          selectedItemTextPadding: const EdgeInsets.only(left: 16),
          margin: const EdgeInsets.fromLTRB(10, 12, 10, 12),
          padding: const EdgeInsets.fromLTRB(0, 6, 0, 0),
          // 此装饰作用于整个导航板
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.withOpacity(0.3), width: 1),
          ),
        ),
        theme: SidebarXTheme(
          selectedItemMargin:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          itemMargin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          margin: const EdgeInsets.fromLTRB(10, 12, 10, 12),
          padding: const EdgeInsets.fromLTRB(0, 6, 0, 0),
          textStyle: const TextStyle(color: ColorTokens.softPurple),
          selectedItemDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey.withOpacity(0.12),
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.withOpacity(0.3), width: 1),
          ),
          width: 64,
          iconTheme: const IconThemeData(
              color: Color.fromARGB(255, 196, 171, 212)),
          selectedIconTheme: const IconThemeData(
              color: Color.fromARGB(255, 240, 128, 128)),
        ),
      ),
    );
  }
}

/// 标题栏窗口操作按钮。
Widget buildWindowOperation(IconData icon, VoidCallback? onPressed) {
  return TextButton(
    onPressed: () => {onPressed?.call()},
    style: TextButton.styleFrom(
      padding: EdgeInsets.zero,
      fixedSize: const Size.square(48),
      minimumSize: const Size(32, 32),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    ),
    child: Icon(icon, color: ColorTokens.softPurple),
  );
}

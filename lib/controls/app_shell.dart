import 'dart:io';

import 'package:cc98_ocean/core/constants/color_tokens.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

/// 桌面端应用壳：自定义标题栏 + Fluent 风格左侧导航（对齐 WinUI NavigationView）。
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
  /// 桌面：0 首页 / 1 动态 / 2 收藏 / 3 发现 / 4 版块 / footer 5 我 / 6 设置。
  static final ValueNotifier<int> selectedIndex = ValueNotifier(0);

  /// 侧栏展开状态（汉堡按钮切换：48px 窄栏 ↔ 216px 展开栏）。
  static final ValueNotifier<bool> sidebarExpanded = ValueNotifier(false);

  /// 根导航器，用于侧栏切换时清除压入的二级页面。
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static bool get isDesktop =>
      !kIsWeb &&
      (Platform.isWindows || Platform.isLinux || Platform.isMacOS);

  /// 侧栏条目点击：同步索引，并弹出压在内容区上的二级页面。
  static void selectIndex(int index) {
    if (AppShell.selectedIndex.value != index) {
      AppShell.selectedIndex.value = index;
    }
    // 无论是否切换项，都回到该页根部（清除二级页面）
    final navigator = navigatorKey.currentState;
    if (navigator != null && navigator.canPop()) {
      navigator.popUntil((route) => route.isFirst);
    }
  }

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  @override
  void initState() {
    super.initState();
    AppShell.sidebarVisible.value = widget.initiallyLoggedIn;
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
                      visible ? const _FluentSideBar() : const SizedBox.shrink(),
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
}

/// Fluent NavigationView 风格的左侧导航。
///
/// 对齐 WinUI：面板**贴窗左边、顶部与标题栏/内容分隔线平齐**，
/// 无外边距、无圆角、无外框，仅右侧一条竖分隔线；内部只有很小的 padding。
/// 收起态 48px（图标居中 + 选中胶囊条）/ 展开态 216px（图标 + 文字）。
class _FluentSideBar extends StatelessWidget {
  const _FluentSideBar();

  static const List<({String label, IconData icon})> _items = [
    (label: '首页', icon: FluentIcons.design_ideas_16_regular),
    (label: '动态', icon: FluentIcons.alert_16_regular),
    (label: '收藏', icon: FluentIcons.animal_paw_print_16_regular),
    (label: '发现', icon: FluentIcons.leaf_one_16_regular),
    (label: '版块', icon: FluentIcons.board_16_regular),
  ];

  static const List<({String label, IconData icon})> _footerItems = [
    (label: '我', icon: FluentIcons.person_16_regular),
    (label: '设置', icon: FluentIcons.settings_16_regular),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // 侧栏位于 Navigator 之外，没有全局 Overlay；Tooltip 需要局部 Overlay。
    // Row 中宽度无界，Overlay 外需 SizedBox 提供有限宽度。
    return ValueListenableBuilder<bool>(
      valueListenable: AppShell.sidebarExpanded,
      builder: (context, expanded, _) => SizedBox(
        width: expanded ? 216.0 : 48.0,
        child: Overlay(
          initialEntries: [
            OverlayEntry(
              // OverlayEntry 的内容不随外层重建：其 builder 只会在内部依赖
              // 变化时重跑。因此这里再订阅一次 sidebarExpanded，
              // 保证展开/收起时条目立刻重建出正确的图标+文字。
              builder: (context) => ValueListenableBuilder<bool>(
                valueListenable: AppShell.sidebarExpanded,
                builder: (context, expanded, _) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  // 贴边整块面板：无外边距 / 圆角，仅右侧竖分隔线
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerLow,
                    border: Border(
                      right: BorderSide(
                        color: theme.dividerColor.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                  ),
                  // 内部仅很小的 padding（WinUI 的 4px 量级）
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHamburger(expanded),
                      const SizedBox(height: 2),
                      for (var i = 0; i < _items.length; i++)
                        _buildItem(
                          index: i,
                          label: _items[i].label,
                          icon: _items[i].icon,
                          expanded: expanded,
                        ),
                      const Spacer(),
                      // footer 分隔线
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Divider(
                          height: 1,
                          thickness: 1,
                          color: theme.dividerColor.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 2),
                      for (var i = 0; i < _footerItems.length; i++)
                        _buildItem(
                          index: _items.length + i,
                          label: _footerItems[i].label,
                          icon: _footerItems[i].icon,
                          expanded: expanded,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHamburger(bool expanded) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: expanded ? 4 : 2),
      child: Tooltip(
        message: expanded ? '收起导航' : '展开导航',
        child: _NavItem(
          icon: FluentIcons.line_horizontal_3_20_regular,
          label: expanded ? '导航' : null,
          selected: false,
          onTap: () =>
              AppShell.sidebarExpanded.value = !AppShell.sidebarExpanded.value,
        ),
      ),
    );
  }

  Widget _buildItem({
    required int index,
    required String label,
    required IconData icon,
    required bool expanded,
  }) {
    // 小内边距：收起 2px / 展开 4px（面板本身另有 4px 竖向 padding）
    final hPad = expanded ? 4.0 : 2.0;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 2),
      child: ValueListenableBuilder<int>(
        valueListenable: AppShell.selectedIndex,
        builder: (context, selected, _) {
          final item = _NavItem(
            icon: icon,
            label: expanded ? label : null,
            selected: selected == index,
            onTap: () => AppShell.selectIndex(index),
          );
          // 收起态用 Tooltip 提供标签提示
          return expanded ? item : Tooltip(message: label, child: item);
        },
      ),
    );
  }
}

/// 单条导航项：左侧圆角胶囊指示条 + 居中图标（+ 展开态文字）。
class _NavItem extends StatelessWidget {
  final IconData icon;
  final String? label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.selected,
    required this.onTap,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = ColorTokens.softPurple;
    final hasLabel = label != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      hoverColor: theme.colorScheme.onSurface.withOpacity(0.05),
      child: Container(
        // 收起态固定 40×36；展开态定高、宽度撑满
        width: hasLabel ? null : 40,
        height: 36,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: selected
              ? theme.colorScheme.primary.withOpacity(0.08)
              : Colors.transparent,
        ),
        // Stack：胶囊贴左缘垂直居中；图标两种形态都在项内居中（对齐 WinUI）
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              left: 4,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeOut,
                width: 3,
                height: selected ? 18 : 0,
                decoration: BoxDecoration(
                  color: selected ? accent : Colors.transparent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            if (!hasLabel)
              Icon(
                icon,
                size: 20,
                color: selected ? accent : theme.colorScheme.onSurfaceVariant,
              ),
            if (hasLabel)
              Positioned.fill(
                left: 14,
                right: 4,
                child: Row(
                  children: [
                    Icon(
                      icon,
                      size: 20,
                      color: selected
                          ? accent
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        label!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 14,
                          color: selected
                              ? accent
                              : theme.colorScheme.onSurfaceVariant,
                          fontWeight:
                              selected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
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

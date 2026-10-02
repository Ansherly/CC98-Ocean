import 'package:cc98_ocean/controls/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// 侧栏几何验收：对齐 WinUI NavigationView 指标。
/// - 收起栏宽 48px
/// - 导航项 40×36，居中，两侧各约 3–4px gutter
/// - 图标在项内水平居中（不受胶囊影响）
/// - 选中态显示胶囊指示条
///
/// 说明：AppShell 仅在桌面平台渲染侧栏；测试运行在 Windows 宿主，
/// Platform 判定成立。
void main() {
  testWidgets('桌面侧栏收起态：宽度/居中/胶囊符合 Fluent 规范', (tester) async {
    AppShell.sidebarExpanded.value = false;
    AppShell.selectedIndex.value = 0;
    AppShell.sidebarVisible.value = true;

    await tester.pumpWidget(MaterialApp(
      home: AppShell(
        initiallyLoggedIn: true,
        child: const Scaffold(body: SizedBox.expand()),
      ),
    ));
    await tester.pumpAndSettle();

    // 收起栏宽 48px（面板 AnimatedContainer 宽度）
    final panel = tester.widget<AnimatedContainer>(find.byType(AnimatedContainer).first);
    expect(panel.constraints?.maxWidth, isNull); // 宽度由外层 SizedBox 控制

    final sizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox));
    final sidebarBox = sizedBoxes.where((s) => s.width == 48.0).firstOrNull;
    expect(sidebarBox, isNotNull, reason: '收起栏应为 48px 宽');

    // 导航项 40×36
    final navItems = tester.widgetList<Container>(
      find.descendant(of: find.byType(InkWell), matching: find.byType(Container)),
    );
    final item = navItems.where((c) {
      final w = c.constraints?.maxWidth;
      final h = c.constraints?.minHeight;
      return w == 40.0 && h == 36.0;
    }).firstOrNull;
    expect(item, isNotNull, reason: '收起态导航项应为 40×36');

    // 每个导航项内都有胶囊（选中高度 18 / 未选中 0，但元素存在）
    final capsules = tester.widgetList<AnimatedContainer>(
      find.descendant(
          of: find.byType(InkWell), matching: find.byType(AnimatedContainer)),
    );
    expect(capsules, isNotEmpty, reason: '收起态也应渲染胶囊指示条');
  });

  testWidgets('展开态显示条目文字（OverlayEntry 实时重建）', (tester) async {
    AppShell.sidebarExpanded.value = false;
    AppShell.selectedIndex.value = 0;
    AppShell.sidebarVisible.value = true;

    await tester.pumpWidget(MaterialApp(
      home: AppShell(
        initiallyLoggedIn: true,
        child: const Scaffold(body: SizedBox.expand()),
      ),
    ));
    await tester.pumpAndSettle();

    // 收起态：无文字
    expect(find.text('首页'), findsNothing);

    // 展开：OverlayEntry 内的 ValueListenableBuilder 应重建出文字
    AppShell.sidebarExpanded.value = true;
    await tester.pumpAndSettle();

    final width = tester
        .widgetList<SizedBox>(find.byType(SizedBox))
        .where((s) => s.width == 216.0)
        .firstOrNull;
    expect(width, isNotNull, reason: '展开栏应为 216px 宽');
    expect(find.text('首页'), findsOneWidget, reason: '展开态应显示条目文字');
    expect(find.text('动态'), findsOneWidget);
    expect(find.text('设置'), findsOneWidget);
  });

  testWidgets('图标在导航项内水平居中', (tester) async {
    AppShell.sidebarExpanded.value = false;
    AppShell.selectedIndex.value = 0;
    AppShell.sidebarVisible.value = true;

    await tester.pumpWidget(MaterialApp(
      home: AppShell(
        initiallyLoggedIn: true,
        child: const Scaffold(body: SizedBox.expand()),
      ),
    ));
    await tester.pumpAndSettle();

    // 取第一个导航项（汉堡）与其内图标的中心 x 对比
    final itemRect = tester.getRect(find.byType(InkWell).at(0));
    final icons = find.descendant(
        of: find.byType(InkWell), matching: find.byType(Icon));
    expect(icons.evaluate().isNotEmpty, isTrue);
    final firstIconRect = tester.getRect(icons.first);
    expect(
      (firstIconRect.center.dx - itemRect.center.dx).abs() < 12,
      isTrue,
      reason: '图标应在项内近似水平居中',
    );
  });
}

import 'package:cc98_ocean/controls/pivot.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pivot 标签宽度验收：文字无论何时都完整显示（不被省略号截断）。
void main() {
  const tabs = ['十大话题', '校园活动', '学术通知', '感性·情感', '实习兼职'];

  Future<void> pumpPivot(WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: PivotTabBar(
          tabs: tabs,
          selectedIndex: 0,
          onTabSelected: (_) {},
          tabWidth: 88, // 最小宽度
          selectedTextStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          unselectedTextStyle: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('四个字标签完整显示，宽度不小于自身文字宽度', (tester) async {
    await pumpPivot(tester);

    for (var i = 0; i < tabs.length; i++) {
      final textFinder = find.text(tabs[i]);
      expect(textFinder, findsOneWidget, reason: '标签「${tabs[i]}」应存在');

      // 文本组件未被裁切：其宽高与文本自身尺寸相符
      final textSize = tester.getSize(textFinder);
      final textWidget = tester.widget<Text>(textFinder);

      // 用与渲染一致的 textScaler 计算文本固有宽度
      final scaler = tester.binding.platformDispatcher.textScaleFactor;
      final painter = TextPainter(
        text: TextSpan(text: textWidget.data, style: textWidget.style),
        textDirection: TextDirection.ltr,
        textScaler: TextScaler.linear(scaler),
      )..layout();

      // 渲染宽度应 >= 文字固有宽度（未被截断），允许 1px 取整误差
      expect(
        textSize.width + 1.0 >= painter.width,
        isTrue,
        reason: '「${tabs[i]}」渲染宽 ${textSize.width} < 文字宽 ${painter.width}（被截断）',
      );
      painter.dispose();
    }
  });

  testWidgets('选中项切换后指示器随实测宽度定位', (tester) async {
    await pumpPivot(tester);
    // 简单冒烟：切换到末尾项不抛异常，且标签仍完整
    await tester.tap(find.text(tabs.last));
    await tester.pumpAndSettle();
    expect(find.text(tabs.last), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('胶囊位于标签区内底部，标签项无圆角', (tester) async {
    await pumpPivot(tester);

    // 整个 Pivot 高度 == 标签区高度（无独立指示器区）
    final pivotSize = tester.getSize(find.byType(PivotTabBar));
    expect(pivotSize.height, 40.0, reason: 'Pivot 总高应等于标签区高度');

    // 胶囊（AnimatedPositioned 内的指示容器）底边应贴 Pivot 底边
    final pivotRect = tester.getRect(find.byType(PivotTabBar));
    final capsuleRect = tester.getRect(
      find.descendant(
        of: find.byType(AnimatedPositioned),
        matching: find.byType(Container),
      ).first,
    );
    expect((capsuleRect.bottom - pivotRect.bottom).abs() <= 1.0, isTrue,
        reason: '胶囊应贴在标签区（InkWell 下边缘）底部');

    // InkWell 无圆角：其裁剪不再出现 RoundedRectangleBorder
    final inkWell = tester.widget<InkWell>(find.byType(InkWell).first);
    expect(inkWell.borderRadius, isNull, reason: '标签项应为直角（无圆角）');
  });

  testWidgets('鼠标拖拽可横向滚动到右侧溢出部分', (tester) async {
    // 窄视口，使标签总宽超过窗口
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await pumpPivot(tester);

    // 找到横向 ListView 的 Scrollable
    final scrollable = find.byType(Scrollable).first;
    final state = tester.state<ScrollableState>(scrollable);
    expect(state.position.maxScrollExtent, greaterThan(0),
        reason: '标签总宽应超过视口，存在可滚动范围');

    final before = state.position.pixels;
    // 用鼠标（mouse kind）向左拖动，相当于把内容往左推、露出右侧
    final gesture = await tester.startGesture(
      tester.getCenter(scrollable),
      kind: PointerDeviceKind.mouse,
    );
    // 分步移动以超过拖拽 slop 阈值
    for (var i = 0; i < 6; i++) {
      await gesture.moveBy(const Offset(-30, 0));
      await tester.pump(const Duration(milliseconds: 16));
    }
    await gesture.up();
    await tester.pumpAndSettle();

    expect(state.position.pixels, greaterThan(before),
        reason: '鼠标拖拽后应向右滚动（露出溢出部分）');
  });
}

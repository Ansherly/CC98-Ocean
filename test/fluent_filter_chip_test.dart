import 'package:cc98_ocean/controls/fluent_filter_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// FluentFilterChip 视觉规格验收（对齐 WinUI ToggleButton）。
void main() {
  final accent = Colors.deepPurple;

  Future<void> pump(WidgetTester tester,
      {required bool selected, VoidCallback? onTap}) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(
          child: FluentFilterChip(
            label: '默认分组',
            selected: selected,
            accentColor: accent,
            onTap: onTap,
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();
  }

  BoxDecoration decorationOf(WidgetTester tester) =>
      tester.widget<AnimatedContainer>(find.byType(AnimatedContainer)).decoration!
          as BoxDecoration;

  testWidgets('选中态：强调色 10% 浅底 + 强调色文字，无对勾图标', (tester) async {
    await pump(tester, selected: true);

    final deco = decorationOf(tester);
    expect(deco.color, accent.withOpacity(0.10), reason: '选中底应为强调色 10%');
    expect(deco.borderRadius, BorderRadius.circular(4), reason: '圆角应为 4px');

    final text = tester.widget<Text>(find.text('默认分组'));
    expect(text.style?.color, accent, reason: '选中文字应为强调色');
    expect(text.style?.fontWeight, FontWeight.w600);

    // 无对勾图标（与 Material ChoiceChip 的关键区别）
    expect(find.byIcon(Icons.check), findsNothing);
  });

  testWidgets('未选中态：非强调色文字', (tester) async {
    await pump(tester, selected: false);
    final text = tester.widget<Text>(find.text('默认分组'));
    expect(text.style?.color, isNot(accent));
    expect(text.style?.fontWeight, isNot(FontWeight.w600));
  });

  testWidgets('文字竖直居中（行高归一）', (tester) async {
    await pump(tester, selected: false);
    final text = tester.widget<Text>(find.text('默认分组'));
    expect(text.style?.height, 1.0, reason: '行高应归一，避免中文字形被压低');
    expect(text.textHeightBehavior?.leadingDistribution,
        TextLeadingDistribution.even);
  });

  testWidgets('chip 宽度贴合内容，不撑满整行', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: FluentFilterChipGroup<String>(
          items: const ['默认分组', '资源'],
          labelOf: (s) => s,
          isSelected: (s) => false,
          onSelected: (_) {},
        ),
      ),
    ));
    await tester.pumpAndSettle();

    // 窄标签「资源」的容器宽度应远小于屏宽（贴合内容，而非撑满整行）
    final screenWidth = tester.getSize(find.byType(Scaffold)).width;
    final chipWidth = tester.getSize(find.ancestor(
      of: find.text('资源'),
      matching: find.byType(AnimatedContainer),
    )).width;
    expect(chipWidth, lessThan(screenWidth / 2),
        reason: 'chip 宽度应贴合内容，不应撑满整行');
  });

  testWidgets('ChipGroup 自动换行（窄视口下多行）', (tester) async {
    tester.view.physicalSize = const Size(260, 600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: FluentFilterChipGroup<String>(
          items: const ['默认分组', '资源', '一路楼', '能源资源', 'CS资源', '故事'],
          labelOf: (s) => s,
          isSelected: (s) => s == '资源',
          onSelected: (_) {},
        ),
      ),
    ));
    await tester.pumpAndSettle();

    // 窄视口下应折行：各 chip 的 top 不止一个取值
    final tops = <double>{};
    for (final label in ['默认分组', '资源', '一路楼', '能源资源', 'CS资源', '故事']) {
      tops.add(tester.getTopLeft(find.text(label)).dy);
    }
    expect(tops.length, greaterThan(1), reason: '宽度不足时应折到下一行');
  });

  testWidgets('点击回调触发', (tester) async {
    var tapped = false;
    await pump(tester, selected: false, onTap: () => tapped = true);
    await tester.tap(find.text('默认分组'));
    expect(tapped, isTrue);
  });

  testWidgets('高度为 32px（WinUI 控件标准）', (tester) async {
    await pump(tester, selected: false);
    expect(tester.getSize(find.byType(AnimatedContainer)).height, 32.0);
  });
}

import 'package:cc98_ocean/ubb_text_block/render_context.dart';
import 'package:cc98_ocean/ubb_text_block/ubb_text.dart';
import 'package:cc98_ocean/ubb_text_block/ubb_text_style.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: ThemeData(fontFamily: 'Hm Sans'),
      home: Scaffold(body: child),
    );

/// 递归收集 RichText 中的所有叶子 TextSpan。
List<TextSpan> _leafSpans(InlineSpan span) {
  final result = <TextSpan>[];
  void walk(InlineSpan s) {
    if (s is TextSpan) {
      if (s.text != null && s.text!.isNotEmpty) result.add(s);
      for (final child in s.children ?? const <InlineSpan>[]) {
        walk(child);
      }
    }
  }

  walk(span);
  return result;
}

List<TextSpan> _leafSpansOfWidget(WidgetTester tester) {
  final rich = tester.widget<RichText>(find.byType(RichText).first);
  return _leafSpans(rich.text);
}

void main() {
  testWidgets('renders plain and bold text inline', (tester) async {
    await tester.pumpWidget(_wrap(const UbbText(data: 'hello [b]world[/b]')));

    final leaves = _leafSpansOfWidget(tester);
    expect(leaves.map((s) => s.text), ['hello ', 'world']);

    final boldSpan = leaves.firstWhere((s) => s.text == 'world');
    // 样式作用在容器 TextSpan 上，由叶子继承
    final boldContainer = ((tester
                .widget<RichText>(find.byType(RichText).first)
                .text as TextSpan)
            .children!)
        .whereType<TextSpan>()
        .firstWhere((s) => s.style?.fontWeight == FontWeight.bold);
    expect(boldContainer.children!.length, 1);
    expect(boldSpan.text, 'world');
  });

  testWidgets('block element flushes inline content into separate widgets',
      (tester) async {
    await tester.pumpWidget(_wrap(const UbbText(data: 'before [hr] after')));
    // 'before' 与 'after' 应各自成为独立的 RichText
    final texts = tester
        .widgetList<RichText>(find.byType(RichText))
        .map((r) => _leafSpans(r.text).map((s) => s.text).join())
        .toList();
    expect(texts, ['before ', ' after']); // 与 C# 一致：只裁剪换行，保留空格
  });

  testWidgets('url renders clickable link with recognizer', (tester) async {
    String? tapped;
    await tester.pumpWidget(_wrap(UbbText(
      data: '[url=https://www.cc98.org]CC98[/url]',
      onLinkTap: (url) => tapped = url,
    )));

    final leaves = _leafSpansOfWidget(tester);
    expect(leaves.map((s) => s.text), ['CC98']);
    // 链接样式作用于容器 TextSpan，识别器附加在叶子 span 上
    final root = tester.widget<RichText>(find.byType(RichText)).text as TextSpan;
    final linkContainer = root.children!.whereType<TextSpan>().first;
    // 链接不再显示下划线，仅靠强调色区分
    expect(linkContainer.style?.decoration ?? TextDecoration.none,
        isNot(TextDecoration.underline));
    expect(leaves.first.recognizer, isA<TapGestureRecognizer>());

    // 点击文本字形所在的位置（RichText 中心可能不在短文本上）
    final box =
        tester.renderObject<RenderBox>(find.byType(RichText).first);
    await tester.tapAt(box.localToGlobal(Offset(5, box.size.height / 2)));
    expect(tapped, 'https://www.cc98.org');
  });

  testWidgets('bare url auto-links by default', (tester) async {
    await tester.pumpWidget(
        _wrap(const UbbText(data: 'see https://www.cc98.org/topic/1 ok')));

    final leaves = _leafSpansOfWidget(tester);
    expect(leaves, hasLength(3)); // 前后文本 + 中间链接
    expect(leaves[1].text, 'https://www.cc98.org/topic/1');
    expect(leaves[1].recognizer, isA<TapGestureRecognizer>());
  });

  testWidgets('quote renders with collapse button beyond two levels',
      (tester) async {
    await tester.pumpWidget(_wrap(const UbbText(
      data: '[quote]q1[quote]q2[quote]q3[/quote][/quote][/quote]',
    )));

    expect(find.text('展开1条引用'), findsOneWidget);

    await tester.tap(find.text('展开1条引用'));
    await tester.pumpAndSettle();
    expect(find.text('收起引用'), findsOneWidget);

    // q3 位于折叠区，展开后应出现（q1/q2 为可见的两层）
    final allTexts = tester
        .widgetList<RichText>(find.byType(RichText))
        .expand((r) => _leafSpans(r.text).map((s) => s.text))
        .toList();
    expect(allTexts, containsAll(['q1', 'q2', 'q3']));
  });

  testWidgets('code block renders verbatim content', (tester) async {
    await tester.pumpWidget(
        _wrap(const UbbText(data: '[code]if (a [b]) {}[/code]')));

    expect(find.text('if (a [b]) {}'), findsOneWidget);
  });

  testWidgets('reply view placeholder renders', (tester) async {
    await tester.pumpWidget(
        _wrap(const UbbText(data: '[replyview]hidden[/replyview]')));
    final leaves = _leafSpansOfWidget(tester);
    expect(leaves.map((s) => s.text), contains('此消息回复可见'));
  });

  testWidgets('empty and malformed input do not crash', (tester) async {
    await tester.pumpWidget(_wrap(const UbbText(data: '')));
    expect(find.byType(UbbText), findsOneWidget);

    await tester.pumpWidget(_wrap(const UbbText(data: '[size=[b]x[/size]')));
    expect(tester.takeException(), isNull);
  });

  testWidgets('content inherits theme font and uses unified body size',
      (tester) async {
    await tester.pumpWidget(_wrap(const UbbText(data: '正文')));

    final root =
        tester.widget<RichText>(find.byType(RichText).first).text as TextSpan;
    // 继承主题的 Hm Sans，字号统一为帖子正文基准
    expect(root.style?.fontFamily, 'Hm Sans');
    expect(root.style?.fontSize, kPostContentFontSize);
  });

  testWidgets('ubb url with relative href passes href to router', (tester) async {
    String? captured;
    UbbMediaType? capturedType;
    await tester.pumpWidget(_wrap(UbbText(
      data: '[url=/topic/6641917#5]>>查看原帖<<[/url]',
      onMediaTap: (src, type) {
        captured = src;
        capturedType = type;
      },
    )));

    // 点击文本字形所在的位置
    final box =
        tester.renderObject<RenderBox>(find.byType(RichText).first);
    await tester.tapAt(box.localToGlobal(Offset(5, box.size.height / 2)));

    // 必须传 href 本身，而不是链接文本"查看原帖"
    expect(captured, '/topic/6641917#5');
    expect(capturedType, UbbMediaType.link);
  });
}

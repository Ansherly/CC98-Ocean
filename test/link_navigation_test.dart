import 'package:cc98_ocean/core/link_definition.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LinkNavigator.analyze', () {
    test('topic link without target', () {
      final t = LinkNavigator.analyze('https://www.cc98.org/topic/5700000');
      expect(t.type, LinkTargetType.topic);
      expect(t.topicId, 5700000);
      expect(t.globalFloor, isNull);
    });

    test('topic link with page and anchor', () {
      final t =
          LinkNavigator.analyze('https://www.cc98.org/topic/5700000/2#3');
      expect(t.type, LinkTargetType.topic);
      expect(t.topicId, 5700000);
      expect(t.page, 2);
      expect(t.anchor, 3);
      // 全局楼层（1-based）= (2-1)*10 + 3 = 13 → 0-based 索引 12
      expect(t.globalFloor, 12);
    });

    test('page without anchor defaults to first floor of that page', () {
      final t = LinkNavigator.analyze('/topic/5700000/2');
      expect(t.globalFloor, 10); // 第二页第一条 = 11 楼 → 索引 10
    });

    test('floor anchor without page (引用块 >>查看原帖<< 格式)', () {
      // [url=/topic/6641917#5]>>查看原帖<<[/url] —— #5 是 1-based 楼层号
      final t = LinkNavigator.analyze('/topic/6641917#5');
      expect(t.type, LinkTargetType.topic);
      expect(t.topicId, 6641917);
      expect(t.page, isNull);
      expect(t.anchor, 5);
      expect(t.globalFloor, 4); // 0-based 回复索引
    });

    test('relative topic path also matches', () {
      final t = LinkNavigator.analyze('/topic/123');
      expect(t.type, LinkTargetType.topic);
      expect(t.topicId, 123);
    });

    test('board link', () {
      final t = LinkNavigator.analyze('https://www.cc98.org/board/462');
      expect(t.type, LinkTargetType.board);
      expect(t.boardId, 462);
    });

    test('user by id (both /user/id/N and /user/N)', () {
      for (final url in [
        'https://www.cc98.org/user/id/482942',
        'https://www.cc98.org/user/482942',
      ]) {
        final t = LinkNavigator.analyze(url);
        expect(t.type, LinkTargetType.userId, reason: url);
        expect(t.userId, 482942);
      }
    });

    test('user by name with URL encoding', () {
      final t = LinkNavigator.analyze(
          'https://www.cc98.org/user/name/%E5%BF%83%E4%B8%8A%E4%BA%BA');
      expect(t.type, LinkTargetType.userName);
      expect(t.userName, '心上人');
    });

    test('cc98 file image', () {
      final t = LinkNavigator.analyze(
          'https://file.cc98.org/upload/2025/xx/abc.webp');
      expect(t.type, LinkTargetType.image);
    });

    test('external link is unknown → copy', () {
      final t = LinkNavigator.analyze('https://github.com/example/repo');
      expect(t.type, LinkTargetType.unknown);
    });

    test('other cc98 paths fall back to copy', () {
      final t = LinkNavigator.analyze('https://www.cc98.org/home');
      expect(t.type, LinkTargetType.unknown);
    });
  });

  group('LinkNavigator.handle', () {
    testWidgets('external link copies with toast, no navigation',
        (tester) async {
      // mock 剪贴板平台通道，否则 setData 的 await 在测试中不会完成
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async => null,
      );
      int pushCount = 0;
      await tester.pumpWidget(MaterialApp(
        navigatorObservers: [
          _CountingObserver(() => pushCount++),
        ],
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => LinkNavigator.handle(context, 'https://example.com/page'),
            child: const Text('go'),
          ),
        ),
      ));

      await tester.pump();
      pushCount = 0; // 初始路由挂载也会触发 didPush，归零后再点击

      await tester.tap(find.text('go'));
      await tester.pump();

      expect(pushCount, 0); // 外链不导航
      expect(find.text('链接已复制到剪贴板'), findsOneWidget); // 弹出提示

      // 冲刷 InfoFlower 的自动消失定时器与退场动画，避免测试结束时挂起
      await tester.pump(const Duration(seconds: 3));
      await tester.pump(const Duration(milliseconds: 800));
    });
  });
}

class _CountingObserver extends NavigatorObserver {
  final VoidCallback onPush;
  _CountingObserver(this.onPush);

  @override
  void didPush(Route route, Route? previousRoute) => onPush();
}

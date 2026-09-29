import 'package:cc98_ocean/controls/clickarea.dart';
import 'package:cc98_ocean/controls/fluent_iconbutton.dart';
import 'package:cc98_ocean/controls/info_flower.dart';
import 'package:cc98_ocean/controls/info_indicator.dart';
import 'package:cc98_ocean/controls/status_title.dart';
import 'package:cc98_ocean/core/constants/color_tokens.dart';
import 'package:cc98_ocean/core/models/extras.dart';
import 'package:cc98_ocean/core/network/api_client.dart';
import 'package:cc98_ocean/core/network/api_endpoints.dart';
import 'package:cc98_ocean/core/services/user_service.dart';
import 'package:cc98_ocean/pages/topic.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

/// 浏览历史页（对应 C# HistoryPage）。
class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final _userService = UserService();
  final ScrollController _controller = ScrollController();

  final List<SimpleTopicInfo> topics = [];
  bool isLoading = true;
  bool hasError = false;
  bool hasMore = false;
  String errorMessage = '';
  int currentPage = 0;

  /// 浏览记录开关（来自 /me 的 browsingHistoryEnabled）。
  bool? _historyEnabled;

  static const int pageSize = 10;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
    _loadEnabled();
    _load();
  }

  Future<void> _loadEnabled() async {
    final result = await ApiClient.instance.getTyped<Map<String, dynamic>>(
      ApiEndpoints.userProfile(isMe: true),
      fromJson: (json) => json as Map<String, dynamic>,
    );
    if (!result.isError) {
      setState(() {
        _historyEnabled = result.data!['browsingHistoryEnabled'] == true;
      });
    }
  }

  Future<void> _load({bool reset = true}) async {
    if (reset) {
      setState(() {
        topics.clear();
        currentPage = 0;
        isLoading = true;
        hasError = false;
      });
    }
    final result =
        await _userService.getBrowseHistory(currentPage * pageSize);
    if (result.isError) {
      setState(() {
        // 接口限速时返回 403，与 C# 行为一致
        errorMessage = result.error?.statusCode == 403
            ? '请求频率过快，请稍后再试'
            : (result.error?.message ?? '获取历史记录失败');
        hasError = true;
        isLoading = false;
      });
      return;
    }
    final parsed = result.data!;
    setState(() {
      hasMore = parsed.length > pageSize;
      topics.addAll(hasMore ? parsed.sublist(0, pageSize) : parsed);
      isLoading = false;
    });
  }

  Future<void> _toggleEnabled() async {
    final target = !(_historyEnabled ?? false);
    final result = await _userService.enableBrowseHistory(target);
    if (!mounted) return;
    if (result.success) {
      setState(() => _historyEnabled = target);
      InfoFlower.show(context,
          icon: FluentIcons.checkmark_circle_16_regular,
          text: target ? '已开启浏览记录' : '已关闭浏览记录');
    } else {
      InfoFlower.show(context,
          icon: FluentIcons.error_circle_16_regular, text: '操作失败');
    }
  }

  void _onScroll() {
    if (_controller.position.pixels >=
            _controller.position.maxScrollExtent - 200 &&
        !isLoading &&
        hasMore) {
      currentPage++;
      _load(reset: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 48,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        actionsPadding: const EdgeInsets.only(right: 13),
        leading: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: FluentIconbutton(
            icon: FluentIcons.chevron_left_16_regular,
            onPressed: () => Navigator.maybePop(context),
          ),
        ),
        actions: [
          Tooltip(
            message: _historyEnabled == true ? '关闭浏览记录' : '开启浏览记录',
            child: FluentIconbutton(
              icon: _historyEnabled == true
                  ? FluentIcons.eye_16_regular
                  : FluentIcons.eye_off_16_regular,
              iconColor: ColorTokens.softPurple,
              onPressed: _toggleEnabled,
            ),
          ),
          const SizedBox(width: 6),
          FluentIconbutton(
            icon: FluentIcons.arrow_sync_16_regular,
            iconColor: ColorTokens.softPurple,
            onPressed: () => _load(),
          ),
        ],
        title: StatusTitle(title: '浏览历史', isLoading: isLoading, onTap: () => _load()),
      ),
      body: buildLayout(),
    );
  }

  Widget buildLayout() {
    if (hasError && topics.isEmpty) {
      return ErrorIndicator(
          icon: FluentIcons.music_note_2_16_regular,
          info: errorMessage,
          onTapped: () => _load());
    }
    if (!isLoading && topics.isEmpty) {
      return const ErrorIndicator(
          icon: FluentIcons.history_16_regular, info: '暂无浏览记录');
    }
    return ListView.separated(
      controller: _controller,
      itemCount: topics.length + (hasMore || isLoading ? 1 : 0),
      separatorBuilder: (_, __) => Divider(
          height: 6, thickness: 1, color: Theme.of(context).dividerColor),
      itemBuilder: (_, i) {
        if (i == topics.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return buildHistoryRow(topics[i]);
      },
    );
  }

  Widget buildHistoryRow(SimpleTopicInfo topic) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      child: ClickArea(
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => Topic(topicId: topic.id))),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              const Icon(FluentIcons.history_16_regular,
                  size: 16, color: ColorTokens.softPurple),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    Text(topic.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14)),
                    Text(
                        '${topic.isAnonymous ? "匿名" : topic.userName}'
                        '${topic.boardName.isEmpty ? "" : " · ${topic.boardName}"}'
                        '${topic.lastBrowsingTime.isEmpty ? "" : " · ${topic.lastBrowsingTime}"}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

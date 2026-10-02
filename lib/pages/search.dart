import 'package:cc98_ocean/controls/clickarea.dart';
import 'package:cc98_ocean/controls/portrait_oval.dart';
import 'package:cc98_ocean/controls/search_bar.dart';
import 'package:cc98_ocean/controls/segmented.dart';
import 'package:cc98_ocean/controls/status_title.dart';
import 'package:cc98_ocean/core/constants/color_tokens.dart';
import 'package:cc98_ocean/core/models/extras.dart';
import 'package:cc98_ocean/core/models/user.dart';
import 'package:cc98_ocean/core/services/post_service.dart';
import 'package:cc98_ocean/core/services/user_service.dart';
import 'package:cc98_ocean/pages/profile.dart';
import 'package:cc98_ocean/pages/user_space.dart';
import 'package:cc98_ocean/pages/topic.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

/// 搜索页（对应 C# SearchPage）。
///
/// [keyword] 传入时自动执行搜索；[boardId] 传入时限定版面内搜索。
class SearchPage extends StatefulWidget {
  final String? keyword;
  final int? boardId;

  const SearchPage({super.key, this.keyword, this.boardId});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _postService = PostService();
  final _userService = UserService();
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  int _tab = 0; // 0=主题 1=用户
  final List<SimpleTopicInfo> topics = [];
  SimpleUserInfo? _userResult;
  bool isLoading = false;
  bool hasError = false;
  bool hasMore = false;
  String errorMessage = '';
  int currentPage = 0;
  static const int pageSize = 20;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    if (widget.keyword != null && widget.keyword!.isNotEmpty) {
      _controller.text = widget.keyword!;
      _search(widget.keyword!);
    }
  }

  Future<void> _search(String keyword, {bool reset = true}) async {
    if (keyword.trim().isEmpty) return;
    if (reset) {
      setState(() {
        topics.clear();
        _userResult = null;
        currentPage = 0;
        hasMore = false;
        isLoading = true;
        hasError = false;
      });
    }

    if (_tab == 0) {
      final result = widget.boardId != null
          ? await _postService
              .searchTopicsInBoard(widget.boardId!, keyword, currentPage * pageSize)
          : await _postService.searchTopics(keyword, currentPage * pageSize);
      if (result.isError) {
        setState(() {
          hasError = true;
          errorMessage = result.error!.message;
          isLoading = false;
        });
        return;
      }
      final parsed = result.data!
          .map((e) => SimpleTopicInfo.fromJson(e))
          .toList();
      setState(() {
        topics.addAll(parsed);
        hasMore = parsed.length == pageSize;
        isLoading = false;
      });
    } else {
      final result = await _userService.searchUserByName(keyword);
      setState(() {
        _userResult = result.data;
        isLoading = false;
        hasMore = false;
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !isLoading &&
        !hasError &&
        hasMore) {
      currentPage++;
      _search(_controller.text, reset: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 56,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        actionsPadding: const EdgeInsets.only(right: 13),
        titleSpacing: 8,
        leading: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: IconButton(
            icon: const Icon(FluentIcons.chevron_left_16_regular),
            onPressed: () => Navigator.maybePop(context),
          ),
        ),
        title: SimpleCapsuleSearchBar(
          hintText: '搜索主题 / 用户',
          controller: _controller,
          onSubmitted: (k) => _search(k),
        ),
      ),
      body: buildLayout(),
    );
  }

  Widget buildLayout() {
    final keyword = _controller.text.trim();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: SegmentedControl(
            items: const ['主题', '用户'],
            initialIndex: _tab,
            onSelected: (i) {
              setState(() => _tab = i);
              if (keyword.isNotEmpty) _search(keyword);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Text(
                isLoading
                    ? '正在搜索…'
                    : _tab == 0
                        ? (topics.isEmpty
                            ? ''
                            : '找到 ${topics.length}${hasMore ? '+' : ''} 个结果')
                        : '',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
        Expanded(child: buildResults(keyword)),
      ],
    );
  }

  Widget buildResults(String keyword) {
    if (keyword.isEmpty) {
      return const Center(
          child: Text('输入关键词开始搜索',
              style: TextStyle(color: Colors.grey)));
    }
    if (hasError) {
      return Center(
          child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(errorMessage, style: const TextStyle(color: Colors.grey)),
          TextButton(onPressed: () => _search(keyword), child: const Text('重试')),
        ],
      ));
    }
    if (_tab == 0) {
      if (!isLoading && topics.isEmpty) {
        return const Center(
            child: Text('没有找到相关主题', style: TextStyle(color: Colors.grey)));
      }
      return ListView.separated(
        controller: _scrollController,
        itemCount: topics.length + (hasMore ? 1 : 0),
        separatorBuilder: (_, __) => Divider(
            height: 6, thickness: 1, color: Theme.of(context).dividerColor),
        itemBuilder: (_, i) {
          if (i == topics.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return buildTopicCard(topics[i]);
        },
      );
    }
    return buildUserResult();
  }

  Widget buildTopicCard(SimpleTopicInfo topic) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      child: ClickArea(
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => Topic(topicId: topic.id))),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 6,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(topic.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                  ),
                  if (topic.boardName.isNotEmpty)
                    Text(topic.boardName,
                        style: const TextStyle(
                            color: ColorTokens.softPurple, fontSize: 12)),
                ],
              ),
              Row(
                spacing: 6,
                children: [
                  Text(
                      topic.isAnonymous ? '匿名' : topic.userName,
                      style: const TextStyle(
                          color: Colors.grey, fontSize: 12)),
                  Text('${topic.replyCount}回复·${topic.hitCount}浏览',
                      style:
                          const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildUserResult() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    final user = _userResult;
    if (user == null || user.userId == 0) {
      return const Center(
          child: Text('未找到该用户', style: TextStyle(color: Colors.grey)));
    }
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Card(
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: ClickArea(
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        UserSpacePage(userId: user.userId))),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  PortraitOval(url: user.portraitUrl, size: 44),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.userName,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        const Text('查看空间',
                            style: TextStyle(
                                color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                  const Icon(FluentIcons.chevron_right_16_regular,
                      size: 14, color: Colors.grey),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

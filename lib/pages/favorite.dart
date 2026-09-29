import 'package:cc98_ocean/controls/clickarea.dart';
import 'package:cc98_ocean/controls/fluent_dialog.dart';
import 'package:cc98_ocean/controls/fluent_iconbutton.dart';
import 'package:cc98_ocean/controls/info_flower.dart';
import 'package:cc98_ocean/controls/info_indicator.dart';
import 'package:cc98_ocean/controls/status_title.dart';
import 'package:cc98_ocean/core/constants/color_tokens.dart';
import 'package:cc98_ocean/core/models/extras.dart';
import 'package:cc98_ocean/core/services/post_service.dart';
import 'package:cc98_ocean/core/services/user_service.dart';
import 'package:cc98_ocean/pages/topic.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

/// 收藏夹页（对应 C# FavoritePage）。
class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final _postService = PostService();
  final _userService = UserService();
  final ScrollController _controller = ScrollController();

  List<FavoriteGroup> groups = [];
  int selectedGroupId = 0;
  // 与 C# PostOrder 一致：0=按发布时间 1=按最后回复
  int order = 1;

  final List<SimpleTopicInfo> topics = [];
  bool isLoading = true;
  bool hasError = false;
  bool hasMore = false;
  String errorMessage = '';
  int currentPage = 0;
  static const int pageSize = 10;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    final result = await _userService.getFavoriteGroups();
    if (result.isError) {
      setState(() {
        hasError = true;
        errorMessage = result.error!.message;
        isLoading = false;
      });
      return;
    }
    setState(() {
      groups = result.data!;
      hasError = false;
    });
    if (groups.isEmpty) {
      setState(() => isLoading = false);
      return;
    }
    selectedGroupId = groups.first.id;
    _loadTopics();
  }

  Future<void> _loadTopics({bool reset = true}) async {
    if (reset) {
      setState(() {
        topics.clear();
        currentPage = 0;
        isLoading = true;
        hasError = false;
      });
    }
    final result = await _userService
        .getFavoriteTopics(currentPage * pageSize, order, selectedGroupId);
    if (result.isError) {
      setState(() {
        hasError = true;
        errorMessage = result.error!.message;
        isLoading = false;
      });
      return;
    }
    final parsed = result.data!;
    setState(() {
      // 约定：返回 pageSize+1 条表示还有更多，截掉末条
      hasMore = parsed.length > pageSize;
      topics.addAll(hasMore ? parsed.sublist(0, pageSize) : parsed);
      isLoading = false;
    });
  }

  void _onScroll() {
    if (_controller.position.pixels >=
            _controller.position.maxScrollExtent - 200 &&
        !isLoading &&
        hasMore) {
      currentPage++;
      _loadTopics(reset: false);
    }
  }

  Future<void> _removeFavorite(SimpleTopicInfo topic) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const FluentDialog(
        title: '取消收藏',
        content: Text('确定取消收藏该主题吗？'),
        confirmText: '确定',
      ),
    );
    if (confirmed != true) return;
    final result = await _postService.deleteFavorite(topic.id);
    if (!mounted) return;
    if (result.success) {
      InfoFlower.show(context, icon: FluentIcons.heart_16_regular, text: '已取消收藏');
      _loadTopics();
    } else {
      InfoFlower.show(context,
          icon: FluentIcons.error_circle_16_regular,
          text: result.message ?? '取消收藏失败');
    }
  }

  void _toggleOrder() {
    setState(() => order = order == 0 ? 1 : 0);
    _loadTopics();
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
            message: order == 0 ? '按发布时间排序' : '按最后回复排序',
            child: FluentIconbutton(
              icon: order == 0
                  ? FluentIcons.arrow_sort_16_regular
                  : FluentIcons.arrow_upload_16_regular,
              iconColor: ColorTokens.softPurple,
              onPressed: _toggleOrder,
            ),
          ),
          const SizedBox(width: 6),
          FluentIconbutton(
            icon: FluentIcons.arrow_sync_16_regular,
            iconColor: ColorTokens.softPurple,
            onPressed: () {
              _loadGroups();
            },
          ),
        ],
        title: StatusTitle(title: '收藏', isLoading: isLoading, onTap: _loadTopics),
      ),
      body: buildLayout(),
    );
  }

  Widget buildLayout() {
    if (hasError && groups.isEmpty) {
      return ErrorIndicator(
          icon: FluentIcons.music_note_2_16_regular,
          info: errorMessage,
          onTapped: _loadGroups);
    }
    if (!isLoading && groups.isEmpty) {
      return const ErrorIndicator(
          icon: FluentIcons.star_16_regular, info: '暂无收藏夹');
    }
    return Column(
      children: [
        if (groups.isNotEmpty) buildGroupChips(),
        Expanded(child: buildList()),
      ],
    );
  }

  Widget buildGroupChips() {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        children: [
          for (final g in groups)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(g.name),
                selected: g.id == selectedGroupId,
                selectedColor:
                    Theme.of(context).colorScheme.primaryContainer,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6)),
                onSelected: (_) {
                  setState(() => selectedGroupId = g.id);
                  _loadTopics();
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget buildList() {
    if (!isLoading && topics.isEmpty) {
      return const ErrorIndicator(
          icon: FluentIcons.star_16_regular, info: '该收藏夹暂无主题');
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
        return buildTopicRow(topics[i]);
      },
    );
  }

  Widget buildTopicRow(SimpleTopicInfo topic) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      child: ClickArea(
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => Topic(topicId: topic.id))),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              const Icon(FluentIcons.star_16_regular,
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
                        ' · ${topic.replyCount}回复',
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
              FluentIconbutton(
                icon: FluentIcons.heart_16_regular,
                iconColor: Colors.grey,
                tooltip: '取消收藏',
                onPressed: () => _removeFavorite(topic),
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

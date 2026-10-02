import 'dart:math';

import 'package:cc98_ocean/controls/clickarea.dart';
import 'package:cc98_ocean/controls/fluent_dialog.dart';
import 'package:cc98_ocean/controls/fluent_iconbutton.dart';
import 'package:cc98_ocean/controls/fluent_menu.dart';
import 'package:cc98_ocean/controls/info_flower.dart';
import 'package:cc98_ocean/controls/info_indicator.dart';
import 'package:cc98_ocean/controls/markdown_view.dart';
import 'package:cc98_ocean/controls/pager.dart';
import 'package:cc98_ocean/controls/portrait_oval.dart';
import 'package:cc98_ocean/controls/segmented.dart';
import 'package:cc98_ocean/controls/status_title.dart';
import 'package:cc98_ocean/controls/vote_panel.dart';
import 'package:share_plus/share_plus.dart';

import 'package:cc98_ocean/core/constants/color_tokens.dart';
import 'package:cc98_ocean/core/link_definition.dart';
import 'package:cc98_ocean/core/models/extras.dart';
import 'package:cc98_ocean/core/models/reply.dart';
import 'package:cc98_ocean/core/services/post_service.dart';
import 'package:cc98_ocean/core/services/user_service.dart';
import 'package:cc98_ocean/ubb_text_block/ubb_text.dart';
import 'package:cc98_ocean/core/themes/setting_controller.dart';
import 'package:cc98_ocean/core/helper.dart';
import 'package:cc98_ocean/pages/profile.dart';
import 'package:cc98_ocean/pages/user_space.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';


class Topic extends StatefulWidget {
  final int topicId;

  /// 初始定位的全局楼层索引（0-based，来自内链 /topic/{id}/{page}#{anchor}）。
  final int? initialFloor;

  const Topic({super.key, required this.topicId, this.initialFloor});

  @override
  State<Topic> createState() => _TopicState();
}

class _TopicState extends State<Topic> {
  bool useTail=true;
  Map<String, dynamic>? topicDetail;
  List<Reply> replies = [];
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';
  int currentPage = 0;
  int totalPages=1;
  final int pageSize = 10;
  bool hasMore = true;
  final ScrollController controller = ScrollController();
  final _postService = PostService();
  final _userService = UserService();
  bool isFavorite = false;

  // 楼层跳转：定位到当前页内的该条回复
  int? _jumpIndex;
  final GlobalKey _jumpKey = GlobalKey();

  /// 当前展示的主题 ID。就地跳转（不 push 新路由）时可变。
  late int _topicId = widget.topicId;

  @override
  void initState() {
    super.initState();
    // 注册就地跳转处理器：话题内点击主题链接时不再 push 新页面
    LinkNavigator.inPlaceTopicJump = _jumpToTopic;
    if (widget.initialFloor != null) {
      _jumpIndex = widget.initialFloor;
      currentPage = _jumpIndex! ~/ pageSize;
    }
    controller.addListener(onScroll);
    getTopicData();
  }

  /// 话题链接的就地跳转（对应 C# 同窗体导航语义）：
  /// - 跨话题：重置本页状态并重新加载，不 push 新路由；
  /// - 同话题：仅切换页码并滚动到锚点楼层。
  void _jumpToTopic(int topicId, int? floor) {
    if (!mounted) return;
    if (topicId == _topicId) {
      if (floor == null) return; // 当前主题的无锚点链接，无需动作
      setState(() {
        _jumpIndex = floor;
        currentPage = floor ~/ pageSize;
        replies.clear();
        isLoading = true;
      });
      getReply();
      return;
    }
    setState(() {
      _topicId = topicId;
      topicDetail = null;
      isFavorite = false;
      totalPages = 1;
      hasMore = true;
      hasError = false;
      errorMessage = '';
      replies.clear();
      _jumpIndex = floor;
      currentPage = floor != null ? floor! ~/ pageSize : 0;
      isLoading = true;
    });
    getTopicData();
  }

  Future<void> getTopicData() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    final topicResult = await _postService.getTopicInfo(_topicId);
    if (topicResult.isError) {
      setState(() {
        hasError = true;
        errorMessage = topicResult.error!.message;
        isLoading = false;
      });
    } else {
      final data = topicResult.data!;
      // 与 C# 一致：收藏状态与主题信息并行加载
      final favorite = _postService.isFavorite(_topicId);
      setState(() {
        topicDetail = data;
        totalPages = (data["replyCount"] as int? ?? 0) ~/ pageSize + 1;
      });
      isFavorite = await favorite;
      // 楼层锚点跳转时保持 initState 算出的起始页；普通打开则从第一页开始
      currentPage = _jumpIndex != null ? _jumpIndex! ~/ pageSize : 0;
      replies.clear();
      await getReply();
    }
  }

  Future<void> getReply() async {
    final result = await _postService.getReplyList(_topicId, currentPage * pageSize);
    if (result.isError) {
      setState(() {
        hasError = true;
        errorMessage = result.error!.message;
        isLoading = false;
      });
    } else {
      setState(() {
        replies.addAll(result.data!);
        hasMore = result.data!.length == pageSize;
        isLoading = false;
      });
      // 楼层锚点待定位：列表渲染完成后统一触发滚动。
      // 不能依赖目标楼层自身的构建回调——它可能超出 cacheExtent
      // 而根本没被 ListView 构建，那样回调永远不会触发。
      if (_jumpIndex != null) {
        WidgetsBinding.instance
            .addPostFrameCallback((_) => _scrollToJumpTarget());
      }
    }
  }

  Future<void> loadMore() async {
    if (!hasMore || isLoading) return;
    currentPage++;
    setState(() {
      isLoading = true;
    });
    await getReply();
  }

  @override
  Widget build(BuildContext context) {
    useTail = Provider.of<AppState>(context).useTail;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 48,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        actionsPadding: EdgeInsets.only(right: 8),
        titleSpacing: 8,
        leading: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: FluentIconbutton(
            icon: FluentIcons.chevron_left_16_regular,
            onPressed: () => {Navigator.maybePop(context)},
          ),
        ),
        actions: [
          FluentIconbutton(
            icon: FluentIcons.share_16_regular,
            iconColor: ColorTokens.softPurple,
            tooltip: '分享',
            onPressed: _shareToSystem,
          ),
          SizedBox(width: 6),
          FluentMenuButton(
            icon: FluentIcons.more_horizontal_16_regular,
            iconColor: ColorTokens.softPurple,
            tooltip: '更多操作',
            items: [
              FluentMenuItem(
                text: isFavorite ? '取消收藏' : '收藏主题',
                icon: isFavorite
                    ? FluentIcons.heart_16_regular
                    : FluentIcons.heart_16_regular,
                onTap: isFavorite ? _unfavoriteTopic : _favoriteTopic,
              ),
              if (topicDetail?['isVote'] == true)
                FluentMenuItem(
                  text: '参与投票',
                  icon: FluentIcons.poll_16_regular,
                  onTap: () => VotePanel.show(context, _topicId),
                ),
              FluentMenuItem(
                text: '复制链接',
                icon: FluentIcons.link_16_regular,
                onTap: _shareTopic,
              ),
              FluentMenuItem(
                text: '刷新',
                icon: FluentIcons.arrow_sync_16_regular,
                onTap: getTopicData,
              ),
            ],
          ),
        ],
        title: StatusTitle(
          title: "帖子详情",
          isLoading: isLoading,
          onTap: getTopicData,
        ),
      ),
      body: SafeArea(child: buildLayout()),
      floatingActionButton: FloatingActionButton(
        elevation: 3,
        mini: true,
        shape: const CircleBorder(),
        onPressed: () => _showReplyDialog(0, _topicId.toString()),
        child: const Icon(FluentIcons.add_12_regular),
      ),
      bottomNavigationBar: isLoading
          ? null
          : (totalPages < 4
              ? null
              : SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: PageBar(
                      currentPage: currentPage + 1,
                      totalPages: totalPages,
                      onJump: (p) {
                        setState(() {
                          currentPage = p - 1;
                          replies.clear();
                          getReply();
                        });
                      },
                    ),
                  ),
                )),
    );
  }

  Widget buildLayout() {
    if (hasError)
      return ErrorIndicator(
        icon: FluentIcons.music_note_2_16_regular,
        info: errorMessage,
        onTapped: getReply,
      );
    return Column(
      children: [
        buildTitleBanner(),
        const SizedBox(height: 8),
        buildReplyList(),
      ],
    );
  }

  Widget buildTitleBanner() {
    if (topicDetail == null) return Container();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            softWrap: true,
            topicDetail!['title'] ?? '无标题',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(FluentIcons.person_16_filled, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 6),
              Text(
                topicDetail!['userName'] ?? '匿名',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(width: 16),
              Icon(FluentIcons.history_16_regular, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 6),
              Text(
                DateFormat('yyyy-MM-dd HH:mm').format(
                  DateTime.parse(topicDetail!['time'] ?? DateTime.now().toString())
                      .add(const Duration(hours: 8)),
                ),
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildReplyList() {
    return Expanded(
      child: RefreshIndicator(
        onRefresh: getTopicData,
        child: ListView.separated(
          separatorBuilder: (_, __) => Divider(
              height: 1, thickness: 1, color: Theme.of(context).dividerColor),
          controller: controller,
          itemCount: totalPages > 3 ? replies.length : replies.length + 1,
          itemBuilder: (context, index) {
            if (index == replies.length && totalPages < 4) {
              return _buildLoadMoreIndicator();
            }
            return buildReplyItem(replies[index], index);
          },
        ),
      ),
    );
  }

  Widget buildReplyItem(Reply reply, int index) {
    final isJumpTarget = _jumpIndex != null &&
        index == _jumpIndex! - currentPage * pageSize;
    final item = Card(
      margin: EdgeInsets.all(0),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClickArea(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              UserSpacePage(userId: reply.userId))),
                  child: PortraitOval(url: reply.portraitUrl),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reply.userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: ColorTokens.softPink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        reply.time.toUtc8,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Text("${reply.floor}L",
                    style: TextStyle(fontSize: 14, color: ColorTokens.softPurple)),
              ],
            ),
            const SizedBox(height: 16),
            reply.contentType == 0
                ? UbbText(data: reply.content)
                : MarkdownView(MdConverter.convertHtml(reply.content).trim()),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _buildReactionChip(
                      icon: reply.likeState == 1
                          ? FluentIcons.thumb_like_16_filled
                          : FluentIcons.thumb_like_16_regular,
                      count: reply.likeCount,
                      onPressed: () => _handleLike(reply.id, true),
                    ),
                    const SizedBox(width: 6),
                    _buildReactionChip(
                      icon: reply.likeState == 2
                          ? FluentIcons.thumb_dislike_16_filled
                          : FluentIcons.thumb_dislike_16_regular,
                      count: reply.dislikeCount,
                      onPressed: () => _handleLike(reply.id, false),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () => _showReplyDialog(0, reply.userName),
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    padding: const EdgeInsets.all(6),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    minimumSize: const Size(0, 0),
                  ),
                  child: Icon(FluentIcons.comment_16_regular, size: 16),
                ),
                FluentMenuButton(
                  icon: FluentIcons.more_vertical_16_regular,
                  iconColor: Colors.grey,
                  items: [
                    FluentMenuItem(
                      text: '回复',
                      icon: FluentIcons.comment_16_regular,
                      onTap: () => _showReplyDialog(reply.id, reply.userName),
                    ),
                    FluentMenuItem(
                      text: '赠米',
                      icon: FluentIcons.food_cake_16_regular,
                      onTap: () => _showWealthTransferDialog(reply),
                    ),
                    FluentMenuItem(
                      text: '风评',
                      icon: FluentIcons.star_16_regular,
                      onTap: () => _showRatingDialog(reply),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );

    // 楼层跳转目标：包一层 KeyedSubtree 供滚动定位。
    // 滚动由 getReply 完成后统一触发，不挂条目自身回调。
    if (isJumpTarget) {
      return KeyedSubtree(key: _jumpKey, child: item);
    }
    return item;
  }

  /// 滚动定位到锚点楼层。
  ///
  /// 目标楼层可能尚未被 ListView 构建（超出 cacheExtent 时
  /// GlobalKey 的 currentContext 为 null，直接定位会静默失效），
  /// 因此分两阶段：先按页内比例粗滚把它拉进构建范围，再精确对齐到视口 10% 处。
  Future<void> _scrollToJumpTarget() async {
    final jump = _jumpIndex;
    if (jump == null || !controller.hasClients) return;
    final localIndex = jump - currentPage * pageSize;
    try {
      // 阶段 1：粗定位（仅当目标楼层还没被构建时需要）。
      // 用 jumpTo 瞬时完成，避免两段快速动画叠加造成剧烈晃动
      if (_jumpKey.currentContext == null) {
        final maxExtent = controller.position.maxScrollExtent;
        final total = replies.isNotEmpty ? replies.length : 1;
        final rough = (maxExtent * (localIndex / total))
            .clamp(0.0, maxExtent)
            .toDouble();
        controller.jumpTo(rough);
        // 等一帧，让新进入构建范围的楼层完成布局
        await WidgetsBinding.instance.endOfFrame;
      }
      // 阶段 2：目标楼层进入构建范围后精确对齐；粗滚后可能仍差一点，
      // 最多再等 5 帧，等不到就按比例再前进一截
      for (var attempt = 0; attempt < 5; attempt++) {
        final ctx = _jumpKey.currentContext;
        final renderObject = ctx?.findRenderObject();
        if (renderObject != null) {
          final viewport = RenderAbstractViewport.of(renderObject);
          final target = viewport.getOffsetToReveal(renderObject, 0.1).offset;
          await controller.animateTo(
            target.clamp(0.0, controller.position.maxScrollExtent).toDouble(),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOutCubic,
          );
          return;
        }
        await WidgetsBinding.instance.endOfFrame;
      }
    } finally {
      if (mounted) {
        setState(() => _jumpIndex = null);
      } else {
        _jumpIndex = null;
      }
    }
  }

  Widget _buildReactionChip({
    required IconData icon,
    required int count,
    required VoidCallback onPressed,
  }) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        padding: const EdgeInsets.all(6),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        minimumSize: const Size(0, 0),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Text(count.toString(),
              style: TextStyle(color: Colors.grey.shade800, fontSize: 12)),
        ],
      ),
    );
  }

  String get platform => switch (defaultTargetPlatform) {
        TargetPlatform.android => 'Android',
        TargetPlatform.iOS => 'IOS',
        TargetPlatform.windows => 'Windows',
        TargetPlatform.macOS => 'macOS',
        TargetPlatform.linux => 'Linux',
        TargetPlatform.fuchsia => 'Fuchsia',
      };

  void _handleLike(int replyId, bool mode) async {
    final result = await _postService.react(replyId, mode,
        bodyBuilder: (like) => like ? "1" : "2");
    if (result.isError) {
      InfoFlower.showContent(context,
          child: Text(mode ? "点赞失败" : "点踩失败"));
    } else {
      final data = result.data!;
      setState(() {
        final target = replies.firstWhere((e) => e.id == replyId);
        target.likeCount = data['likeCount'] as int;
        target.dislikeCount = data['dislikeCount'] as int;
        target.likeState = data['likeState'] as int;
      });
      InfoFlower.showContent(context,
          child: Text(mode ? "已点赞回复$replyId" : "已点踩回复$replyId"));
    }
  }

  void _showReplyDialog(int replyId, String receiverName) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => FluentDialog(
        title: '回复:$receiverName',
        content: TextField(
          controller: controller,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: '输入您的回复内容...',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {},
        ),
        cancelText: "取消",
        confirmText: "发送",
        onConfirm: () async {
          String originalContent = controller.text.trim();
          String content = useTail
              ? "$originalContent\n[align=right][size=3][color=gray]——来自「[b][color=purple]CC98 For $platform[/color][/b]」[/color][/size][/align]"
              : originalContent;
          if (originalContent.isEmpty) {
            InfoFlower.showContent(context,
                child: Text("回复内容不能为空",
                    style: TextStyle(color: ColorTokens.primaryLight)));
            return;
          } else {
            final reply = {
              "clientType": 1,
              "content": content,
              "contentType": 0,
              "isAnonymous": false,
              "notifyAllReplier": false,
              "title": "",
              if (replyId != 0) "parentId": replyId,
            };
            final sendResult = await _postService.sendReply(_topicId, reply);
            if (!context.mounted) return;
            InfoFlower.showContent(context,
                child: Text(
                    sendResult.isError ? "回复失败" : "回复已提交",
                    style: TextStyle(color: ColorTokens.primaryLight)));
            Navigator.pop(context);
            if (!sendResult.isError) {
              // 发送成功后刷新整个主题（从第一页）
              getTopicData();
            }
          }
        },
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Text(hasMore ? "下拉加载更多" : '没有更多回复了',
            style: TextStyle(color: Colors.grey)),
      ),
    );
  }

  void onScroll() async {
    if (controller.position.pixels >= controller.position.maxScrollExtent - 100 &&
        !isLoading &&
        !hasError &&
        totalPages < 4) {
      currentPage++;
      await loadMore();
    }
  }

  // ── 收藏 / 分享 ─────────────────────────────────────

  /// 构造分享文本：「来自CC98的分享：[{标题}]-{链接}」
  String _shareText() {
    final title = (topicDetail?['title'] as String?) ?? 'CC98 主题';
    return '来自CC98的分享：[$title]-https://www.cc98.org/topic/$_topicId';
  }

  /// 顶部分享按钮：移动端调起系统分享界面（QQ/微信等），
  /// 桌面端无系统分享面板，回落为复制到剪贴板。
  Future<void> _shareToSystem() async {
    final text = _shareText();
    final isMobile = !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS);
    if (isMobile) {
      await SharePlus.instance.share(
        ShareParams(text: text, subject: 'CC98 分享', title: 'CC98 分享'),
      );
      return;
    }
    _shareTopic();
  }

  void _shareTopic() {
    Clipboard.setData(ClipboardData(text: 'https://www.cc98.org/topic/${_topicId}'));
    InfoFlower.show(context,
        icon: FluentIcons.checkmark_circle_16_regular, text: '链接已复制到剪贴板');
  }

  // 收藏主题：弹出收藏夹选择对话框
  Future<void> _favoriteTopic() async {
    final groupsResult = await _userService.getFavoriteGroups();
    if (!mounted) return;
    if (groupsResult.isError || groupsResult.data!.isEmpty) {
      InfoFlower.show(context,
          icon: FluentIcons.error_circle_16_regular, text: '暂无收藏夹');
      return;
    }
    final groups = groupsResult.data!;
    final selected = await showDialog<int>(
      context: context,
      builder: (context) => FluentDialog(
        title: '收藏到...',
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final g in groups)
              ListTile(
                leading: const Icon(FluentIcons.folder_16_regular, size: 16),
                title: Text(g.name),
                onTap: () => Navigator.pop(context, g.id),
              ),
          ],
        ),
        confirmText: '取消',
        cancelText: null,
      ),
    );
    if (selected == null || !mounted) return;
    final result = await _postService.addIntoFavorites(_topicId, selected);
    if (!mounted) return;
    if (result.success) {
      setState(() => isFavorite = true);
      InfoFlower.show(context, icon: FluentIcons.heart_16_regular, text: '已收藏');
    } else {
      InfoFlower.show(context,
          icon: FluentIcons.error_circle_16_regular,
          text: result.message ?? '收藏失败');
    }
  }

  Future<void> _unfavoriteTopic() async {
    final result = await _postService.deleteFavorite(_topicId);
    if (!mounted) return;
    if (result.success) {
      setState(() => isFavorite = false);
      InfoFlower.show(context,
          icon: FluentIcons.heart_16_regular, text: '已取消收藏');
    } else {
      InfoFlower.show(context,
          icon: FluentIcons.error_circle_16_regular,
          text: result.message ?? '取消收藏失败');
    }
  }

  // ── 赠米（财富转账） ────────────────────────────────

  Future<void> _showWealthTransferDialog(Reply reply) async {
    if (reply.isMe) {
      InfoFlower.show(context,
          icon: FluentIcons.error_circle_16_regular, text: '不能给自己赠米');
      return;
    }
    final amountController = TextEditingController();
    final reasonController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final amount = int.tryParse(amountController.text) ?? 0;
          final fee = amount >= 10 ? max(10, amount * 0.1).round() : 0;
          return FluentDialog(
            title: '赠米给 ${reply.userName}',
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: '金额（≥10）',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => setDialogState(() {}),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: reasonController,
                  decoration: const InputDecoration(
                    hintText: '附言（可选）',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                if (amount >= 10)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '手续费 $fee 米，对方实际收到 ${amount - fee} 米',
                      style:
                          const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
              ],
            ),
            confirmText: '赠送',
            onConfirm: () async {
              if (amount < 10) {
                InfoFlower.show(context,
                    icon: FluentIcons.error_circle_16_regular,
                    text: '赠米金额不能低于 10');
                return;
              }
              final result = await _userService.transferWealth(
                wealth: amount,
                userNames: [reply.userName],
                reason: reasonController.text.trim(),
              );
              if (!context.mounted) return;
              Navigator.pop(context);
              if (result.success) {
                InfoFlower.show(context,
                    icon: FluentIcons.checkmark_circle_16_regular,
                    text: '赠米成功：${reply.userName}');
              } else {
                InfoFlower.show(context,
                    icon: FluentIcons.error_circle_16_regular,
                    text: '赠米失败');
              }
            },
          );
        },
      ),
    );
  }

  // ── 风评（评分） ─────────────────────────────────────

  Future<void> _showRatingDialog(Reply reply) async {
    int type = 1; // 1=加风评 2=扣风评
    List<RatingReason> reasons = [];
    RatingReason? selected;
    String error = '';

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          Future<void> loadReasons() async {
            final result = await _postService.getRatingReasons(type);
            if (!context.mounted) return;
            setDialogState(() {
              reasons = result.isError
                  ? []
                  : result.data!.where((r) => r.enabled).toList();
              selected = reasons.isNotEmpty ? reasons.first : null;
              if (reasons.isEmpty) error = '没有可用的风评理由';
            });
          }

          if (reasons.isEmpty && error.isEmpty) loadReasons();

          return FluentDialog(
            title: '风评：${reply.userName}',
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SegmentedControl(
                  items: const ['加风评', '扣风评'],
                  initialIndex: type - 1,
                  onSelected: (i) {
                    setDialogState(() => type = i + 1);
                    loadReasons();
                  },
                ),
                const SizedBox(height: 8),
                if (error.isNotEmpty)
                  Text(error, style: const TextStyle(color: Colors.red))
                else if (reasons.isEmpty)
                  const Center(child: CircularProgressIndicator())
                else
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 240),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          for (final r in reasons)
                            ListTile(
                              dense: true,
                              leading: Icon(
                                selected?.id == r.id
                                    ? FluentIcons.radio_button_16_filled
                                    : FluentIcons.radio_button_16_regular,
                                size: 16,
                                color: ColorTokens.softPurple,
                              ),
                              title: Text(r.reason),
                              onTap: () =>
                                  setDialogState(() => selected = r),
                            ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            confirmText: '提交',
            onConfirm: () async {
              if (selected == null) {
                InfoFlower.show(context,
                    icon: FluentIcons.error_circle_16_regular,
                    text: '请选择一个风评理由');
                return;
              }
              final result = await _postService.rate(reply.id,
                  reasonId: selected!.id, type: type);
              if (!context.mounted) return;
              Navigator.pop(context);
              if (result.success) {
                InfoFlower.show(context,
                    icon: FluentIcons.checkmark_circle_16_regular,
                    text: '风评成功：${selected!.reason}');
              } else {
                InfoFlower.show(context,
                    icon: FluentIcons.error_circle_16_regular,
                    text: '风评失败');
              }
            },
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    if (LinkNavigator.inPlaceTopicJump == _jumpToTopic) {
      LinkNavigator.inPlaceTopicJump = null;
    }
    controller.removeListener(onScroll);
    controller.dispose();
    super.dispose();
  }
}

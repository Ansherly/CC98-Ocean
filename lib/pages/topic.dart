import 'package:cc98_ocean/controls/clickarea.dart';
import 'package:cc98_ocean/controls/fluent_dialog.dart';
import 'package:cc98_ocean/controls/fluent_iconbutton.dart';
import 'package:cc98_ocean/controls/info_flower.dart';
import 'package:cc98_ocean/controls/info_indicator.dart';
import 'package:cc98_ocean/controls/pager.dart';
import 'package:cc98_ocean/controls/portrait_oval.dart';
import 'package:cc98_ocean/controls/status_title.dart';

import 'package:cc98_ocean/core/constants/color_tokens.dart';
import 'package:cc98_ocean/core/models/reply.dart';
import 'package:cc98_ocean/core/services/post_service.dart';
import 'package:cc98_ocean/ubb_text_block/ubb_text.dart';
import 'package:cc98_ocean/core/themes/setting_controller.dart';
import 'package:cc98_ocean/core/helper.dart';
import 'package:cc98_ocean/pages/profile.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:markdown_widget/widget/all.dart';
import 'package:provider/provider.dart';


class Topic extends StatefulWidget {
  final int topicId;

  const Topic({super.key, required this.topicId});

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

  @override
  void initState() {
    super.initState();
    controller.addListener(onScroll);
    getTopicData();
  }

  Future<void> getTopicData() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    final topicResult = await _postService.getTopicInfo(widget.topicId);
    if (topicResult.isError) {
      setState(() {
        hasError = true;
        errorMessage = topicResult.error!.message;
        isLoading = false;
      });
    } else {
      final data = topicResult.data!;
      setState(() {
        topicDetail = data;
        totalPages = (data["replyCount"] as int? ?? 0) ~/ pageSize + 1;
      });
      currentPage = 0;
      replies.clear();
      await getReply();
    }
  }

  Future<void> getReply() async {
    final result = await _postService.getReplyList(widget.topicId, currentPage * pageSize);
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
          ),
          SizedBox(width: 6),
          FluentIconbutton(
            icon: FluentIcons.more_horizontal_16_regular,
            iconColor: ColorTokens.softPurple,
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
        onPressed: () => _showReplyDialog(0, widget.topicId.toString()),
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
            return buildReplyItem(replies[index]);
          },
        ),
      ),
    );
  }

  Widget buildReplyItem(Reply reply) {
    return Card(
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
                              Profile(userId: reply.userId, canEscape: true))),
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
                : MarkdownBlock(data: MdConverter.convertHtml(reply.content).trim()),
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
              ],
            ),
          ],
        ),
      ),
    );
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
            final sendResult = await _postService.sendReply(widget.topicId, reply);
            InfoFlower.showContent(context,
                child: Text(
                    sendResult.isError ? "回复失败" : "回复已提交",
                    style: TextStyle(color: ColorTokens.primaryLight)));
          }
          Navigator.pop(context);
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

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

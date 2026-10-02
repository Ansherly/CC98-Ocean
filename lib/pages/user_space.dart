import 'package:cc98_ocean/controls/app_shell.dart';
import 'package:cc98_ocean/controls/clickarea.dart';
import 'package:cc98_ocean/controls/expand_button.dart';
import 'package:cc98_ocean/controls/fluent_iconbutton.dart';
import 'package:cc98_ocean/controls/info_flower.dart';
import 'package:cc98_ocean/controls/info_indicator.dart';
import 'package:cc98_ocean/controls/pager.dart';
import 'package:cc98_ocean/controls/portrait_oval.dart';
import 'package:cc98_ocean/controls/status_title.dart';
import 'package:cc98_ocean/core/constants/color_tokens.dart';
import 'package:cc98_ocean/core/models/board.dart';
import 'package:cc98_ocean/core/models/user.dart';
import 'package:cc98_ocean/core/services/user_service.dart';
import 'package:cc98_ocean/core/themes/setting_controller.dart';
import 'package:cc98_ocean/pages/topic.dart';
import 'package:cc98_ocean/ubb_text_block/ubb_text.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

/// 他人空间页。
///
/// 与自己的空间（[Profile]）分离：
/// - 头像区与签名档**固定不可滑动**；签名档**默认折叠**；
/// - 下方为可滑动区域，**不使用无限列表**，底部用 [PageBar] 分页；
/// - 顶部提供返回与关注/取关。
class UserSpacePage extends StatefulWidget {
  final int userId;

  const UserSpacePage({super.key, required this.userId});

  @override
  State<UserSpacePage> createState() => _UserSpacePageState();
}

class _UserSpacePageState extends State<UserSpacePage> {
  final _userService = UserService();

  /// 每页 11 条（接口固定 size=11，多取 1 条判断有无下一页）。
  static const int _pageSize = 11;

  User userProfile = User(
    id: 0,
    name: "98用户",
    portraitUrl: "",
    fanCount: 0,
    postCount: 0,
    gender: 1,
    introduction: "",
    followCount: 0,
    popularity: 0,
    wealth: 0,
    isFollowing: false,
    levelTitle: "98er",
    signatureCode: "",
  );

  List<StandardPost> topics = [];
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';
  int currentPage = 0;
  int totalPages = 1;

  /// 签名档默认折叠。
  bool isExpanded = false;

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 兜底：若目标的 userId 就是自己，说明应进「我的空间」，
    // 这里直接回到上位页面，避免出现"他人空间"视角的自己主页。
    final myId = Provider.of<AppState>(context, listen: false).userId;
    if (myId != 0 && myId == widget.userId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        // 目标是自己：切到主页壳的「我的」标签（索引 5），
        // 并退回本页，避免以"他人空间"视角打开自己的主页。
        AppShell.selectIndex(5);
        Navigator.maybePop(context);
      });
    }
  }

  Future<void> getUserData() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });
    final result = await _userService.getUserProfile(
        isMe: false, userId: widget.userId);
    if (!mounted) return;
    if (result.isError) {
      setState(() {
        errorMessage = result.error!.message;
        hasError = true;
        isLoading = false;
      });
      return;
    }
    final user = result.data!;
    // 总页数：发帖数按页大小向上取整（每页多取 1 条）
    final pages = user.postCount <= 0
        ? 1
        : ((user.postCount + _pageSize - 2) ~/ (_pageSize - 1));
    setState(() {
      userProfile = user;
      totalPages = pages;
      isLoading = false;
    });
    getTopics();
  }

  Future<void> getTopics() async {
    setState(() => isLoading = true);
    final result = await _userService.getRecentTopics(
      isMe: false,
      userId: widget.userId,
      start: currentPage * _pageSize,
    );
    if (!mounted) return;
    if (result.isError) {
      setState(() {
        errorMessage = result.error!.message;
        hasError = true;
        isLoading = false;
      });
      return;
    }
    final parsed = result.data!;
    // 接口 size=11；有多余一条则说明还有更多页
    if (parsed.length == _pageSize) parsed.removeLast();
    setState(() {
      topics = parsed;
      isLoading = false;
    });
  }

  Future<void> _toggleFollow() async {
    final follow = !userProfile.isFollowing;
    final result =
        await _userService.editFollowee(userProfile.id, follow: follow);
    if (!mounted) return;
    if (result.success) {
      setState(() => userProfile = userProfile.copyWith(isFollowing: follow));
      InfoFlower.show(context,
          icon: FluentIcons.person_available_16_regular,
          text: follow ? '已关注 ${userProfile.name}' : '已取消关注 ${userProfile.name}');
    } else {
      InfoFlower.show(context,
          icon: FluentIcons.error_circle_16_regular, text: '操作失败');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 48,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        actionsPadding: const EdgeInsets.only(right: 13),
        leading: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: FluentIconbutton(
            icon: FluentIcons.chevron_left_16_regular,
            onPressed: () => Navigator.maybePop(context),
          ),
        ),
        actions: [
          FluentIconbutton(
            icon: userProfile.isFollowing
                ? FluentIcons.person_delete_16_regular
                : FluentIcons.person_add_16_regular,
            iconColor: ColorTokens.softPurple,
            tooltip: userProfile.isFollowing ? '取消关注' : '关注',
            onPressed: _toggleFollow,
          ),
        ],
        title: StatusTitle(
            title: '空间', isLoading: isLoading, onTap: getUserData),
      ),
      body: buildLayout(),
      bottomNavigationBar: isLoading
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: PageBar(
                  currentPage: currentPage + 1,
                  totalPages: totalPages,
                  onJump: (p) {
                    setState(() {
                      currentPage = p - 1;
                      topics.clear();
                      getTopics();
                    });
                  },
                ),
              ),
            ),
    );
  }

  Widget buildLayout() {
    if (hasError && topics.isEmpty && userProfile.id == 0) {
      return ErrorIndicator(
          icon: FluentIcons.music_note_2_16_regular,
          info: errorMessage,
          onTapped: getUserData);
    }
    // 固定头部（头像 + 统计 + 签名档）+ 可滑动的发帖列表
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
          child: Column(
            children: [
              buildProfile(),
              const SizedBox(height: 8),
              buildSignature(),
              const SizedBox(height: 8),
            ],
          ),
        ),
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : (topics.isEmpty
                  ? const ErrorIndicator(
                      icon: FluentIcons.notepad_16_regular,
                      info: '暂无帖子')
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                      itemCount: topics.length,
                      itemBuilder: (_, i) => buildTopicCard(topics[i]),
                    )),
        ),
      ],
    );
  }

  Widget buildProfile() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              PortraitOval(url: userProfile.portraitUrl, size: 40),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      spacing: 12,
                      children: [
                        Text(
                          userProfile.name,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        Icon(
                          userProfile.gender == 1 ? Icons.male : Icons.female,
                          color: userProfile.gender == 1
                              ? Colors.blue.shade100
                              : Colors.pink.shade100,
                          size: 20,
                        ),
                      ],
                    ),
                    Text(userProfile.levelTitle,
                        style: const TextStyle(
                            fontSize: 13, color: ColorTokens.softPurple)),
                    Text('ID: ${userProfile.id}',
                        style: const TextStyle(
                            fontSize: 13, color: ColorTokens.softPurple)),
                  ],
                ),
              ),
              ClickArea(
                onTap: () => launchUrl(
                    Uri.parse('https://www.cc98.org/user/${userProfile.id}')),
                child: const Row(
                  spacing: 4,
                  children: [
                    Text("空间",
                        style: TextStyle(
                            fontSize: 12, color: ColorTokens.softGrey)),
                    Icon(FluentIcons.chevron_right_16_regular,
                        size: 14, color: ColorTokens.softGrey),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('风评', userProfile.popularity.toString()),
              const SizedBox(
                  height: 24,
                  child: VerticalDivider(
                      width: 16,
                      thickness: 1,
                      color: ColorTokens.dividerBlue)),
              _buildStatItem('动态', userProfile.postCount.toString()),
              const SizedBox(
                  height: 24,
                  child: VerticalDivider(
                      width: 16,
                      thickness: 1,
                      color: ColorTokens.dividerBlue)),
              _buildStatItem('关注', userProfile.followCount.toString()),
              const SizedBox(
                  height: 24,
                  child: VerticalDivider(
                      width: 16,
                      thickness: 1,
                      color: ColorTokens.dividerBlue)),
              _buildStatItem('粉丝', userProfile.fanCount.toString()),
              const SizedBox(
                  height: 24,
                  child: VerticalDivider(
                      width: 16,
                      thickness: 1,
                      color: ColorTokens.dividerBlue)),
              _buildStatItem('财富', userProfile.wealth.toString()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                fontSize: 14, color: ColorTokens.primaryLight)),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(fontSize: 12, color: ColorTokens.softGrey)),
      ],
    );
  }

  /// 签名档：默认折叠，位置等价于图中"成为大会员"横幅。
  Widget buildSignature() {
    final signature = userProfile.signatureCode;
    return Card(
      elevation: 0,
      color: Theme.of(context).brightness == Brightness.light
          ? ColorTokens.dividerBlue
          : ColorTokens.darkGrey,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ExpandButton(
              initialExpanded: false,
              onExpansionChanged: (i) => setState(() => isExpanded = i),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: isExpanded
                  ? (signature.isNotEmpty
                      ? UbbText(data: signature)
                      : const Text('该用户还没有设置签名档',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.grey,
                              fontStyle: FontStyle.italic)))
                  : const Text('签名档已折叠',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.grey, fontStyle: FontStyle.italic)),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTopicCard(StandardPost post) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => Topic(topicId: post.id))),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              const Icon(FluentIcons.notepad_16_regular,
                  size: 16, color: ColorTokens.softPurple),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  post.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey[700], fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

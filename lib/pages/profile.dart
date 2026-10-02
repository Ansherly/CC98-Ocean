import 'package:cc98_ocean/controls/info_flower.dart';
import 'package:cc98_ocean/controls/info_indicator.dart';
import 'package:cc98_ocean/controls/portrait_oval.dart';
import 'package:cc98_ocean/controls/status_title.dart';
import 'package:cc98_ocean/core/models/user.dart';
import 'package:cc98_ocean/core/models/board.dart';
import 'package:cc98_ocean/core/services/user_service.dart';
import 'package:cc98_ocean/ubb_text_block/ubb_text.dart';
import 'package:cc98_ocean/controls/clickarea.dart';
import 'package:cc98_ocean/controls/expand_button.dart';
import 'package:cc98_ocean/controls/fluent_iconbutton.dart';
import 'package:cc98_ocean/core/constants/color_tokens.dart';
import 'package:cc98_ocean/core/themes/setting_controller.dart';
import 'package:cc98_ocean/pages/favorite.dart';
import 'package:cc98_ocean/pages/friends.dart';
import 'package:cc98_ocean/pages/history.dart';
import 'package:cc98_ocean/pages/settings.dart';
import 'package:cc98_ocean/pages/topic.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
/// 自己的空间页：固定头部（头像/统计/签名档）+ 下方可滑动的入口宫格。
///
/// 他人空间见 [UserSpacePage]。
class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}
class _ProfileState extends State<Profile> {
  bool get wantKeepAlive => true;

  User userProfile=User(id: 0, name: "98用户", portraitUrl: "", fanCount: 0, postCount: 0, gender: 1, introduction: "", followCount: 0, popularity: 0, wealth: 0, isFollowing: false, levelTitle: "98er", signatureCode: "");
  bool isLoading = true;
  bool hasError = false;
  bool isExpanded=true;
  String errorMessage = '';
  final _userService = UserService();

  /// 今日是否已签到（null = 未知）。用于标题栏状态按钮。
  bool? _signedToday;
  
  @override
  void initState() {
    super.initState();
    getUserData();
  }
  // 获取用户数据
  Future<void> getUserData() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });
    final result = await _userService.getUserProfile(isMe: true, userId: 0);
    if (result.isError) {
      setState(() {
        errorMessage = result.error!.message;
        hasError = true;
        isLoading = false;
      });
    } else {
      if (!mounted) return;
      setState(() {
        userProfile = result.data!;
        isLoading = false;
      });
      // 记录自己的用户 ID，供「是否他人空间」比对
      Provider.of<AppState>(context, listen: false).setUserId(userProfile.id);
      _autoSignIn();
    }
  }

  // 进入自己主页时自动签到（与 C# ProfilePage 行为一致）。
  // 仅"本次签到成功"弹提示；今日已签到/失败不弹。
  Future<void> _autoSignIn() => _doSignIn(force: false);

  /// 执行签到。[force] 为 true 表示用户手动点击（失败时给出提示）。
  Future<void> _doSignIn({required bool force}) async {
    final result = await _userService.signIn();
    if (!mounted) return;
    switch (result.status) {
      case SignInStatus.success:
        setState(() => _signedToday = true);
        InfoFlower.show(context,
            icon: FluentIcons.checkmark_circle_16_regular,
            text: result.message);
        // 签到会改变财富值，刷新显示
        final refreshed = await _userService.getUserProfile(isMe: true);
        if (!mounted) return;
        if (!refreshed.isError) setState(() => userProfile = refreshed.data!);
      case SignInStatus.alreadySigned:
        // 今日已签到：静默记录状态，不弹提示
        setState(() => _signedToday = true);
      case SignInStatus.failed:
        if (force) {
          InfoFlower.show(context,
              icon: FluentIcons.error_circle_16_regular,
              text: result.message);
        }
    }
  }

  // 关注 / 取关当前用户
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
      //主区域
      appBar: AppBar(
        toolbarHeight: 48,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
        ),       
        actionsPadding: EdgeInsets.only(right: 13),
        titleSpacing: 8,
        automaticallyImplyLeading: false,
        actions: [
          // 签到状态标识：点击强制再签到一次
          FluentIconbutton(
            icon: (_signedToday ?? false)
                ? FluentIcons.checkmark_circle_16_filled
                : FluentIcons.circle_16_regular,
            iconColor: (_signedToday ?? false)
                ? ColorTokens.softOrange
                : ColorTokens.softPurple,
            tooltip: (_signedToday ?? false) ? '今日已签到（点击再签到）' : '签到',
            onPressed: () => _doSignIn(force: true),
          ),
          FluentIconbutton(icon: FluentIcons.settings_16_regular,iconColor: ColorTokens.softPurple,onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context)=>Settings()));
          },),
        ],
        centerTitle: true,
        title: StatusTitle(title: "空间",isLoading: isLoading,onTap:getUserData)
      ),
      body: buildLayout(),
      
    );
  }

  Widget buildLayout() {
    if (hasError) {
      return ErrorIndicator(
          icon: FluentIcons.music_note_2_16_regular,
          info: errorMessage,
          onTapped: getUserData);
    }
    // 自己的空间：头部（头像 + 统计 + 签名档）固定；下方入口宫格可滑动。
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
          child: Column(
            children: [
              buildProfile(),
              const SizedBox(height: 8),
              // 签名档（等价图中"成为大会员"横幅的位置）
              buildSignature(),
              const SizedBox(height: 8),
            ],
          ),
        ),
        // 签名档下方：入口宫格，整体可滚动
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
            children: [
              buildEntryGrid(),
            ],
          ),
        ),
      ],
    );
  }

  /// 我的空间四入口：草稿箱 / 历史记录 / 收藏 / 稍后再看。
  Widget buildEntryGrid() {
    final entries = [
      (
        label: '草稿箱',
        icon: FluentIcons.archive_16_regular,
        // 官方 API 无草稿接口，先占位
        onTap: () => InfoFlower.show(context,
            icon: FluentIcons.archive_16_regular, text: '草稿箱功能开发中')
      ),
      (
        label: '历史记录',
        icon: FluentIcons.history_16_regular,
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => const HistoryPage()))
      ),
      (
        label: '收藏',
        icon: FluentIcons.star_16_regular,
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => const FavoritesPage()))
      ),
      (
        label: '稍后再看',
        icon: FluentIcons.bookmark_16_regular,
        onTap: () => InfoFlower.show(context,
            icon: FluentIcons.bookmark_16_regular, text: '稍后再看功能开发中')
      ),
    ];
    return Row(
      children: [
        for (final e in entries)
          Expanded(
            child: _buildEntryItem(label: e.label, icon: e.icon, onTap: e.onTap),
          ),
      ],
    );
  }

  Widget _buildEntryItem({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 26, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 6),
            Text(label,
                style: const TextStyle(fontSize: 13, color: ColorTokens.softGrey)),
          ],
        ),
      ),
    );
  }

  Widget buildProfile() {
    var colorBase=ColorScheme.fromSeed(seedColor: ColorTokens.surfaceLight);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Column(
        children: [
          // 头像和昵称
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 头像
              PortraitOval(url:userProfile.portraitUrl, size: 40),
              const SizedBox(width: 16),
              // 昵称和基本信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 昵称和性别
                    Row(
                      spacing: 12,
                      children: [
                        Text(
                          userProfile.name,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color:Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          userProfile.gender == 1 ? Icons.male : Icons.female,
                          color: userProfile.gender == 1 ? Colors.blue.shade100 : Colors.pink.shade100,
                          size: 20,
                        ),
                      ],
                    ),
                    Text(userProfile.levelTitle,
                         style: TextStyle(
                          fontSize: 13,
                          color: ColorTokens.softPurple)
                        ),
                    // 用户ID
                    Text('ID: ${userProfile.id}',
                         style: TextStyle(
                          fontSize: 13,
                          color: ColorTokens.softPurple)
                        ),
                  ],
                ),
              ),
              ClickArea(
                onTap: () {
                  // 跳转到网页版个人空间
                  launchUrl(Uri.parse('https://www.cc98.org/user/${userProfile.id}'));
                },
                child: Row(
                  spacing: 4,
                  children: [
                    Text("空间",style: TextStyle(fontSize: 12,color: ColorTokens.softGrey),),
                    Icon(FluentIcons.chevron_right_16_regular,size: 14,color: ColorTokens.softGrey,)
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 12),
          // 数据指标
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              buildStatItem('风评', userProfile.popularity.toString()),
              SizedBox(height: 24,child: VerticalDivider(width: 16,thickness: 1,color: ColorTokens.dividerBlue,)),
              buildStatItem('动态', userProfile.postCount.toString()),
              SizedBox(height: 24,child: VerticalDivider(width: 16,thickness: 1,color: ColorTokens.dividerBlue,)),
              ClickArea(child: buildStatItem('粉丝', userProfile.fanCount.toString()),onTap: () {
                Navigator.push(context,MaterialPageRoute(builder: (context) => const Friends()));}),
              SizedBox(height: 24,child: VerticalDivider(width: 16,thickness: 1,color: ColorTokens.dividerBlue,)),
              buildStatItem('财富', userProfile.wealth.toString()),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: ColorTokens.primaryLight,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: ColorTokens.softGrey,
          ),
        ),
      ],
    );
  }

  Widget buildSignature() {
    final signature = userProfile.signatureCode;
    return Card(
      elevation: 0,
      color: Theme.of(context).brightness==Brightness.light? ColorTokens.dividerBlue:ColorTokens.darkGrey,
      shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(8)),
      child:Padding(padding: EdgeInsetsGeometry.all(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ExpandButton(initialExpanded: true,onExpansionChanged: (i)=>setState(() {
            isExpanded=i;
          })),
          SizedBox(width: 8),
          Expanded(
            child: isExpanded?(signature.isNotEmpty
                  ? UbbText(data: signature)
                  : const Text(
                      '该用户还没有设置签名档',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    )):const Text(
                      '签名档已折叠',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    )

          )
        ],
      ),
      )
       );
  }
  
  // 加载更多回复
}

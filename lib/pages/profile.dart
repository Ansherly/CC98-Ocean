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
import 'package:cc98_ocean/pages/friends.dart';
import 'package:cc98_ocean/pages/settings.dart';
import 'package:cc98_ocean/pages/topic.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
class Profile extends StatefulWidget {
  final int userId;
  final bool canEscape;
  const Profile({super.key, required this.userId,required this.canEscape});
  
  @override
  State<Profile> createState() => _ProfileState();
}
class _ProfileState extends State<Profile> {
  bool get wantKeepAlive => true;
  final ScrollController controller = ScrollController();

  User userProfile=User(id: 0, name: "98用户", portraitUrl: "", fanCount: 0, postCount: 0, gender: 1, introduction: "", followCount: 0, popularity: 0, wealth: 0, isFollowing: false, levelTitle: "98er", signatureCode: "");
  List<StandardPost> recentTopics = [];
  bool isLoading = true;
  bool hasError = false;
  bool isExpanded=true;
  bool hasMore = true; 
  String errorMessage = '';
  int currentPage = 0;
  final int pageSize = 10;
  final _userService = UserService();
  
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
    final result = await _userService.getUserProfile(isMe: widget.userId == 0, userId: widget.userId);
    if (result.isError) {
      setState(() {
        errorMessage = result.error!.message;
        hasError = true;
        isLoading = false;
      });
    } else {
      userProfile = result.data!;
      getTopics();
    }
  }
  Future<void> getTopics() async {
    // 获取历史发帖
      final topicResult = await _userService.getRecentTopics(
        isMe: widget.userId == 0,
        userId: widget.userId,
        start: currentPage * pageSize,
      );

      if (topicResult.isError) {
        setState(() {
          hasError = true;
          errorMessage = topicResult.error!.message;
          isLoading = false;
        });
      } else {
        final parsed = topicResult.data!;
        if (parsed.length == 11) {
          parsed.removeLast();
        }
        setState(() {
          recentTopics.addAll(parsed);
          isLoading = false;
          hasMore = parsed.length == pageSize;
        });
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
        leading:widget.canEscape? Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 8),
          child: FluentIconbutton(
            icon:FluentIcons.chevron_left_16_regular,
            onPressed: () => Navigator.maybePop(context),
          ),
        ):null,
        actions: [
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
    if(hasError)return ErrorIndicator(icon: FluentIcons.music_note_2_16_regular, info: errorMessage,onTapped: getUserData);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
            buildProfile(),
            buildSignature(),
            buildHistory(),
          ],
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
                if(widget.canEscape)return;//可以退出说明这不是用户自己的主页，不允许查看好友
                Navigator.push(context,MaterialPageRoute(builder: (context) => Friends()));}),
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
  
  Widget buildHistory() {
    return Expanded(
      child: ListView.builder(
        controller: controller,
        itemCount: recentTopics.length,
        itemBuilder:(_,i){
          return buildTopicCard(recentTopics[i]);
        }
    ));
  }
  // 加载更多回复
  Future<void> loadMore() async {
    if (!hasMore || isLoading) return;
    
    setState(() {
      currentPage++;
      isLoading = true;
    });
    
    await getTopics();
  }

  // 构建加载更多指示器
  Widget _buildLoadMoreIndicator() {
    if (!hasMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text('没有更多回复了', style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : TextButton(
                onPressed: loadMore,
                child: const Text('加载更多回复'),
              ),
      ),
    );
  }

  Widget buildTopicCard(StandardPost post){
    return Card(
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(4),
    ),
    child: InkWell(
      borderRadius: BorderRadius.circular(4),
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Topic(topicId: post.id),
            ),
          );
      },
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(FluentIcons.notepad_16_regular,size: 16,color: ColorTokens.softPurple,),
            SizedBox(width: 6,),
            Expanded(
              child: Text(
                  post.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                ),
            ),
          ],
        ),
      ),
    ),
  );
  }
  
  
}

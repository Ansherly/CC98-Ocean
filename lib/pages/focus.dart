import 'package:cc98_ocean/controls/clickarea.dart';
import 'package:cc98_ocean/controls/adaptive_divider.dart';
import 'package:cc98_ocean/controls/fluent_iconbutton.dart';
import 'package:cc98_ocean/controls/info_indicator.dart';
import 'package:cc98_ocean/controls/portrait_oval.dart';
import 'package:cc98_ocean/controls/segmented.dart';
import 'package:cc98_ocean/controls/smart_image.dart';
import 'package:cc98_ocean/controls/status_title.dart';
import 'package:cc98_ocean/core/constants/color_tokens.dart';
import 'package:cc98_ocean/core/models/post.dart';
import 'package:cc98_ocean/core/models/user.dart';
import 'package:cc98_ocean/core/services/post_service.dart';
import 'package:cc98_ocean/core/helper.dart';
import 'package:cc98_ocean/pages/profile.dart';
import 'package:cc98_ocean/pages/topic.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';


class Moments extends StatefulWidget {
  const Moments({super.key});

  @override
  State<Moments> createState() => _MomentsState();
}
class _MomentsState extends State<Moments>{
  int _selected=0;
  List<SimpleUserInfo> users=[];
  int currentPage=0;
  int pageSize=20;
  bool isLoading=false;
  bool hasError=false;
  bool hasMore=true;
  String errorMessage="";
  List<FeedPost> posts=[];
  final ScrollController controller=ScrollController();
  final _postService = PostService();

  @override
  void initState() {
    super.initState();
    controller.addListener(onScroll);
    getMoments();
  }

  Future<void> getMoments()async{
    setState(() {
      isLoading=true;
      hasError=false;
    });
    final result = _selected == 0
        ? await _postService.getMoments(currentPage * pageSize)
        : await _postService.getFavoriteUpdates(currentPage * pageSize);
    if (result.isError) {
      setState(() {
        hasError = true;
        errorMessage = result.error!.message;
        isLoading = false;
      });
    } else {
      setState(() {
        posts.addAll(result.data!);
        isLoading = false;
      });
    }
    
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 48,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),       
        actionsPadding: EdgeInsets.only(right: 13),
        centerTitle: true,
        titleSpacing: 8,
        actions: [
          FluentIconbutton(
            icon: FluentIcons.arrow_sync_16_regular,
            iconColor: ColorTokens.softPurple,
            onPressed: () {
              
            },
            ),
          SizedBox(width: 6),
          FluentIconbutton(
            icon: FluentIcons.edit_16_regular,
            iconColor: ColorTokens.softPurple,
            onPressed: () {
            },
            ),
        ],
        title: StatusTitle(title: "动态",isLoading: isLoading)
      ),
      body:buildLayout(),
    );
  }
  
  Widget buildLayout(){
    if(!isLoading&&posts.isEmpty)return ErrorIndicator(icon: FluentIcons.music_note_1_20_regular, info: "暂无帖子，点击刷新",onTapped: getMoments);
    if(hasError)return ErrorIndicator(icon: FluentIcons.music_note_2_16_regular, info: errorMessage,onTapped: getMoments);
    return CustomScrollView(
    controller: controller,
    slivers: [
      // SegmentedControl
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 4),
          child: SegmentedControl(
              items: const ['关注', '追更'],
              initialIndex: _selected,
              onSelected: (i) {
                setState((){
                  _selected=i;
                  currentPage=0;
                  hasMore=true;
                  posts.clear();
                } );
                getMoments();
              }),
        ),
      ),
      // SizedBox（占位或分隔）
      SliverToBoxAdapter(
        child: buildUserList(users),
      ),
      SliverToBoxAdapter(child:AdaptiveDivider()),
      //SliverList
      SliverList.separated(
        itemCount:posts.length ,
        itemBuilder: (context, index) => buildPostItem(posts[index]),
        separatorBuilder:(_, __) =>AdaptiveDivider()
        ),
    ],
  );
  }

  

  Widget buildUserList(List<SimpleUserInfo> users){
    return SizedBox(
      height: 84,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12,vertical:8),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: users.length,
          itemBuilder: (_,i)=>Padding(
            padding: EdgeInsetsGeometry.symmetric(horizontal: 8),
            child:buildUserInfo(users[i]) ,
            )
          ),
      ),
    );
  }
  Widget buildUserInfo(SimpleUserInfo info){
    return ClickArea(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Profile(userId: info.userId,canEscape: true,),
            ),
          );
      },
      child: Column(
        spacing: 6,
        children: [
          PortraitOval(url: info.portraitUrl),
          Text(info.userName,style: TextStyle(color: ColorTokens.softPurple,fontSize: 10),)                     
        ],
      ),
    );
  }

  Widget buildPostItem(FeedPost post) {
  final mediaMap=post.mediaContent;//取出第一层
  final thumbNails=(mediaMap["thumbnail"] as List<dynamic>?)?.cast<String>()??<String>[];
  return Card( 
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(0),
    ),
    child: ClickArea(
      onTap: ()=>{Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Topic(topicId: post.id),
            ),
          )},
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 作者信息和发布时间
            Row(
              children: [
                // 作者头像
                PortraitOval(url: post.portraitUrl),
                const SizedBox(width: 12),
                // 作者名和发布时间
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: ColorTokens.primaryLight,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        post.time.toUtc8,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                // 收藏按钮
                FluentIconbutton(icon: FluentIcons.more_vertical_16_regular)
              ],
            ),
            const SizedBox(height: 12),
            // 帖子标题
            Text(
                post.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 14,
                ),
              ),
      
            const SizedBox(height: 12),
            if (thumbNails.isNotEmpty)
              Wrap(
                runSpacing: 8,
                spacing: 12,
                children: thumbNails
                    .map((url) => Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(side: BorderSide(color: ColorTokens.softPurple),borderRadius:BorderRadiusGeometry.circular(6)),
                      child: ClipRRect(
                        borderRadius: BorderRadiusGeometry.circular(6),
                        child: Image.network(
                              url,
                              width: 150,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Text("图片加载失败:$url"),
                                  ),
                            ),
                      ),
                    ))
                    .toList(),
              ),
            // 回复数和浏览量
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6,vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  buildStatItem(FluentIcons.fire_16_regular, post.hitCount),
                  buildStatItem(FluentIcons.chat_16_regular, post.replyCount),
                  buildStatItem(FluentIcons.chevron_up_16_regular, post.likeCount)     
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  ); 
}
Widget buildStatItem(IconData icon,int count){
    return Row(
      spacing: 4,
      children: [
      Icon(icon,color: ColorTokens.softPurple,size: 12),
      Text(count.toString(),style: TextStyle(color: ColorTokens.softPurple))
    ]);
  }
void onScroll()async {
    if (controller.position.pixels >=controller.position.maxScrollExtent - 100 &&!isLoading &&!hasError && hasMore) {
        currentPage++;
        await getMoments();
    }
  }
  @override
  void dispose() {
  controller.dispose();
  super.dispose();
  }
}
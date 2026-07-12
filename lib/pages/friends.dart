import 'package:cc98_ocean/controls/clickarea.dart';
import 'package:cc98_ocean/controls/fluent_iconbutton.dart';
import 'package:cc98_ocean/controls/info_indicator.dart';
import 'package:cc98_ocean/controls/portrait_oval.dart';
import 'package:cc98_ocean/controls/segmented.dart';
import 'package:cc98_ocean/controls/status_title.dart';
import 'package:cc98_ocean/core/constants/color_tokens.dart';
import 'package:cc98_ocean/core/models/user.dart';
import 'package:cc98_ocean/core/services/user_service.dart';
import 'package:cc98_ocean/pages/profile.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

class Friends extends StatefulWidget {
  const Friends({super.key});

  @override
  State<Friends> createState() => _FriendsState();
}
class _FriendsState extends State<Friends>{
  int _selected=0;
  int currentPage=0;
  int pageSize=10;
  bool isLoading=false;
  bool hasError=false;
  bool hasMore=true;
  String errorMessage="";
  List<SimpleUserInfo> friends=[];
  final ScrollController controller = ScrollController();

  @override
  void initState() {
    super.initState();
    controller.addListener(onScroll);
    getFriends();
  }

  Future<void> getFriends()async{
    setState(() {
      isLoading = true;
      hasError = false;
    });
    String mode = _selected==0? "follower":"followee";
    final result = await UserService().getFriends(mode, currentPage * pageSize);
    if (result.isError) {
      setState(() {
        hasError = true;
        errorMessage = result.error!.message;
        isLoading = false;
      });
    } else {
      setState(() {
        friends.addAll(result.data!);
        hasMore = result.data!.length == pageSize;
        hasError = false;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        toolbarHeight: 48,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),       
        actionsPadding: EdgeInsets.only(right: 13),
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 8),
          child: FluentIconbutton(
            icon: FluentIcons.chevron_left_16_regular,
            onPressed: () {
              Navigator.maybePop(context);
            },
          ),
        ),
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
        
        title: StatusTitle(title: "好友",isLoading: isLoading,onTap: () {
          setState(() {
            friends.clear();
          });
          currentPage=0;
          getFriends();
        },) 
      ),
      body: buildLayout(),
      );
  }

  Widget buildLayout(){
    if(!isLoading&&friends.isEmpty)return ErrorIndicator(icon: FluentIcons.music_note_1_20_regular, info: "暂无好友，点击刷新",onTapped: getFriends);
    if(hasError)return ErrorIndicator(icon: FluentIcons.music_note_2_16_regular, info: errorMessage,onTapped: getFriends);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 4),
          child: SegmentedControl(
              items: const ['粉丝', '关注'],
              initialIndex: _selected,
              onSelected: (i) {
                setState((){
                  _selected=i;
                  currentPage=0;
                  hasMore=true;
                  friends.clear();//涉及UI更新，必须setState
              });
                getFriends();
            }),
        ),
        Text(errorMessage),
        Expanded(child: 
          ListView.separated(
            controller: controller,
            itemCount: hasMore?friends.length+1: friends.length,
            separatorBuilder: (context, index) => Divider(indent: 60,height: 6, thickness: 1,color: Theme.of(context).dividerColor),
            itemBuilder: (_,i){
              if(i==friends.length){
                return buildLoadMoreIndicator();
              }
              return buildFriend(friends[i]);
            }
            )
        )
      ],
    ) ;
  }
  Widget buildFriend(SimpleUserInfo info){
    return Card(
      elevation: 0, 
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(0)
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            SizedBox(
              height: 36,
              width: 36,
              child: ClickArea(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context)=>Profile(userId: info.userId,canEscape: true,))),
                child: ClipOval(
                  child: PortraitOval(url: info.portraitUrl), 
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(info.userName,style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: ColorTokens.primaryLight, 
                            ),),
                  SizedBox(height: 2),
                  Text((info.introduction ?? "").isEmpty ? "该用户还没有设置简介~" : info.introduction!,style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),)
                      
                ],
              ),
            ),
            FluentIconbutton(icon: FluentIcons.heart_16_regular),
            SizedBox(width: 20,)
          ],
        ),
      ),
    );
  }
  Widget buildLoadMoreIndicator(){
    return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text('下拉加载更多', style: TextStyle(color: Colors.grey)),
        ),
      );
  }
  void onScroll()async{
    if (controller.position.pixels >=controller.position.maxScrollExtent - 100 &&!isLoading &&!hasError && hasMore) {
        currentPage++;
        await getFriends();  
    }
  }

  @override
  void dispose() {
  controller.dispose();
  super.dispose();
}
}
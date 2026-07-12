import 'package:cc98_ocean/controls/fluent_iconbutton.dart';
import 'package:cc98_ocean/controls/info_flower.dart';
import 'package:cc98_ocean/controls/info_indicator.dart';
import 'package:cc98_ocean/controls/status_title.dart';
import 'package:cc98_ocean/core/constants/color_tokens.dart';
import 'package:cc98_ocean/core/models/message.dart';
import 'package:cc98_ocean/core/services/user_service.dart';
import 'package:cc98_ocean/pages/profile.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
class Chat extends StatefulWidget {
  final int senderId;
  final String senderName;
  const Chat({super.key,required this.senderId,required this.senderName});
  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final _userService = UserService();
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> messages = [];
  int currentPage=0;
  int pageSize=10;
  bool hasMore=true;
  bool isLoading=false;
  bool hasError=false;
  String errorMessage="";
  void _sendMessage() {
}
  @override
  void initState(){
    super.initState();
    getChatHistory();
  }
  Future<void> getChatHistory()async{
    setState(() {
      hasError=false;
      isLoading=true;
    });
    final result = await _userService.getChatHistory(widget.senderId, currentPage * pageSize);
    if (result.isError) {
      setState(() {
        errorMessage = result.error!.message;
        hasError = true;
        isLoading = false;
      });
    } else {
      final data = result.data!;
      setState(() {
        hasMore = data.length == pageSize;
        for (var e in data) {
          messages.insert(0, e);
        }
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
            icon:FluentIcons.chevron_left_16_regular,
            onPressed: () => Navigator.maybePop(context)
          ),
        ),
        actions: [
          FluentIconbutton(icon: FluentIcons.arrow_sync_16_regular,iconColor: ColorTokens.softPurple,onPressed: (){
            currentPage=0;
            messages.clear();
            getChatHistory();
          }),
          FluentIconbutton(icon: FluentIcons.person_16_regular,iconColor: ColorTokens.softPurple,onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context)=>Profile(userId: widget.senderId, canEscape: true)));
          },)
        ],
        title: StatusTitle(title: widget.senderName,isLoading: isLoading,onTap:() {
          setState(() {
            messages.clear();
          });
          currentPage=0;
          getChatHistory();
        })

      ),
      body:buildLayout()
    );
  }

  Widget buildLayout(){
    if(!isLoading&&messages.isEmpty)return ErrorIndicator(icon: FluentIcons.music_note_1_20_regular, info: "暂无帖子，点击刷新",onTapped: getChatHistory);
    if(hasError)return ErrorIndicator(icon: FluentIcons.music_note_2_16_regular, info: errorMessage,onTapped: getChatHistory);
    return SafeArea(
      child: Column(
          children: [
            Expanded(
              child: buildChatList()
            ),
            buildInputField()
          ],
        ),
    );
  }

  Widget buildChatList(){
    return RefreshIndicator(
      onRefresh: ()async{
        if(hasMore){
          currentPage++;
          getChatHistory();
        }
        else{
          InfoFlower.showContent(context, child:Text("已加载全部对话"));
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10,vertical: 12),
        color: ColorTokens.chatBackground,
        child: ListView.builder(
                  itemCount: messages.length+1,
                  itemBuilder: (context, index) {
                    if(index==0){
                      return Center(child: Padding(padding: EdgeInsetsGeometry.all(12),child: Text(hasMore?"下拉加载更多":"没有更多回复了",style: TextStyle(color: Colors.grey,fontSize: 12),),));
                    }
                    else{
                      final msg = messages[index-1];
                      return buildChatBox(msg); 
                    }
                    
                  },
                ),
      ),
    );
  }
  Widget buildChatBox(ChatMessage msg){
    bool isMe=msg.senderId!=widget.senderId;
    return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isMe ? ColorTokens.softPurple.withAlpha(100) : Colors.white,
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(12),topRight: Radius.zero,bottomLeft:Radius.circular(12) ,bottomRight: Radius.circular(12)),
                    ),
                    child: Column(
                      spacing: 4,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          msg.content,
                          style: TextStyle(
                            color: isMe ? Colors.white : Colors.black87,
                          ),
                        ),
                        Text(
                          msg.time,
                          style: TextStyle(
                            color:isMe?Colors.white:ColorTokens.softGrey,
                            fontSize: 10
                          ),
                        ),
                      ],
                    ),
                  ),
                );
  }
  Widget buildInputField(){
    return Container(
            padding: EdgeInsets.symmetric(horizontal: 8,vertical: 4),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(hintText: "输入消息...",
                    enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: ColorTokens.softPurple),
                    ),
                    focusedBorder: UnderlineInputBorder(

                    borderSide: BorderSide(color: ColorTokens.primaryLight),
                    ),
                    hintStyle: TextStyle(color: ColorTokens.softPurple),
                    prefixIconColor: ColorTokens.softPurple,
                    suffixIconColor: ColorTokens.softPurple)
                     ),
                  ),
                
                FluentIconbutton(icon: FluentIcons.send_16_regular,onPressed: () => _sendMessage(),)
              ],
            ),
          );
  }
}
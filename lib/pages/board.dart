
import 'package:cc98_ocean/controls/info_flower.dart';
import 'package:cc98_ocean/controls/info_indicator.dart';
import 'package:cc98_ocean/controls/status_title.dart';
import 'package:cc98_ocean/core/models/board.dart';
import 'package:cc98_ocean/core/services/board_service.dart';
import 'package:cc98_ocean/controls/fluent_iconbutton.dart';
import 'package:cc98_ocean/ubb_text_block/ubb_text.dart';
import 'package:cc98_ocean/controls/hyperlink_button.dart';
import 'package:cc98_ocean/controls/pager.dart';
import 'package:cc98_ocean/core/constants/color_tokens.dart';
import 'package:cc98_ocean/pages/topic.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

class Board extends StatefulWidget {
  final int boardId;
  const Board({super.key,required this.boardId});

  @override
  State<Board> createState() => _BoardState();
}

class _BoardState extends State<Board>
{
  /// 用于打开版面通告的 endDrawer
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isPinned=false;
  bool isLoading = true;
  bool hasError = false;
  String errorMessage="";
  late BoardInfo data;
  List<StandardPost> posts=[];
  int currentPage=0;
  int pageSize=20;


  @override
  void initState() {
    super.initState();
    getMetaData();
  }

  Future<void> getMetaData()async{
    setState(() {
      isLoading = true;
      hasError = false;
    });

  final result = await BoardService().getBoardInfo(widget.boardId);
  if (result.isError) {
    setState(() {
      hasError = true;
      errorMessage = result.error!.message;
      isLoading = false;
    });
  } else {
    setState(() {
      data = result.data!;
      isLoading = false;
    });
    getTopic();
  }
  }
  
  Future<void> getTopic()async{

    final result = await BoardService().getBoardTopics(widget.boardId, currentPage * pageSize);
    if (result.isError) {
      setState(() {
        isLoading = false;
        hasError = true;
        errorMessage = result.error!.message;
      });
    } else {
      setState(() {
        posts.clear();
        posts.addAll(result.data!);
        isLoading = false;
      });
    }
    
  }

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      endDrawer: buildBigPaperDrawer(),
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
            icon: _isPinned
                ? FluentIcons.pin_off_16_regular
                : FluentIcons.pin_16_regular,
            iconColor: ColorTokens.softPurple,
            tooltip: _isPinned ? '取消关注版面' : '关注版面',
            onPressed: _toggleFocusBoard,
            ),
          SizedBox(width: 6),
          FluentIconbutton(
            icon: FluentIcons.slide_text_16_regular,
            iconColor: ColorTokens.softPurple,
            tooltip: '版面通告',
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
            ),
        ],
        title: StatusTitle(title:isLoading?"加载中···":data.name,isLoading: isLoading,onTap:getMetaData)
        //对于late变量，我们确保已经初始化再调用
      ),
      body:buildLayout(),
      bottomNavigationBar: SafeArea( 
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child:isLoading?null:PageBar(currentPage: currentPage+1,totalPages:data.topicCount~/20,onJump:(p) {
                setState(() {
                  currentPage=p-1;
                  getTopic();
                });
              }),
        ),
      ),
    );
  }

  // 关注 / 取消关注版面（PUT / DELETE，与 C# BoardPage.Pin 一致）
  Future<void> _toggleFocusBoard() async {
    final follow = !_isPinned;
    final result = await BoardService()
        .editFocusBoards(widget.boardId, follow: follow);
    if (!mounted) return;
    if (result.success) {
      setState(() => _isPinned = follow);
      InfoFlower.show(context,
          icon: FluentIcons.pin_16_regular,
          text: follow ? '已关注' : '已取消关注');
    } else {
      InfoFlower.show(context,
          icon: FluentIcons.error_circle_16_regular,
          text: result.message ?? '操作失败');
    }
  }

  Widget buildLayout(){
    if(isLoading)return Center(child: CircularProgressIndicator());
    if(!isLoading&&posts.isEmpty)return ErrorIndicator(icon: FluentIcons.music_note_1_20_regular, info: "暂无帖子，点击刷新",onTapped: getTopic);
    if(hasError)return ErrorIndicator(icon: FluentIcons.music_note_2_16_regular, info: errorMessage,onTapped: getTopic);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: buildTopicList(posts),
    );
  }

  /// 版面通告：从右侧滑出的面板（竖直可滚动），右上角 × 关闭。
  Widget buildBigPaperDrawer() {
    final bigPaper = isLoading ? '' : data.bigPaper;
    final theme = Theme.of(context);
    return Drawer(
      backgroundColor: theme.colorScheme.surface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 面板头：标题 + 关闭按钮
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
              child: Row(
                children: [
                  const Icon(FluentIcons.slide_text_16_regular,
                      size: 18, color: ColorTokens.softPurple),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text('版面通告',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  FluentIconbutton(
                    icon: FluentIcons.dismiss_16_regular,
                    tooltip: '关闭',
                    onPressed: () => Navigator.maybePop(context),
                  ),
                ],
              ),
            ),
            Divider(
                height: 1,
                thickness: 1,
                color: theme.dividerColor.withOpacity(0.6)),
            // 通告内容：竖直可滚动
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: UbbText(data: bigPaper),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTopicList(List<StandardPost> posts){
    if (hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(FluentIcons.music_note_1_24_regular, size: 64, color: ColorTokens.primaryLight),
            const SizedBox(height: 16),
            Text(errorMessage),
            const SizedBox(height: 16),
            HyperlinkButton(onPressed: () => getTopic(),text: "刷新",icon:FluentIcons.arrow_sync_16_regular ,)
          ],
        ),
      );
    }
    //占位组件
    
    return Expanded(
      child: ListView.builder(
        itemCount: posts.length,
        shrinkWrap: true,
        itemBuilder:(context,index){
          return buildTopicCard(posts[index]);
        } ),
    );
  }

  Widget buildTopicCard(StandardPost post){
    return Card(
    key: ValueKey(post.id),
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
            SizedBox(width: 6),
            Text(post.userName,style:TextStyle(fontSize: 12) ,)      
          ],
        ),
      ),
    ),
  );
  }
}

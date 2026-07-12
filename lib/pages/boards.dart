import 'package:cc98_ocean/controls/adaptive_divider.dart';
import 'package:cc98_ocean/controls/info_indicator.dart';
import 'package:cc98_ocean/controls/status_title.dart';
import 'package:cc98_ocean/core/models/board.dart';
import 'package:cc98_ocean/core/services/board_service.dart';
import 'package:cc98_ocean/pages/board.dart';
import 'package:cc98_ocean/controls/fluent_iconbutton.dart';
import 'package:cc98_ocean/core/constants/color_tokens.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

class Boards extends StatefulWidget {
  const Boards({super.key});

  @override
  State<Boards> createState() => _BoardsState();
}

class _BoardsState extends State<Boards> 
{
  bool isLoading = true;
  bool hasError = false;
  String errorMessage="";
  List<BoardSection> sections=[];

  @override
  void initState() {
    super.initState();
    getSections();
  }

  Future<void> getSections()async{
    setState(() {
      sections.clear();
      isLoading = true;
      hasError = false;
    });

  final result = await BoardService().getAllBoards();
  if (result.isError) {
    setState(() {
      isLoading = false;
      hasError = true;
      errorMessage = result.error!.message;
    });
  } else {
    setState(() {
      sections.addAll(result.data!);
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
        automaticallyImplyLeading: false,
        titleSpacing: 8,
        actions: [
          FluentIconbutton(icon: FluentIcons.arrow_sync_16_regular,iconColor: ColorTokens.softPurple,),
        ],
        title: StatusTitle(title: "全部版面",isLoading: isLoading,onTap: getSections)
      ),
      body: buildLayout(),
    );
  }
  
  Widget buildLayout(){
    if (hasError)return ErrorIndicator(icon: FluentIcons.music_note_2_16_regular, info: errorMessage,onTapped: getSections);
    return Column(
      children: [
        // 回复列表
        Expanded(
          child: ListView.builder(
            itemCount: sections.length,
            
            itemBuilder: (context, index) {
              return buildSection(sections[index]);
  
            },
          ),
        ),
      ],
    );

    
  }
  Widget buildSection(BoardSection section){
    return Card(
      elevation: 0,
      surfaceTintColor: ColorTokens.softPurple,
      shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
          title: Text(section.name,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
        ),
        Divider(height: 6, thickness: 1,color: Theme.of(context).dividerColor),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12,horizontal: 8),
          child: Wrap(
            runAlignment: WrapAlignment.start,
            alignment: WrapAlignment.start,
            runSpacing: 8,
            spacing: 6,
            children: section.boards.map((e)=>buildBoardCard(e)).toList(),
          ),
        )
        ],
      ),
    );
  }
  Widget buildBoardCard(BoardInfo info){
    return TextButton(onPressed: ()=>{
      Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Board(boardId: info.id),
            ),
      )
    }, 
    style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
                side: BorderSide(color:Theme.of(context).brightness==Brightness.light? ColorTokens.dividerBlue:ColorTokens.dividerGrey)
              ),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
    
    child: Text(info.name));
  }
}
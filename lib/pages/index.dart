import 'package:cc98_ocean/controls/fluent_iconbutton.dart';
import 'package:cc98_ocean/controls/info_indicator.dart';
import 'package:cc98_ocean/controls/pivot.dart';
import 'package:cc98_ocean/controls/portrait_oval.dart';
import 'package:cc98_ocean/controls/search_bar.dart';
import 'package:cc98_ocean/controls/tag_box.dart';
import 'package:cc98_ocean/core/constants/color_tokens.dart';
import 'package:cc98_ocean/core/constants/section_info.dart';
import 'package:cc98_ocean/core/models/post.dart';
import 'package:cc98_ocean/core/models/section.dart';
import 'package:cc98_ocean/core/network/result.dart';
import 'package:cc98_ocean/core/services/post_service.dart';
import 'package:cc98_ocean/core/services/user_service.dart';
import 'package:cc98_ocean/pages/mailbox.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';


class Index extends StatefulWidget {
  const Index({super.key});

  @override
  State<Index> createState() => _IndexState();
}

class _IndexState extends State<Index> {
  List<IndexSection> sections = [];
  int selectedSection = 0;
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    getPosts();
  }

  Future<void> getPosts() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    final result = await PostService().getHotIndex();
    if (result.isError) {
      setState(() {
        hasError = true;
        errorMessage = result.error!.message;
        isLoading = false;
      });
    } else {
      final data = result.data!;
      sections.clear();
      for (var sectionInfo in ConstantItems.sectionList) {
        String key = sectionInfo.jsonPropertyName;
        final List<dynamic> sectionPosts = data[key] ?? [];
        final List<Map<String, dynamic>> sectionData =
            List<Map<String, dynamic>>.from(sectionPosts);
        List<HotPost> posts = sectionData.map((json) => HotPost.fromJson(json)).toList();
        sections.add(IndexSection.fromJson(key, posts));
      }
      isLoading = false;
      await loadPortrait(0);
    }
  }

  Future<void> loadPortrait(int index) async {
    if (sections.isEmpty) return;
    if (!sections[selectedSection].portraitLoaded) {
      await UserService().enrichPortraits(
        sections[selectedSection].posts,
        (p) => p.authorUserId,
        (p, url) => p.portraitUrl = url,
      );
      setState(() {
        sections[selectedSection].portraitLoaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: buildLayout());
  }

  Widget buildLayout() {
    if (!isLoading && (sections.isEmpty || sections.length < selectedSection + 1))
      return ErrorIndicator(
          icon: FluentIcons.music_note_1_20_regular,
          info: "暂无帖子，点击刷新",
          onTapped: getPosts);
    if (hasError)
      return ErrorIndicator(
          icon: FluentIcons.music_note_2_16_regular,
          info: errorMessage,
          onTapped: getPosts);
    return Column(
      children: [
        builldAppBar(),
        buildPivot(),
        Divider(
            height: 0.2,
            thickness: 0.2,
            color: Theme.of(context).primaryColor),
        if (!isLoading) buildSection(sections[selectedSection]),
      ],
    );
  }

  Widget builldAppBar() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        spacing: 10,
        children: [
          FlutterLogo(),
          Expanded(child: SimpleCapsuleSearchBar(hintText: "CC98,My home")),
          FluentIconbutton(icon: FluentIcons.gift_open_16_regular),
          FluentIconbutton(
            icon: FluentIcons.mail_16_regular,
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => Mailbox()));
            },
          ),
        ],
      ),
    );
  }

  Widget buildPivot() {
    return PivotTabBar(
      tabs: ConstantItems.sectionList.map((s) => s.description).toList(),
      indicatorColor: ColorTokens.softPurple,
      selectedIndex: selectedSection,
      onTabSelected: (index) {
        setState(() {
          selectedSection = index;
        });
        loadPortrait(index);
      },
      indicatorHeight: 3.0,
      indicatorWidth: 50.0,
      tabWidth: 88,
      tabSpacing: 4.0,
      selectedTextStyle: const TextStyle(
        fontSize: 16.0,
        fontWeight: FontWeight.bold,
      ),
      unselectedTextStyle: const TextStyle(
        fontSize: 16.0,
        color: Colors.grey,
      ),
    );
  }

  Widget buildSection(IndexSection section) {
    return Expanded(
      child: ListView.separated(
        separatorBuilder: (context, index) => Divider(
            height: 6,
            thickness: 1,
            color: Theme.of(context).dividerColor),
        itemCount: section.posts.length,
        itemBuilder: (context, index) =>
            buildPostItem(section.posts[index],
                key: ValueKey(section.posts[index].id)),
      ),
    );
  }

  Widget buildPostItem(HotPost post, {Key? key}) {
    return Card(
      key: key,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Column(
          spacing: 8,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 4,
                  children: [
                    PortraitOval(url: post.portraitUrl),
                    Text(post.authorName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: ColorTokens.softPink,
                        )),
                  ],
                ),
                if (post.boardName.isNotEmpty)
                  TextTagBox(
                    text: post.boardName,
                    backgroundColor:
                        Theme.of(context).colorScheme.secondaryContainer,
                    borderRadius: 4,
                    textColor: Theme.of(context).primaryColor,
                    textStyle: TextStyle(fontSize: 12),
                  ),
              ],
            ),
            Text(post.title, maxLines: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("${post.replyCount}回复·${post.hitCount}浏览",
                    style:
                        TextStyle(fontSize: 12, color: ColorTokens.softGrey)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

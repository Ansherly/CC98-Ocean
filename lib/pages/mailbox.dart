import 'package:cc98_ocean/controls/clickarea.dart';
import 'package:cc98_ocean/controls/fluent_iconbutton.dart';
import 'package:cc98_ocean/controls/info_indicator.dart';
import 'package:cc98_ocean/controls/portrait_oval.dart';
import 'package:cc98_ocean/controls/segmented.dart';
import 'package:cc98_ocean/controls/status_title.dart';
import 'package:cc98_ocean/core/helper.dart';
import 'package:cc98_ocean/core/models/message.dart';
import 'package:cc98_ocean/core/models/user.dart';
import 'package:cc98_ocean/core/network/api_client.dart';
import 'package:cc98_ocean/core/network/api_endpoints.dart';
import 'package:cc98_ocean/core/services/post_service.dart';
import 'package:cc98_ocean/core/services/user_service.dart';
import 'package:cc98_ocean/pages/chat.dart';
import 'package:cc98_ocean/pages/topic.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum MailType {
  message,
  comments,
  systemNotification,
}

class Mailbox extends StatefulWidget {
  const Mailbox({super.key});

  @override
  State<Mailbox> createState() => _MailboxState();
}

class _MailboxState extends State<Mailbox> {
  final _userService = UserService();
  final _postService = PostService();
  Map<MailType, List<dynamic>> dataMap = {
    MailType.message: <Contact>[],
    MailType.comments: <NotificationItem>[],
    MailType.systemNotification: <NotificationItem>[],
  };
  // 通知主题标题缓存（topicId → title）
  Map<int, String> topicTitles = {};
  // 通知人头像缓存（userId → url）
  Map<int, String> portraits = {};
  bool isLoading = false;
  bool hasError = false;
  MailType currentMailType = MailType.message;
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
    getRecentContact();
  }

  Future<void> getRecentContact() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    final result = currentMailType == MailType.message
        ? await _userService.getContacts()
        : await _userService.getNotifications(
            currentMailType == MailType.systemNotification
                ? 'system'
                : 'reply',
            0);
    if (result.isError) {
      setState(() {
        hasError = true;
        errorMessage = result.error!.message;
        isLoading = false;
      });
    } else {
      final parsed = await parseMail(currentMailType, result.data!);
      setState(() {
        dataMap[currentMailType]?.clear();
        dataMap[currentMailType]?.addAll(parsed);
        isLoading = false;
      });
    }
  }

  /// 通知数据补齐：批量拉取主题标题 + 通知人头像。
  Future<void> enrichNotifications(List<NotificationItem> items) async {
    final userIds =
        items.map((n) => n.postBasicInfo.userId).where((id) => id > 0).toSet().toList();
    if (userIds.isNotEmpty) {
      final portraitResult = await ApiClient.instance.getTyped<List<dynamic>>(
        ApiEndpoints.basicUserInfoList(
            userIds.map((id) => 'id=$id').join('&')),
        fromJson: (json) => json as List<dynamic>,
      );
      if (!portraitResult.isError) {
        for (final e in portraitResult.data!) {
          final user = SimpleUserInfo.fromJson(e as Map<String, dynamic>);
          portraits[user.userId] = user.portraitUrl;
        }
      }
    }

    final topicIds = items
        .map((n) => n.topicId)
        .where((id) => id > 0 && !topicTitles.containsKey(id))
        .toSet()
        .toList();
    if (topicIds.isNotEmpty) {
      final titleResult = await _postService.getBasicTopicInfos(topicIds);
      if (!titleResult.isError) {
        for (final t in titleResult.data!) {
          topicTitles[t.id] = t.title;
        }
      }
    }
  }

  Future<List<dynamic>> parseMail(MailType type, List<dynamic> list) async {
    switch (type) {
      case MailType.message:
        final data = list
            .map((e) => Contact.fromJson(e as Map<String, dynamic>))
            .toList();
        // 批量补充联系人头像和名称
        await _userService.enrichPortraits(
          data,
          (c) => c.id,
          (c, url) => c.portraitUrl = url,
        );
        // 补充联系人名称
        final userIds = data.map((e) => e.id).toList();
        final portResult = await ApiClient.instance.getTyped<List<dynamic>>(
          ApiEndpoints.basicUserInfoList(
              userIds.map((id) => 'id=$id').join('&')),
          fromJson: (json) => json as List<dynamic>,
        );
        if (!portResult.isError) {
          final userInfoList = portResult.data!
              .map((e) =>
                  SimpleUserInfo.fromJson(e as Map<String, dynamic>))
              .toList();
          for (final e in data) {
            final match = userInfoList.cast<SimpleUserInfo?>().firstWhere(
                  (u) => u?.userId == e.id,
                  orElse: () => null,
                );
            if (match != null) {
              e.name = match.userName;
            }
          }
        }
        return data;
      case MailType.comments:
      case MailType.systemNotification:
        final data = list
            .map((e) =>
                NotificationItem.fromJson(e as Map<String, dynamic>))
            .toList();
        await enrichNotifications(data);
        return data;
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
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: FluentIconbutton(
            icon: FluentIcons.chevron_left_16_regular,
            onPressed: () => Navigator.maybePop(context),
          ),
        ),
        title: StatusTitle(
            title: "消息",
            isLoading: isLoading,
            onTap: getRecentContact),
      ),
      body: buildLayout(),
    );
  }

  Widget buildLayout() {
    if (!isLoading && dataMap[currentMailType]!.isEmpty)
      return ErrorIndicator(
          icon: FluentIcons.music_note_1_20_regular,
          info: "暂无消息，点击刷新",
          onTapped: getRecentContact);
    if (hasError)
      return ErrorIndicator(
          icon: FluentIcons.music_note_2_16_regular,
          info: errorMessage,
          onTapped: getRecentContact);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: SegmentedControl(
            items: ["私信", "系统消息", "@我的"],
            onSelected: (i) {
              setState(() {
                currentMailType = MailType.values[i];
              });
              getRecentContact();
            },
          ),
        ),
        Expanded(child: buildMailList()),
      ],
    );
  }

  Widget buildMailList() {
    switch (currentMailType) {
      case MailType.message:
        return ListView.separated(
          itemBuilder: (_, i) =>
              buildMailCard((dataMap[currentMailType] as List<Contact>)[i]),
          separatorBuilder: (_, i) => Divider(
              indent: 60,
              height: 6,
              thickness: 1,
              color: Theme.of(context).dividerColor),
          itemCount: dataMap[currentMailType]!.length,
        );
      case MailType.comments:
        return ListView.separated(
          itemBuilder: (_, i) => buildNotificationCard(
              (dataMap[currentMailType] as List<NotificationItem>)[i]),
          separatorBuilder: (_, i) => Divider(
              height: 6,
              thickness: 1,
              color: Theme.of(context).dividerColor),
          itemCount: dataMap[currentMailType]!.length,
        );
      case MailType.systemNotification:
        return ListView.separated(
          itemBuilder: (_, i) => buildNotificationCard(
              (dataMap[currentMailType] as List<NotificationItem>)[i]),
          separatorBuilder: (_, i) => Divider(
              height: 6,
              thickness: 1,
              color: Theme.of(context).dividerColor),
          itemCount: dataMap[currentMailType]!.length,
        );
    }
  }

  Widget buildMailCard(Contact contact) {
    return ClickArea(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  Chat(senderId: contact.id, senderName: contact.name))),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            SizedBox(
              height: 36,
              width: 36,
              child: PortraitOval(url: contact.portraitUrl),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(contact.name,
                          style: const TextStyle(fontSize: 14)),
                      Text(
                        DateFormat('yyyy-MM-dd').format(
                          DateTime.parse(contact.time)
                              .add(const Duration(hours: 8)),
                        ),
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 10),
                      ),
                    ],
                  ),
                  SizedBox(height: 2),
                  Text(contact.lastContent,
                      style: const TextStyle(
                          color: Colors.grey, fontSize: 12),
                      maxLines: 1),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildNotificationCard(NotificationItem item) {
    final title = topicTitles[item.topicId];
    final floor = item.postBasicInfo.floor;
    final action =
        currentMailType == MailType.systemNotification ? '系统消息' : '回复了你';
    final description = item.postBasicInfo.isDeleted
        ? '该回复已被删除'
        : (title != null ? '在帖子《$title》的${floor}L$action' : '在CC${item.topicId}中$action');
    return ClickArea(
      onTap: item.topicId > 0
          ? () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => Topic(topicId: item.topicId)))
          : null,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            SizedBox(
              height: 36,
              width: 36,
              child: PortraitOval(
                  url: portraits[item.postBasicInfo.userId] ?? ""),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(item.postBasicInfo.userName,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold)),
                      Text(item.time.toUtc8,
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 10)),
                    ],
                  ),
                  SizedBox(height: 6),
                  Text(description,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

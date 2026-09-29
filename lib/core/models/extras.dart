/// 新增功能的轻量模型（收藏夹 / 投票 / 风评 / 通知计数 / 抽卡等）。
/// 均使用容错手写 fromJson，与现有模型风格一致。

int _toInt(dynamic v) => (v as num?)?.toInt() ?? 0;
String _toStr(dynamic v) => v as String? ?? '';
bool _toBool(dynamic v) => v as bool? ?? false;
List<dynamic> _toList(dynamic v) => v as List<dynamic>? ?? [];

/// 收藏夹（GET /me/favorite-topic-group）。
class FavoriteGroup {
  final int id;
  final String name;

  const FavoriteGroup({required this.id, required this.name});

  /// 响应可能为 {data: [...]} 或裸数组，两种形式都兼容。
  static List<FavoriteGroup> listFromJson(dynamic json) {
    final raw = json is Map<String, dynamic> ? json['data'] : json;
    return _toList(raw)
        .whereType<Map<String, dynamic>>()
        .map(FavoriteGroup.fromJson)
        .toList();
  }

  factory FavoriteGroup.fromJson(Map<String, dynamic> json) => FavoriteGroup(
        id: _toInt(json['id']),
        name: _toStr(json['name']),
      );
}

/// 精简主题信息（收藏列表 / 浏览历史等）。
class SimpleTopicInfo {
  final int id;
  final String title;
  final int userId;
  final String userName;
  final int boardId;
  final String boardName;
  final bool isAnonymous;
  final int hitCount;
  final int replyCount;
  final String time;
  final String lastBrowsingTime;

  SimpleTopicInfo({
    required this.id,
    required this.title,
    required this.userId,
    required this.userName,
    required this.boardId,
    required this.boardName,
    required this.isAnonymous,
    required this.hitCount,
    required this.replyCount,
    required this.time,
    required this.lastBrowsingTime,
  });

  static List<SimpleTopicInfo> listFromJson(dynamic json) {
    final raw = json is Map<String, dynamic> ? json['data'] : json;
    return _toList(raw)
        .whereType<Map<String, dynamic>>()
        .map(SimpleTopicInfo.fromJson)
        .toList();
  }

  factory SimpleTopicInfo.fromJson(Map<String, dynamic> json) =>
      SimpleTopicInfo(
        id: _toInt(json['id']),
        title: _toStr(json['title']),
        userId: _toInt(json['userId']),
        userName: _toStr(json['userName']),
        boardId: _toInt(json['boardId']),
        boardName: _toStr(json['boardName']),
        isAnonymous: _toBool(json['isAnonymous']),
        hitCount: _toInt(json['hitCount']),
        replyCount: _toInt(json['replyCount']),
        time: _toStr(json['time']),
        lastBrowsingTime: _toStr(json['lastBrowsingTime']),
      );
}

/// 投票项。
class VoteItem {
  final int id;
  final int count;
  final String description;

  const VoteItem({
    required this.id,
    required this.count,
    required this.description,
  });

  factory VoteItem.fromJson(Map<String, dynamic> json) => VoteItem(
        id: _toInt(json['id']),
        count: _toInt(json['count']),
        description: _toStr(json['description']),
      );
}

/// 投票信息（GET /topic/{id}/vote）。
class VoteInfo {
  final List<int> myRecord;
  final List<VoteItem> voteItems;
  final bool canVote;
  final bool isAvailable;
  final int maxVoteCount;
  final String expiredTime;
  final int voteUserCount;

  const VoteInfo({
    required this.myRecord,
    required this.voteItems,
    required this.canVote,
    required this.isAvailable,
    required this.maxVoteCount,
    required this.expiredTime,
    required this.voteUserCount,
  });

  factory VoteInfo.fromJson(Map<String, dynamic> json) => VoteInfo(
        myRecord: _toList(json['myRecord']).map((e) => _toInt(e)).toList(),
        voteItems: _toList(json['voteItems'])
            .whereType<Map<String, dynamic>>()
            .map(VoteItem.fromJson)
            .toList(),
        canVote: _toBool(json['canVote']),
        isAvailable: _toBool(json['isAvailable']),
        maxVoteCount: _toInt(json['maxVoteCount']),
        expiredTime: _toStr(json['expiredTime']),
        voteUserCount: _toInt(json['voteUserCount']),
      );
}

/// 风评理由（GET /post/rating-reason?type=）。
class RatingReason {
  final bool enabled;
  final String reason;
  final int id;
  final int type;

  const RatingReason({
    required this.enabled,
    required this.reason,
    required this.id,
    required this.type,
  });

  static List<RatingReason> listFromJson(dynamic json) => _toList(json)
      .whereType<Map<String, dynamic>>()
      .map(RatingReason.fromJson)
      .toList();

  factory RatingReason.fromJson(Map<String, dynamic> json) => RatingReason(
        enabled: _toBool(json['enabled']),
        reason: _toStr(json['reason']),
        id: _toInt(json['id']),
        type: _toInt(json['type']),
      );
}

/// 未读消息计数（GET /me/unread-count）。
class UnreadMessageInfo {
  final int messageCount;
  final int replyCount;
  final int atCount;
  final int systemCount;

  const UnreadMessageInfo({
    required this.messageCount,
    required this.replyCount,
    required this.atCount,
    required this.systemCount,
  });

  int get total => messageCount + replyCount + atCount + systemCount;

  factory UnreadMessageInfo.fromJson(Map<String, dynamic> json) =>
      UnreadMessageInfo(
        messageCount: _toInt(json['messageCount']),
        replyCount: _toInt(json['replyCount']),
        atCount: _toInt(json['atCount']),
        systemCount: _toInt(json['systemCount']),
      );
}

/// 主题标题（GET /topic/basic?id=1&id=2）。
class BasicTopicInfo {
  final int id;
  final String title;

  const BasicTopicInfo({required this.id, required this.title});

  factory BasicTopicInfo.fromJson(Map<String, dynamic> json) =>
      BasicTopicInfo(id: _toInt(json['id']), title: _toStr(json['title']));
}

/// 抽卡结果（POST /card/api/draw/{rule}）。
class CardInfo {
  final String name;
  final String imageUri;

  const CardInfo({required this.name, required this.imageUri});

  static List<CardInfo> listFromJson(dynamic json) => _toList(json)
      .whereType<Map<String, dynamic>>()
      .map(CardInfo.fromJson)
      .toList();

  factory CardInfo.fromJson(Map<String, dynamic> json)
      => CardInfo(name: _toStr(json['name']), imageUri: _normalizeUri(_toStr(json['imageUri'])));

  /// API 返回形如 "~/Image/xxx.webp"，补全资源域名
  static String _normalizeUri(String uri) {
    if (uri.startsWith('http')) return uri;
    if (uri.startsWith('~')) return 'https://card.cc98.org${uri.substring(1)}';
    if (uri.startsWith('/')) return 'https://card.cc98.org$uri';
    return 'https://card.cc98.org/$uri';
  }
}

/// 抽卡统计（GET /card/api/collection/stat）。
class CardStatInfo {
  final int drawCount;
  final int totalCost;
  final int totalBonus;
  final int cardCount;

  const CardStatInfo({
    required this.drawCount,
    required this.totalCost,
    required this.totalBonus,
    required this.cardCount,
  });

  factory CardStatInfo.fromJson(Map<String, dynamic> json) => CardStatInfo(
        drawCount: _toInt(json['drawCount']),
        totalCost: _toInt(json['totalCost']),
        totalBonus: _toInt(json['totalBonus']),
        cardCount: _toInt(json['cardCount']),
      );
}

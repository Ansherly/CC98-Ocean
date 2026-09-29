/// API 终结点定义。集中管理所有 API URL，通过字符串插值从基础常量派生。
///
/// 参照 [windows/Endpoints.cs] 的结构组织。
class ApiEndpoints {
  static const String _base = 'https://api.cc98.org';
  static const String _oidc = 'https://openid.cc98.org';
  static const String _card = 'https://card.cc98.org';

  ApiEndpoints._();

  // ── Forum ──────────────────────────────────────────

  static const String appCenter = _oidc;

  /// 获取所有版面信息
  static const String allBoards = '$_base/Board/all';

  /// 获取论坛首页相关数据（十大话题等）
  static const String index = '$_base/config/index';

  /// 获取抽卡统计信息
  static const String cardStat = '$_card/api/collection/stat';

  /// 获取特定抽卡规则
  static String drawCard(int ruleId) => '$_card/api/draw/$ruleId';

  /// 分解所有多余卡牌
  static const String destroyAllCards = '$_card/api/collection/all-rest';

  /// 上传文件
  static const String uploadFile = '$_base/file';

  // ── User ───────────────────────────────────────────

  /// 发送私信
  static const String sendPrivateMessage = '$_base/message';

  /// 单个用户详细信息
  static String userProfile({required bool isMe, int userId = 0}) =>
      isMe ? '$_base/me' : '$_base/user/$userId';

  /// 每日签到
  static const String signIn = '$_base/me/signin';

  /// 获取一系列用户的基本信息（含头像URL）
  ///
  /// [param] 格式: `id=1&id=2&id=3...`
  static String basicUserInfoList(String param) => '$_base/user/basic?$param';

  /// 获取一系列用户的详细信息
  ///
  /// [param] 格式: `id=1&id=2&id=3...`
  static String userInfoList(String param) => '$_base/user?$param';

  /// 获取当前用户的好友列表（返回id列表）
  static String friendList(String type, int start) =>
      '$_base/me/$type?from=$start&size=10';

  /// 获取关注用户的帖子动态
  static String moment(int start) =>
      '$_base/me/followee/topic?from=$start&size=20&order=0';

  /// 已收藏帖子的最近更新
  static String favoriteTopicUpdate(int start) =>
      '$_base/topic/me/favorite?from=$start&size=20&order=1';

  /// 收藏夹列表
  static const String favoritesList = '$_base/me/favorite-topic-group';

  /// 最近私信联系人
  static String recentChatUserList(int start) =>
      '$_base/message/recent-contact-users?from=$start&size=10';

  /// 与某用户的私信历史
  static String chatHistory(int userId, int start) =>
      '$_base/message/user/$userId?from=$start&size=10';

  /// 按用户名搜索
  static String searchUserByName(String name) => '$_base/user/name/$name';

  /// 未读消息数
  static const String unreadMessage = '$_base/me/unread-count';

  /// 系统通知
  static String systemNotice(String typeName, int start) =>
      '$_base/notification/$typeName?from=$start&size=10';

  /// 编辑好友（关注/取消关注）
  static String editFriends(int userId) => '$_base/me/followee/$userId';

  /// 财富转账
  static const String transferWealth = '$_base/me/transfer-wealth';

  /// 开关浏览历史记录
  static String enableBrowseHistory(bool value) =>
      '$_base/me/browsing-history?enabled=${value.toString().toLowerCase()}';

  /// 浏览历史记录
  static String browseHistory(int start) =>
      '$_base/me/browsing-record?from=$start&size=11';

  // ── Post ───────────────────────────────────────────

  /// 点赞状态获取 / 点赞/点踩
  static String react(int postId) => '$_base/post/$postId/like';

  /// 编辑帖子
  static String editPost(int postId) => '$_base/post/$postId';

  /// 帖子评分
  static String rate(int postId) => '$_base/post/$postId/rating-v2';

  /// 评分原因列表
  static String rateReason(int type) => '$_base/post/rating-reason?type=$type';

  // ── Board ──────────────────────────────────────────

  /// 版面基本信息
  static String boardInfo(int boardId) => '$_base/board/$boardId';

  /// 获取版面帖子列表
  static String topicList(int boardId, int start) =>
      '$_base/board/$boardId/topic?from=$start&size=20';

  /// 编辑关注版面
  static String editFocusBoards(int boardId) => '$_base/me/custom-board/$boardId';

  /// 版面网页链接
  static String boardWebUrl(int boardId) => 'https://www.cc98.org/board/$boardId';

  /// 版面发帖
  static String sendNewTopic(int boardId) => '$_base/board/$boardId/topic';

  /// 版面标签
  static String boardTags(int boardId) => '$_base/board/$boardId/tags';

  // ── Topic ──────────────────────────────────────────

  /// 用户近期发帖
  static String recentTopic({
    required bool isMe,
    required int userId,
    required int start,
  }) =>
      isMe
          ? '$_base/me/recent-topic?from=$start&size=11'
          : '$_base/user/$userId/recent-topic?userid=$userId&from=$start&size=11';

  /// 帖子基本信息
  static String topicInfo(int topicId) => '$_base/topic/$topicId';

  /// 是否已收藏
  static String isFavorite(int topicId) => '$_base/topic/$topicId/isfavorite';

  /// 帖子回复列表
  static String replyList(int topicId, int start) =>
      '$_base/Topic/$topicId/post?from=$start&size=10';

  /// 最新帖子列表
  static String newTopicList(int start) => '$_base/topic/new?from=$start&size=20';

  /// 随机帖子列表
  static String randomTopicList() => '$_base/topic/random-recent?size=10';

  /// 搜索帖子
  static String searchTopic(String key, int start) =>
      '$_base/topic/search?keyword=$key&from=$start&size=20';

  /// 收藏帖子列表
  static String favoriteTopicList(int start, int order, int groupId) =>
      '$_base/topic/me/favorite?from=$start&size=11&order=$order&groupid=$groupId';

  /// 投票
  static String vote(int topicId) => '$_base/topic/$topicId/vote';

  /// 添加收藏
  static String addIntoFavorites(int topicId, int groupId) =>
      '$_base/me/favorite/$topicId?groupid=$groupId';

  /// 取消收藏
  static String deleteFavoriteTopic(int topicId) =>
      '$_base/me/favorite/$topicId';

  /// 版面内搜索（keyword 需 UrlEncode）
  static String searchTopicInBoard(int boardId, String key, int start) =>
      '$_base/topic/search/board/$boardId?keyword=$key&from=$start&size=20';

  /// 批量获取帖子基本信息
  static String basicTopicInfoList(String param) => '$_base/topic/basic?$param';

  /// 发送回复
  static String sendReply(int topicId) => '$_base/topic/$topicId/post';

  // ── OpenId ─────────────────────────────────────────

  static const String openIdEndpoint = _oidc;

  /// 鉴权服务起点，用于产生跳转URL
  static String authorizeUrl() => '$_oidc/connect/authorize';

  /// 令牌获取地址（返回包含 access_token, refresh_token 的 JSON）
  static const String tokenEndpoint = '$_oidc/connect/token';
}

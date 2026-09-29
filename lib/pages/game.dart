import 'package:cc98_ocean/controls/fluent_dialog.dart';
import 'package:cc98_ocean/controls/fluent_iconbutton.dart';
import 'package:cc98_ocean/controls/info_flower.dart';
import 'package:cc98_ocean/controls/status_title.dart';
import 'package:cc98_ocean/core/constants/color_tokens.dart';
import 'package:cc98_ocean/core/models/extras.dart';
import 'package:cc98_ocean/core/network/api_client.dart';
import 'package:cc98_ocean/core/network/api_endpoints.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

/// 抽卡页（对应 C# GamePage）。
///
/// 规则 1 = 单抽，规则 2 = 十连（11 张）；扣费为真实 API 调用。
class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  final _api = ApiClient.instance;

  int wealth = 0;
  CardStatInfo stat =
      const CardStatInfo(drawCount: 0, totalCost: 0, totalBonus: 0, cardCount: 0);
  List<CardInfo> cards = [];
  bool _isDrawing = false;

  @override
  void initState() {
    super.initState();
    _refreshStat();
  }

  Future<void> _refreshStat() async {
    // 财富与抽卡统计互不依赖，并行发起
    final profileResult = await _api.getTyped<Map<String, dynamic>>(
        ApiEndpoints.userProfile(isMe: true),
        fromJson: (json) => json as Map<String, dynamic>);
    final statResult = await _api.getTyped<CardStatInfo>(
        ApiEndpoints.cardStat,
        fromJson: (json) => CardStatInfo.fromJson(json as Map<String, dynamic>));
    if (!mounted) return;
    setState(() {
      if (!profileResult.isError) {
        wealth = (profileResult.data!['wealth'] as num?)?.toInt() ?? 0;
      }
      if (!statResult.isError) stat = statResult.data!;
    });
  }

  Future<void> _draw(int rule) async {
    if (_isDrawing) return; // 抽卡扣费，防连点
    setState(() {
      _isDrawing = true;
      cards = [];
    });
    try {
      final response =
          await _api.post(ApiEndpoints.drawCard(rule), data: '');
      if (response.statusCode != 200) {
        throw StateError('抽卡失败 (HTTP ${response.statusCode})');
      }
      final drawn = CardInfo.listFromJson(response.data);
      if (!mounted) return;
      setState(() => cards = drawn);
    } catch (e) {
      if (mounted) {
        InfoFlower.show(context,
            icon: FluentIcons.error_circle_16_regular, text: '抽卡失败');
      }
    } finally {
      if (mounted) setState(() => _isDrawing = false);
      _refreshStat();
    }
  }

  Future<void> _destroyAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const FluentDialog(
        title: '分解所有卡牌',
        content: Text('将分解所有多余的卡牌并转化为财富值，是否继续？'),
        confirmText: '分解',
      ),
    );
    if (confirmed != true) return;
    try {
      final response = await _api.delete(ApiEndpoints.destroyAllCards);
      if (!mounted) return;
      if (response.statusCode == 200) {
        InfoFlower.show(context,
            icon: FluentIcons.checkmark_circle_16_regular, text: '分解成功');
        _refreshStat();
      } else {
        InfoFlower.show(context,
            icon: FluentIcons.error_circle_16_regular, text: '分解失败');
      }
    } catch (_) {
      if (mounted) {
        InfoFlower.show(context,
            icon: FluentIcons.error_circle_16_regular, text: '分解失败');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 48,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        actionsPadding: const EdgeInsets.only(right: 13),
        leading: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: FluentIconbutton(
            icon: FluentIcons.chevron_left_16_regular,
            onPressed: () => Navigator.maybePop(context),
          ),
        ),
        actions: [
          FluentIconbutton(
            icon: FluentIcons.arrow_sync_16_regular,
            iconColor: ColorTokens.softPurple,
            onPressed: () {
              _refreshStat();
              InfoFlower.show(context,
                  icon: FluentIcons.checkmark_circle_16_regular,
                  text: '正在刷新数据');
            },
          ),
        ],
        title: const StatusTitle(title: '抽卡小屋'),
      ),
      body: buildLayout(),
    );
  }

  Widget buildLayout() {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        buildStatCard(),
        const SizedBox(height: 12),
        buildDrawButtons(),
        const SizedBox(height: 12),
        if (_isDrawing)
          const Padding(
            padding: EdgeInsets.all(48),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (cards.isNotEmpty)
          buildCardGrid(),
      ],
    );
  }

  Widget buildStatCard() {
    return Card(
      elevation: 0,
      color: Theme.of(context).brightness == Brightness.light
          ? ColorTokens.dividerBlue
          : ColorTokens.darkGrey,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _statItem('财富', '$wealth'),
            _statItem('抽卡次数', '${stat.drawCount}'),
            _statItem('持有卡牌', '${stat.cardCount}'),
            _statItem('总收益', '${stat.totalBonus - stat.totalCost}'),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String label, String value) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: ColorTokens.primaryLight)),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(fontSize: 12, color: ColorTokens.softGrey)),
      ],
    );
  }

  Widget buildDrawButtons() {
    return Row(
      spacing: 12,
      children: [
        Expanded(
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: ColorTokens.softPurple,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: _isDrawing ? null : () => _draw(1),
            icon: Icon(FluentIcons.card_ui_20_regular, size: 18),
            label: const Text('单抽'),
          ),
        ),
        Expanded(
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: ColorTokens.softPink,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: _isDrawing ? null : () => _draw(2),
            icon: const Icon(FluentIcons.apps_16_regular, size: 18),
            label: const Text('十连抽'),
          ),
        ),
        FluentIconbutton(
          icon: FluentIcons.delete_16_regular,
          tooltip: '分解所有多余卡牌',
          onPressed: _destroyAll,
        ),
      ],
    );
  }

  Widget buildCardGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cards.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.72,
      ),
      itemBuilder: (_, i) => buildCard(cards[i]),
    );
  }

  Widget buildCard(CardInfo card) {
    return Column(
      children: [
        Expanded(
          child: Card(
            elevation: 2,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
            child: Image.network(
              card.imageUri,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Center(
                  child: Icon(FluentIcons.image_16_regular, size: 24)),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(card.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}

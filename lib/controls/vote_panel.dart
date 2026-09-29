import 'package:cc98_ocean/controls/info_flower.dart';
import 'package:cc98_ocean/core/models/extras.dart';
import 'package:cc98_ocean/core/services/post_service.dart';
import 'package:cc98_ocean/core/constants/color_tokens.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

/// 投票面板（对应 C# TopicPage 的 VotePanel TeachingTip）。
///
/// 以对话框内容的形式展示投票项，支持多选（受票数限制）、
/// 回填我的投票记录、过期/已投票状态置灰。
class VotePanel extends StatefulWidget {
  final int topicId;

  const VotePanel({super.key, required this.topicId});

  /// 以对话框形式弹出；返回 true 表示投票已提交成功。
  static Future<bool> show(BuildContext context, int topicId) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: VotePanel(topicId: topicId),
        ),
      ),
    );
    return result ?? false;
  }

  @override
  State<VotePanel> createState() => _VotePanelState();
}

class _VotePanelState extends State<VotePanel> {
  final _postService = PostService();
  VoteInfo? _info;
  bool _isLoading = true;
  bool _isSubmitting = false;
  String _error = '';
  final Set<int> _selected = {}; // 选中项的 1-based 序号

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });
    final result = await _postService.getVoteInfo(widget.topicId);
    if (result.isError) {
      setState(() {
        _error = result.error!.message;
        _isLoading = false;
      });
      return;
    }
    final info = result.data!;
    setState(() {
      _info = info;
      _isLoading = false;
      // 回填我的投票记录（1-based）
      _selected.addAll(info.myRecord);
    });
  }

  bool get _canSubmit {
    final info = _info;
    if (info == null) return false;
    return info.canVote && info.isAvailable && _selected.isNotEmpty;
  }

  String get _title {
    final info = _info;
    if (info == null) return '投票';
    if (!info.isAvailable) return '投票（已过期）';
    if (!info.canVote) return '投票（已投票）';
    return '投票（开放中）';
  }

  Future<void> _submit() async {
    if (_selected.isEmpty) {
      InfoFlower.showContent(context, child: const Text('请至少选择一项'));
      return;
    }
    setState(() => _isSubmitting = true);
    final result = await _postService.sendVote(widget.topicId, _selected.toList());
    setState(() => _isSubmitting = false);
    if (!mounted) return;
    if (result.success) {
      Navigator.pop(context, true);
    } else {
      InfoFlower.showContent(context, child: Text(result.message ?? '投票失败'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(FluentIcons.poll_16_regular,
                    size: 18, color: ColorTokens.softPurple),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(_title,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                ),
                IconButton(
                  icon: const Icon(FluentIcons.dismiss_16_regular, size: 16),
                  onPressed: () => Navigator.pop(context, false),
                ),
              ],
            ),
            const Divider(height: 16),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text('加载投票信息失败：$_error',
                    style: TextStyle(color: theme.colorScheme.error)),
              )
            else ...[
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var i = 0; i < _info!.voteItems.length; i++)
                        _buildVoteItem(i + 1, _info!.voteItems[i]),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '过期时间：${_info!.expiredTime}\n'
                '参与人数：${_info!.voteUserCount}，票数限制：${_info!.maxVoteCount}',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 12),
              FilledButton(
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6)),
                ),
                onPressed:
                    _canSubmit && !_isSubmitting ? _submit : null,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('投票'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVoteItem(int index, VoteItem item) {
    final info = _info!;
    final canSelect = info.canVote && info.isAvailable;
    final isSelected = _selected.contains(index);
    final theme = Theme.of(context);
    final maxSelected = _selected.length >= info.maxVoteCount;

    return InkWell(
      borderRadius: BorderRadius.circular(6),
      onTap: canSelect
          ? () {
              setState(() {
                if (isSelected) {
                  _selected.remove(index);
                } else if (!maxSelected) {
                  _selected.add(index);
                }
              });
            }
          : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? FluentIcons.checkbox_checked_16_filled
                  : FluentIcons.checkbox_unchecked_16_regular,
              size: 18,
              color: isSelected
                  ? theme.colorScheme.primary
                  : Colors.grey,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(item.description)),
            Text('${item.count}票',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

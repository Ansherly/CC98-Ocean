import 'package:cc98_ocean/controls/segmented.dart';
import 'package:cc98_ocean/controls/status_title.dart';
import 'package:cc98_ocean/core/constants/color_tokens.dart';
import 'package:cc98_ocean/core/models/board.dart';
import 'package:cc98_ocean/core/services/board_service.dart';
import 'package:cc98_ocean/core/services/post_service.dart';
import 'package:cc98_ocean/core/themes/setting_controller.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// 发帖编辑器（对应 C# SketchPage 的 DraftNewTopic 模式）。
///
/// [boardId] 为空时需要先从版面列表中选择目标版面。
class TopicEditorPage extends StatefulWidget {
  final int? boardId;
  final String? boardName;

  const TopicEditorPage({super.key, this.boardId, this.boardName});

  @override
  State<TopicEditorPage> createState() => _TopicEditorPageState();
}

class _TopicEditorPageState extends State<TopicEditorPage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _postService = PostService();
  final _boardService = BoardService();

  List<BoardSection> sections = [];
  int? _selectedBoardId;
  String _selectedBoardName = '';
  int _contentType = 0; // 0=UBB 1=Markdown
  bool _isAnonymous = false;
  bool _isSending = false;

  bool get useTail => Provider.of<AppState>(context, listen: false).useTail;

  @override
  void initState() {
    super.initState();
    _selectedBoardId = widget.boardId;
    _selectedBoardName = widget.boardName ?? '';
    if (widget.boardId == null) _loadBoards();
  }

  Future<void> _loadBoards() async {
    final result = await _boardService.getAllBoards();
    if (!mounted || result.isError) return;
    setState(() => sections = result.data!);
  }

  String get platform => switch (defaultTargetPlatform) {
        TargetPlatform.android => 'Android',
        TargetPlatform.iOS => 'IOS',
        TargetPlatform.windows => 'Windows',
        TargetPlatform.macOS => 'macOS',
        TargetPlatform.linux => 'Linux',
        TargetPlatform.fuchsia => 'Fuchsia',
      };

  Future<void> _send() async {
    final title = _titleController.text.trim();
    var content = _contentController.text.trim();
    if (_selectedBoardId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('请选择发布版面')));
      return;
    }
    if (title.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('标题不能为空')));
      return;
    }
    if (content.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('正文不能为空')));
      return;
    }
    if (useTail) {
      content =
          "$content\n[align=right][size=3][color=gray]——来自「[b][color=purple]CC98 For $platform[/color][/b]」[/color][/size][/align]";
    }

    setState(() => _isSending = true);
    final result = await _postService.sendNewTopic(_selectedBoardId!, {
      "clientType": 1,
      "content": content,
      "contentType": _contentType,
      "isAnonymous": _isAnonymous,
      "notifyPoster": false,
      "title": title,
      "type": 0,
    });
    if (!mounted) return;
    setState(() => _isSending = false);
    if (result.success) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('发送失败：${result.message ?? "未知错误"}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 48,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        actionsPadding: const EdgeInsets.only(right: 13),
        leading: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: IconButton(
            icon: const Icon(FluentIcons.chevron_left_16_regular),
            onPressed: () => Navigator.maybePop(context),
          ),
        ),
        actions: [
          TextButton.icon(
            style: TextButton.styleFrom(
              foregroundColor: ColorTokens.softPurple,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6)),
            ),
            onPressed: _isSending ? null : _send,
            icon: _isSending
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(FluentIcons.send_16_regular, size: 16),
            label: const Text('发布'),
          ),
        ],
        title: const StatusTitle(title: '发布新主题'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            spacing: 10,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              buildBoardSelector(theme),
              TextField(
                controller: _titleController,
                maxLength: 100,
                decoration: InputDecoration(
                  hintText: '标题',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6)),
                  isDense: true,
                ),
              ),
              SegmentedControl(
                items: const ['UBB', 'Markdown'],
                initialIndex: _contentType,
                onSelected: (i) => setState(() => _contentType = i),
              ),
              Expanded(
                child: TextField(
                  controller: _contentController,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    hintText: '正文…（支持${_contentType == 0 ? "UBB" : "Markdown"}语法）',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6)),
                  ),
                ),
              ),
              Row(
                children: [
                  Icon(FluentIcons.eye_off_16_regular,
                      size: 14, color: Colors.grey),
                  const SizedBox(width: 6),
                  const Text('匿名发布', style: TextStyle(fontSize: 13)),
                  const Spacer(),
                  Switch(
                    value: _isAnonymous,
                    onChanged: (v) => setState(() => _isAnonymous = v),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildBoardSelector(ThemeData theme) {
    if (_selectedBoardId != null && sections.isEmpty) {
      return Row(
        children: [
          const Icon(FluentIcons.board_16_regular,
              size: 16, color: ColorTokens.softPurple),
          const SizedBox(width: 8),
          Text(_selectedBoardName.isEmpty
              ? '版面 #$_selectedBoardId'
              : _selectedBoardName),
        ],
      );
    }
    if (sections.isEmpty) {
      return const Row(
        children: [
          SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2)),
          SizedBox(width: 8),
          Text('正在加载版面列表…',
              style: TextStyle(fontSize: 13, color: Colors.grey)),
        ],
      );
    }
    return DropdownButtonFormField<int>(
      value: _selectedBoardId,
      isExpanded: true,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
        isDense: true,
        prefixIcon: const Icon(FluentIcons.board_16_regular, size: 16),
      ),
      hint: const Text('选择发布版面'),
      items: [
        for (final section in sections)
          ...section.boards.map((b) => DropdownMenuItem(
                value: b.id,
                child: Text('${section.name} / ${b.name}',
                    overflow: TextOverflow.ellipsis),
              )),
      ],
      onChanged: (id) {
        if (id == null) return;
        String name = '版面 #$id';
        for (final section in sections) {
          for (final b in section.boards) {
            if (b.id == id) name = b.name;
          }
        }
        setState(() {
          _selectedBoardId = id;
          _selectedBoardName = name;
        });
      },
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}

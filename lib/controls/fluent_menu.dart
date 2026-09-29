import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

/// Fluent 风格菜单项。
class FluentMenuItem {
  final String text;
  final IconData? icon;
  final VoidCallback? onTap;

  /// 分隔线占位项（text 为空时渲染分隔线）。
  final bool isSeparator;

  /// 危险操作（红色文字）。
  final bool isDestructive;

  const FluentMenuItem({
    required this.text,
    this.icon,
    this.onTap,
    this.isSeparator = false,
    this.isDestructive = false,
  });

  const FluentMenuItem.separator()
      : this._separator();

  const FluentMenuItem._separator()
      : text = '',
        icon = null,
        onTap = null,
        isSeparator = true,
        isDestructive = false;
}

/// Fluent 风格弹出菜单按钮。
///
/// 点击 [child]（默认为 [icon]）后在下方弹出圆角浮层菜单，
/// 选中项回调 [FluentMenuItem.onTap]。
class FluentMenuButton extends StatelessWidget {
  final IconData? icon;
  final Widget? child;
  final List<FluentMenuItem> items;
  final Color? iconColor;
  final String? tooltip;

  const FluentMenuButton({
    super.key,
    this.icon,
    this.child,
    required this.items,
    this.iconColor,
    this.tooltip,
  });

  Future<void> _show(BuildContext context) async {
    final theme = Theme.of(context);
    final RenderBox button = context.findRenderObject() as RenderBox;
    final overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset(0, button.size.height),
            ancestor: overlay),
        button.localToGlobal(
            button.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    await showMenu<String>(
      context: context,
      position: position,
      color: theme.colorScheme.surface,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      constraints: const BoxConstraints(minWidth: 160, maxWidth: 260),
      items: [
        for (var i = 0; i < items.length; i++)
          if (items[i].isSeparator)
            const PopupMenuItem<String>(
              enabled: false,
              height: 8,
              child: Divider(height: 1, thickness: 1),
            )
          else
            PopupMenuItem<String>(
              value: '$i',
              height: 40,
              child: Row(
                children: [
                  if (items[i].icon != null) ...[
                    Icon(
                      items[i].icon,
                      size: 16,
                      color: items[i].isDestructive
                          ? theme.colorScheme.error
                          : theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 10),
                  ],
                  Text(
                    items[i].text,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: items[i].isDestructive
                          ? theme.colorScheme.error
                          : null,
                    ),
                  ),
                ],
              ),
            ),
      ],
    ).then((value) {
      if (value == null) return;
      final index = int.tryParse(value);
      if (index != null && index < items.length) {
        items[index].onTap?.call();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget trigger = child ??
        Icon(icon ?? FluentIcons.more_horizontal_16_regular,
            size: 18, color: iconColor ?? Theme.of(context).colorScheme.primary);
    trigger = InkWell(
      borderRadius: BorderRadius.circular(6),
      onTap: () => _show(context),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: trigger,
      ),
    );
    if (tooltip != null) {
      trigger = Tooltip(message: tooltip!, child: trigger);
    }
    return trigger;
  }
}

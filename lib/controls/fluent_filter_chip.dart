import 'package:flutter/material.dart';

/// Fluent 风格的筛选 / 选择标签（对齐 WinUI 的 ToggleButton / SelectorBar 视觉）。
///
/// 与 Material `ChoiceChip` 的区别：
/// - 选中态为「强调色 10% 浅底 + 强调色文字」，不用实心块、不用对勾图标；
/// - 未选中态为透明底 + 次要文字色（可选细描边）；
/// - 统一 4px 小圆角（WinUI 标准控件圆角），高度 32px；
/// - 无 Material 墨水扩散，悬停仅背景微加深。
///
/// 数量较多时请用 [FluentFilterChipGroup]，它会自动换行。
class FluentFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  /// 强调色（选中态的文字与背景基色），默认取主题 primary。
  final Color? accentColor;

  /// 是否显示未选中态的细描边。
  final bool outlined;

  final EdgeInsetsGeometry padding;

  const FluentFilterChip({
    super.key,
    required this.label,
    required this.selected,
    this.onTap,
    this.accentColor,
    this.outlined = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = accentColor ?? theme.colorScheme.primary;
    final radius = BorderRadius.circular(4);

    // 选中：强调色浅底 + 强调色文字；未选中：透明底 + 次要文字色
    final background = selected
        ? accent.withOpacity(0.10)
        : outlined
            ? Colors.transparent
            : theme.colorScheme.surfaceContainerHighest.withOpacity(0.4);
    final foreground =
        selected ? accent : theme.colorScheme.onSurfaceVariant;

    Border? border;
    if (outlined && !selected) {
      border = Border.all(color: theme.dividerColor.withOpacity(0.8));
    }

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        // Fluent 悬停仅背景微加深，不做墨水扩散
        hoverColor: theme.colorScheme.onSurface.withOpacity(0.05),
        splashFactory: NoSplash.splashFactory,
        highlightColor: theme.colorScheme.onSurface.withOpacity(0.03),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          height: 32,
          padding: padding,
          // 宽度贴合内容：不设 alignment（否则在有界宽度下会撑满整行）
          constraints: const BoxConstraints(minWidth: 48),
          decoration: BoxDecoration(
            color: background,
            borderRadius: radius,
            border: border,
          ),
          child: Center(
            // widthFactor 让宽度贴合内容（Wrap 中有界宽度下不撑满整行）；
            // 高度不设 factor，撑满 32px 实现竖直居中
            widthFactor: 1.0,
            child: Text(
              label,
              maxLines: 1,
              textAlign: TextAlign.center,
              // 竖直居中：主题样式自带行高会把中文字形压低，显式归一
              textHeightBehavior: const TextHeightBehavior(
                leadingDistribution: TextLeadingDistribution.even,
              ),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 13,
                height: 1.0,
                color: foreground,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Fluent 标签组：按行自动换行（Wrap），宽度不足时折到下一行。
///
/// 相比横向滚动，换行布局能让所有选项一次可见，更适合收藏夹分组、
/// 标签筛选等数量不定且需要一览的场景。
class FluentFilterChipGroup<T> extends StatelessWidget {
  final List<T> items;
  final String Function(T item) labelOf;

  /// 判定某选项是否选中。
  final bool Function(T item) isSelected;
  final ValueChanged<T> onSelected;

  final Color? accentColor;
  final bool outlined;

  /// 标签之间水平间距。
  final double spacing;

  /// 换行后各行的垂直间距。
  final double runSpacing;

  const FluentFilterChipGroup({
    super.key,
    required this.items,
    required this.labelOf,
    required this.isSelected,
    required this.onSelected,
    this.accentColor,
    this.outlined = false,
    this.spacing = 8,
    this.runSpacing = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final item in items)
          FluentFilterChip(
            label: labelOf(item),
            selected: isSelected(item),
            accentColor: accentColor,
            outlined: outlined,
            onTap: () => onSelected(item),
          ),
      ],
    );
  }
}

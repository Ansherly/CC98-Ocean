import 'package:flutter/material.dart';

/// 图标按钮
class FluentIconbutton extends StatelessWidget {
  final VoidCallback? onPressed;  // 点击事件
  final Color? iconColor;         // 图标颜色
  final IconData icon;
  final String? tooltip;          // 悬停提示

  const FluentIconbutton({
    super.key,
    this.onPressed,
    this.iconColor,
    required this.icon,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    Widget button = TextButton(
            onPressed:()=>{onPressed?.call()},
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              fixedSize: const Size.square(36),
              minimumSize: Size(32,32),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Icon(icon,color: iconColor));
    if (tooltip != null) {
      button = Tooltip(message: tooltip!, child: button);
    }
    return button;
  }
}

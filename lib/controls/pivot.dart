import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class PivotTabBar extends StatefulWidget {
  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  final Color indicatorColor;
  final double indicatorHeight;
  final double indicatorWidth;

  /// 标签**最小**宽度。实际宽度取「文字实测宽度（含 textScaler）+ 内边距」
  /// 与该值的较大者，保证文字任何时候都完整显示、不被省略号截断。
  final double tabWidth;
  final EdgeInsetsGeometry tabPadding;
  final TextStyle selectedTextStyle;
  final TextStyle unselectedTextStyle;
  final double tabSpacing;

  const PivotTabBar({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
    this.indicatorColor = Colors.blue,
    this.indicatorHeight = 3.0,
    this.indicatorWidth = 40.0,
    this.tabWidth = 72.0,
    this.tabPadding = const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
    this.selectedTextStyle = const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16.0,
    ),
    this.unselectedTextStyle = const TextStyle(
      fontWeight: FontWeight.normal,
      fontSize: 16.0,
      color: Colors.grey,
    ),
    this.tabSpacing = 8.0,
  });

  @override
  State<PivotTabBar> createState() => _PivotTabBarState();
}

class _PivotTabBarState extends State<PivotTabBar>
    with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _animationController;
  late int _currentIndex;
  late double _indicatorPosition;

  /// 各标签实际渲染宽度与累计左偏移（由真实布局测得，避免字体预估偏差）。
  List<double> _tabWidths = const [];
  List<double> _tabOffsets = const [0.0];

  /// 每个标签的 Key，用于读取真实渲染宽度。
  late List<GlobalKey> _tabKeys =
      List.generate(widget.tabs.length, (_) => GlobalKey());

  double get _tabAreaHeight => 40.0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.selectedIndex;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 180),
      vsync: this,
    );

    _scrollController = ScrollController();

    // 初始位置设为0，等待构建完成后再计算正确位置
    _indicatorPosition = 0;

    // 监听滚动，更新指示器位置
    _scrollController.addListener(_onScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 布局完成后读取真实渲染宽度，再定位指示器
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _measureFromLayout();
      _updateIndicatorPosition();
      _scrollToSelectedTab();
    });
  }

  /// 从真实布局读取各标签渲染宽度并累加偏移。
  /// 不使用 TextPainter 预估——预估需复刻全部字体回退/主题样式，容易偏小而截断文字。
  void _measureFromLayout() {
    final widths = <double>[];
    final offsets = <double>[0.0];
    for (var i = 0; i < widget.tabs.length; i++) {
      final ctx = i < _tabKeys.length ? _tabKeys[i].currentContext : null;
      final box = ctx?.findRenderObject();
      final width = box is RenderBox && box.hasSize && box.size.width > 0
          ? box.size.width
          : widget.tabWidth;
      widths.add(width);
      offsets.add(offsets.last + width + widget.tabSpacing);
    }
    _tabWidths = widths;
    _tabOffsets = offsets;
  }

  void _onScroll() {
    // 当滚动时，重新计算指示器位置
    if (!_animationController.isAnimating) {
      _updateIndicatorPosition();
    }
  }

  void _updateIndicatorPosition() {
    if (!mounted) return;

    final newPosition = _calculateIndicatorPosition(_currentIndex);
    if (_indicatorPosition != newPosition) {
      setState(() {
        _indicatorPosition = newPosition;
      });
    }
  }

  double _calculateIndicatorPosition(int index) {
    if (index < 0 || index >= _tabWidths.length) return _indicatorPosition;
    // 按实测宽度累计偏移定位（各标签宽度不等）
    final theoreticalPosition = _tabOffsets[index] +
        (_tabWidths[index] - widget.indicatorWidth) / 2;

    // 减去当前滚动偏移量，确保指示器位置正确
    final scrollOffset =
        _scrollController.hasClients ? _scrollController.offset : 0.0;
    return theoreticalPosition - scrollOffset;
  }

  @override
  void didUpdateWidget(PivotTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 标签数量变化时重建 Key 列表
    if (oldWidget.tabs.length != widget.tabs.length) {
      _tabKeys = List.generate(widget.tabs.length, (_) => GlobalKey());
    }

    if (widget.selectedIndex != _currentIndex) {
      _animateToIndex(widget.selectedIndex);
    } else {
      _updateIndicatorPosition();
    }
  }

  void _animateToIndex(int index) {
    if (index < 0 || index >= widget.tabs.length) return;
    
    final targetPosition = _calculateIndicatorPosition(index);
    
    final animation = Tween<double>(
      begin: _indicatorPosition,
      end: targetPosition,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    animation.addListener(() {
      if (mounted) {
        setState(() {
          _indicatorPosition = animation.value;
        });
      }
    });
    
    _animationController
      ..reset()
      ..forward().then((_) {
        if (mounted) {
          setState(() {
            _currentIndex = index;
            _indicatorPosition = targetPosition;
          });
          _scrollToSelectedTab();
        }
      });
  }

  void _scrollToSelectedTab() {
    if (!_scrollController.hasClients || !mounted) return;
    if (_currentIndex < 0 || _currentIndex >= _tabWidths.length) return;

    final viewportWidth = MediaQuery.of(context).size.width;
    // 末项后有间距，总宽 = 累计偏移末值 - 间距
    final totalWidth = _tabOffsets.last - widget.tabSpacing;
    if (totalWidth <= viewportWidth) return;

    final tabStart = _tabOffsets[_currentIndex];
    final tabWidth = _tabWidths[_currentIndex];
    final maxOffset = totalWidth - viewportWidth;

    // 计算滚动位置，使选中的标签居中
    final centerOffset = tabStart - (viewportWidth - tabWidth) / 2;
    final clampedOffset = centerOffset.clamp(0.0, maxOffset);

    _scrollController.animateTo(
      clampedOffset,
      duration: const Duration(milliseconds: 90),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 标签区与胶囊同一 Stack：胶囊贴在标签项底部（InkWell 内），
    // 整个组件底部即为 InkWell 下边缘，可与下方分割线贴紧。
    return SizedBox(
      height: _tabAreaHeight,
      child: Stack(
        children: [
          // 横向可滚动标签。桌面端需显式允许鼠标拖拽（默认只响应触摸）。
          ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              scrollbars: false,
              overscroll: false,
              dragDevices: {
                PointerDeviceKind.touch,
                PointerDeviceKind.mouse,
                PointerDeviceKind.trackpad,
                PointerDeviceKind.stylus,
              },
            ),
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              // Clamping：桌面端无回弹更贴合 Fluent
              physics: const ClampingScrollPhysics(),
              itemCount: widget.tabs.length,
              itemBuilder: (context, index) {
                final isSelected = index == _currentIndex;
                return Padding(
                  padding: EdgeInsets.only(
                      right: index < widget.tabs.length - 1
                          ? widget.tabSpacing
                          : 0),
                  // 用 InkWell 而非 GestureDetector：不抢占拖拽手势，
                  // 横向滑动与点击互不干扰。直角（无圆角），撑满标签区高度。
                  child: InkWell(
                    onTap: () {
                      if (!isSelected) {
                        widget.onTabSelected(index);
                        _animateToIndex(index);
                      }
                    },
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minWidth: widget.tabWidth),
                      child: IntrinsicWidth(
                        child: Container(
                          key: index < _tabKeys.length ? _tabKeys[index] : null,
                          alignment: Alignment.center,
                          padding: widget.tabPadding,
                          child: Text(
                            widget.tabs[index],
                            textAlign: TextAlign.center,
                            // 竖直居中：主题样式自带 height（bodyMedium 为 1.43），
                            // 额外行距按比例分配会把中文字形压低，故显式归一
                            textHeightBehavior: const TextHeightBehavior(
                              leadingDistribution: TextLeadingDistribution.even,
                            ),
                            style: (isSelected
                                    ? widget.selectedTextStyle.copyWith(
                                        color: widget.indicatorColor,
                                      )
                                    : widget.unselectedTextStyle)
                                .copyWith(height: 1.0),
                            maxLines: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // 胶囊指示条：贴标签项底部（在 InkWell 区域内），随滚动同步
          AnimatedPositioned(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeInOut,
            left: _indicatorPosition,
            bottom: 0,
            child: Container(
              width: widget.indicatorWidth,
              height: widget.indicatorHeight,
              decoration: BoxDecoration(
                color: widget.indicatorColor,
                borderRadius: BorderRadius.circular(widget.indicatorHeight / 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
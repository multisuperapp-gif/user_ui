part of '../../main.dart';

class _AllQuickCategoryStrip extends StatelessWidget {
  const _AllQuickCategoryStrip({
    required this.items,
    required this.selected,
    required this.onSelected,
  });

  final List<_AllQuickCategoryItem> items;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 2, 0, 2),
      color: Colors.white,
      child: SizedBox(
        height: 92,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final item = items[index];
            return _AllQuickCategoryCard(
              item: item,
              selected: item.label == selected,
              onTap: () => onSelected(item.label),
            );
          },
        ),
      ),
    );
  }
}

class _AllQuickCategoryCard extends StatelessWidget {
  const _AllQuickCategoryCard({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _AllQuickCategoryItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 64,
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    item.accent.withValues(alpha: 0.22),
                    Colors.white,
                  ],
                ),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: item.accent.withValues(alpha: selected ? 0.55 : 0.28),
                  width: selected ? 1.4 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: item.accent.withValues(alpha: 0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: _AllQuickCategoryThumb(item: item),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              item.label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: selected ? const Color(0xFFF04F7C) : const Color(0xFF202435),
                fontSize: 11.5,
                fontWeight: selected ? FontWeight.w900 : FontWeight.w500,
                height: 1.02,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AllQuickCategoryThumb extends StatelessWidget {
  const _AllQuickCategoryThumb({required this.item});

  final _AllQuickCategoryItem item;

  @override
  Widget build(BuildContext context) {
    final visual = _sceneVisual(item.label);
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            item.accent.withValues(alpha: 0.82),
            visual.$2.withValues(alpha: 0.92),
          ],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            right: -8,
            bottom: -14,
            child: Opacity(
              opacity: 0.18,
              child: Text(
                visual.$1,
                style: const TextStyle(
                  fontSize: 64,
                  height: 1,
                ),
              ),
            ),
          ),
          Positioned(
            left: 10,
            right: 10,
            top: 10,
            bottom: 10,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(22),
              ),
            ),
          ),
          Center(
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                item.icon,
                size: 18,
                color: item.accent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeFilterRow extends StatelessWidget {
  const _ModeFilterRow({
    required this.filters,
    required this.selected,
    required this.selectedTextColor,
    required this.onSelected,
    this.disabledFilters = const {},
  });

  final List<String> filters;
  final String selected;
  final Color selectedTextColor;
  final ValueChanged<String> onSelected;
  final Set<String> disabledFilters;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final active = filter == selected;
          final disabled = disabledFilters.contains(filter);
          return GestureDetector(
            onTap: () => onSelected(filter),
            child: Container(
              width: 68,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: disabled ? 2 : 0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 42,
                          height: 22,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Center(
                                child: Opacity(
                                  opacity: disabled ? 0.4 : 1,
                                  child: Text(
                                    _sceneVisual(filter).$1,
                                    style: const TextStyle(fontSize: 20, height: 1),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          filter,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: disabled
                                ? const Color(0xFF9CA3AF)
                                : active
                                    ? selectedTextColor
                                    : const Color(0xFF202435),
                            fontWeight: active ? FontWeight.w800 : FontWeight.w700,
                            fontSize: 10.2,
                            height: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (disabled)
                    const Positioned.fill(
                      child: IgnorePointer(
                        child: _ComingSoonDiagonalRibbon(),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ComingSoonDiagonalRibbon extends StatefulWidget {
  const _ComingSoonDiagonalRibbon();

  @override
  State<_ComingSoonDiagonalRibbon> createState() => _ComingSoonDiagonalRibbonState();
}

class _ComingSoonDiagonalRibbonState extends State<_ComingSoonDiagonalRibbon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final pulse = 0.72 + (_controller.value * 0.28);
        return Center(
          child: Transform.translate(
            offset: const Offset(0, 2),
            child: OverflowBox(
              minWidth: 0,
              minHeight: 0,
              maxWidth: 96,
              maxHeight: 34,
              alignment: Alignment.center,
              child: Opacity(
                opacity: pulse,
                child: Transform.rotate(
                  angle: -0.86,
                  child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 88,
                        height: 14,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFFD90F1E).withValues(alpha: 0.95),
                              const Color(0xFFFF3B30).withValues(alpha: 0.98),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFD92D20).withValues(alpha: 0.22 + (_controller.value * 0.1)),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                      const Text(
                        'COMING SOON',
                        maxLines: 1,
                        overflow: TextOverflow.visible,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 6,
                          fontWeight: FontWeight.w900,
                          height: 1,
                          letterSpacing: 0.18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

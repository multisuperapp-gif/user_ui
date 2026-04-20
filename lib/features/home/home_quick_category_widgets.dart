part of '../../main.dart';

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
                                    ? const Color(0xFF202435)
                                    : const Color(0xFF202435).withValues(alpha: 0.78),
                            fontWeight: active ? FontWeight.w800 : FontWeight.w700,
                            fontSize: 10.2,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 5),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          curve: Curves.easeOut,
                          width: active ? 38 : 18,
                          height: active ? 3.2 : 1.4,
                          decoration: BoxDecoration(
                            color: active
                                ? const Color(0xFFD92D20)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(999),
                            boxShadow: active
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFFD92D20).withValues(alpha: 0.28),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
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

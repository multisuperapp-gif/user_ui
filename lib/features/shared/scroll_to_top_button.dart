part of '../../main.dart';

mixin _ScrollToTopVisibilityMixin<T extends StatefulWidget> on State<T> {
  bool _showScrollToTopButton = false;
  Timer? _scrollToTopHideTimer;

  ScrollController get scrollToTopController;

  void initScrollToTopVisibility() {
    scrollToTopController.addListener(_handleScrollToTopVisibility);
  }

  void disposeScrollToTopVisibility() {
    scrollToTopController.removeListener(_handleScrollToTopVisibility);
    _scrollToTopHideTimer?.cancel();
  }

  void _handleScrollToTopVisibility() {
    if (!scrollToTopController.hasClients) {
      return;
    }
    final shouldShow = scrollToTopController.offset > 96;
    _scrollToTopHideTimer?.cancel();
    if (shouldShow != _showScrollToTopButton && mounted) {
      setState(() => _showScrollToTopButton = shouldShow);
    }
    if (shouldShow) {
      _scrollToTopHideTimer = Timer(const Duration(milliseconds: 1100), () {
        if (mounted && _showScrollToTopButton) {
          setState(() => _showScrollToTopButton = false);
        }
      });
    }
  }

  void scrollToPageTop() {
    if (!scrollToTopController.hasClients) {
      return;
    }
    scrollToTopController.animateTo(
      0,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );
  }

  Widget buildScrollToTopOverlay({double bottom = 26}) {
    return _ScrollToTopOverlayButton(
      visible: _showScrollToTopButton,
      bottom: bottom,
      onTap: scrollToPageTop,
    );
  }
}

class _ScrollToTopOverlayButton extends StatelessWidget {
  const _ScrollToTopOverlayButton({
    required this.visible,
    required this.bottom,
    required this.onTap,
  });

  final bool visible;
  final double bottom;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: bottom,
      child: IgnorePointer(
        ignoring: !visible,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 180),
          opacity: visible ? 1 : 0,
          child: Center(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onTap,
              child: const Padding(
                padding: EdgeInsets.all(10),
                child: Text(
                  '↑',
                  style: TextStyle(
                    color: Color(0xFFCB6E5B),
                    fontSize: 38,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

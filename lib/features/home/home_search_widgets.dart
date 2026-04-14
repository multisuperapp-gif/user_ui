part of '../../main.dart';

class _HomeSearchBar extends StatefulWidget {
  const _HomeSearchBar({
    required this.controller,
    required this.hint,
    required this.tint,
    required this.onFocusChanged,
  });

  final TextEditingController controller;
  final String hint;
  final Color tint;
  final ValueChanged<bool> onFocusChanged;

  @override
  State<_HomeSearchBar> createState() => _HomeSearchBarState();
}

class _HomeSearchBarState extends State<_HomeSearchBar> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode()
      ..addListener(() {
        widget.onFocusChanged(_focusNode.hasFocus);
        if (mounted) {
          setState(() {});
        }
      });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isFocused = _focusNode.hasFocus;
    return Row(
      children: [
        Expanded(
          child: TapRegion(
            onTapOutside: (_) => _focusNode.unfocus(),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              height: isFocused ? 50 : 48,
              padding: EdgeInsets.symmetric(horizontal: isFocused ? 16 : 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: isFocused ? widget.tint.withValues(alpha: 0.55) : const Color(0xFFA8A8A8),
                  width: isFocused ? 1.4 : 1.2,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.tint.withValues(alpha: 0.16),
                      border: Border.all(color: widget.tint.withValues(alpha: 0.28)),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'M',
                      style: TextStyle(
                        color: widget.tint,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: widget.controller,
                      focusNode: _focusNode,
                      style: TextStyle(
                        color: const Color(0xFF202435),
                        fontWeight: FontWeight.w600,
                        fontSize: isFocused ? 16 : 14.5,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: widget.hint,
                        hintStyle: TextStyle(
                          color: Color(0xFF686B78),
                          fontWeight: FontWeight.w500,
                          fontSize: isFocused ? 16 : 14,
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => _focusNode.requestFocus(),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 4),
                          child: Icon(Icons.search_rounded, color: Color(0xFF686B78), size: 24),
                        ),
                      ),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        child: isFocused
                            ? GestureDetector(
                                key: const ValueKey('mic'),
                                behavior: HitTestBehavior.opaque,
                                onTap: () => _focusNode.requestFocus(),
                                child: const Padding(
                                  padding: EdgeInsets.only(left: 8),
                                child: Icon(
                                    Icons.mic_none_rounded,
                                    color: Color(0xFF686B78),
                                    size: 22,
                                  ),
                                ),
                              )
                            : const SizedBox(key: ValueKey('no-mic')),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

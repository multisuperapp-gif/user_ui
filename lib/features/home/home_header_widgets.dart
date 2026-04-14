part of '../../main.dart';

Color _modeTint(_HomeMode mode) {
  switch (mode) {
    case _HomeMode.all:
      return const Color(0xFF5C8FD8);
    case _HomeMode.labour:
      return const Color(0xFFF2A13D);
    case _HomeMode.service:
      return const Color(0xFFDF7DA0);
    case _HomeMode.shop:
      return const Color(0xFF4DAF50);
  }
}

List<Color> _headerGradient(_HomeMode mode) {
  switch (mode) {
    case _HomeMode.all:
      return const [
        Color(0xFFDCEAFF),
        Color(0xFFEDF5FF),
        Color(0xFFFBFDFF),
      ];
    case _HomeMode.labour:
      return const [
        Color(0xFFFFEDB8),
        Color(0xFFFFF4D4),
        Color(0xFFFFFCF1),
      ];
    case _HomeMode.service:
      return const [
        Color(0xFFFFD7E0),
        Color(0xFFFFE8EE),
        Color(0xFFFFFBFC),
      ];
    case _HomeMode.shop:
      return const [
        Color(0xFFDDF4DF),
        Color(0xFFEAF8EB),
        Color(0xFFFCFEFC),
      ];
  }
}

class _PinnedHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _PinnedHeaderDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  final double minHeight;
  final double maxHeight;
  final Widget child;

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(covariant _PinnedHeaderDelegate oldDelegate) {
    return minHeight != oldDelegate.minHeight ||
        maxHeight != oldDelegate.maxHeight ||
        child != oldDelegate.child;
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Icon(Icons.location_on_rounded, color: Color(0xFF202435), size: 18),
        const SizedBox(width: 5),
        Expanded(
          child: RichText(
            text: const TextSpan(
              style: TextStyle(
                color: Color(0xFF202435),
                fontSize: 13,
                fontFamily: 'SF Pro Display',
              ),
              children: [
                TextSpan(text: 'Deliver to '),
                TextSpan(
                  text: 'X7MF+53X - Nawada, Bihar 84150...',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF202435), size: 20),
      ],
    );
  }
}

class _PinnedSearchHeader extends StatefulWidget {
  const _PinnedSearchHeader({
    required this.controller,
    required this.hint,
    required this.tint,
    required this.onNotificationTap,
    required this.onProfileTap,
    required this.onCartTap,
    required this.unreadNotificationCount,
  });

  final TextEditingController controller;
  final String hint;
  final Color tint;
  final VoidCallback onNotificationTap;
  final VoidCallback onProfileTap;
  final VoidCallback onCartTap;
  final int unreadNotificationCount;

  @override
  State<_PinnedSearchHeader> createState() => _PinnedSearchHeaderState();
}

class _PinnedSearchHeaderState extends State<_PinnedSearchHeader> {
  bool _searchActive = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: _HomeSearchBar(
            controller: widget.controller,
            hint: widget.hint,
            tint: widget.tint,
            onFocusChanged: (active) {
              if (_searchActive != active) {
                setState(() => _searchActive = active);
              }
            },
          ),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeOut,
          child: _searchActive
              ? const SizedBox.shrink()
              : Row(
                  key: const ValueKey('header-actions'),
                  children: [
                    const SizedBox(width: 12),
                    InkWell(
                      onTap: widget.onNotificationTap,
                      borderRadius: BorderRadius.circular(999),
                      child: _HeaderNotificationIcon(
                        unreadCount: widget.unreadNotificationCount,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const _HeaderCircleIcon(icon: Icons.favorite_border_rounded),
                    const SizedBox(width: 12),
                    InkWell(
                      onTap: widget.onCartTap,
                      borderRadius: BorderRadius.circular(999),
                      child: const _HeaderCircleIcon(icon: Icons.shopping_cart_outlined),
                    ),
                    const SizedBox(width: 12),
                    InkWell(
                      onTap: widget.onProfileTap,
                      borderRadius: BorderRadius.circular(999),
                      child: Container(
                        width: 34,
                        height: 34,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.person_outline_rounded,
                          color: Color(0xFF202435),
                          size: 29,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}

class _HeaderNotificationIcon extends StatelessWidget {
  const _HeaderNotificationIcon({required this.unreadCount});

  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    final showBadge = unreadCount > 0;
    final badgeText = unreadCount > 99 ? '99+' : '$unreadCount';
    return SizedBox(
      width: 30,
      height: 30,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Align(
            alignment: Alignment.center,
            child: Icon(
              Icons.notifications_none_rounded,
              color: Color(0xFF202435),
              size: 28,
            ),
          ),
          if (showBadge)
            Positioned(
              right: -3,
              top: -3,
              child: Container(
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: const Color(0xFFCB6E5B),
                  borderRadius: BorderRadius.circular(999),
                ),
                alignment: Alignment.center,
                child: Text(
                  badgeText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _HeaderCircleIcon extends StatelessWidget {
  const _HeaderCircleIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 30,
      height: 30,
      child: Icon(icon, color: const Color(0xFF202435), size: 28),
    );
  }
}

class _ModeSwitcher extends StatelessWidget {
  const _ModeSwitcher({
    required this.mode,
    required this.onModeSelected,
  });

  final _HomeMode mode;
  final ValueChanged<_HomeMode> onModeSelected;

  @override
  Widget build(BuildContext context) {
    final cards = [
      (_HomeMode.all, 'ALL'),
      (_HomeMode.labour, 'LABOUR'),
      (_HomeMode.service, 'SERVICE'),
      (_HomeMode.shop, 'SHOP'),
    ];

    return SizedBox(
      height: 40,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 1.5,
              color: _modeTint(mode),
            ),
          ),
          ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            scrollDirection: Axis.horizontal,
            itemCount: cards.length,
            itemBuilder: (context, index) {
              final card = cards[index];
              final selected = mode == card.$1;
              final selectedWidth = (card.$2.length * 13.0 + 54.0).clamp(104.0, 152.0);
              return GestureDetector(
                onTap: () => onModeSelected(card.$1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: selected ? selectedWidth : 82,
                  child: CustomPaint(
                    painter: _CategoryTabBorderPainter(
                      label: card.$2,
                      color: _modeTint(mode),
                      fillColor: card.$1 == _HomeMode.all && selected
                          ? Colors.white
                          : _headerGradient(mode).first,
                      selected: selected,
                    ),
                    child: Container(
                      color: Colors.transparent,
                      alignment: Alignment.center,
                      padding: EdgeInsets.only(
                        left: selected ? 8 : 0,
                        right: selected ? 8 : 0,
                        top: selected ? 0 : 0,
                        bottom: selected ? 0 : 0,
                      ),
                      child: Transform.translate(
                        offset: Offset(0, selected ? 6 : 0),
                        child: Text(
                          card.$2,
                          style: TextStyle(
                            color: const Color(0xFF202435),
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.8,
                            fontSize: selected ? 12.8 : 12.2,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CategoryTabBorderPainter extends CustomPainter {
  const _CategoryTabBorderPainter({
    required this.label,
    required this.color,
    required this.fillColor,
    required this.selected,
  });

  final String label;
  final Color color;
  final Color fillColor;
  final bool selected;

  @override
  void paint(Canvas canvas, Size size) {
    final baselineY = size.height - 1.0;

    if (!selected) {
      return;
    }

    final borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.butt
      ..strokeJoin = StrokeJoin.miter;
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final bottomY = baselineY;
    const curveRadius = 12.0;
    const borderWidth = 1.5;
    const boxSize = curveRadius + borderWidth;
    const bodyLeft = boxSize + 4;
    final bodyRight = size.width - boxSize - 4;
    const topY = 2.0;

    final sideJoinY = bottomY - curveRadius;
    const baselineLeft = 0.0;
    final baselineRight = size.width;
    final leftJoinX = bodyLeft - curveRadius;
    final rightJoinX = bodyRight + curveRadius;

    final fillPath = Path()
      ..moveTo(leftJoinX, bottomY + 1)
      ..arcToPoint(
        Offset(bodyLeft, sideJoinY),
        radius: const Radius.circular(curveRadius),
        clockwise: false,
      )
      ..lineTo(bodyLeft, topY + curveRadius)
      ..arcToPoint(
        Offset(bodyLeft + curveRadius, topY),
        radius: const Radius.circular(curveRadius),
        clockwise: true,
      )
      ..lineTo(bodyRight - curveRadius, topY)
      ..arcToPoint(
        Offset(bodyRight, topY + curveRadius),
        radius: const Radius.circular(curveRadius),
        clockwise: true,
      )
      ..lineTo(bodyRight, sideJoinY)
      ..arcToPoint(
        Offset(rightJoinX, bottomY + 1),
        radius: const Radius.circular(curveRadius),
        clockwise: false,
      )
      ..close();

    canvas.drawPath(fillPath, fillPaint);

    final bodyBorder = Path()
      ..moveTo(bodyLeft + curveRadius, topY)
      ..lineTo(bodyRight - curveRadius, topY)
      ..arcToPoint(
        Offset(bodyRight, topY + curveRadius),
        radius: const Radius.circular(curveRadius),
        clockwise: true,
      )
      ..lineTo(bodyRight, sideJoinY)
      ..moveTo(bodyLeft, sideJoinY)
      ..lineTo(bodyLeft, topY + curveRadius)
      ..arcToPoint(
        Offset(bodyLeft + curveRadius, topY),
        radius: const Radius.circular(curveRadius),
        clockwise: true,
      );

    final leftSwoop = Path()
      ..moveTo(baselineLeft, bottomY)
      ..lineTo(bodyLeft - curveRadius, bottomY)
      ..arcToPoint(
        Offset(bodyLeft, sideJoinY),
        radius: const Radius.circular(curveRadius),
        clockwise: false,
      );
    final rightSwoop = Path()
      ..moveTo(bodyRight, sideJoinY)
      ..arcToPoint(
        Offset(bodyRight + curveRadius, bottomY),
        radius: const Radius.circular(curveRadius),
        clockwise: false,
      )
      ..lineTo(baselineRight, bottomY);

    canvas.drawPath(bodyBorder, borderPaint);
    canvas.drawPath(leftSwoop, borderPaint);
    canvas.drawPath(rightSwoop, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _CategoryTabBorderPainter oldDelegate) {
    return label != oldDelegate.label ||
        color != oldDelegate.color ||
        fillColor != oldDelegate.fillColor ||
        selected != oldDelegate.selected;
  }
}

class _SceneThumb extends StatelessWidget {
  const _SceneThumb({
    required this.title,
    required this.accent,
    this.compact = false,
  });

  final String title;
  final Color accent;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final visual = _sceneVisual(title);
    final sceneIcon = _sceneIcon(title);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            visual.$2.withValues(alpha: compact ? 0.74 : 0.96),
            accent.withValues(alpha: compact ? 0.58 : 0.88),
          ],
        ),
        borderRadius: BorderRadius.circular(compact ? 16 : 22),
        border: Border.all(
          color: Colors.white.withValues(alpha: compact ? 0.16 : 0.1),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: compact ? 18 : 24,
            right: compact ? 18 : 24,
            top: compact ? 18 : 30,
            bottom: compact ? 18 : 26,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: compact ? 0.18 : 0.14),
                borderRadius: BorderRadius.circular(compact ? 18 : 28),
              ),
            ),
          ),
          Positioned(
            right: compact ? -4 : -8,
            bottom: compact ? -10 : -14,
            child: Opacity(
              opacity: compact ? 0.14 : 0.1,
              child: Text(
                visual.$1,
                style: TextStyle(
                  fontSize: compact ? 34 : 72,
                  height: 1,
                ),
              ),
            ),
          ),
          Positioned(
            left: compact ? 8 : 12,
            top: compact ? 8 : 10,
            child: Container(
              width: compact ? 16 : 20,
              height: compact ? 16 : 20,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: compact ? 0 : 0,
            right: compact ? 0 : 0,
            top: compact ? 26 : 38,
            child: Center(
              child: Icon(
                sceneIcon,
                size: compact ? 36 : 62,
                color: Colors.white.withValues(alpha: 0.96),
              ),
            ),
          ),
          if (!compact)
            Positioned(
              left: 18,
              top: 18,
              child: Text(
                visual.$1,
                style: const TextStyle(
                  fontSize: 22,
                  height: 1,
                ),
              ),
            ),
          if (!compact && visual.$3.isNotEmpty)
            Positioned(
              right: 12,
              bottom: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  visual.$3,
                  style: const TextStyle(
                    color: Color(0xFF22314D),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

(String, Color, String) _sceneVisual(String title) {
  final key = title.toLowerCase();
  if (key.contains('labour') || key.contains('helper') || key.contains('loader')) {
    return ('👷', const Color(0xFFF2A13D), 'ON DUTY');
  }
  if (key.contains('service') || key.contains('plumber') || key.contains('electric') || key.contains('appliance')) {
    return ('🛠️', const Color(0xFFDF7DA0), 'BOOK NOW');
  }
  if (key.contains('shop') || key.contains('grocery') || key.contains('fresh') || key.contains('vegetable')) {
    return ('🛍️', const Color(0xFF4DAF50), 'TOP PICKS');
  }
  if (key.contains('pharmacy')) {
    return ('💊', const Color(0xFF5C8FD8), 'QUICK NEED');
  }
  if (key.contains('gift')) {
    return ('🎁', const Color(0xFFCB6E5B), 'PICK A GIFT');
  }
  if (key.contains('dining') || key.contains('food')) {
    return ('🍽️', const Color(0xFFCB6E5B), 'TRENDING');
  }
  return ('✨', const Color(0xFF5C8FD8), '');
}

IconData _sceneIcon(String title) {
  final key = title.toLowerCase();
  if (key.contains('vegetable') || key.contains('veg') || key.contains('spinach') || key.contains('capsicum')) {
    return Icons.eco_rounded;
  }
  if (key.contains('fruit') || key.contains('onion') || key.contains('potato')) {
    return Icons.shopping_basket_rounded;
  }
  if (key.contains('pharmacy') || key.contains('tablet') || key.contains('medicine')) {
    return Icons.local_pharmacy_rounded;
  }
  if (key.contains('gift') || key.contains('combo')) {
    return Icons.redeem_rounded;
  }
  if (key.contains('milk') || key.contains('bread') || key.contains('bakery')) {
    return Icons.breakfast_dining_rounded;
  }
  if (key.contains('dinner') || key.contains('food') || key.contains('restaurant')) {
    return Icons.restaurant_rounded;
  }
  if (key.contains('dress') || key.contains('kurta') || key.contains('saree') || key.contains('top') || key.contains('cloth')) {
    return Icons.checkroom_rounded;
  }
  if (key.contains('shop') || key.contains('store') || key.contains('grocery')) {
    return Icons.storefront_rounded;
  }
  if (key.contains('repair') || key.contains('service') || key.contains('ac') || key.contains('appliance')) {
    return Icons.handyman_rounded;
  }
  return Icons.widgets_rounded;
}

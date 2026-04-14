part of '../../../main.dart';

class _SimpleHeaderCircleButton extends StatelessWidget {
  const _SimpleHeaderCircleButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFE8EAEE)),
        ),
        child: Icon(icon, size: 19, color: const Color(0xFF444C5C)),
      ),
    );
  }
}

class _ShopMenuFilterChip extends StatelessWidget {
  const _ShopMenuFilterChip({
    required this.label,
    required this.icon,
    this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE8EAEE)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.035),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: const Color(0xFF566074)),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF4B5567),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShopMenuItemRow extends StatelessWidget {
  const _ShopMenuItemRow({
    super.key,
    required this.item,
    required this.onOpenTap,
    required this.onWishlistTap,
    required this.onShareTap,
    required this.onAddTap,
  });

  final _DiscoveryItem item;
  final VoidCallback onOpenTap;
  final VoidCallback onWishlistTap;
  final VoidCallback onShareTap;
  final VoidCallback onAddTap;

  String get _description =>
      'An exotic selection of fine melted chocolate combined with ${item.title.toLowerCase()} and rich flavours.';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onOpenTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFFF0F1F4)),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 13,
                      height: 13,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFF31A24C), width: 1.5),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: const Center(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Color(0xFF31A24C),
                            shape: BoxShape.circle,
                          ),
                          child: SizedBox(width: 5, height: 5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF1F2635),
                        fontSize: 14.2,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          width: 26,
                          height: 5,
                          decoration: BoxDecoration(
                            color: const Color(0xFF27A65A),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Highly reordered',
                          style: TextStyle(
                            color: Color(0xFF6E7480),
                            fontWeight: FontWeight.w700,
                            fontSize: 11.2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Text(
                      item.price,
                      style: const TextStyle(
                        color: Color(0xFF232A3C),
                        fontSize: 15.2,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      _description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF757B87),
                        fontWeight: FontWeight.w700,
                        fontSize: 12.1,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Row(
                      children: [
                        _RoundActionIcon(
                          icon: Icons.bookmark_border_rounded,
                          color: const Color(0xFF6A7484),
                          onTap: onWishlistTap,
                          size: 28,
                          iconSize: 15,
                        ),
                        const SizedBox(width: 10),
                        _RoundActionIcon(
                          icon: Icons.share_outlined,
                          color: const Color(0xFF6A7484),
                          onTap: onShareTap,
                          size: 28,
                          iconSize: 15,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: 120,
              child: Column(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: SizedBox(
                          width: 120,
                          height: 101,
                          child: _TemporaryCatalogImage(
                            item: item,
                            fallback: _SceneThumb(
                              title: item.title,
                              accent: item.accent,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 9,
                        right: 9,
                        bottom: -13,
                        child: InkWell(
                          onTap: onAddTap,
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 7),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF2FFF3),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFF7AC08A)),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'ADD',
                                  style: TextStyle(
                                    color: Color(0xFF26A05A),
                                    fontWeight: FontWeight.w900,
                                    fontSize: 13.2,
                                  ),
                                ),
                                SizedBox(width: 6),
                                Icon(Icons.add_rounded, size: 16, color: Color(0xFF26A05A)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 19),
                  const Text(
                    'customisable',
                    style: TextStyle(
                      color: Color(0xFF9A9EA8),
                      fontWeight: FontWeight.w700,
                      fontSize: 10.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

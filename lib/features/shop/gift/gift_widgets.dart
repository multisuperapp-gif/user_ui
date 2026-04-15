part of '../../../main.dart';

class _GiftPillButton extends StatelessWidget {
  const _GiftPillButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0xFFE7E2D8)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: const Color(0xFF555B68)),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF3E4452),
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GiftGridProductCard extends StatelessWidget {
  const _GiftGridProductCard({
    required this.item,
    required this.onTap,
  });

  final _DiscoveryItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final outOfStock = _isShopItemOutOfStock(item);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: _TemporaryCatalogImage(
                      item: item,
                      fallback: _GiftProductPlaceholder(item: item),
                    ),
                  ),
                ),
                if (outOfStock)
                  const Positioned(
                    top: 6,
                    left: 6,
                    child: _OutOfStockBadge(compact: true),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF232835),
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              height: 1.22,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.price,
            style: const TextStyle(
              color: Color(0xFF171C25),
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _GiftProductPlaceholder extends StatelessWidget {
  const _GiftProductPlaceholder({
    required this.item,
  });

  final _DiscoveryItem item;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            item.accent.withValues(alpha: 0.9),
            item.accent.withValues(alpha: 0.55),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -18,
            top: -10,
            child: Icon(
              item.icon,
              size: 76,
              color: Colors.white.withValues(alpha: 0.22),
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(item.icon, color: Colors.white, size: 18),
                  ),
                  const Spacer(),
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GiftHeroImage extends StatelessWidget {
  const _GiftHeroImage({
    required this.item,
    required this.assetKey,
  });

  final _DiscoveryItem item;
  final String assetKey;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: _TemporaryCatalogImage(
          item: item,
          assetKey: assetKey,
          fallback: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  item.accent.withValues(alpha: 0.94),
                  const Color(0xFFFFF2E1),
                ],
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -28,
                  top: -8,
                  child: Icon(
                    item.icon,
                    size: 156,
                    color: Colors.white.withValues(alpha: 0.18),
                  ),
                ),
                Positioned(
                  left: 24,
                  right: 24,
                  bottom: 24,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          item.extra.isEmpty ? 'Curated gift' : item.extra,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          height: 1.05,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.subtitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GiftOptionCard extends StatelessWidget {
  const _GiftOptionCard({
    required this.item,
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final _DiscoveryItem item;
  final _GiftOptionData option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 168,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFFFBF3) : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selected ? const Color(0xFFB5B36A) : const Color(0xFFE6E0D6),
            width: selected ? 1.6 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: selected ? 0.08 : 0.04),
              blurRadius: 18,
              offset: const Offset(0, 10),
              spreadRadius: -10,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: item.accent.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(item.icon, color: const Color(0xFF6D7034), size: 18),
                ),
                const Spacer(),
                Icon(
                  selected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                  color: selected ? const Color(0xFF8A8B2E) : const Color(0xFFC1BEAF),
                  size: 22,
                ),
              ],
            ),
            const Spacer(),
            Text(
              option.label,
              style: const TextStyle(
                color: Color(0xFF202435),
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              option.price,
              style: const TextStyle(
                color: Color(0xFF171C25),
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              selected ? 'Selected gift variant' : 'Tap to choose this variant',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF7B7F88),
                fontSize: 11.8,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

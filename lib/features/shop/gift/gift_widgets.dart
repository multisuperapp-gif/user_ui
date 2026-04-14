part of '../../../main.dart';

class _GiftCategoryShowcase extends StatelessWidget {
  const _GiftCategoryShowcase({
    required this.selectedCategory,
    required this.sortOption,
    required this.onItemTap,
    required this.onShopTap,
    required this.onAddToCart,
    required this.isWishlisted,
    required this.onWishlistToggle,
  });

  final String selectedCategory;
  final String sortOption;
  final ValueChanged<_DiscoveryItem> onItemTap;
  final ValueChanged<_DiscoveryItem> onShopTap;
  final ValueChanged<_DiscoveryItem> onAddToCart;
  final bool Function(_DiscoveryItem item) isWishlisted;
  final ValueChanged<_DiscoveryItem> onWishlistToggle;

  @override
  Widget build(BuildContext context) {
    if (selectedCategory == 'All') {
      return ColoredBox(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            const _GiftOfferCarousel(),
            const SizedBox(height: 14),
            const _GiftQuickCategoryGrid(),
            const SizedBox(height: 18),
            for (final section in _giftLandingSections) ...[
              _GiftLandingSection(
                section: section,
                onTap: onShopTap,
              ),
              const SizedBox(height: 18),
            ],
            const SizedBox(height: 12),
          ],
        ),
      );
    }

    final items = _sortedGiftItems(
      _giftProductsForOccasion(selectedCategory),
      sortOption,
    ).take(12).toList();

    return ColoredBox(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$selectedCategory Picks',
              style: const TextStyle(
                color: Color(0xFF1E2432),
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Curated gifting ideas ready for same-day delivery.',
              style: TextStyle(
                color: Color(0xFF7B7E87),
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 14),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 18,
                childAspectRatio: 0.78,
              ),
              itemBuilder: (context, index) {
                final item = items[index];
                return _GiftGridProductCard(
                  item: item,
                  onTap: () => onItemTap(item),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _GiftShopWiseSection extends StatelessWidget {
  const _GiftShopWiseSection({
    required this.items,
    required this.isWishlisted,
    required this.onWishlistToggle,
    required this.onTap,
  });

  final List<_DiscoveryItem> items;
  final bool Function(_DiscoveryItem item) isWishlisted;
  final ValueChanged<_DiscoveryItem> onWishlistToggle;
  final ValueChanged<_DiscoveryItem> onTap;

  @override
  Widget build(BuildContext context) {
    final shops = items.isEmpty ? _giftShopSeeds : items.take(6).toList();
    return ColoredBox(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'GIFT STORES',
              style: TextStyle(
                color: Color(0xFF8C8B80),
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.4,
              ),
            ),
            const SizedBox(height: 12),
            for (final shop in shops) ...[
              _GiftShopWiseCard(
                item: shop,
                isWishlisted: isWishlisted(shop),
                onWishlistToggle: () => onWishlistToggle(shop),
                onTap: () => onTap(shop),
              ),
              const SizedBox(height: 14),
            ],
          ],
        ),
      ),
    );
  }
}

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

class _GiftOfferCarousel extends StatelessWidget {
  const _GiftOfferCarousel();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        children: [
          Container(
            height: 140,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFFCEEC6),
                  Color(0xFFF7E39D),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -14,
                  top: -6,
                  bottom: -6,
                  child: Opacity(
                    opacity: 0.18,
                    child: Text(
                      '%off',
                      style: TextStyle(
                        color: const Color(0xFFBB9E3B),
                        fontSize: 104,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),
                  ),
                ),
                const Positioned(
                  left: 18,
                  top: 20,
                  child: Text(
                    'Extra Rs.750 OFF',
                    style: TextStyle(
                      color: Color(0xFF7C6824),
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const Positioned(
                  left: 18,
                  top: 50,
                  child: Text(
                    'Summer best gifts are here',
                    style: TextStyle(
                      color: Color(0xFF8B7A3F),
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Positioned(
                  left: 18,
                  bottom: 18,
                  child: Text(
                    'Use code: GIFT750',
                    style: TextStyle(
                      color: Color(0xFF9A8C5A),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Positioned(
                  right: 22,
                  bottom: 18,
                  child: Row(
                    children: List.generate(
                      4,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: index == 1 ? 8 : 6,
                        height: index == 1 ? 8 : 6,
                        decoration: BoxDecoration(
                          color: index == 1 ? const Color(0xFF4D4D2F) : Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GiftQuickCategoryGrid extends StatelessWidget {
  const _GiftQuickCategoryGrid();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _giftQuickCategories.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 12,
          mainAxisSpacing: 18,
          childAspectRatio: 0.82,
        ),
        itemBuilder: (context, index) {
          final item = _giftQuickCategories[index];
          return Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: const Color(0xFFF0ECE5)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: _GiftQuickPlaceholder(item: item),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF232835),
                  fontSize: 11.8,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _GiftLandingSection extends StatelessWidget {
  const _GiftLandingSection({
    required this.section,
    required this.onTap,
  });

  final _GiftLandingSectionData section;
  final ValueChanged<_DiscoveryItem> onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.title,
            style: const TextStyle(
              color: Color(0xFF222732),
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 164,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: section.items.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final item = section.items[index];
                return _GiftLandingCard(
                  item: item,
                  onTap: () => onTap(item),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _GiftLandingCard extends StatelessWidget {
  const _GiftLandingCard({
    required this.item,
    required this.onTap,
  });

  final _DiscoveryItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: SizedBox(
        width: 154,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: _TemporaryCatalogImage(
                  item: item,
                  fallback: _GiftProductPlaceholder(item: item),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF232835),
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GiftShopWiseCard extends StatelessWidget {
  const _GiftShopWiseCard({
    required this.item,
    required this.isWishlisted,
    required this.onWishlistToggle,
    required this.onTap,
  });

  final _DiscoveryItem item;
  final bool isWishlisted;
  final VoidCallback onWishlistToggle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFF0ECE5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.045),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                SizedBox(
                  height: 150,
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                    child: _TemporaryCatalogImage(
                      item: item,
                      fallback: _GiftProductPlaceholder(item: item),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: InkWell(
                    onTap: onWishlistToggle,
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: Colors.white,
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
                        isWishlisted ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        color: const Color(0xFF9B4D72),
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      color: Color(0xFF222732),
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.subtitle,
                    style: const TextStyle(
                      color: Color(0xFF7B7E87),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _GiftMetaChip(
                        icon: Icons.star_rounded,
                        label: item.rating,
                        tint: const Color(0xFF1FA663),
                        background: const Color(0xFFE7F8EF),
                      ),
                      const SizedBox(width: 8),
                      _GiftMetaChip(
                        icon: Icons.local_shipping_outlined,
                        label: 'Same day',
                        tint: const Color(0xFF7D7F2D),
                        background: const Color(0xFFF4F5E2),
                      ),
                    ],
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

class _GiftHeroImage extends StatelessWidget {
  const _GiftHeroImage({
    required this.item,
    required this.assetKey,
  });

  final _DiscoveryItem item;
  final String assetKey;

  @override
  Widget build(BuildContext context) {
    return _TemporaryCatalogImage(
      item: item,
      assetKey: assetKey,
      fallback: _GiftProductPlaceholder(item: item, full: true),
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
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 118,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? const Color(0xFF8A8B2E) : const Color(0xFFE8E7DB),
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: _TemporaryCatalogImage(
                  item: item,
                  fallback: _GiftProductPlaceholder(item: item),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              option.label,
              style: const TextStyle(
                color: Color(0xFF3A3E49),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              option.price,
              style: const TextStyle(
                color: Color(0xFF232835),
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GiftMetaChip extends StatelessWidget {
  const _GiftMetaChip({
    required this.icon,
    required this.label,
    required this.tint,
    required this.background,
  });

  final IconData icon;
  final String label;
  final Color tint;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: tint),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: tint,
              fontSize: 12.4,
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
    this.full = false,
  });

  final _DiscoveryItem item;
  final bool full;

  @override
  Widget build(BuildContext context) {
    final icon = _giftIconForItem(item.title);
    final colors = _giftGradientForItem(item.title, item.accent);
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            right: -18,
            top: -18,
            child: Container(
              width: full ? 170 : 110,
              height: full ? 170 : 110,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: -22,
            bottom: -30,
            child: Container(
              width: full ? 210 : 130,
              height: full ? 210 : 130,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Center(
            child: Icon(
              icon,
              size: full ? 108 : 56,
              color: Colors.white.withValues(alpha: 0.95),
            ),
          ),
        ],
      ),
    );
  }
}

class _GiftQuickPlaceholder extends StatelessWidget {
  const _GiftQuickPlaceholder({required this.item});

  final _GiftQuickCategoryData item;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            item.accent.withValues(alpha: 0.95),
            item.accent.withValues(alpha: 0.65),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          item.icon,
          size: 38,
          color: Colors.white,
        ),
      ),
    );
  }
}

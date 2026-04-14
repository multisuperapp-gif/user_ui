part of '../../../main.dart';

class _PharmacyCategoryShowcase extends StatelessWidget {
  const _PharmacyCategoryShowcase({
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

  List<_PharmacyCampaignSectionData> get _sections {
    final categories = selectedCategory == 'All'
        ? const ['Wellness', 'Baby care', 'Personal care', 'Essentials']
        : [selectedCategory];
    return categories
        .map((category) => _PharmacyCampaignSectionData(
              category: category,
              title: _pharmacyCampaignTitle(category),
              colors: _pharmacyCampaignColors(category),
              items: _sortedPharmacyItems(
                _pharmacyItemsForCategory(category),
                sortOption,
              ),
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final sections = _sections;
    return ColoredBox(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < sections.length; i++) ...[
            if (i == 0) const SizedBox(height: 10) else const SizedBox(height: 18),
            _PharmacyCampaignSection(
              data: sections[i],
              onItemTap: onItemTap,
              onShopTap: onShopTap,
              onAddToCart: onAddToCart,
              isWishlisted: isWishlisted,
              onWishlistToggle: onWishlistToggle,
            ),
          ],
          const SizedBox(height: 18),
        ],
      ),
    );
  }
}

class _PharmacyShopWiseSection extends StatelessWidget {
  const _PharmacyShopWiseSection({
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
    final shops = items.isEmpty ? _pharmacyShopWiseSeeds : items.take(8).toList();
    return ColoredBox(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'PHARMACY STORES',
              style: TextStyle(
                color: Color(0xFF7B8392),
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.6,
              ),
            ),
            const SizedBox(height: 10),
            for (final shop in shops) ...[
              _PharmacyShopWiseCard(
                item: shop,
                previewItems: _pharmacyItemsForCategory(
                  _shopSubcategoryFor(shop, 'Pharmacy'),
                  shopName: shop.title,
                ).take(4).toList(),
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

class _PharmacyCampaignSection extends StatelessWidget {
  const _PharmacyCampaignSection({
    required this.data,
    required this.onItemTap,
    required this.onShopTap,
    required this.onAddToCart,
    required this.isWishlisted,
    required this.onWishlistToggle,
  });

  final _PharmacyCampaignSectionData data;
  final ValueChanged<_DiscoveryItem> onItemTap;
  final ValueChanged<_DiscoveryItem> onShopTap;
  final ValueChanged<_DiscoveryItem> onAddToCart;
  final bool Function(_DiscoveryItem item) isWishlisted;
  final ValueChanged<_DiscoveryItem> onWishlistToggle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: data.colors,
          ),
          borderRadius: BorderRadius.circular(26),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: Align(
                alignment: _pharmacyCampaignTitleAlignment(data.category),
                child: Text(
                  data.title,
                  style: _pharmacyCampaignTitleStyle(data.category),
                ),
              ),
            ),
            const SizedBox(height: 8),
            GridView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: data.items.take(8).length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 10,
                mainAxisSpacing: 12,
                childAspectRatio: 0.66,
              ),
              itemBuilder: (context, index) {
                final item = data.items[index];
                return _PharmacyPromoGridTile(
                  item: item,
                  onTap: () => onItemTap(item),
                  onShopTap: () => onShopTap(item),
                  onAddToCart: () => onAddToCart(item),
                  isWishlisted: isWishlisted(item),
                  onWishlistToggle: () => onWishlistToggle(item),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PharmacyPromoGridTile extends StatelessWidget {
  const _PharmacyPromoGridTile({
    required this.item,
    required this.onTap,
    required this.onShopTap,
    required this.onAddToCart,
    required this.isWishlisted,
    required this.onWishlistToggle,
  });

  final _DiscoveryItem item;
  final VoidCallback onTap;
  final VoidCallback onShopTap;
  final VoidCallback onAddToCart;
  final bool isWishlisted;
  final VoidCallback onWishlistToggle;

  @override
  Widget build(BuildContext context) {
    final outOfStock = _isShopItemOutOfStock(item);
    return GestureDetector(
      onTap: onTap,
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
                      fallback: _SceneThumb(
                        title: item.title,
                        accent: item.accent,
                        compact: true,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: GestureDetector(
                    onTap: onWishlistToggle,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.88),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isWishlisted ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                        size: 13,
                        color: const Color(0xFF268B9C),
                      ),
                    ),
                  ),
                ),
                if (outOfStock)
                  const Positioned(
                    top: 6,
                    left: 6,
                    child: _OutOfStockBadge(compact: true),
                  ),
                Positioned(
                  left: 6,
                  right: 6,
                  bottom: 6,
                  child: GestureDetector(
                    onTap: outOfStock ? () {} : onAddToCart,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'ADD',
                            style: TextStyle(
                              color: Color(0xFF268B9C),
                              fontSize: 10.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.add_rounded, size: 14, color: Color(0xFF268B9C)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            item.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF222A3B),
              fontSize: 11.2,
              fontWeight: FontWeight.w800,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.price,
            style: const TextStyle(
              color: Color(0xFF222A3B),
              fontSize: 11.4,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _PharmacyShopWiseCard extends StatelessWidget {
  const _PharmacyShopWiseCard({
    required this.item,
    required this.previewItems,
    required this.isWishlisted,
    required this.onWishlistToggle,
    required this.onTap,
  });

  final _DiscoveryItem item;
  final List<_DiscoveryItem> previewItems;
  final bool isWishlisted;
  final VoidCallback onWishlistToggle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE7E9EE)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          color: Color(0xFF202A3E),
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Nearby pharmacy • ${item.distance}',
                        style: const TextStyle(
                          color: Color(0xFF6C7585),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: onWishlistToggle,
                  child: Icon(
                    isWishlisted ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                    color: const Color(0xFF268B9C),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: _ratingColor(item.rating),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded, size: 12, color: Colors.white),
                      const SizedBox(width: 3),
                      Text(
                        item.rating,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Promotion first • trusted essentials',
                  style: TextStyle(
                    color: Color(0xFF6C7585),
                    fontSize: 11.6,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 84,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: previewItems.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final preview = previewItems[index];
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SizedBox(
                      width: 76,
                      child: _TemporaryCatalogImage(
                        item: preview,
                        fallback: _SceneThumb(
                          title: preview.title,
                          accent: preview.accent,
                          compact: true,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PharmacyProfilePromoStrip extends StatelessWidget {
  const _PharmacyProfilePromoStrip({
    required this.items,
    required this.onTap,
  });

  final List<_DiscoveryItem> items;
  final ValueChanged<_DiscoveryItem> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF0FBFE),
            Color(0xFFEAF4FF),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Top pharmacy deals',
            style: TextStyle(
              color: Color(0xFF1E2636),
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 132,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final item = items[index];
                return GestureDetector(
                  onTap: () => onTap(item),
                  child: SizedBox(
                    width: 110,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: _TemporaryCatalogImage(
                              item: item,
                              fallback: _SceneThumb(
                                title: item.title,
                                accent: item.accent,
                                compact: true,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF273042),
                            fontSize: 11.3,
                            fontWeight: FontWeight.w800,
                            height: 1.08,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PharmacyProfileSectionHeader extends StatelessWidget {
  const _PharmacyProfileSectionHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF1E2636),
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: const TextStyle(
            color: Color(0xFF6B7484),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _PharmacyProfileItemCard extends StatelessWidget {
  const _PharmacyProfileItemCard({
    super.key,
    required this.item,
    required this.isWishlisted,
    required this.onTap,
    required this.onWishlistToggle,
    required this.onAddTap,
  });

  final _DiscoveryItem item;
  final bool isWishlisted;
  final VoidCallback onTap;
  final VoidCallback onWishlistToggle;
  final Future<bool> Function() onAddTap;

  @override
  Widget build(BuildContext context) {
    final outOfStock = _isShopItemOutOfStock(item);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.fromLTRB(6, 6, 6, 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFE7E9EE)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: _TemporaryCatalogImage(
                        item: item,
                        fallback: _SceneThumb(
                          title: item.title,
                          accent: item.accent,
                          compact: true,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: GestureDetector(
                      onTap: onWishlistToggle,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.88),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isWishlisted ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                          size: 11,
                          color: const Color(0xFF268B9C),
                        ),
                      ),
                    ),
                  ),
                  if (outOfStock)
                    const Positioned(
                      top: 6,
                      left: 6,
                      child: _OutOfStockBadge(compact: true),
                    ),
                  Positioned(
                    left: 6,
                    bottom: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        item.rating,
                        style: TextStyle(
                          color: _ratingColor(item.rating),
                          fontSize: 8.6,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              item.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF1F2635),
                fontSize: 8.8,
                fontWeight: FontWeight.w700,
                height: 1.02,
              ),
            ),
            const SizedBox(height: 3),
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.price,
                    style: const TextStyle(
                      color: Color(0xFF1F2635),
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => onAddTap(),
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: const Color(0xFF268B9C),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PharmacyPackChip extends StatelessWidget {
  const _PharmacyPackChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEFFAFE) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? const Color(0xFF268B9C) : const Color(0xFFE3E6EC),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? const Color(0xFF268B9C) : const Color(0xFF3A4150),
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

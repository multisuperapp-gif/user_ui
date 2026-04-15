part of '../../../main.dart';

class _GroceryCampaignSection extends StatelessWidget {
  const _GroceryCampaignSection({
    required this.data,
    required this.onItemTap,
    required this.onShopTap,
    required this.onAddToCart,
    required this.isWishlisted,
    required this.onWishlistToggle,
  });

  final _GroceryCampaignSectionData data;
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
                alignment: _groceryCampaignTitleAlignment(data.category),
                child: Text(
                  data.title,
                  style: _groceryCampaignTitleStyle(data.category),
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
                return _GroceryPromoGridTile(
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

class _GroceryPromoGridTile extends StatelessWidget {
  const _GroceryPromoGridTile({
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
                        color: const Color(0xFF2E8E45),
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
                              color: Color(0xFF26A05A),
                              fontSize: 10.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.add_rounded, size: 14, color: Color(0xFF26A05A)),
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

class _GroceryPackChip extends StatelessWidget {
  const _GroceryPackChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEFF9F1) : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? const Color(0xFF2E8E45) : const Color(0xFFE0E6DE),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? const Color(0xFF206534) : const Color(0xFF5A6370),
            fontSize: 12.4,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _GroceryProfilePromoStrip extends StatelessWidget {
  const _GroceryProfilePromoStrip({
    required this.items,
    required this.onTap,
  });

  final List<_DiscoveryItem> items;
  final ValueChanged<_DiscoveryItem> onTap;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF1FBF3), Color(0xFFFFFFFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFDCECDD)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recommended nearby',
            style: TextStyle(
              color: Color(0xFF202A3E),
              fontSize: 14.5,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Fast picks from this grocery store',
            style: TextStyle(
              color: Color(0xFF6B7482),
              fontSize: 12.2,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 96,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final item = items[index];
                return InkWell(
                  onTap: () => onTap(item),
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    width: 168,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: SizedBox(
                            width: 62,
                            height: 76,
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
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                item.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFF202A3E),
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                  height: 1.15,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                item.price,
                                style: const TextStyle(
                                  color: Color(0xFF2E8E45),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
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

class _GroceryProfileSectionHeader extends StatelessWidget {
  const _GroceryProfileSectionHeader({
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
            color: Color(0xFF202A3E),
            fontSize: 15.5,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: const TextStyle(
            color: Color(0xFF6D7685),
            fontSize: 12.1,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _GroceryProfileItemCard extends StatelessWidget {
  const _GroceryProfileItemCard({
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
      borderRadius: BorderRadius.circular(18),
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
                      width: 23,
                      height: 23,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.92),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isWishlisted ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                        size: 13,
                        color: const Color(0xFF2E8E45),
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
                  child: InkWell(
                    onTap: outOfStock ? null : () => onAddTap(),
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.94),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        outOfStock ? 'Unavailable' : 'ADD',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: outOfStock ? const Color(0xFF9AA1AD) : const Color(0xFF2E8E45),
                          fontSize: 10.8,
                          fontWeight: FontWeight.w900,
                        ),
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
              color: Color(0xFF202A3E),
              fontSize: 11.2,
              fontWeight: FontWeight.w800,
              height: 1.08,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.price,
            style: const TextStyle(
              color: Color(0xFF202A3E),
              fontSize: 11.6,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

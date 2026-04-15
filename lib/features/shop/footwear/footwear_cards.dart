part of '../../../main.dart';

class _FootwearInfiniteFeedSection extends StatelessWidget {
  const _FootwearInfiniteFeedSection({
    required this.items,
    required this.hasMore,
    required this.onTap,
    required this.isWishlisted,
    required this.onWishlistToggle,
  });

  final List<_FootwearFeedCardData> items;
  final bool hasMore;
  final ValueChanged<_DiscoveryItem> onTap;
  final bool Function(_DiscoveryItem item) isWishlisted;
  final ValueChanged<_DiscoveryItem> onWishlistToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(2, 0, 2, 4),
            child: Text(
              'MORE FROM NEARBY SHOPS',
              style: TextStyle(
                color: Color(0xFF7F8391),
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 3.2,
              ),
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 22,
              mainAxisExtent: 302,
            ),
            itemBuilder: (context, index) {
              final data = items[index];
              return _FootwearMarketplaceTile(
                data: data,
                isWishlisted: isWishlisted(data.item),
                onTap: () => onTap(data.item),
                onWishlistToggle: () => onWishlistToggle(data.item),
              );
            },
          ),
          if (hasMore)
            const Padding(
              padding: EdgeInsets.only(top: 18, bottom: 4),
              child: Center(
                child: Text(
                  'Scroll for next 20 items',
                  style: TextStyle(
                    color: Color(0xFF8A7180),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FootwearMarketplaceTile extends StatelessWidget {
  const _FootwearMarketplaceTile({
    required this.data,
    required this.isWishlisted,
    required this.onTap,
    required this.onWishlistToggle,
  });

  final _FootwearFeedCardData data;
  final bool isWishlisted;
  final VoidCallback onTap;
  final VoidCallback onWishlistToggle;

  @override
  Widget build(BuildContext context) {
    final item = data.item;
    final outOfStock = _isShopItemOutOfStock(item);
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F3F3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  _TemporaryCatalogImage(
                    item: item,
                    fallback: _SceneThumb(title: item.title, accent: item.accent),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.04),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (data.promoted)
                    Positioned(
                      left: 0,
                      bottom: 20,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F8B78).withValues(alpha: 0.94),
                          borderRadius: const BorderRadius.horizontal(right: Radius.circular(10)),
                        ),
                        child: const Text(
                          'Top Rated',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    left: 8,
                    bottom: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            item.rating,
                            style: const TextStyle(
                              color: Color(0xFF252B36),
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              height: 1,
                            ),
                          ),
                          const SizedBox(width: 3),
                          Icon(Icons.star_rounded, size: 11, color: _ratingColor(item.rating)),
                          Container(
                            width: 1,
                            height: 11,
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            color: const Color(0xFFC8C8C8),
                          ),
                          Text(
                            data.votes,
                            style: const TextStyle(
                              color: Color(0xFF6C7280),
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              height: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (outOfStock)
                    const Positioned(
                      left: 8,
                      top: 8,
                      child: _OutOfStockBadge(compact: true),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  item.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF2C3140),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onWishlistToggle,
                child: Icon(
                  isWishlisted ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  size: 22,
                  color: isWishlisted ? const Color(0xFFE73A5A) : const Color(0xFF6C7280),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            item.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF6F7481),
              fontSize: 12,
              fontWeight: FontWeight.w500,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Text(
                item.price,
                style: const TextStyle(
                  color: Color(0xFF2C3140),
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                data.oldPrice,
                style: const TextStyle(
                  color: Color(0xFF9CA0AA),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.lineThrough,
                  height: 1,
                ),
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  data.discount,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFE86E32),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          RichText(
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              style: const TextStyle(
                color: Color(0xFF586070),
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                height: 1,
              ),
              children: [
                TextSpan(
                  text: 'Best Price ${data.couponPrice}',
                  style: const TextStyle(
                    color: Color(0xFF009B73),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const TextSpan(text: ' with coupon'),
              ],
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Get it by Tomorrow',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Color(0xFF393F4D),
              fontSize: 11.2,
              fontWeight: FontWeight.w500,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

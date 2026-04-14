part of '../../../main.dart';

class _FootwearProductCard extends StatelessWidget {
  const _FootwearProductCard({
    required this.data,
    required this.isWishlisted,
    required this.onTap,
    required this.onWishlistToggle,
    required this.onAddToCart,
  });

  final _FootwearCardData data;
  final bool isWishlisted;
  final VoidCallback onTap;
  final VoidCallback onWishlistToggle;
  final VoidCallback onAddToCart;

  @override
  Widget build(BuildContext context) {
    final item = data.item;
    final label = _footwearCardLabel(item.title);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE7E7E7)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned.fill(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 22,
                    child: Center(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF171B25),
                          fontSize: 5.5,
                          fontWeight: FontWeight.w400,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
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
                                  Colors.black.withValues(alpha: 0.14),
                                ],
                              ),
                            ),
                          ),
                        ),
                        if (data.discount.isNotEmpty)
                          Positioned(
                            left: 8,
                            bottom: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE83E4D).withValues(alpha: 0.96),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                data.discount,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  height: 1,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.price,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF232838),
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              height: 1,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: _ratingColor(item.rating),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star_rounded, size: 7, color: Colors.white),
                              const SizedBox(width: 2),
                              Text(
                                item.rating,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 7,
                                  fontWeight: FontWeight.w800,
                                  height: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 8,
              top: 30,
              child: _RoundActionIcon(
                icon: isWishlisted ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                color: item.accent,
                onTap: onWishlistToggle,
                size: 28,
                iconSize: 15,
              ),
            ),
            Positioned(
              right: 8,
              bottom: 34,
              child: _RoundActionIcon(
                icon: Icons.add_rounded,
                color: const Color(0xFF22314D),
                onTap: onAddToCart,
                size: 28,
                iconSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BudgetFriendlyFootwearSection extends StatelessWidget {
  const _BudgetFriendlyFootwearSection({
    required this.items,
    required this.onTap,
  });

  final List<_FootwearCardData> items;
  final ValueChanged<_DiscoveryItem> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF5FFFC),
            Color(0xFFDCF8F1),
            Color(0xFFF5FFFC),
          ],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 18),
      child: Column(
        children: [
          const Text(
            'Budget-Friendly Picks 👟',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF0B7A69),
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.1,
              height: 1,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 306,
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 16,
                mainAxisExtent: 132,
              ),
              itemBuilder: (context, index) {
                final card = items[index];
                return _BudgetFootwearTile(
                  data: card,
                  onTap: () => onTap(card.item),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: 58,
            height: 6,
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Container(
              width: 20,
              height: 6,
              decoration: BoxDecoration(
                color: const Color(0xFF515765),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BudgetFootwearTile extends StatelessWidget {
  const _BudgetFootwearTile({
    required this.data,
    required this.onTap,
  });

  final _FootwearCardData data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final item = data.item;
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          fit: StackFit.expand,
          children: [
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
                      Colors.black.withValues(alpha: 0.02),
                      Colors.black.withValues(alpha: 0.2),
                      Colors.black.withValues(alpha: 0.7),
                    ],
                    stops: const [0.2, 0.58, 1],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 12,
              right: 10,
              bottom: 11,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Under',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.price,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      height: 1,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      height: 1,
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

String _footwearCardLabel(String title) {
  final text = title.toLowerCase();
  if (text.contains('formal')) return 'Formal Shoes';
  if (text.contains('sneaker')) return 'Sneakers';
  if (text.contains('slipper')) return 'Slippers';
  if (text.contains('loafer')) return 'Loafers';
  if (text.contains('heel')) return 'Heels';
  if (text.contains('flat')) return 'Flats';
  if (text.contains('sandal')) return 'Sandals';
  if (text.contains('slide')) return 'Slides';
  if (text.contains('boot')) return 'Boots';
  if (text.contains('school')) return 'School Shoes';
  if (text.contains('sport')) return 'Sports Shoes';
  return title;
}

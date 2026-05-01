part of '../../main.dart';

class _HorizontalDiscoverySection extends StatefulWidget {
  const _HorizontalDiscoverySection({
    required this.title,
    required this.caption,
    required this.items,
    required this.onTap,
    required this.isWishlisted,
    required this.isFavourited,
    required this.onWishlistToggle,
    required this.onFavouriteToggle,
    required this.onAddToCart,
  });

  final String title;
  final String caption;
  final List<_DiscoveryItem> items;
  final ValueChanged<_DiscoveryItem> onTap;
  final bool Function(_DiscoveryItem item) isWishlisted;
  final bool Function(_DiscoveryItem item) isFavourited;
  final ValueChanged<_DiscoveryItem> onWishlistToggle;
  final ValueChanged<_DiscoveryItem> onFavouriteToggle;
  final ValueChanged<_DiscoveryItem> onAddToCart;

  @override
  State<_HorizontalDiscoverySection> createState() => _HorizontalDiscoverySectionState();
}

class _HorizontalDiscoverySectionState extends State<_HorizontalDiscoverySection> {
  late final ScrollController _controller;
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (!_controller.hasClients) {
        return;
      }
      final maxScroll = _controller.position.maxScrollExtent;
      if (maxScroll <= 0) {
        return;
      }
      final nextOffset = _controller.offset + 108;
      _controller.animateTo(
        nextOffset >= maxScroll ? 0 : nextOffset,
        duration: const Duration(milliseconds: 650),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isShopSpotlight = widget.title == 'Most shopped';
    return Padding(
      padding: EdgeInsets.fromLTRB(0, isShopSpotlight ? 0 : 14, 0, 0),
      child: Container(
        padding: EdgeInsets.fromLTRB(18, isShopSpotlight ? 2 : 12, 0, 18),
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isShopSpotlight)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF7EE),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.storefront_rounded,
                          size: 14,
                          color: Color(0xFF2D9F5A),
                        ),
                        SizedBox(width: 5),
                        Text(
                          'SHOP SPOTLIGHT',
                          style: TextStyle(
                            color: Color(0xFF216E3E),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                            height: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.title,
                    style: const TextStyle(
                      color: Color(0xFF183A28),
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.3,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 84,
                    height: 4,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF2D9F5A),
                          Color(0xFF8DDEAB),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ],
              )
            else
              Text(
                widget.title,
                style: const TextStyle(
                  color: Color(0xFFB9312F),
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.1,
                  height: 1,
                ),
              ),
            const SizedBox(height: 12),
            SizedBox(
              height: 316,
              child: GridView.builder(
                controller: _controller,
                padding: const EdgeInsets.only(right: 18),
                scrollDirection: Axis.horizontal,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 12,
                  mainAxisExtent: 112,
                ),
                itemCount: widget.items.length.clamp(0, 8),
                itemBuilder: (context, index) => _CompactDiscoveryTile(
                  item: widget.items[index],
                  onTap: () => widget.onTap(widget.items[index]),
                  isWishlisted: widget.isWishlisted(widget.items[index]),
                  isFavourited: widget.isFavourited(widget.items[index]),
                  onWishlistToggle: () => widget.onWishlistToggle(widget.items[index]),
                  onFavouriteToggle: () => widget.onFavouriteToggle(widget.items[index]),
                  onAddToCart: () => widget.onAddToCart(widget.items[index]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShopSingleRowSection extends StatelessWidget {
  const _ShopSingleRowSection({
    required this.title,
    required this.items,
    required this.onTap,
    required this.isWishlisted,
    required this.isFavourited,
    required this.onWishlistToggle,
    required this.onFavouriteToggle,
    required this.onAddToCart,
  });

  final String title;
  final List<_DiscoveryItem> items;
  final ValueChanged<_DiscoveryItem> onTap;
  final bool Function(_DiscoveryItem item) isWishlisted;
  final bool Function(_DiscoveryItem item) isFavourited;
  final ValueChanged<_DiscoveryItem> onWishlistToggle;
  final ValueChanged<_DiscoveryItem> onFavouriteToggle;
  final ValueChanged<_DiscoveryItem> onAddToCart;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF7EE),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.restaurant_menu_rounded,
                        size: 14,
                        color: Color(0xFF2D9F5A),
                      ),
                      SizedBox(width: 5),
                      Text(
                        'FOOD SPOTLIGHT',
                        style: TextStyle(
                          color: Color(0xFF216E3E),
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF183A28),
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.2,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 86,
                  height: 4,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF2D9F5A),
                        Color(0xFF8DDEAB),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 182,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final item = items[index];
                return SizedBox(
                  width: 126,
                  child: _CompactDiscoveryTile(
                    item: item,
                    onTap: () => onTap(item),
                    isWishlisted: isWishlisted(item),
                    isFavourited: isFavourited(item),
                    onWishlistToggle: () => onWishlistToggle(item),
                    onFavouriteToggle: () => onFavouriteToggle(item),
                    onAddToCart: () => onAddToCart(item),
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

class _CompactDiscoveryTile extends StatelessWidget {
  const _CompactDiscoveryTile({
    required this.item,
    required this.onTap,
    required this.isWishlisted,
    required this.isFavourited,
    required this.onWishlistToggle,
    required this.onFavouriteToggle,
    required this.onAddToCart,
  });

  final _DiscoveryItem item;
  final VoidCallback onTap;
  final bool isWishlisted;
  final bool isFavourited;
  final VoidCallback onWishlistToggle;
  final VoidCallback onFavouriteToggle;
  final VoidCallback onAddToCart;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: _ImageBackedShopTile(item: item),
    );
  }
}

class _VerticalShopCard extends StatelessWidget {
  const _VerticalShopCard({
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
    final outOfStock = _isShopItemOutOfStock(item);
    final isServiceProviderCard = item.backendServiceProviderId != null;
    final serviceBadgeColor = const Color(0xFF4DAF50);
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
      child: InkWell(
        onTap: item.isDisabled ? null : onTap,
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.20),
                    blurRadius: 70,
                    spreadRadius: -20,
                    offset: const Offset(0, 58),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 34,
                    spreadRadius: -10,
                    offset: const Offset(0, 24),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 12,
                    spreadRadius: -4,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: isServiceProviderCard ? CrossAxisAlignment.start : CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 74,
                    height: 74,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: _TemporaryCatalogImage(
                        item: item,
                        fallback: _SceneThumb(
                          title: item.subtitle,
                          accent: item.accent,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: isServiceProviderCard ? 38 : 26,
                        top: isServiceProviderCard ? 1 : 0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF22314D),
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                              height: 1.05,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF69778E),
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(height: isServiceProviderCard ? 10 : 6),
                          if (isServiceProviderCard)
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: [
                                if (item.hasRating)
                                  SizedBox(
                                    width: 62,
                                    child: _ServiceInlineMetaPill(
                                      icon: Icons.star_rounded,
                                      value: item.rating,
                                      color: _ratingColor(item.rating),
                                    ),
                                  ),
                                if (item.distance.trim().isNotEmpty)
                                  SizedBox(
                                    width: 78,
                                    child: _ServiceInlineMetaPill(
                                      icon: Icons.place_rounded,
                                      value: item.distance,
                                      color: const Color(0xFF5C8FD8),
                                    ),
                                  ),
                                SizedBox(
                                  width: 82,
                                  child: _ServiceInlineMetaPill(
                                    icon: Icons.work_history_rounded,
                                    value: '${item.completedJobsCount ?? 0} bookings',
                                    color: serviceBadgeColor,
                                  ),
                                ),
                              ],
                            )
                          else
                            Row(
                              children: [
                                Expanded(
                                  flex: 11,
                                  child: _ServiceInlineMetaPill(
                                    icon: Icons.place_rounded,
                                    value: item.distance,
                                    color: const Color(0xFF5C8FD8),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  flex: 14,
                                  child: _ServiceInlineMetaPill(
                                    icon: Icons.currency_rupee_rounded,
                                    value: item.price,
                                    color: item.accent,
                                  ),
                                ),
                                if (item.hasRating) ...[
                                  const SizedBox(width: 4),
                                  Expanded(
                                    flex: 10,
                                    child: _ServiceInlineMetaPill(
                                      icon: Icons.star_rounded,
                                      value: item.rating,
                                      color: _ratingColor(item.rating),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: _RoundActionIcon(
                icon: isWishlisted ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                color: const Color(0xFF4DAF50),
                onTap: onWishlistToggle,
                size: 28,
                iconSize: 15,
              ),
            ),
            if (outOfStock)
              const Positioned(
                left: 10,
                top: 10,
                child: _OutOfStockBadge(compact: true),
              ),
            if (item.isDisabled && item.disabledLabel.trim().isNotEmpty)
              Positioned(
                left: 10,
                top: outOfStock ? 38 : 10,
                child: _AvailabilityBadge(
                  label: item.disabledLabel,
                  compact: true,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

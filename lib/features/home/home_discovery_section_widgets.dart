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

class _ShopBeautySection extends StatelessWidget {
  const _ShopBeautySection({
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
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(top: 10, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _ShopSectionTitle(
            title: 'Beauty',
            pillText: 'BEAUTY PICKS',
            pillColor: Color(0xFFFFF2D8),
            icon: Icons.spa_rounded,
            accentStart: Color(0xFFF29F38),
            accentEnd: Color(0xFFFFD696),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              const horizontalPadding = 18.0;
              const gap = 12.0;
              final cardWidth =
                  ((constraints.maxWidth - (horizontalPadding * 2) - gap) / 2).clamp(120.0, 220.0);
              return SizedBox(
                height: 274,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
                  scrollDirection: Axis.horizontal,
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(width: gap),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return SizedBox(
                      width: cardWidth,
                      child: _BeautyOfferCard(
                        item: item,
                        offerText: _beautyOfferText(item, index),
                        onTap: () => onTap(item),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _BeautyOfferCard extends StatelessWidget {
  const _BeautyOfferCard({
    required this.item,
    required this.offerText,
    required this.onTap,
  });

  final _DiscoveryItem item;
  final String offerText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E1DB)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _TemporaryCatalogImage(
                      item: item,
                      fallback: _SceneThumb(
                        title: item.title,
                        accent: item.accent,
                        compact: true,
                      ),
                    ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.08),
                              Colors.black.withValues(alpha: 0.72),
                            ],
                            stops: const [0.45, 0.72, 1],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 10,
                      right: 10,
                      bottom: 10,
                      child: Text(
                        offerText,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11.8,
                          fontWeight: FontWeight.w900,
                          height: 1.02,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
              child: Text(
                item.subtitle.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF6A6276),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.4,
                  height: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShopMedicineSection extends StatelessWidget {
  const _ShopMedicineSection({
    required this.items,
    required this.onTap,
  });

  final List<_DiscoveryItem> items;
  final ValueChanged<_DiscoveryItem> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(top: 10, bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _ShopSectionTitle(
            title: 'Common medicines',
            pillText: 'DAILY CARE',
            pillColor: Color(0xFFEAF3FF),
            icon: Icons.local_pharmacy_rounded,
            accentStart: Color(0xFF4C7EDB),
            accentEnd: Color(0xFF8FB6FF),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 194,
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
              scrollDirection: Axis.horizontal,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 12,
                mainAxisExtent: 92,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return _MedicineMiniTile(
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

class _MedicineMiniTile extends StatelessWidget {
  const _MedicineMiniTile({
    required this.item,
    required this.onTap,
  });

  final _DiscoveryItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE6E1DA)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(6, 6, 6, 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _TemporaryCatalogImage(
                        item: item,
                        fallback: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                item.accent.withValues(alpha: 0.20),
                                item.accent.withValues(alpha: 0.08),
                              ],
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              item.icon,
                              size: 28,
                              color: item.accent,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 4,
                        top: 4,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            item.icon,
                            size: 10,
                            color: item.accent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                item.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF2A3040),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  height: 1.06,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.price,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: item.accent,
                  fontSize: 10.8,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
      child: InkWell(
        onTap: onTap,
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
                      padding: const EdgeInsets.only(right: 26),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.subtitle,
                            style: const TextStyle(
                              color: Color(0xFF22314D),
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
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
                          const SizedBox(height: 6),
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
          ],
        ),
      ),
    );
  }
}

String _beautyOfferText(_DiscoveryItem item, int index) {
  const offers = [
    'UP TO 35% OFF',
    'MIN. 35% OFF',
    'MIN. 50% OFF',
    'UP TO 60% OFF',
    'UP TO 40% OFF',
    'MIN. 45% OFF',
  ];
  final label = item.title.split(' ').take(2).join(' ');
  return '${offers[index % offers.length]}\n$label';
}

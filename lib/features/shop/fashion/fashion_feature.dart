part of '../../../main.dart';

class _ShopFashionPanelsSection extends StatelessWidget {
  const _ShopFashionPanelsSection({
    required this.panels,
    required this.onTap,
  });

  final List<(String, Color, Color, List<_DiscoveryItem>)> panels;
  final ValueChanged<_DiscoveryItem> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _ShopSectionTitle(
            title: 'Fashion',
            pillText: 'STYLE PICKS',
            pillColor: Color(0xFFFBEAF2),
            icon: Icons.checkroom_rounded,
            accentStart: Color(0xFFDF7DA0),
            accentEnd: Color(0xFFF6B7CC),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 296,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
              scrollDirection: Axis.horizontal,
              itemCount: panels.length,
              separatorBuilder: (_, _) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                final panel = panels[index];
                return _ServiceDealsPanel(
                  title: panel.$1,
                  startColor: panel.$2,
                  endColor: panel.$3,
                  items: panel.$4,
                  onTap: onTap,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FashionCategoryShowcase extends StatelessWidget {
  const _FashionCategoryShowcase({
    required this.selectedCategory,
    required this.onTap,
    required this.onAddToCart,
    required this.isWishlisted,
    required this.onWishlistToggle,
    required this.visibleFeedCount,
    required this.sortOption,
  });

  final String selectedCategory;
  final ValueChanged<_DiscoveryItem> onTap;
  final ValueChanged<_DiscoveryItem> onAddToCart;
  final bool Function(_DiscoveryItem item) isWishlisted;
  final ValueChanged<_DiscoveryItem> onWishlistToggle;
  final int visibleFeedCount;
  final String sortOption;

  List<_FashionCardData> get _items {
    final category = selectedCategory == 'All' ? 'Men' : selectedCategory;
    return switch (category) {
      'Women' => const [
          _FashionCardData(
            item: _DiscoveryItem(
              title: 'Silk Saree',
              subtitle: 'Women',
              accent: Color(0xFFE75D93),
              icon: Icons.style_rounded,
              price: '₹1,899',
              rating: '4.8',
              distance: '1.4 km',
            ),
            discount: '20% OFF',
          ),
          _FashionCardData(
            item: _DiscoveryItem(
              title: 'Cotton Kurti',
              subtitle: 'Women',
              accent: Color(0xFFE75D93),
              icon: Icons.checkroom_rounded,
              price: '₹749',
              rating: '4.7',
              distance: '1.1 km',
            ),
            discount: '10% OFF',
          ),
          _FashionCardData(
            item: _DiscoveryItem(
              title: 'Festive Lehenga',
              subtitle: 'Women',
              accent: Color(0xFFC65AF0),
              icon: Icons.auto_awesome_rounded,
              price: '₹2,499',
              rating: '4.6',
              distance: '1.8 km',
            ),
          ),
          _FashionCardData(
            item: _DiscoveryItem(
              title: 'Floral Dress',
              subtitle: 'Women',
              accent: Color(0xFFFF7DA7),
              icon: Icons.style_rounded,
              price: '₹1,199',
              rating: '4.6',
              distance: '1.6 km',
            ),
            discount: '15% OFF',
          ),
        ],
      'Boys' => const [
          _FashionCardData(
            item: _DiscoveryItem(
              title: 'Boys Party Shirt',
              subtitle: 'Boys',
              accent: Color(0xFF3E7BD6),
              icon: Icons.boy_rounded,
              price: '₹549',
              rating: '4.6',
              distance: '1.2 km',
            ),
            discount: '10% OFF',
          ),
          _FashionCardData(
            item: _DiscoveryItem(
              title: 'Denim Shorts',
              subtitle: 'Boys',
              accent: Color(0xFF5C8FD8),
              icon: Icons.checkroom_rounded,
              price: '₹399',
              rating: '4.5',
              distance: '1.3 km',
            ),
          ),
          _FashionCardData(
            item: _DiscoveryItem(
              title: 'School Shoes',
              subtitle: 'Boys',
              accent: Color(0xFF2D8ACB),
              icon: Icons.hiking_rounded,
              price: '₹699',
              rating: '4.7',
              distance: '1.6 km',
            ),
            discount: '20% OFF',
          ),
        ],
      'Girls' => const [
          _FashionCardData(
            item: _DiscoveryItem(
              title: 'Girls Frock',
              subtitle: 'Girls',
              accent: Color(0xFFE75D93),
              icon: Icons.girl_rounded,
              price: '₹699',
              rating: '4.8',
              distance: '1.2 km',
            ),
            discount: '20% OFF',
          ),
          _FashionCardData(
            item: _DiscoveryItem(
              title: 'Party Gown',
              subtitle: 'Girls',
              accent: Color(0xFFFF8DB5),
              icon: Icons.auto_awesome_rounded,
              price: '₹1,199',
              rating: '4.6',
              distance: '1.7 km',
            ),
          ),
          _FashionCardData(
            item: _DiscoveryItem(
              title: 'Cute Top Set',
              subtitle: 'Girls',
              accent: Color(0xFFDF7DA0),
              icon: Icons.checkroom_rounded,
              price: '₹499',
              rating: '4.7',
              distance: '1.5 km',
            ),
            discount: '10% OFF',
          ),
        ],
      _ => const [
          _FashionCardData(
            item: _DiscoveryItem(
              title: 'Casual Shirt',
              subtitle: 'Men',
              accent: Color(0xFF3E7BD6),
              icon: Icons.man_rounded,
              price: '₹599',
              rating: '4.7',
              distance: '1.2 km',
            ),
            discount: '20% OFF',
          ),
          _FashionCardData(
            item: _DiscoveryItem(
              title: 'Denim Jeans',
              subtitle: 'Men',
              accent: Color(0xFF5C8FD8),
              icon: Icons.dry_cleaning_rounded,
              price: '₹899',
              rating: '4.6',
              distance: '1.2 km',
            ),
          ),
          _FashionCardData(
            item: _DiscoveryItem(
              title: 'Formal Blazer',
              subtitle: 'Men',
              accent: Color(0xFF22314D),
              icon: Icons.checkroom_rounded,
              price: '₹1,999',
              rating: '4.8',
              distance: '1.5 km',
            ),
            discount: '10% OFF',
          ),
          _FashionCardData(
            item: _DiscoveryItem(
              title: 'Formal Shoes',
              subtitle: 'Men',
              accent: Color(0xFF5C8FD8),
              icon: Icons.hiking_rounded,
              price: '₹1,299',
              rating: '4.5',
              distance: '1.7 km',
            ),
          ),
        ],
    };
  }

  List<_FashionCardData> get _budgetItems {
    final category = selectedCategory == 'All' ? 'Men' : selectedCategory;
    return switch (category) {
      'Women' => const [
          _FashionCardData(item: _DiscoveryItem(title: 'Handbags', subtitle: 'Women', accent: Color(0xFFE75D93), icon: Icons.shopping_bag_rounded, price: '₹1049', rating: '4.7')),
          _FashionCardData(item: _DiscoveryItem(title: 'Sweaters', subtitle: 'Women', accent: Color(0xFF98A7B8), icon: Icons.checkroom_rounded, price: '₹799', rating: '4.5')),
          _FashionCardData(item: _DiscoveryItem(title: 'Earrings', subtitle: 'Women', accent: Color(0xFFC69B48), icon: Icons.diamond_rounded, price: '₹399', rating: '4.6')),
          _FashionCardData(item: _DiscoveryItem(title: 'Kurtis', subtitle: 'Women', accent: Color(0xFFE75D93), icon: Icons.style_rounded, price: '₹649', rating: '4.8')),
          _FashionCardData(item: _DiscoveryItem(title: 'Sarees', subtitle: 'Women', accent: Color(0xFFB45DE8), icon: Icons.auto_awesome_rounded, price: '₹1249', rating: '4.7')),
          _FashionCardData(item: _DiscoveryItem(title: 'Casual Shoes', subtitle: 'Women', accent: Color(0xFF6A7C91), icon: Icons.hiking_rounded, price: '₹1249', rating: '4.5')),
        ],
      'Boys' => const [
          _FashionCardData(item: _DiscoveryItem(title: 'Shirts', subtitle: 'Boys', accent: Color(0xFF3E7BD6), icon: Icons.boy_rounded, price: '₹649', rating: '4.6')),
          _FashionCardData(item: _DiscoveryItem(title: 'Casual Shoes', subtitle: 'Boys', accent: Color(0xFF6A7C91), icon: Icons.hiking_rounded, price: '₹1249', rating: '4.5')),
          _FashionCardData(item: _DiscoveryItem(title: 'Sweatshirts', subtitle: 'Boys', accent: Color(0xFFC88B22), icon: Icons.checkroom_rounded, price: '₹649', rating: '4.7')),
          _FashionCardData(item: _DiscoveryItem(title: 'T-Shirts', subtitle: 'Boys', accent: Color(0xFF5C8FD8), icon: Icons.checkroom_rounded, price: '₹449', rating: '4.5')),
          _FashionCardData(item: _DiscoveryItem(title: 'Jeans', subtitle: 'Boys', accent: Color(0xFF24314B), icon: Icons.dry_cleaning_rounded, price: '₹799', rating: '4.4')),
        ],
      'Girls' => const [
          _FashionCardData(item: _DiscoveryItem(title: 'Frocks', subtitle: 'Girls', accent: Color(0xFFE75D93), icon: Icons.girl_rounded, price: '₹649', rating: '4.8')),
          _FashionCardData(item: _DiscoveryItem(title: 'Gowns', subtitle: 'Girls', accent: Color(0xFFFF8DB5), icon: Icons.auto_awesome_rounded, price: '₹999', rating: '4.6')),
          _FashionCardData(item: _DiscoveryItem(title: 'Tops', subtitle: 'Girls', accent: Color(0xFFDF7DA0), icon: Icons.checkroom_rounded, price: '₹449', rating: '4.5')),
          _FashionCardData(item: _DiscoveryItem(title: 'Casual Shoes', subtitle: 'Girls', accent: Color(0xFF6A7C91), icon: Icons.hiking_rounded, price: '₹1249', rating: '4.4')),
          _FashionCardData(item: _DiscoveryItem(title: 'Hair Clips', subtitle: 'Girls', accent: Color(0xFFC69B48), icon: Icons.diamond_rounded, price: '₹199', rating: '4.5')),
        ],
      _ => const [
          _FashionCardData(item: _DiscoveryItem(title: 'Shirts', subtitle: 'Men', accent: Color(0xFF5C8FD8), icon: Icons.man_rounded, price: '₹649', rating: '4.7')),
          _FashionCardData(item: _DiscoveryItem(title: 'Casual Shoes', subtitle: 'Men', accent: Color(0xFF6A7C91), icon: Icons.hiking_rounded, price: '₹1249', rating: '4.5')),
          _FashionCardData(item: _DiscoveryItem(title: 'Sweatshirts', subtitle: 'Men', accent: Color(0xFFC88B22), icon: Icons.checkroom_rounded, price: '₹649', rating: '4.6')),
          _FashionCardData(item: _DiscoveryItem(title: 'T-Shirts', subtitle: 'Men', accent: Color(0xFF3E7BD6), icon: Icons.checkroom_rounded, price: '₹449', rating: '4.5')),
          _FashionCardData(item: _DiscoveryItem(title: 'Jeans', subtitle: 'Men', accent: Color(0xFF24314B), icon: Icons.dry_cleaning_rounded, price: '₹899', rating: '4.4')),
          _FashionCardData(item: _DiscoveryItem(title: 'Blazers', subtitle: 'Men', accent: Color(0xFF22314D), icon: Icons.checkroom_rounded, price: '₹1999', rating: '4.8')),
        ],
    };
  }

  List<_FashionFeedCardData> get _feedTemplates {
    final category = selectedCategory == 'All' ? 'Men' : selectedCategory;
    return switch (category) {
      'Women' => const [
          _FashionFeedCardData(item: _DiscoveryItem(title: 'Silk Kurti Set', subtitle: 'Grace House', accent: Color(0xFFE75D93), icon: Icons.style_rounded, price: '₹799', rating: '4.5'), oldPrice: '₹1,399', couponPrice: '₹699', discount: '43% OFF', votes: '8.7k', promoted: true),
          _FashionFeedCardData(item: _DiscoveryItem(title: 'Cotton Saree', subtitle: 'Bloom Boutique', accent: Color(0xFFB45DE8), icon: Icons.auto_awesome_rounded, price: '₹1,099', rating: '4.4'), oldPrice: '₹2,199', couponPrice: '₹999', discount: '50% OFF', votes: '6.1k'),
          _FashionFeedCardData(item: _DiscoveryItem(title: 'Floral Dress', subtitle: 'Style Studio', accent: Color(0xFFE75D93), icon: Icons.checkroom_rounded, price: '₹999', rating: '4.6'), oldPrice: '₹1,899', couponPrice: '₹899', discount: '47% OFF', votes: '4.8k', promoted: true),
          _FashionFeedCardData(item: _DiscoveryItem(title: 'Party Top', subtitle: 'Carry Charm', accent: Color(0xFFFF7DA7), icon: Icons.checkroom_rounded, price: '₹549', rating: '4.1'), oldPrice: '₹999', couponPrice: '₹499', discount: '45% OFF', votes: '1.9k'),
        ],
      'Boys' => const [
          _FashionFeedCardData(item: _DiscoveryItem(title: 'Boys Track Pants', subtitle: 'Tiny Trends', accent: Color(0xFF3E7BD6), icon: Icons.boy_rounded, price: '₹499', rating: '4.2'), oldPrice: '₹899', couponPrice: '₹449', discount: '44% OFF', votes: '879', promoted: true),
          _FashionFeedCardData(item: _DiscoveryItem(title: 'Printed Shirt', subtitle: 'Urban Wear', accent: Color(0xFF5C8FD8), icon: Icons.checkroom_rounded, price: '₹599', rating: '4.5'), oldPrice: '₹1,099', couponPrice: '₹529', discount: '45% OFF', votes: '2.1k'),
          _FashionFeedCardData(item: _DiscoveryItem(title: 'Denim Jeans', subtitle: 'Style Studio', accent: Color(0xFF22314D), icon: Icons.dry_cleaning_rounded, price: '₹799', rating: '4.3'), oldPrice: '₹1,499', couponPrice: '₹699', discount: '47% OFF', votes: '937'),
          _FashionFeedCardData(item: _DiscoveryItem(title: 'School Shoes', subtitle: 'Step Up', accent: Color(0xFF2D8ACB), icon: Icons.hiking_rounded, price: '₹699', rating: '4.0'), oldPrice: '₹1,299', couponPrice: '₹629', discount: '46% OFF', votes: '1.3k'),
        ],
      'Girls' => const [
          _FashionFeedCardData(item: _DiscoveryItem(title: 'Party Frock', subtitle: 'Tiny Trends', accent: Color(0xFFE75D93), icon: Icons.girl_rounded, price: '₹699', rating: '4.7'), oldPrice: '₹1,299', couponPrice: '₹649', discount: '46% OFF', votes: '2.8k', promoted: true),
          _FashionFeedCardData(item: _DiscoveryItem(title: 'Cute Top Set', subtitle: 'Bloom Boutique', accent: Color(0xFFDF7DA0), icon: Icons.checkroom_rounded, price: '₹549', rating: '4.3'), oldPrice: '₹999', couponPrice: '₹499', discount: '45% OFF', votes: '1.1k'),
          _FashionFeedCardData(item: _DiscoveryItem(title: 'Kids Gown', subtitle: 'Grace House', accent: Color(0xFFFF8DB5), icon: Icons.auto_awesome_rounded, price: '₹999', rating: '4.6'), oldPrice: '₹1,899', couponPrice: '₹899', discount: '47% OFF', votes: '2.0k'),
          _FashionFeedCardData(item: _DiscoveryItem(title: 'Hair Clip Combo', subtitle: 'Carry Charm', accent: Color(0xFFC69B48), icon: Icons.diamond_rounded, price: '₹199', rating: '4.1'), oldPrice: '₹399', couponPrice: '₹179', discount: '50% OFF', votes: '876'),
        ],
      _ => const [
          _FashionFeedCardData(item: _DiscoveryItem(title: 'Solid Track Pants', subtitle: 'Jockey', accent: Color(0xFF22314D), icon: Icons.man_rounded, price: '₹999', rating: '4.5'), oldPrice: '₹1,499', couponPrice: '₹699', discount: '33% OFF', votes: '8.7k', promoted: true),
          _FashionFeedCardData(item: _DiscoveryItem(title: 'Formal Trouser', subtitle: 'Arrow', accent: Color(0xFF3E7BD6), icon: Icons.dry_cleaning_rounded, price: '₹1,199', rating: '3.8'), oldPrice: '₹2,399', couponPrice: '₹899', discount: '50% OFF', votes: '9'),
          _FashionFeedCardData(item: _DiscoveryItem(title: 'Cotton Overshirt', subtitle: 'VASTRADO', accent: Color(0xFFC88B22), icon: Icons.checkroom_rounded, price: '₹899', rating: '4.6'), oldPrice: '₹1,899', couponPrice: '₹799', discount: '52% OFF', votes: '79', promoted: true),
          _FashionFeedCardData(item: _DiscoveryItem(title: 'Pure Cotton Jeans', subtitle: 'Roadster', accent: Color(0xFF6A7C91), icon: Icons.dry_cleaning_rounded, price: '₹1,049', rating: '3.9'), oldPrice: '₹2,099', couponPrice: '₹899', discount: '50% OFF', votes: '12.6k'),
          _FashionFeedCardData(item: _DiscoveryItem(title: 'Casual Shirt', subtitle: 'Urban Wear', accent: Color(0xFF5C8FD8), icon: Icons.checkroom_rounded, price: '₹649', rating: '4.4'), oldPrice: '₹1,299', couponPrice: '₹599', discount: '50% OFF', votes: '3.2k'),
        ],
    };
  }

  List<_FashionFeedCardData> get _feedItems {
    final templates = _feedTemplates;
    final generated = List.generate(120, (index) {
      final template = templates[index % templates.length];
      final basePrice = _extractFashionPrice(template.item.price);
      final bump = (index ~/ templates.length) * 27;
      final price = basePrice + bump;
      final couponPrice = price > 120 ? price - 100 : price;
      final rating = (3.8 + ((index + templates.length) % 11) / 10).clamp(3.8, 4.8).toStringAsFixed(1);
      return template.copyWith(
        item: _DiscoveryItem(
          title: template.item.title,
          subtitle: template.item.subtitle,
          accent: template.item.accent,
          icon: template.item.icon,
          price: '₹$price',
          rating: rating,
          distance: template.item.distance,
        ),
        oldPrice: '₹${price + 700 + (index % 4) * 100}',
        couponPrice: '₹$couponPrice',
        votes: index % 4 == 0 ? '${(8 + index / 10).toStringAsFixed(1)}k' : template.votes,
        newRank: index,
        promoted: template.promoted || index % 6 == 0,
      );
    });
    switch (sortOption) {
      case 'Low to High':
        generated.sort((left, right) => _extractFashionPrice(left.item.price).compareTo(_extractFashionPrice(right.item.price)));
        break;
      case 'High to Low':
        generated.sort((left, right) => _extractFashionPrice(right.item.price).compareTo(_extractFashionPrice(left.item.price)));
        break;
      case 'Newly Added':
        generated.sort((left, right) => right.newRank.compareTo(left.newRank));
        break;
      case 'Popular':
      default:
        generated.sort((left, right) {
          final promotedCompare = (right.promoted ? 1 : 0).compareTo(left.promoted ? 1 : 0);
          if (promotedCompare != 0) {
            return promotedCompare;
          }
          return (double.tryParse(right.item.rating) ?? 0).compareTo(double.tryParse(left.item.rating) ?? 0);
        });
        break;
    }
    return generated;
  }

  @override
  Widget build(BuildContext context) {
    final feedItems = _feedItems;
    return ColoredBox(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 18),
            child: SizedBox(
              height: 272,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
                itemCount: _items.length,
                separatorBuilder: (_, _) => const SizedBox(width: 14),
                itemBuilder: (context, index) {
                  final card = _items[index];
                  return SizedBox(
                    width: 148,
                    child: _FashionProductCard(
                      data: card,
                      isWishlisted: isWishlisted(card.item),
                      onTap: () => onTap(card.item),
                      onWishlistToggle: () => onWishlistToggle(card.item),
                      onAddToCart: () => onAddToCart(card.item),
                    ),
                  );
                },
              ),
            ),
          ),
          _BudgetFriendlyFashionSection(
            items: _budgetItems,
            onTap: onTap,
          ),
          _FashionInfiniteFeedSection(
            items: feedItems.take(visibleFeedCount).toList(),
            hasMore: visibleFeedCount < feedItems.length,
            onTap: onTap,
            isWishlisted: isWishlisted,
            onWishlistToggle: onWishlistToggle,
          ),
        ],
      ),
    );
  }
}

class _FashionCardData {
  const _FashionCardData({
    required this.item,
    this.discount = '',
  });

  final _DiscoveryItem item;
  final String discount;
}

class _FashionFeedCardData {
  const _FashionFeedCardData({
    required this.item,
    required this.oldPrice,
    required this.couponPrice,
    required this.discount,
    required this.votes,
    this.promoted = false,
    this.newRank = 0,
  });

  final _DiscoveryItem item;
  final String oldPrice;
  final String couponPrice;
  final String discount;
  final String votes;
  final bool promoted;
  final int newRank;

  _FashionFeedCardData copyWith({
    _DiscoveryItem? item,
    String? oldPrice,
    String? couponPrice,
    String? discount,
    String? votes,
    bool? promoted,
    int? newRank,
  }) {
    return _FashionFeedCardData(
      item: item ?? this.item,
      oldPrice: oldPrice ?? this.oldPrice,
      couponPrice: couponPrice ?? this.couponPrice,
      discount: discount ?? this.discount,
      votes: votes ?? this.votes,
      promoted: promoted ?? this.promoted,
      newRank: newRank ?? this.newRank,
    );
  }
}

class _FashionInfiniteFeedSection extends StatelessWidget {
  const _FashionInfiniteFeedSection({
    required this.items,
    required this.hasMore,
    required this.onTap,
    required this.isWishlisted,
    required this.onWishlistToggle,
  });

  final List<_FashionFeedCardData> items;
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
              return _FashionMarketplaceTile(
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

class _FashionMarketplaceTile extends StatelessWidget {
  const _FashionMarketplaceTile({
    required this.data,
    required this.isWishlisted,
    required this.onTap,
    required this.onWishlistToggle,
  });

  final _FashionFeedCardData data;
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
                          color: const Color(0xFFB84C64).withValues(alpha: 0.94),
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

class _ShopFilterPage extends StatefulWidget {
  const _ShopFilterPage({required this.initialGender});

  final String initialGender;

  @override
  State<_ShopFilterPage> createState() => _ShopFilterPageState();
}

class _ShopFilterPageState extends State<_ShopFilterPage> {
  late String _gender = _normalizeGender(widget.initialGender);
  String _category = 'Shirts';
  String _occasion = 'Casual';
  String _color = 'Black';
  String _size = 'M';
  String _brand = 'All brands';
  double _minPrice = 199;
  double _maxPrice = 2499;
  int _rating = 4;

  static const List<String> _genders = ['Men', 'Women', 'Boys', 'Girls'];
  static const List<String> _occasions = ['Casual', 'Party Wear', 'Formal', 'Ethnic', 'Sports'];
  static const List<String> _colors = ['Black', 'White', 'Blue', 'Red', 'Green', 'Yellow', 'Pink', 'Brown'];
  static const List<String> _sizes = ['S', 'M', 'L', 'XL', 'XXL', '3XL'];
  static const List<String> _brands = ['All brands', 'Jockey', 'Arrow', 'Roadster', 'VASTRADO', 'Urban Wear', 'Style Studio'];

  List<String> get _categories => switch (_gender) {
        'Women' => ['Sarees', 'Kurtis', 'Dresses', 'Tops', 'Handbags', 'Footwear', 'Jeans'],
        'Boys' => ['Shirts', 'Jeans', 'T-Shirts', 'Shorts', 'Shoes', 'School wear'],
        'Girls' => ['Frocks', 'Tops', 'Gowns', 'Skirts', 'Hair clips', 'Shoes'],
        _ => ['Shirts', 'Jeans', 'T-Shirts', 'Trousers', 'Blazers', 'Shoes'],
      };

  static String _normalizeGender(String value) =>
      _genders.contains(value) ? value : 'Men';

  void _setGender(String value) {
    setState(() {
      _gender = value;
      _category = _categories.first;
    });
  }

  void _reset() {
    setState(() {
      _gender = 'Men';
      _category = _categories.first;
      _occasion = 'Casual';
      _color = 'Black';
      _size = 'M';
      _brand = 'All brands';
      _minPrice = 199;
      _maxPrice = 2499;
      _rating = 4;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F5EF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F5EF),
        elevation: 0,
        foregroundColor: const Color(0xFF202435),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        title: const Text(
          'Filter fashion',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          TextButton(
            onPressed: _reset,
            child: const Text(
              'Reset',
              style: TextStyle(
                color: Color(0xFFCB6E5B),
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 6, 18, 120),
        children: [
          _ShopFilterCard(
            title: 'Gender',
            child: _ShopFilterWrap(
              values: _genders,
              selected: _gender,
              onSelected: _setGender,
            ),
          ),
          _ShopFilterCard(
            title: 'Category',
            subtitle: 'Item type changes based on selected gender',
            child: _ShopFilterWrap(
              values: _categories,
              selected: _category,
              onSelected: (value) => setState(() => _category = value),
            ),
          ),
          _ShopFilterCard(
            title: 'Occasion',
            child: _ShopFilterWrap(
              values: _occasions,
              selected: _occasion,
              onSelected: (value) => setState(() => _occasion = value),
            ),
          ),
          _ShopFilterCard(
            title: 'Color',
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _colors
                  .map(
                    (color) => _ColorFilterChip(
                      label: color,
                      selected: _color == color,
                      onTap: () => setState(() => _color = color),
                    ),
                  )
                  .toList(),
            ),
          ),
          _ShopFilterCard(
            title: 'Size',
            child: _ShopFilterWrap(
              values: _sizes,
              selected: _size,
              onSelected: (value) => setState(() => _size = value),
            ),
          ),
          _ShopFilterCard(
            title: 'Rating',
            child: Row(
              children: List.generate(
                5,
                (index) {
                  final star = index + 1;
                  final selected = star <= _rating;
                  return GestureDetector(
                    onTap: () => setState(() => _rating = star),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Icon(
                        selected ? Icons.star_rounded : Icons.star_border_rounded,
                        color: selected ? const Color(0xFFF2A13D) : const Color(0xFFC8C2BA),
                        size: 32,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          _ShopFilterCard(
            title: 'Brand',
            child: _ShopFilterWrap(
              values: _brands,
              selected: _brand,
              onSelected: (value) => setState(() => _brand = value),
            ),
          ),
          _ShopFilterCard(
            title: 'Price range',
            subtitle: '₹${_minPrice.round()} - ₹${_maxPrice.round()}',
            child: RangeSlider(
              values: RangeValues(_minPrice, _maxPrice),
              min: 99,
              max: 5000,
              divisions: 49,
              activeColor: const Color(0xFFCB6E5B),
              inactiveColor: const Color(0xFFE9DED6),
              labels: RangeLabels('₹${_minPrice.round()}', '₹${_maxPrice.round()}'),
              onChanged: (value) => setState(() {
                _minPrice = value.start;
                _maxPrice = value.end;
              }),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(18, 10, 18, 18),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(false),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF202435),
                  side: const BorderSide(color: Color(0xFFD8CCC4)),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFCB6E5B),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
                child: const Text(
                  'Apply filters',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FashionProductCard extends StatelessWidget {
  const _FashionProductCard({
    required this.data,
    required this.isWishlisted,
    required this.onTap,
    required this.onWishlistToggle,
    required this.onAddToCart,
  });

  final _FashionCardData data;
  final bool isWishlisted;
  final VoidCallback onTap;
  final VoidCallback onWishlistToggle;
  final VoidCallback onAddToCart;

  @override
  Widget build(BuildContext context) {
    final item = data.item;
    final label = _fashionCardLabel(item.title);
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

class _BudgetFriendlyFashionSection extends StatelessWidget {
  const _BudgetFriendlyFashionSection({
    required this.items,
    required this.onTap,
  });

  final List<_FashionCardData> items;
  final ValueChanged<_DiscoveryItem> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFEFFFFF),
            Color(0xFFDDFBFF),
            Color(0xFFEFFFFF),
          ],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 18),
      child: Column(
        children: [
          const Text(
            'Budget-Friendly Picks 🍊',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFFB22A22),
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
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
                return _BudgetFashionTile(
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

class _BudgetFashionTile extends StatelessWidget {
  const _BudgetFashionTile({
    required this.data,
    required this.onTap,
  });

  final _FashionCardData data;
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
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                      height: 1,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
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

String _fashionCardLabel(String title) {
  final text = title.toLowerCase();
  if (text.contains('shirt')) return 'Shirts';
  if (text.contains('tee') || text.contains('top')) return 'T-Shirts';
  if (text.contains('jeans') || text.contains('denim')) return 'Jeans';
  if (text.contains('saree')) return 'Sarees';
  if (text.contains('kurti') || text.contains('kurta')) return 'Kurtis';
  if (text.contains('lehenga')) return 'Lehenga';
  if (text.contains('dress') || text.contains('frock') || text.contains('gown')) return 'Dresses';
  if (text.contains('shoe')) return 'Shoes';
  if (text.contains('bag')) return 'Bags';
  if (text.contains('watch')) return 'Watches';
  if (text.contains('wallet')) return 'Wallets';
  if (text.contains('short')) return 'Shorts';
  return title;
}

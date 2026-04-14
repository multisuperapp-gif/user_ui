part of '../../../main.dart';

class _ShopFootwearPanelsSection extends StatelessWidget {
  const _ShopFootwearPanelsSection({
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
            title: 'Footwear',
            pillText: 'STEP PICKS',
            pillColor: Color(0xFFEAF8F4),
            icon: Icons.hiking_rounded,
            accentStart: Color(0xFF1FB8A4),
            accentEnd: Color(0xFF8BE6D3),
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

class _FootwearCategoryShowcase extends StatelessWidget {
  const _FootwearCategoryShowcase({
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

  List<_FootwearCardData> get _items {
    final category = selectedCategory == 'All' ? 'Men' : selectedCategory;
    return switch (category) {
      'Women' => const [
          _FootwearCardData(item: _DiscoveryItem(title: 'Heels', subtitle: 'Women', accent: Color(0xFFE75D93), icon: Icons.woman_rounded, price: '₹1,149', rating: '4.5', distance: '1.9 km'), discount: '15% OFF'),
          _FootwearCardData(item: _DiscoveryItem(title: 'Sandals', subtitle: 'Women', accent: Color(0xFFDF7DA0), icon: Icons.hiking_rounded, price: '₹799', rating: '4.4', distance: '1.5 km'), discount: '10% OFF'),
          _FootwearCardData(item: _DiscoveryItem(title: 'Flats', subtitle: 'Women', accent: Color(0xFFDF7DA0), icon: Icons.checkroom_rounded, price: '₹649', rating: '4.6', distance: '1.4 km')),
          _FootwearCardData(item: _DiscoveryItem(title: 'Party Heels', subtitle: 'Women', accent: Color(0xFFFF7DA7), icon: Icons.auto_awesome_rounded, price: '₹1,499', rating: '4.7', distance: '1.8 km'), discount: '20% OFF'),
        ],
      'Boys' => const [
          _FootwearCardData(item: _DiscoveryItem(title: 'School Shoes', subtitle: 'Boys', accent: Color(0xFFF2A13D), icon: Icons.school_rounded, price: '₹699', rating: '4.7', distance: '1.6 km'), discount: '10% OFF'),
          _FootwearCardData(item: _DiscoveryItem(title: 'Sports Shoes', subtitle: 'Boys', accent: Color(0xFFF2A13D), icon: Icons.directions_run_rounded, price: '₹999', rating: '4.5', distance: '1.7 km')),
          _FootwearCardData(item: _DiscoveryItem(title: 'Kids Sandals', subtitle: 'Boys', accent: Color(0xFFF2A13D), icon: Icons.child_friendly_rounded, price: '₹549', rating: '4.4', distance: '1.8 km'), discount: '15% OFF'),
          _FootwearCardData(item: _DiscoveryItem(title: 'Slides', subtitle: 'Boys', accent: Color(0xFFF2A13D), icon: Icons.airline_seat_legroom_normal_rounded, price: '₹399', rating: '4.6', distance: '1.5 km')),
        ],
      'Girls' => const [
          _FootwearCardData(item: _DiscoveryItem(title: 'Cute Sandals', subtitle: 'Girls', accent: Color(0xFFE75D93), icon: Icons.girl_rounded, price: '₹699', rating: '4.7', distance: '1.3 km'), discount: '20% OFF'),
          _FootwearCardData(item: _DiscoveryItem(title: 'Ballet Flats', subtitle: 'Girls', accent: Color(0xFFFF8DB5), icon: Icons.auto_awesome_rounded, price: '₹799', rating: '4.6', distance: '1.4 km')),
          _FootwearCardData(item: _DiscoveryItem(title: 'School Shoes', subtitle: 'Girls', accent: Color(0xFFDF7DA0), icon: Icons.school_rounded, price: '₹749', rating: '4.5', distance: '1.7 km'), discount: '10% OFF'),
          _FootwearCardData(item: _DiscoveryItem(title: 'Party Sandals', subtitle: 'Girls', accent: Color(0xFFE75D93), icon: Icons.star_rounded, price: '₹899', rating: '4.8', distance: '1.5 km')),
        ],
      _ => const [
          _FootwearCardData(item: _DiscoveryItem(title: 'Formal Shoes', subtitle: 'Men', accent: Color(0xFF3E7BD6), icon: Icons.hiking_rounded, price: '₹1,299', rating: '4.5', distance: '1.7 km'), discount: '15% OFF'),
          _FootwearCardData(item: _DiscoveryItem(title: 'Sneakers', subtitle: 'Men', accent: Color(0xFF5C8FD8), icon: Icons.directions_walk_rounded, price: '₹1,499', rating: '4.7', distance: '1.5 km')),
          _FootwearCardData(item: _DiscoveryItem(title: 'Loafers', subtitle: 'Men', accent: Color(0xFF22314D), icon: Icons.checkroom_rounded, price: '₹1,149', rating: '4.6', distance: '1.6 km'), discount: '10% OFF'),
          _FootwearCardData(item: _DiscoveryItem(title: 'Slippers', subtitle: 'Men', accent: Color(0xFF1FB8A4), icon: Icons.airline_seat_legroom_normal_rounded, price: '₹499', rating: '4.3', distance: '1.8 km')),
        ],
    };
  }

  List<_FootwearCardData> get _budgetItems {
    final category = selectedCategory == 'All' ? 'Men' : selectedCategory;
    return switch (category) {
      'Women' => const [
          _FootwearCardData(item: _DiscoveryItem(title: 'Heels', subtitle: 'Women', accent: Color(0xFFE75D93), icon: Icons.woman_rounded, price: '₹999', rating: '4.5')),
          _FootwearCardData(item: _DiscoveryItem(title: 'Sandals', subtitle: 'Women', accent: Color(0xFFDF7DA0), icon: Icons.hiking_rounded, price: '₹699', rating: '4.4')),
          _FootwearCardData(item: _DiscoveryItem(title: 'Flats', subtitle: 'Women', accent: Color(0xFFCB6E5B), icon: Icons.auto_awesome_rounded, price: '₹499', rating: '4.6')),
          _FootwearCardData(item: _DiscoveryItem(title: 'Party Heels', subtitle: 'Women', accent: Color(0xFFFF7DA7), icon: Icons.star_rounded, price: '₹1249', rating: '4.7')),
          _FootwearCardData(item: _DiscoveryItem(title: 'Casual Slippers', subtitle: 'Women', accent: Color(0xFF6A7C91), icon: Icons.airline_seat_legroom_normal_rounded, price: '₹599', rating: '4.2')),
          _FootwearCardData(item: _DiscoveryItem(title: 'Office Shoes', subtitle: 'Women', accent: Color(0xFF22314D), icon: Icons.hiking_rounded, price: '₹1449', rating: '4.4')),
        ],
      'Boys' => const [
          _FootwearCardData(item: _DiscoveryItem(title: 'School Shoes', subtitle: 'Boys', accent: Color(0xFFF2A13D), icon: Icons.school_rounded, price: '₹649', rating: '4.6')),
          _FootwearCardData(item: _DiscoveryItem(title: 'Sports Shoes', subtitle: 'Boys', accent: Color(0xFF6A7C91), icon: Icons.directions_run_rounded, price: '₹1249', rating: '4.5')),
          _FootwearCardData(item: _DiscoveryItem(title: 'Slides', subtitle: 'Boys', accent: Color(0xFFC88B22), icon: Icons.airline_seat_legroom_normal_rounded, price: '₹449', rating: '4.3')),
          _FootwearCardData(item: _DiscoveryItem(title: 'Sandals', subtitle: 'Boys', accent: Color(0xFF5C8FD8), icon: Icons.child_friendly_rounded, price: '₹549', rating: '4.4')),
          _FootwearCardData(item: _DiscoveryItem(title: 'Sneakers', subtitle: 'Boys', accent: Color(0xFF24314B), icon: Icons.hiking_rounded, price: '₹999', rating: '4.5')),
        ],
      'Girls' => const [
          _FootwearCardData(item: _DiscoveryItem(title: 'Cute Sandals', subtitle: 'Girls', accent: Color(0xFFE75D93), icon: Icons.girl_rounded, price: '₹649', rating: '4.8')),
          _FootwearCardData(item: _DiscoveryItem(title: 'Ballet Flats', subtitle: 'Girls', accent: Color(0xFFFF8DB5), icon: Icons.auto_awesome_rounded, price: '₹799', rating: '4.6')),
          _FootwearCardData(item: _DiscoveryItem(title: 'Party Shoes', subtitle: 'Girls', accent: Color(0xFFDF7DA0), icon: Icons.star_rounded, price: '₹849', rating: '4.5')),
          _FootwearCardData(item: _DiscoveryItem(title: 'School Shoes', subtitle: 'Girls', accent: Color(0xFF6A7C91), icon: Icons.school_rounded, price: '₹699', rating: '4.4')),
          _FootwearCardData(item: _DiscoveryItem(title: 'Casual Slides', subtitle: 'Girls', accent: Color(0xFFC69B48), icon: Icons.airline_seat_legroom_normal_rounded, price: '₹399', rating: '4.5')),
        ],
      _ => const [
          _FootwearCardData(item: _DiscoveryItem(title: 'Formal Shoes', subtitle: 'Men', accent: Color(0xFF5C8FD8), icon: Icons.hiking_rounded, price: '₹1249', rating: '4.6')),
          _FootwearCardData(item: _DiscoveryItem(title: 'Sneakers', subtitle: 'Men', accent: Color(0xFF6A7C91), icon: Icons.directions_walk_rounded, price: '₹1499', rating: '4.5')),
          _FootwearCardData(item: _DiscoveryItem(title: 'Slippers', subtitle: 'Men', accent: Color(0xFFC88B22), icon: Icons.airline_seat_legroom_normal_rounded, price: '₹449', rating: '4.2')),
          _FootwearCardData(item: _DiscoveryItem(title: 'Loafers', subtitle: 'Men', accent: Color(0xFF22314D), icon: Icons.checkroom_rounded, price: '₹1149', rating: '4.4')),
          _FootwearCardData(item: _DiscoveryItem(title: 'Boots', subtitle: 'Men', accent: Color(0xFF24314B), icon: Icons.hiking_rounded, price: '₹1899', rating: '4.7')),
          _FootwearCardData(item: _DiscoveryItem(title: 'Sport Shoes', subtitle: 'Men', accent: Color(0xFF1FB8A4), icon: Icons.directions_run_rounded, price: '₹1299', rating: '4.5')),
        ],
    };
  }

  List<_FootwearFeedCardData> get _feedTemplates {
    final category = selectedCategory == 'All' ? 'Men' : selectedCategory;
    return switch (category) {
      'Women' => const [
          _FootwearFeedCardData(item: _DiscoveryItem(title: 'Elegant Heels', subtitle: 'Step Aura', accent: Color(0xFFE75D93), icon: Icons.woman_rounded, price: '₹1,099', rating: '4.5'), oldPrice: '₹1,999', couponPrice: '₹949', discount: '45% OFF', votes: '5.4k', promoted: true),
          _FootwearFeedCardData(item: _DiscoveryItem(title: 'Daily Sandals', subtitle: 'Sole Studio', accent: Color(0xFFDF7DA0), icon: Icons.hiking_rounded, price: '₹699', rating: '4.3'), oldPrice: '₹1,299', couponPrice: '₹629', discount: '46% OFF', votes: '2.7k'),
          _FootwearFeedCardData(item: _DiscoveryItem(title: 'Soft Flats', subtitle: 'Urban Steps', accent: Color(0xFFCB6E5B), icon: Icons.auto_awesome_rounded, price: '₹599', rating: '4.4'), oldPrice: '₹1,099', couponPrice: '₹549', discount: '45% OFF', votes: '1.9k'),
          _FootwearFeedCardData(item: _DiscoveryItem(title: 'Party Heels', subtitle: 'Glam Walk', accent: Color(0xFFFF7DA7), icon: Icons.star_rounded, price: '₹1,399', rating: '4.7'), oldPrice: '₹2,399', couponPrice: '₹1,249', discount: '42% OFF', votes: '3.3k', promoted: true),
        ],
      'Boys' => const [
          _FootwearFeedCardData(item: _DiscoveryItem(title: 'School Shoes', subtitle: 'Tiny Steps', accent: Color(0xFFF2A13D), icon: Icons.school_rounded, price: '₹699', rating: '4.6'), oldPrice: '₹1,199', couponPrice: '₹629', discount: '42% OFF', votes: '1.5k', promoted: true),
          _FootwearFeedCardData(item: _DiscoveryItem(title: 'Sports Shoes', subtitle: 'Run Kids', accent: Color(0xFF6A7C91), icon: Icons.directions_run_rounded, price: '₹999', rating: '4.4'), oldPrice: '₹1,799', couponPrice: '₹899', discount: '44% OFF', votes: '2.2k'),
          _FootwearFeedCardData(item: _DiscoveryItem(title: 'Kids Sandals', subtitle: 'Happy Feet', accent: Color(0xFF5C8FD8), icon: Icons.child_friendly_rounded, price: '₹549', rating: '4.3'), oldPrice: '₹999', couponPrice: '₹499', discount: '45% OFF', votes: '978'),
          _FootwearFeedCardData(item: _DiscoveryItem(title: 'Slides', subtitle: 'Step Up', accent: Color(0xFFC88B22), icon: Icons.airline_seat_legroom_normal_rounded, price: '₹399', rating: '4.1'), oldPrice: '₹699', couponPrice: '₹359', discount: '43% OFF', votes: '884'),
        ],
      'Girls' => const [
          _FootwearFeedCardData(item: _DiscoveryItem(title: 'Cute Sandals', subtitle: 'Tiny Trends', accent: Color(0xFFE75D93), icon: Icons.girl_rounded, price: '₹699', rating: '4.7'), oldPrice: '₹1,199', couponPrice: '₹649', discount: '42% OFF', votes: '2.4k', promoted: true),
          _FootwearFeedCardData(item: _DiscoveryItem(title: 'Ballet Flats', subtitle: 'Bloom Steps', accent: Color(0xFFFF8DB5), icon: Icons.auto_awesome_rounded, price: '₹799', rating: '4.5'), oldPrice: '₹1,399', couponPrice: '₹729', discount: '43% OFF', votes: '1.6k'),
          _FootwearFeedCardData(item: _DiscoveryItem(title: 'Party Sandals', subtitle: 'Little Glam', accent: Color(0xFFDF7DA0), icon: Icons.star_rounded, price: '₹899', rating: '4.6'), oldPrice: '₹1,599', couponPrice: '₹829', discount: '44% OFF', votes: '1.2k'),
          _FootwearFeedCardData(item: _DiscoveryItem(title: 'School Shoes', subtitle: 'Tiny Steps', accent: Color(0xFF6A7C91), icon: Icons.school_rounded, price: '₹749', rating: '4.4'), oldPrice: '₹1,299', couponPrice: '₹699', discount: '42% OFF', votes: '1.1k'),
        ],
      _ => const [
          _FootwearFeedCardData(item: _DiscoveryItem(title: 'Formal Shoes', subtitle: 'Arrow Walk', accent: Color(0xFF22314D), icon: Icons.hiking_rounded, price: '₹1,299', rating: '4.5'), oldPrice: '₹2,199', couponPrice: '₹1,099', discount: '41% OFF', votes: '6.8k', promoted: true),
          _FootwearFeedCardData(item: _DiscoveryItem(title: 'Sneakers', subtitle: 'Roadster', accent: Color(0xFF3E7BD6), icon: Icons.directions_walk_rounded, price: '₹1,499', rating: '4.3'), oldPrice: '₹2,599', couponPrice: '₹1,299', discount: '42% OFF', votes: '4.6k'),
          _FootwearFeedCardData(item: _DiscoveryItem(title: 'Loafers', subtitle: 'Urban Wear', accent: Color(0xFF5C8FD8), icon: Icons.checkroom_rounded, price: '₹1,149', rating: '4.4'), oldPrice: '₹1,999', couponPrice: '₹999', discount: '43% OFF', votes: '2.8k', promoted: true),
          _FootwearFeedCardData(item: _DiscoveryItem(title: 'Slippers', subtitle: 'Step Ease', accent: Color(0xFF1FB8A4), icon: Icons.airline_seat_legroom_normal_rounded, price: '₹499', rating: '4.1'), oldPrice: '₹899', couponPrice: '₹449', discount: '44% OFF', votes: '1.4k'),
          _FootwearFeedCardData(item: _DiscoveryItem(title: 'Boots', subtitle: 'VASTRADO', accent: Color(0xFF24314B), icon: Icons.hiking_rounded, price: '₹1,899', rating: '4.6'), oldPrice: '₹3,099', couponPrice: '₹1,699', discount: '39% OFF', votes: '3.9k'),
        ],
    };
  }

  List<_FootwearFeedCardData> get _feedItems {
    final templates = _feedTemplates;
    final generated = List.generate(120, (index) {
      final template = templates[index % templates.length];
      final basePrice = _extractFashionPrice(template.item.price);
      final bump = (index ~/ templates.length) * 24;
      final price = basePrice + bump;
      final couponPrice = price > 120 ? price - 90 : price;
      final rating = (3.9 + ((index + templates.length) % 10) / 10).clamp(3.9, 4.8).toStringAsFixed(1);
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
        oldPrice: '₹${price + 650 + (index % 4) * 90}',
        couponPrice: '₹$couponPrice',
        votes: index % 4 == 0 ? '${(6 + index / 10).toStringAsFixed(1)}k' : template.votes,
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
                    child: _FootwearProductCard(
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
          _BudgetFriendlyFootwearSection(
            items: _budgetItems,
            onTap: onTap,
          ),
          _FootwearInfiniteFeedSection(
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

class _FootwearCardData {
  const _FootwearCardData({
    required this.item,
    this.discount = '',
  });

  final _DiscoveryItem item;
  final String discount;
}

class _FootwearFeedCardData {
  const _FootwearFeedCardData({
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

  _FootwearFeedCardData copyWith({
    _DiscoveryItem? item,
    String? oldPrice,
    String? couponPrice,
    String? discount,
    String? votes,
    bool? promoted,
    int? newRank,
  }) {
    return _FootwearFeedCardData(
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

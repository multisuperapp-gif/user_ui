part of '../../../main.dart';

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


part of '../../../main.dart';

class _ShopProfilePage extends StatefulWidget {
  const _ShopProfilePage({
    required this.item,
    required this.shopCategory,
    required this.initialFashionSubcategory,
    required this.isWishlisted,
    required this.onWishlistToggle,
    required this.onAddToCart,
    required this.onOpenCart,
    required this.autoAddItem,
  });

  final _DiscoveryItem item;
  final String shopCategory;
  final String initialFashionSubcategory;
  final bool Function(_DiscoveryItem item) isWishlisted;
  final ValueChanged<_DiscoveryItem> onWishlistToggle;
  final Future<bool> Function(_DiscoveryItem item) onAddToCart;
  final VoidCallback onOpenCart;
  final bool autoAddItem;

  @override
  State<_ShopProfilePage> createState() => _ShopProfilePageState();
}

class _ShopProfilePageState extends State<_ShopProfilePage>
    with _ScrollToTopVisibilityMixin<_ShopProfilePage> {
  late final List<_DiscoveryItem> _shopItems;
  late final List<_ShopMenuSection> _menuSections;
  late final Map<String, GlobalKey> _menuSectionKeys;
  late final Map<_DiscoveryItem, GlobalKey> _menuItemKeys;
  final GlobalKey _recommendedSectionKey = GlobalKey();
  bool _didAutoAdd = false;
  final ScrollController _scrollController = ScrollController();
  late String _fashionProfileFilter;
  late String _footwearProfileFilter;
  String _fashionProfileSort = 'Popular';
  String _footwearProfileSort = 'Popular';

  bool get _isFashionProfile => widget.shopCategory == 'Fashion';
  bool get _isFootwearProfile => widget.shopCategory == 'Footwear';
  _ShopTimingState get _shopTiming => _shopTimingFor(widget.item.subtitle, widget.shopCategory);

  @override
  ScrollController get scrollToTopController => _scrollController;

  static const List<String> _fashionProfileOptions = ['All', 'Men', 'Women', 'Boys', 'Girls'];
  static const List<String> _footwearProfileOptions = ['All', 'Men', 'Women', 'Boys', 'Girls'];

  @override
  void initState() {
    super.initState();
    initScrollToTopVisibility();
    _fashionProfileFilter = _fashionProfileOptions.contains(widget.initialFashionSubcategory)
        ? widget.initialFashionSubcategory
        : 'All';
    _footwearProfileFilter = _footwearProfileOptions.contains(widget.initialFashionSubcategory)
        ? widget.initialFashionSubcategory
        : 'All';
    _shopItems = [
      widget.item,
      _DiscoveryItem(
        title: '${widget.item.title} Special',
        subtitle: widget.item.subtitle,
        accent: widget.item.accent,
        icon: widget.item.icon,
        price: '₹${_extractAmount(widget.item.price) + 59}',
        rating: '4.7',
        distance: widget.item.distance,
      ),
      _DiscoveryItem(
        title: 'Choco Crunch ${widget.item.title.split(' ').first}',
        subtitle: widget.item.subtitle,
        accent: widget.item.accent,
        icon: widget.item.icon,
        price: '₹${_extractAmount(widget.item.price) + 44}',
        rating: '4.6',
        distance: widget.item.distance,
      ),
      _DiscoveryItem(
        title: 'Butterscotch ${widget.item.title.split(' ').first}',
        subtitle: widget.item.subtitle,
        accent: widget.item.accent,
        icon: widget.item.icon,
        price: '₹${_extractAmount(widget.item.price) + 29}',
        rating: '4.8',
        distance: widget.item.distance,
      ),
      _DiscoveryItem(
        title: 'Classic ${widget.item.title.split(' ').first}',
        subtitle: widget.item.subtitle,
        accent: widget.item.accent,
        icon: widget.item.icon,
        price: '₹${_extractAmount(widget.item.price) + 79}',
        rating: '4.5',
        distance: widget.item.distance,
      ),
      _DiscoveryItem(
        title: 'Premium ${widget.item.title.split(' ').first}',
        subtitle: widget.item.subtitle,
        accent: widget.item.accent,
        icon: widget.item.icon,
        price: '₹${_extractAmount(widget.item.price) + 99}',
        rating: '4.9',
        distance: widget.item.distance,
      ),
    ];
    _menuSections = [
      _ShopMenuSection(
        title: 'Rice',
        items: [
          _buildMenuItem(
            title: 'Jeera Rice',
            price: _extractAmount(widget.item.price) - 120,
            rating: '4.3',
            icon: Icons.rice_bowl_rounded,
          ),
          _buildMenuItem(
            title: 'Veg Pulao',
            price: _extractAmount(widget.item.price) - 90,
            rating: '4.4',
            icon: Icons.dinner_dining_rounded,
          ),
          _buildMenuItem(
            title: 'Paneer Fried Rice',
            price: _extractAmount(widget.item.price) - 55,
            rating: '4.6',
            icon: Icons.ramen_dining_rounded,
          ),
        ],
      ),
      _ShopMenuSection(
        title: 'Vegetables',
        items: [
          _buildMenuItem(
            title: 'Mixed Veg Curry',
            price: _extractAmount(widget.item.price) - 110,
            rating: '4.2',
            icon: Icons.eco_rounded,
          ),
          _buildMenuItem(
            title: 'Aloo Gobhi Masala',
            price: _extractAmount(widget.item.price) - 95,
            rating: '4.1',
            icon: Icons.spa_rounded,
          ),
          _buildMenuItem(
            title: 'Green Veg Combo',
            price: _extractAmount(widget.item.price) - 75,
            rating: '4.5',
            icon: Icons.local_florist_rounded,
          ),
        ],
      ),
      _ShopMenuSection(
        title: 'Breads',
        items: [
          _buildMenuItem(
            title: 'Butter Naan',
            price: _extractAmount(widget.item.price) - 170,
            rating: '4.3',
            icon: Icons.bakery_dining_rounded,
          ),
          _buildMenuItem(
            title: 'Tawa Roti',
            price: _extractAmount(widget.item.price) - 190,
            rating: '4.0',
            icon: Icons.cookie_rounded,
          ),
          _buildMenuItem(
            title: 'Stuffed Kulcha',
            price: _extractAmount(widget.item.price) - 130,
            rating: '4.4',
            icon: Icons.lunch_dining_rounded,
          ),
        ],
      ),
      _ShopMenuSection(
        title: 'Desserts',
        items: [
          _buildMenuItem(
            title: 'Gulab Jamun Box',
            price: _extractAmount(widget.item.price) - 140,
            rating: '4.7',
            icon: Icons.icecream_rounded,
          ),
          _buildMenuItem(
            title: 'Kesar Rasmalai',
            price: _extractAmount(widget.item.price) - 105,
            rating: '4.6',
            icon: Icons.cake_rounded,
          ),
          _buildMenuItem(
            title: 'Sweet Treat Bowl',
            price: _extractAmount(widget.item.price) - 125,
            rating: '4.5',
            icon: Icons.emoji_food_beverage_rounded,
          ),
        ],
      ),
    ];
    _menuSectionKeys = {
      for (final section in _menuSections) section.title: GlobalKey(),
    };
    _menuItemKeys = {
      for (final item in [..._shopItems, ..._menuSections.expand((section) => section.items)]) item: GlobalKey(),
    };
  }

  List<_FashionFeedCardData> get _fashionProfileItems {
    final selected = _fashionProfileFilter == 'All' ? 'Men' : _fashionProfileFilter;
    final templates = switch (selected) {
      'Women' => const [
          _FashionFeedCardData(item: _DiscoveryItem(title: 'Silk Saree', subtitle: 'Women', accent: Color(0xFFE75D93), icon: Icons.style_rounded, price: '₹1,249', rating: '4.6'), oldPrice: '₹2,399', couponPrice: '₹1,099', discount: '48% OFF', votes: '8.7k', promoted: true),
          _FashionFeedCardData(item: _DiscoveryItem(title: 'Cotton Kurti', subtitle: 'Women', accent: Color(0xFFE75D93), icon: Icons.checkroom_rounded, price: '₹699', rating: '4.5'), oldPrice: '₹1,399', couponPrice: '₹599', discount: '50% OFF', votes: '2.9k'),
          _FashionFeedCardData(item: _DiscoveryItem(title: 'Floral Dress', subtitle: 'Women', accent: Color(0xFFFF7DA7), icon: Icons.auto_awesome_rounded, price: '₹999', rating: '4.4'), oldPrice: '₹1,899', couponPrice: '₹899', discount: '47% OFF', votes: '1.6k'),
          _FashionFeedCardData(item: _DiscoveryItem(title: 'Classic Handbag', subtitle: 'Women', accent: Color(0xFF8A5BE8), icon: Icons.shopping_bag_rounded, price: '₹899', rating: '4.3'), oldPrice: '₹1,699', couponPrice: '₹799', discount: '47% OFF', votes: '980'),
        ],
      'Boys' => const [
          _FashionFeedCardData(item: _DiscoveryItem(title: 'Boys Track Pants', subtitle: 'Boys', accent: Color(0xFF3E7BD6), icon: Icons.boy_rounded, price: '₹499', rating: '4.2'), oldPrice: '₹999', couponPrice: '₹449', discount: '50% OFF', votes: '879', promoted: true),
          _FashionFeedCardData(item: _DiscoveryItem(title: 'Printed Shirt', subtitle: 'Boys', accent: Color(0xFF5C8FD8), icon: Icons.checkroom_rounded, price: '₹599', rating: '4.4'), oldPrice: '₹1,099', couponPrice: '₹529', discount: '45% OFF', votes: '2.1k'),
          _FashionFeedCardData(item: _DiscoveryItem(title: 'Denim Jeans', subtitle: 'Boys', accent: Color(0xFF22314D), icon: Icons.dry_cleaning_rounded, price: '₹799', rating: '4.3'), oldPrice: '₹1,499', couponPrice: '₹699', discount: '47% OFF', votes: '937'),
          _FashionFeedCardData(item: _DiscoveryItem(title: 'School Shoes', subtitle: 'Boys', accent: Color(0xFF2D8ACB), icon: Icons.hiking_rounded, price: '₹699', rating: '4.1'), oldPrice: '₹1,299', couponPrice: '₹629', discount: '46% OFF', votes: '1.3k'),
        ],
      'Girls' => const [
          _FashionFeedCardData(item: _DiscoveryItem(title: 'Party Frock', subtitle: 'Girls', accent: Color(0xFFE75D93), icon: Icons.girl_rounded, price: '₹699', rating: '4.7'), oldPrice: '₹1,299', couponPrice: '₹649', discount: '46% OFF', votes: '2.8k', promoted: true),
          _FashionFeedCardData(item: _DiscoveryItem(title: 'Cute Top Set', subtitle: 'Girls', accent: Color(0xFFDF7DA0), icon: Icons.checkroom_rounded, price: '₹549', rating: '4.3'), oldPrice: '₹999', couponPrice: '₹499', discount: '45% OFF', votes: '1.1k'),
          _FashionFeedCardData(item: _DiscoveryItem(title: 'Kids Gown', subtitle: 'Girls', accent: Color(0xFFFF8DB5), icon: Icons.auto_awesome_rounded, price: '₹999', rating: '4.6'), oldPrice: '₹1,899', couponPrice: '₹899', discount: '47% OFF', votes: '2.0k'),
          _FashionFeedCardData(item: _DiscoveryItem(title: 'Hair Clip Combo', subtitle: 'Girls', accent: Color(0xFFC69B48), icon: Icons.diamond_rounded, price: '₹199', rating: '4.1'), oldPrice: '₹399', couponPrice: '₹179', discount: '50% OFF', votes: '876'),
        ],
      _ => const [
          _FashionFeedCardData(item: _DiscoveryItem(title: 'Solid Track Pants', subtitle: 'Men', accent: Color(0xFF22314D), icon: Icons.man_rounded, price: '₹999', rating: '4.5'), oldPrice: '₹1,499', couponPrice: '₹699', discount: '33% OFF', votes: '8.7k', promoted: true),
          _FashionFeedCardData(item: _DiscoveryItem(title: 'Formal Trouser', subtitle: 'Men', accent: Color(0xFF3E7BD6), icon: Icons.dry_cleaning_rounded, price: '₹1,199', rating: '3.8'), oldPrice: '₹2,399', couponPrice: '₹899', discount: '50% OFF', votes: '9'),
          _FashionFeedCardData(item: _DiscoveryItem(title: 'Cotton Overshirt', subtitle: 'Men', accent: Color(0xFFC88B22), icon: Icons.checkroom_rounded, price: '₹899', rating: '4.6'), oldPrice: '₹1,899', couponPrice: '₹799', discount: '52% OFF', votes: '79', promoted: true),
          _FashionFeedCardData(item: _DiscoveryItem(title: 'Pure Cotton Jeans', subtitle: 'Men', accent: Color(0xFF6A7C91), icon: Icons.dry_cleaning_rounded, price: '₹1,049', rating: '3.9'), oldPrice: '₹2,099', couponPrice: '₹899', discount: '50% OFF', votes: '12.6k'),
          _FashionFeedCardData(item: _DiscoveryItem(title: 'Casual Shirt', subtitle: 'Men', accent: Color(0xFF5C8FD8), icon: Icons.checkroom_rounded, price: '₹649', rating: '4.4'), oldPrice: '₹1,299', couponPrice: '₹599', discount: '50% OFF', votes: '3.2k'),
        ],
    };
    final generated = List.generate(12, (index) {
      final template = templates[index % templates.length];
      final base = _extractFashionPrice(template.item.price);
      final price = base + (index ~/ templates.length) * 35;
      final rating = (double.tryParse(template.item.rating) ?? 4.2) + ((index % 3) * 0.1);
      return template.copyWith(
        item: _DiscoveryItem(
          title: template.item.title,
          subtitle: widget.item.subtitle,
          accent: template.item.accent,
          icon: template.item.icon,
          price: '₹$price',
          rating: rating.clamp(3.8, 4.9).toStringAsFixed(1),
          distance: widget.item.distance,
        ),
        oldPrice: '₹${price + 500 + (index % 4) * 120}',
        couponPrice: '₹${price > 120 ? price - 100 : price}',
        promoted: template.promoted || index % 5 == 0,
      );
    });
    switch (_fashionProfileSort) {
      case 'Low to High':
        generated.sort((a, b) => _extractFashionPrice(a.item.price).compareTo(_extractFashionPrice(b.item.price)));
        break;
      case 'High to Low':
        generated.sort((a, b) => _extractFashionPrice(b.item.price).compareTo(_extractFashionPrice(a.item.price)));
        break;
      case 'Newly Added':
        generated.sort((a, b) => b.newRank.compareTo(a.newRank));
        break;
      case 'Popular':
      default:
        generated.sort((a, b) {
          final promotedCompare = (b.promoted ? 1 : 0).compareTo(a.promoted ? 1 : 0);
          if (promotedCompare != 0) return promotedCompare;
          return (double.tryParse(b.item.rating) ?? 0).compareTo(double.tryParse(a.item.rating) ?? 0);
        });
    }
    return generated;
  }

  List<_FootwearFeedCardData> get _footwearProfileItems {
    final selected = _footwearProfileFilter == 'All' ? 'Men' : _footwearProfileFilter;
    final templates = switch (selected) {
      'Women' => const [
          _FootwearFeedCardData(item: _DiscoveryItem(title: 'Heels', subtitle: 'Women', accent: Color(0xFFE75D93), icon: Icons.woman_rounded, price: '₹1,249', rating: '4.6'), oldPrice: '₹2,299', couponPrice: '₹1,099', discount: '46% OFF', votes: '4.8k', promoted: true),
          _FootwearFeedCardData(item: _DiscoveryItem(title: 'Sandals', subtitle: 'Women', accent: Color(0xFFDF7DA0), icon: Icons.hiking_rounded, price: '₹749', rating: '4.4'), oldPrice: '₹1,399', couponPrice: '₹679', discount: '46% OFF', votes: '2.6k'),
          _FootwearFeedCardData(item: _DiscoveryItem(title: 'Flats', subtitle: 'Women', accent: Color(0xFFCB6E5B), icon: Icons.auto_awesome_rounded, price: '₹699', rating: '4.5'), oldPrice: '₹1,299', couponPrice: '₹629', discount: '46% OFF', votes: '1.8k'),
          _FootwearFeedCardData(item: _DiscoveryItem(title: 'Party Heels', subtitle: 'Women', accent: Color(0xFFFF7DA7), icon: Icons.star_rounded, price: '₹1,499', rating: '4.7'), oldPrice: '₹2,699', couponPrice: '₹1,299', discount: '44% OFF', votes: '2.1k'),
        ],
      'Boys' => const [
          _FootwearFeedCardData(item: _DiscoveryItem(title: 'School Shoes', subtitle: 'Boys', accent: Color(0xFFF2A13D), icon: Icons.school_rounded, price: '₹699', rating: '4.5'), oldPrice: '₹1,299', couponPrice: '₹629', discount: '46% OFF', votes: '1.7k', promoted: true),
          _FootwearFeedCardData(item: _DiscoveryItem(title: 'Sports Shoes', subtitle: 'Boys', accent: Color(0xFF5C8FD8), icon: Icons.directions_run_rounded, price: '₹999', rating: '4.4'), oldPrice: '₹1,799', couponPrice: '₹899', discount: '44% OFF', votes: '2.0k'),
          _FootwearFeedCardData(item: _DiscoveryItem(title: 'Kids Sandals', subtitle: 'Boys', accent: Color(0xFFC88B22), icon: Icons.child_friendly_rounded, price: '₹549', rating: '4.3'), oldPrice: '₹999', couponPrice: '₹499', discount: '45% OFF', votes: '983'),
          _FootwearFeedCardData(item: _DiscoveryItem(title: 'Slides', subtitle: 'Boys', accent: Color(0xFF6A7C91), icon: Icons.airline_seat_legroom_normal_rounded, price: '₹399', rating: '4.1'), oldPrice: '₹699', couponPrice: '₹359', discount: '43% OFF', votes: '812'),
        ],
      'Girls' => const [
          _FootwearFeedCardData(item: _DiscoveryItem(title: 'Cute Sandals', subtitle: 'Girls', accent: Color(0xFFE75D93), icon: Icons.girl_rounded, price: '₹699', rating: '4.7'), oldPrice: '₹1,299', couponPrice: '₹649', discount: '46% OFF', votes: '2.3k', promoted: true),
          _FootwearFeedCardData(item: _DiscoveryItem(title: 'Ballet Flats', subtitle: 'Girls', accent: Color(0xFFFF8DB5), icon: Icons.auto_awesome_rounded, price: '₹799', rating: '4.5'), oldPrice: '₹1,499', couponPrice: '₹729', discount: '47% OFF', votes: '1.4k'),
          _FootwearFeedCardData(item: _DiscoveryItem(title: 'Party Sandals', subtitle: 'Girls', accent: Color(0xFFDF7DA0), icon: Icons.star_rounded, price: '₹899', rating: '4.6'), oldPrice: '₹1,699', couponPrice: '₹829', discount: '47% OFF', votes: '1.1k'),
          _FootwearFeedCardData(item: _DiscoveryItem(title: 'School Shoes', subtitle: 'Girls', accent: Color(0xFF6A7C91), icon: Icons.school_rounded, price: '₹749', rating: '4.4'), oldPrice: '₹1,399', couponPrice: '₹699', discount: '46% OFF', votes: '936'),
        ],
      _ => const [
          _FootwearFeedCardData(item: _DiscoveryItem(title: 'Formal Shoes', subtitle: 'Men', accent: Color(0xFF22314D), icon: Icons.hiking_rounded, price: '₹1,199', rating: '4.5'), oldPrice: '₹2,199', couponPrice: '₹1,049', discount: '45% OFF', votes: '6.2k', promoted: true),
          _FootwearFeedCardData(item: _DiscoveryItem(title: 'Sneakers', subtitle: 'Men', accent: Color(0xFF3E7BD6), icon: Icons.directions_walk_rounded, price: '₹1,399', rating: '4.3'), oldPrice: '₹2,499', couponPrice: '₹1,249', discount: '44% OFF', votes: '3.8k'),
          _FootwearFeedCardData(item: _DiscoveryItem(title: 'Loafers', subtitle: 'Men', accent: Color(0xFF5C8FD8), icon: Icons.checkroom_rounded, price: '₹1,049', rating: '4.4'), oldPrice: '₹1,899', couponPrice: '₹949', discount: '45% OFF', votes: '2.5k', promoted: true),
          _FootwearFeedCardData(item: _DiscoveryItem(title: 'Slippers', subtitle: 'Men', accent: Color(0xFF1FB8A4), icon: Icons.airline_seat_legroom_normal_rounded, price: '₹499', rating: '4.1'), oldPrice: '₹899', couponPrice: '₹449', discount: '44% OFF', votes: '1.3k'),
        ],
    };
    final generated = List.generate(12, (index) {
      final template = templates[index % templates.length];
      final base = _extractFashionPrice(template.item.price);
      final price = base + (index ~/ templates.length) * 30;
      final rating = (double.tryParse(template.item.rating) ?? 4.2) + ((index % 3) * 0.1);
      return template.copyWith(
        item: _DiscoveryItem(
          title: template.item.title,
          subtitle: widget.item.subtitle,
          accent: template.item.accent,
          icon: template.item.icon,
          price: '₹$price',
          rating: rating.clamp(4.0, 4.9).toStringAsFixed(1),
          distance: widget.item.distance,
        ),
        oldPrice: '₹${price + 450 + (index % 4) * 120}',
        couponPrice: '₹${price > 100 ? price - 90 : price}',
        promoted: template.promoted || index % 5 == 0,
      );
    });
    switch (_footwearProfileSort) {
      case 'Low to High':
        generated.sort((a, b) => _extractFashionPrice(a.item.price).compareTo(_extractFashionPrice(b.item.price)));
        break;
      case 'High to Low':
        generated.sort((a, b) => _extractFashionPrice(b.item.price).compareTo(_extractFashionPrice(a.item.price)));
        break;
      case 'Newly Added':
        generated.sort((a, b) => b.newRank.compareTo(a.newRank));
        break;
      case 'Popular':
      default:
        generated.sort((a, b) {
          final promotedCompare = (b.promoted ? 1 : 0).compareTo(a.promoted ? 1 : 0);
          if (promotedCompare != 0) return promotedCompare;
          return (double.tryParse(b.item.rating) ?? 0).compareTo(double.tryParse(a.item.rating) ?? 0);
        });
    }
    return generated;
  }

  Future<void> _openFashionProfileSortSheet() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        const options = ['Popular', 'Low to High', 'High to Low', 'Newly Added'];
        return Container(
          margin: const EdgeInsets.fromLTRB(14, 0, 14, 16),
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0D7D0),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Sort items',
                  style: TextStyle(
                    color: Color(0xFF202435),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 14),
                for (final option in options)
                  _ShopSortOptionTile(
                    label: option,
                    selected: option == _fashionProfileSort,
                    onTap: () => Navigator.of(context).pop(option),
                  ),
              ],
            ),
          ),
        );
      },
    );
    if (selected != null && mounted) {
      setState(() => _fashionProfileSort = selected);
    }
  }

  Future<void> _openFashionProfileFilterPage() async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => _ShopFilterPage(
          initialGender: _fashionProfileFilter == 'All' ? 'Men' : _fashionProfileFilter,
        ),
      ),
    );
  }

  Future<void> _openFootwearProfileSortSheet() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        const options = ['Popular', 'Low to High', 'High to Low', 'Newly Added'];
        return Container(
          margin: const EdgeInsets.fromLTRB(14, 0, 14, 16),
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0D7D0),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Sort items',
                  style: TextStyle(
                    color: Color(0xFF202435),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 14),
                for (final option in options)
                  _ShopSortOptionTile(
                    label: option,
                    selected: option == _footwearProfileSort,
                    onTap: () => Navigator.of(context).pop(option),
                  ),
              ],
            ),
          ),
        );
      },
    );
    if (selected != null && mounted) {
      setState(() => _footwearProfileSort = selected);
    }
  }

  Future<void> _openFootwearProfileFilterPage() async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => _ShopFootwearFilterPage(
          initialGender: _footwearProfileFilter == 'All' ? 'Men' : _footwearProfileFilter,
        ),
      ),
    );
  }

  _DiscoveryItem _buildMenuItem({
    required String title,
    required int price,
    required String rating,
    required IconData icon,
  }) {
    return _DiscoveryItem(
      title: title,
      subtitle: widget.item.subtitle,
      accent: widget.item.accent,
      icon: icon,
      price: '₹${price < 49 ? 49 : price}',
      rating: rating,
      distance: widget.item.distance,
    );
  }

  List<_DiscoveryItem> get _recommendedItems => _shopItems.take(5).toList();

  Future<void> _scrollToSection(GlobalKey key) async {
    final targetContext = key.currentContext;
    if (targetContext == null) {
      return;
    }
    await Scrollable.ensureVisible(
      targetContext,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      alignment: 0.08,
    );
  }

  void _openShopItemPage(_DiscoveryItem item) {
    if (_isFashionProfile) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => _ShopItemDetailPage(
            item: item,
            supportsColorVariants: true,
            useFoodPopupStyle: false,
            onAddToCart: () => widget.onAddToCart(item),
            onOpenCart: widget.onOpenCart,
            onWishlistTap: () => widget.onWishlistToggle(item),
            onShareTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Share link for ${item.title} will be connected next.')),
              );
            },
          ),
        ),
      );
      return;
    }
    if (_isFootwearProfile) {
      Navigator.of(context).push<bool>(
        MaterialPageRoute<bool>(
          builder: (_) => _FootwearItemDetailPage(
            item: item,
            onAddToCart: () => widget.onAddToCart(item),
            onOpenCart: widget.onOpenCart,
            onWishlistTap: () => widget.onWishlistToggle(item),
            onShareTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Share link for ${item.title} will be connected next.')),
              );
            },
          ),
        ),
      );
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.52),
      builder: (_) => _ShopItemDetailPage(
        item: item,
        supportsColorVariants: false,
        useFoodPopupStyle: widget.shopCategory == 'Restaurant',
        onAddToCart: () => widget.onAddToCart(item),
        onOpenCart: widget.onOpenCart,
        onWishlistTap: () => widget.onWishlistToggle(item),
        onShareTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Share link for ${item.title} will be connected next.')),
          );
        },
      ),
    );
  }

  Future<void> _openMenuOverlay() async {
    final entries = <_ShopMenuOverlayEntry>[
      _ShopMenuOverlayEntry(
        title: 'Recommended for you',
        count: _recommendedItems.length,
        key: _recommendedSectionKey,
        highlighted: true,
      ),
      ..._menuSections.map(
        (section) => _ShopMenuOverlayEntry(
          title: section.title,
          count: section.items.length,
          key: _menuSectionKeys[section.title]!,
          items: section.items,
        ),
      ),
    ];

    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Menu',
      barrierColor: Colors.black.withValues(alpha: 0.56),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (context, animation, secondaryAnimation) {
        final expandedTitles = <String>{};
        return Material(
          color: Colors.transparent,
          child: SafeArea(
            child: Material(
              type: MaterialType.transparency,
              child: Stack(
              children: [
                Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width - 54,
                    constraints: const BoxConstraints(maxWidth: 320, maxHeight: 420),
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.18),
                          blurRadius: 26,
                          offset: const Offset(0, 16),
                        ),
                      ],
                    ),
                    child: StatefulBuilder(
                      builder: (context, setMenuState) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: ListView.separated(
                                shrinkWrap: true,
                                itemCount: entries.length,
                                separatorBuilder: (_, _) => const SizedBox(height: 2),
                                itemBuilder: (context, index) {
                                  final entry = entries[index];
                                  final isExpanded = expandedTitles.contains(entry.title);
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      InkWell(
                                        onTap: () async {
                                          Navigator.of(context).pop();
                                          await Future<void>.delayed(const Duration(milliseconds: 120));
                                          if (!mounted) {
                                            return;
                                          }
                                          await _scrollToSection(entry.key);
                                        },
                                        borderRadius: BorderRadius.circular(14),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                    Flexible(
                                                      child: Text(
                                                        entry.title,
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                        style: TextStyle(
                                                          color: entry.highlighted
                                                              ? const Color(0xFF2E9B65)
                                                              : const Color(0xFF4B5060),
                                                          fontSize: entry.highlighted ? 13.4 : 12.8,
                                                          fontWeight:
                                                              entry.highlighted ? FontWeight.w900 : FontWeight.w700,
                                                          height: 1.15,
                                                        ),
                                                      ),
                                                    ),
                                                    if (entry.items.isNotEmpty) ...[
                                                      const SizedBox(width: 4),
                                                      GestureDetector(
                                                        behavior: HitTestBehavior.opaque,
                                                        onTap: () {
                                                          setMenuState(() {
                                                            if (isExpanded) {
                                                              expandedTitles.remove(entry.title);
                                                            } else {
                                                              expandedTitles.add(entry.title);
                                                            }
                                                          });
                                                        },
                                                        child: Padding(
                                                          padding: const EdgeInsets.all(2),
                                                          child: Icon(
                                                            isExpanded
                                                                ? Icons.keyboard_arrow_up_rounded
                                                                : Icons.keyboard_arrow_down_rounded,
                                                            size: 16,
                                                            color: const Color(0xFF5A6172),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                '${entry.count}',
                                                textAlign: TextAlign.right,
                                                style: TextStyle(
                                                  color: entry.highlighted
                                                      ? const Color(0xFF2E9B65)
                                                      : const Color(0xFF535A6C),
                                                  fontSize: 12.8,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      if (isExpanded)
                                        Padding(
                                          padding: const EdgeInsets.only(left: 10, right: 4, bottom: 8),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              for (final item in entry.items)
                                                InkWell(
                                                  onTap: () async {
                                                    Navigator.of(context).pop();
                                                    await Future<void>.delayed(const Duration(milliseconds: 120));
                                                    if (!mounted) {
                                                      return;
                                                    }
                                                    await _scrollToSection(_menuItemKeys[item]!);
                                                  },
                                                  borderRadius: BorderRadius.circular(12),
                                                  child: Padding(
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 7,
                                                    ),
                                                    child: Text(
                                                      item.title,
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                        color: Color(0xFF666D7B),
                                                        fontSize: 12.4,
                                                        fontWeight: FontWeight.w600,
                                                        height: 1.15,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                Positioned(
                  right: 16,
                  bottom: 20,
                  child: Material(
                    color: const Color(0xFF333543),
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(16),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.close_rounded, size: 16, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'Close',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.96, end: 1).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    disposeScrollToTopVisibility();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.autoAddItem && !_didAutoAdd) {
      _didAutoAdd = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onAddToCart(widget.item).then((added) {
          if (!mounted || !added) {
            return;
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${widget.item.title} added from ${widget.item.subtitle}.')),
          );
        });
        if (!mounted) {
          return;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isFashionProfile) {
      final shopName = widget.item.subtitle;
      final items = _fashionProfileItems;
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          foregroundColor: const Color(0xFF24314B),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.shopping_cart_outlined),
              onPressed: widget.onOpenCart,
            ),
          ],
        ),
        body: Stack(
          children: [
            ListView(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(14, 4, 14, 24),
              children: [
                Text(
                  shopName,
                  style: const TextStyle(
                    color: Color(0xFF24314B),
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.place_outlined, size: 15, color: Color(0xFF697284)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Pocket C, Sector 22',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF697284),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      widget.item.distance,
                      style: const TextStyle(
                        color: Color(0xFF697284),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        color: _ratingColor(widget.item.rating),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded, size: 12, color: Colors.white),
                          const SizedBox(width: 3),
                          Text(
                            widget.item.rating,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (_shopTiming.shouldHighlight) ...[
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _ShopTimingPill(state: _shopTiming),
                  ),
                ],
                const SizedBox(height: 18),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _ShopMenuFilterChip(
                        label: 'Filter',
                        icon: Icons.tune_rounded,
                        onTap: _openFashionProfileFilterPage,
                      ),
                      const SizedBox(width: 10),
                      _ShopMenuFilterChip(
                        label: _fashionProfileSort,
                        icon: Icons.swap_vert_rounded,
                        onTap: _openFashionProfileSortSheet,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _ShopSubcategoryFilter(
                  category: 'Fashion',
                  options: _fashionProfileOptions,
                  selected: _fashionProfileFilter,
                  onSelected: (value) => setState(() => _fashionProfileFilter = value),
                ),
                const SizedBox(height: 14),
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
                      isWishlisted: widget.isWishlisted(data.item),
                      onTap: () => _openShopItemPage(data.item),
                      onWishlistToggle: () => widget.onWishlistToggle(data.item),
                    );
                  },
                ),
                const SizedBox(height: 24),
                const _MadeWithLoveFooter(),
              ],
            ),
            buildScrollToTopOverlay(bottom: 28),
          ],
        ),
      );
    }
    if (_isFootwearProfile) {
      final shopName = widget.item.subtitle;
      final items = _footwearProfileItems;
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          foregroundColor: const Color(0xFF24314B),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.shopping_cart_outlined),
              onPressed: widget.onOpenCart,
            ),
          ],
        ),
        body: Stack(
          children: [
            ListView(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(14, 4, 14, 24),
              children: [
                Text(
                  shopName,
                  style: const TextStyle(
                    color: Color(0xFF24314B),
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.place_outlined, size: 15, color: Color(0xFF697284)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Pocket C, Sector 22',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF697284),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      widget.item.distance,
                      style: const TextStyle(
                        color: Color(0xFF697284),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        color: _ratingColor(widget.item.rating),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded, size: 12, color: Colors.white),
                          const SizedBox(width: 3),
                          Text(
                            widget.item.rating,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (_shopTiming.shouldHighlight) ...[
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _ShopTimingPill(state: _shopTiming),
                  ),
                ],
                const SizedBox(height: 18),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _ShopMenuFilterChip(
                        label: 'Filter',
                        icon: Icons.tune_rounded,
                        onTap: _openFootwearProfileFilterPage,
                      ),
                      const SizedBox(width: 10),
                      _ShopMenuFilterChip(
                        label: _footwearProfileSort,
                        icon: Icons.swap_vert_rounded,
                        onTap: _openFootwearProfileSortSheet,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _ShopSubcategoryFilter(
                  category: 'Footwear',
                  options: _footwearProfileOptions,
                  selected: _footwearProfileFilter,
                  onSelected: (value) => setState(() => _footwearProfileFilter = value),
                ),
                const SizedBox(height: 14),
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
                      isWishlisted: widget.isWishlisted(data.item),
                      onTap: () => _openShopItemPage(data.item),
                      onWishlistToggle: () => widget.onWishlistToggle(data.item),
                    );
                  },
                ),
                const SizedBox(height: 24),
                const _MadeWithLoveFooter(),
              ],
            ),
            buildScrollToTopOverlay(bottom: 28),
          ],
        ),
      );
    }
    final accent = widget.item.accent;
    final shopName = widget.item.subtitle;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            SafeArea(
              bottom: false,
              child: Row(
                children: [
                  _SimpleHeaderCircleButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: const Color(0xFFE7E9EE)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search_rounded, color: Color(0xFF7E828D)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Search in $shopName',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF8A8E97),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  _SimpleHeaderCircleButton(
                    icon: Icons.shopping_cart_outlined,
                    onTap: widget.onOpenCart,
                  ),
                  const SizedBox(width: 10),
                  _SimpleHeaderCircleButton(
                    icon: Icons.more_vert_rounded,
                    onTap: () => widget.onWishlistToggle(widget.item),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.only(bottom: 14),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFFF0F1F4)),
                ),
              ),
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.eco_rounded, size: 15, color: Color(0xFF38A34D)),
                    SizedBox(width: 4),
                    Text(
                      'Pure Veg',
                      style: TextStyle(
                        color: Color(0xFF3E9E53),
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  shopName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Color(0xFF24314B),
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    height: 1.05,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(Icons.info_outline_rounded, size: 18, color: Color(0xFF697284)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.place_outlined, size: 15, color: Color(0xFF697284)),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            '${widget.item.distance} · Sector 22',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: Color(0xFF697284),
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: Color(0xFF697284)),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    const Row(
                                      children: [
                                        Icon(Icons.flash_on_rounded, size: 16, color: Color(0xFF2C9D59)),
                                        SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            'Schedule for later',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: Color(0xFF2C9D59),
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                        Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: Color(0xFF2C9D59)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: _ratingColor(widget.item.rating),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.star_rounded, size: 12, color: Colors.white),
                                        const SizedBox(width: 3),
                                        Text(
                                          widget.item.rating,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (_shopTiming.shouldHighlight) ...[
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _ShopTimingPill(state: _shopTiming),
                  ),
                ],
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(0),
                    border: const Border(
                      top: BorderSide(color: Color(0xFFF0F1F4)),
                      bottom: BorderSide(color: Color(0xFFF0F1F4)),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.verified_rounded, color: accent, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Flat ₹200 OFF above ₹399',
                        style: TextStyle(
                          color: accent,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const Spacer(),
                      const Text(
                        '5 offers',
                        style: TextStyle(
                          color: Color(0xFF747B89),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: const [
                _ShopMenuFilterChip(label: 'Filters', icon: Icons.tune_rounded),
                SizedBox(width: 10),
                _ShopMenuFilterChip(label: 'Highly reordered', icon: Icons.refresh_rounded),
                SizedBox(width: 10),
                _ShopMenuFilterChip(label: "Kid's choice", icon: Icons.face_rounded),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            key: _recommendedSectionKey,
            children: [
              const Expanded(
                child: Text(
                  'Recommended for you',
                  style: TextStyle(
                    color: Color(0xFF202A3E),
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Icon(Icons.keyboard_arrow_up_rounded, color: Color(0xFF656E7E)),
            ],
          ),
          const SizedBox(height: 8),
          ..._recommendedItems.map(
            (item) => _ShopMenuItemRow(
              key: _menuItemKeys[item],
              item: item,
              onOpenTap: () => _openShopItemPage(item),
              onWishlistTap: () => widget.onWishlistToggle(item),
              onShareTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Share link for ${item.title} will be connected next.')),
                );
              },
              onAddTap: () => _openShopItemPage(item),
            ),
          ),
          ..._menuSections.expand(
            (section) => [
              _ShopMenuSectionHeader(
                key: _menuSectionKeys[section.title],
                title: section.title,
              ),
              ...section.items.map(
                (item) => _ShopMenuItemRow(
                  key: _menuItemKeys[item],
                  item: item,
                  onOpenTap: () => _openShopItemPage(item),
                  onWishlistTap: () => widget.onWishlistToggle(item),
                  onShareTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Share link for ${item.title} will be connected next.')),
                    );
                  },
                  onAddTap: () => _openShopItemPage(item),
                ),
              ),
            ],
          ),
                const SizedBox(height: 74),
              ],
            ),
          ),
          buildScrollToTopOverlay(bottom: 86),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'menu-fab',
            onPressed: _openMenuOverlay,
            backgroundColor: const Color(0xFF2D303B),
            foregroundColor: Colors.white,
            label: const Text(
              'Menu',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            icon: const Icon(Icons.restaurant_menu_rounded),
          ),
        ],
      ),
    );
  }
}

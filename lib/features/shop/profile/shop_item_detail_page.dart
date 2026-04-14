part of '../../../main.dart';

class _ShopItemDetailPage extends StatefulWidget {
  const _ShopItemDetailPage({
    required this.item,
    required this.onAddToCart,
    required this.onOpenCart,
    required this.onWishlistTap,
    required this.onShareTap,
    this.supportsColorVariants = false,
    this.useFoodPopupStyle = false,
    this.returnToShopOnBackAfterAdd = false,
  });

  final _DiscoveryItem item;
  final Future<bool> Function() onAddToCart;
  final VoidCallback onOpenCart;
  final VoidCallback onWishlistTap;
  final VoidCallback onShareTap;
  final bool supportsColorVariants;
  final bool useFoodPopupStyle;
  final bool returnToShopOnBackAfterAdd;

  @override
  State<_ShopItemDetailPage> createState() => _ShopItemDetailPageState();
}

class _ShopItemDetailPageState extends State<_ShopItemDetailPage> {
  int _selectedPreviewIndex = 0;
  int _selectedGalleryIndex = 0;
  String? _selectedSize = '40';
  int _itemQuantity = 1;
  bool _addedInSession = false;
  late final PageController _galleryController;
  late final TextEditingController _cookingRequestController;
  String _selectedVariant = '8 Inches';
  final Set<String> _selectedBeverages = {};
  bool _selectedExtraCheese = false;

  static const List<String> _sizes = ['38', '40', '42', '44'];
  static const List<String> _previewLabels = ['Multi', 'Olive', 'Sky', 'Sand', 'Charcoal'];
  static const int _galleryImageCount = 4;
  static const List<String> _foodVariants = ['8 Inches', '9 Inches'];
  static const List<String> _foodBeverages = ['Sprite [250 Ml]', 'Coke [250 Ml]', 'Thums Up [250 Ml]'];
  static const List<String> _foodQuickNotes = ['No chilli', 'No onion or garlic', 'No mushroom'];

  @override
  void initState() {
    super.initState();
    _galleryController = PageController();
    _cookingRequestController = TextEditingController();
  }

  int get _basePrice {
    final extracted = _extractAmount(widget.item.price);
    return extracted <= 0 ? 999 : extracted;
  }

  int get _mrp {
    final calculated = (_basePrice * 1.92).round();
    return calculated <= _basePrice ? _basePrice + 400 : calculated;
  }

  int get _discountPercent {
    if (_mrp <= 0 || _mrp <= _basePrice) {
      return 0;
    }
    final percent = (((_mrp - _basePrice) / _mrp) * 100);
    if (!percent.isFinite || percent.isNaN) {
      return 0;
    }
    return percent.round();
  }
  String get _voteCount {
    final rating = double.tryParse(widget.item.rating) ?? 4.1;
    if (rating >= 4.5) return '8.7k';
    if (rating >= 4.0) return '1.9k';
    return '879';
  }
  String get _productTitle => '${widget.item.subtitle} ${widget.item.title}';
  bool get _isOutOfStock => _isShopItemOutOfStock(widget.item);
  String get _selectedColorLabel =>
      widget.supportsColorVariants ? _previewLabels[_selectedPreviewIndex] : 'Multi';
  String get _detailsText =>
      'Multicoloured checks checked opaque casual shirt, has a spread collar, button placket, chest pocket, long regular sleeves and a straight hem.';
  int get _foodOptionTotal =>
      (_selectedVariant == '9 Inches' ? 100 : 0) +
      (_selectedBeverages.length * 30) +
      (_selectedExtraCheese ? 40 : 0);
  int get _foodFinalPrice => _basePrice + _foodOptionTotal;
  _ShopTimingState get _shopTiming => _shopTimingFor(widget.item.subtitle, _shopCategoryForItem(widget.item));

  String _galleryAssetKey({
    required int colorIndex,
    required int imageIndex,
  }) {
    if (!widget.supportsColorVariants) {
      return '${_assetSlug(widget.item.title)}_${imageIndex + 1}';
    }
    return '${_assetSlug(widget.item.title)}_${_assetSlug(_previewLabels[colorIndex])}_${imageIndex + 1}';
  }

  @override
  void dispose() {
    _cookingRequestController.dispose();
    _galleryController.dispose();
    super.dispose();
  }

  void _selectColor(int index) {
    if (!widget.supportsColorVariants) {
      return;
    }
    setState(() {
      _selectedPreviewIndex = index;
      _selectedGalleryIndex = 0;
    });
    if (_galleryController.hasClients) {
      _galleryController.jumpToPage(0);
    }
  }

  Future<void> _addToCart() async {
    if (_addedInSession) {
      widget.onOpenCart();
      return;
    }
    final added = await widget.onAddToCart();
    if (added) {
      setState(() {
        _addedInSession = true;
      });
    }
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${widget.item.title} added to cart.')),
    );
  }

  void _closeWithResult() {
    Navigator.of(context).pop(
      widget.returnToShopOnBackAfterAdd && _addedInSession,
    );
  }

  Widget _buildFoodItemSheet(_DiscoveryItem item) {
    return FractionallySizedBox(
      heightFactor: 0.82,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 28),
            decoration: const BoxDecoration(
              color: Color(0xFFF5F2EE),
              borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 18),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                              child: SizedBox(
                                height: 215,
                                width: double.infinity,
                                child: _TemporaryCatalogImage(
                                  item: item,
                                  fallback: _SceneThumb(
                                    title: item.title,
                                    accent: item.accent,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 13,
                                        height: 13,
                                        margin: const EdgeInsets.only(top: 3),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(color: const Color(0xFF31A24C), width: 1.5),
                                          borderRadius: BorderRadius.circular(3),
                                        ),
                                        child: const Center(
                                          child: DecoratedBox(
                                            decoration: BoxDecoration(
                                              color: Color(0xFF31A24C),
                                              shape: BoxShape.circle,
                                            ),
                                            child: SizedBox(width: 5, height: 5),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          item.title,
                                          style: const TextStyle(
                                            color: Color(0xFF202A3E),
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                            height: 1.15,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      _RoundActionIcon(
                                        icon: Icons.bookmark_border_rounded,
                                        color: const Color(0xFF6A7484),
                                        onTap: widget.onWishlistTap,
                                        size: 32,
                                        iconSize: 17,
                                      ),
                                      const SizedBox(width: 8),
                                      _RoundActionIcon(
                                        icon: Icons.share_outlined,
                                        color: const Color(0xFF6A7484),
                                        onTap: widget.onShareTap,
                                        size: 32,
                                        iconSize: 17,
                                      ),
                                      const SizedBox(width: 8),
                                      _RoundActionIcon(
                                        icon: Icons.shopping_cart_outlined,
                                        color: const Color(0xFF6A7484),
                                        onTap: widget.onOpenCart,
                                        size: 32,
                                        iconSize: 17,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Start your favourite ${item.title.toLowerCase()}.',
                                    style: const TextStyle(
                                      color: Color(0xFF7A7F89),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    '+1 more',
                                    style: TextStyle(
                                      color: Color(0xFF35A765),
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Quantity',
                              style: TextStyle(
                                color: Color(0xFF202A3E),
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Required • Select any 1 option',
                              style: TextStyle(
                                color: Color(0xFF8A8F98),
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ..._foodVariants.map(
                              (variant) => _FoodSelectableRow(
                                label: variant,
                                price: variant == '9 Inches' ? '₹${_basePrice + 100}' : '₹$_basePrice',
                                selected: _selectedVariant == variant,
                                isRound: true,
                                onTap: () => setState(() => _selectedVariant = variant),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Choose Your Cold Beverages',
                              style: TextStyle(
                                color: Color(0xFF202A3E),
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Select up to 5 options',
                              style: TextStyle(
                                color: Color(0xFF8A8F98),
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ..._foodBeverages.map(
                              (beverage) => _FoodSelectableRow(
                                label: beverage,
                                price: '₹30',
                                selected: _selectedBeverages.contains(beverage),
                                isRound: false,
                                onTap: () => setState(() {
                                  if (_selectedBeverages.contains(beverage)) {
                                    _selectedBeverages.remove(beverage);
                                  } else if (_selectedBeverages.length < 5) {
                                    _selectedBeverages.add(beverage);
                                  }
                                }),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Extra Cheese',
                              style: TextStyle(
                                color: Color(0xFF202A3E),
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Select up to 1 option',
                              style: TextStyle(
                                color: Color(0xFF8A8F98),
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _FoodSelectableRow(
                              label: 'Extra Cheese',
                              price: '₹40',
                              selected: _selectedExtraCheese,
                              isRound: true,
                              onTap: () => setState(() => _selectedExtraCheese = !_selectedExtraCheese),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Expanded(
                                  child: Text(
                                    'Add a cooking request (optional)',
                                    style: TextStyle(
                                      color: Color(0xFF202A3E),
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                Icon(Icons.info_outline_rounded, size: 18, color: Color(0xFF8A8F98)),
                              ],
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: _cookingRequestController,
                              maxLines: 4,
                              decoration: InputDecoration(
                                hintText: "e.g. Don't make it too spicy",
                                hintStyle: const TextStyle(
                                  color: Color(0xFFB1B5BE),
                                  fontWeight: FontWeight.w700,
                                ),
                                filled: true,
                                fillColor: const Color(0xFFF5F3F7),
                                contentPadding: const EdgeInsets.all(14),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _foodQuickNotes
                                  .map(
                                    (note) => _FoodTagChip(
                                      label: note,
                                      onTap: () => setState(() {
                                        _cookingRequestController.text = note;
                                      }),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 18,
                        offset: const Offset(0, -6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 112,
                        height: 52,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2FFF3),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFF7AC08A)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            InkWell(
                              onTap: () => setState(() {
                                if (_itemQuantity > 1) _itemQuantity -= 1;
                              }),
                              child: const Icon(Icons.remove_rounded, color: Color(0xFF26A05A)),
                            ),
                            Text(
                              '$_itemQuantity',
                              style: const TextStyle(
                                color: Color(0xFF22314D),
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            InkWell(
                              onTap: () => setState(() => _itemQuantity += 1),
                              child: const Icon(Icons.add_rounded, color: Color(0xFF26A05A)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _addedInSession
                              ? _addToCart
                              : !_isOutOfStock && _shopTiming.acceptsOrders
                                  ? _addToCart
                                  : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF26A05A),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: _addedInSession
                                ? const [
                                    Text(
                                      'Go to Cart',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ]
                                : !_shopTiming.acceptsOrders
                                    ? const [
                                        Text(
                                          'Orders closed',
                                          style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ]
                                : _isOutOfStock
                                    ? const [
                                        Text(
                                          'Out of stock',
                                          style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ]
                                : [
                                    Text(
                                      'Add item ₹${_foodFinalPrice + 25}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        decoration: TextDecoration.lineThrough,
                                        decorationColor: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      '₹$_foodFinalPrice',
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w900,
                                        height: 1,
                                      ),
                                    ),
                                  ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Center(
              child: InkWell(
                onTap: _closeWithResult,
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B3C46),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                  ),
                  child: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStandardItemScaffold(_DiscoveryItem item) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F3EE),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 120),
          children: [
            Row(
              children: [
                _SimpleHeaderCircleButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: _closeWithResult,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    height: 42,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: const Color(0xFFE5E7ED)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search_rounded, size: 18, color: Color(0xFF7E828D)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Search shoes, sandals, slippers...',
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
                  icon: Icons.favorite_border_rounded,
                  onTap: widget.onWishlistTap,
                ),
                const SizedBox(width: 8),
                _SimpleHeaderCircleButton(
                  icon: Icons.shopping_cart_outlined,
                  onTap: widget.onOpenCart,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                    child: SizedBox(
                      height: 270,
                      width: double.infinity,
                      child: _TemporaryCatalogImage(
                        item: item,
                        fallback: _SceneThumb(
                          title: item.title,
                          accent: item.accent,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Row(
                      children: [
                        Container(
                          width: 13,
                          height: 13,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: const Color(0xFF31A24C), width: 1.5),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: const Center(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: Color(0xFF31A24C),
                                shape: BoxShape.circle,
                              ),
                              child: SizedBox(width: 5, height: 5),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item.subtitle,
                            style: const TextStyle(
                              color: Color(0xFF697284),
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                        ),
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
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                    child: Text(
                      item.title,
                      style: const TextStyle(
                        color: Color(0xFF202A3E),
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        height: 1.05,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Row(
                      children: [
                        Container(
                          width: 28,
                          height: 5,
                          decoration: BoxDecoration(
                            color: const Color(0xFF27A65A),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Highly reordered',
                          style: TextStyle(
                            color: Color(0xFF6E7480),
                            fontWeight: FontWeight.w700,
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                    child: Text(
                      item.price,
                      style: const TextStyle(
                        color: Color(0xFF232A3C),
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Text(
                      'Freshly prepared ${item.title.toLowerCase()} from ${item.subtitle}. You can add this item to cart and continue shopping from the same shop.',
                      style: const TextStyle(
                        color: Color(0xFF757B87),
                        fontWeight: FontWeight.w700,
                        fontSize: 12.2,
                        height: 1.4,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _ShopMenuFilterChip(label: item.distance, icon: Icons.place_outlined),
                        _ShopMenuFilterChip(label: 'Customisable', icon: Icons.tune_rounded),
                        _ShopMenuFilterChip(label: 'Fast prep', icon: Icons.flash_on_rounded),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Item details',
                    style: TextStyle(
                      color: Color(0xFF202A3E),
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'You can review the full shop menu after adding this item. Cart will stay locked to one shop at a time.',
                    style: TextStyle(
                      color: Color(0xFF6E7480),
                      fontWeight: FontWeight.w700,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 18,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 112,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFF2FFF3),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF7AC08A)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InkWell(
                      onTap: () => setState(() {
                        if (_itemQuantity > 1) _itemQuantity -= 1;
                      }),
                      child: const Icon(Icons.remove_rounded, color: Color(0xFF26A05A)),
                    ),
                    Text(
                      '$_itemQuantity',
                      style: const TextStyle(
                        color: Color(0xFF22314D),
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    InkWell(
                      onTap: () => setState(() => _itemQuantity += 1),
                      child: const Icon(Icons.add_rounded, color: Color(0xFF26A05A)),
                    ),
                  ],
                ),
              ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _addedInSession
                        ? _addToCart
                        : !_isOutOfStock && _shopTiming.acceptsOrders
                            ? _addToCart
                            : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF26A05A),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 17),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(
                    _addedInSession
                        ? 'Go to Cart'
                        : _isOutOfStock
                            ? 'Out of stock'
                        : _shopTiming.acceptsOrders
                            ? 'Add item ${item.price}'
                            : 'Orders closed',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    if (widget.useFoodPopupStyle) {
      return PopScope<bool>(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) {
            return;
          }
          _closeWithResult();
        },
        child: _buildFoodItemSheet(item),
      );
    }
    if (!widget.supportsColorVariants) {
      return PopScope<bool>(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) {
            return;
          }
          _closeWithResult();
        },
        child: _buildStandardItemScaffold(item),
      );
    }
    return PopScope<bool>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }
        _closeWithResult();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(0, 6, 0, 120),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 4, 14, 12),
                child: Row(
                  children: [
                    _SimpleHeaderCircleButton(
                      icon: Icons.arrow_back_ios_new_rounded,
                      onTap: _closeWithResult,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        height: 42,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: const Color(0xFFE6E8EE)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFFF5F8F), Color(0xFFF2A13D)],
                                ),
                              ),
                              child: const Center(
                                child: Text(
                                  'M',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Search in ${item.subtitle}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFF8A8E97),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const Icon(Icons.search_rounded, color: Color(0xFF7E828D)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _SimpleHeaderCircleButton(
                      icon: Icons.favorite_border_rounded,
                      onTap: widget.onWishlistTap,
                    ),
                    const SizedBox(width: 8),
                    _SimpleHeaderCircleButton(
                      icon: Icons.shopping_cart_outlined,
                      onTap: widget.onOpenCart,
                    ),
                  ],
                ),
              ),
              Stack(
                children: [
                  SizedBox(
                    height: 380,
                    width: double.infinity,
                    child: widget.supportsColorVariants
                        ? PageView.builder(
                            controller: _galleryController,
                            itemCount: _galleryImageCount,
                            onPageChanged: (index) => setState(() => _selectedGalleryIndex = index),
                            itemBuilder: (context, index) {
                              return _TemporaryCatalogImage(
                                item: item,
                                assetKey: _galleryAssetKey(
                                  colorIndex: _selectedPreviewIndex,
                                  imageIndex: index,
                                ),
                                fallback: _CatalogGalleryFallback(
                                  item: item,
                                  colorLabel: _selectedColorLabel,
                                  imageIndex: index,
                                ),
                              );
                            },
                          )
                        : _TemporaryCatalogImage(
                            item: item,
                            fallback: _SceneThumb(
                              title: item.title,
                              accent: item.accent,
                            ),
                          ),
                  ),
                  Positioned(
                    left: 0,
                    top: 18,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: const BoxDecoration(
                        color: Color(0xFFD32F5E),
                        borderRadius: BorderRadius.horizontal(right: Radius.circular(10)),
                      ),
                      child: const Text(
                        'Mega Price Drop',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 12,
                    bottom: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.94),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            item.rating,
                            style: const TextStyle(
                              color: Color(0xFF252B36),
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.star_rounded, size: 14, color: _ratingColor(item.rating)),
                          Container(
                            width: 1,
                            height: 14,
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            color: const Color(0xFFD0D3D9),
                          ),
                          Text(
                            _voteCount,
                            style: const TextStyle(
                              color: Color(0xFF5F6675),
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.chevron_right_rounded, size: 16, color: Color(0xFF5F6675)),
                        ],
                      ),
                    ),
                  ),
                  if (widget.supportsColorVariants)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 18,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _galleryImageCount,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 160),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: _selectedGalleryIndex == index
                                  ? Colors.black
                                  : Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFF0F1F4)),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: item.accent.withValues(alpha: 0.18),
                              child: Text(
                                item.subtitle.characters.first.toUpperCase(),
                                style: TextStyle(
                                  color: item.accent,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                item.subtitle,
                                style: const TextStyle(
                                  color: Color(0xFF515866),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const Icon(Icons.store_mall_directory_outlined, size: 18, color: Color(0xFF747B89)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _SimpleHeaderCircleButton(
                      icon: Icons.share_outlined,
                      onTap: widget.onShareTap,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
                child: Text(
                  _productTitle,
                  style: const TextStyle(
                    color: Color(0xFF232A3C),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    height: 1.1,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
                child: Row(
                  children: [
                    Text(
                      'MRP ₹$_mrp',
                      style: const TextStyle(
                        color: Color(0xFF8C919C),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      item.price,
                      style: const TextStyle(
                        color: Color(0xFF232A3C),
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$_discountPercent% OFF!',
                      style: const TextStyle(
                        color: Color(0xFFFF4F6F),
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7F8),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFFFD6DF)),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Get at ₹639\nWith Coupon + Bank Offer',
                          style: TextStyle(
                            color: Color(0xFF303645),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            height: 1.1,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF24A05A),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Extra ₹400 Off',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (widget.supportsColorVariants) ...[
                const Padding(
                  padding: EdgeInsets.fromLTRB(14, 16, 14, 0),
                  child: Text(
                    'Colour Multi',
                    style: TextStyle(
                      color: Color(0xFF232A3C),
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 94,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    itemCount: _previewLabels.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      return _ItemPreviewThumb(
                        item: item,
                        colorLabel: _previewLabels[index],
                        selected: _selectedPreviewIndex == index,
                        assetKey: _galleryAssetKey(colorIndex: index, imageIndex: 0),
                        onTap: () => _selectColor(index),
                      );
                    },
                  ),
                ),
              ],
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 20, 14, 0),
                child: const Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Select Size',
                        style: TextStyle(
                          color: Color(0xFF232A3C),
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _sizes
                      .map(
                        (size) => _ItemSizeChip(
                          label: size,
                          selected: _selectedSize == size,
                          onTap: () => setState(() => _selectedSize = size),
                        ),
                      )
                      .toList(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 20, 14, 0),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(14, 16, 14, 18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: const Color(0xFFE8E9EE)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Collection Name',
                        style: TextStyle(
                          color: Color(0xFF2B3140),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.title.toLowerCase(),
                        style: const TextStyle(
                          color: Color(0xFF515866),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 18),
                      const _ProductSpecGrid(),
                      const SizedBox(height: 18),
                      const Text(
                        'Product Details',
                        style: TextStyle(
                          color: Color(0xFF2B3140),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _detailsText,
                        style: const TextStyle(
                          color: Color(0xFF515866),
                          fontWeight: FontWeight.w700,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Size & Fit',
                        style: TextStyle(
                          color: Color(0xFF2B3140),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Brand Fit: Comfort\nFit: Regular Fit\nThe model (height 6\') is wearing a size ${_selectedSize ?? '40'}',
                        style: const TextStyle(
                          color: Color(0xFF515866),
                          fontWeight: FontWeight.w700,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Material & Care',
                        style: TextStyle(
                          color: Color(0xFF2B3140),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'CARE INSTRUCTIONS: Machine wash. Wash & dry inside out. Wash separately. Do not soak for a long time. Do not bleach. Tumble dry normal cycle. Medium heat iron or line dry in reverse medium heat iron.',
                        style: TextStyle(
                          color: Color(0xFF515866),
                          fontWeight: FontWeight.w700,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(14, 26, 14, 0),
                child: Text(
                  'Ratings & Reviews',
                  style: TextStyle(
                    color: Color(0xFF232A3C),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 18,
                  offset: const Offset(0, -6),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _addedInSession
                        ? _addToCart
                        : _isOutOfStock
                            ? null
                            : _addToCart,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF3E78),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 17),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.shopping_cart_outlined, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          _addedInSession
                              ? 'Go to Cart'
                              : _isOutOfStock
                                  ? 'Out of stock'
                                  : 'Add to Bag',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FoodSelectableRow extends StatelessWidget {
  const _FoodSelectableRow({
    required this.label,
    required this.price,
    required this.selected,
    required this.isRound,
    required this.onTap,
  });

  final String label;
  final String price;
  final bool selected;
  final bool isRound;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF202A3E),
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
            Text(
              price,
              style: const TextStyle(
                color: Color(0xFF202A3E),
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: selected && !isRound ? const Color(0xFF26A05A) : Colors.white,
                shape: isRound ? BoxShape.circle : BoxShape.rectangle,
                borderRadius: isRound ? null : BorderRadius.circular(4),
                border: Border.all(color: const Color(0xFF26A05A), width: 1.8),
              ),
              child: selected
                  ? Icon(
                      isRound ? Icons.circle : Icons.check_rounded,
                      size: isRound ? 12 : 14,
                      color: const Color(0xFF26A05A),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _FoodTagChip extends StatelessWidget {
  const _FoodTagChip({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0xFFE3E6EC)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Color(0xFF6E7480),
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _ItemPreviewThumb extends StatelessWidget {
  const _ItemPreviewThumb({
    required this.item,
    required this.colorLabel,
    required this.selected,
    required this.assetKey,
    required this.onTap,
  });

  final _DiscoveryItem item;
  final String colorLabel;
  final bool selected;
  final String assetKey;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 66,
        height: 86,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? const Color(0xFFFF4F6F) : const Color(0xFFE8E9EE),
            width: selected ? 2 : 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _TemporaryCatalogImage(
                item: item,
                assetKey: assetKey,
                fallback: _CatalogGalleryFallback(
                  item: item,
                  colorLabel: colorLabel,
                  imageIndex: 0,
                  compact: true,
                ),
              ),
              Positioned(
                left: 4,
                right: 4,
                bottom: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.88),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    colorLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: selected ? const Color(0xFFFF4F6F) : const Color(0xFF4B5567),
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CatalogGalleryFallback extends StatelessWidget {
  const _CatalogGalleryFallback({
    required this.item,
    required this.colorLabel,
    required this.imageIndex,
    this.compact = false,
  });

  final _DiscoveryItem item;
  final String colorLabel;
  final int imageIndex;
  final bool compact;

  Color get _colorAccent => switch (colorLabel.toLowerCase()) {
        'olive' => const Color(0xFF6E8B3D),
        'sky' => const Color(0xFF6CAED9),
        'sand' => const Color(0xFFCAA77D),
        'charcoal' => const Color(0xFF505763),
        _ => item.accent,
      };

  @override
  Widget build(BuildContext context) {
    return _SceneThumb(
      title: '${item.title} $colorLabel',
      accent: _colorAccent,
      compact: compact,
    );
  }
}

class _ItemSizeChip extends StatelessWidget {
  const _ItemSizeChip({
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
        width: 42,
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFFF1F5) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? const Color(0xFFFF4F6F) : const Color(0xFFE3E6EC),
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? const Color(0xFFFF4F6F) : const Color(0xFF3A4150),
            fontWeight: FontWeight.w900,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _ProductSpecGrid extends StatelessWidget {
  const _ProductSpecGrid();

  @override
  Widget build(BuildContext context) {
    const specs = [
      ('Weave Pattern', 'Regular'),
      ('Transparency', 'Opaque'),
      ('Fit', 'Regular Fit'),
      ('Sustainable', 'Regular'),
      ('Brand Fit Name', 'Comfort'),
      ('Fabrics', 'Polycotton'),
    ];
    return Wrap(
      spacing: 32,
      runSpacing: 18,
      children: specs
          .map(
            (spec) => SizedBox(
              width: 130,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    spec.$1,
                    style: const TextStyle(
                      color: Color(0xFF2B3140),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    spec.$2,
                    style: const TextStyle(
                      color: Color(0xFF515866),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

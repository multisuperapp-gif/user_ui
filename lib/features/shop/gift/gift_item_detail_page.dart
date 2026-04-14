part of '../../../main.dart';

class _GiftItemDetailPage extends StatefulWidget {
  const _GiftItemDetailPage({
    required this.item,
    required this.onAddToCart,
    required this.onOpenCart,
    required this.onGiftNow,
    required this.onWishlistTap,
    required this.onShareTap,
    this.returnToShopOnBackAfterAdd = false,
  });

  final _DiscoveryItem item;
  final Future<bool> Function() onAddToCart;
  final VoidCallback onOpenCart;
  final Future<bool> Function() onGiftNow;
  final VoidCallback onWishlistTap;
  final VoidCallback onShareTap;
  final bool returnToShopOnBackAfterAdd;

  @override
  State<_GiftItemDetailPage> createState() => _GiftItemDetailPageState();
}

class _GiftItemDetailPageState extends State<_GiftItemDetailPage> {
  final PageController _pageController = PageController();
  int _imageIndex = 0;
  bool _addedToCart = false;
  int _selectedOption = 0;
  bool get _isOutOfStock => _isShopItemOutOfStock(widget.item);
  _ShopTimingState get _shopTiming => _shopTimingFor(widget.item.subtitle, 'Gift');

  List<_GiftOptionData> get _options {
    final price = _extractAmount(widget.item.price);
    return [
      _GiftOptionData(
        label: 'Option 1',
        price: '₹${price.toStringAsFixed(0)}',
      ),
      _GiftOptionData(
        label: 'Option 2',
        price: '₹${(price + 200).toStringAsFixed(0)}',
      ),
    ];
  }

  Future<void> _handleAddToCart() async {
    if (_addedToCart) {
      widget.onOpenCart();
      return;
    }
    final added = await widget.onAddToCart();
    if (!mounted) {
      return;
    }
    if (added) {
      setState(() => _addedToCart = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.item.title} added to cart.')),
      );
    }
  }

  Future<void> _handleGiftNow() async {
    final added = await widget.onGiftNow();
    if (!mounted) {
      return;
    }
    if (added) {
      Navigator.of(context).pop(true);
    }
  }

  Future<bool> _handleBack() async {
    Navigator.of(context).pop(_addedToCart && widget.returnToShopOnBackAfterAdd);
    return false;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final option = _options[_selectedOption];
    final currentPrice = option.price;
    final original = _extractAmount(currentPrice) + 250;
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: _handleBack,
      child: Scaffold(
        backgroundColor: Colors.white,
        bottomNavigationBar: SafeArea(
          minimum: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _addedToCart
                      ? _handleAddToCart
                      : !_isOutOfStock && _shopTiming.acceptsOrders
                          ? _handleAddToCart
                          : null,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF8A8B2E),
                    side: const BorderSide(color: Color(0xFFB5B36A), width: 1.3),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.shopping_cart_checkout_rounded),
                  label: Text(
                    _addedToCart
                        ? 'Go To Cart'
                        : _isOutOfStock
                            ? 'Out of stock'
                        : _shopTiming.acceptsOrders
                            ? 'Add To Cart'
                            : 'Orders closed',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: (!_isOutOfStock && _shopTiming.acceptsOrders) ? _handleGiftNow : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF8A8B2E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.redeem_rounded),
                  label: const Text(
                    'Gift Now',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ),
        body: SafeArea(
          bottom: false,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => _handleBack(),
                        icon: const Icon(Icons.arrow_back_rounded),
                        color: const Color(0xFF1F2430),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: widget.onOpenCart,
                        icon: const Icon(Icons.shopping_cart_outlined),
                        color: const Color(0xFF1F2430),
                      ),
                      IconButton(
                        onPressed: widget.onWishlistTap,
                        icon: const Icon(Icons.favorite_border_rounded),
                        color: const Color(0xFF1F2430),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: AspectRatio(
                  aspectRatio: 1.12,
                  child: Stack(
                    children: [
                      PageView.builder(
                        controller: _pageController,
                        itemCount: 5,
                        onPageChanged: (value) => setState(() => _imageIndex = value),
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(0, 2, 0, 0),
                            child: _GiftHeroImage(
                              item: widget.item,
                              assetKey: '${_assetSlug(widget.item.title)}_${index + 1}',
                            ),
                          );
                        },
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 16,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            5,
                            (index) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: index == _imageIndex ? 8 : 7,
                              height: index == _imageIndex ? 8 : 7,
                              decoration: BoxDecoration(
                                color: index == _imageIndex ? const Color(0xFF969638) : const Color(0xFFE9E8DF),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              widget.item.title,
                              style: const TextStyle(
                                color: Color(0xFF222732),
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          InkWell(
                            onTap: widget.onShareTap,
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: const Color(0xFFE8E5DB)),
                              ),
                              child: const Icon(Icons.share_outlined, size: 20),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          ...List.generate(
                            5,
                            (_) => const Padding(
                              padding: EdgeInsets.only(right: 2),
                              child: Icon(
                                Icons.star_rounded,
                                color: Color(0xFF16A34A),
                                size: 18,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            '5',
                            style: TextStyle(
                              color: Color(0xFF1F2937),
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            '12 Reviews',
                            style: TextStyle(
                              color: Color(0xFF4C78B2),
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F8EC),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Text(
                              'Free Delivery',
                              style: TextStyle(
                                color: Color(0xFF319758),
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            currentPrice,
                            style: const TextStyle(
                              color: Color(0xFF202435),
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '₹${original.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: Color(0xFF9A9BA3),
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            '23% OFF',
                            style: TextStyle(
                              color: Color(0xFF2AA56A),
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF4E7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.local_fire_department_rounded, color: Color(0xFFFF8A00), size: 18),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Ordered 4681+ times in past month',
                                style: TextStyle(
                                  color: Color(0xFF6F6139),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                      const Text(
                        "Gift Receiver's Location",
                        style: TextStyle(
                          color: Color(0xFF222732),
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFBFBF8),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE9E7DC)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.location_on_outlined, color: Color(0xFFE9A325), size: 20),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'X7MF+53X - Nawada, Bihar 84150',
                                style: TextStyle(
                                  color: Color(0xFF353944),
                                  fontSize: 13.4,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Available Options',
                        style: TextStyle(
                          color: Color(0xFF222732),
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 136,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _options.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            final data = _options[index];
                            return _GiftOptionCard(
                              item: widget.item,
                              option: data,
                              selected: _selectedOption == index,
                              onTap: () => setState(() => _selectedOption = index),
                            );
                          },
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
    );
  }
}

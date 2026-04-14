part of '../../../main.dart';

class _GroceryItemDetailPage extends StatefulWidget {
  const _GroceryItemDetailPage({
    required this.item,
    required this.onAddToCart,
    required this.onOpenCart,
    required this.onWishlistTap,
    required this.onShareTap,
    this.returnToShopOnBackAfterAdd = false,
  });

  final _DiscoveryItem item;
  final Future<bool> Function() onAddToCart;
  final VoidCallback onOpenCart;
  final VoidCallback onWishlistTap;
  final VoidCallback onShareTap;
  final bool returnToShopOnBackAfterAdd;

  @override
  State<_GroceryItemDetailPage> createState() => _GroceryItemDetailPageState();
}

class _GroceryItemDetailPageState extends State<_GroceryItemDetailPage> {
  int _quantity = 1;
  bool _addedInSession = false;
  String _pack = '1 Unit';

  static const List<String> _packs = ['1 Unit', '2 Units', 'Family Pack'];

  int get _basePrice {
    final amount = _extractAmount(widget.item.price);
    return amount <= 0 ? 39 : amount;
  }

  int get _mrp {
    final calculated = (_basePrice * 1.35).round();
    return calculated <= _basePrice ? _basePrice + 20 : calculated;
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

  int get _packDelta => switch (_pack) {
        '2 Units' => _basePrice,
        'Family Pack' => _basePrice * 2,
        _ => 0,
      };

  int get _finalPrice => (_basePrice + _packDelta) * _quantity;
  _ShopTimingState get _shopTiming => _shopTimingFor(widget.item.subtitle, 'Groceries');
  bool get _isOutOfStock => _isShopItemOutOfStock(widget.item);

  Future<void> _addToCart() async {
    if (_addedInSession) {
      widget.onOpenCart();
      return;
    }
    final added = await widget.onAddToCart();
    if (added) {
      setState(() => _addedInSession = true);
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

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return PopScope<bool>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }
        _closeWithResult();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F6F1),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF8F6F1),
          elevation: 0,
          automaticallyImplyLeading: false,
          titleSpacing: 0,
          title: Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 12, 6),
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
                            'Search in ${item.subtitle}',
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
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(14, 6, 14, 120),
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(26),
              child: SizedBox(
                height: 280,
                child: _TemporaryCatalogImage(
                  item: item,
                  fallback: _SceneThumb(
                    title: item.title,
                    accent: item.accent,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.subtitle,
                        style: const TextStyle(
                          color: Color(0xFF687285),
                          fontWeight: FontWeight.w800,
                          fontSize: 12.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.title,
                        style: const TextStyle(
                          color: Color(0xFF202A3E),
                          fontSize: 21,
                          fontWeight: FontWeight.w900,
                          height: 1.06,
                        ),
                      ),
                    ],
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
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  'MRP ₹$_mrp',
                  style: const TextStyle(
                    color: Color(0xFF8C919C),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '₹$_finalPrice',
                  style: const TextStyle(
                    color: Color(0xFF1F2635),
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$_discountPercent% OFF',
                  style: const TextStyle(
                    color: Color(0xFF26A05A),
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE6E9EE)),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Top grocery deal\nSave more with family packs and nearby shop offers.',
                      style: TextStyle(
                        color: Color(0xFF4B5567),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E8E45),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Extra Save',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Pack size',
              style: TextStyle(
                color: Color(0xFF202A3E),
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _packs
                  .map(
                    (pack) => _GroceryPackChip(
                      label: pack,
                      selected: _pack == pack,
                      onTap: () => setState(() => _pack = pack),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE8E9EE)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Delivery & storage',
                    style: TextStyle(
                      color: Color(0xFF202A3E),
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Fast doorstep delivery from nearby shop. Store in a cool dry place and keep sealed for best freshness.',
                    style: TextStyle(
                      color: Color(0xFF697284),
                      fontSize: 12.4,
                      fontWeight: FontWeight.w700,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE8E9EE)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'About this item',
                    style: TextStyle(
                      color: Color(0xFF202A3E),
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${item.title} from ${item.subtitle}. Handy daily-use grocery pick with reliable quality, quick refill value and regular household demand.',
                    style: const TextStyle(
                      color: Color(0xFF697284),
                      fontSize: 12.4,
                      fontWeight: FontWeight.w700,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
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
                  width: 118,
                  height: 50,
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
                          if (_quantity > 1) {
                            _quantity -= 1;
                          }
                        }),
                        child: const Icon(Icons.remove_rounded, color: Color(0xFF26A05A)),
                      ),
                      Text(
                        '$_quantity',
                        style: const TextStyle(
                          color: Color(0xFF22314D),
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      InkWell(
                        onTap: () => setState(() => _quantity += 1),
                        child: const Icon(Icons.add_rounded, color: Color(0xFF26A05A)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _addedInSession
                        ? _addToCart
                        : !_isOutOfStock && _shopTiming.acceptsOrders
                            ? _addToCart
                            : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF26A05A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(
                      _addedInSession
                          ? 'Go to Cart'
                          : _isOutOfStock
                              ? 'Out of stock'
                          : _shopTiming.acceptsOrders
                              ? 'Add item ₹$_finalPrice'
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
      ),
    );
  }
}

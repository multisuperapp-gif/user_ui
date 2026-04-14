part of '../../../main.dart';

class _FootwearItemDetailPage extends StatefulWidget {
  const _FootwearItemDetailPage({
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
  State<_FootwearItemDetailPage> createState() => _FootwearItemDetailPageState();
}

class _FootwearItemDetailPageState extends State<_FootwearItemDetailPage> {
  int _selectedPreviewIndex = 0;
  int _selectedGalleryIndex = 0;
  String? _selectedSize = '8';
  bool _addedInSession = false;
  late final PageController _galleryController;

  static const List<String> _sizes = ['6', '7', '8', '9', '10'];
  static const List<String> _previewLabels = ['Black', 'Tan', 'White', 'Navy', 'Olive'];
  static const int _galleryImageCount = 4;

  @override
  void initState() {
    super.initState();
    _galleryController = PageController();
  }

  @override
  void dispose() {
    _galleryController.dispose();
    super.dispose();
  }

  int get _basePrice {
    final digits = widget.item.price.replaceAll(RegExp(r'[^0-9]'), '');
    final parsed = int.tryParse(digits) ?? 0;
    return parsed <= 0 ? 1199 : parsed;
  }

  int get _mrp {
    final calculated = (_basePrice * 1.85).round();
    return calculated <= _basePrice ? _basePrice + 500 : calculated;
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
    final rating = double.tryParse(widget.item.rating) ?? 4.2;
    if (rating >= 4.5) return '6.2k';
    if (rating >= 4.0) return '2.4k';
    return '986';
  }

  String get _productTitle => '${widget.item.subtitle} ${widget.item.title}';
  bool get _isOutOfStock => _isShopItemOutOfStock(widget.item);

  String _galleryAssetKey({
    required int colorIndex,
    required int imageIndex,
  }) {
    return '${_assetSlug(widget.item.title)}_${_assetSlug(_previewLabels[colorIndex])}_${imageIndex + 1}';
  }

  void _selectColor(int index) {
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
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          toolbarHeight: 58,
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
          children: [
            Stack(
              children: [
                SizedBox(
                  height: 380,
                  width: double.infinity,
                  child: PageView.builder(
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
                        fallback: _FootwearGalleryFallback(
                          item: item,
                          colorLabel: _previewLabels[_selectedPreviewIndex],
                          imageIndex: index,
                        ),
                      );
                    },
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
                          color: _selectedGalleryIndex == index ? Colors.black : Colors.white,
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
                        'Get at ₹799\nWith Coupon + Bank Offer',
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
                        'Extra ₹300 Off',
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
                  return _FootwearItemPreviewThumb(
                    item: item,
                    colorLabel: _previewLabels[index],
                    selected: _selectedPreviewIndex == index,
                    assetKey: _galleryAssetKey(colorIndex: index, imageIndex: 0),
                    onTap: () => _selectColor(index),
                  );
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(14, 20, 14, 0),
              child: Row(
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
                      (size) => _FootwearItemSizeChip(
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
                      widget.item.title.toLowerCase(),
                      style: const TextStyle(
                        color: Color(0xFF515866),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const _FootwearProductSpecGrid(),
                    const SizedBox(height: 18),
                    const Text(
                      'Product Details',
                      style: TextStyle(
                        color: Color(0xFF2B3140),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Comfort-first footwear with cushioned sole, easy slip-on fit and sturdy everyday finish. Built for casual wear, office movement and long walking comfort.',
                      style: TextStyle(
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
                      'Fit: Regular Fit\nClosure: Easy wear\nRecommended size: ${_selectedSize ?? '8'}',
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
                      'Wipe with dry cloth. Keep away from direct moisture for long hours. Use soft brush for sole cleaning and store in a cool dry place.',
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

class _FootwearItemPreviewThumb extends StatelessWidget {
  const _FootwearItemPreviewThumb({
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
                fallback: _FootwearGalleryFallback(
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

class _FootwearGalleryFallback extends StatelessWidget {
  const _FootwearGalleryFallback({
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
        'black' => const Color(0xFF343742),
        'tan' => const Color(0xFFC18B57),
        'white' => const Color(0xFFD8DCE5),
        'navy' => const Color(0xFF4467AE),
        'olive' => const Color(0xFF6E8B3D),
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

class _FootwearItemSizeChip extends StatelessWidget {
  const _FootwearItemSizeChip({
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

class _FootwearProductSpecGrid extends StatelessWidget {
  const _FootwearProductSpecGrid();

  @override
  Widget build(BuildContext context) {
    const specs = [
      ('Type', 'Casual'),
      ('Pattern', 'Solid'),
      ('Closure', 'Slip-On'),
      ('Sole', 'Cushioned'),
      ('Fit', 'Comfort'),
      ('Material', 'Synthetic'),
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

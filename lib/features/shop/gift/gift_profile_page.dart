part of '../../../main.dart';

class _GiftProfilePage extends StatefulWidget {
  const _GiftProfilePage({
    required this.item,
    required this.initialCategory,
    required this.isWishlisted,
    required this.onWishlistToggle,
    required this.onAddToCart,
    required this.onOpenCart,
    required this.autoAddItem,
  });

  final _DiscoveryItem item;
  final String initialCategory;
  final bool Function(_DiscoveryItem item) isWishlisted;
  final ValueChanged<_DiscoveryItem> onWishlistToggle;
  final Future<bool> Function(_DiscoveryItem item) onAddToCart;
  final VoidCallback onOpenCart;
  final bool autoAddItem;

  @override
  State<_GiftProfilePage> createState() => _GiftProfilePageState();
}

class _GiftProfilePageState extends State<_GiftProfilePage>
    with _ScrollToTopVisibilityMixin<_GiftProfilePage> {
  final ScrollController _scrollController = ScrollController();
  bool _didAutoAdd = false;
  bool _loadQueued = false;
  String _sortOption = 'Popular';
  int _visibleRows = 20;

  String get _occasion =>
      _giftOccasionOptions.contains(widget.initialCategory) ? widget.initialCategory : 'Birthday';

  String get _shopName {
    final subtitle = widget.item.subtitle.trim();
    if (_giftKnownShopNames.contains(subtitle)) {
      return subtitle;
    }
    return widget.item.title.trim().isEmpty ? 'Luxe' : widget.item.title.trim();
  }

  List<_DiscoveryItem> get _allItems {
    final scoped = _giftProductsForOccasion(_occasion, shopName: _shopName);
    final source = scoped.isEmpty ? _giftProductsForOccasion(_occasion) : scoped;
    return _sortedGiftItems(source, _sortOption);
  }

  List<_DiscoveryItem> get _visibleItems {
    final count = (_visibleRows * 2).clamp(0, _allItems.length);
    return _allItems.take(count).toList();
  }

  @override
  ScrollController get scrollToTopController => _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    initScrollToTopVisibility();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.autoAddItem && !_didAutoAdd) {
      _didAutoAdd = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await widget.onAddToCart(widget.item);
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${widget.item.title} added from ${widget.item.subtitle}.')),
        );
      });
    }
  }

  @override
  void dispose() {
    disposeScrollToTopVisibility();
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  void _handleScroll() {
    final shouldLoadMore =
        _visibleItems.length < _allItems.length && !_loadQueued && _scrollController.position.extentAfter < 700;
    if (!shouldLoadMore) {
      return;
    }
    _loadQueued = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _visibleRows = (_visibleRows + 20).clamp(0, (_allItems.length / 2).ceil());
        _loadQueued = false;
      });
    });
  }

  Future<void> _openSortSheet() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
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
                  'Sort gifts',
                  style: TextStyle(
                    color: Color(0xFF202435),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 14),
                for (final option in _giftSortOptions)
                  _ShopSortOptionTile(
                    label: option,
                    selected: option == _sortOption,
                    onTap: () => Navigator.of(context).pop(option),
                  ),
              ],
            ),
          ),
        );
      },
    );
    if (selected != null && mounted) {
      setState(() => _sortOption = selected);
    }
  }

  Future<void> _openFilterPage() async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => const _ShopGiftFilterPage(initialCategory: 'Flowers'),
      ),
    );
  }

  Future<void> _openItemPage(_DiscoveryItem item) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => _GiftItemDetailPage(
          item: item,
          onAddToCart: () => widget.onAddToCart(item),
          onOpenCart: widget.onOpenCart,
          onGiftNow: () => widget.onAddToCart(item),
          onWishlistTap: () => widget.onWishlistToggle(item),
          onShareTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Share link for ${item.title} will be connected next.')),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _visibleItems;
    final shopName = _shopName;
    final shopTiming = _shopTimingFor(shopName, 'Gift');
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back_rounded),
                        color: const Color(0xFF1F2430),
                      ),
                      Expanded(
                        child: Text(
                          '$shopName - $_occasion Gifts · ${_allItems.length} items',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF222732),
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.search_rounded),
                        color: const Color(0xFF1F2430),
                      ),
                      IconButton(
                        onPressed: widget.onOpenCart,
                        icon: const Icon(Icons.shopping_cart_outlined),
                        color: const Color(0xFF1F2430),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (shopTiming.shouldHighlight) ...[
                        _ShopTimingPill(state: shopTiming),
                        const SizedBox(height: 10),
                      ],
                      Row(
                        children: [
                          _GiftPillButton(
                            icon: Icons.filter_alt_outlined,
                            label: 'Filters',
                            onTap: _openFilterPage,
                          ),
                          const SizedBox(width: 10),
                          _GiftPillButton(
                            icon: Icons.swap_vert_rounded,
                            label: 'Sort By',
                            onTap: _openSortSheet,
                          ),
                          const SizedBox(width: 10),
                          _GiftPillButton(
                            icon: Icons.currency_rupee_rounded,
                            label: 'Price',
                            onTap: _openSortSheet,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(14, 8, 14, 110),
                    itemCount: items.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 22,
                      childAspectRatio: 0.74,
                    ),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return _GiftGridProductCard(
                        item: item,
                        onTap: () => _openItemPage(item),
                      );
                    },
                  ),
                ),
              ],
            ),
            buildScrollToTopOverlay(bottom: 28),
          ],
        ),
      ),
    );
  }
}

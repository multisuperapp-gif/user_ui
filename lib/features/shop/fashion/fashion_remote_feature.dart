part of '../../../main.dart';

class _RemoteFashionShowcase extends StatelessWidget {
  const _RemoteFashionShowcase({
    required this.items,
    required this.hasMore,
    required this.onItemTap,
    required this.isWishlisted,
    required this.onWishlistToggle,
  });

  final List<_FashionRemoteProduct> items;
  final bool hasMore;
  final ValueChanged<_DiscoveryItem> onItemTap;
  final bool Function(_DiscoveryItem item) isWishlisted;
  final ValueChanged<_DiscoveryItem> onWishlistToggle;

  @override
  Widget build(BuildContext context) {
    return _FashionInfiniteFeedSection(
      items: items
          .map(
            (item) => _FashionFeedCardData(
              item: item.item,
              oldPrice: item.oldPrice,
              couponPrice: item.couponPrice,
              discount: item.discount,
              votes: item.votes,
              promoted: item.promoted,
            ),
          )
          .toList(growable: false),
      hasMore: hasMore,
      onTap: onItemTap,
      isWishlisted: isWishlisted,
      onWishlistToggle: onWishlistToggle,
    );
  }
}

class _RemoteFashionShopPage extends StatefulWidget {
  const _RemoteFashionShopPage({
    required this.shopId,
    required this.fallbackTitle,
    required this.onOpenCart,
    required this.onCartUpdated,
    required this.isWishlisted,
    required this.onWishlistToggle,
  });

  final int shopId;
  final String fallbackTitle;
  final Future<void> Function() onOpenCart;
  final ValueChanged<_RemoteCartState> onCartUpdated;
  final bool Function(_DiscoveryItem item) isWishlisted;
  final ValueChanged<_DiscoveryItem> onWishlistToggle;

  @override
  State<_RemoteFashionShopPage> createState() => _RemoteFashionShopPageState();
}

class _RemoteFashionShopPageState extends State<_RemoteFashionShopPage> {
  _FashionShopProfileData? _profile;
  String _selectedCategory = 'All';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    unawaited(_loadProfile());
  }

  Future<void> _loadProfile({int? categoryId}) async {
    setState(() {
      _loading = true;
    });
    try {
      final profile = await _UserAppApi.fetchFashionShopProfile(
        widget.shopId,
        categoryId: categoryId,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _profile = profile;
        _loading = false;
      });
    } on _UserAppApiException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not load fashion shop right now.')),
      );
    }
  }

  Future<void> _selectCategory(String value) async {
    setState(() {
      _selectedCategory = value;
    });
    int? categoryId;
    for (final item in _profile?.categories ?? const <_FashionRemoteCategory>[]) {
      if (item.label == value) {
        categoryId = item.backendCategoryId;
        break;
      }
    }
    await _loadProfile(categoryId: categoryId);
  }

  Future<void> _openItem(_DiscoveryItem item) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => _ShopItemDetailPage(
          item: item,
          supportsColorVariants: true,
          useFoodPopupStyle: false,
          returnToShopOnBackAfterAdd: false,
          onAddToCart: () async {
            final cart = await _UserAppApi.addItemToCart(item);
            widget.onCartUpdated(cart);
            return true;
          },
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
  }

  @override
  Widget build(BuildContext context) {
    final profile = _profile;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F2EC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        titleSpacing: 0,
        title: Text(
          profile?.shopName ?? widget.fallbackTitle,
          style: const TextStyle(
            color: Color(0xFF22314D),
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            onPressed: widget.onOpenCart,
            icon: const Icon(Icons.shopping_cart_outlined, color: Color(0xFF22314D)),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFCB6E5B)))
          : profile == null
              ? const Center(
                  child: Text(
                    'Fashion shop is not available right now.',
                    style: TextStyle(
                      color: Color(0xFF6D7A91),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 28),
                  children: [
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile.shopName,
                            style: const TextStyle(
                              color: Color(0xFF22314D),
                              fontWeight: FontWeight.w900,
                              fontSize: 28,
                              height: 1,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(Icons.place_outlined, size: 17, color: Color(0xFF5C677D)),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  profile.city.isEmpty ? 'Fashion shop' : profile.city,
                                  style: const TextStyle(
                                    color: Color(0xFF5C677D),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _ratingColor(profile.rating),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.star_rounded, size: 14, color: Colors.white),
                                    const SizedBox(width: 4),
                                    Text(
                                      profile.rating,
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
                          const SizedBox(height: 8),
                          Text(
                            profile.acceptsOrders
                                ? (profile.openNow
                                    ? 'Open now${profile.closesAt.isEmpty ? '' : ' · Closes at ${profile.closesAt}'}'
                                    : 'Currently closed')
                                : 'Orders are stopped for today',
                            style: TextStyle(
                              color: profile.acceptsOrders ? const Color(0xFF2F8F46) : const Color(0xFFD15555),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
                      child: _ShopSubcategoryFilter(
                        category: 'Fashion',
                        options: profile.categories.map((item) => item.label).toList(growable: false),
                        selected: _selectedCategory,
                        onSelected: (value) => unawaited(_selectCategory(value)),
                      ),
                    ),
                    _RemoteFashionShowcase(
                      items: profile.products.items,
                      hasMore: profile.products.hasMore,
                      onItemTap: _openItem,
                      isWishlisted: widget.isWishlisted,
                      onWishlistToggle: widget.onWishlistToggle,
                    ),
                  ],
                ),
    );
  }
}

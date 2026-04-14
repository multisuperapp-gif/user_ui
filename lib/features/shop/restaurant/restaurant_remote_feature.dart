part of '../../../main.dart';

class _RemoteRestaurantShopPage extends StatefulWidget {
  const _RemoteRestaurantShopPage({
    required this.shopId,
    required this.fallbackTitle,
    required this.onOpenCart,
    required this.onCartUpdated,
    required this.onWishlistToggle,
  });

  final int shopId;
  final String fallbackTitle;
  final Future<void> Function() onOpenCart;
  final ValueChanged<_RemoteCartState> onCartUpdated;
  final ValueChanged<_DiscoveryItem> onWishlistToggle;

  @override
  State<_RemoteRestaurantShopPage> createState() => _RemoteRestaurantShopPageState();
}

class _RemoteRestaurantShopPageState extends State<_RemoteRestaurantShopPage> {
  _RestaurantShopProfileData? _profile;
  String _selectedCuisine = 'All';
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
      final profile = await _UserAppApi.fetchRestaurantShopProfile(
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
        const SnackBar(content: Text('Could not load restaurant profile right now.')),
      );
    }
  }

  Future<void> _selectCuisine(String value) async {
    setState(() {
      _selectedCuisine = value;
    });
    int? categoryId;
    final cuisines = _profile?.cuisines ?? const <_RestaurantCuisineItem>[];
    for (final item in cuisines) {
      if (item.label == value) {
        categoryId = item.backendCategoryId;
        break;
      }
    }
    await _loadProfile(categoryId: categoryId);
  }

  Future<void> _openFoodPopup(_DiscoveryItem item) async {
    await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.52),
      builder: (_) => _ShopItemDetailPage(
        item: item,
        supportsColorVariants: false,
        useFoodPopupStyle: true,
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
                    'Restaurant profile is not available right now.',
                    style: TextStyle(
                      color: Color(0xFF6D7A91),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
                  children: [
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
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
                                  profile.city.isEmpty ? 'Restaurant city' : profile.city,
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
                    _RestaurantCuisineStrip(
                      items: profile.cuisines,
                      selected: _selectedCuisine,
                      onSelected: _selectCuisine,
                    ),
                    const _RestaurantFilterRow(),
                    _RestaurantRecommendedSection(
                      items: profile.products
                          .take(6)
                          .map(
                            (item) => _RestaurantListingItem(
                              item: item,
                              offer: item.price.isEmpty ? 'Recommended' : 'Items at ${item.price}',
                              eta: '',
                              location: profile.city,
                              cuisineLine: item.extra.isEmpty ? profile.shopName : item.extra,
                            ),
                          )
                          .toList(),
                      onTap: (listing) => _openFoodPopup(listing.item),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 6, 18, 0),
                      child: Column(
                        children: profile.products
                            .map(
                              (item) => _RemoteRestaurantMenuTile(
                                item: item,
                                onTap: () => _openFoodPopup(item),
                                onAdd: () => _openFoodPopup(item),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ],
                ),
    );
  }
}

class _RemoteRestaurantMenuTile extends StatelessWidget {
  const _RemoteRestaurantMenuTile({
    required this.item,
    required this.onTap,
    required this.onAdd,
  });

  final _DiscoveryItem item;
  final VoidCallback onTap;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        color: Color(0xFF202A3E),
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _ratingColor(item.rating),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star_rounded, size: 12, color: Colors.white),
                              const SizedBox(width: 4),
                              Text(
                                item.rating,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (item.extra.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item.extra,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF7A7F89),
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.price,
                      style: const TextStyle(
                        color: Color(0xFF202A3E),
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 116,
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: SizedBox(
                        height: 98,
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
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: onAdd,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF2F8F46),
                          side: const BorderSide(color: Color(0xFF93C8A1)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'ADD',
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

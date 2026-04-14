part of '../../../main.dart';

class _RemoteGiftShowcase extends StatelessWidget {
  const _RemoteGiftShowcase({
    required this.items,
    required this.onItemTap,
  });

  final List<_GiftRemoteProduct> items;
  final ValueChanged<_DiscoveryItem> onItemTap;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 18,
            childAspectRatio: 0.78,
          ),
          itemBuilder: (context, index) {
            final item = items[index].item;
            return _GiftGridProductCard(
              item: item,
              onTap: () => onItemTap(item),
            );
          },
        ),
      ),
    );
  }
}

class _RemoteGiftShopPage extends StatefulWidget {
  const _RemoteGiftShopPage({
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
  State<_RemoteGiftShopPage> createState() => _RemoteGiftShopPageState();
}

class _RemoteGiftShopPageState extends State<_RemoteGiftShopPage> {
  _GiftShopProfileData? _profile;
  String _selectedCategory = 'All';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    unawaited(_loadProfile());
  }

  Future<void> _loadProfile({int? categoryId}) async {
    setState(() => _loading = true);
    try {
      final profile = await _UserAppApi.fetchGiftShopProfile(widget.shopId, categoryId: categoryId);
      if (!mounted) return;
      setState(() {
        _profile = profile;
        _loading = false;
      });
    } on _UserAppApiException catch (error) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not load gift store right now.')),
      );
    }
  }

  Future<void> _selectCategory(String value) async {
    setState(() => _selectedCategory = value);
    int? categoryId;
    for (final item in _profile?.categories ?? const <_GiftRemoteCategory>[]) {
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
        builder: (_) => _GiftItemDetailPage(
          item: item,
          onAddToCart: () async {
            final cart = await _UserAppApi.addItemToCart(item);
            widget.onCartUpdated(cart);
            return true;
          },
          onOpenCart: widget.onOpenCart,
          onGiftNow: () async {
            final cart = await _UserAppApi.addItemToCart(item);
            widget.onCartUpdated(cart);
            return true;
          },
          onWishlistTap: () => widget.onWishlistToggle(item),
          onShareTap: () {},
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = _profile;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        title: Text(
          profile?.shopName ?? widget.fallbackTitle,
          style: const TextStyle(
            color: Color(0xFF1F2430),
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          IconButton(
            onPressed: widget.onOpenCart,
            icon: const Icon(Icons.shopping_cart_outlined, color: Color(0xFF1F2430)),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF8A8B2E)))
          : profile == null
              ? const Center(child: Text('Gift store is not available right now.'))
              : ListView(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 6, 18, 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${profile.shopName} · ${profile.products.items.length} items',
                              style: const TextStyle(
                                color: Color(0xFF222732),
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: _ratingColor(profile.rating),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              profile.rating,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
                      child: _ShopSubcategoryFilter(
                        category: 'Gift',
                        options: profile.categories.map((item) => item.label).toList(growable: false),
                        selected: _selectedCategory,
                        onSelected: (value) => unawaited(_selectCategory(value)),
                      ),
                    ),
                    _RemoteGiftShowcase(
                      items: profile.products.items,
                      onItemTap: _openItem,
                    ),
                  ],
                ),
    );
  }
}

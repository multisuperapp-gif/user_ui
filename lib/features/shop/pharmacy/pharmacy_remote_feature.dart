part of '../../../main.dart';

class _RemotePharmacyShowcase extends StatelessWidget {
  const _RemotePharmacyShowcase({
    required this.items,
    required this.selectedCategory,
    required this.onItemTap,
    required this.onAddToCart,
    required this.isWishlisted,
    required this.onWishlistToggle,
  });

  final List<_PharmacyRemoteProduct> items;
  final String selectedCategory;
  final ValueChanged<_DiscoveryItem> onItemTap;
  final ValueChanged<_DiscoveryItem> onAddToCart;
  final bool Function(_DiscoveryItem item) isWishlisted;
  final ValueChanged<_DiscoveryItem> onWishlistToggle;

  List<_PharmacyCampaignSectionData> get _sections {
    final groups = <String, List<_DiscoveryItem>>{};
    for (final product in items) {
      groups.putIfAbsent(product.categoryLabel, () => <_DiscoveryItem>[]).add(product.item);
    }
    final labels = selectedCategory == 'All' ? groups.keys : <String>[selectedCategory];
    return labels
        .where(groups.containsKey)
        .map(
          (label) => _PharmacyCampaignSectionData(
            category: label,
            title: _pharmacyCampaignTitle(label),
            colors: _pharmacyCampaignColors(label),
            items: groups[label] ?? const <_DiscoveryItem>[],
          ),
        )
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < _sections.length; i++) ...[
            if (i == 0) const SizedBox(height: 10) else const SizedBox(height: 18),
            _PharmacyCampaignSection(
              data: _sections[i],
              onItemTap: onItemTap,
              onShopTap: (_) {},
              onAddToCart: onAddToCart,
              isWishlisted: isWishlisted,
              onWishlistToggle: onWishlistToggle,
            ),
          ],
          const SizedBox(height: 18),
        ],
      ),
    );
  }
}

class _RemotePharmacyShopPage extends StatefulWidget {
  const _RemotePharmacyShopPage({
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
  State<_RemotePharmacyShopPage> createState() => _RemotePharmacyShopPageState();
}

class _RemotePharmacyShopPageState extends State<_RemotePharmacyShopPage> {
  _PharmacyShopProfileData? _profile;
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
      final profile = await _UserAppApi.fetchPharmacyShopProfile(widget.shopId, categoryId: categoryId);
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
        const SnackBar(content: Text('Could not load pharmacy store right now.')),
      );
    }
  }

  Future<void> _selectCategory(String value) async {
    setState(() => _selectedCategory = value);
    int? categoryId;
    for (final item in _profile?.categories ?? const <_PharmacyRemoteCategory>[]) {
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
        builder: (_) => _PharmacyItemDetailPage(
          item: item,
          onAddToCart: () async {
            final cart = await _UserAppApi.addItemToCart(item);
            widget.onCartUpdated(cart);
            return true;
          },
          onOpenCart: widget.onOpenCart,
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
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF268B9C)))
          : profile == null
              ? const Center(child: Text('Pharmacy store is not available right now.'))
              : ListView(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 6, 18, 10),
                      child: _ShopSubcategoryFilter(
                        category: 'Pharmacy',
                        options: profile.categories.map((item) => item.label).toList(growable: false),
                        selected: _selectedCategory,
                        onSelected: (value) => unawaited(_selectCategory(value)),
                      ),
                    ),
                    _RemotePharmacyShowcase(
                      items: profile.products.items,
                      selectedCategory: _selectedCategory,
                      onItemTap: _openItem,
                      onAddToCart: (_) {},
                      isWishlisted: widget.isWishlisted,
                      onWishlistToggle: widget.onWishlistToggle,
                    ),
                  ],
                ),
    );
  }
}

part of '../../../main.dart';

class _PharmacyProfilePage extends StatefulWidget {
  const _PharmacyProfilePage({
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
  State<_PharmacyProfilePage> createState() => _PharmacyProfilePageState();
}

class _PharmacyProfilePageState extends State<_PharmacyProfilePage>
    with _ScrollToTopVisibilityMixin<_PharmacyProfilePage> {
  late String _selectedCategory;
  String _sortOption = 'Popular';
  bool _didAutoAdd = false;
  final ScrollController _scrollController = ScrollController();
  late final List<_PharmacyMenuSectionData> _sections;
  late final Map<String, GlobalKey> _sectionKeys;
  late final Map<_DiscoveryItem, GlobalKey> _itemKeys;

  @override
  ScrollController get scrollToTopController => _scrollController;

  @override
  void initState() {
    super.initState();
    initScrollToTopVisibility();
    _selectedCategory = _pharmacyCategoryOptions.contains(widget.initialCategory)
        ? widget.initialCategory
        : 'Wellness';
    _sections = _buildSectionsForShop(widget.item.subtitle);
    _sectionKeys = {for (final section in _sections) section.title: GlobalKey()};
    _itemKeys = {for (final item in _sections.expand((section) => section.items)) item: GlobalKey()};
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.autoAddItem && !_didAutoAdd) {
      _didAutoAdd = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await widget.onAddToCart(widget.item);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${widget.item.title} added from ${widget.item.subtitle}.')),
        );
      });
    }
  }

  List<_PharmacyMenuSectionData> get _visibleSections {
    final filtered = _selectedCategory == 'All'
        ? _sections
        : _sections.where((section) => section.title == _selectedCategory).toList();
    return filtered
        .map((section) => _PharmacyMenuSectionData(
              title: section.title,
              items: _sortedPharmacyItems(section.items, _sortOption),
            ))
        .toList();
  }

  List<_DiscoveryItem> get _recommendedItems =>
      _visibleSections.expand((section) => section.items.take(2)).take(4).toList();

  List<_PharmacyMenuSectionData> _buildSectionsForShop(String shopName) {
    return [
      for (final category in const ['Wellness', 'Baby care', 'Personal care', 'Essentials'])
        _PharmacyMenuSectionData(
          title: category,
          items: _pharmacyItemsForCategory(category, shopName: shopName),
        ),
    ];
  }

  Future<void> _openSortSheet() async {
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
                  'Sort pharmacy',
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
        builder: (_) => _ShopPharmacyFilterPage(
          initialCategory: _selectedCategory == 'All' ? 'Wellness' : _selectedCategory,
        ),
      ),
    );
  }

  Future<void> _openItemPage(_DiscoveryItem item) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => _PharmacyItemDetailPage(
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
  }

  Future<void> _scrollToKey(GlobalKey key) async {
    final context = key.currentContext;
    if (context == null) return;
    await Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      alignment: 0.08,
    );
  }

  Future<void> _openMenuOverlay() async {
    final entries = _visibleSections;
    final expandedTitles = <String>{for (final entry in entries) entry.title};
    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Pharmacy menu',
      barrierColor: Colors.black.withValues(alpha: 0.45),
      pageBuilder: (context, animation, secondaryAnimation) {
        return StatefulBuilder(
          builder: (context, setMenuState) {
            return SafeArea(
              child: Material(
                type: MaterialType.transparency,
                child: Stack(
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      width: 308,
                      margin: const EdgeInsets.fromLTRB(22, 70, 18, 86),
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.18),
                            blurRadius: 28,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Browse pharmacy menu',
                            style: TextStyle(
                              color: Color(0xFF1F2635),
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Expanded(
                            child: ListView.builder(
                              itemCount: entries.length,
                              itemBuilder: (context, index) {
                                final entry = entries[index];
                                final isExpanded = expandedTitles.contains(entry.title);
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    InkWell(
                                      onTap: () async {
                                        Navigator.of(context).pop();
                                        await Future<void>.delayed(const Duration(milliseconds: 90));
                                        if (!mounted) return;
                                        await _scrollToKey(_sectionKeys[entry.title]!);
                                      },
                                      borderRadius: BorderRadius.circular(14),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Row(
                                                children: [
                                                  Flexible(
                                                    child: Text(
                                                      entry.title,
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                        color: Color(0xFF2B87A3),
                                                        fontSize: 13.4,
                                                        fontWeight: FontWeight.w900,
                                                      ),
                                                    ),
                                                  ),
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
                                                    child: const Padding(
                                                      padding: EdgeInsets.all(2),
                                                      child: Icon(
                                                        Icons.keyboard_arrow_down_rounded,
                                                        size: 16,
                                                        color: Color(0xFF5A6172),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              '${entry.items.length}',
                                              style: const TextStyle(
                                                color: Color(0xFF535A6C),
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
                                        padding: const EdgeInsets.only(left: 8, right: 4, bottom: 8),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            for (final item in entry.items)
                                              InkWell(
                                                onTap: () async {
                                                  Navigator.of(context).pop();
                                                  await Future<void>.delayed(const Duration(milliseconds: 90));
                                                  if (!mounted) return;
                                                  await _scrollToKey(_itemKeys[item]!);
                                                },
                                                borderRadius: BorderRadius.circular(12),
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                                                  child: Text(
                                                    item.title,
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      color: Color(0xFF666D7B),
                                                      fontSize: 12.4,
                                                      fontWeight: FontWeight.w600,
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
                      ),
                    ),
                  ),
                  Positioned(
                    right: 18,
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
            );
          },
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
  Widget build(BuildContext context) {
    final shopName = widget.item.subtitle;
    final shopTiming = _shopTimingFor(shopName, 'Pharmacy');
    final visibleSections = _visibleSections;
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
              if (shopTiming.shouldHighlight) ...[
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: _ShopTimingPill(state: shopTiming),
                ),
              ],
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
              const SizedBox(height: 18),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _ShopMenuFilterChip(
                      label: 'Filter',
                      icon: Icons.tune_rounded,
                      onTap: _openFilterPage,
                    ),
                    const SizedBox(width: 10),
                    _ShopMenuFilterChip(
                      label: _sortOption,
                      icon: Icons.swap_vert_rounded,
                      onTap: _openSortSheet,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _PharmacyProfilePromoStrip(
                items: _recommendedItems,
                onTap: _openItemPage,
              ),
              const SizedBox(height: 18),
              for (final section in visibleSections) ...[
                _PharmacyProfileSectionHeader(
                  key: _sectionKeys[section.title],
                  title: section.title,
                  subtitle: _pharmacyCampaignTitle(section.title),
                ),
                const SizedBox(height: 10),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: section.items.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.66,
                  ),
                  itemBuilder: (context, index) {
                    final item = section.items[index];
                    return _PharmacyProfileItemCard(
                      key: _itemKeys[item],
                      item: item,
                      isWishlisted: widget.isWishlisted(item),
                      onTap: () => _openItemPage(item),
                      onWishlistToggle: () => widget.onWishlistToggle(item),
                      onAddTap: () => widget.onAddToCart(item),
                    );
                  },
                ),
                const SizedBox(height: 18),
              ],
              const _MadeWithLoveFooter(),
              const SizedBox(height: 70),
            ],
          ),
          buildScrollToTopOverlay(bottom: 28),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'pharmacy-menu-fab',
        onPressed: _openMenuOverlay,
        backgroundColor: const Color(0xFF2D303B),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.medical_information_rounded),
        label: const Text(
          'Menu',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

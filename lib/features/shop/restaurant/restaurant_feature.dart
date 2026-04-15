part of '../../../main.dart';

class _RestaurantCuisineItem {
  const _RestaurantCuisineItem({
    required this.label,
    required this.imageKey,
    required this.accent,
    required this.icon,
    this.backendCategoryId,
  });

  final String label;
  final String imageKey;
  final Color accent;
  final IconData icon;
  final int? backendCategoryId;
}

class _RestaurantListingItem {
  const _RestaurantListingItem({
    required this.item,
    required this.offer,
    required this.eta,
    required this.location,
    required this.cuisineLine,
  });

  final _DiscoveryItem item;
  final String offer;
  final String eta;
  final String location;
  final String cuisineLine;
}

class _RestaurantCuisineStrip extends StatelessWidget {
  const _RestaurantCuisineStrip({
    required this.items,
    required this.selected,
    required this.onSelected,
  });

  final List<_RestaurantCuisineItem> items;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 4),
      child: SizedBox(
        height: 88,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
          scrollDirection: Axis.horizontal,
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(width: 12),
          itemBuilder: (context, index) => _RestaurantCuisineChip(
            item: items[index],
            selected: items[index].label == selected,
            onTap: () => onSelected(items[index].label),
          ),
        ),
      ),
    );
  }
}

class _RestaurantCuisineChip extends StatelessWidget {
  const _RestaurantCuisineChip({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _RestaurantCuisineItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        width: 68,
        child: Column(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFF1E7D9), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipOval(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        item.accent,
                        item.accent.withValues(alpha: 0.52),
                      ],
                    ),
                  ),
                  child: Icon(
                    item.icon,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF4A4A4A),
                fontSize: 10.2,
                fontWeight: FontWeight.w700,
                height: 1.05,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: selected ? 26 : 0,
              height: selected ? 3 : 0,
              decoration: BoxDecoration(
                color: const Color(0xFFFF9933),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RestaurantFilterRow extends StatelessWidget {
  const _RestaurantFilterRow();

  @override
  Widget build(BuildContext context) {
    const filters = [
      ('Filter', Icons.tune_rounded),
      ('Sort by', Icons.keyboard_arrow_down_rounded),
      ('99 Store', Icons.local_offer_rounded),
      ('Fast delivery', Icons.flash_on_rounded),
    ];
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (var i = 0; i < filters.length; i++) ...[
              _RestaurantFilterChip(
                label: filters[i].$1,
                icon: filters[i].$2,
                accent: i == 2 ? const Color(0xFFF6D97B) : const Color(0xFFF7F7F7),
              ),
              if (i != filters.length - 1) const SizedBox(width: 10),
            ],
          ],
        ),
      ),
    );
  }
}

class _RestaurantFilterChip extends StatelessWidget {
  const _RestaurantFilterChip({
    required this.label,
    required this.icon,
    required this.accent,
  });

  final String label;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final bool isPromo = accent != const Color(0xFFF7F7F7);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEAEAEA)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isPromo)
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Icon(
                Icons.bolt_rounded,
                size: 12,
                color: Color(0xFF523B00),
              ),
            )
          else
            Icon(icon, size: 16, color: const Color(0xFF5A5A5A)),
          const SizedBox(width: 7),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF333333),
              fontSize: 12,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _RestaurantRecommendedSection extends StatelessWidget {
  const _RestaurantRecommendedSection({
    required this.items,
    required this.onTap,
  });

  final List<_RestaurantListingItem> items;
  final ValueChanged<_RestaurantListingItem> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 18),
            child: Text(
              'RECOMMENDED',
              style: TextStyle(
                color: Color(0xFF777C86),
                fontSize: 16,
                fontWeight: FontWeight.w500,
                letterSpacing: 3.2,
                height: 1,
              ),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 284,
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
              scrollDirection: Axis.horizontal,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 14,
                mainAxisExtent: 118,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) => _RestaurantRecommendedTile(
                listing: items[index],
                onTap: () => onTap(items[index]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RestaurantRecommendedTile extends StatelessWidget {
  const _RestaurantRecommendedTile({
    required this.listing,
    required this.onTap,
  });

  final _RestaurantListingItem listing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final item = listing.item;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: SizedBox(
              height: 96,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _TemporaryCatalogImage(
                    item: item,
                    fallback: _SceneThumb(
                      title: item.title,
                      accent: item.accent,
                    ),
                  ),
                  Positioned(
                    left: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.68),
                        borderRadius: const BorderRadius.only(
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                      child: Text(
                        listing.offer,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10.4,
                          fontWeight: FontWeight.w800,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 8,
                    bottom: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                      decoration: BoxDecoration(
                        color: _ratingColor(item.rating),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 11,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            item.rating,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10.8,
                              fontWeight: FontWeight.w800,
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
          ),
          const SizedBox(height: 6),
          Text(
            item.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF212121),
              fontSize: 11.8,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _RestaurantListingCard extends StatelessWidget {
  const _RestaurantListingCard({
    required this.listing,
    required this.isFavourited,
    required this.onFavouriteToggle,
    required this.onTap,
  });

  final _RestaurantListingItem listing;
  final bool isFavourited;
  final VoidCallback onFavouriteToggle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final item = listing.item;
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 10),
      child: InkWell(
        onTap: item.isDisabled ? null : onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: SizedBox(
                  height: 186,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _TemporaryCatalogImage(
                        item: item,
                        fallback: _SceneThumb(
                          title: item.title,
                          accent: item.accent,
                        ),
                      ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: GestureDetector(
                          onTap: onFavouriteToggle,
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.18),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isFavourited ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      if (item.isDisabled && item.disabledLabel.trim().isNotEmpty)
                        Positioned(
                          left: 12,
                          top: 12,
                          child: _AvailabilityBadge(
                            label: item.disabledLabel,
                          ),
                        ),
                      Positioned(
                        left: 10,
                        bottom: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.72),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            listing.offer,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              height: 1,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 10,
                        bottom: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            listing.eta,
                            style: const TextStyle(
                              color: Color(0xFF272727),
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              height: 1,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF1F1F1F),
                        fontSize: 15.5,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                          decoration: BoxDecoration(
                            color: _ratingColor(item.rating),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                size: 12,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                item.rating,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11.3,
                                  fontWeight: FontWeight.w800,
                                  height: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            listing.location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF5A677A),
                              fontSize: 12.2,
                              fontWeight: FontWeight.w700,
                              height: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      listing.cuisineLine,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF767676),
                        fontSize: 12.2,
                        fontWeight: FontWeight.w600,
                        height: 1,
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

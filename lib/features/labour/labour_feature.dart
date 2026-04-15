part of '../../main.dart';

class _AllLabourSection extends StatelessWidget {
  const _AllLabourSection({
    required this.title,
    required this.items,
    required this.isFavourited,
    required this.onFavouriteToggle,
    required this.onTap,
  });

  final String title;
  final List<_DiscoveryItem> items;
  final bool Function(_DiscoveryItem item) isFavourited;
  final ValueChanged<_DiscoveryItem> onFavouriteToggle;
  final ValueChanged<_DiscoveryItem> onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFFBFC),
              Color(0xFFFFEEF3),
              Color(0xFFFFDDE8),
              Color(0xFFFDF8FA),
              Colors.white,
            ],
            stops: [0, 0.18, 0.46, 0.78, 1],
          ),
        ),
        padding: const EdgeInsets.only(top: 2, bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF2D8),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.engineering_rounded,
                          size: 14,
                          color: Color(0xFFF29F38),
                        ),
                        SizedBox(width: 5),
                        Text(
                          'LABOUR PICKS',
                          style: TextStyle(
                            color: Color(0xFF8C5C14),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                            height: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF2B2F39),
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.3,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 84,
                    height: 4,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFF2A13D),
                          Color(0xFFFFD696),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ],
              ),
            ),
            _LabourPortraitSection(
              items: items,
              isFavourited: isFavourited,
              onFavouriteToggle: onFavouriteToggle,
              onTap: onTap,
              topPadding: 6,
              compactScale: 0.6,
              trackColor: const Color(0xFFFFEEF3),
            ),
          ],
        ),
      ),
    );
  }
}

class _LabourPortraitSection extends StatelessWidget {
  const _LabourPortraitSection({
    required this.items,
    required this.isFavourited,
    required this.onFavouriteToggle,
    required this.onTap,
    this.compactScale = 1,
    this.topPadding = 14,
    this.trackColor,
  });

  final List<_DiscoveryItem> items;
  final bool Function(_DiscoveryItem item) isFavourited;
  final ValueChanged<_DiscoveryItem> onFavouriteToggle;
  final ValueChanged<_DiscoveryItem> onTap;
  final double compactScale;
  final double topPadding;
  final Color? trackColor;

  @override
  Widget build(BuildContext context) {
    final sectionHeight = 402 * compactScale;
    final cardWidth = 270 * compactScale;
    final cardGap = 10 * compactScale;
    return Padding(
      padding: EdgeInsets.fromLTRB(18, topPadding, 0, 0),
      child: Container(
        color: trackColor ?? Colors.white,
        child: SizedBox(
          height: sectionHeight,
          child: ListView.separated(
            padding: const EdgeInsets.only(right: 18),
          scrollDirection: Axis.horizontal,
          itemCount: items.length,
          separatorBuilder: (_, _) => SizedBox(width: cardGap),
          itemBuilder: (context, index) {
            final item = items[index];
            return SizedBox(
              width: cardWidth,
              child: _LabourPortraitTile(
                item: item,
                isFavourited: isFavourited(item),
                onFavouriteToggle: () => onFavouriteToggle(item),
                onTap: () => onTap(item),
                compactScale: compactScale,
              ),
            );
            },
          ),
        ),
      ),
    );
  }
}

class _LabourPortraitTile extends StatelessWidget {
  const _LabourPortraitTile({
    required this.item,
    required this.isFavourited,
    required this.onFavouriteToggle,
    required this.onTap,
    this.compactScale = 1,
  });

  final _DiscoveryItem item;
  final bool isFavourited;
  final VoidCallback onFavouriteToggle;
  final VoidCallback onTap;
  final double compactScale;

  @override
  Widget build(BuildContext context) {
    final outerRadius = 20 * compactScale;
    final outerPaddingX = 4 * compactScale;
    final outerPaddingTop = compactScale < 1 ? 2.0 : 4 * compactScale;
    final outerPaddingBottom = 6 * compactScale;
    final titleFont = compactScale < 1 ? 9.6 : 12.8;
    final imageHeight = compactScale < 1 ? 176.0 : 270 * compactScale;
    final imageRadius = compactScale < 1 ? 12.0 : 14.0;
    final imageTextInset = compactScale < 1 ? 7.0 : 10 * compactScale;
    final imageTextFont = compactScale < 1 ? 11.2 : 13.8;
    final metricsGap = compactScale < 1 ? 5.0 : 8 * compactScale;
    final distanceFont = compactScale < 1 ? 9.4 : 10.4;
    return GestureDetector(
      onTap: item.isDisabled ? null : onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(outerRadius),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFDF7DA0).withValues(alpha: 0.18),
              blurRadius: 60 * compactScale,
              spreadRadius: -10 * compactScale,
              offset: Offset(0, 72 * compactScale),
            ),
            BoxShadow(
              color: const Color(0xFFDF7DA0).withValues(alpha: 0.12),
              blurRadius: 24 * compactScale,
              spreadRadius: -6 * compactScale,
              offset: Offset(0, 24 * compactScale),
            ),
            BoxShadow(
              color: const Color(0xFFDF7DA0).withValues(alpha: 0.08),
              blurRadius: 10 * compactScale,
              spreadRadius: -2 * compactScale,
              offset: Offset(0, 8 * compactScale),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            outerPaddingX,
            outerPaddingTop,
            outerPaddingX,
            outerPaddingBottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Transform.translate(
                offset: Offset(0, compactScale < 1 ? -5 : -8),
                child: SizedBox(
                  height: imageHeight,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(imageRadius),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFDF7DA0)
                                    .withValues(alpha: compactScale < 1 ? 0.16 : 0.12),
                                blurRadius: compactScale < 1 ? 14 : 20,
                                spreadRadius: compactScale < 1 ? 0.1 : 0.4,
                                offset: Offset(0, compactScale < 1 ? 8 : 10),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(imageRadius),
                            child: _LabourPortraitImage(item: item),
                          ),
                        ),
                      ),
                      if (item.isDisabled && item.disabledLabel.trim().isNotEmpty)
                        Positioned(
                          left: 8,
                          top: 8,
                          child: _AvailabilityBadge(
                            label: item.disabledLabel,
                            compact: compactScale < 1,
                          ),
                        ),
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(imageRadius),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.08),
                                Colors.black.withValues(alpha: 0.72),
                              ],
                              stops: const [0.45, 0.7, 1],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: imageTextInset,
                        left: imageTextInset,
                        right: imageTextInset,
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: compactScale < 1 ? 5 : 8,
                                vertical: compactScale < 1 ? 2.5 : 4,
                              ),
                              decoration: BoxDecoration(
                                color: _ratingColor(item.rating),
                                borderRadius: BorderRadius.circular(999),
                                boxShadow: [
                                  BoxShadow(
                                    color: _ratingColor(item.rating).withValues(alpha: 0.26),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.star_rounded,
                                    size: compactScale < 1 ? 9 : 12,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    item.rating,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: compactScale < 1 ? 8.8 : 10.6,
                                      fontWeight: FontWeight.w800,
                                      height: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: compactScale < 1 ? 6 : 8,
                                vertical: compactScale < 1 ? 3 : 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                item.distance,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: distanceFont,
                                  fontWeight: FontWeight.w700,
                                  height: 1,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        left: imageTextInset,
                        right: imageTextInset,
                        bottom: imageTextInset,
                        child: Text(
                          item.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            height: 1.02,
                          ).copyWith(fontSize: imageTextFont),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: metricsGap),
              Center(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: compactScale < 1 ? 8 : 12,
                    vertical: compactScale < 1 ? 4 : 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        item.accent.withValues(alpha: 0.16),
                        item.accent.withValues(alpha: 0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    item.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                      height: 1,
                    ).copyWith(fontSize: titleFont),
                  ),
                ),
              ),
              SizedBox(height: metricsGap),
              Row(
                children: [
                  Expanded(
                    child: _labourPriceChip(
                      label: 'Half Day',
                      value: _halfDayRate(item.price),
                      compactScale: compactScale,
                    ),
                  ),
                  SizedBox(width: 8 * compactScale),
                  Expanded(
                    child: _labourPriceChip(
                      label: 'Full Day',
                      value: _fullDayRate(item.price),
                      compactScale: compactScale,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _labourPriceChip({
    required String label,
    required String value,
    required double compactScale,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compactScale < 1 ? 6 : 8,
        vertical: compactScale < 1 ? 5 : 6,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFFF5E8),
            item.accent.withValues(alpha: 0.12),
          ],
        ),
        borderRadius: BorderRadius.circular(10 * compactScale),
        boxShadow: [
          BoxShadow(
            color: item.accent.withValues(alpha: 0.12),
            blurRadius: compactScale < 1 ? 6 : 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFF737373),
              fontSize: compactScale < 1 ? 7.4 : 8.2,
              fontWeight: FontWeight.w600,
              height: 1,
            ),
          ),
          SizedBox(height: 4 * compactScale),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontSize: compactScale < 1 ? 10 : 10.8,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }

}

String _fullDayRate(String price) {
  final hourly = _extractAmount(price);
  final fullDay = (hourly * 8).round();
  return '₹$fullDay';
}

String _halfDayRate(String price) {
  final hourly = _extractAmount(price);
  final halfDay = (hourly * 4).round();
  return '₹$halfDay';
}

int _extractAmount(String value) {
  final digits = RegExp(r'\d+').stringMatch(value);
  return int.tryParse(digits ?? '0') ?? 0;
}

class _LabourPortraitImage extends StatelessWidget {
  const _LabourPortraitImage({
    required this.item,
    this.fit = BoxFit.cover,
    this.scale = 1.09,
    this.alignment = Alignment.center,
  });

  final _DiscoveryItem item;
  final BoxFit fit;
  final double scale;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Transform.scale(
        scale: scale,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                item.accent.withValues(alpha: 0.92),
                const Color(0xFF22314D),
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -10,
                bottom: -16,
                child: Opacity(
                  opacity: 0.14,
                  child: Icon(
                    item.icon,
                    size: 136,
                    color: Colors.white,
                  ),
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                top: 16,
                bottom: 16,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
              Positioned.fill(
                child: Align(
                  alignment: alignment,
                  child: Icon(
                    item.icon,
                    size: 96,
                    color: Colors.white.withValues(alpha: 0.97),
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

class _ImageBackedShopTile extends StatelessWidget {
  const _ImageBackedShopTile({required this.item});

  final _DiscoveryItem item;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
            ),
          ),
          _TemporaryCatalogImage(
            item: item,
            fallback: _SceneThumb(
              title: item.title,
              accent: item.accent,
              compact: true,
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    item.accent.withValues(alpha: 0.18),
                    item.accent.withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                  stops: const [0, 0.36, 0.72],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.08),
                    Colors.black.withValues(alpha: 0.72),
                  ],
                  stops: const [0.25, 0.55, 1],
                ),
              ),
            ),
          ),
          Positioned(
            left: 8,
            right: 8,
            bottom: 8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.price,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: _ratingColor(item.rating),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded, size: 9, color: Colors.white),
                          const SizedBox(width: 2),
                          Text(
                            item.rating,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8.8,
                              fontWeight: FontWeight.w800,
                              height: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TemporaryCatalogImage extends StatelessWidget {
  const _TemporaryCatalogImage({
    required this.item,
    required this.fallback,
    this.assetKey,
  });

  final _DiscoveryItem item;
  final Widget fallback;
  final String? assetKey;

  @override
  Widget build(BuildContext context) {
    return fallback;
  }
}

Color _ratingColor(String rating) {
  final value = double.tryParse(rating.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
  if (value > 4) {
    return const Color(0xFF0B7A3B);
  }
  if (value > 3) {
    return const Color(0xFF53B96A);
  }
  if (value >= 2) {
    return const Color(0xFFE7B928);
  }
  return const Color(0xFFD23B3B);
}

class _VerticalProfileCard extends StatelessWidget {
  const _VerticalProfileCard({
    required this.item,
    required this.mode,
    required this.isFavourited,
    required this.onFavouriteToggle,
    required this.onTap,
  });

  final _DiscoveryItem item;
  final _HomeMode mode;
  final bool isFavourited;
  final VoidCallback onFavouriteToggle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
      child: InkWell(
        onTap: item.isDisabled ? null : onTap,
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
	            Container(
	              padding: const EdgeInsets.all(12),
	              decoration: BoxDecoration(
	                color: Colors.white,
	                borderRadius: BorderRadius.circular(20),
	                border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
	                boxShadow: [
	                  BoxShadow(
	                    color: Colors.black.withValues(alpha: 0.20),
	                    blurRadius: 70,
	                    spreadRadius: -20,
	                    offset: const Offset(0, 58),
	                  ),
	                  BoxShadow(
	                    color: Colors.black.withValues(alpha: 0.12),
	                    blurRadius: 34,
	                    spreadRadius: -10,
	                    offset: const Offset(0, 24),
	                  ),
	                  BoxShadow(
	                    color: Colors.black.withValues(alpha: 0.05),
	                    blurRadius: 12,
	                    spreadRadius: -4,
	                    offset: const Offset(0, 8),
	                  ),
	                ],
	              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 74,
                    height: 74,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: _TemporaryCatalogImage(
                        item: item,
                        fallback: _ServiceProviderThumb(item: item),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
	                  Expanded(
	                    child: Padding(
	                      padding: const EdgeInsets.only(right: 26),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: const TextStyle(
                              color: Color(0xFF22314D),
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.subtitle,
                            style: const TextStyle(
                              color: Color(0xFF69778E),
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
	                              Expanded(
	                                flex: 11,
                                child: _ServiceInlineMetaPill(
                                  icon: Icons.place_rounded,
                                  value: item.distance,
                                  color: const Color(0xFF5C8FD8),
                                ),
                              ),
                              const SizedBox(width: 4),
	                              Expanded(
	                                flex: 16,
                                child: _ServiceInlineMetaPill(
                                  icon: Icons.currency_rupee_rounded,
                                  value: item.price,
                                  color: item.accent,
                                ),
                              ),
                              const SizedBox(width: 4),
	                              Expanded(
	                                flex: 10,
                                child: _ServiceInlineMetaPill(
                                  icon: Icons.star_rounded,
                                  value: item.rating,
                                  color: _ratingColor(item.rating),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: _RoundActionIcon(
                icon: isFavourited ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: const Color(0xFFCB6E5B),
                onTap: onFavouriteToggle,
                size: 28,
                iconSize: 15,
              ),
            ),
            if (item.isDisabled && item.disabledLabel.trim().isNotEmpty)
              Positioned(
                left: 8,
                top: 8,
                child: _AvailabilityBadge(
                  label: item.disabledLabel,
                  compact: true,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _LabourModeCard extends StatelessWidget {
  const _LabourModeCard({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const selectedColor = Color(0xFFE53935);
    final labelColor = selected ? selectedColor : const Color(0xFF22314D);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              height: 46,
              width: 46,
              decoration: BoxDecoration(
                color: selected ? selectedColor.withValues(alpha: 0.1) : const Color(0xFFF7F3EF),
                shape: BoxShape.circle,
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: selectedColor.withValues(alpha: 0.18),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : const [],
              ),
              child: Icon(
                icon,
                color: labelColor,
                size: selected ? 28 : 26,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: labelColor,
                fontSize: 13,
                fontWeight: selected ? FontWeight.w900 : FontWeight.w600,
                height: 1,
              ),
            ),
            const SizedBox(height: 5),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              height: 3,
              width: selected ? 76 : 0,
              decoration: BoxDecoration(
                color: selectedColor,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupBookingCard extends StatelessWidget {
  const _GroupBookingCard({
    required this.availableLabour,
    required this.selectedMaxPrice,
    required this.selectedPricePeriod,
    required this.selectedCount,
    required this.onPriceSelected,
    required this.onPricePeriodSelected,
    required this.onCountSelected,
    required this.onBook,
  });

  final int availableLabour;
  final String selectedMaxPrice;
  final String selectedPricePeriod;
  final int selectedCount;
  final ValueChanged<String> onPriceSelected;
  final ValueChanged<String> onPricePeriodSelected;
  final ValueChanged<int> onCountSelected;
  final VoidCallback onBook;

  @override
  Widget build(BuildContext context) {
    final paymentAmount = selectedCount * 25;
    final availabilityColor = _availableLabourColor(availableLabour);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFCB6E5B).withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFFF1E4),
                  Color(0xFFFFE5E8),
                ],
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.82),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.groups_2_rounded,
                    color: Color(0xFFCB6E5B),
                    size: 34,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Book multiple labour',
                        style: TextStyle(
                          color: Color(0xFF22314D),
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                          height: 1.05,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$availableLabour available now',
                        style: TextStyle(
                          color: availabilityColor,
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _GroupBookingInfoTile(
                  label: 'Needed',
                  value: '$selectedCount labour',
                  color: const Color(0xFFF2A13D),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _GroupBookingInfoTile(
                  label: 'Payment',
                  value: '₹$paymentAmount',
                  color: const Color(0xFFCB6E5B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _GroupBookingFlow(
            steps: const ['Notify', 'Accept request', 'Pay in 5 min'],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _GroupBookingNumberField(
                  label: 'Max price',
                  value: selectedMaxPrice,
                  prefix: '₹',
                  icon: Icons.currency_rupee_rounded,
                  color: const Color(0xFFF2A13D),
                  dropdownValue: selectedPricePeriod,
                  dropdownOptions: const ['Full Day', 'Half Day'],
                  onDropdownChanged: onPricePeriodSelected,
                  onChanged: onPriceSelected,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _GroupBookingNumberField(
                  label: 'No. of labour',
                  value: selectedCount.toString(),
                  suffix: 'labour',
                  icon: Icons.groups_rounded,
                  color: const Color(0xFFCB6E5B),
                  onChanged: (value) => onCountSelected(int.tryParse(value) ?? 0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onBook,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFCB6E5B),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: const RoundedRectangleBorder(),
              ),
              child: Text(
                'Book $selectedCount labours - ₹$paymentAmount',
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Request will go to matching labour in your range. Payment must be completed within 5 minutes after labour accepts.',
            style: TextStyle(
              color: Color(0xFF66748C),
              fontWeight: FontWeight.w700,
              height: 1.35,
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }
}

Color _availableLabourColor(int count) {
  if (count <= 10) return const Color(0xFFD23B3B);
  if (count <= 20) return const Color(0xFFE7B928);
  if (count <= 30) return const Color(0xFF53B96A);
  return const Color(0xFF0B7A3B);
}

class _GroupBookingNumberField extends StatefulWidget {
  const _GroupBookingNumberField({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.onChanged,
    this.prefix = '',
    this.suffix = '',
    this.dropdownValue,
    this.dropdownOptions = const [],
    this.onDropdownChanged,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final ValueChanged<String> onChanged;
  final String prefix;
  final String suffix;
  final String? dropdownValue;
  final List<String> dropdownOptions;
  final ValueChanged<String>? onDropdownChanged;

  @override
  State<_GroupBookingNumberField> createState() => _GroupBookingNumberFieldState();
}

class _GroupBookingNumberFieldState extends State<_GroupBookingNumberField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant _GroupBookingNumberField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _controller.text) {
      _controller
        ..text = widget.value
        ..selection = TextSelection.collapsed(offset: widget.value.length);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: widget.color.withValues(alpha: 0.55), width: 1.6),
        boxShadow: [
          BoxShadow(
            color: widget.color.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(widget.icon, color: widget.color, size: 15),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  widget.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF22314D),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
              ),
              if (widget.dropdownValue != null && widget.dropdownOptions.isNotEmpty)
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: widget.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: DropdownButtonHideUnderline(
	                      child: DropdownButton<String>(
	                        value: widget.dropdownValue,
	                        borderRadius: BorderRadius.circular(14),
	                        dropdownColor: const Color(0xFFFFF1E4),
	                        icon: Icon(Icons.keyboard_arrow_down_rounded, color: widget.color, size: 18),
	                        isDense: true,
                        style: TextStyle(
                          color: widget.color,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                        items: widget.dropdownOptions
                            .map(
	                              (option) => DropdownMenuItem<String>(
	                                value: option,
	                                child: Container(
	                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
	                                  decoration: BoxDecoration(
	                                    color: option == widget.dropdownValue
	                                        ? widget.color.withValues(alpha: 0.14)
	                                        : Colors.transparent,
	                                    borderRadius: BorderRadius.circular(10),
	                                  ),
	                                  child: Text(option),
	                                ),
	                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            widget.onDropdownChanged?.call(value);
                          }
                        },
                      ),
                    ),
                  ),
                )
              else
                Icon(Icons.edit_rounded, color: widget.color, size: 16),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: widget.color.withValues(alpha: 0.28)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (widget.prefix.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(right: 2),
                    child: Text(
                      widget.prefix,
                      style: TextStyle(
                        color: widget.color,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),
                  ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: widget.onChanged,
                    cursorColor: widget.color,
                    style: const TextStyle(
                      color: Color(0xFF22314D),
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      border: InputBorder.none,
                      counterText: '',
                      hintText: 'Tap',
                      hintStyle: TextStyle(
                        color: Color(0xFFB6BCCD),
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                if (widget.suffix.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Text(
                      widget.suffix,
                      style: const TextStyle(
                        color: Color(0xFF7A879B),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        height: 1,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupBookingInfoTile extends StatelessWidget {
  const _GroupBookingInfoTile({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF22314D),
              fontWeight: FontWeight.w900,
              fontSize: 15,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupBookingFlow extends StatelessWidget {
  const _GroupBookingFlow({required this.steps});

  final List<String> steps;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var index = 0; index < steps.length; index++) ...[
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
              decoration: BoxDecoration(
                color: const Color(0xFFF6F2EF),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 18,
                    height: 18,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Color(0xFF22314D),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      steps[index],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF22314D),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        height: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (index != steps.length - 1) const SizedBox(width: 6),
        ],
      ],
    );
  }
}

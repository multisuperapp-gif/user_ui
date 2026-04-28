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

class _AllLabourLoadingSection extends StatelessWidget {
  const _AllLabourLoadingSection({
    required this.title,
  });

  final String title;

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
                        Icon(Icons.engineering_rounded, size: 14, color: Color(0xFFF29F38)),
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
                        colors: [Color(0xFFF2A13D), Color(0xFFFFD696)],
                      ),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ],
              ),
            ),
            const _LabourPortraitLoadingSection(
              topPadding: 6,
              compactScale: 0.6,
              trackColor: Color(0xFFFFEEF3),
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

class _LabourPortraitLoadingSection extends StatelessWidget {
  const _LabourPortraitLoadingSection({
    this.compactScale = 1,
    this.topPadding = 14,
    this.trackColor,
  });

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
            itemCount: 3,
            separatorBuilder: (_, _) => SizedBox(width: cardGap),
            itemBuilder: (context, index) => SizedBox(
              width: cardWidth,
              child: _LabourPortraitSkeletonTile(compactScale: compactScale),
            ),
          ),
        ),
      ),
    );
  }
}

class _LabourGridLoadingSection extends StatelessWidget {
  const _LabourGridLoadingSection();

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 0),
      sliver: SliverGrid.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          mainAxisExtent: 246,
        ),
        itemCount: 4,
        itemBuilder: (context, index) => const _LabourPortraitSkeletonTile(compactScale: 0.62),
      ),
    );
  }
}

class _LabourPortraitSkeletonTile extends StatelessWidget {
  const _LabourPortraitSkeletonTile({
    this.compactScale = 1,
  });

  final double compactScale;

  @override
  Widget build(BuildContext context) {
    final outerRadius = 20 * compactScale;
    final outerPaddingX = 4 * compactScale;
    final outerPaddingTop = compactScale < 1 ? 1.0 : 4 * compactScale;
    final outerPaddingBottom = compactScale < 1 ? 3.0 : 6 * compactScale;
    final imageHeight = compactScale < 1 ? 152.0 : 270 * compactScale;
    final imageRadius = compactScale < 1 ? 12.0 : 14.0;
    final primaryGap = compactScale < 1 ? 5.0 : 10 * compactScale;
    final secondaryGap = compactScale < 1 ? 4.0 : 8 * compactScale;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(outerRadius),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFDF7DA0).withValues(alpha: 0.1),
            blurRadius: 18 * compactScale,
            spreadRadius: -4 * compactScale,
            offset: Offset(0, 10 * compactScale),
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
            _LoadingSheenBox(
              height: imageHeight,
              borderRadius: BorderRadius.circular(imageRadius),
            ),
            SizedBox(height: primaryGap),
            const _LoadingSheenBox(
              height: 10,
              width: 84,
            ),
            SizedBox(height: secondaryGap),
            const _LoadingSheenBox(
              height: 14,
              width: 120,
            ),
            SizedBox(height: secondaryGap),
            const _LoadingSheenBox(
              height: 12,
              width: 96,
            ),
            SizedBox(height: primaryGap),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: const LinearProgressIndicator(
                minHeight: 4,
                backgroundColor: Color(0xFFE7E2DE),
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFCFC6C0)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingSheenBox extends StatefulWidget {
  const _LoadingSheenBox({
    required this.height,
    this.width,
    this.borderRadius,
  });

  final double height;
  final double? width;
  final BorderRadius? borderRadius;

  @override
  State<_LoadingSheenBox> createState() => _LoadingSheenBoxState();
}

class _LoadingSheenBoxState extends State<_LoadingSheenBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final value = _controller.value;
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(10),
            gradient: LinearGradient(
              begin: Alignment(-1.8 + (value * 2.8), 0),
              end: Alignment(-0.6 + (value * 2.8), 0),
              colors: const [
                Color(0xFFEAE5E0),
                Color(0xFFF5F1EE),
                Color(0xFFEAE5E0),
              ],
              stops: const [0.15, 0.5, 0.85],
            ),
          ),
        );
      },
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
    final hasVisibleRating = _hasVisibleRating(item.rating);
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
      onTap: onTap,
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
                          left: -8,
                          bottom: compactScale < 1 ? 54 : 72,
                          child: _LabourAvailabilityRibbon(
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
                            if (hasVisibleRating)
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
                            if (hasVisibleRating) const Spacer() else const SizedBox(),
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
                      value: _halfDayRate(item),
                      compactScale: compactScale,
                    ),
                  ),
                  SizedBox(width: 8 * compactScale),
                  Expanded(
                    child: _labourPriceChip(
                      label: 'Full Day',
                      value: _fullDayRate(item),
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

String _fullDayRate(_DiscoveryItem item) {
  if (item.labourFullDayPrice.trim().isNotEmpty) {
    return item.labourFullDayPrice;
  }
  final hourly = _extractAmount(item.price);
  if (hourly <= 0) {
    return 'Not available';
  }
  final fullDay = (hourly * 8).round();
  return '₹$fullDay';
}

String _halfDayRate(_DiscoveryItem item) {
  if (item.labourHalfDayPrice.trim().isNotEmpty) {
    return item.labourHalfDayPrice;
  }
  final hourly = _extractAmount(item.price);
  if (hourly <= 0) {
    return 'Not available';
  }
  final halfDay = (hourly * 4).round();
  return '₹$halfDay';
}

int _extractAmount(String value) {
  final digits = RegExp(r'\d+').stringMatch(value);
  return int.tryParse(digits ?? '0') ?? 0;
}

class _LabourAvailabilityRibbon extends StatelessWidget {
  const _LabourAvailabilityRibbon({
    required this.label,
    this.compact = false,
  });

  final String label;
  final bool compact;

  bool get _isOffline => label.trim().toLowerCase() == 'offline';
  bool get _isBooked => label.trim().toLowerCase() == 'booked';

  @override
  Widget build(BuildContext context) {
    final background = _isOffline ? const Color(0xFFD84A4A) : (_isBooked ? const Color(0xFF141414) : const Color(0xFFCB6E5B));
    return Transform.rotate(
      angle: -0.79,
      child: Container(
        width: compact ? 172 : 214,
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 10 : 12,
          vertical: compact ? 5 : 6,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              background,
              background.withValues(alpha: 0.88),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: background.withValues(alpha: 0.22),
              blurRadius: compact ? 10 : 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white,
            fontSize: compact ? 10 : 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.2,
            height: 1,
          ),
        ),
      ),
    );
  }
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
    final imageUrl = item.profileImageUrl.trim();
    return ClipRect(
      child: Transform.scale(
        scale: scale,
        child: imageUrl.isNotEmpty
            ? Image.network(
                imageUrl,
                fit: fit,
                alignment: alignment,
                errorBuilder: (_, _, _) => _LabourPortraitFallback(item: item, alignment: alignment),
              )
            : _LabourPortraitFallback(item: item, alignment: alignment),
      ),
    );
  }
}

class _LabourPortraitFallback extends StatelessWidget {
  const _LabourPortraitFallback({
    required this.item,
    required this.alignment,
  });

  final _DiscoveryItem item;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    return Container(
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
                    if (_hasVisibleRating(item.rating))
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
    final imageUrl = item.profileImageUrl.trim();
    if (imageUrl.isEmpty) {
      return fallback;
    }
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => fallback,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }
        return fallback;
      },
    );
  }
}

bool _hasVisibleRating(String rating) {
  final value = double.tryParse(rating.replaceAll(RegExp(r'[^0-9.]'), ''));
  return value != null && value > 0;
}

Color _ratingColor(String rating) {
  final value = double.tryParse(rating.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
  if (value > 4.0) {
    return const Color(0xFF0B7A3B);
  }
  if (value >= 3.5) {
    return const Color(0xFF53B96A);
  }
  if (value >= 3.0) {
    return const Color(0xFFE7B928);
  }
  if (value >= 2.0) {
    return const Color(0xFFE53935);
  }
  return const Color(0xFF8B1E1E);
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
        onTap: onTap,
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
                              if (_hasVisibleRating(item.rating)) ...[
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
                left: -12,
                bottom: 28,
                child: _LabourAvailabilityRibbon(
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

class _SingleLabourFilterBar extends StatefulWidget {
  const _SingleLabourFilterBar({
    required this.selectedPeriod,
    required this.maxPrice,
    required this.onPeriodSelected,
    required this.onMaxPriceChanged,
  });

  final String selectedPeriod;
  final String maxPrice;
  final ValueChanged<String> onPeriodSelected;
  final ValueChanged<String> onMaxPriceChanged;

  @override
  State<_SingleLabourFilterBar> createState() => _SingleLabourFilterBarState();
}

class _SingleLabourFilterBarState extends State<_SingleLabourFilterBar> {
  late final TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(text: widget.maxPrice);
  }

  @override
  void didUpdateWidget(covariant _SingleLabourFilterBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.maxPrice != widget.maxPrice && _priceController.text != widget.maxPrice) {
      _priceController.text = widget.maxPrice;
    }
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Filter single labour',
                  style: TextStyle(
                    color: Color(0xFF22314D),
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
              ),
              if (widget.selectedPeriod != 'All' || widget.maxPrice.trim().isNotEmpty)
                TextButton(
                  onPressed: () {
                    _priceController.clear();
                    widget.onPeriodSelected('All');
                    widget.onMaxPriceChanged('');
                  },
                  style: TextButton.styleFrom(
                    minimumSize: const Size(0, 32),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Clear',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: widget.selectedPeriod,
                  decoration: InputDecoration(
                    labelText: 'Booking type',
                    filled: true,
                    fillColor: Colors.white,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFE6D8CF)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFE6D8CF)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFCB6E5B), width: 1.4),
                    ),
                  ),
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFFCB6E5B)),
                  items: const ['All', 'Half Day', 'Full Day']
                      .map(
                        (period) => DropdownMenuItem<String>(
                          value: period,
                          child: Text(
                            period,
                            style: const TextStyle(
                              color: Color(0xFF22314D),
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: (value) {
                    if (value != null) {
                      widget.onPeriodSelected(value);
                    }
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  scrollPadding: const EdgeInsets.only(bottom: 24),
                  onChanged: widget.onMaxPriceChanged,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.currency_rupee_rounded, color: Color(0xFFCB6E5B), size: 18),
                    hintText: 'Max price range',
                    filled: true,
                    fillColor: Colors.white,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFE6D8CF)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFE6D8CF)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFCB6E5B), width: 1.4),
                    ),
                    hintStyle: const TextStyle(fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GroupBookingCard extends StatelessWidget {
  const _GroupBookingCard({
    required this.availableLabour,
    required this.selectedLabourType,
    required this.needsLabourTypeSelection,
    required this.selectedMaxPrice,
    required this.selectedPricePeriod,
    required this.selectedCount,
    required this.maxSelectableCount,
    required this.bookingChargePerLabour,
    required this.showPriceError,
    required this.showCountError,
    this.countErrorText,
    required this.onLabourTypeSelected,
    required this.onPriceSelected,
    required this.onPricePeriodSelected,
    required this.onCountSelected,
    required this.onBook,
  });

  final int availableLabour;
  final String selectedLabourType;
  final bool needsLabourTypeSelection;
  final String selectedMaxPrice;
  final String selectedPricePeriod;
  final int selectedCount;
  final int maxSelectableCount;
  final String bookingChargePerLabour;
  final bool showPriceError;
  final bool showCountError;
  final String? countErrorText;
  final VoidCallback onLabourTypeSelected;
  final ValueChanged<String> onPriceSelected;
  final ValueChanged<String> onPricePeriodSelected;
  final ValueChanged<int> onCountSelected;
  final VoidCallback onBook;

  void _showEstimatedPriceInfo(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text('Estimated price'),
        content: const Text(
          'This is only an estimate based on the number of labour you selected and the maximum budget per labour. The final labour amount depends on which labour actually accept and the real prices they accept at.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showEstimatedBookingFeeInfo(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text('Estimated booking fees'),
        content: const Text(
          'This is only an estimate based on your selected labour count, max price, and booking fee percentage. Final booking fees are calculated on the actual total of the labour who accept, so the payable fee can be lower or different at payment time.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasSelectedCount = selectedCount > 0;
    final hasSelectedPrice = selectedMaxPrice.trim().isNotEmpty;
    final parsedBudget = int.tryParse(selectedMaxPrice.trim()) ?? 0;
    final estimatedPrice = hasSelectedCount && hasSelectedPrice ? selectedCount * parsedBudget : 0;
    final bookingChargePercent = _amountFromLabel(bookingChargePerLabour);
    final bookingChargeAmount = hasSelectedCount && hasSelectedPrice
        ? selectedCount * parsedBudget * (bookingChargePercent / 100)
        : 0.0;
    final availabilityColor = _availableLabourColor(availableLabour);
    final availabilityLabel = needsLabourTypeSelection
        ? '$availableLabour available across all labour'
        : '$availableLabour $selectedLabourType available';
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFE5E8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.groups_2_rounded,
                  color: Color(0xFFCB6E5B),
                  size: 25,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Book multiple labour',
                      style: TextStyle(
                        color: Color(0xFF22314D),
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        height: 1.05,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      availabilityLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: availabilityColor,
                        fontWeight: FontWeight.w900,
                        fontSize: 12.2,
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
              Expanded(
                child: _GroupBookingInfoTile(
                  label: 'Needed',
                  value: hasSelectedCount ? '$selectedCount labour' : 'Select',
                  color: const Color(0xFFF2A13D),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _GroupBookingInfoTile(
                  label: 'Estimated booking fees',
                  value: hasSelectedCount && hasSelectedPrice ? _formatRupee(bookingChargeAmount) : 'Pending',
                  color: const Color(0xFFCB6E5B),
                  onInfoTap: () => _showEstimatedBookingFeeInfo(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _GroupBookingFlow(
            steps: const ['Notify', 'Accept request', 'Pay in 5 min'],
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: onLabourTypeSelected,
            borderRadius: BorderRadius.circular(18),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
              decoration: BoxDecoration(
                color: needsLabourTypeSelection ? const Color(0xFFFFF4EA) : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: needsLabourTypeSelection ? const Color(0xFFCB6E5B) : const Color(0xFFE6D8CF),
                  width: needsLabourTypeSelection ? 1.35 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.engineering_rounded,
                    color: needsLabourTypeSelection ? const Color(0xFFCB6E5B) : const Color(0xFF66748C),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          needsLabourTypeSelection ? 'Select labour type *' : 'Labour type',
                          style: TextStyle(
                            color: needsLabourTypeSelection ? const Color(0xFFCB6E5B) : const Color(0xFF66748C),
                            fontWeight: FontWeight.w900,
                            fontSize: 12.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          needsLabourTypeSelection ? 'Required for group booking' : selectedLabourType,
                          style: const TextStyle(
                            color: Color(0xFF22314D),
                            fontWeight: FontWeight.w900,
                            fontSize: 14.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFFCB6E5B)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _GroupBookingNumberField(
                  label: 'Max budget per labour',
                  value: selectedMaxPrice,
                  hasError: showPriceError,
                  errorText: showPriceError ? 'Enter budget' : null,
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
                  value: hasSelectedCount ? selectedCount.toString() : '',
                  hasError: showCountError,
                  errorText: showCountError ? (countErrorText ?? 'Select count') : null,
                  suffix: 'labour',
                  icon: Icons.groups_rounded,
                  color: const Color(0xFFCB6E5B),
                  selectionOptions: [
                    for (var count = 1; count <= maxSelectableCount; count++) '$count',
                  ],
                  onChanged: (value) => onCountSelected(int.tryParse(value) ?? 0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _GroupBookingAmountSummary(
            estimatedPrice: hasSelectedPrice ? _formatRupee(estimatedPrice.toDouble()) : 'Enter max price',
            bookingCharge: hasSelectedCount ? _formatRupee(bookingChargeAmount) : 'Select count',
            bookingChargeHint: '$selectedCount x max price x $bookingChargePerLabour',
            onEstimatedPriceInfoTap: () => _showEstimatedPriceInfo(context),
            onEstimatedBookingFeeInfoTap: () => _showEstimatedBookingFeeInfo(context),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onBook,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFCB6E5B),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(
                hasSelectedPrice && hasSelectedCount
                    ? 'Continue with group request'
                    : 'Select labour count and budget',
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15.5),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Request will go to matching labour in your range. Booking charge is platform commission and payment must be completed within 5 minutes after labour accepts.',
            style: TextStyle(
              color: Color(0xFF66748C),
              fontWeight: FontWeight.w700,
              height: 1.35,
              fontSize: 11.8,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Note: booking fee is separate and will not be deducted from the labour charge. You still pay the full Half Day or Full Day amount charged by labour.',
            style: TextStyle(
              color: Color(0xFF8A5A1F),
              fontWeight: FontWeight.w700,
              height: 1.35,
              fontSize: 11.8,
            ),
          ),
        ],
      ),
    );
  }
}

double _amountFromLabel(String value) {
  final normalized = value.replaceAll(RegExp(r'[^0-9.]'), '');
  return double.tryParse(normalized) ?? 0;
}

String _formatRupee(double amount) {
  if (amount.truncateToDouble() == amount) {
    return '₹${amount.toStringAsFixed(0)}';
  }
  return '₹${amount.toStringAsFixed(2)}';
}

class _GroupBookingAmountSummary extends StatelessWidget {
  const _GroupBookingAmountSummary({
    required this.estimatedPrice,
    required this.bookingCharge,
    required this.bookingChargeHint,
    required this.onEstimatedPriceInfoTap,
    required this.onEstimatedBookingFeeInfoTap,
  });

  final String estimatedPrice;
  final String bookingCharge;
  final String bookingChargeHint;
  final VoidCallback onEstimatedPriceInfoTap;
  final VoidCallback onEstimatedBookingFeeInfoTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE6D8CF)),
      ),
      child: Column(
        children: [
          _GroupBookingAmountRow(
            label: 'Estimated price',
            value: estimatedPrice,
            helper: 'No. of labour x max price',
            onInfoTap: onEstimatedPriceInfoTap,
          ),
          const SizedBox(height: 10),
          _GroupBookingAmountRow(
            label: 'Estimated booking fees',
            value: bookingCharge,
            helper: bookingChargeHint,
            onInfoTap: onEstimatedBookingFeeInfoTap,
          ),
        ],
      ),
    );
  }
}

class _GroupBookingAmountRow extends StatelessWidget {
  const _GroupBookingAmountRow({
    required this.label,
    required this.value,
    required this.helper,
    this.onInfoTap,
  });

  final String label;
  final String value;
  final String helper;
  final VoidCallback? onInfoTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      label,
                      style: const TextStyle(
                        color: Color(0xFF22314D),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  if (onInfoTap != null) ...[
                    const SizedBox(width: 6),
                    _GroupBookingInfoIconButton(onTap: onInfoTap!),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Text(
                helper,
                style: const TextStyle(
                  color: Color(0xFF7A879B),
                  fontSize: 11.2,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFFCB6E5B),
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
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
    this.selectionOptions = const [],
    this.onDropdownChanged,
    this.hasError = false,
    this.errorText,
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
  final List<String> selectionOptions;
  final ValueChanged<String>? onDropdownChanged;
  final bool hasError;
  final String? errorText;

  @override
  State<_GroupBookingNumberField> createState() => _GroupBookingNumberFieldState();
}

class _GroupBookingNumberFieldState extends State<_GroupBookingNumberField> {
  late final TextEditingController _controller;

  String get _hintText {
    if (widget.prefix.isNotEmpty) {
      return 'Enter budget';
    }
    if (widget.suffix.isNotEmpty) {
      return 'How many?';
    }
    return 'Tap';
  }

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
    final borderColor =
        widget.hasError ? const Color(0xFFD84A4A) : widget.color.withValues(alpha: 0.55);
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: widget.hasError ? 2 : 1.6),
        boxShadow: [
          BoxShadow(
            color: (widget.hasError ? const Color(0xFFD84A4A) : widget.color)
                .withValues(alpha: 0.12),
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
              border: Border.all(
                color: widget.hasError
                    ? const Color(0xFFD84A4A).withValues(alpha: 0.42)
                    : widget.color.withValues(alpha: 0.28),
              ),
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
                  child: widget.selectionOptions.isNotEmpty
                      ? DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: widget.selectionOptions.contains(widget.value)
                                ? widget.value
                                : widget.selectionOptions.first,
                            isExpanded: true,
                            isDense: true,
                            borderRadius: BorderRadius.circular(14),
                            icon: Icon(Icons.keyboard_arrow_down_rounded, color: widget.color, size: 20),
                            style: const TextStyle(
                              color: Color(0xFF22314D),
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              height: 1,
                            ),
                            items: widget.selectionOptions
                                .map(
                                  (option) => DropdownMenuItem<String>(
                                    value: option,
                                    child: Text(option),
                                  ),
                                )
                                .toList(growable: false),
                            onChanged: (value) {
                              if (value != null) {
                                widget.onChanged(value);
                              }
                            },
                          ),
                        )
                      : TextField(
                          controller: _controller,
                          keyboardType: TextInputType.number,
                          scrollPadding: const EdgeInsets.only(bottom: 24),
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
                          ).copyWith(
                            hintText: _hintText,
                            hintStyle: const TextStyle(
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
          if (widget.hasError && (widget.errorText ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 7),
            Text(
              widget.errorText!,
              style: const TextStyle(
                color: Color(0xFFD84A4A),
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
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
    this.onInfoTap,
  });

  final String label;
  final String value;
  final Color color;
  final VoidCallback? onInfoTap;

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
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
              ),
              if (onInfoTap != null) ...[
                const SizedBox(width: 6),
                _GroupBookingInfoIconButton(
                  onTap: onInfoTap!,
                  iconColor: color,
                ),
              ],
            ],
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

class _GroupBookingInfoIconButton extends StatelessWidget {
  const _GroupBookingInfoIconButton({
    required this.onTap,
    this.iconColor = const Color(0xFF66748C),
  });

  final VoidCallback onTap;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.info_outline_rounded,
          size: 13,
          color: iconColor,
        ),
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

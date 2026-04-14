part of '../../../main.dart';

class _ShopGiftSection extends StatelessWidget {
  const _ShopGiftSection({
    required this.occasions,
    required this.favourites,
    this.showOccasions = true,
  });

  final List<_GiftOccasionItem> occasions;
  final List<_GiftFavouriteTileItem> favourites;
  final bool showOccasions;

  @override
  Widget build(BuildContext context) {
    final cakes = favourites[0];
    final gadgets = favourites[1];
    final flowers = favourites[2];
    final beauty = favourites[3];
    final games = favourites[4];
    final home = favourites[5];
    final fashion = favourites[6];
    final books = favourites[7];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showOccasions) ...[
            const _GiftCenteredTitle(title: 'For Every Occasion'),
            const SizedBox(height: 14),
            SizedBox(
              height: 114,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
                scrollDirection: Axis.horizontal,
                itemCount: occasions.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final item = occasions[index];
                  return _GiftOccasionCard(item: item);
                },
              ),
            ),
          ],
          if (showOccasions) const SizedBox(height: 24),
          ...[
            const _GiftCenteredTitle(title: 'Gifting Favourites'),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        _GiftFavouriteTile(
                          item: cakes,
                          height: 118,
                        ),
                        const SizedBox(height: 10),
                        _GiftFavouriteTile(
                          item: beauty,
                          height: 180,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      children: [
                        _GiftFavouriteTile(
                          item: gadgets,
                          height: 180,
                        ),
                        const SizedBox(height: 10),
                        _GiftFavouriteTile(
                          item: games,
                          height: 118,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      children: [
                        _GiftFavouriteTile(
                          item: flowers,
                          height: 180,
                        ),
                        const SizedBox(height: 10),
                        _GiftFavouriteTile(
                          item: home,
                          height: 118,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                children: [
                  Expanded(
                    child: _GiftFavouriteTile(
                      item: fashion,
                      height: 78,
                      wide: true,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _GiftFavouriteTile(
                      item: books,
                      height: 78,
                      wide: true,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _GiftCenteredTitle extends StatelessWidget {
  const _GiftCenteredTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Center(
            child: Text(
              '༺',
              style: TextStyle(
                color: Color(0xFFB8B2AA),
                fontSize: 16,
                fontWeight: FontWeight.w600,
                height: 1,
              ),
            ),
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF222222),
            fontSize: 15,
            fontWeight: FontWeight.w800,
            height: 1,
          ),
        ),
        const Expanded(
          child: Center(
            child: Text(
              '༻',
              style: TextStyle(
                color: Color(0xFFB8B2AA),
                fontSize: 16,
                fontWeight: FontWeight.w600,
                height: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _GiftOccasionCard extends StatelessWidget {
  const _GiftOccasionCard({required this.item});

  final _GiftOccasionItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 112,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            item.accent,
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _GiftImage(
              accent: item.accent,
              icon: item.icon,
              fit: BoxFit.cover,
            ),
            Positioned(
              left: 10,
              right: 10,
              top: 12,
              child: Text(
                item.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF2F2B2B),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  height: 1.05,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GiftFavouriteTile extends StatelessWidget {
  const _GiftFavouriteTile({
    required this.item,
    required this.height,
    this.wide = false,
  });

  final _GiftFavouriteTileItem item;
  final double height;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _GiftImage(
              accent: item.accent,
              icon: item.icon,
              fit: BoxFit.cover,
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.04),
                      Colors.black.withValues(alpha: 0.24),
                    ],
                    stops: const [0.36, 0.68, 1],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 12,
              right: 12,
              top: 12,
              child: Text(
                item.label,
                maxLines: wide ? 1 : 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  height: 1.05,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GiftImage extends StatelessWidget {
  const _GiftImage({
    required this.accent,
    required this.icon,
    required this.fit,
  });

  final Color accent;
  final IconData icon;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withValues(alpha: 0.92),
            Colors.white.withValues(alpha: 0.98),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          icon,
          size: 44,
          color: Colors.white,
        ),
      ),
    );
  }
}

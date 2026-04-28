part of '../../main.dart';

class _AllServiceSection extends StatelessWidget {
  const _AllServiceSection({
    required this.title,
    required this.items,
    required this.onTap,
  });

  final String title;
  final List<_DiscoveryItem> items;
  final ValueChanged<_DiscoveryItem> onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.only(top: 4, bottom: 8),
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
                      color: const Color(0xFFFBEAF2),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.miscellaneous_services_rounded,
                          size: 14,
                          color: Color(0xFFCB5D8E),
                        ),
                        SizedBox(width: 5),
                        Text(
                          'SERVICE SPOTLIGHT',
                          style: TextStyle(
                            color: Color(0xFF9D3F6B),
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
                      color: Color(0xFF342436),
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
                          Color(0xFFDF7DA0),
                          Color(0xFFF6B7CC),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 0, 0),
              child: SizedBox(
                height: 182,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: items.length > 20 ? 20 : items.length,
                  padding: const EdgeInsets.only(right: 18),
                  separatorBuilder: (_, _) => const SizedBox(width: 14),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return SizedBox(
                      width: 146,
                      child: _ServiceDealMiniTile(
                        item: item,
                        onTap: () => onTap(item),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceDealMiniTile extends StatelessWidget {
  const _ServiceDealMiniTile({
    required this.item,
    required this.onTap,
  });

  final _DiscoveryItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Stack(
              fit: StackFit.expand,
              children: [
                const DecoratedBox(
                  decoration: BoxDecoration(color: Colors.white),
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
                          item.accent.withValues(alpha: 0.14),
                          item.accent.withValues(alpha: 0.06),
                          Colors.transparent,
                        ],
                        stops: const [0, 0.34, 0.7],
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
                          Colors.black.withValues(alpha: 0.78),
                        ],
                        stops: const [0.24, 0.58, 1],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 7,
                  left: 7,
                  right: 7,
                  child: Row(
                    children: [
                      if (item.rating.trim().isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: _ratingColor(item.rating),
                            borderRadius: BorderRadius.circular(999),
                            boxShadow: [
                              BoxShadow(
                                color: _ratingColor(item.rating).withValues(alpha: 0.24),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
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
                                  fontSize: 8.4,
                                  fontWeight: FontWeight.w800,
                                  height: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const Spacer(),
                      if (item.distance.trim().isNotEmpty)
                        Container(
                          constraints: const BoxConstraints(maxWidth: 66),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            item.distance,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8.4,
                              fontWeight: FontWeight.w700,
                              height: 1,
                            ),
                          ),
                        ),
                    ],
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
                          fontSize: 10.4,
                          fontWeight: FontWeight.w800,
                          height: 1,
                        ),
                      ),
                      if (item.subtitle.trim().isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          item.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 8.8,
                            fontWeight: FontWeight.w700,
                            height: 1,
                          ),
                        ),
                      ],
                      const SizedBox(height: 5),
                      Text(
                        item.price,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11.8,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (item.isDisabled && item.disabledLabel.trim().isNotEmpty)
            Positioned(
              left: -6,
              bottom: 48,
              child: _LabourAvailabilityRibbon(
                label: item.disabledLabel,
                compact: true,
              ),
            ),
        ],
      ),
    );
  }
}

class _ServiceProviderThumb extends StatelessWidget {
  const _ServiceProviderThumb({required this.item});

  final _DiscoveryItem item;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            item.accent.withValues(alpha: 0.88),
            const Color(0xFF22314D).withValues(alpha: 0.86),
          ],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            right: -12,
            bottom: -12,
            child: Icon(
              item.icon,
              size: 76,
              color: Colors.white.withValues(alpha: 0.14),
            ),
          ),
          Center(
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.22),
                shape: BoxShape.circle,
              ),
              child: Icon(
                item.icon,
                size: 30,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceSubcategoryFilter extends StatelessWidget {
  const _ServiceSubcategoryFilter({
    required this.selectedCategory,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final String selectedCategory;
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    if (options.length <= 1) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 62,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: options.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final option = options[index];
              final selectedOption = selected == option || (!options.contains(selected) && option == 'All');
              final visual = _serviceSubcategoryVisual(option);
              return GestureDetector(
                onTap: () => onSelected(option),
	                child: AnimatedContainer(
	                  duration: const Duration(milliseconds: 160),
	                  width: 86,
	                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 7),
	                  decoration: BoxDecoration(
	                    color: selectedOption ? visual.$2 : Colors.white,
	                    borderRadius: BorderRadius.circular(18),
	                    border: Border.all(
	                      color: selectedOption ? visual.$2 : const Color(0xFFE7E0D9),
	                      width: selectedOption ? 1.3 : 0.9,
	                    ),
                    boxShadow: selectedOption
                        ? [
                            BoxShadow(
                              color: visual.$2.withValues(alpha: 0.14),
	                              blurRadius: 12,
	                              offset: const Offset(0, 6),
                            ),
                          ]
                        : const [],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
	                      Icon(
                          visual.$1,
                          color: selectedOption ? Colors.white : visual.$2,
                          size: 21,
                        ),
	                      const SizedBox(height: 5),
                      Text(
                        option,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: selectedOption ? Colors.white : const Color(0xFF22314D),
	                          fontSize: 11.5,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}


(IconData, Color) _serviceSubcategoryVisual(String label) {
  switch (label) {
    case 'All':
      return (Icons.auto_awesome_rounded, const Color(0xFF22314D));
    case '2 Wheeler':
      return (Icons.two_wheeler_rounded, const Color(0xFF5C8FD8));
    case '3 Wheeler':
      return (Icons.electric_rickshaw_rounded, const Color(0xFFF2A13D));
    case '4 Wheeler':
      return (Icons.directions_car_filled_rounded, const Color(0xFFE55A57));
    case 'Leak repair':
    case 'Fitting':
    case 'Drainage':
      return (Icons.plumbing_rounded, const Color(0xFF3F7FE7));
    case 'Window AC':
    case 'Split AC':
    case 'Gas refill':
      return (Icons.ac_unit_rounded, const Color(0xFF5C8FD8));
    case 'Fridge':
    case 'Washing':
    case 'Kitchen':
      return (Icons.kitchen_rounded, const Color(0xFFDF7DA0));
    case 'Wiring':
    case 'Fan':
    case 'Switchboard':
      return (Icons.electrical_services_rounded, const Color(0xFFF2A13D));
    default:
      return (Icons.miscellaneous_services_rounded, const Color(0xFFCB6E5B));
  }
}

class _ServiceInlineMetaPill extends StatelessWidget {
  const _ServiceInlineMetaPill({
    required this.icon,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 3),
          Expanded(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w900,
                fontSize: 10.4,
                height: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

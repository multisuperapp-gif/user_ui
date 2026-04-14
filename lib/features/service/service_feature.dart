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
    const panelTitles = [
      'Automobile',
      'Home repair',
      'Appliance care',
      'Quick service',
      'Water & power',
      'More services',
    ];
    const panelColors = [
      (Color(0xFF8FD0FF), Color(0xFF74BFF6)),
      (Color(0xFFC20C38), Color(0xFFA20830)),
      (Color(0xFF7E3AF2), Color(0xFF6930D4)),
      (Color(0xFFFF9F6E), Color(0xFFE87142)),
      (Color(0xFF3CC9B6), Color(0xFF189886)),
      (Color(0xFF4756D8), Color(0xFF2939B6)),
    ];
    final panelItems = List.generate(
      panelTitles.length,
      (panelIndex) => List.generate(
        4,
        (itemIndex) => items[(panelIndex * 2 + itemIndex) % items.length],
      ),
    );
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
                height: 296,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: panelItems.length,
                  padding: const EdgeInsets.only(right: 18),
                  separatorBuilder: (_, _) => const SizedBox(width: 14),
                  itemBuilder: (context, index) {
                    final colors = panelColors[index % panelColors.length];
                    return _ServiceDealsPanel(
                      title: panelTitles[index % panelTitles.length],
                      startColor: colors.$1,
                      endColor: colors.$2,
                      items: panelItems[index],
                      onTap: onTap,
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

class _ServiceDealsPanel extends StatelessWidget {
  const _ServiceDealsPanel({
    required this.title,
    required this.startColor,
    required this.endColor,
    required this.items,
    required this.onTap,
  });

  final String title;
  final Color startColor;
  final Color endColor;
  final List<_DiscoveryItem> items;
  final ValueChanged<_DiscoveryItem> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 226,
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [startColor, endColor],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: endColor.withValues(alpha: 0.16),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w900,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: _ServiceDealMiniTile(
                          item: items[0],
                          onTap: () => onTap(items[0]),
                        ),
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: _ServiceDealMiniTile(
                          item: items[1],
                          onTap: () => onTap(items[1]),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: _ServiceDealMiniTile(
                          item: items[2],
                          onTap: () => onTap(items[2]),
                        ),
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: _ServiceDealMiniTile(
                          item: items[3],
                          onTap: () => onTap(items[3]),
                        ),
                      ),
                    ],
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
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
                      Colors.black.withValues(alpha: 0.06),
                      Colors.black.withValues(alpha: 0.76),
                    ],
                    stops: const [0.28, 0.6, 1],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 6,
              right: 6,
              bottom: 6,
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
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
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
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                        decoration: BoxDecoration(
                          color: _ratingColor(item.rating),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded, size: 8, color: Colors.white),
                            const SizedBox(width: 2),
                            Text(
                              item.rating,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8.2,
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

List<String> _serviceSubcategoriesFor(String category) {
  switch (category) {
    case 'Automobile':
      return const ['All', '2 Wheeler', '3 Wheeler', '4 Wheeler'];
    case 'Plumber':
      return const ['All', 'Leak repair', 'Fitting', 'Drainage'];
    case 'AC Repair':
      return const ['All', 'Window AC', 'Split AC', 'Gas refill'];
    case 'Appliance':
    case 'Home Appliance':
      return const ['All', 'Fridge', 'Washing', 'Kitchen'];
    case 'Electrician':
      return const ['All', 'Wiring', 'Fan', 'Switchboard'];
    default:
      return const ['All'];
  }
}

String _serviceCategoryFor(_DiscoveryItem item) {
  final text = '${item.title} ${item.subtitle} ${item.extra}'.toLowerCase();
  if (text.contains('2 wheeler') ||
      text.contains('3 wheeler') ||
      text.contains('4 wheeler') ||
      text.contains('auto') ||
      text.contains('bike') ||
      text.contains('car') ||
      text.contains('rickshaw')) {
    return 'Automobile';
  }
  if (text.contains('plumb') || text.contains('pipe')) {
    return 'Plumber';
  }
  if (text.contains('ac')) {
    return 'AC Repair';
  }
  if (text.contains('appliance') || text.contains('home restore')) {
    return 'Appliance';
  }
  if (text.contains('electric') || text.contains('volt')) {
    return 'Electrician';
  }
  return 'Automobile';
}

String _serviceSubcategoryFor(_DiscoveryItem item, String category) {
  final text = '${item.title} ${item.subtitle} ${item.extra}'.toLowerCase();
  switch (category) {
    case 'Automobile':
      if (text.contains('3 wheeler') || text.contains('rickshaw')) {
        return '3 Wheeler';
      }
      if (text.contains('4 wheeler') || text.contains('car')) {
        return '4 Wheeler';
      }
      return '2 Wheeler';
    case 'Plumber':
      if (text.contains('drain')) return 'Drainage';
      if (text.contains('fit')) return 'Fitting';
      return 'Leak repair';
    case 'AC Repair':
      if (text.contains('gas')) return 'Gas refill';
      if (text.contains('window')) return 'Window AC';
      return 'Split AC';
    case 'Appliance':
    case 'Home Appliance':
      if (text.contains('washing')) return 'Washing';
      if (text.contains('kitchen')) return 'Kitchen';
      return 'Fridge';
    case 'Electrician':
      if (text.contains('fan')) return 'Fan';
      if (text.contains('switch')) return 'Switchboard';
      return 'Wiring';
    default:
      return 'All';
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

part of '../../../main.dart';

class _ShopSectionTitle extends StatelessWidget {
  const _ShopSectionTitle({
    required this.title,
    required this.pillText,
    required this.pillColor,
    required this.icon,
    required this.accentStart,
    required this.accentEnd,
  });

  final String title;
  final String pillText;
  final Color pillColor;
  final IconData icon;
  final Color accentStart;
  final Color accentEnd;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: pillColor,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 14, color: accentStart),
                const SizedBox(width: 5),
                Text(
                  pillText,
                  style: TextStyle(
                    color: accentStart,
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
              letterSpacing: 0.2,
              height: 1,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: 84,
            height: 4,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [accentStart, accentEnd]),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ],
      ),
    );
  }
}

int _extractFashionPrice(String value) {
  final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
  return int.tryParse(digits) ?? 0;
}

class _ShopSubcategoryFilter extends StatelessWidget {
  const _ShopSubcategoryFilter({
    required this.category,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final String category;
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    if (options.length <= 1) {
      return const SizedBox.shrink();
    }
    if (category == 'Fashion') {
      return SizedBox(
        height: 58,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: options.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final option = options[index];
            final selectedOption = selected == option;
            final visual = _fashionSubcategoryVisual(option);
            return GestureDetector(
              onTap: () => onSelected(option),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: _fashionSubcategoryWidth(option),
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: selectedOption
                        ? [
                            visual.$2,
                            visual.$3,
                          ]
                        : const [
                            Colors.white,
                            Color(0xFFFFFAF8),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: selectedOption ? Colors.white.withValues(alpha: 0.62) : visual.$2.withValues(alpha: 0.18),
                    width: selectedOption ? 1.1 : 0.9,
                  ),
                  boxShadow: selectedOption
                      ? [
                          BoxShadow(
                            color: visual.$2.withValues(alpha: 0.2),
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
                      size: 20,
                      color: selectedOption ? Colors.white : visual.$2,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      option,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: selectedOption ? Colors.white : const Color(0xFF283041),
                        fontSize: 10.8,
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
      );
    }
    if (category == 'Footwear') {
      return SizedBox(
        height: 58,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: options.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final option = options[index];
            final selectedOption = selected == option;
            final visual = _footwearSubcategoryVisual(option);
            return GestureDetector(
              onTap: () => onSelected(option),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: _footwearSubcategoryWidth(option),
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: selectedOption
                        ? [
                            visual.$2,
                            visual.$3,
                          ]
                        : const [
                            Colors.white,
                            Color(0xFFFFFBF6),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: selectedOption ? Colors.white.withValues(alpha: 0.62) : visual.$2.withValues(alpha: 0.18),
                    width: selectedOption ? 1.1 : 0.9,
                  ),
                  boxShadow: selectedOption
                      ? [
                          BoxShadow(
                            color: visual.$2.withValues(alpha: 0.2),
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
                      size: 20,
                      color: selectedOption ? Colors.white : visual.$2,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      option,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: selectedOption ? Colors.white : const Color(0xFF283041),
                        fontSize: 10.8,
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
      );
    }
    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: options.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final option = options[index];
          final selectedOption = selected == option;
          return GestureDetector(
            onTap: () => onSelected(option),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              decoration: BoxDecoration(
                color: selectedOption ? const Color(0xFF4DAF50).withValues(alpha: 0.12) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selectedOption ? const Color(0xFF4DAF50) : const Color(0xFFE4E7DE),
                  width: selectedOption ? 1.2 : 0.9,
                ),
                boxShadow: selectedOption
                    ? [
                        BoxShadow(
                          color: const Color(0xFF4DAF50).withValues(alpha: 0.12),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : const [],
              ),
              child: Center(
                child: Text(
                  option,
                  style: TextStyle(
                    color: selectedOption ? const Color(0xFF2E8E45) : const Color(0xFF22314D),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

(IconData, Color, Color) _fashionSubcategoryVisual(String option) {
  switch (option) {
    case 'Men':
      return (Icons.man_rounded, const Color(0xFF3E7BD6), const Color(0xFF75B7FF));
    case 'Women':
      return (Icons.woman_rounded, const Color(0xFFE75D93), const Color(0xFFFFA1C1));
    case 'Boys':
      return (Icons.boy_rounded, const Color(0xFFF2A13D), const Color(0xFFFFD172));
    case 'Girls':
      return (Icons.girl_rounded, const Color(0xFFE75D93), const Color(0xFFFFA1C1));
    default:
      return (Icons.auto_awesome_rounded, const Color(0xFF22314D), const Color(0xFF7A879B));
  }
}

double _fashionSubcategoryWidth(String option) {
  switch (option) {
    case 'Women':
      return 78;
    case 'Boys':
    case 'Girls':
      return 66;
    default:
      return 68;
  }
}

(IconData, Color, Color) _footwearSubcategoryVisual(String option) {
  switch (option) {
    case 'Men':
      return (Icons.directions_walk_rounded, const Color(0xFF3E7BD6), const Color(0xFF75B7FF));
    case 'Women':
      return (Icons.woman_rounded, const Color(0xFFE75D93), const Color(0xFFFFA1C1));
    case 'Boys':
      return (Icons.directions_run_rounded, const Color(0xFFF2A13D), const Color(0xFFFFD172));
    case 'Girls':
      return (Icons.auto_awesome_rounded, const Color(0xFFCB6E5B), const Color(0xFFFFB99D));
    default:
      return (Icons.hiking_rounded, const Color(0xFF1FB8A4), const Color(0xFF8BE6D3));
  }
}

double _footwearSubcategoryWidth(String option) {
  switch (option) {
    case 'Women':
      return 78;
    case 'Boys':
    case 'Girls':
      return 66;
    default:
      return 68;
  }
}

List<String> _shopSubcategoriesFor(String category) {
  switch (category) {
    case 'Restaurant':
      return const ['All'];
    case 'Gift':
      return const ['All', 'Birthday', 'Anniversary', 'Reception', 'Festival'];
    case 'Groceries':
      return const ['All', 'Biscuits', 'Noodles', 'Rice', 'Chips', 'Household'];
    case 'Pharmacy':
      return const ['All', 'Wellness', 'Baby care', 'Personal care', 'Essentials'];
    case 'Fashion':
    case 'Cloth':
      return const ['All', 'Men', 'Women', 'Boys', 'Girls'];
    case 'Footwear':
      return const ['All', 'Men', 'Women', 'Boys', 'Girls'];
    default:
      return const ['All'];
  }
}

String _shopCategoryForSection(_DiscoverySection section) {
  final title = section.title.toLowerCase();
  if (title.contains('gift')) return 'Gift';
  if (title.contains('grocery')) return 'Groceries';
  if (title.contains('pharmacy')) return 'Pharmacy';
  if (title.contains('footwear') || title.contains('shoe') || title.contains('sandal')) return 'Footwear';
  if (title.contains('fashion') || title.contains('cloth')) return 'Fashion';
  return 'All';
}

String _shopCategoryForItem(_DiscoveryItem item) {
  final explicit = item.shopCategory?.trim();
  if (explicit != null && explicit.isNotEmpty && explicit.toLowerCase() != 'all') {
    return explicit;
  }
  final text = '${item.title} ${item.subtitle} ${item.shopCategory ?? ''}'.toLowerCase();
  if (text.contains('shoe') ||
      text.contains('shoes') ||
      text.contains('sandal') ||
      text.contains('sandals') ||
      text.contains('slipper') ||
      text.contains('slippers') ||
      text.contains('sneaker') ||
      text.contains('sneakers') ||
      text.contains('loafer') ||
      text.contains('loafers') ||
      text.contains('heel') ||
      text.contains('heels') ||
      text.contains('slides') ||
      text.contains('boots') ||
      text.contains('boot') ||
      text.contains('flats')) {
    return 'Footwear';
  }
  if (text.contains('shirt') ||
      text.contains('jeans') ||
      text.contains('kurti') ||
      text.contains('saree') ||
      text.contains('dress') ||
      text.contains('blazer') ||
      text.contains('trouser') ||
      text.contains('frock') ||
      text.contains('gown')) {
    return 'Fashion';
  }
  if (text.contains('pharmacy') || text.contains('tablet') || text.contains('vitamin') || text.contains('lotion')) {
    return 'Pharmacy';
  }
  if (text.contains('gift') ||
      text.contains('frame') ||
      text.contains('hamper') ||
      text.contains('perfume') ||
      text.contains('bouquet') ||
      text.contains('bloom') ||
      text.contains('orchid') ||
      text.contains('flower') ||
      text.contains('roses') ||
      text.contains('rosey') ||
      text.contains('plant')) {
    return 'Gift';
  }
  if (text.contains('vegetable') || text.contains('tomato') || text.contains('spinach') || text.contains('capsicum')) {
    return 'Groceries';
  }
  if (text.contains('pizza') ||
      text.contains('burger') ||
      text.contains('meal') ||
      text.contains('thali') ||
      text.contains('combo')) {
    return 'Restaurant';
  }
  return 'Groceries';
}

String _shopSubcategoryFor(_DiscoveryItem item, String category) {
  final text = '${item.title} ${item.subtitle}'.toLowerCase();
  switch (category) {
    case 'Gift':
      if (text.contains('frame') || text.contains('perfume') || text.contains('lamp')) {
        return 'Anniversary';
      }
      if (text.contains('dry fruit') || text.contains('decor')) {
        return 'Reception';
      }
      if (text.contains('chocolate') || text.contains('hamper')) {
        return 'Festival';
      }
      return 'Birthday';
    case 'Groceries':
      if (text.contains('biscuit') || text.contains('cracker') || text.contains('cookie')) {
        return 'Biscuits';
      }
      if (text.contains('maggi') || text.contains('noodle') || text.contains('pasta')) {
        return 'Noodles';
      }
      if (text.contains('rice') || text.contains('atta') || text.contains('dal')) {
        return 'Rice';
      }
      if (text.contains('chips') || text.contains('snack')) {
        return 'Chips';
      }
      return 'Household';
    case 'Pharmacy':
      if (text.contains('baby')) return 'Baby care';
      if (text.contains('face') || text.contains('sanitizer')) return 'Personal care';
      if (text.contains('bandage') || text.contains('paracetamol')) return 'Essentials';
      return 'Wellness';
    case 'Fashion':
    case 'Cloth':
      if (text.contains('girls') || text.contains('gown') || text.contains('frock')) return 'Girls';
      if (text.contains('boys') || text.contains('kids')) return 'Boys';
      if (text.contains('shirt') || text.contains('jeans') || text.contains('blazer') || text.contains('trouser')) {
        return 'Men';
      }
      return 'Women';
    case 'Footwear':
      if (text.contains('girls') || text.contains('cute') || text.contains('ballet')) return 'Girls';
      if (text.contains('boys') || text.contains('kids') || text.contains('school')) return 'Boys';
      if (text.contains('heels') || text.contains('flats') || text.contains('women') || text.contains('party')) {
        return 'Women';
      }
      return 'Men';
    default:
      return 'All';
  }
}

class _ShopBrowseToggle extends StatelessWidget {
  const _ShopBrowseToggle({
    required this.selected,
    required this.onSelected,
    required this.sortByPrice,
    required this.onSortByPrice,
    required this.onFilterTap,
  });

  final _ShopBrowseMode selected;
  final ValueChanged<_ShopBrowseMode> onSelected;
  final bool sortByPrice;
  final VoidCallback onSortByPrice;
  final VoidCallback onFilterTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F2EF),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFEDE1DA)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _shopBrowseChip(
                      label: 'Item wise',
                      icon: Icons.grid_view_rounded,
                      selected: selected == _ShopBrowseMode.itemWise,
                      onTap: () => onSelected(_ShopBrowseMode.itemWise),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: _shopBrowseChip(
                      label: 'Shop wise',
                      icon: Icons.storefront_rounded,
                      selected: selected == _ShopBrowseMode.shopWise,
                      onTap: () => onSelected(_ShopBrowseMode.shopWise),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          _shopActionIcon(
            icon: Icons.tune_rounded,
            selected: false,
            onTap: onFilterTap,
          ),
          const SizedBox(width: 8),
          _shopSortChip(),
        ],
      ),
    );
  }

  Widget _shopBrowseChip({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: const Color(0xFFCB6E5B).withValues(alpha: 0.14),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : const [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 15,
              color: selected ? const Color(0xFFCB6E5B) : const Color(0xFF7A879B),
            ),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected ? const Color(0xFF22314D) : const Color(0xFF63728A),
                  fontWeight: FontWeight.w900,
                  fontSize: 11.3,
                  height: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _shopSortChip() {
    return _shopActionIcon(
      icon: Icons.swap_vert_rounded,
      selected: sortByPrice,
      onTap: onSortByPrice,
    );
  }

  Widget _shopActionIcon({
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF22314D) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: selected ? const Color(0xFF22314D) : const Color(0xFFE7DED8),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: selected ? 0.12 : 0.05),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 21,
          color: selected ? Colors.white : const Color(0xFFCB6E5B),
        ),
      ),
    );
  }
}

class _ShopSortOptionTile extends StatelessWidget {
  const _ShopSortOptionTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? const Color(0xFFCB6E5B) : const Color(0xFF4D5362);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFFF0EA) : const Color(0xFFF8F6F3),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? const Color(0xFFFFC3AD) : const Color(0xFFECE4DD),
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
              color: color,
              size: 19,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

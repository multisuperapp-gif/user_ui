part of '../../main.dart';

String _allQuickCategoryLabelForItem(_DiscoveryItem item) {
  return _allQuickCategoryChipLabelForItem(item);
}

String _allQuickCategoryChipLabelForItem(_DiscoveryItem item) {
  final extra = item.extra.trim();
  final text = '${item.title} ${item.subtitle} ${item.extra}'.toLowerCase();

  if (extra == 'Bakery' || text.contains('bakery')) {
    return 'Bakery';
  }
  if (extra == 'Gift' || text.contains('gift')) {
    return 'Gifting';
  }
  if (extra == 'Shop' ||
      text.contains('kitchen') ||
      text.contains('staples') ||
      text.contains('oil') ||
      text.contains('atta') ||
      text.contains('dal')) {
    return 'Kitchen';
  }
  if (extra == 'Dining' ||
      text.contains('dinner') ||
      text.contains('meal') ||
      text.contains('thali') ||
      text.contains('restaurant')) {
    return 'Dining';
  }
  if (extra == 'Pharmacy' || text.contains('pharmacy')) {
    return 'Pharmacy';
  }
  if (extra == 'Essentials' || text.contains('milk') || text.contains('bread')) {
    return 'Essentials';
  }
  if (extra == 'Groceries' || text.contains('grocery') || text.contains('veg') || text.contains('fruit')) {
    return 'Groceries';
  }
  return extra.isNotEmpty ? extra : 'Groceries';
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundActionIcon extends StatelessWidget {
  const _RoundActionIcon({
    required this.icon,
    required this.color,
    required this.onTap,
    this.size = 34,
    this.iconSize = 18,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: iconSize),
      ),
    );
  }
}

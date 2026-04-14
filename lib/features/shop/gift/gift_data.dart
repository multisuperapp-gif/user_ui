part of '../../../main.dart';

class _GiftLandingSectionData {
  const _GiftLandingSectionData({
    required this.title,
    required this.items,
  });

  final String title;
  final List<_DiscoveryItem> items;
}

class _GiftQuickCategoryData {
  const _GiftQuickCategoryData({
    required this.label,
    required this.icon,
    required this.accent,
  });

  final String label;
  final IconData icon;
  final Color accent;
}

class _GiftOptionData {
  const _GiftOptionData({
    required this.label,
    required this.price,
  });

  final String label;
  final String price;
}

final List<_GiftQuickCategoryData> _giftQuickCategories = const [
  _GiftQuickCategoryData(
    label: 'Get Same Day',
    icon: Icons.delivery_dining_rounded,
    accent: Color(0xFFA8D7B0),
  ),
  _GiftQuickCategoryData(
    label: 'Birthday',
    icon: Icons.cake_rounded,
    accent: Color(0xFFF4C971),
  ),
  _GiftQuickCategoryData(
    label: 'Anniversary',
    icon: Icons.wine_bar_rounded,
    accent: Color(0xFFE7A5A5),
  ),
  _GiftQuickCategoryData(
    label: 'Personalised',
    icon: Icons.style_rounded,
    accent: Color(0xFFF5CF6E),
  ),
  _GiftQuickCategoryData(
    label: 'Flowers',
    icon: Icons.local_florist_rounded,
    accent: Color(0xFFF2A9A1),
  ),
  _GiftQuickCategoryData(
    label: 'Luxe',
    icon: Icons.auto_awesome_rounded,
    accent: Color(0xFF2A2A2A),
  ),
  _GiftQuickCategoryData(
    label: 'Cakes',
    icon: Icons.cake_outlined,
    accent: Color(0xFFB78669),
  ),
  _GiftQuickCategoryData(
    label: 'Plants',
    icon: Icons.eco_rounded,
    accent: Color(0xFF8FD089),
  ),
];

final List<_GiftLandingSectionData> _giftLandingSections = [
  _GiftLandingSectionData(
    title: 'Gifts That Go Together',
    items: const [
      _DiscoveryItem(
        title: 'Flowers n Chocolates',
        subtitle: 'Luxe',
        accent: Color(0xFFF09EAA),
        icon: Icons.favorite_rounded,
        price: '₹1,799',
        rating: '4.9',
        extra: 'Birthday',
      ),
      _DiscoveryItem(
        title: 'Flowers n Cakes',
        subtitle: 'Cake For You',
        accent: Color(0xFFF2C877),
        icon: Icons.cake_rounded,
        price: '₹1,899',
        rating: '4.8',
        extra: 'Birthday',
      ),
      _DiscoveryItem(
        title: 'Chocolate Celebration',
        subtitle: 'Gift Aura',
        accent: Color(0xFFCB8E71),
        icon: Icons.card_giftcard_rounded,
        price: '₹1,499',
        rating: '4.7',
        extra: 'Festival',
      ),
    ],
  ),
  _GiftLandingSectionData(
    title: 'Plants For Every Vibe',
    items: const [
      _DiscoveryItem(
        title: 'New Arrivals',
        subtitle: 'Plant Nest',
        accent: Color(0xFF9FD3A9),
        icon: Icons.eco_rounded,
        price: '₹699',
        rating: '4.7',
        extra: 'Festival',
      ),
      _DiscoveryItem(
        title: 'Indoor Plants',
        subtitle: 'Plant Nest',
        accent: Color(0xFF94C78F),
        icon: Icons.spa_rounded,
        price: '₹899',
        rating: '4.8',
        extra: 'Festival',
      ),
      _DiscoveryItem(
        title: 'Green Gift Pots',
        subtitle: 'Bloom Basket',
        accent: Color(0xFFA1D89B),
        icon: Icons.grass_rounded,
        price: '₹1,099',
        rating: '4.7',
        extra: 'Reception',
      ),
    ],
  ),
  _GiftLandingSectionData(
    title: 'Home & Living Gifts',
    items: const [
      _DiscoveryItem(
        title: 'Soft Home Set',
        subtitle: 'HomeGlow',
        accent: Color(0xFFE2D3C2),
        icon: Icons.weekend_rounded,
        price: '₹1,499',
        rating: '4.6',
        extra: 'Festival',
      ),
      _DiscoveryItem(
        title: 'Living Room Luxe',
        subtitle: 'HomeGlow',
        accent: Color(0xFFD7C1B7),
        icon: Icons.chair_alt_rounded,
        price: '₹1,999',
        rating: '4.8',
        extra: 'Reception',
      ),
      _DiscoveryItem(
        title: 'Cozy Decor Tray',
        subtitle: 'Gift Aura',
        accent: Color(0xFFCDB7A5),
        icon: Icons.table_restaurant_rounded,
        price: '₹1,299',
        rating: '4.5',
        extra: 'Anniversary',
      ),
    ],
  ),
];

final List<_DiscoveryItem> _giftShopSeeds = const [
  _DiscoveryItem(
    title: 'Luxe',
    subtitle: 'Birthday bouquets and premium hampers',
    accent: Color(0xFFE5B8C5),
    icon: Icons.local_florist_rounded,
    rating: '4.9',
    distance: '1.4 km',
  ),
  _DiscoveryItem(
    title: 'Bloom Basket',
    subtitle: 'Flowers, orchids and same-day arrangements',
    accent: Color(0xFFF0B3B3),
    icon: Icons.filter_vintage_rounded,
    rating: '4.8',
    distance: '1.7 km',
  ),
  _DiscoveryItem(
    title: 'Cake For You',
    subtitle: 'Cakes with gift combos and surprise boxes',
    accent: Color(0xFFF2C477),
    icon: Icons.cake_rounded,
    rating: '4.7',
    distance: '1.3 km',
  ),
  _DiscoveryItem(
    title: 'Plant Nest',
    subtitle: 'Indoor plants and green decor gifts',
    accent: Color(0xFF9FD3A9),
    icon: Icons.eco_rounded,
    rating: '4.8',
    distance: '2.0 km',
  ),
];

List<_DiscoveryItem> _giftProductsForOccasion(String occasion, {String? shopName}) {
  final normalizedOccasion = _giftOccasionOptions.contains(occasion) ? occasion : 'Birthday';
  final base = <({
    String title,
    String shop,
    String price,
    String rating,
    String occasion,
    Color accent,
    IconData icon,
  })>[
    (
      title: 'Garden of Eden',
      shop: 'Luxe',
      price: '₹3,299',
      rating: '5.0',
      occasion: 'Birthday',
      accent: const Color(0xFFE6A4B4),
      icon: Icons.local_florist_rounded,
    ),
    (
      title: 'Butterfly Rosey Charm Gift Bouquet',
      shop: 'Petal Story',
      price: '₹2,599',
      rating: '4.9',
      occasion: 'Birthday',
      accent: const Color(0xFFF2A7BA),
      icon: Icons.favorite_rounded,
    ),
    (
      title: 'Royal Bloom Arrangement',
      shop: 'Luxe',
      price: '₹3,499',
      rating: '4.8',
      occasion: 'Anniversary',
      accent: const Color(0xFFE4B5C8),
      icon: Icons.auto_awesome_rounded,
    ),
    (
      title: 'Rosy Orchid Celebration Bouquet',
      shop: 'Bloom Basket',
      price: '₹849',
      rating: '5.0',
      occasion: 'Anniversary',
      accent: const Color(0xFFF0A0C5),
      icon: Icons.filter_vintage_rounded,
    ),
    (
      title: 'Flowers n Cakes Delight',
      shop: 'Cake For You',
      price: '₹1,899',
      rating: '4.7',
      occasion: 'Birthday',
      accent: const Color(0xFFF2C877),
      icon: Icons.cake_rounded,
    ),
    (
      title: 'Flowers n Chocolates',
      shop: 'Gift Aura',
      price: '₹1,799',
      rating: '4.7',
      occasion: 'Festival',
      accent: const Color(0xFFCB8E71),
      icon: Icons.card_giftcard_rounded,
    ),
    (
      title: 'Indoor Plant Serenity',
      shop: 'Plant Nest',
      price: '₹699',
      rating: '4.8',
      occasion: 'Festival',
      accent: const Color(0xFF9FD3A9),
      icon: Icons.eco_rounded,
    ),
    (
      title: 'Home Glow Hamper',
      shop: 'HomeGlow',
      price: '₹1,499',
      rating: '4.6',
      occasion: 'Reception',
      accent: const Color(0xFFD5C7B2),
      icon: Icons.home_filled,
    ),
  ];

  final expanded = List<_DiscoveryItem>.generate(120, (index) {
    final entry = base[index % base.length];
    final round = index ~/ base.length;
    final title = round == 0 ? entry.title : '${entry.title} ${round + 1}';
    final priceAmount = _extractAmount(entry.price) + (round * 40);
    return _DiscoveryItem(
      title: title,
      subtitle: entry.shop,
      accent: entry.accent,
      icon: entry.icon,
      price: '₹${priceAmount.toStringAsFixed(0)}',
      rating: entry.rating,
      distance: '1.${(index % 8) + 1} km',
      extra: entry.occasion,
    );
  });

  return expanded.where((item) {
    final matchesOccasion = item.extra == normalizedOccasion;
    final matchesShop = shopName == null || shopName.isEmpty || item.subtitle == shopName;
    return matchesOccasion && matchesShop;
  }).toList();
}

List<_DiscoveryItem> _sortedGiftItems(List<_DiscoveryItem> items, String sortOption) {
  final sorted = [...items];
  switch (sortOption) {
    case 'Low to High':
      sorted.sort((left, right) => _extractAmount(left.price).compareTo(_extractAmount(right.price)));
      break;
    case 'High to Low':
      sorted.sort((left, right) => _extractAmount(right.price).compareTo(_extractAmount(left.price)));
      break;
    case 'Newly Added':
      return sorted.reversed.toList();
    case 'Popular':
    default:
      sorted.sort((left, right) => _giftRatingScore(right.rating).compareTo(_giftRatingScore(left.rating)));
      break;
  }
  return sorted;
}

double _giftRatingScore(String rating) =>
    double.tryParse(rating.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;

IconData _giftIconForItem(String title) {
  final key = title.toLowerCase();
  if (key.contains('cake')) return Icons.cake_rounded;
  if (key.contains('plant')) return Icons.eco_rounded;
  if (key.contains('home')) return Icons.home_filled;
  if (key.contains('chocolate')) return Icons.card_giftcard_rounded;
  return Icons.local_florist_rounded;
}

List<Color> _giftGradientForItem(String title, Color accent) {
  final key = title.toLowerCase();
  if (key.contains('cake')) {
    return const [Color(0xFFFFE8C5), Color(0xFFF6C585)];
  }
  if (key.contains('plant')) {
    return const [Color(0xFFE1F6E0), Color(0xFF98D39A)];
  }
  if (key.contains('home')) {
    return const [Color(0xFFF2E8DE), Color(0xFFDABCA6)];
  }
  return [
    accent.withValues(alpha: 0.92),
    accent.withValues(alpha: 0.64),
  ];
}

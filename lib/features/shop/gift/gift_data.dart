part of '../../../main.dart';

class _GiftOptionData {
  const _GiftOptionData({
    required this.label,
    required this.price,
  });

  final String label;
  final String price;
}

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

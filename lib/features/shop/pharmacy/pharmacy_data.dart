part of '../../../main.dart';

class _PharmacyCampaignSectionData {
  const _PharmacyCampaignSectionData({
    required this.category,
    required this.title,
    required this.colors,
    required this.items,
  });

  final String category;
  final String title;
  final List<Color> colors;
  final List<_DiscoveryItem> items;
}

class _PharmacyMenuSectionData {
  const _PharmacyMenuSectionData({
    required this.title,
    required this.items,
  });

  final String title;
  final List<_DiscoveryItem> items;
}

List<_DiscoveryItem> _sortedPharmacyItems(List<_DiscoveryItem> items, String sortOption) {
  final sorted = [...items];
  switch (sortOption) {
    case 'Low to High':
      sorted.sort((left, right) => _extractAmount(left.price).compareTo(_extractAmount(right.price)));
      break;
    case 'High to Low':
      sorted.sort((left, right) => _extractAmount(right.price).compareTo(_extractAmount(left.price)));
      break;
    case 'Newly Added':
      sorted.sort((left, right) => right.title.compareTo(left.title));
      break;
    case 'Popular':
    default:
      sorted.sort((left, right) {
        final promotedCompare = (right.extra.contains('Promoted') ? 1 : 0)
            .compareTo(left.extra.contains('Promoted') ? 1 : 0);
        if (promotedCompare != 0) return promotedCompare;
        return (double.tryParse(right.rating) ?? 0).compareTo(double.tryParse(left.rating) ?? 0);
      });
  }
  return sorted;
}

List<_DiscoveryItem> _pharmacyItemsForCategory(String category, {String? shopName}) {
  final shop = shopName ?? _pharmacyDefaultShopFor(category);
  switch (category) {
    case 'Baby care':
      return [
        _DiscoveryItem(title: 'Baby Lotion', subtitle: shop, accent: const Color(0xFFE7A4B8), icon: Icons.child_friendly_rounded, price: '₹199', rating: '4.6', extra: 'Promoted'),
        _DiscoveryItem(title: 'Baby Wipes', subtitle: shop, accent: const Color(0xFF97C8D5), icon: Icons.clean_hands_rounded, price: '₹149', rating: '4.4'),
        _DiscoveryItem(title: 'Diaper Pack', subtitle: shop, accent: const Color(0xFFF2C47B), icon: Icons.inventory_2_rounded, price: '₹399', rating: '4.5'),
        _DiscoveryItem(title: 'Baby Soap', subtitle: shop, accent: const Color(0xFFC9B2E8), icon: Icons.soap_rounded, price: '₹89', rating: '4.2'),
        _DiscoveryItem(title: 'Rash Cream', subtitle: shop, accent: const Color(0xFFE88F9A), icon: Icons.healing_rounded, price: '₹129', rating: '4.3'),
        _DiscoveryItem(title: 'Baby Powder', subtitle: shop, accent: const Color(0xFFB6D7E0), icon: Icons.face_rounded, price: '₹119', rating: '4.1'),
        _DiscoveryItem(title: 'Feeding Bottle', subtitle: shop, accent: const Color(0xFF8FC7C2), icon: Icons.local_drink_rounded, price: '₹179', rating: '4.2'),
        _DiscoveryItem(title: 'Nasal Drops', subtitle: shop, accent: const Color(0xFF7CB4D6), icon: Icons.water_drop_rounded, price: '₹65', rating: '4.0'),
      ];
    case 'Personal care':
      return [
        _DiscoveryItem(title: 'Face Wash', subtitle: shop, accent: const Color(0xFF7CB4D6), icon: Icons.face_rounded, price: '₹149', rating: '4.5', extra: 'Promoted'),
        _DiscoveryItem(title: 'Body Lotion', subtitle: shop, accent: const Color(0xFFE7A4B8), icon: Icons.spa_rounded, price: '₹249', rating: '4.4'),
        _DiscoveryItem(title: 'Shampoo', subtitle: shop, accent: const Color(0xFF7AD0BF), icon: Icons.sanitizer_rounded, price: '₹189', rating: '4.3'),
        _DiscoveryItem(title: 'Hand Sanitizer', subtitle: shop, accent: const Color(0xFF85B9E8), icon: Icons.clean_hands_rounded, price: '₹99', rating: '4.2'),
        _DiscoveryItem(title: 'Lip Balm', subtitle: shop, accent: const Color(0xFFE68CA0), icon: Icons.favorite_border_rounded, price: '₹79', rating: '4.1'),
        _DiscoveryItem(title: 'Sunscreen', subtitle: shop, accent: const Color(0xFFF0C26A), icon: Icons.wb_sunny_outlined, price: '₹329', rating: '4.6'),
        _DiscoveryItem(title: 'Hair Serum', subtitle: shop, accent: const Color(0xFFC7A1DA), icon: Icons.auto_awesome_rounded, price: '₹279', rating: '4.0'),
        _DiscoveryItem(title: 'Toothpaste', subtitle: shop, accent: const Color(0xFF8CC7D8), icon: Icons.medication_rounded, price: '₹68', rating: '4.2'),
      ];
    case 'Essentials':
      return [
        _DiscoveryItem(title: 'Paracetamol', subtitle: shop, accent: const Color(0xFF7CB4D6), icon: Icons.medication_rounded, price: '₹28', rating: '4.8', extra: 'Promoted'),
        _DiscoveryItem(title: 'Bandage', subtitle: shop, accent: const Color(0xFF8FC7C2), icon: Icons.healing_rounded, price: '₹35', rating: '4.6'),
        _DiscoveryItem(title: 'ORS Pack', subtitle: shop, accent: const Color(0xFFF2C47B), icon: Icons.local_drink_rounded, price: '₹22', rating: '4.7'),
        _DiscoveryItem(title: 'Vapor Rub', subtitle: shop, accent: const Color(0xFFB6D7E0), icon: Icons.spa_rounded, price: '₹68', rating: '4.5'),
        _DiscoveryItem(title: 'Antacid', subtitle: shop, accent: const Color(0xFF7AD0BF), icon: Icons.medication_liquid_rounded, price: '₹48', rating: '4.4'),
        _DiscoveryItem(title: 'Thermometer', subtitle: shop, accent: const Color(0xFFE7A4B8), icon: Icons.device_thermostat_rounded, price: '₹179', rating: '4.3'),
        _DiscoveryItem(title: 'Pain Relief', subtitle: shop, accent: const Color(0xFF97C8D5), icon: Icons.health_and_safety_rounded, price: '₹54', rating: '4.5'),
        _DiscoveryItem(title: 'Cotton Roll', subtitle: shop, accent: const Color(0xFFCDDCE8), icon: Icons.inventory_2_rounded, price: '₹42', rating: '4.1'),
      ];
    case 'Wellness':
    default:
      return [
        _DiscoveryItem(title: 'Vitamin C', subtitle: shop, accent: const Color(0xFFF0C26A), icon: Icons.health_and_safety_rounded, price: '₹95', rating: '4.9', extra: 'Promoted'),
        _DiscoveryItem(title: 'Protein Drink', subtitle: shop, accent: const Color(0xFF7AD0BF), icon: Icons.local_drink_rounded, price: '₹399', rating: '4.5'),
        _DiscoveryItem(title: 'Immunity Kit', subtitle: shop, accent: const Color(0xFFE7A4B8), icon: Icons.favorite_rounded, price: '₹299', rating: '4.6'),
        _DiscoveryItem(title: 'Multivitamins', subtitle: shop, accent: const Color(0xFF7CB4D6), icon: Icons.medication_rounded, price: '₹185', rating: '4.4'),
        _DiscoveryItem(title: 'Calcium Tablets', subtitle: shop, accent: const Color(0xFFB6D7E0), icon: Icons.medication_rounded, price: '₹159', rating: '4.3'),
        _DiscoveryItem(title: 'Herbal Tea', subtitle: shop, accent: const Color(0xFF8FC7C2), icon: Icons.emoji_food_beverage_rounded, price: '₹129', rating: '4.2'),
        _DiscoveryItem(title: 'Omega Softgel', subtitle: shop, accent: const Color(0xFFC7A1DA), icon: Icons.medication_rounded, price: '₹249', rating: '4.1'),
        _DiscoveryItem(title: 'Electrolyte Mix', subtitle: shop, accent: const Color(0xFF97C8D5), icon: Icons.water_drop_rounded, price: '₹89', rating: '4.0'),
      ];
  }
}

String _pharmacyDefaultShopFor(String category) {
  switch (category) {
    case 'Baby care':
      return 'Little Care Pharmacy';
    case 'Personal care':
      return 'Glow Pharmacy';
    case 'Essentials':
      return 'Care Plus';
    case 'Wellness':
    default:
      return 'Wellness Hub';
  }
}

String _pharmacyCampaignTitle(String category) {
  switch (category) {
    case 'Baby care':
      return 'Baby Care Picks';
    case 'Personal care':
      return 'Daily Care';
    case 'Essentials':
      return 'Health Essentials';
    case 'Wellness':
    default:
      return 'Wellness Boost';
  }
}

List<Color> _pharmacyCampaignColors(String category) {
  switch (category) {
    case 'Baby care':
      return const [Color(0xFFFFF1F5), Color(0xFFFDE7EE)];
    case 'Personal care':
      return const [Color(0xFFF0FBFE), Color(0xFFE8F3FF)];
    case 'Essentials':
      return const [Color(0xFFF5FBF7), Color(0xFFE6F4EE)];
    case 'Wellness':
    default:
      return const [Color(0xFFF7FAFF), Color(0xFFEFF7FF)];
  }
}

TextStyle _pharmacyCampaignTitleStyle(String category) {
  switch (category) {
    case 'Baby care':
      return const TextStyle(
        color: Color(0xFFB35C7A),
        fontSize: 18,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.2,
        fontStyle: FontStyle.italic,
        height: 0.92,
      );
    case 'Personal care':
      return const TextStyle(
        color: Color(0xFF267896),
        fontSize: 18,
        fontWeight: FontWeight.w900,
        height: 0.92,
      );
    case 'Essentials':
      return const TextStyle(
        color: Color(0xFF3E7F63),
        fontSize: 17.5,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        height: 0.92,
      );
    case 'Wellness':
    default:
      return const TextStyle(
        color: Color(0xFF316A97),
        fontSize: 17.5,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.35,
        height: 0.92,
      );
  }
}

Alignment _pharmacyCampaignTitleAlignment(String category) {
  switch (category) {
    case 'Baby care':
      return Alignment.centerLeft;
    case 'Personal care':
      return Alignment.center;
    case 'Essentials':
      return Alignment.centerRight;
    case 'Wellness':
    default:
      return Alignment.centerLeft;
  }
}

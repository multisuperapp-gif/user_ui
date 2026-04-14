part of '../../../main.dart';

class _GroceryCampaignSectionData {
  const _GroceryCampaignSectionData({
    required this.category,
    required this.title,
    required this.subtitle,
    required this.colors,
    required this.items,
  });

  final String category;
  final String title;
  final String subtitle;
  final List<Color> colors;
  final List<_DiscoveryItem> items;
}

class _GroceryMenuSectionData {
  const _GroceryMenuSectionData({
    required this.title,
    required this.items,
  });

  final String title;
  final List<_DiscoveryItem> items;
}

List<_DiscoveryItem> _sortedGroceryItems(List<_DiscoveryItem> items, String sortOption) {
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
        if (promotedCompare != 0) {
          return promotedCompare;
        }
        return (double.tryParse(right.rating) ?? 0).compareTo(double.tryParse(left.rating) ?? 0);
      });
  }
  return sorted;
}

List<_DiscoveryItem> _groceryItemsForCategory(String category, {String? shopName}) {
  final shop = shopName ?? _groceryDefaultShopFor(category);
  switch (category) {
    case 'Biscuits':
      return [
        _DiscoveryItem(title: 'Parle Crackjack', subtitle: shop, accent: const Color(0xFFD9A64A), icon: Icons.cookie_rounded, price: '₹35', rating: '4.5', extra: 'Promoted'),
        _DiscoveryItem(title: 'Marie Gold', subtitle: shop, accent: const Color(0xFFE5C25D), icon: Icons.cookie_rounded, price: '₹32', rating: '4.4'),
        _DiscoveryItem(title: 'Bourbon', subtitle: shop, accent: const Color(0xFF8F5C48), icon: Icons.cookie_rounded, price: '₹40', rating: '4.6'),
        _DiscoveryItem(title: 'Good Day', subtitle: shop, accent: const Color(0xFFC77D4A), icon: Icons.cookie_rounded, price: '₹30', rating: '4.3'),
        _DiscoveryItem(title: 'Treat Cream', subtitle: shop, accent: const Color(0xFFDA6E6D), icon: Icons.cookie_rounded, price: '₹25', rating: '4.2'),
        _DiscoveryItem(title: 'Oat Bites', subtitle: shop, accent: const Color(0xFF85A35B), icon: Icons.breakfast_dining_rounded, price: '₹49', rating: '4.1'),
        _DiscoveryItem(title: 'Salt Cracker', subtitle: shop, accent: const Color(0xFF8895B5), icon: Icons.cookie_rounded, price: '₹38', rating: '4.0'),
        _DiscoveryItem(title: 'Choco Chip', subtitle: shop, accent: const Color(0xFF7A614E), icon: Icons.cookie_rounded, price: '₹55', rating: '4.6'),
      ];
    case 'Noodles':
      return [
        _DiscoveryItem(title: 'Maggi 2-Minute', subtitle: shop, accent: const Color(0xFFF2B030), icon: Icons.ramen_dining_rounded, price: '₹18', rating: '4.7', extra: 'Promoted'),
        _DiscoveryItem(title: 'Yippee Noodles', subtitle: shop, accent: const Color(0xFFE56B52), icon: Icons.ramen_dining_rounded, price: '₹20', rating: '4.4'),
        _DiscoveryItem(title: 'Cup Noodles', subtitle: shop, accent: const Color(0xFFE8914E), icon: Icons.lunch_dining_rounded, price: '₹45', rating: '4.3'),
        _DiscoveryItem(title: 'Pasta Elbows', subtitle: shop, accent: const Color(0xFFDE9A58), icon: Icons.set_meal_rounded, price: '₹62', rating: '4.1'),
        _DiscoveryItem(title: 'Masala Pasta', subtitle: shop, accent: const Color(0xFFC65A4F), icon: Icons.set_meal_rounded, price: '₹39', rating: '4.2'),
        _DiscoveryItem(title: 'Schezwan Noodles', subtitle: shop, accent: const Color(0xFFBA5043), icon: Icons.ramen_dining_rounded, price: '₹36', rating: '4.5'),
        _DiscoveryItem(title: 'Vermicelli', subtitle: shop, accent: const Color(0xFFE0C57D), icon: Icons.soup_kitchen_rounded, price: '₹28', rating: '4.0'),
        _DiscoveryItem(title: 'Macaroni', subtitle: shop, accent: const Color(0xFFD38F60), icon: Icons.set_meal_rounded, price: '₹52', rating: '4.1'),
      ];
    case 'Rice':
      return [
        _DiscoveryItem(title: 'Basmati Rice', subtitle: shop, accent: const Color(0xFFE1CF8A), icon: Icons.rice_bowl_rounded, price: '₹149', rating: '4.6', extra: 'Promoted'),
        _DiscoveryItem(title: 'Sona Masoori', subtitle: shop, accent: const Color(0xFFEAD7A3), icon: Icons.rice_bowl_rounded, price: '₹119', rating: '4.4'),
        _DiscoveryItem(title: 'Daily Rice', subtitle: shop, accent: const Color(0xFFC9B36E), icon: Icons.rice_bowl_rounded, price: '₹89', rating: '4.2'),
        _DiscoveryItem(title: 'Brown Rice', subtitle: shop, accent: const Color(0xFFAB8D5B), icon: Icons.rice_bowl_rounded, price: '₹169', rating: '4.3'),
        _DiscoveryItem(title: 'Poha', subtitle: shop, accent: const Color(0xFFE9D79A), icon: Icons.breakfast_dining_rounded, price: '₹55', rating: '4.1'),
        _DiscoveryItem(title: 'Daliya', subtitle: shop, accent: const Color(0xFFC8B072), icon: Icons.breakfast_dining_rounded, price: '₹48', rating: '4.0'),
        _DiscoveryItem(title: 'Atta Flour', subtitle: shop, accent: const Color(0xFFDDC27F), icon: Icons.bakery_dining_rounded, price: '₹219', rating: '4.5'),
        _DiscoveryItem(title: 'Toor Dal', subtitle: shop, accent: const Color(0xFFE8C05A), icon: Icons.lunch_dining_rounded, price: '₹129', rating: '4.2'),
      ];
    case 'Chips':
      return [
        _DiscoveryItem(title: 'Classic Chips', subtitle: shop, accent: const Color(0xFFF0B03C), icon: Icons.fastfood_rounded, price: '₹20', rating: '4.5', extra: 'Promoted'),
        _DiscoveryItem(title: 'Masala Chips', subtitle: shop, accent: const Color(0xFFE97E3A), icon: Icons.fastfood_rounded, price: '₹22', rating: '4.3'),
        _DiscoveryItem(title: 'Nacho Crunch', subtitle: shop, accent: const Color(0xFFE55B4D), icon: Icons.fastfood_rounded, price: '₹35', rating: '4.2'),
        _DiscoveryItem(title: 'Salted Peanuts', subtitle: shop, accent: const Color(0xFFBE8A58), icon: Icons.lunch_dining_rounded, price: '₹28', rating: '4.1'),
        _DiscoveryItem(title: 'Roasted Mix', subtitle: shop, accent: const Color(0xFF82A35F), icon: Icons.rice_bowl_rounded, price: '₹48', rating: '4.0'),
        _DiscoveryItem(title: 'Party Namkeen', subtitle: shop, accent: const Color(0xFFDF7B2F), icon: Icons.fastfood_rounded, price: '₹52', rating: '4.4'),
        _DiscoveryItem(title: 'Corn Rings', subtitle: shop, accent: const Color(0xFFF0C053), icon: Icons.fastfood_rounded, price: '₹25', rating: '4.2'),
        _DiscoveryItem(title: 'Spicy Sticks', subtitle: shop, accent: const Color(0xFFB95142), icon: Icons.fastfood_rounded, price: '₹30', rating: '4.1'),
      ];
    case 'Household':
    default:
      return [
        _DiscoveryItem(title: 'Dishwash Gel', subtitle: shop, accent: const Color(0xFF66A8D6), icon: Icons.cleaning_services_rounded, price: '₹99', rating: '4.5', extra: 'Promoted'),
        _DiscoveryItem(title: 'Toilet Cleaner', subtitle: shop, accent: const Color(0xFF4CA06B), icon: Icons.clean_hands_rounded, price: '₹129', rating: '4.3'),
        _DiscoveryItem(title: 'Liquid Detergent', subtitle: shop, accent: const Color(0xFF5B8FE2), icon: Icons.local_laundry_service_rounded, price: '₹199', rating: '4.4'),
        _DiscoveryItem(title: 'Floor Cleaner', subtitle: shop, accent: const Color(0xFF71B08F), icon: Icons.cleaning_services_rounded, price: '₹155', rating: '4.1'),
        _DiscoveryItem(title: 'Tissue Roll', subtitle: shop, accent: const Color(0xFFD7C8A0), icon: Icons.receipt_long_rounded, price: '₹78', rating: '4.0'),
        _DiscoveryItem(title: 'Trash Bags', subtitle: shop, accent: const Color(0xFF808892), icon: Icons.delete_outline_rounded, price: '₹65', rating: '4.2'),
        _DiscoveryItem(title: 'Hand Wash', subtitle: shop, accent: const Color(0xFFE58FA0), icon: Icons.soap_rounded, price: '₹89', rating: '4.3'),
        _DiscoveryItem(title: 'Scrub Sponge', subtitle: shop, accent: const Color(0xFFEEB96E), icon: Icons.cleaning_services_rounded, price: '₹39', rating: '4.0'),
      ];
  }
}

String _groceryDefaultShopFor(String category) {
  switch (category) {
    case 'Biscuits':
      return 'Chai Time Store';
    case 'Noodles':
      return 'Quick Basket';
    case 'Rice':
      return 'Staples Mart';
    case 'Chips':
      return 'Crunchy Corner';
    case 'Household':
    default:
      return 'Home Essentials';
  }
}

String _groceryCampaignTitle(String category) {
  switch (category) {
    case 'Biscuits':
      return 'Chai Time Campaign';
    case 'Noodles':
      return 'Top Deals';
    case 'Rice':
      return 'Daily Staples';
    case 'Chips':
      return 'Crunchy Snacks';
    case 'Household':
    default:
      return 'Household Essentials';
  }
}

String _groceryCampaignSubtitle(String category) {
  switch (category) {
    case 'Biscuits':
      return 'Tea-time biscuit picks from nearby shops';
    case 'Noodles':
      return 'Instant picks sorted by promotion and rating';
    case 'Rice':
      return 'Family staples loaded category by category';
    case 'Chips':
      return 'Party snacks and quick munching picks';
    case 'Household':
    default:
      return 'Cleaning and refill products for home';
  }
}

List<Color> _groceryCampaignColors(String category) {
  switch (category) {
    case 'Biscuits':
      return const [Color(0xFFFFF3D9), Color(0xFFFFE7B2)];
    case 'Noodles':
      return const [Color(0xFFFFF0EB), Color(0xFFFFD8C8)];
    case 'Rice':
      return const [Color(0xFFFFF8DF), Color(0xFFF3EDC4)];
    case 'Chips':
      return const [Color(0xFFFFF0D7), Color(0xFFFFD9A0)];
    case 'Household':
    default:
      return const [Color(0xFFEFF8FF), Color(0xFFE4F2E9)];
  }
}

TextStyle _groceryCampaignTitleStyle(String category) {
  switch (category) {
    case 'Biscuits':
      return const TextStyle(
        color: Color(0xFF6E4A1D),
        fontSize: 18,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.2,
        fontStyle: FontStyle.italic,
        height: 0.92,
      );
    case 'Noodles':
      return const TextStyle(
        color: Color(0xFFB74B2D),
        fontSize: 18,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.1,
        height: 0.92,
      );
    case 'Rice':
      return const TextStyle(
        color: Color(0xFF8F6A22),
        fontSize: 17.5,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.9,
        height: 0.92,
      );
    case 'Chips':
      return const TextStyle(
        color: Color(0xFFCC5A18),
        fontSize: 18.5,
        fontWeight: FontWeight.w900,
        height: 0.9,
        shadows: [
          Shadow(
            color: Color(0x33FFFFFF),
            offset: Offset(0, 1),
            blurRadius: 0,
          ),
        ],
      );
    case 'Household':
    default:
      return const TextStyle(
        color: Color(0xFF2E5C79),
        fontSize: 17.5,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.35,
        height: 0.92,
      );
  }
}

Alignment _groceryCampaignTitleAlignment(String category) {
  switch (category) {
    case 'Biscuits':
      return Alignment.centerLeft;
    case 'Noodles':
      return Alignment.center;
    case 'Rice':
      return Alignment.centerRight;
    case 'Chips':
      return Alignment.centerLeft;
    case 'Household':
    default:
      return Alignment.center;
  }
}

List<_DiscoveryItem> get _groceryShopWiseSeeds => const [
      _DiscoveryItem(
        title: 'Chai Time Store',
        subtitle: 'Groceries',
        accent: Color(0xFFE7B95B),
        icon: Icons.storefront_rounded,
        rating: '4.6',
        distance: '1.1 km',
      ),
      _DiscoveryItem(
        title: 'Quick Basket',
        subtitle: 'Groceries',
        accent: Color(0xFFE97E3A),
        icon: Icons.storefront_rounded,
        rating: '4.4',
        distance: '1.4 km',
      ),
      _DiscoveryItem(
        title: 'Staples Mart',
        subtitle: 'Groceries',
        accent: Color(0xFFD8BF6A),
        icon: Icons.storefront_rounded,
        rating: '4.5',
        distance: '1.8 km',
      ),
      _DiscoveryItem(
        title: 'Home Essentials',
        subtitle: 'Groceries',
        accent: Color(0xFF67A3D3),
        icon: Icons.storefront_rounded,
        rating: '4.3',
        distance: '2.0 km',
      ),
    ];

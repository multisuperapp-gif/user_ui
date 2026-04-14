part of '../../main.dart';

enum _HomeMode { all, labour, service, shop }

enum _LabourViewMode { individual, group }
enum _ShopBrowseMode { itemWise, shopWise }

class _DiscoveryItem {
  const _DiscoveryItem({
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.icon,
    this.price = '',
    this.rating = '4.7',
    this.distance = '1.8 km',
    this.extra = '',
    this.maskedPhone = '98xxxxxx21',
    this.shopCategory,
    this.backendProductId,
    this.backendVariantId,
    this.backendShopId,
    this.backendLabourId,
    this.backendServiceProviderId,
    this.backendCategoryId,
    this.backendSubcategoryId,
  });

  final String title;
  final String subtitle;
  final Color accent;
  final IconData icon;
  final String price;
  final String rating;
  final String distance;
  final String extra;
  final String maskedPhone;
  final String? shopCategory;
  final int? backendProductId;
  final int? backendVariantId;
  final int? backendShopId;
  final int? backendLabourId;
  final int? backendServiceProviderId;
  final int? backendCategoryId;
  final int? backendSubcategoryId;
}

class _DiscoverySection {
  const _DiscoverySection({
    required this.title,
    required this.caption,
    required this.items,
  });

  final String title;
  final String caption;
  final List<_DiscoveryItem> items;
}

class _AllQuickCategoryItem {
  const _AllQuickCategoryItem({
    required this.label,
    required this.accent,
    required this.icon,
  });

  final String label;
  final Color accent;
  final IconData icon;
}

class _GiftOccasionItem {
  const _GiftOccasionItem({
    required this.label,
    required this.imageKey,
    required this.accent,
    required this.icon,
  });

  final String label;
  final String imageKey;
  final Color accent;
  final IconData icon;
}

class _GiftFavouriteTileItem {
  const _GiftFavouriteTileItem({
    required this.label,
    required this.imageKey,
    required this.accent,
    required this.icon,
  });

  final String label;
  final String imageKey;
  final Color accent;
  final IconData icon;
}

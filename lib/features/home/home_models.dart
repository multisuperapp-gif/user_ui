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
    this.isDisabled = false,
    this.disabledLabel = '',
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
  final bool isDisabled;
  final String disabledLabel;
}

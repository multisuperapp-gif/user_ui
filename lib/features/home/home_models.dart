part of '../../main.dart';

enum _HomeMode { all, labour, service, shop }

enum _LabourViewMode { individual, group }
enum _ShopBrowseMode { itemWise, shopWise }

class _LabourCategoryPricing {
  const _LabourCategoryPricing({
    required this.categoryId,
    required this.label,
    this.halfDayPrice = '',
    this.fullDayPrice = '',
  });

  final int? categoryId;
  final String label;
  final String halfDayPrice;
  final String fullDayPrice;
}

class _DiscoveryItem {
  const _DiscoveryItem({
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.icon,
    this.price = '',
    this.rating = '',
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
    this.profileImageUrl = '',
    this.isDisabled = false,
    this.disabledLabel = '',
    this.labourHalfDayPrice = '',
    this.labourFullDayPrice = '',
    this.labourCategoryPricing = const [],
    this.experienceYears,
    this.completedJobsCount,
    this.labourRadiusKm,
    this.labourWorkLatitude,
    this.labourWorkLongitude,
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
  final String profileImageUrl;
  final bool isDisabled;
  final String disabledLabel;
  final String labourHalfDayPrice;
  final String labourFullDayPrice;
  final List<_LabourCategoryPricing> labourCategoryPricing;
  final int? experienceYears;
  final int? completedJobsCount;
  final double? labourRadiusKm;
  final double? labourWorkLatitude;
  final double? labourWorkLongitude;

  bool get hasRating {
    final parsed = double.tryParse(rating.trim());
    return parsed != null && parsed > 0;
  }

  _DiscoveryItem copyWith({
    String? title,
    String? subtitle,
    Color? accent,
    IconData? icon,
    String? price,
    String? rating,
    String? distance,
    String? extra,
    String? maskedPhone,
    String? shopCategory,
    int? backendProductId,
    int? backendVariantId,
    int? backendShopId,
    int? backendLabourId,
    int? backendServiceProviderId,
    int? backendCategoryId,
    int? backendSubcategoryId,
    String? profileImageUrl,
    bool? isDisabled,
    String? disabledLabel,
    String? labourHalfDayPrice,
    String? labourFullDayPrice,
    List<_LabourCategoryPricing>? labourCategoryPricing,
    int? experienceYears,
    int? completedJobsCount,
    double? labourRadiusKm,
    double? labourWorkLatitude,
    double? labourWorkLongitude,
  }) {
    return _DiscoveryItem(
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      accent: accent ?? this.accent,
      icon: icon ?? this.icon,
      price: price ?? this.price,
      rating: rating ?? this.rating,
      distance: distance ?? this.distance,
      extra: extra ?? this.extra,
      maskedPhone: maskedPhone ?? this.maskedPhone,
      shopCategory: shopCategory ?? this.shopCategory,
      backendProductId: backendProductId ?? this.backendProductId,
      backendVariantId: backendVariantId ?? this.backendVariantId,
      backendShopId: backendShopId ?? this.backendShopId,
      backendLabourId: backendLabourId ?? this.backendLabourId,
      backendServiceProviderId: backendServiceProviderId ?? this.backendServiceProviderId,
      backendCategoryId: backendCategoryId ?? this.backendCategoryId,
      backendSubcategoryId: backendSubcategoryId ?? this.backendSubcategoryId,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      isDisabled: isDisabled ?? this.isDisabled,
      disabledLabel: disabledLabel ?? this.disabledLabel,
      labourHalfDayPrice: labourHalfDayPrice ?? this.labourHalfDayPrice,
      labourFullDayPrice: labourFullDayPrice ?? this.labourFullDayPrice,
      labourCategoryPricing: labourCategoryPricing ?? this.labourCategoryPricing,
      experienceYears: experienceYears ?? this.experienceYears,
      completedJobsCount: completedJobsCount ?? this.completedJobsCount,
      labourRadiusKm: labourRadiusKm ?? this.labourRadiusKm,
      labourWorkLatitude: labourWorkLatitude ?? this.labourWorkLatitude,
      labourWorkLongitude: labourWorkLongitude ?? this.labourWorkLongitude,
    );
  }
}

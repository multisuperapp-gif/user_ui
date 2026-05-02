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

class _ServicePricingOption {
  const _ServicePricingOption({
    required this.categoryId,
    required this.subcategoryId,
    required this.categoryName,
    required this.subcategoryName,
    required this.visitingChargeLabel,
  });

  final int? categoryId;
  final int? subcategoryId;
  final String categoryName;
  final String subcategoryName;
  final String visitingChargeLabel;
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
    this.promoted = false,
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
    this.serviceLatitude,
    this.serviceLongitude,
    this.serviceItems = const [],
    this.serviceTileLabel = '',
    this.serviceOptions = const [],
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
  final bool promoted;
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
  final double? serviceLatitude;
  final double? serviceLongitude;
  final List<String> serviceItems;
  final String serviceTileLabel;
  final List<_ServicePricingOption> serviceOptions;

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
    bool? promoted,
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
    double? serviceLatitude,
    double? serviceLongitude,
    List<String>? serviceItems,
    String? serviceTileLabel,
    List<_ServicePricingOption>? serviceOptions,
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
      backendServiceProviderId:
          backendServiceProviderId ?? this.backendServiceProviderId,
      backendCategoryId: backendCategoryId ?? this.backendCategoryId,
      backendSubcategoryId: backendSubcategoryId ?? this.backendSubcategoryId,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      promoted: promoted ?? this.promoted,
      isDisabled: isDisabled ?? this.isDisabled,
      disabledLabel: disabledLabel ?? this.disabledLabel,
      labourHalfDayPrice: labourHalfDayPrice ?? this.labourHalfDayPrice,
      labourFullDayPrice: labourFullDayPrice ?? this.labourFullDayPrice,
      labourCategoryPricing:
          labourCategoryPricing ?? this.labourCategoryPricing,
      experienceYears: experienceYears ?? this.experienceYears,
      completedJobsCount: completedJobsCount ?? this.completedJobsCount,
      labourRadiusKm: labourRadiusKm ?? this.labourRadiusKm,
      labourWorkLatitude: labourWorkLatitude ?? this.labourWorkLatitude,
      labourWorkLongitude: labourWorkLongitude ?? this.labourWorkLongitude,
      serviceLatitude: serviceLatitude ?? this.serviceLatitude,
      serviceLongitude: serviceLongitude ?? this.serviceLongitude,
      serviceItems: serviceItems ?? this.serviceItems,
      serviceTileLabel: serviceTileLabel ?? this.serviceTileLabel,
      serviceOptions: serviceOptions ?? this.serviceOptions,
    );
  }
}

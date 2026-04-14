part of '../../main.dart';

class _RemoteServiceSubcategory {
  const _RemoteServiceSubcategory({
    required this.label,
    this.backendSubcategoryId,
  });

  final String label;
  final int? backendSubcategoryId;
}

class _RemoteServiceCategory {
  const _RemoteServiceCategory({
    required this.label,
    required this.subcategories,
    this.backendCategoryId,
  });

  final String label;
  final int? backendCategoryId;
  final List<_RemoteServiceSubcategory> subcategories;
}

class _RemoteServiceLandingData {
  const _RemoteServiceLandingData({
    required this.categories,
    required this.providers,
  });

  final List<_RemoteServiceCategory> categories;
  final List<_DiscoveryItem> providers;
}

class _RemoteServiceBookingResult {
  const _RemoteServiceBookingResult({
    required this.bookingId,
    required this.bookingCode,
    required this.paymentId,
    required this.paymentCode,
    required this.payableAmount,
    required this.providerName,
    required this.serviceName,
  });

  final int bookingId;
  final String bookingCode;
  final int paymentId;
  final String paymentCode;
  final String payableAmount;
  final String providerName;
  final String serviceName;
}

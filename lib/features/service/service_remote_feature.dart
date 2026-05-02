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

class _RemoteServiceProviderProfile {
  const _RemoteServiceProviderProfile({
    required this.provider,
    required this.serviceItems,
    required this.serviceOptions,
  });

  final _DiscoveryItem provider;
  final List<String> serviceItems;
  final List<_ServicePricingOption> serviceOptions;
}

class _RemoteServiceBookingResult {
  const _RemoteServiceBookingResult({
    required this.requestId,
    required this.requestCode,
    required this.requestStatus,
    required this.quotedPriceAmount,
    required this.providerName,
    required this.serviceName,
    required this.isBroadcast,
    required this.requestedProviderCount,
  });

  final int requestId;
  final String requestCode;
  final String requestStatus;
  final String quotedPriceAmount;
  final String providerName;
  final String serviceName;
  final bool isBroadcast;
  final int requestedProviderCount;
}

class _RemoteServiceBookingRequestStatus {
  const _RemoteServiceBookingRequestStatus({
    required this.requestId,
    required this.requestCode,
    required this.requestStatus,
    required this.providerName,
    required this.providerPhone,
    required this.quotedPriceAmount,
    required this.distanceLabel,
    required this.bookingId,
    required this.bookingCode,
    required this.bookingStatus,
    required this.paymentStatus,
    required this.canMakePayment,
    required this.requestedProviderCount,
    required this.acceptedProviderCount,
    required this.acceptedProviders,
    required this.pendingProviderCount,
  });

  final int requestId;
  final String requestCode;
  final String requestStatus;
  final String providerName;
  final String providerPhone;
  final String quotedPriceAmount;
  final String distanceLabel;
  final int bookingId;
  final String bookingCode;
  final String bookingStatus;
  final String paymentStatus;
  final bool canMakePayment;
  final int requestedProviderCount;
  final int acceptedProviderCount;
  final List<_RemoteAcceptedProvider> acceptedProviders;
  final int pendingProviderCount;
}

class _RemoteServiceBookingPaymentResult {
  const _RemoteServiceBookingPaymentResult({
    required this.bookingId,
    required this.bookingCode,
    required this.paymentCode,
    required this.amountLabel,
    required this.currencyCode,
  });

  final int bookingId;
  final String bookingCode;
  final String paymentCode;
  final String amountLabel;
  final String currencyCode;
}

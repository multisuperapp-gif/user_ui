part of '../../main.dart';

class _RemoteLabourCategory {
  const _RemoteLabourCategory({
    required this.label,
    this.backendCategoryId,
  });

  final String label;
  final int? backendCategoryId;
}

class _RemoteLabourLandingData {
  const _RemoteLabourLandingData({
    required this.categories,
    required this.profiles,
  });

  final List<_RemoteLabourCategory> categories;
  final List<_DiscoveryItem> profiles;
}

class _RemoteLabourBookingPolicy {
  const _RemoteLabourBookingPolicy({
    required this.bookingChargePerLabour,
    required this.currencyCode,
    required this.maxGroupLabourCount,
  });

  final String bookingChargePerLabour;
  final String currencyCode;
  final int maxGroupLabourCount;
}

class _RemoteLabourBookingResult {
  const _RemoteLabourBookingResult({
    required this.requestId,
    required this.requestCode,
    required this.requestStatus,
    required this.quotedPriceAmount,
    required this.labourName,
  });

  final int requestId;
  final String requestCode;
  final String requestStatus;
  final String quotedPriceAmount;
  final String labourName;
}

class _RemoteLabourBookingRequestStatus {
  const _RemoteLabourBookingRequestStatus({
    required this.requestId,
    required this.requestCode,
    required this.requestStatus,
    required this.providerName,
    required this.providerPhone,
    required this.quotedPriceAmount,
    required this.totalAcceptedQuotedPriceAmount,
    required this.totalAcceptedBookingChargeAmount,
    required this.distanceLabel,
    required this.requestedProviderCount,
    required this.acceptedProviderCount,
    required this.pendingProviderCount,
    required this.bookingId,
    required this.bookingCode,
    required this.bookingStatus,
    required this.paymentStatus,
    required this.canMakePayment,
  });

  final int requestId;
  final String requestCode;
  final String requestStatus;
  final String providerName;
  final String providerPhone;
  final String quotedPriceAmount;
  final String totalAcceptedQuotedPriceAmount;
  final String totalAcceptedBookingChargeAmount;
  final String distanceLabel;
  final int requestedProviderCount;
  final int acceptedProviderCount;
  final int pendingProviderCount;
  final int bookingId;
  final String bookingCode;
  final String bookingStatus;
  final String paymentStatus;
  final bool canMakePayment;
}

class _RemoteLabourBookingPaymentResult {
  const _RemoteLabourBookingPaymentResult({
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

class _RemoteLabourGroupBookingResult {
  const _RemoteLabourGroupBookingResult({
    required this.requestId,
    required this.requestCode,
    required this.availableCandidates,
    required this.requestedCount,
    required this.bookingChargePerLabour,
    required this.estimatedLabourAmount,
    required this.platformAmountDue,
  });

  final int requestId;
  final String requestCode;
  final int availableCandidates;
  final int requestedCount;
  final String bookingChargePerLabour;
  final String estimatedLabourAmount;
  final String platformAmountDue;
}

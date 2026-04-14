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

class _RemoteLabourBookingResult {
  const _RemoteLabourBookingResult({
    required this.bookingId,
    required this.bookingCode,
    required this.paymentId,
    required this.paymentCode,
    required this.payableAmount,
    required this.labourName,
  });

  final int bookingId;
  final String bookingCode;
  final int paymentId;
  final String paymentCode;
  final String payableAmount;
  final String labourName;
}

class _RemoteLabourGroupBookingResult {
  const _RemoteLabourGroupBookingResult({
    required this.requestId,
    required this.requestCode,
    required this.availableCandidates,
    required this.requestedCount,
    required this.platformAmountDue,
  });

  final int requestId;
  final String requestCode;
  final int availableCandidates;
  final int requestedCount;
  final String platformAmountDue;
}

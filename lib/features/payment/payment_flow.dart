part of '../../main.dart';

class _PaymentFlowResult {
  const _PaymentFlowResult({
    required this.success,
    required this.cancelled,
    required this.message,
    this.status,
  });

  final bool success;
  final bool cancelled;
  final String message;
  final _PaymentStatusData? status;
}

class _PaymentFlow {
  static const List<String> _pendingStatuses = <String>[
    'INITIATED',
    'PENDING',
  ];

  static Future<_PaymentFlowResult> start(
    BuildContext context, {
    required String paymentCode,
    required String title,
  }) async {
    try {
      final initiation = await _UserAppApi.initiatePayment(paymentCode);
      if (initiation.gatewayKeyId.isEmpty || initiation.gatewayOrderId.isEmpty) {
        throw const _UserAppApiException(
          'Payment gateway is not ready right now. Please try again shortly.',
        );
      }

      final phoneNumber = await _LocalSessionStore.readPhoneNumber();
      final completer = Completer<_PaymentFlowResult>();
      final razorpay = Razorpay();
      var finished = false;

      Future<void> finish(_PaymentFlowResult result) async {
        if (finished) {
          return;
        }
        finished = true;
        razorpay.clear();
        if (!completer.isCompleted) {
          completer.complete(result);
        }
      }

      razorpay.on(
        Razorpay.EVENT_PAYMENT_SUCCESS,
        (dynamic raw) async {
          final response = raw is PaymentSuccessResponse ? raw : null;
          try {
            final verifiedStatus = await _UserAppApi.verifyPayment(
              paymentCode,
              gatewayOrderId: response?.orderId?.trim().isNotEmpty == true
                  ? response!.orderId!
                  : initiation.gatewayOrderId,
              gatewayPaymentId: response?.paymentId ?? '',
              razorpaySignature: response?.signature ?? '',
            );
            final status = await _resolveStableStatus(
              paymentCode,
              preferredStatus: verifiedStatus,
            );
            await finish(
              _PaymentFlowResult(
                success: status.isSuccess,
                cancelled: false,
                message: status.isSuccess
                    ? 'Payment completed successfully.'
                    : _pendingStatuses.contains(status.paymentStatus.trim().toUpperCase())
                        ? 'Payment confirmation is still in progress. We will keep the latest status in your orders.'
                        : 'Payment was verified, but the final status is ${status.paymentStatus}.',
                status: status,
              ),
            );
          } on _UserAppApiException catch (error) {
            final status = await _tryFetchStableStatus(paymentCode);
            await finish(
              _PaymentFlowResult(
                success: status?.isSuccess == true,
                cancelled: false,
                message: status?.isSuccess == true
                    ? 'Payment completed successfully.'
                    : status == null
                        ? error.message
                        : _pendingStatuses.contains(status.paymentStatus.trim().toUpperCase())
                            ? 'Payment confirmation is still in progress. We will keep the latest status in your orders.'
                            : error.message,
                status: status,
              ),
            );
          }
        },
      );

      razorpay.on(
        Razorpay.EVENT_PAYMENT_ERROR,
        (dynamic raw) async {
          final response = raw is PaymentFailureResponse ? raw : null;
          try {
            final failedStatus = await _UserAppApi.failPayment(
              paymentCode,
              gatewayOrderId: initiation.gatewayOrderId,
              failureCode: '${response?.code ?? 'PAYMENT_FAILED'}',
              failureMessage: response?.message ?? 'Payment was not completed.',
            );
            final status = await _resolveStableStatus(
              paymentCode,
              preferredStatus: failedStatus,
            );
            final isPending = _pendingStatuses.contains(status.paymentStatus.trim().toUpperCase());
            await finish(
              _PaymentFlowResult(
                success: status.isSuccess,
                cancelled: !status.isSuccess && !isPending,
                message: status.isSuccess
                    ? 'Payment completed successfully.'
                    : isPending
                        ? 'Payment confirmation is still in progress. Please check the latest status in your orders.'
                        : response?.message?.trim().isNotEmpty == true
                            ? response!.message!
                            : 'Payment was not completed.',
                status: status,
              ),
            );
          } on _UserAppApiException catch (error) {
            final status = await _tryFetchStableStatus(paymentCode);
            await finish(
              _PaymentFlowResult(
                success: status?.isSuccess == true,
                cancelled: status == null || !_pendingStatuses.contains(status.paymentStatus.trim().toUpperCase()),
                message: status?.isSuccess == true
                    ? 'Payment completed successfully.'
                    : status != null && _pendingStatuses.contains(status.paymentStatus.trim().toUpperCase())
                        ? 'Payment confirmation is still in progress. Please check the latest status in your orders.'
                        : error.message,
                status: status,
              ),
            );
          }
        },
      );

      razorpay.on(
        Razorpay.EVENT_EXTERNAL_WALLET,
        (dynamic _) {},
      );

      razorpay.open(
        <String, Object?>{
          'key': initiation.gatewayKeyId,
          'amount': initiation.amountMinorUnits,
          'currency': initiation.currencyCode,
          'name': 'Multi Super App',
          'description': title,
          'order_id': initiation.gatewayOrderId,
          'prefill': <String, Object?>{
            if ((phoneNumber ?? '').trim().isNotEmpty) 'contact': phoneNumber!.trim(),
          },
          'theme': <String, Object?>{
            'color': '#CB6E5B',
          },
          'retry': <String, Object?>{
            'enabled': true,
            'max_count': 1,
          },
          'send_sms_hash': true,
        },
      );

      return completer.future.timeout(
        const Duration(minutes: 10),
        onTimeout: () async {
          try {
            final status = await _resolveStableStatus(paymentCode);
            final isPending = _pendingStatuses.contains(status.paymentStatus.trim().toUpperCase());
            return _PaymentFlowResult(
              success: status.isSuccess,
              cancelled: !status.isSuccess && !isPending,
              message: status.isSuccess
                  ? 'Payment completed successfully.'
                  : isPending
                      ? 'Payment confirmation is still in progress. Please check the latest status in your orders.'
                      : 'Payment session timed out.',
              status: status,
            );
          } on _UserAppApiException catch (error) {
            return _PaymentFlowResult(
              success: false,
              cancelled: true,
              message: error.message,
            );
          } finally {
            razorpay.clear();
          }
        },
      );
    } on _UserAppApiException catch (error) {
      return _PaymentFlowResult(
        success: false,
        cancelled: false,
        message: error.message,
      );
    }
  }

  static Future<_PaymentStatusData> _resolveStableStatus(
    String paymentCode, {
    _PaymentStatusData? preferredStatus,
  }) async {
    var status = preferredStatus ?? await _UserAppApi.fetchPaymentStatus(paymentCode);
    for (int attempt = 0; attempt < 3; attempt++) {
      if (!_pendingStatuses.contains(status.paymentStatus.trim().toUpperCase())) {
        return status;
      }
      await Future<void>.delayed(const Duration(seconds: 2));
      status = await _UserAppApi.fetchPaymentStatus(paymentCode);
    }
    return status;
  }

  static Future<_PaymentStatusData?> _tryFetchStableStatus(String paymentCode) async {
    try {
      return await _resolveStableStatus(paymentCode);
    } on _UserAppApiException {
      return null;
    }
  }

  static Future<void> showOutcome(
    BuildContext context, {
    required _PaymentFlowResult result,
    required String successTitle,
    required String failureTitle,
    List<String> extraLines = const <String>[],
  }) async {
    final title = result.success ? successTitle : failureTitle;
    final accent = result.success ? const Color(0xFF1F8F53) : const Color(0xFFCB6E5B);
    final lines = <String>[
      result.message,
      ...extraLines.where((line) => line.trim().isNotEmpty),
      if ((result.status?.paymentCode ?? '').isNotEmpty)
        'Payment code: ${result.status!.paymentCode}',
      if ((result.status?.paymentStatus ?? '').isNotEmpty)
        'Status: ${result.status!.paymentStatus}',
    ];
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          title,
          style: TextStyle(
            color: accent,
            fontWeight: FontWeight.w900,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: lines
              .map(
                (line) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    line,
                    style: const TextStyle(
                      color: Color(0xFF22314D),
                      fontWeight: FontWeight.w700,
                      height: 1.4,
                    ),
                  ),
                ),
              )
              .toList(growable: false),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text(
              'Close',
              style: TextStyle(
                color: Color(0xFFCB6E5B),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

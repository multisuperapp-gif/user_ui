part of '../../main.dart';

class _PaymentFlowResult {
  const _PaymentFlowResult({
    required this.success,
    required this.cancelled,
    required this.message,
    this.status,
    this.verificationPending = false,
  });

  final bool success;
  final bool cancelled;
  final String message;
  final _PaymentStatusData? status;
  final bool verificationPending;
}

class _PreparedPaymentFlowResult<T> {
  const _PreparedPaymentFlowResult({
    required this.prepared,
    required this.result,
  });

  final T prepared;
  final _PaymentFlowResult result;
}

class _PaymentFlow {
  static const List<String> _pendingStatuses = <String>['INITIATED', 'PENDING'];
  static const String _pendingVerificationMessage =
      "Payment verification is still in progress. We're verifying your payment and will update this shortly.";

  static Future<_PreparedPaymentFlowResult<T>> prepareAndStart<T>(
    BuildContext context, {
    required Future<T> Function() prepare,
    required String Function(T prepared) paymentCode,
    required String title,
  }) async {
    var redirectingDialogVisible = false;
    try {
      await _showBlockingPaymentDialog(
        context,
        title: 'Opening secure payment',
        message: 'Preparing your Razorpay checkout. Please wait.',
        icon: Icons.lock_clock_rounded,
      );
      redirectingDialogVisible = true;
      final prepared = await prepare();
      if (!context.mounted) {
        await _hideBlockingPaymentDialog(
          context,
          isVisible: redirectingDialogVisible,
        );
        throw const _UserAppApiException(
          'Payment screen was closed before checkout opened.',
        );
      }
      final result = await start(
        context,
        paymentCode: paymentCode(prepared),
        title: title,
        redirectingDialogAlreadyVisible: redirectingDialogVisible,
      );
      redirectingDialogVisible = false;
      return _PreparedPaymentFlowResult<T>(prepared: prepared, result: result);
    } catch (_) {
      await _hideBlockingPaymentDialog(
        context,
        isVisible: redirectingDialogVisible,
      );
      rethrow;
    }
  }

  static Future<void> _showBlockingPaymentDialog(
    BuildContext context, {
    required String title,
    required String message,
    IconData icon = Icons.lock_rounded,
  }) async {
    if (!context.mounted) {
      return;
    }
    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        useRootNavigator: true,
        builder: (dialogContext) => PopScope(
          canPop: false,
          child: SafeArea(
            bottom: true,
            child: Material(
              color: Colors.white,
              child: SizedBox(
                width: double.infinity,
                height:
                    MediaQuery.of(dialogContext).size.height -
                    MediaQuery.of(dialogContext).padding.top,
                child: Column(
                  children: [
                    const SizedBox(
                      height: 10,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFFD84A4A),
                              Color(0xFFF2A13D),
                              Color(0xFF5C8FD8),
                              Color(0xFF2E8E45),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(28, 24, 28, 34),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 78,
                              height: 78,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFFF1EC),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                icon,
                                color: const Color(0xFFCB6E5B),
                                size: 38,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFF17233C),
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                height: 1.15,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              message,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFF526071),
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                height: 1.38,
                              ),
                            ),
                            const SizedBox(height: 34),
                            const SizedBox(
                              width: 48,
                              height: 48,
                              child: CircularProgressIndicator(
                                strokeWidth: 4,
                                color: Color(0xFFCB6E5B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 16));
  }

  static Future<void> _hideBlockingPaymentDialog(
    BuildContext context, {
    required bool isVisible,
  }) async {
    if (!isVisible || !context.mounted) {
      return;
    }
    final navigator = Navigator.of(context, rootNavigator: true);
    if (navigator.canPop()) {
      navigator.pop();
      await Future<void>.delayed(const Duration(milliseconds: 16));
    }
  }

  static Future<_PaymentFlowResult> start(
    BuildContext context, {
    required String paymentCode,
    required String title,
    bool redirectingDialogAlreadyVisible = false,
  }) async {
    var redirectingDialogVisible = redirectingDialogAlreadyVisible;
    var progressDialogVisible = false;
    try {
      if (!redirectingDialogVisible) {
        await _showBlockingPaymentDialog(
          context,
          title: 'Opening secure payment',
          message: 'Preparing your Razorpay checkout. Please wait.',
          icon: Icons.lock_clock_rounded,
        );
        redirectingDialogVisible = true;
      }
      final initiation = await _UserAppApi.initiatePayment(paymentCode);
      if (initiation.gatewayKeyId.isEmpty ||
          initiation.gatewayOrderId.isEmpty) {
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
        await _hideBlockingPaymentDialog(
          context,
          isVisible: progressDialogVisible,
        );
        progressDialogVisible = false;
        await _hideBlockingPaymentDialog(
          context,
          isVisible: redirectingDialogVisible,
        );
        redirectingDialogVisible = false;
        razorpay.clear();
        if (!completer.isCompleted) {
          completer.complete(result);
        }
      }

      razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, (dynamic raw) async {
        final response = raw is PaymentSuccessResponse ? raw : null;
        await _showBlockingPaymentDialog(
          context,
          title: 'Verifying payment',
          message:
              'Razorpay completed your payment. We are confirming it securely now.',
          icon: Icons.verified_user_outlined,
        );
        progressDialogVisible = true;
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
          final isPending = _pendingStatuses.contains(
            status.paymentStatus.trim().toUpperCase(),
          );
          await finish(
            _PaymentFlowResult(
              success: status.isSuccess,
              cancelled: false,
              message: status.isSuccess
                  ? 'Payment completed successfully.'
                  : isPending
                  ? _pendingVerificationMessage
                  : 'Payment was verified, but the final status is ${status.paymentStatus}.',
              status: status,
              verificationPending: isPending,
            ),
          );
        } on _UserAppApiException catch (error) {
          final status = await _tryFetchStableStatus(paymentCode);
          final isPending =
              status != null &&
              _pendingStatuses.contains(
                status.paymentStatus.trim().toUpperCase(),
              );
          await finish(
            _PaymentFlowResult(
              success: status?.isSuccess == true,
              cancelled: false,
              message: status?.isSuccess == true
                  ? 'Payment completed successfully.'
                  : status == null
                  ? error.message
                  : isPending
                  ? _pendingVerificationMessage
                  : error.message,
              status: status,
              verificationPending: isPending,
            ),
          );
        }
      });

      razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, (dynamic raw) async {
        final response = raw is PaymentFailureResponse ? raw : null;
        await _showBlockingPaymentDialog(
          context,
          title: 'Checking payment',
          message:
              'Checking the latest Razorpay status before updating your booking.',
          icon: Icons.manage_search_rounded,
        );
        progressDialogVisible = true;
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
          final isPending = _pendingStatuses.contains(
            status.paymentStatus.trim().toUpperCase(),
          );
          await finish(
            _PaymentFlowResult(
              success: status.isSuccess,
              cancelled: !status.isSuccess && !isPending,
              message: status.isSuccess
                  ? 'Payment completed successfully.'
                  : isPending
                  ? _pendingVerificationMessage
                  : response?.message?.trim().isNotEmpty == true
                  ? response!.message!
                  : 'Payment was not completed.',
              status: status,
              verificationPending: isPending,
            ),
          );
        } on _UserAppApiException catch (error) {
          final status = await _tryFetchStableStatus(paymentCode);
          final isPending =
              status != null &&
              _pendingStatuses.contains(
                status.paymentStatus.trim().toUpperCase(),
              );
          await finish(
            _PaymentFlowResult(
              success: status?.isSuccess == true,
              cancelled: status == null || !isPending,
              message: status?.isSuccess == true
                  ? 'Payment completed successfully.'
                  : isPending
                  ? _pendingVerificationMessage
                  : error.message,
              status: status,
              verificationPending: isPending,
            ),
          );
        }
      });

      razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, (dynamic _) {});

      await _hideBlockingPaymentDialog(
        context,
        isVisible: redirectingDialogVisible,
      );
      redirectingDialogVisible = false;
      razorpay.open(<String, Object?>{
        'key': initiation.gatewayKeyId,
        'amount': initiation.amountMinorUnits,
        'currency': initiation.currencyCode,
        'name': 'Multi Super App',
        'description': title,
        'order_id': initiation.gatewayOrderId,
        'prefill': <String, Object?>{
          if ((phoneNumber ?? '').trim().isNotEmpty)
            'contact': phoneNumber!.trim(),
        },
        'theme': <String, Object?>{'color': '#CB6E5B'},
        'retry': <String, Object?>{'enabled': true, 'max_count': 1},
        'send_sms_hash': true,
      });

      return completer.future.timeout(
        const Duration(minutes: 10),
        onTimeout: () async {
          try {
            final status = await _resolveStableStatus(paymentCode);
            final isPending = _pendingStatuses.contains(
              status.paymentStatus.trim().toUpperCase(),
            );
            return _PaymentFlowResult(
              success: status.isSuccess,
              cancelled: !status.isSuccess && !isPending,
              message: status.isSuccess
                  ? 'Payment completed successfully.'
                  : isPending
                  ? _pendingVerificationMessage
                  : 'Payment session timed out.',
              status: status,
              verificationPending: isPending,
            );
          } on _UserAppApiException catch (error) {
            return _PaymentFlowResult(
              success: false,
              cancelled: true,
              message: error.message,
            );
          } finally {
            await _hideBlockingPaymentDialog(
              context,
              isVisible: progressDialogVisible,
            );
            progressDialogVisible = false;
            await _hideBlockingPaymentDialog(
              context,
              isVisible: redirectingDialogVisible,
            );
            redirectingDialogVisible = false;
            razorpay.clear();
          }
        },
      );
    } on _UserAppApiException catch (error) {
      await _hideBlockingPaymentDialog(
        context,
        isVisible: progressDialogVisible,
      );
      await _hideBlockingPaymentDialog(
        context,
        isVisible: redirectingDialogVisible,
      );
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
    var status =
        preferredStatus ?? await _UserAppApi.fetchPaymentStatus(paymentCode);
    for (int attempt = 0; attempt < 6; attempt++) {
      if (!_pendingStatuses.contains(
        status.paymentStatus.trim().toUpperCase(),
      )) {
        return status;
      }
      await Future<void>.delayed(const Duration(seconds: 10));
      status = await _UserAppApi.fetchPaymentStatus(paymentCode);
    }
    return status;
  }

  static Future<_PaymentStatusData?> _tryFetchStableStatus(
    String paymentCode,
  ) async {
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
    final title = result.success
        ? successTitle
        : result.verificationPending
        ? 'Payment verification in progress'
        : failureTitle;
    final accent = result.success
        ? const Color(0xFF1F8F53)
        : result.verificationPending
        ? const Color(0xFFB96A15)
        : const Color(0xFFCB6E5B);
    String extractLineValue(String prefix) {
      for (final line in extraLines) {
        final trimmed = line.trim();
        if (trimmed.toLowerCase().startsWith(prefix.toLowerCase())) {
          return trimmed.substring(prefix.length).trim();
        }
      }
      return '';
    }

    String normalizedAmount() {
      final statusAmount = result.status?.amountLabel.trim() ?? '';
      if (statusAmount.isNotEmpty) {
        return statusAmount;
      }
      return extractLineValue('Amount:');
    }

    final detailRows = <({String label, String value, Color? color})>[
      if (extractLineValue('Booking code:').isNotEmpty)
        (
          label: 'Booking code',
          value: extractLineValue('Booking code:'),
          color: null,
        ),
      if (extractLineValue('Provider:').isNotEmpty)
        (label: 'Provider', value: extractLineValue('Provider:'), color: null),
      if (extractLineValue('Labour:').isNotEmpty)
        (label: 'Labour', value: extractLineValue('Labour:'), color: null),
      if (normalizedAmount().isNotEmpty)
        (label: 'Amount paid', value: normalizedAmount(), color: null),
      if ((result.status?.paymentCode ?? '').trim().isNotEmpty)
        (
          label: 'Payment code',
          value: result.status!.paymentCode.trim(),
          color: null,
        ),
      if ((result.status?.paymentStatus ?? '').trim().isNotEmpty)
        (
          label: 'Status',
          value: result.status!.paymentStatus.trim().toUpperCase(),
          color: result.verificationPending
              ? const Color(0xFFB96A15)
              : result.success
              ? const Color(0xFF1F8F53)
              : const Color(0xFFCB6E5B),
        ),
    ];
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => SafeArea(
        bottom: true,
        child: Material(
          color: Colors.white,
          child: SizedBox(
            width: double.infinity,
            height:
                MediaQuery.of(dialogContext).size.height -
                MediaQuery.of(dialogContext).padding.top,
            child: Column(
              children: [
                SizedBox(
                  height: 10,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: result.success
                            ? const [Color(0xFF2E8E45), Color(0xFF5C8FD8)]
                            : result.verificationPending
                            ? const [Color(0xFFF2A13D), Color(0xFF5C8FD8)]
                            : const [Color(0xFFD84A4A), Color(0xFFF2A13D)],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 28, 14, 22),
                    child: Column(
                      children: [
                        const Spacer(),
                        Container(
                          width: 82,
                          height: 82,
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            result.success
                                ? Icons.check_circle_rounded
                                : result.verificationPending
                                ? Icons.hourglass_top_rounded
                                : Icons.error_rounded,
                            color: accent,
                            size: 42,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: accent,
                            fontSize: result.success
                                ? 21.5
                                : result.verificationPending
                                ? 20
                                : 22,
                            fontWeight: result.verificationPending
                                ? FontWeight.w800
                                : FontWeight.w900,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          result.verificationPending
                              ? "We're verifying your payment."
                              : result.message,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF22314D),
                            fontSize: result.success ? 12.8 : 13.2,
                            fontWeight: FontWeight.w700,
                            height: 1.34,
                          ),
                        ),
                        if (detailRows.isNotEmpty) ...[
                          const SizedBox(height: 18),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFD),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: const Color(0xFFE5EAF2),
                              ),
                            ),
                            child: Column(
                              children: List<Widget>.generate(
                                detailRows.length,
                                (index) {
                                  final row = detailRows[index];
                                  return Padding(
                                    padding: EdgeInsets.only(
                                      bottom: index == detailRows.length - 1
                                          ? 0
                                          : 10,
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 98,
                                          child: Text(
                                            '${row.label}:',
                                            style: const TextStyle(
                                              color: Color(0xFF66748C),
                                              fontSize: 12.2,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            row.value,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color:
                                                  row.color ??
                                                  const Color(0xFF22314D),
                                              fontSize: 12.9,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                        const Spacer(),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            style: FilledButton.styleFrom(
                              backgroundColor: accent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              'Close',
                              style: TextStyle(fontWeight: FontWeight.w900),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

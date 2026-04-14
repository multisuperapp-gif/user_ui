part of '../../main.dart';

class _OrdersPage extends StatefulWidget {
  const _OrdersPage();

  @override
  State<_OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<_OrdersPage> {
  bool _loading = true;
  String? _error;
  List<_UserOrderSummary> _orders = const <_UserOrderSummary>[];

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final orders = await _UserAppApi.fetchMyOrders();
      if (!mounted) {
        return;
      }
      setState(() {
        _orders = orders;
      });
    } on _UserAppApiException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = error.message;
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F2EC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F2EC),
        surfaceTintColor: const Color(0xFFF7F2EC),
        title: const Text(
          'My Orders',
          style: TextStyle(
            color: Color(0xFF22314D),
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          color: const Color(0xFFCB6E5B),
          child: _loading
              ? ListView(
                  padding: const EdgeInsets.all(24),
                  children: const [
                    _AsyncStateCard(
                      icon: Icons.receipt_long_rounded,
                      title: 'Loading your orders',
                      message: 'We are fetching your latest live orders right now.',
                      loading: true,
                    ),
                  ],
                )
              : _error != null
              ? ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    _AsyncStateCard(
                      icon: Icons.cloud_off_rounded,
                      title: 'Could not load orders',
                      message: _error!,
                      actionLabel: 'Try Again',
                      onAction: _load,
                    ),
                  ],
                )
              : _orders.isEmpty
              ? ListView(
                  padding: const EdgeInsets.all(24),
                  children: const [
                    _AsyncStateCard(
                      icon: Icons.shopping_bag_outlined,
                      title: 'No orders yet',
                      message: 'Once you place an order, it will appear here with live status updates.',
                    ),
                  ],
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
                  itemCount: _orders.length,
                  separatorBuilder: (_, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final order = _orders[index];
                    return InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => _OrderDetailPage(orderId: order.orderId),
                          ),
                        );
                        await _load();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0x1A000000),
                              blurRadius: 18,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 62,
                              height: 62,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF4EEE7),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: const Icon(
                                Icons.shopping_bag_rounded,
                                color: Color(0xFFCB6E5B),
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    order.shopName,
                                    style: const TextStyle(
                                      color: Color(0xFF22314D),
                                      fontWeight: FontWeight.w900,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    order.primaryItemName,
                                    style: const TextStyle(
                                      color: Color(0xFF6E7B91),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _trackingSubtitle(
                                      order.orderStatus,
                                      paymentStatus: order.paymentStatus,
                                      updatedAt: order.updatedAt ?? order.createdAt,
                                    ),
                                    style: const TextStyle(
                                      color: Color(0xFF32547A),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      _OrderChip(
                                        label: _humanizeOrderStatus(order.orderStatus),
                                        textColor: _orderStatusColor(order.orderStatus),
                                        backgroundColor: _orderStatusColor(order.orderStatus).withValues(alpha: 0.12),
                                      ),
                                      _OrderChip(
                                        label: '${order.itemCount} item${order.itemCount == 1 ? '' : 's'}',
                                        textColor: const Color(0xFF6E7B91),
                                        backgroundColor: const Color(0xFFF3F1EC),
                                      ),
                                      _OrderChip(
                                        label: order.totalAmount,
                                        textColor: const Color(0xFFCB6E5B),
                                        backgroundColor: const Color(0xFFFFF0EA),
                                      ),
                                      _OrderChip(
                                        label: _titleCase(order.paymentStatus),
                                        textColor: _paymentStatusColor(order.paymentStatus),
                                        backgroundColor: _paymentStatusColor(order.paymentStatus).withValues(alpha: 0.12),
                                      ),
                                      if (order.refundPresent)
                                        _OrderChip(
                                          label: order.latestRefundStatus.isEmpty
                                              ? 'Refund'
                                              : 'Refund ${_titleCase(order.latestRefundStatus)}',
                                          textColor: const Color(0xFF1F8F53),
                                          backgroundColor: const Color(0xFFE9F7EF),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}

class _OrderDetailPage extends StatefulWidget {
  const _OrderDetailPage({
    required this.orderId,
  });

  final int orderId;

  @override
  State<_OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<_OrderDetailPage> {
  bool _loading = true;
  bool _cancelling = false;
  bool _retryingPayment = false;
  String? _error;
  _UserOrderDetail? _detail;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final detail = await _UserAppApi.fetchOrderDetail(widget.orderId);
      if (!mounted) {
        return;
      }
      setState(() {
        _detail = detail;
      });
    } on _UserAppApiException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = error.message;
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _cancelOrder() async {
    final detail = _detail;
    if (detail == null || !detail.cancellable || _cancelling) {
      return;
    }
    setState(() {
      _cancelling = true;
    });
    try {
      await _UserAppApi.cancelOrder(detail.orderId);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order cancelled successfully.')),
      );
      await _load();
    } on _UserAppApiException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message)),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _cancelling = false;
        });
      }
    }
  }

  Future<void> _retryPayment() async {
    final detail = _detail;
    if (detail == null || !detail.paymentRetryAllowed || _retryingPayment) {
      return;
    }
    setState(() {
      _retryingPayment = true;
    });
    final result = await _PaymentFlow.start(
      context,
      paymentCode: detail.paymentCode,
      title: 'Complete payment for ${detail.shopName}',
    );
    if (!mounted) {
      return;
    }
    await _PaymentFlow.showOutcome(
      context,
      result: result,
      successTitle: 'Payment Completed',
      failureTitle: result.cancelled ? 'Payment Cancelled' : 'Payment Not Completed',
      extraLines: <String>[
        'Order code: ${detail.orderCode}',
      ],
    );
    await _load();
    if (mounted) {
      setState(() {
        _retryingPayment = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final detail = _detail;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F2EC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F2EC),
        surfaceTintColor: const Color(0xFFF7F2EC),
        title: Text(
          detail == null ? 'Order details' : detail.orderCode,
          style: const TextStyle(
            color: Color(0xFF22314D),
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SafeArea(
        child: _loading
            ? ListView(
                padding: const EdgeInsets.all(24),
                children: const [
                  _AsyncStateCard(
                    icon: Icons.local_shipping_outlined,
                    title: 'Loading order details',
                    message: 'We are bringing in the latest payment and delivery status.',
                    loading: true,
                  ),
                ],
              )
            : _error != null
            ? ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  _AsyncStateCard(
                    icon: Icons.error_outline_rounded,
                    title: 'Could not load this order',
                    message: _error!,
                    actionLabel: 'Try Again',
                    onAction: _load,
                  ),
                ],
              )
            : detail == null
            ? ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  _AsyncStateCard(
                    icon: Icons.inbox_outlined,
                    title: 'Order not available',
                    message: 'This order could not be found right now. Please refresh and try again.',
                    actionLabel: 'Reload',
                    onAction: _load,
                  ),
                ],
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
                children: [
                  _OrderPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    detail.shopName,
                                    style: const TextStyle(
                                      color: Color(0xFF22314D),
                                      fontWeight: FontWeight.w900,
                                      fontSize: 20,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _trackingTitle(detail.orderStatus, paymentStatus: detail.paymentStatus),
                                    style: TextStyle(
                                      color: _orderStatusColor(detail.orderStatus),
                                      fontWeight: FontWeight.w900,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF4EEE7),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                detail.orderCode,
                                style: const TextStyle(
                                  color: Color(0xFF6E7B91),
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _trackingSubtitle(
                            detail.orderStatus,
                            paymentStatus: detail.paymentStatus,
                            updatedAt: detail.updatedAt ?? detail.createdAt,
                          ),
                          style: const TextStyle(
                            color: Color(0xFF6E7B91),
                            fontWeight: FontWeight.w700,
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _OrderChip(
                              label: _humanizeOrderStatus(detail.orderStatus),
                              textColor: _orderStatusColor(detail.orderStatus),
                              backgroundColor: _orderStatusColor(detail.orderStatus).withValues(alpha: 0.12),
                            ),
                            _OrderChip(
                              label: detail.totalAmount,
                              textColor: const Color(0xFFCB6E5B),
                              backgroundColor: const Color(0xFFFFF0EA),
                            ),
                            _OrderChip(
                              label: _titleCase(detail.paymentStatus),
                              textColor: _paymentStatusColor(detail.paymentStatus),
                              backgroundColor: _paymentStatusColor(detail.paymentStatus).withValues(alpha: 0.12),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Delivering to ${detail.addressLine}',
                          style: const TextStyle(
                            color: Color(0xFF6E7B91),
                            fontWeight: FontWeight.w700,
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9F4EE),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Column(
                            children: [
                              _OrderValueRow(
                                label: 'Items total',
                                value: detail.subtotalAmount,
                              ),
                              const SizedBox(height: 8),
                              _OrderValueRow(
                                label: 'Delivery fee',
                                value: detail.deliveryFeeAmount,
                              ),
                              const SizedBox(height: 8),
                              _OrderValueRow(
                                label: 'Platform fee',
                                value: detail.platformFeeAmount,
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child: Divider(height: 1),
                              ),
                              _OrderValueRow(
                                label: 'Total paid',
                                value: detail.totalAmount,
                                highlight: true,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _OrderPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Items',
                          style: TextStyle(
                            color: Color(0xFF22314D),
                            fontWeight: FontWeight.w900,
                            fontSize: 17,
                          ),
                        ),
                        const SizedBox(height: 12),
                        for (final item in detail.items) ...[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 54,
                                height: 54,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF4EEE7),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Icons.fastfood_rounded,
                                  color: Color(0xFFCB6E5B),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.productName,
                                      style: const TextStyle(
                                        color: Color(0xFF22314D),
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    if (item.variantName.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        item.variantName,
                                        style: const TextStyle(
                                          color: Color(0xFF6E7B91),
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              Text(
                                '${item.quantity} x ${item.unitPrice}',
                                style: const TextStyle(
                                  color: Color(0xFF22314D),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _OrderPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Timeline',
                          style: TextStyle(
                            color: Color(0xFF22314D),
                            fontWeight: FontWeight.w900,
                            fontSize: 17,
                          ),
                        ),
                        const SizedBox(height: 12),
                        for (final event in detail.timeline) ...[
                          _TimelineStep(
                            title: _humanizeOrderStatus(event.newStatus),
                            subtitle:
                                '${_formatDateTime(event.changedAt)}${event.reason.isEmpty ? '' : ' • ${event.reason}'}',
                            color: _orderStatusColor(event.newStatus),
                          ),
                          const SizedBox(height: 14),
                        ],
                      ],
                    ),
                  ),
                  if (detail.refund != null) ...[
                    const SizedBox(height: 12),
                    _OrderPanel(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Refund',
                            style: TextStyle(
                              color: Color(0xFF22314D),
                              fontWeight: FontWeight.w900,
                              fontSize: 17,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '${detail.refund!.refundCode} • ${_titleCase(detail.refund!.refundStatus)}',
                            style: const TextStyle(
                              color: Color(0xFF1F8F53),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Requested ${detail.refund!.requestedAmount}',
                            style: const TextStyle(
                              color: Color(0xFF6E7B91),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (detail.refund!.hasApprovedAmount) ...[
                            const SizedBox(height: 6),
                            Text(
                              'Approved ${detail.refund!.approvedAmount}',
                              style: const TextStyle(
                                color: Color(0xFF22314D),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                          if (detail.refund!.reason.trim().isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              detail.refund!.reason,
                              style: const TextStyle(
                                color: Color(0xFF6E7B91),
                                fontWeight: FontWeight.w700,
                                height: 1.4,
                              ),
                            ),
                          ],
                          if (detail.refund!.initiatedAt != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Started ${_formatDateTime(detail.refund!.initiatedAt)}',
                              style: const TextStyle(
                                color: Color(0xFF6E7B91),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                          if (detail.refund!.completedAt != null) ...[
                            const SizedBox(height: 6),
                            Text(
                              'Completed ${_formatDateTime(detail.refund!.completedAt)}',
                              style: const TextStyle(
                                color: Color(0xFF6E7B91),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  if (detail.paymentRetryAllowed)
                    OutlinedButton.icon(
                      onPressed: _retryingPayment ? null : _retryPayment,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFCB6E5B),
                        side: const BorderSide(color: Color(0xFFCB6E5B)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      ),
                      icon: Icon(_retryingPayment ? Icons.hourglass_top_rounded : Icons.refresh_rounded),
                      label: Text(
                        _retryingPayment ? 'Retrying Payment...' : 'Retry Payment',
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  if (detail.paymentRetryAllowed) const SizedBox(height: 12),
                  if (detail.cancellable)
                    FilledButton(
                      onPressed: _cancelling ? null : _cancelOrder,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFCB6E5B),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      ),
                      child: Text(
                        _cancelling ? 'Cancelling...' : 'Cancel Order',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}

class _OrderPanel extends StatelessWidget {
  const _OrderPanel({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0x12000000),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _OrderValueRow extends StatelessWidget {
  const _OrderValueRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final labelColor = highlight ? const Color(0xFF22314D) : const Color(0xFF6E7B91);
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: labelColor,
              fontWeight: highlight ? FontWeight.w900 : FontWeight.w700,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: highlight ? const Color(0xFFCB6E5B) : const Color(0xFF22314D),
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _OrderChip extends StatelessWidget {
  const _OrderChip({
    required this.label,
    required this.textColor,
    required this.backgroundColor,
  });

  final String label;
  final Color textColor;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({
    required this.title,
    required this.subtitle,
    required this.color,
  });

  final String title;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF22314D),
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF6E7B91),
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

String _humanizeOrderStatus(String status) {
  if (status.trim().isEmpty) {
    return 'Order';
  }
  return status
      .toLowerCase()
      .split('_')
      .map((part) => part.isEmpty ? part : '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}

String _titleCase(String value) {
  if (value.trim().isEmpty) {
    return value;
  }
  return value
      .toLowerCase()
      .split('_')
      .map((part) => part.isEmpty ? part : '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}

Color _orderStatusColor(String status) {
  switch (status.toUpperCase()) {
    case 'DELIVERED':
      return const Color(0xFF1F8F53);
    case 'CANCELLED':
      return const Color(0xFFC13B36);
    case 'OUT_FOR_DELIVERY':
    case 'DISPATCHED':
      return const Color(0xFF355FCE);
    default:
      return const Color(0xFFCB6E5B);
  }
}

Color _paymentStatusColor(String status) {
  switch (status.trim().toUpperCase()) {
    case 'SUCCESS':
      return const Color(0xFF1F8F53);
    case 'FAILED':
      return const Color(0xFFC13B36);
    case 'PENDING':
    case 'INITIATED':
      return const Color(0xFFB87414);
    default:
      return const Color(0xFF32547A);
  }
}

String _trackingTitle(String orderStatus, {String? paymentStatus}) {
  final normalizedOrder = orderStatus.trim().toUpperCase();
  final normalizedPayment = (paymentStatus ?? '').trim().toUpperCase();
  if (normalizedOrder == 'CANCELLED') {
    return 'Order Cancelled';
  }
  if (normalizedOrder == 'DELIVERED') {
    return 'Delivered Successfully';
  }
  if (normalizedPayment == 'FAILED') {
    return 'Payment Needs Attention';
  }
  if (normalizedPayment == 'PENDING' || normalizedPayment == 'INITIATED') {
    return 'Waiting For Payment Confirmation';
  }
  if (normalizedOrder == 'OUT_FOR_DELIVERY') {
    return 'Out For Delivery';
  }
  if (normalizedOrder == 'DISPATCHED') {
    return 'Packed And On The Way';
  }
  if (normalizedOrder == 'CONFIRMED') {
    return 'Order Confirmed';
  }
  return _humanizeOrderStatus(orderStatus);
}

String _trackingSubtitle(
  String orderStatus, {
  required String paymentStatus,
  required DateTime? updatedAt,
}) {
  final normalizedOrder = orderStatus.trim().toUpperCase();
  final normalizedPayment = paymentStatus.trim().toUpperCase();
  final stamp = updatedAt == null ? '' : ' • ${_formatDateTime(updatedAt)}';
  if (normalizedOrder == 'CANCELLED') {
    return 'This order has been cancelled$stamp';
  }
  if (normalizedOrder == 'DELIVERED') {
    return 'Your order reached you successfully$stamp';
  }
  if (normalizedPayment == 'FAILED') {
    return 'Payment did not complete. You can retry from this order page$stamp';
  }
  if (normalizedPayment == 'PENDING' || normalizedPayment == 'INITIATED') {
    return 'Payment is still pending confirmation$stamp';
  }
  if (normalizedOrder == 'OUT_FOR_DELIVERY') {
    return 'Your rider is on the way$stamp';
  }
  if (normalizedOrder == 'DISPATCHED') {
    return 'The store has packed your order and sent it out$stamp';
  }
  if (normalizedOrder == 'CONFIRMED') {
    return 'The store has accepted your order$stamp';
  }
  return 'Order updated$stamp';
}

String _formatDateTime(DateTime? value) {
  if (value == null) {
    return '';
  }
  final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
  final minute = value.minute.toString().padLeft(2, '0');
  final meridiem = value.hour >= 12 ? 'PM' : 'AM';
  return '${value.day}/${value.month}/${value.year} $hour:$minute $meridiem';
}

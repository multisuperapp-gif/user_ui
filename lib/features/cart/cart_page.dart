
part of '../../main.dart';

class _CartPage extends StatefulWidget {
  const _CartPage({
    required this.shopName,
    required this.items,
    required this.isAuthenticated,
    required this.onCheckout,
    required this.onBrowseItems,
    required this.onRequireLogin,
    required this.onItemTap,
  });

  final String shopName;
  final List<_DiscoveryItem> items;
  final bool isAuthenticated;
  final Future<void> Function(int? addressId) onCheckout;
  final VoidCallback onBrowseItems;
  final Future<bool> Function() onRequireLogin;
  final Future<void> Function(_DiscoveryItem item) onItemTap;

  @override
  State<_CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<_CartPage> {
  bool _isAuthenticated = false;
  bool _loadingAddresses = false;
  bool _processingAction = false;
  String? _addressError;
  List<_UserAddressData> _addresses = const <_UserAddressData>[];
  int? _selectedAddressId;
  String _paymentMode = 'COD';

  @override
  void initState() {
    super.initState();
    _isAuthenticated = widget.isAuthenticated;
    if (_isAuthenticated) {
      unawaited(_loadAddresses());
    }
  }

  static double _extractAmount(String price) {
    final match = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(price);
    return double.tryParse(match?.group(1) ?? '') ?? 0;
  }

  double get _itemsTotal =>
      widget.items.fold<double>(0, (total, item) => total + _extractAmount(item.price));

  double get _deliveryCharge => _itemsTotal >= 500 ? 0 : 35;

  double get _grandTotal => _itemsTotal + _deliveryCharge;

  String _money(double amount) => '₹${amount.toStringAsFixed(amount.truncateToDouble() == amount ? 0 : 2)}';

  Future<void> _loadAddresses() async {
    setState(() {
      _loadingAddresses = true;
      _addressError = null;
    });
    try {
      final addresses = await _UserAppApi.fetchAddresses();
      int? selectedAddressId;
      for (final address in addresses) {
        if (address.isDefault) {
          selectedAddressId = address.id;
          break;
        }
      }
      selectedAddressId ??= addresses.isEmpty ? null : addresses.first.id;
      if (!mounted) {
        return;
      }
      setState(() {
        _addresses = addresses;
        _selectedAddressId = selectedAddressId;
        _loadingAddresses = false;
        _addressError = null;
      });
    } on _UserAppApiException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _addresses = const <_UserAddressData>[];
        _selectedAddressId = null;
        _loadingAddresses = false;
        _addressError = error.message;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _addresses = const <_UserAddressData>[];
        _selectedAddressId = null;
        _loadingAddresses = false;
        _addressError = 'Could not load saved addresses right now.';
      });
    }
  }

  Future<void> _handleCheckoutTap() async {
    if (_processingAction) {
      return;
    }
    if (!_isAuthenticated) {
      setState(() {
        _processingAction = true;
      });
      final loggedIn = await widget.onRequireLogin();
      if (!mounted) {
        return;
      }
      setState(() {
        _processingAction = false;
        _isAuthenticated = loggedIn;
      });
      if (loggedIn) {
        await _loadAddresses();
      }
      return;
    }
    setState(() {
      _processingAction = true;
    });
    try {
      await widget.onCheckout(_selectedAddressId);
    } finally {
      if (mounted) {
        setState(() {
          _processingAction = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedAddress = _addresses.where((item) => item.id == _selectedAddressId).firstOrNull;
    const brandColor = Color(0xFFCB6E5B);
    return Scaffold(
      backgroundColor: const Color(0xFFF8F1EA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F1EA),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleSpacing: 0,
        title: const Text(
          'Cart',
          style: TextStyle(
            color: Color(0xFF22314D),
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      bottomNavigationBar: widget.items.isEmpty
          ? null
          : SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1A2030).withValues(alpha: 0.08),
                      blurRadius: 24,
                      offset: const Offset(0, -8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _isAuthenticated ? 'Ready to checkout' : 'Login required to checkout',
                                style: const TextStyle(
                                  color: Color(0xFF22314D),
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '${widget.items.length} item${widget.items.length == 1 ? '' : 's'} · ${_money(_grandTotal)}',
                                style: const TextStyle(
                                  color: Color(0xFF6D7A91),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                          decoration: BoxDecoration(
                            color: brandColor.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            _money(_grandTotal),
                            style: const TextStyle(
                              color: brandColor,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _processingAction ? null : _handleCheckoutTap,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: brandColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                        child: Text(
                          _processingAction
                              ? 'Please wait...'
                              : _isAuthenticated
                                  ? 'Checkout • ${_money(_grandTotal)}'
                                  : 'Login to Checkout',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      body: widget.items.isEmpty
          ? _EmptyCartState(onBrowseItems: widget.onBrowseItems)
          : ListView(
              padding: const EdgeInsets.fromLTRB(18, 6, 18, 124),
              children: [
                _CartHeroBanner(
                  shopName: widget.shopName,
                  itemCount: widget.items.length,
                  grandTotal: _money(_grandTotal),
                ),
                const SizedBox(height: 18),
                Text(
                  '${widget.items.length} item${widget.items.length == 1 ? '' : 's'} for delivery',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF6D7A91),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 14),
                ...widget.items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () => widget.onItemTap(item),
                      borderRadius: BorderRadius.circular(28),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: const Color(0xFFF0E2D8)),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1A2030).withValues(alpha: 0.06),
                              blurRadius: 24,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    item.accent.withValues(alpha: 0.18),
                                    item.accent.withValues(alpha: 0.07),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(22),
                              ),
                              child: Icon(item.icon, color: item.accent, size: 32),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Color(0xFF22314D),
                                      fontWeight: FontWeight.w900,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.subtitle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Color(0xFF6D7A91),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: brandColor.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Text(
                                    '-  1  +',
                                    style: TextStyle(
                                      color: brandColor,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  item.price.isEmpty ? '₹0' : item.price,
                                  style: const TextStyle(
                                    color: Color(0xFF22314D),
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                _CartSectionCard(
                  title: 'Bill Details',
                  child: Column(
                    children: [
                      _CartSummaryRow(label: 'Items total', value: _money(_itemsTotal)),
                      _CartSummaryRow(
                        label: 'Delivery charges',
                        value: _deliveryCharge == 0 ? 'Free Delivery' : _money(_deliveryCharge),
                        accent: _deliveryCharge == 0 ? const Color(0xFF2E8E45) : null,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(height: 1),
                      ),
                      _CartSummaryRow(
                        label: 'Grand Total',
                        value: _money(_grandTotal),
                        highlight: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (_isAuthenticated)
                  _CartSectionCard(
                    title: 'Deliver To',
                    trailing: TextButton(
                      onPressed: _loadingAddresses ? null : _loadAddresses,
                      child: const Text('Refresh'),
                    ),
                    child: _loadingAddresses
                        ? const _AsyncStateCard(
                            icon: Icons.location_on_outlined,
                            title: 'Loading saved addresses',
                            message: 'We are fetching your saved delivery addresses.',
                            dense: true,
                            loading: true,
                          )
                        : _addressError != null
                            ? _AsyncStateCard(
                                icon: Icons.location_off_outlined,
                                title: 'Could not load addresses',
                                message: _addressError!,
                                dense: true,
                                actionLabel: 'Try Again',
                                onAction: _loadAddresses,
                              )
                            : _addresses.isEmpty
                                ? const _AsyncStateCard(
                                    icon: Icons.add_location_alt_outlined,
                                    title: 'No saved address yet',
                                    message: 'Add an address from your profile to continue to checkout.',
                                    dense: true,
                                  )
                                : Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (selectedAddress != null)
                                        Container(
                                          width: double.infinity,
                                          margin: const EdgeInsets.only(bottom: 12),
                                          padding: const EdgeInsets.all(14),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF8F4EF),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                selectedAddress.isDefault
                                                    ? '${selectedAddress.label} · Default'
                                                    : selectedAddress.label,
                                                style: const TextStyle(
                                                  color: Color(0xFF22314D),
                                                  fontWeight: FontWeight.w900,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                selectedAddress.fullAddress,
                                                style: const TextStyle(
                                                  color: Color(0xFF4F5C73),
                                                  fontWeight: FontWeight.w700,
                                                  height: 1.35,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: _addresses
                                            .map(
                                              (address) => ChoiceChip(
                                                label: Text(address.label),
                                                selected: address.id == _selectedAddressId,
                                                onSelected: (_) => setState(() {
                                                  _selectedAddressId = address.id;
                                                }),
                                              ),
                                            )
                                            .toList(growable: false),
                                      ),
                                    ],
                                  ),
                  ),
                  const SizedBox(height: 16),
                _CartSectionCard(
                  title: 'PAY USING',
                  child: Column(
                    children: [
                      _CartPaymentTile(
                        title: 'Cash on Delivery',
                        subtitle: 'Pay with cash at delivery time',
                        selected: _paymentMode == 'COD',
                        onTap: () => setState(() => _paymentMode = 'COD'),
                      ),
                      const SizedBox(height: 12),
                      _CartPaymentTile(
                        title: 'Online Payment',
                        subtitle: 'UPI / Credit, Debit card / Netbanking',
                        selected: _paymentMode == 'ONLINE',
                        onTap: () => setState(() => _paymentMode = 'ONLINE'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _CartHeroBanner extends StatelessWidget {
  const _CartHeroBanner({
    required this.shopName,
    required this.itemCount,
    required this.grandTotal,
  });

  final String shopName;
  final int itemCount;
  final String grandTotal;

  @override
  Widget build(BuildContext context) {
    final title = shopName.trim().isEmpty ? 'Your delivery bag' : shopName.trim();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF6E1D7),
            Color(0xFFFFF5EF),
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFCB6E5B).withValues(alpha: 0.10),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: const Color(0xFFCB6E5B),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(Icons.shopping_bag_rounded, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF22314D),
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$itemCount item${itemCount == 1 ? '' : 's'} ready for checkout',
                  style: const TextStyle(
                    color: Color(0xFF6D7A91),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              grandTotal,
              style: const TextStyle(
                color: Color(0xFFCB6E5B),
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyCartState extends StatefulWidget {
  const _EmptyCartState({required this.onBrowseItems});

  final VoidCallback onBrowseItems;

  @override
  State<_EmptyCartState> createState() => _EmptyCartStateState();
}

class _EmptyCartStateState extends State<_EmptyCartState> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 10, 22, 32),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final bob = Curves.easeInOut.transform(_controller.value);
          final figureOffset = 8 + (-14 * bob);
          final glowScale = 0.96 + (0.06 * bob);
          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFFFF7F2),
                      Color(0xFFF9E6DF),
                      Color(0xFFFFFCFA),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(36),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFCB6E5B).withValues(alpha: 0.12),
                      blurRadius: 30,
                      offset: const Offset(0, 18),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: 286,
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          Transform.scale(
                            scale: glowScale,
                            child: Container(
                              width: 220,
                              height: 220,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    const Color(0xFFCB6E5B).withValues(alpha: 0.14),
                                    const Color(0xFFF2AE83).withValues(alpha: 0.09),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.88),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(color: const Color(0xFFF0DDD3)),
                              ),
                              child: const Text(
                                'Empty bag',
                                style: TextStyle(
                                  color: Color(0xFF22314D),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 28,
                            left: 38,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: const Color(0xFFCB6E5B).withValues(alpha: 0.18),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 46,
                            right: 42,
                            child: Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: const Color(0xFF22314D).withValues(alpha: 0.10),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 28,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: Container(
                                width: 166,
                                height: 22,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(999),
                                  gradient: RadialGradient(
                                    colors: [
                                      const Color(0xFF22314D).withValues(alpha: 0.16),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Transform.translate(
                            offset: Offset(0, figureOffset),
                            child: const _EmptyCartIllustration(),
                          ),
                        ],
                      ),
                    ),
                    const Text(
                      'Your bag is still empty',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF22314D),
                        fontSize: 23,
                        fontWeight: FontWeight.w700,
                        height: 1.16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Let’s find something worth taking home. Explore nearby stores, discover everyday picks, and start filling your bag.",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: const Color(0xFF6D7A91),
                            fontWeight: FontWeight.w500,
                            height: 1.48,
                            fontSize: 15,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: const [
                        _EmptyCartTag(label: 'Nearby shops'),
                        _EmptyCartTag(label: 'Fresh picks'),
                        _EmptyCartTag(label: 'Quick checkout'),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: widget.onBrowseItems,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFCB6E5B),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                          elevation: 0,
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 17,
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.explore_rounded, size: 20),
                            SizedBox(width: 10),
                            Text('Browse Items'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _EmptyCartIllustration extends StatelessWidget {
  const _EmptyCartIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 210,
      height: 226,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 18,
            left: 84,
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFFF3C6B2),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 10,
            left: 72,
            child: Transform.rotate(
              angle: -0.08,
              child: Container(
                width: 64,
                height: 50,
                decoration: const BoxDecoration(
                  color: Color(0xFF22314D),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(26),
                    bottomLeft: Radius.circular(18),
                    bottomRight: Radius.circular(24),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 46,
            left: 92,
            child: Container(
              width: 22,
              height: 18,
              decoration: BoxDecoration(
                color: const Color(0xFFF3C6B2),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          Positioned(
            top: 60,
            left: 58,
            child: Container(
              width: 94,
              height: 92,
              decoration: const BoxDecoration(
                color: Color(0xFF1E8E8E),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(26),
                  topRight: Radius.circular(26),
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(34),
                ),
              ),
            ),
          ),
          Positioned(
            top: 68,
            left: 48,
            child: Transform.rotate(
              angle: -0.12,
              child: Container(
                width: 82,
                height: 110,
                decoration: const BoxDecoration(
                  color: Color(0xFFD85E53),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(36),
                    bottomLeft: Radius.circular(34),
                    bottomRight: Radius.circular(24),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 72,
            left: 36,
            child: Transform.rotate(
              angle: -0.22,
              child: Container(
                width: 80,
                height: 18,
                decoration: const BoxDecoration(
                  color: Color(0xFFF3C6B2),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(18),
                    bottomLeft: Radius.circular(18),
                    bottomRight: Radius.circular(12),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 96,
            left: 126,
            child: const _EmptyBasketArt(),
          ),
          Positioned(
            top: 144,
            left: 62,
            child: Container(
              width: 20,
              height: 58,
              decoration: BoxDecoration(
                color: const Color(0xFFD85E53),
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          Positioned(
            top: 144,
            left: 108,
            child: Container(
              width: 20,
              height: 58,
              decoration: BoxDecoration(
                color: const Color(0xFF1E8E8E),
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          Positioned(
            top: 190,
            left: 52,
            child: Transform.rotate(
              angle: 0.08,
              child: Container(
                width: 42,
                height: 12,
                decoration: BoxDecoration(
                  color: const Color(0xFF22314D),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
          Positioned(
            top: 190,
            left: 104,
            child: Transform.rotate(
              angle: -0.08,
              child: Container(
                width: 42,
                height: 12,
                decoration: BoxDecoration(
                  color: const Color(0xFF22314D),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
          Positioned(
            top: 84,
            left: 166,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: const Color(0xFFF0A5BC).withValues(alpha: 0.75),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 62,
            right: 14,
            child: Transform.rotate(
              angle: -0.4,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFCB6E5B), width: 3),
                    ),
                  ),
                  Positioned(
                    right: -7,
                    bottom: -4,
                    child: Container(
                      width: 14,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFCB6E5B),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyBasketArt extends StatelessWidget {
  const _EmptyBasketArt();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      height: 64,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 0,
            left: 20,
            child: Container(
              width: 30,
              height: 22,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFCB6E5B), width: 3),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          Positioned(
            top: 14,
            left: 4,
            right: 4,
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFFFFFF),
                    Color(0xFFFFF3ED),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(13),
                  topRight: Radius.circular(13),
                  bottomLeft: Radius.circular(19),
                  bottomRight: Radius.circular(19),
                ),
                border: Border.all(color: const Color(0xFFD7B7AA), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF22314D).withValues(alpha: 0.10),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 27,
            left: 16,
            right: 16,
            child: Column(
              children: [
                Container(
                  width: 24,
                  height: 3,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2C9BF),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 7),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    3,
                    (index) => Container(
                      width: 5,
                      height: 5,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFCB6E5B).withValues(alpha: 0.42),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: -2,
            top: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF22314D),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text(
                '0',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                  height: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyCartTag extends StatelessWidget {
  const _EmptyCartTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFF0DDD3)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF6D7A91),
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _CartSectionCard extends StatelessWidget {
  const _CartSectionCard({
    required this.title,
    required this.child,
    this.trailing,
  });

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF0E2D8)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A2030).withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.receipt_long_rounded, color: Color(0xFFCB6E5B), size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF22314D),
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
              ),
              if (trailing != null) ...<Widget>[trailing!],
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _CartSummaryRow extends StatelessWidget {
  const _CartSummaryRow({
    required this.label,
    required this.value,
    this.highlight = false,
    this.accent,
  });

  final String label;
  final String value;
  final bool highlight;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: highlight ? const Color(0xFF22314D) : const Color(0xFF6D7A91),
                fontWeight: highlight ? FontWeight.w900 : FontWeight.w700,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: accent ?? const Color(0xFF22314D),
              fontWeight: highlight ? FontWeight.w900 : FontWeight.w800,
              fontSize: highlight ? 18 : 15,
            ),
          ),
        ],
      ),
    );
  }
}

class _CartPaymentTile extends StatelessWidget {
  const _CartPaymentTile({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? const Color(0xFFCB6E5B) : const Color(0xFFE5E7ED),
            width: selected ? 1.6 : 1,
          ),
          color: selected ? const Color(0xFFFFF2ED) : Colors.white,
        ),
        child: Row(
          children: [
            Icon(
              title == 'Cash on Delivery' ? Icons.money_rounded : Icons.credit_card_rounded,
              color: title == 'Cash on Delivery' ? const Color(0xFF2E8E45) : const Color(0xFF3E7BD6),
            ),
            const SizedBox(width: 12),
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
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF6D7A91),
                      fontWeight: FontWeight.w600,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              selected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
              color: selected ? const Color(0xFFCB6E5B) : const Color(0xFFC4C8D3),
            ),
          ],
        ),
      ),
    );
  }
}

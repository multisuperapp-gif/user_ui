part of '../../main.dart';

class _DiscoveryDetailPage extends StatefulWidget {
  const _DiscoveryDetailPage({
    required this.item,
    required this.mode,
    required this.isAuthenticated,
    required this.isWishlisted,
    required this.isFavourited,
    required this.onWishlistToggle,
    required this.onFavouriteToggle,
    required this.onPrimaryAction,
  });

  final _DiscoveryItem item;
  final _HomeMode mode;
  final bool isAuthenticated;
  final bool isWishlisted;
  final bool isFavourited;
  final VoidCallback onWishlistToggle;
  final VoidCallback onFavouriteToggle;
  final Future<bool> Function(String? labourBookingPeriod, int? labourCategoryId) onPrimaryAction;

  @override
  State<_DiscoveryDetailPage> createState() => _DiscoveryDetailPageState();
}

class _DiscoveryDetailPageState extends State<_DiscoveryDetailPage> {
  String? _selectedLabourBookingPeriod;
  int? _selectedLabourCategoryId;
  late bool _isAuthenticated;
  bool _labourBookedLocally = false;
  bool _primaryActionBusy = false;

  @override
  void initState() {
    super.initState();
    _isAuthenticated = widget.isAuthenticated;
    _selectedLabourCategoryId = _labourCategoryOptions.firstOrNull?.categoryId ?? widget.item.backendCategoryId;
    unawaited(_refreshAuthStateFromSession());
  }

  @override
  void didUpdateWidget(covariant _DiscoveryDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isAuthenticated != widget.isAuthenticated) {
      _isAuthenticated = widget.isAuthenticated;
    }
    if (oldWidget.item.backendLabourId != widget.item.backendLabourId ||
        oldWidget.item.labourCategoryPricing != widget.item.labourCategoryPricing) {
      _labourBookedLocally = false;
      _selectedLabourCategoryId = _labourCategoryOptions.firstOrNull?.categoryId ?? widget.item.backendCategoryId;
      _selectedLabourBookingPeriod = null;
    }
  }

  Future<void> _refreshAuthStateFromSession() async {
    final savedPhoneNumber = await _LocalSessionStore.readPhoneNumber();
    final nextAuthenticated = (savedPhoneNumber ?? '').trim().isNotEmpty;
    if (!mounted || nextAuthenticated == _isAuthenticated) {
      return;
    }
    setState(() {
      _isAuthenticated = nextAuthenticated;
    });
  }

  Future<void> _openLoginBeforeBooking() async {
    final loggedIn = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => const LoginPage(embeddedFlow: true),
      ),
    );
    if (loggedIn == true) {
      await _refreshAuthStateFromSession();
    }
  }

  double? get _distanceKm {
    final match = RegExp(r'([0-9]+(?:\.[0-9]+)?)').firstMatch(widget.item.distance);
    if (match == null) {
      return null;
    }
    return double.tryParse(match.group(1)!);
  }

  String get _distanceLabel {
    final km = _distanceKm;
    if (km == null) {
      return widget.item.distance;
    }
    return '${km.toStringAsFixed(1)} km';
  }

  bool get _isNearbyLabour =>
      widget.mode == _HomeMode.labour && (_distanceKm != null && _distanceKm! <= 1.0);

  bool get _labourUnavailable =>
      widget.mode == _HomeMode.labour && (widget.item.isDisabled || _labourBookedLocally);

  List<_LabourCategoryPricing> get _labourCategoryOptions {
    if (widget.item.labourCategoryPricing.isNotEmpty) {
      return widget.item.labourCategoryPricing;
    }
    return [
      _LabourCategoryPricing(
        categoryId: widget.item.backendCategoryId,
        label: widget.item.subtitle,
        halfDayPrice: widget.item.labourHalfDayPrice,
        fullDayPrice: widget.item.labourFullDayPrice,
      ),
    ];
  }

  String get _labourUnavailableLabel {
    if (_labourBookedLocally) {
      return 'Booked';
    }
    final label = widget.item.disabledLabel.trim();
    return label.isEmpty ? 'Booked' : label;
  }

  String get _primaryAction {
    switch (widget.mode) {
      case _HomeMode.labour:
        if (_labourUnavailable) {
          return _labourUnavailableLabel;
        }
        return _isAuthenticated ? 'Book labour' : 'Login to book labour';
      case _HomeMode.service:
        return _isAuthenticated ? 'Pay visiting charge' : 'Login to book service';
      case _HomeMode.shop:
        return 'Add item to cart';
      case _HomeMode.all:
        return 'Continue';
    }
  }

  String get _description {
    switch (widget.mode) {
      case _HomeMode.labour:
        return 'Full mobile number will be visible only after the labour is booked and payment is completed.';
      case _HomeMode.service:
        return 'Book after checking category, rating, visit charge and service range. If provider does not reach in time, visiting charge can be refunded.';
      case _HomeMode.shop:
        return 'Add items from the same shop in one cart. If you try a different shop, the app will warn before replacing the cart.';
      case _HomeMode.all:
        return 'Open the profile and continue with booking, service or shopping based on the selected category.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final mode = widget.mode;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F2EC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          item.title,
          style: const TextStyle(color: Color(0xFF22314D), fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            onPressed: mode == _HomeMode.shop ? widget.onWishlistToggle : widget.onFavouriteToggle,
            icon: Icon(
              mode == _HomeMode.shop
                  ? (widget.isWishlisted ? Icons.bookmark_rounded : Icons.bookmark_border_rounded)
                  : (widget.isFavourited ? Icons.favorite_rounded : Icons.favorite_border_rounded),
              color: mode == _HomeMode.shop
                  ? const Color(0xFF4DAF50)
                  : const Color(0xFFCB6E5B),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 32),
        children: [
          Container(
            height: mode == _HomeMode.labour ? 176 : 240,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  item.accent.withValues(alpha: 0.18),
                  item.accent.withValues(alpha: 0.6),
                ],
              ),
              borderRadius: BorderRadius.circular(28),
            ),
            clipBehavior: Clip.antiAlias,
            child: mode == _HomeMode.labour
                ? Center(
                    child: AspectRatio(
                      aspectRatio: 0.72,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          _LabourPortraitImage(
                            item: item,
                            fit: BoxFit.cover,
                            scale: 1,
                            alignment: Alignment.topCenter,
                          ),
                          if (_labourUnavailable)
                            Positioned(
                              left: -8,
                              bottom: 56,
                              child: _LabourAvailabilityRibbon(label: _labourUnavailableLabel),
                            ),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.05),
                                  Colors.black.withValues(alpha: 0.44),
                                ],
                                stops: const [0.48, 0.72, 1],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Center(
                    child: Icon(item.icon, size: 88, color: Colors.white),
                  ),
            ),
          const SizedBox(height: 20),
          Text(
            item.title,
            style: TextStyle(
              color: const Color(0xFF22314D),
              fontSize: mode == _HomeMode.labour ? 24 : 28,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: mode == _HomeMode.labour ? 5 : 8),
          Text(
            item.subtitle,
            style: TextStyle(
              color: const Color(0xFF6D7A91),
              fontWeight: FontWeight.w700,
              fontSize: mode == _HomeMode.labour ? 14 : 16,
            ),
          ),
          SizedBox(height: mode == _HomeMode.labour ? 10 : 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              if (item.rating.isNotEmpty)
                _MetaPill(icon: Icons.star_rounded, value: item.rating, color: _ratingColor(item.rating)),
              _MetaPill(icon: Icons.place_rounded, value: _distanceLabel, color: const Color(0xFF5C8FD8)),
              if (_isNearbyLabour)
                const _MetaPill(
                  icon: Icons.eco_rounded,
                  value: 'Nearby',
                  color: Color(0xFF18A957),
                ),
              if (item.price.isNotEmpty && mode != _HomeMode.labour)
                _MetaPill(icon: Icons.currency_rupee_rounded, value: item.price, color: item.accent),
            ],
          ),
          if (mode == _HomeMode.labour) ...[
            const SizedBox(height: 10),
            _labourCategorySelector(),
            if (_labourUnavailable) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE8DCD6)),
                ),
                child: Text(
                  '${item.title} is ${_labourUnavailableLabel.toLowerCase()} right now. Booking will be enabled once the labour becomes available again.',
                  style: const TextStyle(
                    color: Color(0xFF66748C),
                    height: 1.35,
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                  ),
                ),
              ),
            ],
          ],
          SizedBox(height: mode == _HomeMode.labour ? 12 : 18),
          Container(
            padding: EdgeInsets.all(mode == _HomeMode.labour ? 12 : 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Profile details',
                  style: TextStyle(
                    color: Color(0xFF22314D),
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: mode == _HomeMode.labour ? 9 : 12),
                if (mode != _HomeMode.labour) _detailRow('Name', item.title),
                if (mode != _HomeMode.labour && mode != _HomeMode.service) ...[
                  _detailRow('Rating', item.rating),
                  _detailRow('Distance', item.distance),
                  _detailRow('Price', item.price.isEmpty ? 'As per profile' : item.price),
                ],
                if (mode == _HomeMode.labour)
                  _detailRow(
                    'Distance',
                    _isNearbyLabour ? '$_distanceLabel • Nearby' : _distanceLabel,
                  ),
                _detailRow('Experience', '5+ years'),
                _detailRow('Booking success', item.extra.isEmpty ? '124 successful' : item.extra),
                _detailRow(mode == _HomeMode.labour ? 'Masked mobile no.' : 'Mobile no.', item.maskedPhone),
              ],
            ),
          ),
          if (mode == _HomeMode.shop) ...[
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cart and delivery notes',
                    style: TextStyle(
                      color: Color(0xFF22314D),
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _detailRow('Cart rule', 'Same shop only'),
                  _detailRow('Delivery', 'Based on shop threshold'),
                  _detailRow('Platform fee', 'Added at checkout'),
                  _detailRow('Cancellation', 'Allowed before out for delivery'),
                ],
              ),
            ),
          ],
          if (mode != _HomeMode.labour && mode != _HomeMode.service) ...[
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                _description,
                style: const TextStyle(
                  color: Color(0xFF66748C),
                  height: 1.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
          SizedBox(height: mode == _HomeMode.labour || mode == _HomeMode.service ? 12 : 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _labourUnavailable
                  ? null
                  : () async {
                      if (_primaryActionBusy) {
                        return;
                      }
                      if (mode == _HomeMode.labour && !_isAuthenticated) {
                        await _openLoginBeforeBooking();
                        return;
                      }
                      if (mode == _HomeMode.service && !_isAuthenticated) {
                        await _openLoginBeforeBooking();
                        return;
                      }
                      if (mode == _HomeMode.labour && _selectedLabourBookingPeriod == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please select Half Day or Full Day to book labour.')),
                        );
                        return;
                      }
                      if (mode == _HomeMode.labour && _selectedLabourCategoryId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please select the work category to book labour.')),
                        );
                        return;
                      }
                      setState(() => _primaryActionBusy = true);
                      try {
                        final bookingLocked = await widget.onPrimaryAction(
                          _selectedLabourBookingPeriod,
                          _selectedLabourCategoryId,
                        );
                        await _refreshAuthStateFromSession();
                        if (mounted && mode == _HomeMode.labour && bookingLocked) {
                          setState(() {
                            _labourBookedLocally = true;
                          });
                        }
                      } finally {
                        if (mounted) {
                          setState(() => _primaryActionBusy = false);
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFCB6E5B),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  vertical: mode == _HomeMode.labour || mode == _HomeMode.service ? 14 : 18,
                ),
                shape: const RoundedRectangleBorder(),
              ),
              child: _primaryActionBusy
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.6,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      mode != _HomeMode.labour || _selectedLabourBookingPeriod == null
                          ? _primaryAction
                          : 'Book $_selectedLabourBookingPeriod labour',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                    ),
            ),
          ),
          if (mode == _HomeMode.labour || mode == _HomeMode.service) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                _description,
                style: const TextStyle(
                  color: Color(0xFF66748C),
                  height: 1.35,
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                ),
              ),
            ),
          ],
          const SizedBox(height: 26),
          const _MadeWithLoveFooter(),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF7A879B),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF22314D),
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _labourCategorySelector() {
    final options = _labourCategoryOptions;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEED8CF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select work category and duration',
            style: TextStyle(
              color: Color(0xFF22314D),
              fontSize: 13,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Choose the category first, then select Half Day or Full Day pricing for that exact work.',
            style: TextStyle(
              color: Color(0xFF66748C),
              fontWeight: FontWeight.w700,
              fontSize: 12.5,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          ...options.map((pricing) {
            final categorySelected = pricing.categoryId == _selectedLabourCategoryId;
            final halfSelected = categorySelected && _selectedLabourBookingPeriod == 'Half Day';
            final fullSelected = categorySelected && _selectedLabourBookingPeriod == 'Full Day';
            final halfUnavailable = _priceLabelOrUnavailable(pricing.halfDayPrice) == 'Not available';
            final fullUnavailable = _priceLabelOrUnavailable(pricing.fullDayPrice) == 'Not available';
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: categorySelected ? const Color(0xFFFFF5EF) : const Color(0xFFFFFAF7),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: categorySelected ? const Color(0xFFCB6E5B) : const Color(0xFFE8DCD6),
                    width: categorySelected ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            pricing.label,
                            style: const TextStyle(
                              color: Color(0xFF22314D),
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        if (categorySelected)
                          const Icon(Icons.check_circle_rounded, color: Color(0xFFCB6E5B), size: 20),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _labourCategoryPriceTile(
                            categoryId: pricing.categoryId,
                            label: 'Half Day',
                            value: _priceLabelOrUnavailable(pricing.halfDayPrice),
                            icon: Icons.wb_twilight_rounded,
                            color: const Color(0xFFF2A13D),
                            selected: halfSelected,
                            unavailable: halfUnavailable,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _labourCategoryPriceTile(
                            categoryId: pricing.categoryId,
                            label: 'Full Day',
                            value: _priceLabelOrUnavailable(pricing.fullDayPrice),
                            icon: Icons.wb_sunny_rounded,
                            color: const Color(0xFFCB6E5B),
                            selected: fullSelected,
                            unavailable: fullUnavailable,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _labourCategoryPriceTile({
    required int? categoryId,
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required bool selected,
    required bool unavailable,
  }) {
    return GestureDetector(
      onTap: _labourUnavailable || unavailable
          ? null
          : () => setState(() {
                _selectedLabourCategoryId = categoryId;
                _selectedLabourBookingPeriod = label;
              }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: _labourUnavailable || unavailable
              ? const Color(0xFFF5F1ED)
              : (selected ? color.withValues(alpha: 0.16) : Colors.white),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _labourUnavailable || unavailable
                ? const Color(0xFFE8DCD6)
                : (selected ? color : const Color(0xFFE8DCD6)),
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 7),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: selected ? color : const Color(0xFF22314D),
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    value,
                    style: const TextStyle(
                      color: Color(0xFF22314D),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              Padding(
                padding: const EdgeInsets.only(left: 4, top: 1),
                child: Icon(Icons.check_circle_rounded, color: color, size: 17),
              ),
          ],
        ),
      ),
    );
  }

  String _priceLabelOrUnavailable(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty || trimmed == '₹0') {
      return 'Not available';
    }
    return trimmed;
  }

}

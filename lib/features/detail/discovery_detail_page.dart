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
  String? _selectedServiceItemLabel;
  late bool _isAuthenticated;
  bool _labourBookedLocally = false;
  bool _primaryActionBusy = false;

  @override
  void initState() {
    super.initState();
    _isAuthenticated = widget.isAuthenticated;
    _selectedLabourCategoryId = _defaultSelectedLabourCategoryId;
    _selectedServiceItemLabel = _defaultSelectedServiceItemLabel;
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
      _selectedLabourCategoryId = _defaultSelectedLabourCategoryId;
      _selectedLabourBookingPeriod = null;
    }
    if (oldWidget.item.serviceItems != widget.item.serviceItems ||
        oldWidget.item.serviceTileLabel != widget.item.serviceTileLabel ||
        oldWidget.item.backendServiceProviderId != widget.item.backendServiceProviderId) {
      _selectedServiceItemLabel = _defaultSelectedServiceItemLabel;
    }
  }

  int? get _defaultSelectedLabourCategoryId {
    final preferredCategoryId = widget.item.backendCategoryId;
    if (preferredCategoryId != null &&
        _labourCategoryOptions.any((pricing) => pricing.categoryId == preferredCategoryId)) {
      return preferredCategoryId;
    }
    return _labourCategoryOptions.firstOrNull?.categoryId;
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

  double? get _ratingValue {
    final parsed = double.tryParse(widget.item.rating.trim());
    if (parsed == null || parsed <= 0) {
      return null;
    }
    return parsed.clamp(0, 5).toDouble();
  }

  Color get _bandedRatingColor {
    final rating = _ratingValue ?? 0;
    if (rating >= 5) {
      return const Color(0xFF157F3B);
    }
    if (rating >= 4) {
      return const Color(0xFF4FBF68);
    }
    if (rating >= 3) {
      return const Color(0xFFE0B321);
    }
    if (rating >= 2) {
      return const Color(0xFFE26A5B);
    }
    return const Color(0xFF9E2332);
  }

  int get _filledRatingStars {
    final rating = _ratingValue;
    if (rating == null || rating <= 0) {
      return 0;
    }
    return rating.floor().clamp(1, 5);
  }

  String get _labourExperienceLabel {
    final years = widget.item.experienceYears;
    if (years == null || years <= 0) {
      return '0 years';
    }
    return years == 1 ? '1 year' : '$years years';
  }

  String get _completedJobsLabel {
    final count = widget.item.completedJobsCount;
    if (count != null) {
      return '$count';
    }
    final digits = RegExp(r'\d+').firstMatch(widget.item.extra)?.group(0);
    return digits ?? '0';
  }

  bool get _isNearbyLabour =>
      widget.mode == _HomeMode.labour && (_distanceKm != null && _distanceKm! <= 1.0);

  Widget _buildLabourDistanceAndRatingRow(_DiscoveryItem item) {
    final distanceColor = _isNearbyLabour ? const Color(0xFF18A957) : const Color(0xFF5C8FD8);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.place_rounded,
              size: 16,
              color: distanceColor,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                _isNearbyLabour ? '$_distanceLabel Nearby' : _distanceLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: distanceColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        if (item.hasRating) ...[
          const SizedBox(height: 6),
          Wrap(
            spacing: 2,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (var index = 0; index < 5; index++)
                Icon(
                  index < _filledRatingStars ? Icons.star_rounded : Icons.star_border_rounded,
                  size: 14,
                  color: index < _filledRatingStars ? _bandedRatingColor : const Color(0xFFD3D8E2),
                ),
              const SizedBox(width: 2),
              Text(
                item.rating,
                style: TextStyle(
                  color: _bandedRatingColor,
                  fontSize: 12.8,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  bool get _labourUnavailable =>
      widget.mode == _HomeMode.labour && (widget.item.isDisabled || _labourBookedLocally);

  List<_LabourCategoryPricing> get _labourCategoryOptions {
    if (widget.item.labourCategoryPricing.isNotEmpty) {
      final normalized = <_LabourCategoryPricing>[];
      final seenCategoryIds = <int?>{};
      for (final pricing in widget.item.labourCategoryPricing) {
        if (!seenCategoryIds.add(pricing.categoryId)) {
          continue;
        }
        final normalizedLabel = pricing.label
            .split(',')
            .map((part) => part.trim())
            .firstWhere((part) => part.isNotEmpty, orElse: () => pricing.label.trim());
        normalized.add(
          _LabourCategoryPricing(
            categoryId: pricing.categoryId,
            label: normalizedLabel,
            halfDayPrice: pricing.halfDayPrice,
            fullDayPrice: pricing.fullDayPrice,
          ),
        );
      }
      return normalized;
    }
    return [
      _LabourCategoryPricing(
        categoryId: widget.item.backendCategoryId,
        label: widget.item.subtitle
            .split(',')
            .map((part) => part.trim())
            .firstWhere((part) => part.isNotEmpty, orElse: () => widget.item.subtitle.trim()),
        halfDayPrice: widget.item.labourHalfDayPrice,
        fullDayPrice: widget.item.labourFullDayPrice,
      ),
    ];
  }

  List<String> get _serviceCategoryOptions {
    final options = <String>[];
    for (final serviceItem in widget.item.serviceItems) {
      final normalized = serviceItem.trim();
      if (normalized.isNotEmpty && !options.contains(normalized)) {
        options.add(normalized);
      }
    }
    final fallback = widget.item.serviceTileLabel.trim().isNotEmpty
        ? widget.item.serviceTileLabel.trim()
        : widget.item.subtitle.trim().isNotEmpty
            ? widget.item.subtitle.trim()
            : widget.item.title.trim();
    if (fallback.isNotEmpty && !options.contains(fallback)) {
      options.insert(0, fallback);
    }
    return options.isEmpty ? const <String>['Service'] : options;
  }

  String get _defaultSelectedServiceItemLabel {
    final preferred = widget.item.serviceTileLabel.trim();
    if (preferred.isNotEmpty && _serviceCategoryOptions.contains(preferred)) {
      return preferred;
    }
    return _serviceCategoryOptions.first;
  }

  String get _serviceTilePriceLabel => widget.item.price.isEmpty ? 'Visit charge on request' : widget.item.price;

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
        return '';
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
          if (mode == _HomeMode.labour)
            _buildLabourProfileHeader(item)
          else if (mode == _HomeMode.service)
            _buildServiceProfileHeader(item)
          else ...[
            Container(
              height: 240,
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
              child: Center(
                child: Icon(item.icon, size: 88, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              item.title,
              style: const TextStyle(
                color: Color(0xFF22314D),
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.subtitle,
              style: const TextStyle(
                color: Color(0xFF6D7A91),
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                if (item.hasRating)
                  _MetaPill(icon: Icons.star_rounded, value: item.rating, color: _ratingColor(item.rating)),
                _MetaPill(icon: Icons.place_rounded, value: _distanceLabel, color: const Color(0xFF5C8FD8)),
                if (item.price.isNotEmpty) _MetaPill(icon: Icons.currency_rupee_rounded, value: item.price, color: item.accent),
              ],
            ),
          ],
          if (mode == _HomeMode.labour) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8F3),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFEAD9CE)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Work duration',
                    style: TextStyle(
                      color: Color(0xFF22314D),
                      fontWeight: FontWeight.w900,
                      fontSize: 13.5,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Full day: 8 hr including lunch',
                    style: TextStyle(
                      color: Color(0xFF66748C),
                      fontWeight: FontWeight.w700,
                      fontSize: 12.5,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Half day: 4 hr working',
                    style: TextStyle(
                      color: Color(0xFF66748C),
                      fontWeight: FontWeight.w700,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
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
          if (mode == _HomeMode.service) ...[
            const SizedBox(height: 10),
            _serviceCategorySelector(),
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
                    'Profile details',
                    style: TextStyle(
                      color: Color(0xFF22314D),
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _detailRow('Name', item.title),
                  _detailRow('Category', item.subtitle),
                  _detailRow('Visit charge', item.price.isEmpty ? 'As per profile' : item.price),
                  _detailRow('Distance', item.distance),
                  _detailRow('Total bookings', _completedJobsLabel),
                  _detailRow('Mobile', item.maskedPhone),
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
                  const SizedBox(height: 12),
                  _detailRow('Name', item.title),
                  if (mode != _HomeMode.service) ...[
                    if (item.hasRating) _detailRow('Rating', item.rating),
                    _detailRow('Distance', item.distance),
                    _detailRow('Price', item.price.isEmpty ? 'As per profile' : item.price),
                  ],
                  _detailRow('Experience', '5+ years'),
                  _detailRow('Booking success', item.extra.isEmpty ? '124 successful' : item.extra),
                  _detailRow('Mobile no.', item.maskedPhone),
                ],
              ),
            ),
          ],
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
          if ((mode == _HomeMode.labour || mode == _HomeMode.service) && _description.isNotEmpty) ...[
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

  Widget _buildServiceProfileHeader(_DiscoveryItem item) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A2030).withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 124,
            height: 170,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          item.accent.withValues(alpha: 0.18),
                          item.accent.withValues(alpha: 0.55),
                        ],
                      ),
                    ),
                  ),
                  _LabourPortraitImage(
                    item: item,
                    fit: BoxFit.cover,
                    scale: 1,
                    alignment: Alignment.topCenter,
                  ),
                  if (item.isDisabled)
                    Positioned(
                      left: -4,
                      bottom: 48,
                      child: _LabourAvailabilityRibbon(label: item.disabledLabel.trim().isEmpty ? 'Offline' : item.disabledLabel),
                    ),
                ],
              ),
            ),
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
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    height: 1.08,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF6D7A91),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                _buildLabourDistanceAndRatingRow(item),
                const SizedBox(height: 10),
                _labourInfoLine(
                  label: 'Visit charge',
                  value: _serviceTilePriceLabel,
                ),
                const SizedBox(height: 8),
                _labourInfoLine(
                  label: 'Total bookings',
                  value: _completedJobsLabel,
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.phone_android_rounded,
                      size: 15,
                      color: Color(0xFF8090A6),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        item.maskedPhone,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF22314D),
                          fontWeight: FontWeight.w800,
                          fontSize: 12.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _serviceCategorySelector() {
    final options = _serviceCategoryOptions;
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: options.map((label) {
        final selected = label == _selectedServiceItemLabel;
        return InkWell(
          onTap: () => setState(() => _selectedServiceItemLabel = label),
          borderRadius: BorderRadius.circular(18),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: options.length == 1 ? double.infinity : null,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: selected ? const Color(0xFFFFF1EB) : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: selected ? const Color(0xFFCB6E5B) : const Color(0xFFE8DCD6),
                width: selected ? 1.8 : 1.1,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: const Color(0xFFCB6E5B).withValues(alpha: 0.10),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : const [],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: const Color(0xFF22314D),
                    fontSize: 15,
                    fontWeight: selected ? FontWeight.w900 : FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _serviceTilePriceLabel,
                  style: TextStyle(
                    color: selected ? const Color(0xFFCB6E5B) : const Color(0xFF66748C),
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(growable: false),
    );
  }

  Widget _buildLabourProfileHeader(_DiscoveryItem item) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A2030).withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 124,
            height: 170,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          item.accent.withValues(alpha: 0.18),
                          item.accent.withValues(alpha: 0.55),
                        ],
                      ),
                    ),
                  ),
                  _LabourPortraitImage(
                    item: item,
                    fit: BoxFit.cover,
                    scale: 1,
                    alignment: Alignment.topCenter,
                  ),
                  if (_labourUnavailable)
                    Positioned(
                      left: -4,
                      bottom: 48,
                      child: _LabourAvailabilityRibbon(label: _labourUnavailableLabel),
                    ),
                ],
              ),
            ),
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
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    height: 1.08,
                  ),
                ),
                const SizedBox(height: 8),
                _buildLabourDistanceAndRatingRow(item),
                const SizedBox(height: 10),
                _labourInfoLine(
                  label: 'Experience',
                  value: _labourExperienceLabel,
                ),
                const SizedBox(height: 8),
                _labourInfoLine(
                  label: 'Total bookings',
                  value: _completedJobsLabel,
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3EEE9),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.phone_rounded,
                        size: 14,
                        color: Color(0xFF66748C),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.maskedPhone,
                              style: const TextStyle(
                                color: Color(0xFF22314D),
                                fontWeight: FontWeight.w900,
                                fontSize: 13.2,
                              ),
                            ),
                          ),
                          InkWell(
                            borderRadius: BorderRadius.circular(999),
                            onTap: _showPhoneUnmaskInfo,
                            child: Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3EEE9),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Icon(
                                Icons.info_outline_rounded,
                                size: 14,
                                color: Color(0xFF66748C),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _labourInfoLine({
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 86,
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF7A879B),
              fontWeight: FontWeight.w700,
              fontSize: 12.5,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFF22314D),
              fontWeight: FontWeight.w900,
              fontSize: 13.2,
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }

  void _showPhoneUnmaskInfo() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Full mobile number will be visible only after the labour is booked and payment is completed.'),
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
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final tileWidth = (constraints.maxWidth - 10) / 2;
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: options.map((pricing) {
                  final categorySelected = pricing.categoryId == _selectedLabourCategoryId;
                  final halfSelected = categorySelected && _selectedLabourBookingPeriod == 'Half Day';
                  final fullSelected = categorySelected && _selectedLabourBookingPeriod == 'Full Day';
                  final halfUnavailable = _priceLabelOrUnavailable(pricing.halfDayPrice) == 'Not available';
                  final fullUnavailable = _priceLabelOrUnavailable(pricing.fullDayPrice) == 'Not available';
                  return SizedBox(
                    width: tileWidth,
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  pricing.label,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Color(0xFF22314D),
                                    fontWeight: FontWeight.w900,
                                    height: 1.15,
                                  ),
                                ),
                              ),
                              if (categorySelected)
                                const Padding(
                                  padding: EdgeInsets.only(left: 6, top: 1),
                                  child: Icon(Icons.check_circle_rounded, color: Color(0xFFCB6E5B), size: 18),
                                ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          _labourCategoryPriceTile(
                            categoryId: pricing.categoryId,
                            label: 'Half Day',
                            value: _priceLabelOrUnavailable(pricing.halfDayPrice),
                            icon: Icons.wb_twilight_rounded,
                            color: const Color(0xFFF2A13D),
                            selected: halfSelected,
                            unavailable: halfUnavailable,
                          ),
                          const SizedBox(height: 8),
                          _labourCategoryPriceTile(
                            categoryId: pricing.categoryId,
                            label: 'Full Day',
                            value: _priceLabelOrUnavailable(pricing.fullDayPrice),
                            icon: Icons.wb_sunny_rounded,
                            color: const Color(0xFFCB6E5B),
                            selected: fullSelected,
                            unavailable: fullUnavailable,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(growable: false),
              );
            },
          ),
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

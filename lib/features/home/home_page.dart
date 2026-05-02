part of '../../main.dart';

class _ActiveBookingPopupVisibilityController {
  static final ValueNotifier<DateTime?> hiddenUntil = ValueNotifier<DateTime?>(
    null,
  );
  static Timer? _restoreTimer;

  static bool get isHidden {
    final value = hiddenUntil.value;
    return value != null && DateTime.now().isBefore(value);
  }

  static void dismissForDuration(Duration duration) {
    _restoreTimer?.cancel();
    final until = DateTime.now().add(duration);
    hiddenUntil.value = until;
    _restoreTimer = Timer(duration, () {
      if (hiddenUntil.value == until) {
        hiddenUntil.value = null;
      }
    });
  }

  static void clear() {
    _restoreTimer?.cancel();
    _restoreTimer = null;
    if (hiddenUntil.value != null) {
      hiddenUntil.value = null;
    }
  }
}

class _PaymentInvoiceLine {
  const _PaymentInvoiceLine({required this.label, required this.value});

  final String label;
  final String value;
}

class _InvoicePaymentResult<T> {
  const _InvoicePaymentResult({
    required this.payment,
    required this.paymentFlowResult,
  });

  final T payment;
  final _PaymentFlowResult paymentFlowResult;
}

class _HomeLocationChoice {
  const _HomeLocationChoice({
    required this.title,
    required this.subtitle,
    required this.city,
    required this.latitude,
    required this.longitude,
    this.addressId,
    this.isCurrentLocation = false,
  });

  final String title;
  final String subtitle;
  final String city;
  final double latitude;
  final double longitude;
  final int? addressId;
  final bool isCurrentLocation;
}

class _HomeLocationSearchSuggestion {
  const _HomeLocationSearchSuggestion({
    required this.placeId,
    required this.title,
    required this.subtitle,
    required this.description,
    this.latitude,
    this.longitude,
    this.city = '',
  });

  final String placeId;
  final String title;
  final String subtitle;
  final String description;
  final double? latitude;
  final double? longitude;
  final String city;
}

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key, this.phoneNumber});

  final String? phoneNumber;

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  static const Set<String> _shopComingSoonCategories = <String>{};
  static const double _savedAddressSnapDistanceMeters = 100;
  static const double _activeBookingPopupDragSpeedMultiplier = 1.85;
  static const String _singleLabourQuickBookOpenBudget = '99999999';
  static const String _androidPlacesApiKey =
      'AIzaSyA51i0ow9o6wBQzJ1km94Hv_9g2rzesgRA';
  static const String _iosPlacesApiKey =
      'AIzaSyBSV5mUsHDu_XcocYqRaFfGOERKsggAdyQ';
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final Set<String> _favouriteProfiles = <String>{};
  final Set<String> _wishlistedItems = <String>{};
  final List<_DiscoveryItem> _cartItems = <_DiscoveryItem>[];
  final List<_DiscoveryItem> _backendTopProducts = <_DiscoveryItem>[];
  final List<_DiscoveryItem> _labourRemoteProfiles = <_DiscoveryItem>[];
  final List<_DiscoveryItem> _serviceRemoteProviders = <_DiscoveryItem>[];
  final List<_DiscoveryItem> _restaurantRemoteProducts = <_DiscoveryItem>[];
  final List<_FashionRemoteProduct> _fashionRemoteProducts =
      <_FashionRemoteProduct>[];
  final List<_FootwearRemoteProduct> _footwearRemoteProducts =
      <_FootwearRemoteProduct>[];
  final List<_RestaurantRemoteShopSummary> _restaurantRemoteShops =
      <_RestaurantRemoteShopSummary>[];
  final List<_FashionRemoteShopSummary> _fashionRemoteShops =
      <_FashionRemoteShopSummary>[];
  final List<_FootwearRemoteShopSummary> _footwearRemoteShops =
      <_FootwearRemoteShopSummary>[];
  final List<_GiftRemoteProduct> _giftRemoteProducts = <_GiftRemoteProduct>[];
  final List<_GiftRemoteShopSummary> _giftRemoteShops =
      <_GiftRemoteShopSummary>[];
  final List<_GroceryRemoteProduct> _groceryRemoteProducts =
      <_GroceryRemoteProduct>[];
  final List<_GroceryRemoteShopSummary> _groceryRemoteShops =
      <_GroceryRemoteShopSummary>[];
  final List<_PharmacyRemoteProduct> _pharmacyRemoteProducts =
      <_PharmacyRemoteProduct>[];
  final List<_PharmacyRemoteShopSummary> _pharmacyRemoteShops =
      <_PharmacyRemoteShopSummary>[];

  _HomeMode _mode = _HomeMode.all;
  _LabourViewMode _labourViewMode = _LabourViewMode.individual;
  _ShopBrowseMode _shopBrowseMode = _ShopBrowseMode.itemWise;
  String _selectedServiceCategory = '';
  String _selectedServiceSubCategory = '';
  String _selectedServiceSort = 'Best service';
  String _selectedShopCategory = 'All Deals';
  String _selectedShopSubCategory = 'All';
  String _selectedRestaurantCuisine = 'All';
  String _selectedLabourCategory = '';
  String _selectedSingleLabourPeriod = 'All';
  String _selectedSingleLabourMaxPrice = '';
  String _selectedLabourPrice = '';
  String _selectedLabourPricePeriod = 'Full Day';
  int _selectedLabourCount = 1;
  int _maxGroupLabourCount = 7;
  String _labourBookingChargePerLabour = '5%';
  bool _showLabourPriceError = false;
  bool _showLabourCountError = false;
  String? _labourCountErrorText;
  String? _cartShopName;
  int _notificationUnreadCount = 0;
  List<_ActiveBookingStatus> _activeBookingStatuses =
      const <_ActiveBookingStatus>[];
  int _activeBookingIndex = 0;
  Offset _activeBookingPopupOffset = Offset.zero;
  bool _activeBookingPopupPositionInitialized = false;
  bool _activeBookingPopupDragMoved = false;
  List<_UserAddressData> _savedAddresses = const <_UserAddressData>[];
  _HomeLocationChoice? _currentLocationChoice;
  _HomeLocationChoice? _selectedLocationChoice;
  bool _homeLocationLoading = true;
  String? _homeLocationError;
  bool _cartPageOpening = false;
  bool _showScrollToTop = false;
  bool _remoteSyncInFlight = false;
  bool _labourRemoteLoading = false;
  bool _serviceRemoteLoading = false;
  bool _restaurantRemoteLoading = false;
  bool _fashionRemoteLoading = false;
  bool _footwearRemoteLoading = false;
  bool _giftRemoteLoading = false;
  bool _groceryRemoteLoading = false;
  bool _pharmacyRemoteLoading = false;
  bool _fashionRemoteReady = false;
  bool _fashionRemoteHasMore = false;
  bool _footwearRemoteReady = false;
  bool _footwearRemoteHasMore = false;
  bool _giftRemoteReady = false;
  bool _giftRemoteHasMore = false;
  bool _groceryRemoteReady = false;
  bool _groceryRemoteHasMore = false;
  bool _pharmacyRemoteReady = false;
  bool _pharmacyRemoteHasMore = false;
  bool _labourRemoteReady = false;
  bool _serviceRemoteReady = false;
  String? _labourRemoteError;
  String? _serviceRemoteError;
  String? _restaurantRemoteError;
  String? _fashionRemoteError;
  String? _footwearRemoteError;
  String? _giftRemoteError;
  String? _groceryRemoteError;
  String? _pharmacyRemoteError;
  String _shopSortOption = 'Popular';
  List<_RemoteLabourCategory> _labourRemoteCategories =
      const <_RemoteLabourCategory>[];
  List<_RemoteServiceCategory> _serviceRemoteCategories =
      const <_RemoteServiceCategory>[];
  List<_RestaurantCuisineItem> _restaurantRemoteCuisines =
      const <_RestaurantCuisineItem>[];
  List<_FashionRemoteCategory> _fashionRemoteCategories =
      const <_FashionRemoteCategory>[];
  List<_FootwearRemoteCategory> _footwearRemoteCategories =
      const <_FootwearRemoteCategory>[];
  List<_GiftRemoteCategory> _giftRemoteCategories =
      const <_GiftRemoteCategory>[];
  List<_GroceryRemoteCategory> _groceryRemoteCategories =
      const <_GroceryRemoteCategory>[];
  List<_PharmacyRemoteCategory> _pharmacyRemoteCategories =
      const <_PharmacyRemoteCategory>[];
  int _fashionVisibleProductCount = _fashionProductBatchSize;
  int _fashionRemotePage = 0;
  int _footwearVisibleProductCount = _footwearProductBatchSize;
  int _footwearRemotePage = 0;
  int _giftRemotePage = 0;
  int _groceryRemotePage = 0;
  int _pharmacyRemotePage = 0;
  bool _fashionLoadMoreQueued = false;
  bool _footwearLoadMoreQueued = false;
  bool _initialHomeSetupRunning = false;
  bool _localCartNeedsSync = false;
  bool _discoveryDetailNavigationInFlight = false;
  String _headerProfilePhotoDataUri = '';
  String _headerProfilePhotoObjectKey = '';
  _UserProfileData? _cachedUserProfile;
  Future<_UserProfileData?>? _profilePreviewWarmupFuture;
  String? _sessionPhoneNumber;
  StreamSubscription<_NotificationEvent>? _notificationEventSubscription;
  Timer? _activeBookingRefreshTimer;
  int _discoveryBatchInFlightCount = 0;
  bool _initialDiscoveryBatchResolved = false;
  bool _clearingExpiredSession = false;
  final Set<int> _announcedArrivedBookingIds = <int>{};

  static const int _fashionProductBatchSize = 20;
  static const int _fashionProductTotalCount = 120;
  static const int _footwearProductBatchSize = 20;
  static const int _footwearProductTotalCount = 120;

  @override
  void initState() {
    super.initState();
    _sessionPhoneNumber = widget.phoneNumber?.trim();
    _scrollController.addListener(_handleScroll);
    _searchController.addListener(_handleSearchChanged);
    _notificationEventSubscription = _NotificationBootstrap.events.listen(
      _handleNotificationEvent,
    );
    _ActiveBookingPopupVisibilityController.hiddenUntil.addListener(
      _handleActiveBookingPopupVisibilityChanged,
    );
    unawaited(_warmProfilePreviewOnAppOpen());
    unawaited(_hydrateRemoteState());
    unawaited(_loadLabourBookingPolicy());
    _syncActiveBookingRefreshPolling();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_initializeHomeRequirements());
      final pendingEvent = _NotificationBootstrap.takePendingOpenEvent();
      if (pendingEvent != null) {
        unawaited(_handleNotificationEvent(pendingEvent));
      }
    });
  }

  @override
  void dispose() {
    _ActiveBookingPopupVisibilityController.hiddenUntil.removeListener(
      _handleActiveBookingPopupVisibilityChanged,
    );
    _notificationEventSubscription?.cancel();
    _activeBookingRefreshTimer?.cancel();
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    _searchController.removeListener(_handleSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  _ActiveBookingStatus? get _activeBookingStatus {
    if (_activeBookingStatuses.isEmpty) {
      return null;
    }
    final safeIndex = _activeBookingIndex.clamp(
      0,
      _activeBookingStatuses.length - 1,
    );
    return _activeBookingStatuses[safeIndex];
  }

  void _handleSearchChanged() {
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  void _handleActiveBookingPopupVisibilityChanged() {
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  double _servicePriceSortValue(_DiscoveryItem item) {
    final match = RegExp(r'([0-9]+(?:\.[0-9]+)?)').firstMatch(item.price);
    if (match == null) {
      return double.infinity;
    }
    return double.tryParse(match.group(1)!) ?? double.infinity;
  }

  bool _matchesServiceSearch(_DiscoveryItem item, String normalizedQuery) {
    if (normalizedQuery.isEmpty) {
      return true;
    }
    final haystacks = <String>[
      item.title,
      item.subtitle,
      item.serviceTileLabel,
      ...item.serviceItems,
    ];
    return haystacks.any(
      (value) => value.toLowerCase().contains(normalizedQuery),
    );
  }

  String _deriveSelectedServiceTileLabel(_DiscoveryItem item) {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      for (final serviceItem in item.serviceItems) {
        if (serviceItem.toLowerCase().contains(query)) {
          return serviceItem;
        }
      }
    }
    if (item.serviceTileLabel.trim().isNotEmpty) {
      return item.serviceTileLabel.trim();
    }
    if (item.title.trim().isNotEmpty) {
      return item.title.trim();
    }
    return item.serviceItems.firstOrNull ?? 'Service';
  }

  void _setActiveBookingStatuses(List<_ActiveBookingStatus> statuses) {
    _announceArrivedBookings(statuses);
    _activeBookingStatuses = statuses;
    if (_activeBookingStatuses.isEmpty) {
      _activeBookingIndex = 0;
      _activeBookingPopupPositionInitialized = false;
      _ActiveBookingPopupVisibilityController.clear();
      _syncActiveBookingRefreshPolling();
      return;
    }
    _activeBookingIndex = _activeBookingIndex.clamp(
      0,
      _activeBookingStatuses.length - 1,
    );
    _syncActiveBookingRefreshPolling();
  }

  bool _shouldPollActiveBookings() => _isAuthenticated;

  void _syncActiveBookingRefreshPolling() {
    if (!_shouldPollActiveBookings()) {
      _activeBookingRefreshTimer?.cancel();
      _activeBookingRefreshTimer = null;
      return;
    }
    _activeBookingRefreshTimer ??= Timer.periodic(const Duration(seconds: 6), (
      _,
    ) {
      if (!mounted || !_isAuthenticated) {
        return;
      }
      unawaited(_refreshActiveBookingsSilently());
    });
  }

  Future<void> _refreshActiveBookingsSilently() async {
    try {
      final statuses = await _loadActiveBookingStatusesSafe();
      if (!mounted) {
        return;
      }
      setState(() {
        _setActiveBookingStatuses(statuses);
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
    }
  }

  void _announceArrivedBookings(List<_ActiveBookingStatus> statuses) {
    final visibleBookingIds = <int>{};
    for (final status in statuses) {
      if (status.bookingId > 0) {
        visibleBookingIds.add(status.bookingId);
      }
      final bookingStatus = status.bookingStatus.trim().toUpperCase();
      if (bookingStatus != 'ARRIVED' || status.bookingId <= 0) {
        continue;
      }
      if (_announcedArrivedBookingIds.contains(status.bookingId)) {
        continue;
      }
      _announcedArrivedBookingIds.add(status.bookingId);
      unawaited(_BookingUpdateSoundPlayer.play());
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        _showLabourArrivedNotification(
          providerName: status.providerName.trim(),
        );
      });
    }
    _announcedArrivedBookingIds.removeWhere(
      (bookingId) => !visibleBookingIds.contains(bookingId),
    );
  }

  int? _bookingIdFromNotificationEvent(_NotificationEvent event) {
    return int.tryParse((event.data['bookingId'] ?? '').trim());
  }

  bool _isProviderNoShowNotification(_NotificationEvent event) {
    if (event.type == 'BOOKING_PROVIDER_NO_SHOW') {
      return true;
    }
    if (event.type != 'BOOKING_CANCELLED') {
      return false;
    }
    final message = '${event.title} ${event.body} ${event.data['reason'] ?? ''}'
        .toUpperCase();
    return message.contains('NO_SHOW') ||
        message.contains('NO SHOW') ||
        message.contains('DID NOT REACH') ||
        message.contains('REACH IN TIME');
  }

  bool _shouldPlayUserNotificationSound(_NotificationEvent event) {
    final type = event.type;
    return type == 'BOOKING_ACCEPTED' ||
        type == 'BOOKING_PROVIDER_ARRIVED' ||
        _isProviderNoShowNotification(event);
  }

  void _showBookingForegroundNotification({
    required String title,
    required String body,
    required Color backgroundColor,
    required Color iconTint,
    required Color iconSurfaceColor,
    required IconData icon,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(18, 0, 18, 110),
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        content: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconSurfaceColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconTint, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 14.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    body,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.86),
                      fontWeight: FontWeight.w700,
                      fontSize: 12.4,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLabourArrivedNotification({
    required String providerName,
    String? body,
  }) {
    _showBookingForegroundNotification(
      title: 'Labour has arrived',
      body: body?.trim().isNotEmpty == true
          ? body!.trim()
          : (providerName.isEmpty
                ? 'Your labour is now at your location.'
                : '$providerName has arrived at your location.'),
      backgroundColor: const Color(0xFF22314D),
      iconTint: const Color(0xFF79E0A1),
      iconSurfaceColor: const Color(0xFF1FA855).withValues(alpha: 0.18),
      icon: Icons.notifications_active_rounded,
    );
  }

  void _showBookingAcceptedNotification(_NotificationEvent event) {
    final body = event.body.trim().isNotEmpty
        ? event.body.trim()
        : 'Your booking has been accepted.';
    _showBookingForegroundNotification(
      title: event.title.trim().isNotEmpty
          ? event.title.trim()
          : 'Booking accepted',
      body: body,
      backgroundColor: const Color(0xFF22314D),
      iconTint: const Color(0xFF7BD5FF),
      iconSurfaceColor: const Color(0xFF4AA4D8).withValues(alpha: 0.20),
      icon: Icons.verified_rounded,
    );
  }

  void _showProviderNoShowNotification(_NotificationEvent event) {
    final body = event.body.trim().isNotEmpty
        ? event.body.trim()
        : 'Your booking was auto-cancelled because the provider did not reach in time.';
    _showBookingForegroundNotification(
      title: event.title.trim().isNotEmpty
          ? event.title.trim()
          : 'Booking cancelled',
      body: body,
      backgroundColor: const Color(0xFF5B2430),
      iconTint: const Color(0xFFFFC857),
      iconSurfaceColor: const Color(0xFFFFC857).withValues(alpha: 0.16),
      icon: Icons.error_outline_rounded,
    );
  }

  void _upsertActiveBookingStatus(_ActiveBookingStatus? status) {
    if (status == null) {
      final current = _activeBookingStatus;
      if (current == null) {
        _setActiveBookingStatuses(const <_ActiveBookingStatus>[]);
        return;
      }
      final remaining = _activeBookingStatuses
          .where((entry) => entry.requestId != current.requestId)
          .toList(growable: false);
      _setActiveBookingStatuses(remaining);
      return;
    }
    final updated = List<_ActiveBookingStatus>.from(_activeBookingStatuses);
    final matchIndex = updated.indexWhere(
      (entry) => entry.requestId == status.requestId,
    );
    if (matchIndex >= 0) {
      updated[matchIndex] = status;
      _activeBookingIndex = matchIndex;
    } else {
      updated.insert(0, status);
      _activeBookingIndex = 0;
    }
    _setActiveBookingStatuses(updated);
  }

  void _dismissActiveBookingPopupTemporarily() {
    _ActiveBookingPopupVisibilityController.dismissForDuration(
      const Duration(seconds: 30),
    );
  }

  void _markLabourBookedLocally(int labourId) {
    setState(() {
      for (var index = 0; index < _labourRemoteProfiles.length; index++) {
        final item = _labourRemoteProfiles[index];
        if (item.backendLabourId == labourId) {
          _labourRemoteProfiles[index] = item.copyWith(
            isDisabled: true,
            disabledLabel: 'Booked',
          );
        }
      }
    });
  }

  _ActiveBookingStatus _activeBookingStatusFromLabourRequest({
    required _RemoteLabourBookingResult request,
    required _RemoteLabourBookingRequestStatus status,
  }) {
    final destination = _selectedLocationChoice ?? _currentLocationChoice;
    return _ActiveBookingStatus(
      requestId: status.requestId,
      requestCode: status.requestCode,
      bookingType: 'LABOUR',
      requestStatus: status.requestStatus,
      historyStatus: '',
      providerEntityType: 'LABOUR',
      providerEntityId: null,
      providerName: status.providerName.trim().isNotEmpty
          ? status.providerName
          : request.labourName,
      providerPhone: status.providerPhone,
      quotedPriceAmount: status.quotedPriceAmount,
      totalAcceptedQuotedPriceAmount: status.totalAcceptedQuotedPriceAmount,
      totalAcceptedBookingChargeAmount: status.totalAcceptedBookingChargeAmount,
      distanceLabel: status.distanceLabel,
      providerPhotoUrl: '',
      providerLatitude: null,
      providerLongitude: null,
      destinationLatitude: destination?.latitude,
      destinationLongitude: destination?.longitude,
      paymentDueAt: null,
      reachByAt: null,
      labourPricingModel: '',
      categoryLabel: '',
      subcategoryLabel: '',
      bookingId: status.bookingId,
      bookingCode: status.bookingCode,
      bookingStatus: status.bookingStatus,
      paymentStatus: status.paymentStatus,
      cancelReason: '',
      reviewRating: null,
      reviewComment: '',
      createdAt: DateTime.now(),
      canMakePayment: status.canMakePayment,
      reviewSubmitted: false,
    );
  }

  _ActiveBookingStatus _activeBookingStatusFromServiceRequest({
    required _RemoteServiceBookingResult request,
    required _RemoteServiceBookingRequestStatus status,
  }) {
    final destination = _selectedLocationChoice ?? _currentLocationChoice;
    return _ActiveBookingStatus(
      requestId: status.requestId,
      requestCode: status.requestCode,
      bookingType: 'SERVICE',
      requestStatus: status.requestStatus,
      historyStatus: '',
      providerEntityType: 'SERVICE_PROVIDER',
      providerEntityId: null,
      providerName: status.providerName.trim().isNotEmpty
          ? status.providerName
          : request.providerName,
      providerPhone: status.providerPhone,
      quotedPriceAmount: status.quotedPriceAmount,
      totalAcceptedQuotedPriceAmount: status.quotedPriceAmount,
      totalAcceptedBookingChargeAmount: status.quotedPriceAmount,
      distanceLabel: status.distanceLabel,
      providerPhotoUrl: '',
      providerLatitude: null,
      providerLongitude: null,
      destinationLatitude: destination?.latitude,
      destinationLongitude: destination?.longitude,
      paymentDueAt: null,
      reachByAt: null,
      labourPricingModel: '',
      categoryLabel: request.serviceName,
      subcategoryLabel: '',
      bookingId: status.bookingId,
      bookingCode: status.bookingCode,
      bookingStatus: status.bookingStatus,
      paymentStatus: status.paymentStatus,
      cancelReason: '',
      reviewRating: null,
      reviewComment: '',
      createdAt: DateTime.now(),
      canMakePayment: status.canMakePayment,
      reviewSubmitted: false,
    );
  }

  Future<void> _hydrateRemoteState({bool silent = true}) async {
    if (_remoteSyncInFlight) {
      return;
    }
    if (mounted) {
      setState(() {
        _remoteSyncInFlight = true;
      });
    } else {
      _remoteSyncInFlight = true;
    }
    try {
      List<_DiscoveryItem> remoteProducts = const <_DiscoveryItem>[];
      try {
        remoteProducts = await _UserAppApi.fetchHomeTopProducts();
      } on _UserAppApiException catch (_) {
      } catch (_) {}
      _RemoteCartState? remoteCart;
      List<_ActiveBookingStatus> activeBookings =
          const <_ActiveBookingStatus>[];
      _UserProfileData? profile;
      if (_isAuthenticated) {
        final results = await Future.wait<dynamic>([
          _UserAppApi.fetchCart(),
          _loadActiveBookingStatusesSafe(),
          _ensureProfilePreviewWarmed(),
        ]);
        remoteCart = results[0] as _RemoteCartState;
        activeBookings = results[1] as List<_ActiveBookingStatus>;
        profile = results[2] as _UserProfileData?;
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _backendTopProducts
          ..clear()
          ..addAll(remoteProducts);
        if (remoteCart != null) {
          _cartShopName = remoteCart.shopName.isEmpty
              ? null
              : remoteCart.shopName;
          _cartItems
            ..clear()
            ..addAll(remoteCart.items);
          _localCartNeedsSync = false;
        }
        _cachedUserProfile = _isAuthenticated ? profile : null;
        _headerProfilePhotoDataUri = _isAuthenticated
            ? (profile?.profilePhotoDataUri.trim() ?? '')
            : '';
        _headerProfilePhotoObjectKey = _isAuthenticated
            ? (profile?.profilePhotoObjectKey.trim() ?? '')
            : '';
        _setActiveBookingStatuses(
          _isAuthenticated ? activeBookings : const <_ActiveBookingStatus>[],
        );
      });
      if (_isAuthenticated) {
        unawaited(_refreshNotificationPreview(silent: true));
      }
    } on _UserAppApiException catch (_) {
    } catch (_) {
    } finally {
      if (mounted) {
        setState(() {
          _remoteSyncInFlight = false;
        });
      } else {
        _remoteSyncInFlight = false;
      }
    }
  }

  Future<void> _handleNotificationEvent(_NotificationEvent event) async {
    if (!event.isVisibleInUserApp) {
      return;
    }
    final arrivalBookingId = event.type == 'BOOKING_PROVIDER_ARRIVED'
        ? _bookingIdFromNotificationEvent(event)
        : null;
    final alreadyAnnouncedArrival =
        arrivalBookingId != null &&
        _announcedArrivedBookingIds.contains(arrivalBookingId);
    if (arrivalBookingId != null) {
      _announcedArrivedBookingIds.add(arrivalBookingId);
    }
    if (!event.openedApp && _shouldPlayUserNotificationSound(event)) {
      if (event.type != 'BOOKING_PROVIDER_ARRIVED' ||
          !alreadyAnnouncedArrival) {
        unawaited(_BookingUpdateSoundPlayer.play());
      }
    }
    await _refreshNotificationPreview(silent: true);
    await _hydrateRemoteState(silent: true);
    if (!mounted) {
      return;
    }

    if (event.openedApp) {
      if (event.isOrderRelated) {
        await Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => const _OrdersPage()));
        await _refreshNotificationPreview(silent: true);
      } else if (event.isBookingRelated) {
        await Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const _MyBookingsPage()),
        );
        await _hydrateRemoteState(silent: true);
      } else {
        await _openNotificationsPage();
      }
      return;
    }

    if (!event.hasVisibleContent) {
      return;
    }

    if (event.type == 'BOOKING_PROVIDER_ARRIVED') {
      _showLabourArrivedNotification(
        providerName: '',
        body: event.body.trim().isNotEmpty ? event.body : null,
      );
      return;
    }

    if (event.type == 'BOOKING_ACCEPTED') {
      _showBookingAcceptedNotification(event);
      return;
    }

    if (_isProviderNoShowNotification(event)) {
      _showProviderNoShowNotification(event);
      return;
    }

    if (event.isBookingRelated) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (event.title.isNotEmpty)
              Text(
                event.title,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            if (event.body.isNotEmpty)
              Text(event.body, maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
        ),
        action: SnackBarAction(
          label: 'View',
          onPressed: () {
            if (event.isOrderRelated) {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const _OrdersPage()),
              );
            } else {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const _NotificationsPage(),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Future<void> _refreshNotificationPreview({bool silent = true}) async {
    try {
      final notifications = await _UserAppApi.fetchNotifications(
        page: 0,
        size: 1,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _notificationUnreadCount = notifications.unreadCount;
      });
    } catch (_) {
      if (!silent && mounted) {
        _showCartSnack('Could not load notifications right now.');
      }
    }
  }

  String get _selectedLocationCity => _selectedLocationChoice?.city ?? '';
  double? get _selectedLatitude => _selectedLocationChoice?.latitude;
  double? get _selectedLongitude => _selectedLocationChoice?.longitude;
  String get _currentPhoneNumber => (_sessionPhoneNumber ?? '').trim();
  bool get _isAuthenticated => _currentPhoneNumber.isNotEmpty;
  bool get _anyHomeRemoteLoading =>
      _discoveryBatchInFlightCount > 0 ||
      _remoteSyncInFlight ||
      _labourRemoteLoading ||
      _serviceRemoteLoading ||
      _restaurantRemoteLoading ||
      _fashionRemoteLoading ||
      _footwearRemoteLoading ||
      _giftRemoteLoading ||
      _groceryRemoteLoading ||
      _pharmacyRemoteLoading ||
      _homeLocationLoading;

  Future<void> _refreshSessionPhoneFromStore() async {
    final savedPhoneNumber =
        (await _LocalSessionStore.readPhoneNumber())?.trim() ?? '';
    if (!mounted || savedPhoneNumber == _currentPhoneNumber) {
      return;
    }
    setState(() {
      _sessionPhoneNumber = savedPhoneNumber.isEmpty ? null : savedPhoneNumber;
    });
  }

  Future<_UserProfileData?> _loadProfilePreviewSafe() async {
    try {
      final profile = await _UserAppApi.fetchProfile();
      await _LocalSessionStore.saveProfileCache(jsonEncode(profile.toJson()));
      return profile;
    } catch (_) {
      return await _readCachedProfilePreview();
    }
  }

  Future<_UserProfileData?> _ensureProfilePreviewWarmed() async {
    if (!_isAuthenticated) {
      return null;
    }
    final cachedProfile = _cachedUserProfile;
    if (cachedProfile != null) {
      return cachedProfile;
    }
    final existingFuture = _profilePreviewWarmupFuture;
    if (existingFuture != null) {
      return await existingFuture;
    }
    final future = _loadProfilePreviewSafe();
    _profilePreviewWarmupFuture = future;
    try {
      final profile = await future;
      if (profile != null) {
        if (mounted) {
          setState(() {
            _cachedUserProfile = profile;
            _headerProfilePhotoDataUri = profile.profilePhotoDataUri.trim();
            _headerProfilePhotoObjectKey = profile.profilePhotoObjectKey.trim();
          });
        } else {
          _cachedUserProfile = profile;
          _headerProfilePhotoDataUri = profile.profilePhotoDataUri.trim();
          _headerProfilePhotoObjectKey = profile.profilePhotoObjectKey.trim();
        }
      }
      return profile;
    } finally {
      if (identical(_profilePreviewWarmupFuture, future)) {
        _profilePreviewWarmupFuture = null;
      }
    }
  }

  Future<_UserProfileData?> _readCachedProfilePreview() async {
    final raw = await _LocalSessionStore.readProfileCache();
    if (raw == null || raw.trim().isEmpty) {
      return null;
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }
      return _UserProfileData.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  Future<void> _restoreCachedProfilePreview() async {
    if (!_isAuthenticated) {
      return;
    }
    final cached = await _readCachedProfilePreview();
    if (!mounted || cached == null) {
      return;
    }
    setState(() {
      _cachedUserProfile = cached;
      _headerProfilePhotoDataUri = cached.profilePhotoDataUri.trim();
      _headerProfilePhotoObjectKey = cached.profilePhotoObjectKey.trim();
    });
  }

  Future<void> _warmProfilePreviewOnAppOpen() async {
    await _restoreCachedProfilePreview();
    if (_cachedUserProfile != null || !_isAuthenticated) {
      return;
    }
    await _ensureProfilePreviewWarmed();
  }

  void _markDiscoveryPending() {
    if (mounted) {
      setState(() {
        _initialDiscoveryBatchResolved = false;
      });
    } else {
      _initialDiscoveryBatchResolved = false;
    }
  }

  Future<bool> _ensureAuthenticated() async {
    if (_isAuthenticated) {
      return true;
    }
    final loggedIn = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => const LoginPage(embeddedFlow: true),
      ),
    );
    if (loggedIn != true) {
      return false;
    }
    final savedPhoneNumber = await _LocalSessionStore.readPhoneNumber();
    if (savedPhoneNumber == null || savedPhoneNumber.trim().isEmpty) {
      if (mounted) {
        _showCartSnack(
          'Login completed, but the session could not be restored.',
        );
      }
      return false;
    }
    if (!mounted) {
      return true;
    }
    setState(() {
      _sessionPhoneNumber = savedPhoneNumber.trim();
    });
    _markDiscoveryPending();
    await _loadHomeLocationOptions();
    await _reloadAddressAwareDiscovery(silent: true);
    await _NotificationBootstrap.ensureRegistered();
    await _hydrateRemoteState(silent: true);
    await _refreshNotificationPreview(silent: true);
    return true;
  }

  Future<void> _syncLocalCartToBackend() async {
    if (!_isAuthenticated || !_localCartNeedsSync) {
      return;
    }
    final syncableItems = _cartItems
        .where((item) => item.backendProductId != null)
        .toList(growable: false);
    if (syncableItems.isEmpty) {
      if (mounted) {
        setState(() {
          _localCartNeedsSync = false;
        });
      } else {
        _localCartNeedsSync = false;
      }
      return;
    }
    _RemoteCartState? remoteCart;
    for (final item in syncableItems) {
      remoteCart = await _UserAppApi.addItemToCart(item);
    }
    if (!mounted) {
      _localCartNeedsSync = false;
      return;
    }
    if (remoteCart != null) {
      setState(() {
        _cartShopName = remoteCart!.shopName.isEmpty
            ? null
            : remoteCart.shopName;
        _cartItems
          ..clear()
          ..addAll(remoteCart.items);
        _localCartNeedsSync = false;
      });
    } else {
      setState(() {
        _localCartNeedsSync = false;
      });
    }
  }

  Future<void> _initializeHomeRequirements() async {
    if (_initialHomeSetupRunning) {
      return;
    }
    _initialHomeSetupRunning = true;
    try {
      _markDiscoveryPending();
      await _enforceHomePermissions();
      await _loadHomeLocationOptions(forceCurrentSelection: true);
      await _reloadAddressAwareDiscovery();
      await _NotificationBootstrap.ensureRegistered();
    } finally {
      _initialHomeSetupRunning = false;
    }
  }

  Future<void> _enforceHomePermissions() async {
    final locationPermission = await Permission.locationWhenInUse.status;
    if (!locationPermission.isGranted) {
      await Permission.locationWhenInUse.request();
    }
    if (Platform.isAndroid || Platform.isIOS) {
      final notificationPermission = await Permission.notification.status;
      if (!notificationPermission.isGranted) {
        await Permission.notification.request();
      }
    }
  }

  Future<void> _loadHomeLocationOptions({
    bool forceCurrentSelection = false,
  }) async {
    if (mounted) {
      setState(() {
        _homeLocationLoading = true;
        _homeLocationError = null;
      });
    } else {
      _homeLocationLoading = true;
      _homeLocationError = null;
    }
    try {
      final addresses = _isAuthenticated
          ? await _UserAppApi.fetchAddresses()
          : <_UserAddressData>[];
      _HomeLocationChoice? currentLocation;
      try {
        currentLocation = await _resolveCurrentLocationChoice();
      } catch (_) {
        currentLocation = null;
      }
      if (!mounted) {
        return;
      }
      final nearbySavedLocation = currentLocation == null
          ? null
          : _nearestSavedAddressChoice(currentLocation, addresses);
      final previousSelection = _selectedLocationChoice;
      _HomeLocationChoice? selectedLocation;
      if (forceCurrentSelection && currentLocation != null) {
        selectedLocation = nearbySavedLocation ?? currentLocation;
      } else {
        selectedLocation = previousSelection;
        if (selectedLocation != null && !selectedLocation.isCurrentLocation) {
          if (selectedLocation.addressId != null) {
            final selectedAddress = addresses
                .where((item) => item.id == selectedLocation!.addressId)
                .firstOrNull;
            if (selectedAddress != null) {
              selectedLocation = _locationChoiceFromAddress(selectedAddress);
            } else {
              selectedLocation = null;
            }
          }
        } else if (selectedLocation?.isCurrentLocation == true) {
          selectedLocation = nearbySavedLocation ?? currentLocation;
        }
        selectedLocation ??= nearbySavedLocation;
        selectedLocation ??= currentLocation;
        selectedLocation ??= addresses
            .where((item) => item.isDefault)
            .map(_locationChoiceFromAddress)
            .firstOrNull;
        selectedLocation ??= addresses
            .map(_locationChoiceFromAddress)
            .firstOrNull;
      }
      setState(() {
        _savedAddresses = addresses;
        _currentLocationChoice = currentLocation;
        _selectedLocationChoice = selectedLocation;
        _homeLocationError = null;
        _homeLocationLoading = false;
      });
    } catch (error) {
      _HomeLocationChoice? currentLocation;
      try {
        currentLocation = await _resolveCurrentLocationChoice();
      } catch (_) {
        currentLocation = null;
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _savedAddresses = const <_UserAddressData>[];
        _currentLocationChoice = currentLocation;
        _selectedLocationChoice = currentLocation;
        _homeLocationError = currentLocation == null ? '$error' : null;
        _homeLocationLoading = false;
      });
    }
  }

  Future<_HomeLocationChoice?> _resolveCurrentLocationChoice() async {
    final locationServiceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!locationServiceEnabled) {
      return null;
    }
    final locationPermission = await Permission.locationWhenInUse.status;
    if (!locationPermission.isGranted) {
      return null;
    }
    final position = await Geolocator.getCurrentPosition();
    final placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );
    final placemark = placemarks.isEmpty ? null : placemarks.first;
    final city = (placemark?.locality ?? placemark?.subAdministrativeArea ?? '')
        .trim();
    final subtitleParts = <String>[
      if ((placemark?.subLocality ?? '').trim().isNotEmpty)
        placemark!.subLocality!.trim(),
      if ((placemark?.locality ?? '').trim().isNotEmpty)
        placemark!.locality!.trim(),
      if ((placemark?.administrativeArea ?? '').trim().isNotEmpty)
        placemark!.administrativeArea!.trim(),
      if ((placemark?.postalCode ?? '').trim().isNotEmpty)
        placemark!.postalCode!.trim(),
    ];
    return _HomeLocationChoice(
      title: 'Current location',
      subtitle: subtitleParts.isEmpty
          ? 'Live device location'
          : subtitleParts.join(', '),
      city: city,
      latitude: position.latitude,
      longitude: position.longitude,
      isCurrentLocation: true,
    );
  }

  _HomeLocationChoice _locationChoiceFromAddress(_UserAddressData address) {
    return _HomeLocationChoice(
      title: address.label,
      subtitle: address.fullAddress,
      city: address.city,
      latitude: address.latitude,
      longitude: address.longitude,
      addressId: address.id,
    );
  }

  bool _sameHomeLocationChoice(
    _HomeLocationChoice left,
    _HomeLocationChoice right,
  ) {
    if (left.isCurrentLocation != right.isCurrentLocation) {
      return false;
    }
    if (left.addressId != null || right.addressId != null) {
      return left.addressId == right.addressId;
    }
    return (left.latitude - right.latitude).abs() < 0.00001 &&
        (left.longitude - right.longitude).abs() < 0.00001 &&
        left.title == right.title &&
        left.subtitle == right.subtitle;
  }

  String get _placesApiKey =>
      Platform.isIOS ? _iosPlacesApiKey : _androidPlacesApiKey;

  List<String> _homeLocationSearchQueryVariants(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return const <String>[];
    }
    final variants = <String>[trimmed];
    final normalizedQuery = trimmed.toLowerCase();
    final selectedCity = _selectedLocationCity.trim();
    if (selectedCity.isNotEmpty &&
        !normalizedQuery.contains(selectedCity.toLowerCase())) {
      variants.add('$trimmed, $selectedCity');
    }
    if (!normalizedQuery.contains('india')) {
      variants.add('$trimmed, India');
    }
    final seen = <String>{};
    return variants
        .where((variant) => seen.add(variant.trim().toLowerCase()))
        .toList(growable: false);
  }

  Future<List<_HomeLocationSearchSuggestion>> _searchHomeLocationSuggestions(
    String query,
  ) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return const <_HomeLocationSearchSuggestion>[];
    }
    final merged = <_HomeLocationSearchSuggestion>[];
    for (final variant in _homeLocationSearchQueryVariants(trimmed)) {
      try {
        merged.addAll(
          await _searchHomeLocationSuggestionsWithQueryAutocomplete(variant),
        );
      } catch (_) {
        // Keep going and enrich results from the next sources.
      }
      try {
        merged.addAll(
          await _searchHomeLocationSuggestionsWithAutocomplete(variant),
        );
      } catch (_) {
        // Keep going and enrich results from the next sources.
      }
      try {
        merged.addAll(
          await _searchHomeLocationSuggestionsWithTextSearch(variant),
        );
      } catch (_) {
        // Keep going and enrich results from the next sources.
      }
      try {
        merged.addAll(await _searchHomeLocationSuggestionsWithGeocode(variant));
      } catch (_) {
        // Keep going and enrich results from the next sources.
      }
      final enriched = _dedupeHomeLocationSuggestions(merged);
      if (enriched.length >= 8) {
        return enriched;
      }
    }
    if (merged.length < 8) {
      try {
        merged.addAll(
          await _searchHomeLocationSuggestionsWithOpenStreetMap(trimmed),
        );
      } catch (_) {
        // Keep whatever remote suggestions we already have.
      }
    }
    if (merged.length < 8) {
      try {
        merged.addAll(
          await _searchHomeLocationSuggestionsWithDeviceGeocoder(trimmed),
        );
      } catch (_) {
        // Keep whatever richer remote suggestions we already have.
      }
    }
    final deduped = _dedupeHomeLocationSuggestions(merged);
    if (deduped.isNotEmpty) {
      return deduped;
    }
    return const <_HomeLocationSearchSuggestion>[];
  }

  Future<List<_HomeLocationSearchSuggestion>>
  _searchHomeLocationSuggestionsWithOpenStreetMap(String query) async {
    final response = await http.get(
      Uri.https('nominatim.openstreetmap.org', '/search', {
        'q': query,
        'format': 'jsonv2',
        'limit': '10',
        'addressdetails': '1',
        'countrycodes': 'in',
      }),
      headers: const <String, String>{
        'User-Agent': 'MSAUserApp/1.0 location-search',
        'Accept': 'application/json',
      },
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'OpenStreetMap search failed with ${response.statusCode}',
      );
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw Exception('OpenStreetMap search returned an invalid response.');
    }
    final seen = <String>{};
    final results = <_HomeLocationSearchSuggestion>[];
    for (final raw in decoded.whereType<Map<dynamic, dynamic>>()) {
      final entry = Map<String, dynamic>.from(raw);
      final latitude = double.tryParse('${entry['lat'] ?? ''}');
      final longitude = double.tryParse('${entry['lon'] ?? ''}');
      final description = '${entry['display_name'] ?? ''}'.trim();
      if (latitude == null || longitude == null || description.isEmpty) {
        continue;
      }
      final key =
          '${latitude.toStringAsFixed(5)}:${longitude.toStringAsFixed(5)}';
      if (!seen.add(key)) {
        continue;
      }
      final address = Map<String, dynamic>.from(
        (entry['address'] as Map?) ?? const {},
      );
      final title =
          <String>[
            '${address['name'] ?? ''}'.trim(),
            '${address['suburb'] ?? ''}'.trim(),
            '${address['neighbourhood'] ?? ''}'.trim(),
            '${address['city'] ?? ''}'.trim(),
            '${address['town'] ?? ''}'.trim(),
            '${address['village'] ?? ''}'.trim(),
          ].firstWhere(
            (value) => value.isNotEmpty,
            orElse: () => description.split(',').first.trim(),
          );
      final subtitle = description == title
          ? ''
          : description
                .substring(title.length)
                .replaceFirst(RegExp(r'^,\s*'), '')
                .trim();
      final city = <String>[
        '${address['city'] ?? ''}'.trim(),
        '${address['town'] ?? ''}'.trim(),
        '${address['village'] ?? ''}'.trim(),
        '${address['county'] ?? ''}'.trim(),
      ].firstWhere((value) => value.isNotEmpty, orElse: () => '');
      results.add(
        _HomeLocationSearchSuggestion(
          placeId: '',
          title: title,
          subtitle: subtitle,
          description: description,
          latitude: latitude,
          longitude: longitude,
          city: city,
        ),
      );
    }
    return results;
  }

  Future<List<_HomeLocationSearchSuggestion>>
  _searchHomeLocationSuggestionsWithQueryAutocomplete(String query) async {
    final response = await http.get(
      Uri.https(
        'maps.googleapis.com',
        '/maps/api/place/queryautocomplete/json',
        {'input': query, 'key': _placesApiKey, 'language': 'en'},
      ),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Query autocomplete request failed with ${response.statusCode}',
      );
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Query autocomplete returned an invalid response.');
    }
    final status = '${decoded['status'] ?? ''}'.trim().toUpperCase();
    if (status == 'ZERO_RESULTS') {
      return const <_HomeLocationSearchSuggestion>[];
    }
    if (status != 'OK') {
      throw Exception(
        '${decoded['error_message'] ?? decoded['status'] ?? 'Query autocomplete failed'}',
      );
    }
    final predictions = (decoded['predictions'] as List? ?? const []);
    final seen = <String>{};
    final results = <_HomeLocationSearchSuggestion>[];
    for (final raw in predictions.whereType<Map<dynamic, dynamic>>()) {
      final prediction = Map<String, dynamic>.from(raw);
      final placeId = '${prediction['place_id'] ?? ''}'.trim();
      final description = '${prediction['description'] ?? ''}'.trim();
      if (description.isEmpty) {
        continue;
      }
      final key = placeId.isNotEmpty
          ? 'place:$placeId'
          : description.toLowerCase();
      if (!seen.add(key)) {
        continue;
      }
      final formatting = Map<String, dynamic>.from(
        (prediction['structured_formatting'] as Map?) ?? const {},
      );
      final title = '${formatting['main_text'] ?? ''}'.trim();
      final subtitle = '${formatting['secondary_text'] ?? ''}'.trim();
      results.add(
        _HomeLocationSearchSuggestion(
          placeId: placeId,
          title: title.isEmpty ? description : title,
          subtitle: subtitle,
          description: description,
        ),
      );
    }
    return results;
  }

  Future<List<_HomeLocationSearchSuggestion>>
  _searchHomeLocationSuggestionsWithAutocomplete(String query) async {
    final response = await http.get(
      Uri.https('maps.googleapis.com', '/maps/api/place/autocomplete/json', {
        'input': query,
        'key': _placesApiKey,
        'language': 'en',
      }),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Autocomplete request failed with ${response.statusCode}',
      );
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Autocomplete returned an invalid response.');
    }
    final status = '${decoded['status'] ?? ''}'.trim().toUpperCase();
    if (status == 'ZERO_RESULTS') {
      return const <_HomeLocationSearchSuggestion>[];
    }
    if (status != 'OK') {
      throw Exception(
        '${decoded['error_message'] ?? decoded['status'] ?? 'Autocomplete failed'}',
      );
    }
    final predictions = (decoded['predictions'] as List? ?? const []);
    final seen = <String>{};
    final results = <_HomeLocationSearchSuggestion>[];
    for (final raw in predictions.whereType<Map<dynamic, dynamic>>()) {
      final prediction = Map<String, dynamic>.from(raw);
      final placeId = '${prediction['place_id'] ?? ''}'.trim();
      final description = '${prediction['description'] ?? ''}'.trim();
      if (placeId.isEmpty || description.isEmpty || !seen.add(placeId)) {
        continue;
      }
      final formatting = Map<String, dynamic>.from(
        (prediction['structured_formatting'] as Map?) ?? const {},
      );
      final title = '${formatting['main_text'] ?? ''}'.trim();
      final subtitle = '${formatting['secondary_text'] ?? ''}'.trim();
      results.add(
        _HomeLocationSearchSuggestion(
          placeId: placeId,
          title: title.isEmpty ? description : title,
          subtitle: subtitle,
          description: description,
        ),
      );
    }
    return results;
  }

  Future<List<_HomeLocationSearchSuggestion>>
  _searchHomeLocationSuggestionsWithTextSearch(String query) async {
    final response = await http.get(
      Uri.https('maps.googleapis.com', '/maps/api/place/textsearch/json', {
        'query': query,
        'key': _placesApiKey,
        'language': 'en',
      }),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Text search request failed with ${response.statusCode}');
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Text search returned an invalid response.');
    }
    final status = '${decoded['status'] ?? ''}'.trim().toUpperCase();
    if (status == 'ZERO_RESULTS') {
      return const <_HomeLocationSearchSuggestion>[];
    }
    if (status != 'OK') {
      throw Exception(
        '${decoded['error_message'] ?? decoded['status'] ?? 'Text search failed'}',
      );
    }
    final seen = <String>{};
    final results = <_HomeLocationSearchSuggestion>[];
    for (final raw
        in (decoded['results'] as List? ?? const [])
            .whereType<Map<dynamic, dynamic>>()) {
      final result = Map<String, dynamic>.from(raw);
      final placeId = '${result['place_id'] ?? ''}'.trim();
      final name = '${result['name'] ?? ''}'.trim();
      final formattedAddress = '${result['formatted_address'] ?? ''}'.trim();
      final geometry = Map<String, dynamic>.from(
        (result['geometry'] as Map?) ?? const {},
      );
      final location = Map<String, dynamic>.from(
        (geometry['location'] as Map?) ?? const {},
      );
      final latitude = (location['lat'] as num?)?.toDouble();
      final longitude = (location['lng'] as num?)?.toDouble();
      if ((placeId.isEmpty && formattedAddress.isEmpty) ||
          latitude == null ||
          longitude == null) {
        continue;
      }
      final key = placeId.isNotEmpty
          ? 'place:$placeId'
          : '${latitude.toStringAsFixed(5)}:${longitude.toStringAsFixed(5)}';
      if (!seen.add(key)) {
        continue;
      }
      final title = name.isEmpty
          ? (formattedAddress.isEmpty ? query : formattedAddress)
          : name;
      final subtitle = formattedAddress == title ? '' : formattedAddress;
      results.add(
        _HomeLocationSearchSuggestion(
          placeId: placeId,
          title: title,
          subtitle: subtitle,
          description: formattedAddress.isEmpty ? title : formattedAddress,
          latitude: latitude,
          longitude: longitude,
        ),
      );
    }
    return results;
  }

  List<_HomeLocationSearchSuggestion> _dedupeHomeLocationSuggestions(
    List<_HomeLocationSearchSuggestion> suggestions,
  ) {
    if (suggestions.isEmpty) {
      return const <_HomeLocationSearchSuggestion>[];
    }
    final seen = <String>{};
    final results = <_HomeLocationSearchSuggestion>[];
    for (final suggestion in suggestions) {
      final placeId = suggestion.placeId.trim();
      final description = suggestion.description.trim().toLowerCase();
      final latitude = suggestion.latitude;
      final longitude = suggestion.longitude;
      final key = placeId.isNotEmpty
          ? 'place:$placeId'
          : latitude != null && longitude != null
          ? '${latitude.toStringAsFixed(5)}:${longitude.toStringAsFixed(5)}'
          : description;
      if (!seen.add(key)) {
        continue;
      }
      results.add(suggestion);
    }
    return results;
  }

  Future<List<_HomeLocationSearchSuggestion>>
  _searchHomeLocationSuggestionsWithGeocode(String query) async {
    final response = await http.get(
      Uri.https('maps.googleapis.com', '/maps/api/geocode/json', {
        'address': query,
        'key': _placesApiKey,
        'language': 'en',
      }),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Geocode request failed with ${response.statusCode}');
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Geocode returned an invalid response.');
    }
    final status = '${decoded['status'] ?? ''}'.trim().toUpperCase();
    if (status == 'ZERO_RESULTS') {
      return const <_HomeLocationSearchSuggestion>[];
    }
    if (status != 'OK') {
      throw Exception(
        '${decoded['error_message'] ?? decoded['status'] ?? 'Geocode failed'}',
      );
    }
    final seen = <String>{};
    final results = <_HomeLocationSearchSuggestion>[];
    for (final raw
        in (decoded['results'] as List? ?? const [])
            .whereType<Map<dynamic, dynamic>>()) {
      final result = Map<String, dynamic>.from(raw);
      final formattedAddress = '${result['formatted_address'] ?? ''}'.trim();
      final placeId = '${result['place_id'] ?? ''}'.trim();
      final geometry = Map<String, dynamic>.from(
        (result['geometry'] as Map?) ?? const {},
      );
      final location = Map<String, dynamic>.from(
        (geometry['location'] as Map?) ?? const {},
      );
      final latitude = (location['lat'] as num?)?.toDouble();
      final longitude = (location['lng'] as num?)?.toDouble();
      if (formattedAddress.isEmpty || latitude == null || longitude == null) {
        continue;
      }
      final key = placeId.isNotEmpty
          ? 'place:$placeId'
          : '${latitude.toStringAsFixed(5)}:${longitude.toStringAsFixed(5)}';
      if (!seen.add(key)) {
        continue;
      }
      final parts = formattedAddress.split(',');
      final title = parts.firstOrNull?.trim() ?? formattedAddress;
      final subtitle = parts.length > 1
          ? parts.skip(1).join(',').trim()
          : formattedAddress;
      String city = '';
      final components = (result['address_components'] as List? ?? const [])
          .whereType<Map<dynamic, dynamic>>()
          .map((entry) => Map<String, dynamic>.from(entry))
          .toList(growable: false);
      for (final component in components) {
        final types = (component['types'] as List? ?? const [])
            .map((item) => '$item')
            .toList(growable: false);
        if (types.contains('locality') ||
            types.contains('administrative_area_level_2')) {
          city = '${component['long_name'] ?? ''}'.trim();
          if (city.isNotEmpty) {
            break;
          }
        }
      }
      results.add(
        _HomeLocationSearchSuggestion(
          placeId: placeId,
          title: title,
          subtitle: subtitle,
          description: formattedAddress,
          latitude: latitude,
          longitude: longitude,
          city: city,
        ),
      );
    }
    return results;
  }

  Future<List<_HomeLocationSearchSuggestion>>
  _searchHomeLocationSuggestionsWithDeviceGeocoder(String query) async {
    final resolvedLocations = await locationFromAddress(query);
    if (resolvedLocations.isEmpty) {
      return const <_HomeLocationSearchSuggestion>[];
    }
    final seen = <String>{};
    final results = <_HomeLocationSearchSuggestion>[];
    for (final location in resolvedLocations) {
      final key =
          '${location.latitude.toStringAsFixed(5)}:${location.longitude.toStringAsFixed(5)}';
      if (!seen.add(key)) {
        continue;
      }
      Placemark? placemark;
      try {
        final placemarks = await placemarkFromCoordinates(
          location.latitude,
          location.longitude,
        );
        placemark = placemarks.firstOrNull;
      } catch (_) {
        placemark = null;
      }
      final titleParts = <String>[
        if ((placemark?.name ?? '').trim().isNotEmpty) placemark!.name!.trim(),
        if ((placemark?.subLocality ?? '').trim().isNotEmpty)
          placemark!.subLocality!.trim(),
        if ((placemark?.locality ?? '').trim().isNotEmpty)
          placemark!.locality!.trim(),
      ];
      final subtitleParts = <String>[
        if ((placemark?.thoroughfare ?? '').trim().isNotEmpty)
          placemark!.thoroughfare!.trim(),
        if ((placemark?.subAdministrativeArea ?? '').trim().isNotEmpty)
          placemark!.subAdministrativeArea!.trim(),
        if ((placemark?.administrativeArea ?? '').trim().isNotEmpty)
          placemark!.administrativeArea!.trim(),
        if ((placemark?.postalCode ?? '').trim().isNotEmpty)
          placemark!.postalCode!.trim(),
      ];
      final title = titleParts.isEmpty ? query : titleParts.join(', ');
      final subtitle = subtitleParts.isEmpty
          ? 'Lat ${location.latitude.toStringAsFixed(5)}, Lng ${location.longitude.toStringAsFixed(5)}'
          : subtitleParts.join(', ');
      results.add(
        _HomeLocationSearchSuggestion(
          placeId: '',
          title: title,
          subtitle: subtitle,
          description: '$title, $subtitle',
          latitude: location.latitude,
          longitude: location.longitude,
          city: (placemark?.locality ?? placemark?.subAdministrativeArea ?? '')
              .trim(),
        ),
      );
    }
    return results;
  }

  Future<_HomeLocationChoice?> _resolveHomeLocationSuggestion(
    _HomeLocationSearchSuggestion suggestion,
  ) async {
    if (suggestion.latitude != null && suggestion.longitude != null) {
      return _HomeLocationChoice(
        title: suggestion.title,
        subtitle: suggestion.subtitle.isEmpty
            ? suggestion.description
            : suggestion.subtitle,
        city: suggestion.city,
        latitude: suggestion.latitude!,
        longitude: suggestion.longitude!,
      );
    }
    final response = await http.get(
      Uri.https('maps.googleapis.com', '/maps/api/geocode/json', {
        'place_id': suggestion.placeId,
        'key': _placesApiKey,
        'language': 'en',
      }),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Place lookup failed with ${response.statusCode}');
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Place lookup returned an invalid response.');
    }
    final status = '${decoded['status'] ?? ''}'.trim().toUpperCase();
    if (status == 'ZERO_RESULTS') {
      return null;
    }
    if (status != 'OK') {
      throw Exception(
        '${decoded['error_message'] ?? decoded['status'] ?? 'Place lookup failed'}',
      );
    }
    final raw = (decoded['results'] as List? ?? const [])
        .whereType<Map<dynamic, dynamic>>()
        .map((entry) => Map<String, dynamic>.from(entry))
        .firstOrNull;
    if (raw == null) {
      return null;
    }
    final geometry = Map<String, dynamic>.from(
      (raw['geometry'] as Map?) ?? const {},
    );
    final location = Map<String, dynamic>.from(
      (geometry['location'] as Map?) ?? const {},
    );
    final latitude = (location['lat'] as num?)?.toDouble();
    final longitude = (location['lng'] as num?)?.toDouble();
    if (latitude == null || longitude == null) {
      return null;
    }
    final components = (raw['address_components'] as List? ?? const [])
        .whereType<Map<dynamic, dynamic>>()
        .map((entry) => Map<String, dynamic>.from(entry))
        .toList(growable: false);
    String city = '';
    for (final component in components) {
      final types = (component['types'] as List? ?? const [])
          .map((item) => '$item')
          .toList(growable: false);
      if (types.contains('locality') ||
          types.contains('administrative_area_level_2')) {
        city = '${component['long_name'] ?? ''}'.trim();
        if (city.isNotEmpty) {
          break;
        }
      }
    }
    final formattedAddress =
        '${raw['formatted_address'] ?? suggestion.description}'.trim();
    return _HomeLocationChoice(
      title: suggestion.title,
      subtitle: suggestion.subtitle.isEmpty
          ? formattedAddress
          : suggestion.subtitle,
      city: city,
      latitude: latitude,
      longitude: longitude,
    );
  }

  _HomeLocationChoice? _nearestSavedAddressChoice(
    _HomeLocationChoice currentLocation,
    List<_UserAddressData> addresses,
  ) {
    _UserAddressData? nearestAddress;
    double? nearestDistanceMeters;
    for (final address in addresses) {
      final distanceMeters = Geolocator.distanceBetween(
        currentLocation.latitude,
        currentLocation.longitude,
        address.latitude,
        address.longitude,
      );
      if (distanceMeters > _savedAddressSnapDistanceMeters) {
        continue;
      }
      if (nearestDistanceMeters == null ||
          distanceMeters < nearestDistanceMeters) {
        nearestDistanceMeters = distanceMeters;
        nearestAddress = address;
      }
    }
    return nearestAddress == null
        ? null
        : _locationChoiceFromAddress(nearestAddress);
  }

  Future<void> _openHomeLocationSelector({bool? showManageAddresses}) async {
    final canManageAddresses = showManageAddresses ?? _isAuthenticated;
    final result = await Navigator.of(context).push<Object?>(
      PageRouteBuilder<Object?>(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) => Scaffold(
          backgroundColor: Colors.white,
          body: _HomeLocationSelectorSheet(
            options: <_HomeLocationChoice>[
              ...?_currentLocationChoice == null
                  ? null
                  : <_HomeLocationChoice>[_currentLocationChoice!],
              ..._savedAddresses.map(_locationChoiceFromAddress),
            ],
            selectedLocation: _selectedLocationChoice,
            canManageAddresses: canManageAddresses,
            searchSuggestions: _searchHomeLocationSuggestions,
            resolveSuggestion: _resolveHomeLocationSuggestion,
            sameChoice: _sameHomeLocationChoice,
          ),
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.04),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
    if (!mounted || result == null) {
      return;
    }
    if (result == 'manage') {
      final canContinue = await _ensureAuthenticated();
      if (!mounted || !canContinue) {
        return;
      }
      _markDiscoveryPending();
      await Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: (_) => const _AddressesPage()));
      await _loadHomeLocationOptions();
      await _reloadAddressAwareDiscovery(silent: false);
      return;
    }
    if (result is _HomeLocationChoice) {
      setState(() {
        _selectedLocationChoice = result;
      });
      _markDiscoveryPending();
      await _reloadAddressAwareDiscovery(silent: false);
    }
  }

  Future<void> _reloadAddressAwareDiscovery({bool silent = true}) async {
    if (mounted) {
      setState(() {
        _initialDiscoveryBatchResolved = false;
        _discoveryBatchInFlightCount++;
      });
    } else {
      _initialDiscoveryBatchResolved = false;
      _discoveryBatchInFlightCount++;
    }
    try {
      await Future.wait<void>([
        _loadLabourLanding(silent: silent),
        _loadServiceLanding(silent: silent),
        _loadRestaurantLanding(silent: silent),
        _loadFashionLanding(silent: silent),
        _loadFootwearLanding(silent: silent),
        _loadGiftLanding(silent: silent),
        _loadGroceryLanding(silent: silent),
        _loadPharmacyLanding(silent: silent),
      ]);
    } finally {
      if (mounted) {
        setState(() {
          _discoveryBatchInFlightCount = math.max(
            0,
            _discoveryBatchInFlightCount - 1,
          );
          _initialDiscoveryBatchResolved = true;
        });
      } else {
        _discoveryBatchInFlightCount = math.max(
          0,
          _discoveryBatchInFlightCount - 1,
        );
        _initialDiscoveryBatchResolved = true;
      }
    }
  }

  Future<void> _refreshVisiblePage() async {
    _markDiscoveryPending();
    await _loadHomeLocationOptions(forceCurrentSelection: true);
    await _refreshNotificationPreview(silent: true);
    await _loadLabourBookingPolicy();
    await _hydrateRemoteState(silent: false);
    await _reloadAddressAwareDiscovery(silent: false);
  }

  Future<void> _loadLabourBookingPolicy() async {
    try {
      final policy = await _UserAppApi.fetchLabourBookingPolicy();
      if (!mounted) {
        return;
      }
      setState(() {
        _labourBookingChargePerLabour = policy.bookingChargePerLabour;
        _maxGroupLabourCount = policy.maxGroupLabourCount <= 0
            ? 7
            : policy.maxGroupLabourCount;
        if (_selectedLabourCount <= 0) {
          _selectedLabourCount = 1;
        } else if (_selectedLabourCount > _maxGroupLabourCount) {
          _selectedLabourCount = _maxGroupLabourCount;
        }
      });
    } catch (_) {
      // Keep the safe local default until the policy endpoint is reachable.
    }
  }

  Future<void> _loadLabourLanding({bool silent = true}) async {
    if (_labourRemoteLoading) {
      return;
    }
    final hadExistingProfiles = _labourRemoteProfiles.isNotEmpty;
    setState(() {
      _labourRemoteLoading = true;
      _labourRemoteError = null;
    });
    try {
      final landing = await _UserAppApi.fetchLabourLanding(
        categoryId: _labourCategoryIdForLabel(_selectedLabourCategory),
        city: _selectedLocationCity,
        latitude: _selectedLatitude,
        longitude: _selectedLongitude,
      );
      if (!mounted) {
        return;
      }
      final labels = landing.categories
          .map((item) => item.label)
          .toList(growable: false);
      setState(() {
        _labourRemoteCategories = landing.categories;
        _labourRemoteProfiles
          ..clear()
          ..addAll(landing.profiles);
        _labourRemoteReady = true;
        _labourRemoteError = null;
        if (!labels.contains(_selectedLabourCategory)) {
          _selectedLabourCategory = labels.isEmpty ? '' : labels.first;
        }
      });
    } on _UserAppApiException catch (error) {
      if (_shouldTreatAsEmptyResults(error.message)) {
        if (mounted) {
          setState(() {
            _labourRemoteReady = true;
            _labourRemoteCategories = const <_RemoteLabourCategory>[];
            _labourRemoteProfiles.clear();
            _labourRemoteError = null;
            _selectedLabourCategory = '';
          });
        } else {
          _labourRemoteReady = true;
          _labourRemoteCategories = const <_RemoteLabourCategory>[];
          _labourRemoteProfiles.clear();
          _labourRemoteError = null;
          _selectedLabourCategory = '';
        }
        return;
      }
      if (mounted) {
        setState(() {
          _labourRemoteError = hadExistingProfiles ? null : error.message;
        });
      } else {
        _labourRemoteError = hadExistingProfiles ? null : error.message;
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _labourRemoteError = hadExistingProfiles
              ? null
              : 'Could not load labour profiles right now.';
        });
      } else {
        _labourRemoteError = hadExistingProfiles
            ? null
            : 'Could not load labour profiles right now.';
      }
    } finally {
      if (mounted) {
        setState(() => _labourRemoteLoading = false);
      } else {
        _labourRemoteLoading = false;
      }
    }
  }

  Future<void> _loadServiceLanding({bool silent = true}) async {
    if (_serviceRemoteLoading) {
      return;
    }
    setState(() {
      _serviceRemoteLoading = true;
      _serviceRemoteError = null;
    });
    try {
      final landing = await _UserAppApi.fetchServiceLanding(
        categoryId: _serviceCategoryIdForLabel(_selectedServiceCategory),
        subcategoryId: _serviceSubcategoryIdForSelection(
          _selectedServiceCategory,
          _selectedServiceSubCategory,
        ),
        city: _selectedLocationCity,
        latitude: _selectedLatitude,
        longitude: _selectedLongitude,
      );
      if (!mounted) {
        return;
      }
      final categoryLabels = landing.categories
          .map((item) => item.label)
          .toList(growable: false);
      setState(() {
        _serviceRemoteCategories = landing.categories;
        _serviceRemoteProviders
          ..clear()
          ..addAll(landing.providers);
        _serviceRemoteReady = true;
        _serviceRemoteError = null;
        if (!categoryLabels.contains(_selectedServiceCategory)) {
          _selectedServiceCategory = categoryLabels.isEmpty
              ? ''
              : categoryLabels.first;
        }
        final subcategoryOptions = _selectedServiceSubcategories;
        final defaultSubcategory = _defaultServiceSubcategoryLabelFor(
          _selectedServiceCategory,
        );
        if (!subcategoryOptions.contains(_selectedServiceSubCategory) ||
            _selectedServiceSubCategory.trim().isEmpty ||
            _selectedServiceSubCategory == 'All') {
          _selectedServiceSubCategory = defaultSubcategory;
        }
      });
    } on _UserAppApiException catch (error) {
      if (_shouldTreatAsSilentDiscoveryFallback(error.message)) {
        if (mounted) {
          setState(() {
            _serviceRemoteReady = true;
            _serviceRemoteCategories = const <_RemoteServiceCategory>[];
            _serviceRemoteProviders.clear();
            _serviceRemoteError = null;
          });
        } else {
          _serviceRemoteReady = true;
          _serviceRemoteCategories = const <_RemoteServiceCategory>[];
          _serviceRemoteProviders.clear();
          _serviceRemoteError = null;
        }
        return;
      }
      if (mounted) {
        setState(() {
          _serviceRemoteError = error.message;
        });
      } else {
        _serviceRemoteError = error.message;
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _serviceRemoteError = 'Could not load service providers right now.';
        });
      } else {
        _serviceRemoteError = 'Could not load service providers right now.';
      }
    } finally {
      if (mounted) {
        setState(() => _serviceRemoteLoading = false);
      } else {
        _serviceRemoteLoading = false;
      }
    }
  }

  Future<void> _loadRestaurantLanding({bool silent = true}) async {
    if (_restaurantRemoteLoading) {
      return;
    }
    if (mounted) {
      setState(() {
        _restaurantRemoteLoading = true;
        _restaurantRemoteError = null;
      });
    } else {
      _restaurantRemoteLoading = true;
      _restaurantRemoteError = null;
    }
    try {
      final landing = await _UserAppApi.fetchRestaurantLanding(
        latitude: _selectedLatitude,
        longitude: _selectedLongitude,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _restaurantRemoteCuisines = landing.cuisines;
        _restaurantRemoteProducts
          ..clear()
          ..addAll(landing.products);
        _restaurantRemoteShops
          ..clear()
          ..addAll(landing.shops);
        _restaurantRemoteError = null;
      });
    } on _UserAppApiException catch (error) {
      if (_shouldTreatAsSilentDiscoveryFallback(error.message)) {
        if (mounted) {
          setState(() {
            _restaurantRemoteCuisines = const <_RestaurantCuisineItem>[];
            _restaurantRemoteProducts.clear();
            _restaurantRemoteShops.clear();
            _restaurantRemoteError = null;
          });
        } else {
          _restaurantRemoteCuisines = const <_RestaurantCuisineItem>[];
          _restaurantRemoteProducts.clear();
          _restaurantRemoteShops.clear();
          _restaurantRemoteError = null;
        }
        return;
      }
      if (mounted) {
        setState(() {
          _restaurantRemoteError = error.message;
        });
      } else {
        _restaurantRemoteError = error.message;
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _restaurantRemoteError = 'Could not load restaurant data right now.';
        });
      } else {
        _restaurantRemoteError = 'Could not load restaurant data right now.';
      }
    } finally {
      if (mounted) {
        setState(() => _restaurantRemoteLoading = false);
      } else {
        _restaurantRemoteLoading = false;
      }
    }
  }

  Future<void> _loadFashionLanding({bool silent = true}) async {
    if (_fashionRemoteLoading) {
      return;
    }
    if (mounted) {
      setState(() {
        _fashionRemoteLoading = true;
        _fashionRemoteError = null;
      });
    } else {
      _fashionRemoteLoading = true;
      _fashionRemoteError = null;
    }
    try {
      final landing = await _UserAppApi.fetchFashionLanding(
        latitude: _selectedLatitude,
        longitude: _selectedLongitude,
      );
      var productPage = landing.products;
      final selectedCategoryId = _fashionCategoryIdForLabel(
        _selectedShopSubCategory,
        categories: landing.categories,
      );
      if (_selectedShopSubCategory != 'All' && selectedCategoryId != null) {
        productPage = await _UserAppApi.fetchFashionProducts(
          categoryId: selectedCategoryId,
        );
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _fashionRemoteReady = true;
        _fashionRemoteCategories = landing.categories;
        _fashionRemoteProducts
          ..clear()
          ..addAll(productPage.items);
        _fashionRemoteShops
          ..clear()
          ..addAll(landing.shops);
        _fashionRemotePage = productPage.page;
        _fashionRemoteHasMore = productPage.hasMore;
        _fashionRemoteError = null;
      });
    } on _UserAppApiException catch (error) {
      if (_shouldTreatAsSilentDiscoveryFallback(error.message)) {
        if (mounted) {
          setState(() {
            _fashionRemoteReady = true;
            _fashionRemoteCategories = const <_FashionRemoteCategory>[];
            _fashionRemoteProducts.clear();
            _fashionRemoteShops.clear();
            _fashionRemoteError = null;
          });
        } else {
          _fashionRemoteReady = true;
          _fashionRemoteCategories = const <_FashionRemoteCategory>[];
          _fashionRemoteProducts.clear();
          _fashionRemoteShops.clear();
          _fashionRemoteError = null;
        }
        return;
      }
      final friendlyMessage = _friendlyShopErrorMessage(
        rawMessage: error.message,
        fallback: 'Could not load fashion data right now.',
      );
      if (mounted) {
        setState(() {
          _fashionRemoteError = friendlyMessage;
        });
      } else {
        _fashionRemoteError = friendlyMessage;
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _fashionRemoteError = 'Could not load fashion data right now.';
        });
      } else {
        _fashionRemoteError = 'Could not load fashion data right now.';
      }
    } finally {
      if (mounted) {
        setState(() => _fashionRemoteLoading = false);
      } else {
        _fashionRemoteLoading = false;
      }
    }
  }

  Future<void> _loadFootwearLanding({bool silent = true}) async {
    if (_footwearRemoteLoading) {
      return;
    }
    if (mounted) {
      setState(() {
        _footwearRemoteLoading = true;
        _footwearRemoteError = null;
      });
    } else {
      _footwearRemoteLoading = true;
      _footwearRemoteError = null;
    }
    try {
      final landing = await _UserAppApi.fetchFootwearLanding(
        latitude: _selectedLatitude,
        longitude: _selectedLongitude,
      );
      var productPage = landing.products;
      final selectedCategoryId = _footwearCategoryIdForLabel(
        _selectedShopSubCategory,
        categories: landing.categories,
      );
      if (_selectedShopSubCategory != 'All' && selectedCategoryId != null) {
        productPage = await _UserAppApi.fetchFootwearProducts(
          categoryId: selectedCategoryId,
        );
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _footwearRemoteReady = true;
        _footwearRemoteCategories = landing.categories;
        _footwearRemoteProducts
          ..clear()
          ..addAll(productPage.items);
        _footwearRemoteShops
          ..clear()
          ..addAll(landing.shops);
        _footwearRemotePage = productPage.page;
        _footwearRemoteHasMore = productPage.hasMore;
        _footwearRemoteError = null;
      });
    } on _UserAppApiException catch (error) {
      if (_shouldTreatAsSilentDiscoveryFallback(error.message)) {
        if (mounted) {
          setState(() {
            _footwearRemoteReady = true;
            _footwearRemoteCategories = const <_FootwearRemoteCategory>[];
            _footwearRemoteProducts.clear();
            _footwearRemoteShops.clear();
            _footwearRemoteError = null;
          });
        } else {
          _footwearRemoteReady = true;
          _footwearRemoteCategories = const <_FootwearRemoteCategory>[];
          _footwearRemoteProducts.clear();
          _footwearRemoteShops.clear();
          _footwearRemoteError = null;
        }
        return;
      }
      final friendlyMessage = _friendlyShopErrorMessage(
        rawMessage: error.message,
        fallback: 'Could not load footwear data right now.',
      );
      if (mounted) {
        setState(() {
          _footwearRemoteError = friendlyMessage;
        });
      } else {
        _footwearRemoteError = friendlyMessage;
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _footwearRemoteError = 'Could not load footwear data right now.';
        });
      } else {
        _footwearRemoteError = 'Could not load footwear data right now.';
      }
    } finally {
      if (mounted) {
        setState(() => _footwearRemoteLoading = false);
      } else {
        _footwearRemoteLoading = false;
      }
    }
  }

  Future<void> _loadGiftLanding({bool silent = true}) async {
    if (_giftRemoteLoading) return;
    if (mounted) {
      setState(() {
        _giftRemoteLoading = true;
        _giftRemoteError = null;
      });
    } else {
      _giftRemoteLoading = true;
      _giftRemoteError = null;
    }
    try {
      final landing = await _UserAppApi.fetchGiftLanding(
        latitude: _selectedLatitude,
        longitude: _selectedLongitude,
      );
      var productPage = landing.products;
      final selectedCategoryId = _giftCategoryIdForLabel(
        _selectedShopSubCategory,
        categories: landing.categories,
      );
      if (_selectedShopSubCategory != 'All' && selectedCategoryId != null) {
        productPage = await _UserAppApi.fetchGiftProducts(
          categoryId: selectedCategoryId,
        );
      }
      if (!mounted) return;
      setState(() {
        _giftRemoteReady = true;
        _giftRemoteCategories = landing.categories;
        _giftRemoteProducts
          ..clear()
          ..addAll(productPage.items);
        _giftRemoteShops
          ..clear()
          ..addAll(landing.shops);
        _giftRemotePage = productPage.page;
        _giftRemoteHasMore = productPage.hasMore;
        _giftRemoteError = null;
      });
    } on _UserAppApiException catch (error) {
      if (_shouldTreatAsSilentDiscoveryFallback(error.message)) {
        if (mounted) {
          setState(() {
            _giftRemoteReady = true;
            _giftRemoteCategories = const <_GiftRemoteCategory>[];
            _giftRemoteProducts.clear();
            _giftRemoteShops.clear();
            _giftRemoteError = null;
          });
        } else {
          _giftRemoteReady = true;
          _giftRemoteCategories = const <_GiftRemoteCategory>[];
          _giftRemoteProducts.clear();
          _giftRemoteShops.clear();
          _giftRemoteError = null;
        }
        return;
      }
      final friendlyMessage = _friendlyShopErrorMessage(
        rawMessage: error.message,
        fallback: 'Could not load gift data right now.',
      );
      if (mounted) {
        setState(() {
          _giftRemoteError = friendlyMessage;
        });
      } else {
        _giftRemoteError = friendlyMessage;
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _giftRemoteError = 'Could not load gift data right now.';
        });
      } else {
        _giftRemoteError = 'Could not load gift data right now.';
      }
    } finally {
      if (mounted) {
        setState(() => _giftRemoteLoading = false);
      } else {
        _giftRemoteLoading = false;
      }
    }
  }

  Future<void> _loadGroceryLanding({bool silent = true}) async {
    if (_groceryRemoteLoading) return;
    if (mounted) {
      setState(() {
        _groceryRemoteLoading = true;
        _groceryRemoteError = null;
      });
    } else {
      _groceryRemoteLoading = true;
      _groceryRemoteError = null;
    }
    try {
      final landing = await _UserAppApi.fetchGroceryLanding(
        latitude: _selectedLatitude,
        longitude: _selectedLongitude,
      );
      var productPage = landing.products;
      final selectedCategoryId = _groceryCategoryIdForLabel(
        _selectedShopSubCategory,
        categories: landing.categories,
      );
      if (_selectedShopSubCategory != 'All' && selectedCategoryId != null) {
        productPage = await _UserAppApi.fetchGroceryProducts(
          categoryId: selectedCategoryId,
        );
      }
      if (!mounted) return;
      setState(() {
        _groceryRemoteReady = true;
        _groceryRemoteCategories = landing.categories;
        _groceryRemoteProducts
          ..clear()
          ..addAll(productPage.items);
        _groceryRemoteShops
          ..clear()
          ..addAll(landing.shops);
        _groceryRemotePage = productPage.page;
        _groceryRemoteHasMore = productPage.hasMore;
        _groceryRemoteError = null;
      });
    } on _UserAppApiException catch (error) {
      if (_shouldTreatAsSilentDiscoveryFallback(error.message)) {
        if (mounted) {
          setState(() {
            _groceryRemoteReady = true;
            _groceryRemoteCategories = const <_GroceryRemoteCategory>[];
            _groceryRemoteProducts.clear();
            _groceryRemoteShops.clear();
            _groceryRemoteError = null;
          });
        } else {
          _groceryRemoteReady = true;
          _groceryRemoteCategories = const <_GroceryRemoteCategory>[];
          _groceryRemoteProducts.clear();
          _groceryRemoteShops.clear();
          _groceryRemoteError = null;
        }
        return;
      }
      final friendlyMessage = _friendlyShopErrorMessage(
        rawMessage: error.message,
        fallback: 'Could not load grocery data right now.',
      );
      if (mounted) {
        setState(() {
          _groceryRemoteError = friendlyMessage;
        });
      } else {
        _groceryRemoteError = friendlyMessage;
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _groceryRemoteError = 'Could not load grocery data right now.';
        });
      } else {
        _groceryRemoteError = 'Could not load grocery data right now.';
      }
    } finally {
      if (mounted) {
        setState(() => _groceryRemoteLoading = false);
      } else {
        _groceryRemoteLoading = false;
      }
    }
  }

  Future<void> _loadPharmacyLanding({bool silent = true}) async {
    if (_pharmacyRemoteLoading) return;
    if (mounted) {
      setState(() {
        _pharmacyRemoteLoading = true;
        _pharmacyRemoteError = null;
      });
    } else {
      _pharmacyRemoteLoading = true;
      _pharmacyRemoteError = null;
    }
    try {
      final landing = await _UserAppApi.fetchPharmacyLanding(
        latitude: _selectedLatitude,
        longitude: _selectedLongitude,
      );
      var productPage = landing.products;
      final selectedCategoryId = _pharmacyCategoryIdForLabel(
        _selectedShopSubCategory,
        categories: landing.categories,
      );
      if (_selectedShopSubCategory != 'All' && selectedCategoryId != null) {
        productPage = await _UserAppApi.fetchPharmacyProducts(
          categoryId: selectedCategoryId,
        );
      }
      if (!mounted) return;
      setState(() {
        _pharmacyRemoteReady = true;
        _pharmacyRemoteCategories = landing.categories;
        _pharmacyRemoteProducts
          ..clear()
          ..addAll(productPage.items);
        _pharmacyRemoteShops
          ..clear()
          ..addAll(landing.shops);
        _pharmacyRemotePage = productPage.page;
        _pharmacyRemoteHasMore = productPage.hasMore;
        _pharmacyRemoteError = null;
      });
    } on _UserAppApiException catch (error) {
      if (_shouldTreatAsSilentDiscoveryFallback(error.message)) {
        if (mounted) {
          setState(() {
            _pharmacyRemoteReady = true;
            _pharmacyRemoteCategories = const <_PharmacyRemoteCategory>[];
            _pharmacyRemoteProducts.clear();
            _pharmacyRemoteShops.clear();
            _pharmacyRemoteError = null;
          });
        } else {
          _pharmacyRemoteReady = true;
          _pharmacyRemoteCategories = const <_PharmacyRemoteCategory>[];
          _pharmacyRemoteProducts.clear();
          _pharmacyRemoteShops.clear();
          _pharmacyRemoteError = null;
        }
        return;
      }
      final friendlyMessage = _friendlyShopErrorMessage(
        rawMessage: error.message,
        fallback: 'Could not load pharmacy data right now.',
      );
      if (mounted) {
        setState(() {
          _pharmacyRemoteError = friendlyMessage;
        });
      } else {
        _pharmacyRemoteError = friendlyMessage;
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _pharmacyRemoteError = 'Could not load pharmacy data right now.';
        });
      } else {
        _pharmacyRemoteError = 'Could not load pharmacy data right now.';
      }
    } finally {
      if (mounted) {
        setState(() => _pharmacyRemoteLoading = false);
      } else {
        _pharmacyRemoteLoading = false;
      }
    }
  }

  int? _labourCategoryIdForLabel(String label) {
    for (final category in _labourRemoteCategories) {
      if (category.label == label) {
        return category.backendCategoryId;
      }
    }
    return null;
  }

  String? _labourCategoryLabelForId(int? categoryId) {
    if (categoryId == null) {
      return null;
    }
    for (final category in _labourRemoteCategories) {
      if (category.backendCategoryId == categoryId) {
        final label = category.label.trim();
        if (label.isNotEmpty && label.toLowerCase() != 'all labour') {
          return label;
        }
      }
    }
    return null;
  }

  int _availableLabourCountForGroupCategory(int? categoryId) {
    if (categoryId == null) {
      return 0;
    }
    final profiles = _labourRemoteProfiles.where(
      (item) =>
          item.backendCategoryId == categoryId ||
          item.labourCategoryPricing.any(
            (pricing) => pricing.categoryId == categoryId,
          ),
    );
    return profiles.where((item) => !item.isDisabled).length;
  }

  int? _serviceCategoryIdForLabel(String label) {
    for (final category in _serviceRemoteCategories) {
      if (category.label == label) {
        return category.backendCategoryId;
      }
    }
    return null;
  }

  int? _serviceSubcategoryIdForSelection(
    String categoryLabel,
    String subcategoryLabel,
  ) {
    for (final category in _serviceRemoteCategories) {
      if (category.label != categoryLabel) {
        continue;
      }
      for (final subcategory in category.subcategories) {
        if (subcategory.label == subcategoryLabel) {
          return subcategory.backendSubcategoryId;
        }
      }
    }
    return null;
  }

  Future<void> _selectRestaurantCuisine(String value) async {
    setState(() {
      _selectedRestaurantCuisine = value;
      _restaurantRemoteLoading = true;
      _restaurantRemoteProducts.clear();
    });
    _RestaurantCuisineItem? selectedCategory;
    for (final item in _restaurantRemoteCuisines) {
      if (item.label == value) {
        selectedCategory = item;
        break;
      }
    }
    try {
      final products = await _UserAppApi.fetchRestaurantProducts(
        categoryId: selectedCategory?.backendCategoryId,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _restaurantRemoteProducts
          ..clear()
          ..addAll(products);
      });
    } on _UserAppApiException catch (error) {
      if (mounted && !_shouldTreatAsEmptyResults(error.message)) {
        _showCartSnack('Could not refresh restaurant items right now.');
      }
    } catch (_) {
      if (mounted) {
        _showCartSnack('Could not refresh restaurant items right now.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _restaurantRemoteLoading = false;
        });
      } else {
        _restaurantRemoteLoading = false;
      }
    }
  }

  Future<void> _selectFashionSubcategory(
    String value, {
    bool silent = true,
  }) async {
    setState(() {
      _selectedShopSubCategory = value;
    });
    if (!_fashionRemoteReady && value == 'All') {
      await _loadFashionLanding(silent: silent);
      return;
    }
    final categoryId = _fashionCategoryIdForLabel(value);
    try {
      final page = value == 'All' && !_fashionRemoteReady
          ? (await _UserAppApi.fetchFashionLanding(
              latitude: _selectedLatitude,
              longitude: _selectedLongitude,
            )).products
          : await _UserAppApi.fetchFashionProducts(categoryId: categoryId);
      if (!mounted) {
        return;
      }
      setState(() {
        _fashionRemoteReady = true;
        _fashionRemoteProducts
          ..clear()
          ..addAll(page.items);
        _fashionRemotePage = page.page;
        _fashionRemoteHasMore = page.hasMore;
      });
    } on _UserAppApiException catch (error) {
      if (!silent && mounted && !_shouldTreatAsEmptyResults(error.message)) {
        _showCartSnack('Could not refresh fashion items right now.');
      }
    } catch (_) {
      if (!silent && mounted) {
        _showCartSnack('Could not refresh fashion items right now.');
      }
    }
  }

  Future<void> _loadMoreFashionProducts() async {
    if (_fashionRemoteLoading ||
        !_fashionRemoteReady ||
        !_fashionRemoteHasMore) {
      return;
    }
    _fashionRemoteLoading = true;
    try {
      final nextPage = _fashionRemotePage + 1;
      final page = await _UserAppApi.fetchFashionProducts(
        categoryId: _fashionCategoryIdForLabel(_selectedShopSubCategory),
        page: nextPage,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _fashionRemoteProducts.addAll(page.items);
        _fashionRemotePage = page.page;
        _fashionRemoteHasMore = page.hasMore;
      });
    } catch (_) {
      if (mounted) {
        _showCartSnack('Could not load more fashion items right now.');
      }
    } finally {
      _fashionRemoteLoading = false;
    }
  }

  Future<void> _selectFootwearSubcategory(
    String value, {
    bool silent = true,
  }) async {
    setState(() {
      _selectedShopSubCategory = value;
      _footwearRemoteLoading = true;
      _footwearRemoteProducts.clear();
      _footwearRemoteError = null;
    });
    if (!_footwearRemoteReady && value == 'All') {
      await _loadFootwearLanding(silent: silent);
      return;
    }
    final categoryId = _footwearCategoryIdForLabel(value);
    try {
      final page = value == 'All' && !_footwearRemoteReady
          ? (await _UserAppApi.fetchFootwearLanding(
              latitude: _selectedLatitude,
              longitude: _selectedLongitude,
            )).products
          : await _UserAppApi.fetchFootwearProducts(categoryId: categoryId);
      if (!mounted) {
        return;
      }
      setState(() {
        _footwearRemoteReady = true;
        _footwearRemoteProducts
          ..clear()
          ..addAll(page.items);
        _footwearRemotePage = page.page;
        _footwearRemoteHasMore = page.hasMore;
      });
    } on _UserAppApiException catch (error) {
      if (!silent && mounted && !_shouldTreatAsEmptyResults(error.message)) {
        _showCartSnack('Could not refresh footwear items right now.');
      }
    } catch (_) {
      if (!silent && mounted) {
        _showCartSnack('Could not refresh footwear items right now.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _footwearRemoteLoading = false;
        });
      } else {
        _footwearRemoteLoading = false;
      }
    }
  }

  Future<void> _selectGiftSubcategory(
    String value, {
    bool silent = true,
  }) async {
    setState(() {
      _selectedShopSubCategory = value;
      _giftRemoteLoading = true;
      _giftRemoteProducts.clear();
      _giftRemoteError = null;
    });
    final categoryId = _giftCategoryIdForLabel(value);
    try {
      final page = await _UserAppApi.fetchGiftProducts(categoryId: categoryId);
      if (!mounted) return;
      setState(() {
        _giftRemoteReady = true;
        _giftRemoteProducts
          ..clear()
          ..addAll(page.items);
        _giftRemotePage = page.page;
        _giftRemoteHasMore = page.hasMore;
      });
    } on _UserAppApiException catch (error) {
      if (!silent && mounted && !_shouldTreatAsEmptyResults(error.message)) {
        _showCartSnack('Could not refresh gift items right now.');
      }
    } catch (_) {
      if (!silent && mounted) {
        _showCartSnack('Could not refresh gift items right now.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _giftRemoteLoading = false;
        });
      } else {
        _giftRemoteLoading = false;
      }
    }
  }

  Future<void> _selectGrocerySubcategory(
    String value, {
    bool silent = true,
  }) async {
    setState(() {
      _selectedShopSubCategory = value;
      _groceryRemoteLoading = true;
      _groceryRemoteProducts.clear();
      _groceryRemoteError = null;
    });
    final categoryId = _groceryCategoryIdForLabel(value);
    try {
      final page = await _UserAppApi.fetchGroceryProducts(
        categoryId: categoryId,
      );
      if (!mounted) return;
      setState(() {
        _groceryRemoteReady = true;
        _groceryRemoteProducts
          ..clear()
          ..addAll(page.items);
        _groceryRemotePage = page.page;
        _groceryRemoteHasMore = page.hasMore;
      });
    } on _UserAppApiException catch (error) {
      if (!silent && mounted && !_shouldTreatAsEmptyResults(error.message)) {
        _showCartSnack('Could not refresh grocery items right now.');
      }
    } catch (_) {
      if (!silent && mounted) {
        _showCartSnack('Could not refresh grocery items right now.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _groceryRemoteLoading = false;
        });
      } else {
        _groceryRemoteLoading = false;
      }
    }
  }

  Future<void> _selectPharmacySubcategory(
    String value, {
    bool silent = true,
  }) async {
    setState(() {
      _selectedShopSubCategory = value;
      _pharmacyRemoteLoading = true;
      _pharmacyRemoteProducts.clear();
      _pharmacyRemoteError = null;
    });
    final categoryId = _pharmacyCategoryIdForLabel(value);
    try {
      final page = await _UserAppApi.fetchPharmacyProducts(
        categoryId: categoryId,
      );
      if (!mounted) return;
      setState(() {
        _pharmacyRemoteReady = true;
        _pharmacyRemoteProducts
          ..clear()
          ..addAll(page.items);
        _pharmacyRemotePage = page.page;
        _pharmacyRemoteHasMore = page.hasMore;
      });
    } on _UserAppApiException catch (error) {
      if (!silent && mounted && !_shouldTreatAsEmptyResults(error.message)) {
        _showCartSnack('Could not refresh pharmacy items right now.');
      }
    } catch (_) {
      if (!silent && mounted) {
        _showCartSnack('Could not refresh pharmacy items right now.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _pharmacyRemoteLoading = false;
        });
      } else {
        _pharmacyRemoteLoading = false;
      }
    }
  }

  Future<void> _loadMoreFootwearProducts() async {
    if (_footwearRemoteLoading ||
        !_footwearRemoteReady ||
        !_footwearRemoteHasMore) {
      return;
    }
    _footwearRemoteLoading = true;
    try {
      final nextPage = _footwearRemotePage + 1;
      final page = await _UserAppApi.fetchFootwearProducts(
        categoryId: _footwearCategoryIdForLabel(_selectedShopSubCategory),
        page: nextPage,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _footwearRemoteProducts.addAll(page.items);
        _footwearRemotePage = page.page;
        _footwearRemoteHasMore = page.hasMore;
      });
    } catch (_) {
      if (mounted) {
        _showCartSnack('Could not load more footwear items right now.');
      }
    } finally {
      _footwearRemoteLoading = false;
    }
  }

  Future<void> _loadMoreGiftProducts() async {
    if (_giftRemoteLoading || !_giftRemoteReady || !_giftRemoteHasMore) return;
    _giftRemoteLoading = true;
    try {
      final page = await _UserAppApi.fetchGiftProducts(
        categoryId: _giftCategoryIdForLabel(_selectedShopSubCategory),
        page: _giftRemotePage + 1,
      );
      if (!mounted) return;
      setState(() {
        _giftRemoteProducts.addAll(page.items);
        _giftRemotePage = page.page;
        _giftRemoteHasMore = page.hasMore;
      });
    } finally {
      _giftRemoteLoading = false;
    }
  }

  Future<void> _loadMoreGroceryProducts() async {
    if (_groceryRemoteLoading || !_groceryRemoteReady || !_groceryRemoteHasMore)
      return;
    _groceryRemoteLoading = true;
    try {
      final page = await _UserAppApi.fetchGroceryProducts(
        categoryId: _groceryCategoryIdForLabel(_selectedShopSubCategory),
        page: _groceryRemotePage + 1,
      );
      if (!mounted) return;
      setState(() {
        _groceryRemoteProducts.addAll(page.items);
        _groceryRemotePage = page.page;
        _groceryRemoteHasMore = page.hasMore;
      });
    } finally {
      _groceryRemoteLoading = false;
    }
  }

  Future<void> _loadMorePharmacyProducts() async {
    if (_pharmacyRemoteLoading ||
        !_pharmacyRemoteReady ||
        !_pharmacyRemoteHasMore)
      return;
    _pharmacyRemoteLoading = true;
    try {
      final page = await _UserAppApi.fetchPharmacyProducts(
        categoryId: _pharmacyCategoryIdForLabel(_selectedShopSubCategory),
        page: _pharmacyRemotePage + 1,
      );
      if (!mounted) return;
      setState(() {
        _pharmacyRemoteProducts.addAll(page.items);
        _pharmacyRemotePage = page.page;
        _pharmacyRemoteHasMore = page.hasMore;
      });
    } finally {
      _pharmacyRemoteLoading = false;
    }
  }

  int? _fashionCategoryIdForLabel(
    String label, {
    List<_FashionRemoteCategory>? categories,
  }) {
    for (final item in categories ?? _fashionRemoteCategories) {
      if (item.label == label) {
        return item.backendCategoryId;
      }
    }
    return null;
  }

  int? _footwearCategoryIdForLabel(
    String label, {
    List<_FootwearRemoteCategory>? categories,
  }) {
    for (final item in categories ?? _footwearRemoteCategories) {
      if (item.label == label) {
        return item.backendCategoryId;
      }
    }
    return null;
  }

  int? _giftCategoryIdForLabel(
    String label, {
    List<_GiftRemoteCategory>? categories,
  }) {
    for (final item in categories ?? _giftRemoteCategories) {
      if (item.label == label) return item.backendCategoryId;
    }
    return null;
  }

  int? _groceryCategoryIdForLabel(
    String label, {
    List<_GroceryRemoteCategory>? categories,
  }) {
    for (final item in categories ?? _groceryRemoteCategories) {
      if (item.label == label) return item.backendCategoryId;
    }
    return null;
  }

  int? _pharmacyCategoryIdForLabel(
    String label, {
    List<_PharmacyRemoteCategory>? categories,
  }) {
    for (final item in categories ?? _pharmacyRemoteCategories) {
      if (item.label == label) return item.backendCategoryId;
    }
    return null;
  }

  void _handleScroll() {
    final next = _scrollController.offset > 320;
    final shouldLoadMoreFashion =
        _mode == _HomeMode.shop &&
        _shopBrowseMode == _ShopBrowseMode.itemWise &&
        _selectedShopCategory == 'Fashion' &&
        (_fashionRemoteReady
            ? (_fashionRemoteHasMore && !_fashionRemoteLoading)
            : (_fashionVisibleProductCount < _fashionProductTotalCount &&
                  !_fashionLoadMoreQueued)) &&
        _scrollController.position.extentAfter < 700;
    final shouldLoadMoreFootwear =
        _mode == _HomeMode.shop &&
        _shopBrowseMode == _ShopBrowseMode.itemWise &&
        _selectedShopCategory == 'Footwear' &&
        (_footwearRemoteReady
            ? (_footwearRemoteHasMore && !_footwearRemoteLoading)
            : (_footwearVisibleProductCount < _footwearProductTotalCount &&
                  !_footwearLoadMoreQueued)) &&
        _scrollController.position.extentAfter < 700;
    final shouldLoadMoreGift =
        _mode == _HomeMode.shop &&
        _shopBrowseMode == _ShopBrowseMode.itemWise &&
        _selectedShopCategory == 'Gift' &&
        _giftRemoteReady &&
        _giftRemoteHasMore &&
        !_giftRemoteLoading &&
        _scrollController.position.extentAfter < 700;
    final shouldLoadMoreGrocery =
        _mode == _HomeMode.shop &&
        _shopBrowseMode == _ShopBrowseMode.itemWise &&
        _selectedShopCategory == 'Groceries' &&
        _groceryRemoteReady &&
        _groceryRemoteHasMore &&
        !_groceryRemoteLoading &&
        _scrollController.position.extentAfter < 700;
    final shouldLoadMorePharmacy =
        _mode == _HomeMode.shop &&
        _shopBrowseMode == _ShopBrowseMode.itemWise &&
        _selectedShopCategory == 'Pharmacy' &&
        _pharmacyRemoteReady &&
        _pharmacyRemoteHasMore &&
        !_pharmacyRemoteLoading &&
        _scrollController.position.extentAfter < 700;
    if (next != _showScrollToTop) {
      setState(() {
        _showScrollToTop = next;
      });
    }
    if (shouldLoadMoreFashion) {
      if (_fashionRemoteReady) {
        unawaited(_loadMoreFashionProducts());
      } else {
        _queueFashionLoadMore();
      }
    }
    if (shouldLoadMoreFootwear) {
      if (_footwearRemoteReady) {
        unawaited(_loadMoreFootwearProducts());
      } else {
        _queueFootwearLoadMore();
      }
    }
    if (shouldLoadMoreGift) {
      unawaited(_loadMoreGiftProducts());
    }
    if (shouldLoadMoreGrocery) {
      unawaited(_loadMoreGroceryProducts());
    }
    if (shouldLoadMorePharmacy) {
      unawaited(_loadMorePharmacyProducts());
    }
  }

  void _queueFashionLoadMore() {
    _fashionLoadMoreQueued = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _fashionVisibleProductCount =
            (_fashionVisibleProductCount + _fashionProductBatchSize)
                .clamp(0, _fashionProductTotalCount)
                .toInt();
        _fashionLoadMoreQueued = false;
      });
    });
  }

  void _queueFootwearLoadMore() {
    _footwearLoadMoreQueued = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _footwearVisibleProductCount =
            (_footwearVisibleProductCount + _footwearProductBatchSize)
                .clamp(0, _footwearProductTotalCount)
                .toInt();
        _footwearLoadMoreQueued = false;
      });
    });
  }

  Future<void> _openShopSortSheet() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        const options = [
          'Popular',
          'Low to High',
          'High to Low',
          'Newly Added',
        ];
        return Container(
          margin: const EdgeInsets.fromLTRB(14, 0, 14, 16),
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 34,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0D7D0),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Sort fashion items',
                  style: TextStyle(
                    color: Color(0xFF202435),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 14),
                for (final option in options)
                  _ShopSortOptionTile(
                    label: option,
                    selected: option == _shopSortOption,
                    onTap: () => Navigator.of(context).pop(option),
                  ),
              ],
            ),
          ),
        );
      },
    );
    if (selected == null || selected == _shopSortOption || !mounted) {
      return;
    }
    setState(() {
      _shopSortOption = selected;
      _fashionVisibleProductCount = _fashionProductBatchSize;
      _footwearVisibleProductCount = _footwearProductBatchSize;
    });
  }

  Future<void> _openShopFilterPage() async {
    final applied = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => _selectedShopCategory == 'Footwear'
            ? _ShopFootwearFilterPage(
                initialGender: _selectedShopSubCategory == 'All'
                    ? 'Men'
                    : _selectedShopSubCategory,
              )
            : _selectedShopCategory == 'Gift'
            ? _ShopGiftFilterPage(
                initialCategory: _selectedShopSubCategory == 'All'
                    ? 'Flowers'
                    : _selectedShopSubCategory,
              )
            : _selectedShopCategory == 'Groceries'
            ? _ShopGroceryFilterPage(
                initialCategory: _selectedShopSubCategory == 'All'
                    ? 'Biscuits'
                    : _selectedShopSubCategory,
              )
            : _selectedShopCategory == 'Pharmacy'
            ? _ShopPharmacyFilterPage(
                initialCategory: _selectedShopSubCategory == 'All'
                    ? 'Wellness'
                    : _selectedShopSubCategory,
              )
            : _ShopFilterPage(
                initialGender: _selectedShopSubCategory == 'All'
                    ? 'Men'
                    : _selectedShopSubCategory,
              ),
      ),
    );
    if (applied == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Filters applied. API filtering will connect with backend pagination next.',
          ),
        ),
      );
    }
  }

  SliverToBoxAdapter _buildRemoteStateSliver({
    required IconData icon,
    required String title,
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
    bool loading = false,
  }) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
        child: _AsyncStateCard(
          icon: icon,
          title: title,
          message: message,
          actionLabel: actionLabel,
          onAction: onAction,
          loading: loading,
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildAreaComingSoonSliver({
    required IconData icon,
    String title = 'Coming soon in your area....!',
    String message =
        'We are opening this around your selected location. Please check again soon.',
  }) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 2, 18, 0),
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFFF5E8), Color(0xFFFDF1F8), Color(0xFFEFF7FF)],
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFFF0D7B0)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1A2030).withValues(alpha: 0.06),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.88),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: const Color(0xFFCB6E5B), size: 28),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF22314D),
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFF22314D).withValues(alpha: 0.74),
                  fontSize: 13.2,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget? _buildLabourStateSliver() {
    if (_labourRemoteLoading) {
      return null;
    }
    if (_labourRemoteError != null && _labourRemoteProfiles.isEmpty) {
      return _buildRemoteStateSliver(
        icon: Icons.engineering_rounded,
        title: 'Labour is temporarily unavailable',
        message: _friendlyShopErrorMessage(
          rawMessage: _labourRemoteError!,
          fallback:
              'We could not load labour right now. Please try again in a moment.',
        ),
        actionLabel: 'Try Again',
        onAction: () => unawaited(_loadLabourLanding(silent: false)),
      );
    }
    if (_labourRemoteReady && _labourRemoteProfiles.isEmpty) {
      final selectedCategoryName = _selectedLabourCategory.trim().isEmpty
          ? 'labour category'
          : _selectedLabourCategory;
      return _buildAreaComingSoonSliver(
        icon: Icons.engineering_rounded,
        title: 'No labour available yet',
        message:
            'No labour is available yet for $selectedCategoryName. Every day we are onboarding more labour partners to help them get jobs and help you get work done faster.',
      );
    }
    return null;
  }

  List<_DiscoveryItem> get _filteredSingleLabourProfiles {
    final period = _selectedSingleLabourPeriod.trim().toUpperCase();
    final maxPrice = _parseMoneyAmount(_selectedSingleLabourMaxPrice);
    final selectedCategoryId = _labourCategoryIdForLabel(
      _selectedLabourCategory,
    );
    return _labourRemoteProfiles
        .where((item) {
          if (selectedCategoryId != null &&
              item.backendCategoryId != selectedCategoryId &&
              !item.labourCategoryPricing.any(
                (pricing) => pricing.categoryId == selectedCategoryId,
              )) {
            return false;
          }
          final halfDay = _parseMoneyAmount(item.labourHalfDayPrice);
          final fullDay = _parseMoneyAmount(item.labourFullDayPrice);
          if (item.backendLabourId != null && halfDay <= 0 && fullDay <= 0) {
            return false;
          }
          if (period == 'HALF DAY') {
            if (halfDay <= 0) {
              return false;
            }
            return maxPrice <= 0 || halfDay <= maxPrice;
          }
          if (period == 'FULL DAY') {
            if (fullDay <= 0) {
              return false;
            }
            return maxPrice <= 0 || fullDay <= maxPrice;
          }
          if (maxPrice <= 0) {
            return true;
          }
          final prices = <double>[
            if (halfDay > 0) halfDay,
            if (fullDay > 0) fullDay,
          ];
          return prices.any((price) => price <= maxPrice);
        })
        .toList(growable: false);
  }

  double _parseMoneyAmount(String value) {
    final normalized = value.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(normalized) ?? 0;
  }

  Widget? _buildServiceStateSliver({required bool hasVisibleProviders}) {
    if (_serviceRemoteLoading && !hasVisibleProviders) {
      return _buildRemoteStateSliver(
        icon: Icons.handyman_rounded,
        title: 'Loading service providers',
        message:
            'We are fetching live providers for the category you selected.',
        loading: true,
      );
    }
    if (_serviceRemoteError != null && !hasVisibleProviders) {
      return _buildAreaComingSoonSliver(
        icon: Icons.handyman_rounded,
        message:
            'Service providers are not available in your selected area right now.',
      );
    }
    if (_serviceRemoteReady && !hasVisibleProviders) {
      return _buildAreaComingSoonSliver(
        icon: Icons.handyman_rounded,
        message:
            'No service provider is registered within your selected range yet.',
      );
    }
    return null;
  }

  Widget? _buildShopRemoteStateSliver() {
    if (_showShopAllLanding) {
      final hasAnyShopData =
          _restaurantRemoteProducts.isNotEmpty ||
          _restaurantRemoteShops.isNotEmpty ||
          (_fashionRemoteReady &&
              (_fashionRemoteProducts.isNotEmpty ||
                  _fashionRemoteShops.isNotEmpty)) ||
          (_footwearRemoteReady &&
              (_footwearRemoteProducts.isNotEmpty ||
                  _footwearRemoteShops.isNotEmpty)) ||
          (_giftRemoteReady &&
              (_giftRemoteProducts.isNotEmpty ||
                  _giftRemoteShops.isNotEmpty)) ||
          (_groceryRemoteReady &&
              (_groceryRemoteProducts.isNotEmpty ||
                  _groceryRemoteShops.isNotEmpty)) ||
          (_pharmacyRemoteReady &&
              (_pharmacyRemoteProducts.isNotEmpty ||
                  _pharmacyRemoteShops.isNotEmpty));
      if (!hasAnyShopData) {
        return _buildAreaComingSoonSliver(
          icon: Icons.storefront_rounded,
          message: 'No shop is registered within your selected range yet.',
        );
      }
      return null;
    }
    if (_showShopRestaurantLanding) {
      final hasData =
          _restaurantRemoteProducts.isNotEmpty ||
          _restaurantRemoteShops.isNotEmpty ||
          _restaurantRemoteCuisines.isNotEmpty;
      if (_restaurantRemoteLoading && !hasData) {
        return _buildRemoteStateSliver(
          icon: Icons.restaurant_menu_rounded,
          title: 'Loading restaurants',
          message:
              'We are bringing in live restaurants, cuisines, and shop listings.',
          loading: true,
        );
      }
      if (_restaurantRemoteError != null && !hasData) {
        return _buildAreaComingSoonSliver(
          icon: Icons.restaurant_menu_rounded,
          message:
              'Restaurants are not available in your selected area right now.',
        );
      }
      if (!hasData) {
        return _buildAreaComingSoonSliver(
          icon: Icons.restaurant_menu_rounded,
          message:
              'No restaurant is registered within your selected range yet.',
        );
      }
      return null;
    }

    switch (_selectedShopCategory) {
      case 'Fashion':
        final hasData =
            _fashionRemoteProducts.isNotEmpty || _fashionRemoteShops.isNotEmpty;
        if (_fashionRemoteLoading && !hasData) {
          return _buildRemoteStateSliver(
            icon: Icons.checkroom_rounded,
            title: 'Loading fashion items',
            message:
                'We are fetching the latest items and nearby fashion shops.',
            loading: true,
          );
        }
        if (_fashionRemoteError != null && !hasData) {
          return _buildAreaComingSoonSliver(
            icon: Icons.checkroom_rounded,
            message:
                'Fashion shops are not available in your selected area right now.',
          );
        }
        if (_fashionRemoteReady && !hasData) {
          return _buildAreaComingSoonSliver(
            icon: Icons.checkroom_rounded,
            message:
                'No fashion shop is registered within your selected range yet.',
          );
        }
        return null;
      case 'Footwear':
        final hasData =
            _footwearRemoteProducts.isNotEmpty ||
            _footwearRemoteShops.isNotEmpty;
        if (_footwearRemoteLoading && !hasData) {
          return _buildRemoteStateSliver(
            icon: Icons.shopping_bag_outlined,
            title: 'Loading footwear',
            message:
                'We are fetching the latest footwear items and shop listings.',
            loading: true,
          );
        }
        if (_footwearRemoteError != null && !hasData) {
          return _buildAreaComingSoonSliver(
            icon: Icons.shopping_bag_outlined,
            message:
                'Footwear shops are not available in your selected area right now.',
          );
        }
        if (_footwearRemoteReady && !hasData) {
          return _buildAreaComingSoonSliver(
            icon: Icons.shopping_bag_outlined,
            message:
                'No footwear shop is registered within your selected range yet.',
          );
        }
        return null;
      case 'Gift':
        final hasData =
            _giftRemoteProducts.isNotEmpty || _giftRemoteShops.isNotEmpty;
        if (_giftRemoteLoading && !hasData) {
          return _buildRemoteStateSliver(
            icon: Icons.redeem_rounded,
            title: 'Loading gifts',
            message:
                'We are fetching gift items and shop picks for this selection.',
            loading: true,
          );
        }
        if (_giftRemoteError != null && !hasData) {
          return _buildAreaComingSoonSliver(
            icon: Icons.redeem_rounded,
            message:
                'Gift shops are not available in your selected area right now.',
          );
        }
        if (_giftRemoteReady && !hasData) {
          return _buildAreaComingSoonSliver(
            icon: Icons.redeem_rounded,
            message:
                'No gift shop is registered within your selected range yet.',
          );
        }
        return null;
      case 'Groceries':
        final hasData =
            _groceryRemoteProducts.isNotEmpty || _groceryRemoteShops.isNotEmpty;
        if (_groceryRemoteLoading && !hasData) {
          return _buildRemoteStateSliver(
            icon: Icons.local_grocery_store_rounded,
            title: 'Loading groceries',
            message: 'We are fetching grocery items and nearby shop listings.',
            loading: true,
          );
        }
        if (_groceryRemoteError != null && !hasData) {
          return _buildAreaComingSoonSliver(
            icon: Icons.local_grocery_store_rounded,
            message:
                'Grocery shops are not available in your selected area right now.',
          );
        }
        if (_groceryRemoteReady && !hasData) {
          return _buildAreaComingSoonSliver(
            icon: Icons.local_grocery_store_rounded,
            message:
                'No grocery shop is registered within your selected range yet.',
          );
        }
        return null;
      case 'Pharmacy':
        final hasData =
            _pharmacyRemoteProducts.isNotEmpty ||
            _pharmacyRemoteShops.isNotEmpty;
        if (_pharmacyRemoteLoading && !hasData) {
          return _buildRemoteStateSliver(
            icon: Icons.local_pharmacy_rounded,
            title: 'Loading pharmacy items',
            message:
                'We are fetching live pharmacy inventory and nearby shops.',
            loading: true,
          );
        }
        if (_pharmacyRemoteError != null && !hasData) {
          return _buildAreaComingSoonSliver(
            icon: Icons.local_pharmacy_rounded,
            message:
                'Pharmacy shops are not available in your selected area right now.',
          );
        }
        if (_pharmacyRemoteReady && !hasData) {
          return _buildAreaComingSoonSliver(
            icon: Icons.local_pharmacy_rounded,
            message:
                'No pharmacy shop is registered within your selected range yet.',
          );
        }
        return null;
      default:
        return null;
    }
  }

  bool _hasRestaurantShopData() =>
      _restaurantRemoteProducts.isNotEmpty ||
      _restaurantRemoteShops.isNotEmpty ||
      _restaurantRemoteCuisines.isNotEmpty;

  bool _hasFashionShopData() =>
      _fashionRemoteProducts.isNotEmpty || _fashionRemoteShops.isNotEmpty;

  bool _hasFootwearShopData() =>
      _footwearRemoteProducts.isNotEmpty || _footwearRemoteShops.isNotEmpty;

  bool _hasGiftShopData() =>
      _giftRemoteProducts.isNotEmpty || _giftRemoteShops.isNotEmpty;

  bool _hasGroceryShopData() =>
      _groceryRemoteProducts.isNotEmpty || _groceryRemoteShops.isNotEmpty;

  bool _hasPharmacyShopData() =>
      _pharmacyRemoteProducts.isNotEmpty || _pharmacyRemoteShops.isNotEmpty;

  List<String> get _availableShopCategories {
    final categories = <String>['All Deals'];
    if (_hasRestaurantShopData()) {
      categories.add('Restaurant');
    }
    if (_hasFashionShopData()) {
      categories.add('Fashion');
    }
    if (_hasFootwearShopData()) {
      categories.add('Footwear');
    }
    if (_hasGroceryShopData()) {
      categories.add('Groceries');
    }
    if (_hasPharmacyShopData()) {
      categories.add('Pharmacy');
    }
    if (_hasGiftShopData()) {
      categories.add('Gift');
    }
    return categories;
  }

  bool _shouldTreatAsEmptyResults(String message) {
    final normalized = message.trim().toLowerCase();
    return normalized.contains('not found') ||
        normalized.contains('no result') ||
        normalized.contains('no results') ||
        normalized.contains('empty') ||
        normalized.contains('no shop') ||
        normalized.contains('no shops') ||
        normalized.contains('no store') ||
        normalized.contains('no restaurant') ||
        normalized.contains('no restaurants') ||
        normalized.contains('no cuisine') ||
        normalized.contains('no gift') ||
        normalized.contains('no provider') ||
        normalized.contains('no providers') ||
        normalized.contains('no service') ||
        normalized.contains('no data');
  }

  bool _shouldTreatAsSilentDiscoveryFallback(String message) {
    return _shouldTreatAsEmptyResults(message) ||
        _shouldUseFriendlyShopErrorMessage(message);
  }

  bool _shouldUseFriendlyShopErrorMessage(String message) {
    final normalized = message.trim().toLowerCase();
    return normalized.isEmpty ||
        normalized.contains('unexpected server error') ||
        normalized.contains('internal server error') ||
        normalized.contains('unexpected error') ||
        normalized.contains('something went wrong') ||
        normalized.contains('failed to load') ||
        normalized.contains('failed to fetch');
  }

  String _friendlyShopErrorMessage({
    required String rawMessage,
    required String fallback,
  }) {
    if (_shouldUseFriendlyShopErrorMessage(rawMessage)) {
      return fallback;
    }
    return rawMessage;
  }

  void _ensureShopSelectionIsVisible() {
    if (_mode != _HomeMode.shop) {
      return;
    }
    final availableCategories = _availableShopCategories;
    final fallbackCategory = availableCategories.isEmpty
        ? 'All Deals'
        : availableCategories.first;
    if (availableCategories.contains(_selectedShopCategory)) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _selectedShopCategory = fallbackCategory;
        _selectedShopSubCategory = 'All';
      });
    });
  }

  String get _searchHint {
    switch (_mode) {
      case _HomeMode.all:
        return 'Search labour, service, shops or items';
      case _HomeMode.labour:
        return 'Search only labour';
      case _HomeMode.service:
        return 'Search service providers or categories';
      case _HomeMode.shop:
        return 'Search shop category or item';
    }
  }

  List<String> get _modeFilters {
    switch (_mode) {
      case _HomeMode.all:
        return const <String>[];
      case _HomeMode.labour:
        return _labourRemoteCategories.isNotEmpty
            ? _labourRemoteCategories
                  .map((item) => item.label)
                  .toList(growable: false)
            : const <String>[];
      case _HomeMode.service:
        return _serviceRemoteCategories.isNotEmpty
            ? _serviceRemoteCategories
                  .map((item) => item.label)
                  .toList(growable: false)
            : const <String>[];
      case _HomeMode.shop:
        return _availableShopCategories;
    }
  }

  String get _defaultServiceCategoryLabel => _serviceRemoteCategories.isEmpty
      ? ''
      : _serviceRemoteCategories.first.label;

  String _defaultServiceSubcategoryLabelFor(String categoryLabel) {
    for (final category in _serviceRemoteCategories) {
      if (category.label != categoryLabel) {
        continue;
      }
      for (final subcategory in category.subcategories) {
        if (subcategory.label != 'All') {
          return subcategory.label;
        }
      }
      return category.subcategories.firstOrNull?.label ?? '';
    }
    return '';
  }

  List<String> get _selectedServiceSubcategories {
    final activeCategory = _selectedServiceCategory.trim().isEmpty
        ? _defaultServiceCategoryLabel
        : _selectedServiceCategory;
    return _serviceRemoteCategories.isNotEmpty
        ? _serviceRemoteCategories
              .where((category) => category.label == activeCategory)
              .expand((category) => category.subcategories)
              .map((subcategory) => subcategory.label)
              .toList(growable: false)
        : const <String>['All'];
  }

  String get _serviceSubcategoryStripCategoryLabel {
    return _selectedServiceCategory.trim().isEmpty
        ? _defaultServiceCategoryLabel
        : _selectedServiceCategory;
  }

  List<String> get _serviceSubcategoryStripOptions {
    return _selectedServiceSubcategories
        .where((label) => label != 'All')
        .toList(growable: false);
  }

  String get _selectedServiceBookingLabel {
    if (_selectedServiceSubCategory.trim().isNotEmpty) {
      return _selectedServiceSubCategory;
    }
    if (_selectedServiceCategory.trim().isNotEmpty) {
      return _selectedServiceCategory;
    }
    return 'service';
  }

  List<_DiscoveryItem> get _filteredServiceProviders {
    final normalizedQuery = _searchController.text.trim().toLowerCase();
    final selectedCategoryId = _serviceCategoryIdForLabel(
      _selectedServiceCategory,
    );
    final selectedSubcategoryId = _serviceSubcategoryIdForSelection(
      _selectedServiceCategory,
      _selectedServiceSubCategory,
    );
    final providers = _serviceRemoteProviders
        .where((item) {
          if (selectedCategoryId != null &&
              item.backendCategoryId != selectedCategoryId) {
            return false;
          }
          if (selectedSubcategoryId != null &&
              item.backendSubcategoryId != selectedSubcategoryId) {
            return false;
          }
          return true;
        })
        .where((item) => _matchesServiceSearch(item, normalizedQuery))
        .toList(growable: true);
    providers.sort((left, right) {
      final availabilityCompare = _serviceAvailabilityRank(
        left,
      ).compareTo(_serviceAvailabilityRank(right));
      if (availabilityCompare != 0) {
        return availabilityCompare;
      }
      switch (_selectedServiceSort.trim().toUpperCase()) {
        case 'PRICE HIGH-LOW':
          final priceCompare = _servicePriceSortValue(
            right,
          ).compareTo(_servicePriceSortValue(left));
          if (priceCompare != 0) {
            return priceCompare;
          }
          final ratingCompare = _serviceRatingRank(
            right,
          ).compareTo(_serviceRatingRank(left));
          if (ratingCompare != 0) {
            return ratingCompare;
          }
          break;
        case 'PRICE LOW-HIGH':
          final priceCompare = _servicePriceSortValue(
            left,
          ).compareTo(_servicePriceSortValue(right));
          if (priceCompare != 0) {
            return priceCompare;
          }
          final ratingCompare = _serviceRatingRank(
            right,
          ).compareTo(_serviceRatingRank(left));
          if (ratingCompare != 0) {
            return ratingCompare;
          }
          break;
        case 'BEST SERVICE':
        default:
          final promotedCompare = _servicePromotedRank(
            left,
          ).compareTo(_servicePromotedRank(right));
          if (promotedCompare != 0) {
            return promotedCompare;
          }
          final ratingCompare = _serviceRatingRank(
            right,
          ).compareTo(_serviceRatingRank(left));
          if (ratingCompare != 0) {
            return ratingCompare;
          }
          break;
      }
      final bookingsCompare = (right.completedJobsCount ?? 0).compareTo(
        left.completedJobsCount ?? 0,
      );
      if (bookingsCompare != 0) {
        return bookingsCompare;
      }
      return left.subtitle.toLowerCase().compareTo(
        right.subtitle.toLowerCase(),
      );
    });
    return providers;
  }

  bool get _showServiceActionControls =>
      _serviceRemoteReady &&
      !_serviceRemoteLoading &&
      _serviceRemoteError == null &&
      _filteredServiceProviders.isNotEmpty;

  int _serviceAvailabilityRank(_DiscoveryItem item) {
    if (!item.isDisabled) {
      return 0;
    }
    final label = item.disabledLabel.trim().toUpperCase();
    if (label == 'BOOKED') {
      return 1;
    }
    return 2;
  }

  int _servicePromotedRank(_DiscoveryItem item) => item.promoted ? -1 : 0;

  double _serviceRatingRank(_DiscoveryItem item) {
    return double.tryParse(item.rating.trim()) ?? 0;
  }

  bool get _showShopAllLanding =>
      _shopBrowseMode == _ShopBrowseMode.itemWise &&
      _selectedShopCategory == 'All Deals' &&
      _selectedShopSubCategory == 'All';

  bool get _showShopRestaurantLanding => _selectedShopCategory == 'Restaurant';
  bool get _showShopFashionLanding => _selectedShopCategory == 'Fashion';
  bool get _showShopFootwearLanding => _selectedShopCategory == 'Footwear';

  List<_RestaurantCuisineItem> get _effectiveRestaurantCuisines =>
      _restaurantRemoteCuisines;

  List<_RestaurantListingItem> get _effectiveRestaurantListings {
    return _restaurantRemoteShops
        .map(
          (shop) => _RestaurantListingItem(
            item: _DiscoveryItem(
              title: shop.shopName,
              subtitle: shop.city.isEmpty ? 'Restaurant' : shop.city,
              accent: const Color(0xFFF28B3C),
              icon: Icons.storefront_rounded,
              rating: shop.rating,
              distance: shop.city,
              shopCategory: 'Restaurant',
              backendShopId: shop.shopId,
              isDisabled: !shop.acceptsOrders || shop.eta == 'Closed',
              disabledLabel: (!shop.acceptsOrders || shop.eta == 'Closed')
                  ? 'Closed'
                  : '',
            ),
            offer: shop.offer,
            eta: shop.eta,
            location: shop.city,
            cuisineLine: shop.cuisineLine,
          ),
        )
        .toList(growable: false);
  }

  List<_DiscoveryItem> get _effectiveFashionShopCards {
    if (!_fashionRemoteReady || _fashionRemoteShops.isEmpty) {
      return const <_DiscoveryItem>[];
    }
    return _fashionRemoteShops
        .map(
          (shop) => _DiscoveryItem(
            title: shop.city.isEmpty ? 'Fashion' : shop.city,
            subtitle: shop.shopName,
            accent: const Color(0xFFCB6E5B),
            icon: Icons.checkroom_rounded,
            rating: shop.rating,
            distance: shop.openNow
                ? (shop.closingSoon
                      ? 'Closing soon'
                      : (shop.closesAt.isEmpty
                            ? 'Open now'
                            : 'Closes ${shop.closesAt}'))
                : 'Closed',
            extra: 'Fashion shop',
            shopCategory: 'Fashion',
            backendShopId: shop.shopId,
            isDisabled: !shop.openNow || !shop.acceptsOrders,
            disabledLabel: (!shop.openNow || !shop.acceptsOrders)
                ? 'Closed'
                : '',
          ),
        )
        .toList(growable: false);
  }

  List<_DiscoveryItem> get _effectiveFootwearShopCards {
    if (!_footwearRemoteReady || _footwearRemoteShops.isEmpty) {
      return const <_DiscoveryItem>[];
    }
    return _footwearRemoteShops
        .map(
          (shop) => _DiscoveryItem(
            title: shop.city.isEmpty ? 'Footwear' : shop.city,
            subtitle: shop.shopName,
            accent: const Color(0xFF5C8FD8),
            icon: Icons.hiking_rounded,
            rating: shop.rating,
            distance: shop.openNow
                ? (shop.closingSoon
                      ? 'Closing soon'
                      : (shop.closesAt.isEmpty
                            ? 'Open now'
                            : 'Closes ${shop.closesAt}'))
                : 'Closed',
            extra: 'Footwear shop',
            shopCategory: 'Footwear',
            backendShopId: shop.shopId,
            isDisabled: !shop.openNow || !shop.acceptsOrders,
            disabledLabel: (!shop.openNow || !shop.acceptsOrders)
                ? 'Closed'
                : '',
          ),
        )
        .toList(growable: false);
  }

  List<_DiscoveryItem> get _effectiveGiftShopCards => _giftRemoteShops
      .map(
        (shop) => _DiscoveryItem(
          title: shop.shopName,
          subtitle: shop.city.isEmpty ? 'Gift store' : shop.city,
          accent: const Color(0xFFB76AA3),
          icon: Icons.redeem_rounded,
          rating: shop.rating,
          distance: shop.openNow ? 'Open now' : 'Closed',
          shopCategory: 'Gift',
          backendShopId: shop.shopId,
          isDisabled: !shop.openNow || !shop.acceptsOrders,
          disabledLabel: (!shop.openNow || !shop.acceptsOrders) ? 'Closed' : '',
        ),
      )
      .toList(growable: false);

  List<_DiscoveryItem> get _effectiveGroceryShopCards => _groceryRemoteShops
      .map(
        (shop) => _DiscoveryItem(
          title: shop.shopName,
          subtitle: shop.city.isEmpty ? 'Grocery shop' : shop.city,
          accent: const Color(0xFF2E8E45),
          icon: Icons.local_grocery_store_rounded,
          rating: shop.rating,
          distance: shop.openNow ? 'Open now' : 'Closed',
          shopCategory: 'Groceries',
          backendShopId: shop.shopId,
          isDisabled: !shop.openNow || !shop.acceptsOrders,
          disabledLabel: (!shop.openNow || !shop.acceptsOrders) ? 'Closed' : '',
        ),
      )
      .toList(growable: false);

  List<_DiscoveryItem> get _effectivePharmacyShopCards => _pharmacyRemoteShops
      .map(
        (shop) => _DiscoveryItem(
          title: shop.shopName,
          subtitle: shop.city.isEmpty ? 'Pharmacy store' : shop.city,
          accent: const Color(0xFF268B9C),
          icon: Icons.local_pharmacy_rounded,
          rating: shop.rating,
          distance: shop.openNow ? 'Open now' : 'Closed',
          shopCategory: 'Pharmacy',
          backendShopId: shop.shopId,
          isDisabled: !shop.openNow || !shop.acceptsOrders,
          disabledLabel: (!shop.openNow || !shop.acceptsOrders) ? 'Closed' : '',
        ),
      )
      .toList(growable: false);

  List<String> get _selectedShopSubcategories =>
      _selectedShopCategory == 'Fashion' && _fashionRemoteCategories.isNotEmpty
      ? _fashionRemoteCategories
            .map((item) => item.label)
            .toList(growable: false)
      : _selectedShopCategory == 'Footwear' &&
            _footwearRemoteCategories.isNotEmpty
      ? _footwearRemoteCategories
            .map((item) => item.label)
            .toList(growable: false)
      : _selectedShopCategory == 'Gift' && _giftRemoteCategories.isNotEmpty
      ? _giftRemoteCategories.map((item) => item.label).toList(growable: false)
      : _selectedShopCategory == 'Groceries' &&
            _groceryRemoteCategories.isNotEmpty
      ? _groceryRemoteCategories
            .map((item) => item.label)
            .toList(growable: false)
      : _selectedShopCategory == 'Pharmacy' &&
            _pharmacyRemoteCategories.isNotEmpty
      ? _pharmacyRemoteCategories
            .map((item) => item.label)
            .toList(growable: false)
      : const <String>['All'];

  double get _curveForegroundBaseHeight =>
      _mode == _HomeMode.shop &&
          _shopBrowseMode == _ShopBrowseMode.itemWise &&
          _selectedShopSubcategories.length > 1
      ? 116
      : _mode == _HomeMode.labour
      ? 102
      : _mode == _HomeMode.service && _serviceSubcategoryStripOptions.isNotEmpty
      ? 102
      : _mode == _HomeMode.service
      ? 50
      : 76;

  double get _curveForegroundLift =>
      _mode == _HomeMode.labour || _mode == _HomeMode.service
      ? _curveForegroundBaseHeight * 0.2
      : 0;

  double get _curveForegroundHeight =>
      _curveForegroundBaseHeight - _curveForegroundLift;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    const pinnedSearchHeaderHeight = 58.0;
    const pinnedModeHeaderHeight = 44.0;
    const pinnedFilterHeaderHeight = 58.0;
    const locationHeaderHeight = 86.0;
    final refreshEdgeOffset =
        locationHeaderHeight +
        pinnedSearchHeaderHeight +
        pinnedModeHeaderHeight +
        (_mode != _HomeMode.all && _modeFilters.isNotEmpty
            ? pinnedFilterHeaderHeight
            : 0.0);

    _ensureShopSelectionIsVisible();
    final showActiveBookingPopup =
        _activeBookingStatus != null &&
        !_ActiveBookingPopupVisibilityController.isHidden;

    return Scaffold(
      backgroundColor: Colors.white,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
          systemStatusBarContrastEnforced: false,
        ),
        child: Stack(
          children: [
            Column(
              children: [
                Container(
                  height: topInset,
                  color: _headerGradient(_mode).first,
                ),
                Expanded(
                  child: RefreshIndicator.adaptive(
                    onRefresh: _refreshVisiblePage,
                    color: const Color(0xFFCB6E5B),
                    edgeOffset: refreshEdgeOffset,
                    displacement: refreshEdgeOffset + 28,
                    child: SafeArea(
                      top: false,
                      bottom: false,
                      child: Container(
                        color: Colors.white,
                        child: CustomScrollView(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          slivers: [
                            SliverToBoxAdapter(
                              child: Container(
                                color: _headerGradient(_mode).first,
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(18, 2, 18, 6),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _HomeHeader(
                                        title:
                                            _selectedLocationChoice?.title ??
                                            'Choose location',
                                        subtitle:
                                            _selectedLocationChoice?.subtitle ??
                                            _homeLocationError ??
                                            (_isAuthenticated
                                                ? 'Allow location to see nearby shops'
                                                : 'Choose your current area to see nearby shops'),
                                        onTap: _openHomeLocationSelector,
                                        loading: _homeLocationLoading,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SliverPersistentHeader(
                              pinned: true,
                              delegate: _PinnedHeaderDelegate(
                                minHeight: pinnedSearchHeaderHeight,
                                maxHeight: pinnedSearchHeaderHeight,
                                child: Container(
                                  color: _headerGradient(_mode).first,
                                  padding: const EdgeInsets.fromLTRB(
                                    18,
                                    4,
                                    18,
                                    6,
                                  ),
                                  child: _PinnedSearchHeader(
                                    controller: _searchController,
                                    hint: _searchHint,
                                    tint: _modeTint(_mode),
                                    onNotificationTap: _openNotificationsPage,
                                    onProfileTap: _openProfilePage,
                                    onCartTap: _openCartPage,
                                    unreadNotificationCount:
                                        _notificationUnreadCount,
                                    profilePhotoDataUri:
                                        _headerProfilePhotoDataUri,
                                    profilePhotoUrl:
                                        _UserAppApi.profilePhotoViewUrl(
                                          _headerProfilePhotoObjectKey,
                                        ),
                                  ),
                                ),
                              ),
                            ),
                            SliverPersistentHeader(
                              pinned: true,
                              delegate: _PinnedHeaderDelegate(
                                minHeight: pinnedModeHeaderHeight,
                                maxHeight: pinnedModeHeaderHeight,
                                child: Container(
                                  color: _headerGradient(_mode).first,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 2),
                                      _ModeSwitcher(
                                        mode: _mode,
                                        onModeSelected: (mode) {
                                          setState(() {
                                            if (mode == _HomeMode.labour &&
                                                _mode != mode &&
                                                _labourRemoteCategories
                                                    .isNotEmpty) {
                                              _selectedLabourCategory =
                                                  _labourRemoteCategories
                                                      .first
                                                      .label;
                                            }
                                            _mode = mode;
                                          });
                                          if (mode == _HomeMode.labour) {
                                            unawaited(
                                              _loadLabourLanding(silent: false),
                                            );
                                          } else if (mode ==
                                              _HomeMode.service) {
                                            unawaited(
                                              _loadServiceLanding(
                                                silent: false,
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            if (_mode != _HomeMode.all &&
                                _modeFilters.isNotEmpty)
                              SliverPersistentHeader(
                                pinned: true,
                                delegate: _PinnedHeaderDelegate(
                                  minHeight: pinnedFilterHeaderHeight,
                                  maxHeight: pinnedFilterHeaderHeight,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          _headerGradient(_mode).first,
                                          _headerGradient(_mode)[1],
                                          _headerGradient(_mode)[2],
                                          _headerGradient(_mode)[2],
                                        ],
                                        stops: const [0, 0.44, 0.86, 1],
                                      ),
                                    ),
                                    child: Transform.translate(
                                      offset: const Offset(0, 5),
                                      child: Align(
                                        alignment: Alignment.topLeft,
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                            18,
                                            0,
                                            18,
                                            10,
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 5,
                                              vertical: 3,
                                            ),
                                            child: _ModeFilterRow(
                                              filters: _modeFilters,
                                              selected: _selectedFilter,
                                              selectedTextColor: Colors.white,
                                              disabledFilters: const <String>{},
                                              onSelected: _handleFilterSelect,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            SliverToBoxAdapter(
                              child: _CurvedBodyTransition(
                                colors: _headerGradient(_mode),
                                compact: _mode == _HomeMode.all,
                                foreground: _buildCurveForeground(),
                                foregroundHeight: _curveForegroundHeight,
                              ),
                            ),
                            ..._buildModeSlivers(includeTopControls: false),
                            const SliverToBoxAdapter(
                              child: ColoredBox(
                                color: Colors.white,
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(18, 28, 18, 96),
                                  child: _MadeWithLoveFooter(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (showActiveBookingPopup) _buildActiveBookingFloatingCard(),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (_showScrollToTop)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: FloatingActionButton.small(
                heroTag: 'scrollToTop',
                onPressed: () {
                  _scrollController.animateTo(
                    0,
                    duration: const Duration(milliseconds: 420),
                    curve: Curves.easeOutCubic,
                  );
                },
                backgroundColor: const Color(0xFF22314D),
                foregroundColor: Colors.white,
                child: const Icon(Icons.keyboard_arrow_up_rounded),
              ),
            ),
          if (_cartItems.isNotEmpty)
            FloatingActionButton(
              heroTag: 'cartFloat',
              onPressed: _openCartPage,
              backgroundColor: const Color(0xFFCB6E5B),
              foregroundColor: Colors.white,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.shopping_cart_checkout_rounded),
                  Positioned(
                    right: -8,
                    top: -8,
                    child: Container(
                      height: 22,
                      constraints: const BoxConstraints(minWidth: 22),
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF18213A),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Center(
                        child: Text(
                          '${_cartItems.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActiveBookingFloatingCard() {
    final status = _activeBookingStatus!;
    final liveBookingCount = _activeBookingStatuses.length;
    final title = liveBookingCount > 1
        ? '$liveBookingCount live bookings'
        : (status.providerName.trim().isNotEmpty
              ? status.providerName
              : status.bookingType.toUpperCase() == 'SERVICE'
              ? 'Service booking'
              : 'Labour booking');
    final subtitle = liveBookingCount > 1
        ? '${status.providerName.trim().isNotEmpty ? status.providerName : _activeBookingProviderTitle(status)} • ${_liveBookingStatusLabel(status)}'
        : _liveBookingStatusLabel(status);
    final screenSize = MediaQuery.sizeOf(context);
    final width = math.min(screenSize.width * 0.84, 360.0);
    const cardHeight = 108.0;
    final topInset = MediaQuery.paddingOf(context).top;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final minLeft = 12.0;
    final maxLeft = math.max(minLeft, screenSize.width - width - 12);
    final minTop = topInset + 12;
    final defaultTop = math.max(
      minTop,
      screenSize.height - bottomInset - cardHeight - 112,
    );
    final maxTop = math.max(
      minTop,
      screenSize.height - bottomInset - cardHeight - 12,
    );
    final boundedLeft =
        (_activeBookingPopupPositionInitialized
                ? _activeBookingPopupOffset.dx
                : maxLeft)
            .clamp(minLeft, maxLeft)
            .toDouble();
    final boundedTop =
        (_activeBookingPopupPositionInitialized
                ? _activeBookingPopupOffset.dy
                : defaultTop)
            .clamp(minTop, maxTop)
            .toDouble();

    return Positioned(
      left: boundedLeft,
      top: boundedTop,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          if (_activeBookingPopupDragMoved) {
            return;
          }
          _openActiveBookingsOverviewSheet();
        },
        onPanStart: (_) {
          _activeBookingPopupDragMoved = false;
        },
        onPanUpdate: (details) {
          _activeBookingPopupDragMoved = true;
          setState(() {
            final currentLeft = _activeBookingPopupPositionInitialized
                ? _activeBookingPopupOffset.dx
                : boundedLeft;
            final currentTop = _activeBookingPopupPositionInitialized
                ? _activeBookingPopupOffset.dy
                : boundedTop;
            _activeBookingPopupOffset = Offset(
              (currentLeft +
                      (details.delta.dx *
                          _activeBookingPopupDragSpeedMultiplier))
                  .clamp(minLeft, maxLeft)
                  .toDouble(),
              (currentTop +
                      (details.delta.dy *
                          _activeBookingPopupDragSpeedMultiplier))
                  .clamp(minTop, maxTop)
                  .toDouble(),
            );
            _activeBookingPopupPositionInitialized = true;
          });
        },
        onPanEnd: (_) {
          Future<void>.delayed(const Duration(milliseconds: 80), () {
            _activeBookingPopupDragMoved = false;
          });
        },
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: width,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFCB6E5B), Color(0xFFB85F4F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0x33CB6E5B),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            _ActiveBookingAvatar(status: status, size: 42),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 13.2,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    subtitle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.88,
                                      ),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 10.6,
                                      height: 1.1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(999),
                        onTap: () {
                          if (_activeBookingPopupDragMoved) {
                            return;
                          }
                          _dismissActiveBookingPopupTemporarily();
                        },
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(999),
                        onTap: () {
                          if (_activeBookingPopupDragMoved) {
                            return;
                          }
                          _openActiveBookingsOverviewSheet();
                        },
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String get _selectedFilter {
    switch (_mode) {
      case _HomeMode.all:
        return 'ALL';
      case _HomeMode.labour:
        if (_labourRemoteCategories.isNotEmpty) {
          return _selectedLabourCategory;
        }
        return switch (_selectedLabourCategory) {
          'Helper' => 'Helpers',
          'Loader' => 'Loaders',
          'Cleaner' => 'Cleaners',
          'Driver' => 'Drivers',
          _ => _selectedLabourCategory,
        };
      case _HomeMode.service:
        return _modeFilters.contains(_selectedServiceCategory)
            ? _selectedServiceCategory
            : (_modeFilters.isEmpty
                  ? _selectedServiceCategory
                  : _modeFilters.first);
      case _HomeMode.shop:
        return _modeFilters.contains(_selectedShopCategory)
            ? _selectedShopCategory
            : (_modeFilters.isEmpty
                  ? _selectedShopCategory
                  : _modeFilters.first);
    }
  }

  void _handleFilterSelect(String value) {
    setState(() {
      switch (_mode) {
        case _HomeMode.all:
          break;
        case _HomeMode.labour:
          _selectedLabourCategory = _labourRemoteCategories.isNotEmpty
              ? value
              : switch (value) {
                  'Helpers' => 'Helper',
                  'Loaders' => 'Loader',
                  'Cleaners' => 'Cleaner',
                  'Drivers' => 'Driver',
                  _ => value,
                };
        case _HomeMode.service:
          _selectedServiceCategory = value;
          _selectedServiceSubCategory = _defaultServiceSubcategoryLabelFor(
            value,
          );
          _selectedServiceSubCategory = 'All';
        case _HomeMode.shop:
          _selectedShopCategory = value;
          _selectedShopSubCategory = 'All';
          _selectedRestaurantCuisine = 'All';
          _fashionVisibleProductCount = _fashionProductBatchSize;
          _footwearVisibleProductCount = _footwearProductBatchSize;
          if (value == 'Restaurant') {
            _shopBrowseMode = _ShopBrowseMode.itemWise;
          }
      }
    });
    if (_mode == _HomeMode.labour) {
      unawaited(_loadLabourLanding(silent: false));
    } else if (_mode == _HomeMode.service) {
      unawaited(_loadServiceLanding(silent: false));
    }
    if (_mode == _HomeMode.shop) {
      if (value == 'Restaurant') {
        unawaited(_loadRestaurantLanding(silent: false));
      } else if (value == 'Fashion') {
        unawaited(_loadFashionLanding(silent: false));
      } else if (value == 'Footwear') {
        unawaited(_loadFootwearLanding(silent: false));
      } else if (value == 'Gift') {
        unawaited(_loadGiftLanding(silent: false));
      } else if (value == 'Groceries') {
        unawaited(_loadGroceryLanding(silent: false));
      } else if (value == 'Pharmacy') {
        unawaited(_loadPharmacyLanding(silent: false));
      }
    }
  }

  List<_ActiveBookingStatus> _filterVisibleActiveBookings(
    List<_ActiveBookingStatus> statuses,
  ) {
    return statuses
        .where((status) {
          final requestStatus = status.requestStatus.trim().toUpperCase();
          return !(requestStatus == 'OPEN' &&
              !status.canMakePayment &&
              status.bookingId <= 0);
        })
        .toList(growable: false);
  }

  Future<List<_ActiveBookingStatus>> _loadActiveBookingStatusesSafe() async {
    if (!_isAuthenticated) {
      return const <_ActiveBookingStatus>[];
    }
    try {
      return _filterVisibleActiveBookings(
        await _UserAppApi.fetchActiveBookingStatuses(),
      );
    } catch (_) {
      return _activeBookingStatuses;
    }
  }

  Future<void> _openActiveBookingSheet(_ActiveBookingStatus status) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ActiveBookingDetailsSheet(
        initialStatus: status,
        onPayNow: (latestStatus) async {
          Navigator.of(context).pop();
          await _handleActiveBookingPayment(latestStatus);
        },
        onStatusChanged: (latestStatus) {
          if (!mounted) {
            return;
          }
          setState(() {
            _upsertActiveBookingStatus(latestStatus);
          });
        },
        onOpenProviderProfile: _openActiveBookingProviderProfile,
      ),
    );
    if (!mounted) {
      return;
    }
    await _hydrateRemoteState(silent: true);
    if (!mounted) {
      return;
    }
    switch (status.bookingType.trim().toUpperCase()) {
      case 'LABOUR':
        await _loadLabourLanding(silent: true);
        break;
      case 'SERVICE':
        await _loadServiceLanding(silent: true);
        break;
    }
  }

  String _activeBookingProviderTitle(_ActiveBookingStatus status) {
    final name = status.providerName.trim();
    if (name.isNotEmpty) {
      return name;
    }
    return status.bookingType.toUpperCase() == 'SERVICE'
        ? 'Service provider'
        : 'Labour';
  }

  String _activeBookingPaymentStatusLabel(_ActiveBookingStatus status) {
    final normalized = status.paymentStatus.trim().toUpperCase();
    return switch (normalized) {
      '' => 'Unpaid',
      'UNPAID' => 'Unpaid',
      'PENDING' => 'Pending',
      'INITIATED' => 'Pending',
      'PAID' => 'Paid',
      'FAILED' => 'Failed',
      'REFUNDED' => 'Refunded',
      _ => _titleCase(status.paymentStatus),
    };
  }

  Future<void> _openActiveBookingProviderProfile(
    _ActiveBookingStatus status,
  ) async {
    final providerId = status.providerEntityId;
    if (providerId == null || providerId <= 0) {
      return;
    }
    final normalizedProviderType = status.providerEntityType
        .trim()
        .toUpperCase();
    final isService =
        normalizedProviderType == 'SERVICE_PROVIDER' ||
        status.bookingType.trim().toUpperCase() == 'SERVICE';
    final detailItem = _DiscoveryItem(
      title: status.providerName.trim().isNotEmpty
          ? status.providerName.trim()
          : (isService ? 'Service provider' : 'Labour'),
      subtitle: status.categoryLabel.trim().isNotEmpty
          ? status.categoryLabel.trim()
          : (isService ? 'Service' : 'Labour'),
      accent: isService ? const Color(0xFFD48E78) : const Color(0xFF5C8FD8),
      icon: isService
          ? Icons.miscellaneous_services_rounded
          : Icons.handyman_rounded,
      price: status.totalAcceptedQuotedPriceAmount.trim().isNotEmpty
          ? status.totalAcceptedQuotedPriceAmount.trim()
          : status.quotedPriceAmount.trim(),
      rating: '',
      distance: status.distanceLabel.trim().isEmpty
          ? 'Nearby'
          : status.distanceLabel.trim(),
      maskedPhone: status.providerPhone.trim(),
      backendLabourId: isService ? null : providerId,
      backendServiceProviderId: isService ? providerId : null,
      profileImageUrl: status.providerPhotoUrl.trim(),
      serviceItems: status.subcategoryLabel.trim().isEmpty
          ? const <String>[]
          : <String>[status.subcategoryLabel.trim()],
      serviceTileLabel: status.subcategoryLabel.trim(),
    );
    await _openCard(
      detailItem,
      isService ? _HomeMode.service : _HomeMode.labour,
    );
  }

  Future<void> _openActiveBookingsOverviewSheet() async {
    final statuses = List<_ActiveBookingStatus>.from(_activeBookingStatuses);
    final navigator = Navigator.of(context, rootNavigator: true);
    await navigator.push(
      MaterialPageRoute<void>(
        builder: (_) => _ActiveBookingsOverviewPage(
          statuses: statuses,
          statusLabelBuilder: _liveBookingStatusLabel,
          paymentLabelBuilder: _activeBookingPaymentStatusLabel,
          titleBuilder: _activeBookingProviderTitle,
          onOpenDetails: (activeStatus) =>
              _openActiveBookingSheet(activeStatus),
        ),
      ),
    );
  }

  String _liveBookingStatusLabel(_ActiveBookingStatus status) {
    if (status.canMakePayment) {
      return 'Accepted. Pay booking charges.';
    }
    final bookingStatus = status.bookingStatus.trim().toUpperCase();
    switch (bookingStatus) {
      case 'PAYMENT_PENDING':
        return 'Payment is pending. Please wait up to 5 minutes for confirmation.';
      case 'PAYMENT_COMPLETED':
        return 'Payment done. Start work OTP is ready when the provider reaches you.';
      case 'ARRIVED':
        return 'Provider arrived. Enter OTP to start.';
      case 'IN_PROGRESS':
        return 'Work in progress.';
      case 'COMPLETED':
        return 'Booking completed.';
    }
    if (bookingStatus.isNotEmpty) {
      return _titleCase(bookingStatus);
    }
    switch (status.requestStatus.trim().toUpperCase()) {
      case 'OPEN':
        return 'Waiting for provider acceptance';
      case 'REJECTED':
        return 'Provider rejected the request';
      case 'EXPIRED':
        return 'Booking request expired';
      case 'CANCELLED':
        return 'Booking request cancelled';
      default:
        return _titleCase(status.requestStatus);
    }
  }

  Future<void> _handleActiveBookingPayment(_ActiveBookingStatus status) async {
    if (!status.canMakePayment) {
      return;
    }
    try {
      if (status.bookingType.toUpperCase() == 'SERVICE') {
        final invoiceResult = await _showActiveServiceInvoiceDialog(
          status: status,
        );
        if (!mounted || invoiceResult == null) {
          return;
        }
        final payment = invoiceResult.payment;
        final paymentResult = invoiceResult.paymentFlowResult;
        if (!mounted) {
          return;
        }
        await _hydrateRemoteState(silent: true);
        if (!mounted) {
          return;
        }
        await _PaymentFlow.showOutcome(
          context,
          result: paymentResult,
          successTitle: 'Service booking confirmed',
          failureTitle: 'Service payment incomplete',
          extraLines: [
            'Booking code: ${payment.bookingCode}',
            if (status.providerName.trim().isNotEmpty)
              'Provider: ${status.providerName}',
            'Amount: ${payment.amountLabel}',
          ],
        );
        return;
      }
      final invoiceResult = await _showActiveLabourInvoiceDialog(
        status: status,
      );
      if (!mounted || invoiceResult == null) {
        return;
      }
      final payment = invoiceResult.payment;
      final paymentResult = invoiceResult.paymentFlowResult;
      if (!mounted) {
        return;
      }
      await _hydrateRemoteState(silent: true);
      if (!mounted) {
        return;
      }
      await _PaymentFlow.showOutcome(
        context,
        result: paymentResult,
        successTitle: 'Labour booking confirmed',
        failureTitle: 'Labour payment incomplete',
        extraLines: [
          'Booking code: ${payment.bookingCode}',
          if (status.providerName.trim().isNotEmpty)
            'Labour: ${status.providerName}',
          'Amount: ${payment.amountLabel}',
        ],
      );
    } on _UserAppApiException catch (error) {
      if (mounted) {
        _showCartSnack(error.message);
      }
    }
  }

  Widget? _buildCurveForeground() {
    switch (_mode) {
      case _HomeMode.all:
        return null;
      case _HomeMode.labour:
        return Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
          child: SizedBox(
            height: _curveForegroundBaseHeight,
            child: Align(
              alignment: Alignment.topCenter,
              child: Row(
                children: [
                  Expanded(
                    child: _LabourModeCard(
                      label: 'Single booking',
                      icon: Icons.engineering_rounded,
                      selected: _labourViewMode == _LabourViewMode.individual,
                      onTap: () => setState(
                        () => _labourViewMode = _LabourViewMode.individual,
                      ),
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: _LabourModeCard(
                      label: 'Group booking',
                      icon: Icons.groups_2_rounded,
                      selected: _labourViewMode == _LabourViewMode.group,
                      onTap: () => setState(
                        () => _labourViewMode = _LabourViewMode.group,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      case _HomeMode.service:
        final showSubcategoryFilter =
            _serviceSubcategoryStripOptions.isNotEmpty;
        final showActionControls = _showServiceActionControls;
        if (!showSubcategoryFilter && !showActionControls) {
          return null;
        }
        return Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
          child: SizedBox(
            height: _curveForegroundBaseHeight,
            child: showSubcategoryFilter
                ? Stack(
                    children: [
                      Positioned(
                        left: 0,
                        right: 0,
                        top: 0,
                        child: _ServiceSubcategoryFilter(
                          selectedCategory:
                              _serviceSubcategoryStripCategoryLabel,
                          options: _serviceSubcategoryStripOptions,
                          selected: _selectedServiceSubCategory,
                          onSelected: _handleServiceSubcategorySelect,
                        ),
                      ),
                      if (showActionControls)
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: _buildServiceSortAndActionControls(),
                        ),
                    ],
                  )
                : Align(
                    alignment: Alignment.topCenter,
                    child: _buildServiceSortAndActionControls(),
                  ),
          ),
        );
      case _HomeMode.shop:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!_showShopRestaurantLanding)
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
                child: _ShopBrowseToggle(
                  selected: _shopBrowseMode,
                  onSelected: (value) => setState(() {
                    _shopBrowseMode = value;
                    _fashionVisibleProductCount = _fashionProductBatchSize;
                    _footwearVisibleProductCount = _footwearProductBatchSize;
                  }),
                  sortByPrice: _shopSortOption != 'Popular',
                  onSortByPrice: _openShopSortSheet,
                  onFilterTap: _openShopFilterPage,
                ),
              ),
            if (_shopBrowseMode == _ShopBrowseMode.itemWise &&
                _selectedShopSubcategories.length > 1)
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 2, 18, 0),
                child: _ShopSubcategoryFilter(
                  category: _selectedShopCategory,
                  options: _selectedShopSubcategories,
                  selected: _selectedShopSubCategory,
                  onSelected: (value) {
                    if (_selectedShopCategory == 'Fashion') {
                      unawaited(
                        _selectFashionSubcategory(value, silent: false),
                      );
                      return;
                    }
                    if (_selectedShopCategory == 'Footwear') {
                      unawaited(
                        _selectFootwearSubcategory(value, silent: false),
                      );
                      return;
                    }
                    if (_selectedShopCategory == 'Gift') {
                      unawaited(_selectGiftSubcategory(value, silent: false));
                      return;
                    }
                    if (_selectedShopCategory == 'Groceries') {
                      unawaited(
                        _selectGrocerySubcategory(value, silent: false),
                      );
                      return;
                    }
                    if (_selectedShopCategory == 'Pharmacy') {
                      unawaited(
                        _selectPharmacySubcategory(value, silent: false),
                      );
                      return;
                    }
                    setState(() {
                      _selectedShopSubCategory = value;
                      _fashionVisibleProductCount = _fashionProductBatchSize;
                      _footwearVisibleProductCount = _footwearProductBatchSize;
                    });
                  },
                ),
              ),
          ],
        );
    }
  }

  void _handleServiceSubcategorySelect(String value) {
    setState(() {
      _selectedServiceSubCategory = value;
    });
    if (_serviceRemoteCategories.isNotEmpty) {
      unawaited(_loadServiceLanding(silent: false));
    }
  }

  Widget _buildServiceSortAndActionControls() {
    return Row(
      children: [
        Expanded(
          child: PopupMenuButton<String>(
            initialValue: _selectedServiceSort,
            onSelected: (value) {
              if (_selectedServiceSort == value) {
                return;
              }
              setState(() => _selectedServiceSort = value);
            },
            itemBuilder: (context) => const [
              PopupMenuItem<String>(
                value: 'Price low-high',
                child: Text('Price low-high'),
              ),
              PopupMenuItem<String>(
                value: 'Price high-low',
                child: Text('Price high-low'),
              ),
              PopupMenuItem<String>(
                value: 'Best service',
                child: Text('Best service'),
              ),
            ],
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE7D9D1)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.sort_rounded,
                    size: 18,
                    color: Color(0xFFD48E78),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      _selectedServiceSort,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF5E4B45),
                        fontSize: 12.8,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: Color(0xFF5E4B45),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFE36C93),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            onPressed: _serviceRemoteLoading
                ? null
                : _startRandomServiceBookingFlow,
            icon: const Icon(Icons.shuffle_rounded, size: 18),
            label: const Text(
              'Quick Book',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildModeSlivers({bool includeTopControls = true}) {
    switch (_mode) {
      case _HomeMode.all:
        return _buildAllMode();
      case _HomeMode.labour:
        return _buildLabourMode(includeTopControls: includeTopControls);
      case _HomeMode.service:
        return _buildServiceMode(includeTopControls: includeTopControls);
      case _HomeMode.shop:
        return _buildShopMode(includeTopControls: includeTopControls);
    }
  }

  List<Widget> _buildAllMode() {
    final nearbyShopProfiles = <_DiscoveryItem>[
      ..._effectiveFashionShopCards,
      ..._effectiveFootwearShopCards,
      ..._effectiveGiftShopCards,
      ..._effectiveGroceryShopCards,
      ..._effectivePharmacyShopCards,
    ];
    final hasAnyLiveSection =
        _backendTopProducts.isNotEmpty ||
        _labourRemoteProfiles.isNotEmpty ||
        _serviceRemoteProviders.isNotEmpty ||
        _restaurantRemoteProducts.isNotEmpty ||
        _effectiveRestaurantListings.isNotEmpty ||
        nearbyShopProfiles.isNotEmpty;
    final slivers = <Widget>[];

    if (_anyHomeRemoteLoading &&
        _backendTopProducts.isEmpty &&
        !hasAnyLiveSection) {
      slivers.add(
        _buildRemoteStateSliver(
          icon: Icons.storefront_rounded,
          title: 'Loading nearby options',
          message:
              'We are checking live shops, labour, and services around your selected location.',
          loading: true,
        ),
      );
    }

    if (_backendTopProducts.isNotEmpty) {
      slivers.add(
        SliverToBoxAdapter(
          child: _HorizontalDiscoverySection(
            title: 'Nearby shop picks',
            caption: 'Live products available around your selected area',
            items: _backendTopProducts,
            onTap: _openShopItemFromHome,
            isWishlisted: _isWishlisted,
            isFavourited: _isFavourited,
            onWishlistToggle: _toggleWishlist,
            onFavouriteToggle: _toggleFavourite,
            onAddToCart: (item) =>
                _handleShopCartAdd(item, openCartAfterAdd: true),
          ),
        ),
      );
    }

    if (_backendTopProducts.isEmpty && nearbyShopProfiles.isNotEmpty) {
      slivers.add(
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
            child: const Text(
              'Shops nearby',
              style: TextStyle(
                color: Color(0xFF22314D),
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      );
      slivers.add(
        SliverList.builder(
          itemCount: nearbyShopProfiles.length > 4
              ? 4
              : nearbyShopProfiles.length,
          itemBuilder: (context, index) => _VerticalShopCard(
            item: nearbyShopProfiles[index],
            isWishlisted: _isWishlisted(nearbyShopProfiles[index]),
            onWishlistToggle: () => _toggleWishlist(nearbyShopProfiles[index]),
            onTap: () => _openShopProfile(nearbyShopProfiles[index]),
          ),
        ),
      );
    }

    if (_labourRemoteLoading) {
      slivers.add(
        const SliverToBoxAdapter(
          child: _AllLabourLoadingSection(title: 'Labour nearby'),
        ),
      );
    } else if (_labourRemoteProfiles.isNotEmpty) {
      slivers.add(
        SliverToBoxAdapter(
          child: _AllLabourSection(
            title: 'Labour nearby',
            items: _labourRemoteProfiles,
            isFavourited: _isFavourited,
            onFavouriteToggle: _toggleFavourite,
            onTap: (item) => unawaited(_openCard(item, _HomeMode.labour)),
          ),
        ),
      );
    }

    if (_serviceRemoteProviders.isNotEmpty) {
      final spotlightServices = _filteredServiceProviders
          .take(20)
          .toList(growable: false);
      slivers.add(
        SliverToBoxAdapter(
          child: _AllServiceSection(
            title: 'Service nearby',
            items: spotlightServices,
            onTap: (item) => unawaited(_openCard(item, _HomeMode.service)),
          ),
        ),
      );
    }

    if (_restaurantRemoteProducts.isNotEmpty) {
      slivers.add(
        SliverToBoxAdapter(
          child: _ShopSingleRowSection(
            title: 'Top food',
            items: _restaurantRemoteProducts,
            onTap: _openShopProfile,
            isWishlisted: _isWishlisted,
            isFavourited: _isFavourited,
            onWishlistToggle: _toggleWishlist,
            onFavouriteToggle: _toggleFavourite,
            onAddToCart: (item) => _openShopProfile(item, autoAddItem: true),
          ),
        ),
      );
    } else if (_effectiveRestaurantListings.isNotEmpty) {
      slivers.add(
        SliverToBoxAdapter(
          child: _RestaurantRecommendedSection(
            items: _effectiveRestaurantListings.take(6).toList(),
            onTap: (listing) => _openRestaurantListing(listing),
          ),
        ),
      );
    }

    if (_initialDiscoveryBatchResolved &&
        !hasAnyLiveSection &&
        !_anyHomeRemoteLoading) {
      slivers.add(
        _buildAreaComingSoonSliver(
          icon: Icons.location_city_rounded,
          message:
              'No labour, service, or shop is registered within your selected range yet.',
        ),
      );
    }

    return slivers;
  }

  List<Widget> _buildLabourMode({bool includeTopControls = true}) {
    final labourStateSliver = _buildLabourStateSliver();
    final visibleLabourProfiles = _filteredSingleLabourProfiles;
    final selectedGroupCategoryId = _labourCategoryIdForLabel(
      _selectedLabourCategory,
    );
    final groupAvailableLabour = _availableLabourCountForGroupCategory(
      selectedGroupCategoryId,
    );
    return [
      if (includeTopControls)
        SliverToBoxAdapter(child: _buildCurveForeground()),
      if (labourStateSliver != null)
        labourStateSliver
      else if (_labourViewMode == _LabourViewMode.individual) ...[
        SliverToBoxAdapter(
          child: Transform.translate(
            offset: Offset(0, -_curveForegroundLift * 0.35),
            child: _SingleLabourFilterBar(
              selectedPeriod: _selectedSingleLabourPeriod,
              maxPrice: _selectedSingleLabourMaxPrice,
              onPeriodSelected: (value) =>
                  setState(() => _selectedSingleLabourPeriod = value),
              onMaxPriceChanged: (value) =>
                  setState(() => _selectedSingleLabourMaxPrice = value),
              onQuickBook: visibleLabourProfiles.isEmpty || _labourRemoteLoading
                  ? null
                  : _startQuickLabourBookingFlow,
            ),
          ),
        ),
        if (_labourRemoteLoading)
          const _LabourGridLoadingSection()
        else if (visibleLabourProfiles.isEmpty)
          _buildRemoteStateSliver(
            icon: Icons.filter_alt_off_rounded,
            title: 'No labour matched this filter',
            message:
                'Try changing Half Day / Full Day or increasing your price range.',
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 0),
            sliver: SliverGrid.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                mainAxisExtent: 246,
              ),
              itemCount: visibleLabourProfiles.length,
              itemBuilder: (context, index) {
                final item = visibleLabourProfiles[index];
                return _LabourPortraitTile(
                  item: item,
                  isFavourited: _isFavourited(item),
                  onFavouriteToggle: () => _toggleFavourite(item),
                  onTap: () => unawaited(_openCard(item, _mode)),
                  compactScale: 0.62,
                );
              },
            ),
          ),
      ] else
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 6, 18, 0),
            child: _GroupBookingCard(
              availableLabour: groupAvailableLabour,
              selectedLabourType: _selectedLabourCategory.trim().isEmpty
                  ? 'Select category'
                  : _selectedLabourCategory,
              needsLabourTypeSelection: selectedGroupCategoryId == null,
              selectedMaxPrice: _selectedLabourPrice,
              selectedPricePeriod: _selectedLabourPricePeriod,
              selectedCount: _selectedLabourCount,
              maxSelectableCount: _maxGroupLabourCount,
              bookingChargePerLabour: _labourBookingChargePerLabour,
              showPriceError: _showLabourPriceError,
              showCountError: _showLabourCountError,
              countErrorText: _labourCountErrorText,
              onLabourTypeSelected: () {},
              onPriceSelected: (value) => setState(() {
                _selectedLabourPrice = value;
                if (value.trim().isNotEmpty) {
                  _showLabourPriceError = false;
                }
              }),
              onPricePeriodSelected: (value) =>
                  setState(() => _selectedLabourPricePeriod = value),
              onCountSelected: (value) => setState(() {
                _selectedLabourCount = value;
                if (value > 0 && value > groupAvailableLabour) {
                  _showLabourCountError = true;
                  _labourCountErrorText =
                      'Only $groupAvailableLabour labour available';
                } else if (value > 0) {
                  _showLabourCountError = false;
                  _labourCountErrorText = null;
                }
              }),
              onBook: () async {
                if (_selectedLabourPrice.trim().isEmpty) {
                  setState(() {
                    _showLabourPriceError = true;
                  });
                  _showCartSnack(
                    'Enter the maximum budget for each labour first.',
                  );
                  return;
                }
                if (_selectedLabourCount <= 0) {
                  setState(() {
                    _showLabourCountError = true;
                    _labourCountErrorText = 'Select count';
                  });
                  _showCartSnack('Select how many labours you need first.');
                  return;
                }
                if (_selectedLabourCount > groupAvailableLabour) {
                  setState(() {
                    _showLabourCountError = true;
                    _labourCountErrorText =
                        'Only $groupAvailableLabour labour available';
                  });
                  return;
                }
                setState(() {
                  _showLabourPriceError = false;
                  _showLabourCountError = false;
                  _labourCountErrorText = null;
                });
                if (!_isAuthenticated) {
                  final loggedIn = await _ensureAuthenticated();
                  if (!loggedIn) {
                    if (mounted) {
                      _showCartSnack(
                        'Please log in to continue group booking.',
                      );
                    }
                    return;
                  }
                }
                final confirmed = await _confirmBookingLocationUsage(
                  bookingLabel: 'labour',
                );
                if (!mounted || !confirmed) {
                  return;
                }
                final bookingAddressId =
                    await _ensureBookingAddressIdForServiceOrLabour(
                      bookingLabel: 'labour',
                    );
                if (bookingAddressId == null || !mounted) {
                  return;
                }
                final categoryId = _labourCategoryIdForLabel(
                  _selectedLabourCategory,
                );
                if (categoryId == null) {
                  _showCartSnack('Please select a labour category first.');
                  return;
                }
                final selectedTypeAvailableLabour =
                    _availableLabourCountForGroupCategory(categoryId);
                if (_selectedLabourCount > selectedTypeAvailableLabour) {
                  setState(() {
                    _showLabourCountError = true;
                    _labourCountErrorText =
                        'Only $selectedTypeAvailableLabour labour available';
                  });
                  return;
                }
                try {
                  final result = await _UserAppApi.requestGroupLabourBooking(
                    categoryId: categoryId,
                    bookingPeriod: _selectedLabourPricePeriod,
                    maxPrice: _selectedLabourPrice,
                    labourCount: _selectedLabourCount,
                    addressId: bookingAddressId,
                  );
                  if (!mounted) {
                    return;
                  }
                  final request = _RemoteLabourBookingResult(
                    requestId: result.requestId,
                    requestCode: result.requestCode,
                    requestStatus: 'OPEN',
                    quotedPriceAmount: result.platformAmountDue,
                    labourName: 'nearby labour',
                  );
                  final status = await _waitForLabourAcceptance(
                    request,
                    timeoutSeconds: 60,
                    requestedCount: result.requestedCount,
                    isGroupRequest: true,
                    retryRequest: () async {
                      final refreshed =
                          await _UserAppApi.requestGroupLabourBooking(
                            categoryId: categoryId,
                            bookingPeriod: _selectedLabourPricePeriod,
                            maxPrice: _selectedLabourPrice,
                            labourCount: _selectedLabourCount,
                            addressId: bookingAddressId,
                          );
                      return _RemoteLabourBookingResult(
                        requestId: refreshed.requestId,
                        requestCode: refreshed.requestCode,
                        requestStatus: 'OPEN',
                        quotedPriceAmount: refreshed.platformAmountDue,
                        labourName: 'nearby labour',
                      );
                    },
                    candidates: _labourWaitCandidates(
                      _labourRemoteProfiles.where(
                        (item) =>
                            item.backendCategoryId == categoryId ||
                            item.labourCategoryPricing.any(
                              (pricing) => pricing.categoryId == categoryId,
                            ),
                      ),
                      _selectedLabourPricePeriod,
                    ),
                  );
                  if (!mounted) {
                    return;
                  }
                  if (status == null ||
                      !status.canMakePayment ||
                      status.acceptedProviderCount <= 0) {
                    await _showLabourRequestStateDialog(
                      request: request,
                      status: status,
                      isGroupRequest: true,
                      requestedCount: result.requestedCount,
                    );
                    return;
                  }
                  setState(() {
                    _upsertActiveBookingStatus(
                      _activeBookingStatusFromLabourRequest(
                        request: request,
                        status: status,
                      ),
                    );
                  });
                  final invoiceResult = await _showAcceptedLabourInvoiceDialog(
                    request: request,
                    status: status,
                    requestedCount: result.requestedCount,
                    categoryLabel: _selectedLabourCategory,
                    periodLabel: _selectedLabourPricePeriod,
                    isGroupRequest: true,
                  );
                  if (!mounted || invoiceResult == null) {
                    return;
                  }
                  final payment = invoiceResult.payment;
                  final acceptedPayments = math.max(
                    1,
                    status.acceptedProviderCount,
                  );
                  final paymentResult = invoiceResult.paymentFlowResult;
                  if (!mounted) {
                    return;
                  }
                  await _hydrateRemoteState(silent: true);
                  if (!mounted) {
                    return;
                  }
                  await _PaymentFlow.showOutcome(
                    context,
                    result: paymentResult,
                    successTitle: 'Group labour booking confirmed',
                    failureTitle: 'Group labour payment incomplete',
                    extraLines: [
                      'Request code: ${result.requestCode}',
                      'Accepted labour: $acceptedPayments',
                      'Requested labour: ${result.requestedCount}',
                      'Amount: ${payment.amountLabel}',
                    ],
                  );
                } on _UserAppApiException catch (error) {
                  if (mounted) {
                    _showCartSnack(error.message);
                  }
                }
              },
            ),
          ),
        ),
    ];
  }

  List<Widget> _buildServiceMode({bool includeTopControls = true}) {
    final providers = _filteredServiceProviders;
    final serviceStateSliver = _buildServiceStateSliver(
      hasVisibleProviders: providers.isNotEmpty,
    );
    return [
      if (includeTopControls)
        SliverToBoxAdapter(child: _buildCurveForeground()),
      if (serviceStateSliver != null)
        serviceStateSliver
      else
        SliverList.builder(
          itemCount: providers.length,
          itemBuilder: (context, index) => _VerticalProfileCard(
            item: providers[index],
            mode: _mode,
            isFavourited: _isFavourited(providers[index]),
            onFavouriteToggle: () => _toggleFavourite(providers[index]),
            onTap: () => unawaited(_openCard(providers[index], _mode)),
          ),
        ),
    ];
  }

  List<Widget> _buildShopMode({bool includeTopControls = true}) {
    final shopRemoteStateSliver = _buildShopRemoteStateSliver();
    final visibleRestaurantListings = _effectiveRestaurantListings;
    final allNearbyShopProfiles = <_DiscoveryItem>[
      ..._effectiveFashionShopCards,
      ..._effectiveFootwearShopCards,
      ..._effectiveGiftShopCards,
      ..._effectiveGroceryShopCards,
      ..._effectivePharmacyShopCards,
    ];
    return [
      if (includeTopControls)
        SliverToBoxAdapter(child: _buildCurveForeground()),
      if (shopRemoteStateSliver != null)
        shopRemoteStateSliver
      else if (_showShopAllLanding) ...[
        if (_restaurantRemoteProducts.isNotEmpty)
          SliverToBoxAdapter(
            child: _ShopSingleRowSection(
              title: 'Top food',
              items: _restaurantRemoteProducts,
              onTap: _openShopProfile,
              isWishlisted: _isWishlisted,
              isFavourited: _isFavourited,
              onWishlistToggle: _toggleWishlist,
              onFavouriteToggle: _toggleFavourite,
              onAddToCart: (item) => _openShopProfile(item, autoAddItem: true),
            ),
          ),
        if (visibleRestaurantListings.isNotEmpty)
          SliverToBoxAdapter(
            child: _RestaurantRecommendedSection(
              items: visibleRestaurantListings.take(6).toList(),
              onTap: (listing) => _openRestaurantListing(listing),
            ),
          ),
        if (allNearbyShopProfiles.isNotEmpty)
          SliverList.builder(
            itemCount: allNearbyShopProfiles.length > 6
                ? 6
                : allNearbyShopProfiles.length,
            itemBuilder: (context, index) => _VerticalShopCard(
              item: allNearbyShopProfiles[index],
              isWishlisted: _isWishlisted(allNearbyShopProfiles[index]),
              onWishlistToggle: () =>
                  _toggleWishlist(allNearbyShopProfiles[index]),
              onTap: () => _openShopProfile(allNearbyShopProfiles[index]),
            ),
          ),
      ] else if (_showShopRestaurantLanding) ...[
        SliverToBoxAdapter(
          child: _RestaurantCuisineStrip(
            items: _effectiveRestaurantCuisines,
            selected: _selectedRestaurantCuisine,
            onSelected: _selectRestaurantCuisine,
          ),
        ),
        const SliverToBoxAdapter(child: _RestaurantFilterRow()),
        if (visibleRestaurantListings.isNotEmpty)
          SliverToBoxAdapter(
            child: _RestaurantRecommendedSection(
              items: visibleRestaurantListings.take(6).toList(),
              onTap: (listing) => _openRestaurantListing(listing),
            ),
          ),
        SliverList.builder(
          itemCount: visibleRestaurantListings.length,
          itemBuilder: (context, index) {
            final listing = visibleRestaurantListings[index];
            return _RestaurantListingCard(
              listing: listing,
              isFavourited: _isFavourited(listing.item),
              onFavouriteToggle: () => _toggleFavourite(listing.item),
              onTap: () => _openRestaurantListing(listing),
            );
          },
        ),
      ] else if (_shopBrowseMode == _ShopBrowseMode.itemWise &&
          _selectedShopCategory == 'Gift') ...[
        if (_giftRemoteReady)
          if (_giftRemoteProducts.isNotEmpty)
            SliverToBoxAdapter(
              child: _RemoteGiftShowcase(
                items: _giftRemoteProducts,
                onItemTap: _openShopItemFromHome,
              ),
            )
          else
            SliverList.builder(
              itemCount: _effectiveGiftShopCards.length,
              itemBuilder: (context, index) => _VerticalShopCard(
                item: _effectiveGiftShopCards[index],
                isWishlisted: _isWishlisted(_effectiveGiftShopCards[index]),
                onWishlistToggle: () =>
                    _toggleWishlist(_effectiveGiftShopCards[index]),
                onTap: () => _openShopProfile(_effectiveGiftShopCards[index]),
              ),
            ),
      ] else if (_shopBrowseMode == _ShopBrowseMode.itemWise &&
          _selectedShopCategory == 'Groceries') ...[
        if (_groceryRemoteReady)
          if (_groceryRemoteProducts.isNotEmpty)
            SliverToBoxAdapter(
              child: _RemoteGroceryShowcase(
                items: _groceryRemoteProducts,
                selectedCategory: _selectedShopSubCategory,
                onItemTap: _openShopItemFromHome,
                onAddToCart: (item) =>
                    _openShopProfile(item, autoAddItem: true),
                isWishlisted: _isWishlisted,
                onWishlistToggle: _toggleWishlist,
              ),
            )
          else
            SliverList.builder(
              itemCount: _effectiveGroceryShopCards.length,
              itemBuilder: (context, index) => _VerticalShopCard(
                item: _effectiveGroceryShopCards[index],
                isWishlisted: _isWishlisted(_effectiveGroceryShopCards[index]),
                onWishlistToggle: () =>
                    _toggleWishlist(_effectiveGroceryShopCards[index]),
                onTap: () =>
                    _openShopProfile(_effectiveGroceryShopCards[index]),
              ),
            ),
      ] else if (_shopBrowseMode == _ShopBrowseMode.itemWise &&
          _selectedShopCategory == 'Pharmacy') ...[
        if (_pharmacyRemoteReady)
          if (_pharmacyRemoteProducts.isNotEmpty)
            SliverToBoxAdapter(
              child: _RemotePharmacyShowcase(
                items: _pharmacyRemoteProducts,
                selectedCategory: _selectedShopSubCategory,
                onItemTap: _openShopItemFromHome,
                onAddToCart: (item) =>
                    _openShopProfile(item, autoAddItem: true),
                isWishlisted: _isWishlisted,
                onWishlistToggle: _toggleWishlist,
              ),
            )
          else
            SliverList.builder(
              itemCount: _effectivePharmacyShopCards.length,
              itemBuilder: (context, index) => _VerticalShopCard(
                item: _effectivePharmacyShopCards[index],
                isWishlisted: _isWishlisted(_effectivePharmacyShopCards[index]),
                onWishlistToggle: () =>
                    _toggleWishlist(_effectivePharmacyShopCards[index]),
                onTap: () =>
                    _openShopProfile(_effectivePharmacyShopCards[index]),
              ),
            ),
      ] else if (_shopBrowseMode == _ShopBrowseMode.itemWise &&
          _showShopFashionLanding &&
          _fashionRemoteReady) ...[
        if (_fashionRemoteProducts.isNotEmpty)
          SliverToBoxAdapter(
            child: _RemoteFashionShowcase(
              items: _fashionRemoteProducts,
              hasMore: _fashionRemoteHasMore,
              onItemTap: _openShopItemFromHome,
              isWishlisted: _isWishlisted,
              onWishlistToggle: _toggleWishlist,
            ),
          )
        else
          SliverList.builder(
            itemCount: _effectiveFashionShopCards.length,
            itemBuilder: (context, index) => _VerticalShopCard(
              item: _effectiveFashionShopCards[index],
              isWishlisted: _isWishlisted(_effectiveFashionShopCards[index]),
              onWishlistToggle: () =>
                  _toggleWishlist(_effectiveFashionShopCards[index]),
              onTap: () => _openShopProfile(_effectiveFashionShopCards[index]),
            ),
          ),
      ] else if (_shopBrowseMode == _ShopBrowseMode.itemWise &&
          _showShopFootwearLanding &&
          _footwearRemoteReady) ...[
        if (_footwearRemoteProducts.isNotEmpty)
          SliverToBoxAdapter(
            child: _RemoteFootwearShowcase(
              items: _footwearRemoteProducts,
              hasMore: _footwearRemoteHasMore,
              onItemTap: _openShopItemFromHome,
              isWishlisted: _isWishlisted,
              onWishlistToggle: _toggleWishlist,
            ),
          )
        else
          SliverList.builder(
            itemCount: _effectiveFootwearShopCards.length,
            itemBuilder: (context, index) => _VerticalShopCard(
              item: _effectiveFootwearShopCards[index],
              isWishlisted: _isWishlisted(_effectiveFootwearShopCards[index]),
              onWishlistToggle: () =>
                  _toggleWishlist(_effectiveFootwearShopCards[index]),
              onTap: () => _openShopProfile(_effectiveFootwearShopCards[index]),
            ),
          ),
      ],
      if (_shopBrowseMode == _ShopBrowseMode.shopWise &&
          _selectedShopCategory == 'Groceries')
        SliverList.builder(
          itemCount: _effectiveGroceryShopCards.length,
          itemBuilder: (context, index) => _VerticalShopCard(
            item: _effectiveGroceryShopCards[index],
            isWishlisted: _isWishlisted(_effectiveGroceryShopCards[index]),
            onWishlistToggle: () =>
                _toggleWishlist(_effectiveGroceryShopCards[index]),
            onTap: () => _openShopProfile(_effectiveGroceryShopCards[index]),
          ),
        ),
      if (_shopBrowseMode == _ShopBrowseMode.shopWise &&
          _selectedShopCategory == 'Pharmacy')
        SliverList.builder(
          itemCount: _effectivePharmacyShopCards.length,
          itemBuilder: (context, index) => _VerticalShopCard(
            item: _effectivePharmacyShopCards[index],
            isWishlisted: _isWishlisted(_effectivePharmacyShopCards[index]),
            onWishlistToggle: () =>
                _toggleWishlist(_effectivePharmacyShopCards[index]),
            onTap: () => _openShopProfile(_effectivePharmacyShopCards[index]),
          ),
        ),
      if (_shopBrowseMode == _ShopBrowseMode.shopWise &&
          _selectedShopCategory == 'Gift')
        SliverList.builder(
          itemCount: _effectiveGiftShopCards.length,
          itemBuilder: (context, index) => _VerticalShopCard(
            item: _effectiveGiftShopCards[index],
            isWishlisted: _isWishlisted(_effectiveGiftShopCards[index]),
            onWishlistToggle: () =>
                _toggleWishlist(_effectiveGiftShopCards[index]),
            onTap: () => _openShopProfile(_effectiveGiftShopCards[index]),
          ),
        ),
      if (_shopBrowseMode == _ShopBrowseMode.shopWise &&
          _selectedShopCategory == 'Fashion' &&
          _fashionRemoteReady)
        SliverList.builder(
          itemCount: _effectiveFashionShopCards.length,
          itemBuilder: (context, index) => _VerticalShopCard(
            item: _effectiveFashionShopCards[index],
            isWishlisted: _isWishlisted(_effectiveFashionShopCards[index]),
            onWishlistToggle: () =>
                _toggleWishlist(_effectiveFashionShopCards[index]),
            onTap: () => _openShopProfile(_effectiveFashionShopCards[index]),
          ),
        ),
      if (_shopBrowseMode == _ShopBrowseMode.shopWise &&
          _selectedShopCategory == 'Footwear' &&
          _footwearRemoteReady)
        SliverList.builder(
          itemCount: _effectiveFootwearShopCards.length,
          itemBuilder: (context, index) => _VerticalShopCard(
            item: _effectiveFootwearShopCards[index],
            isWishlisted: _isWishlisted(_effectiveFootwearShopCards[index]),
            onWishlistToggle: () =>
                _toggleWishlist(_effectiveFootwearShopCards[index]),
            onTap: () => _openShopProfile(_effectiveFootwearShopCards[index]),
          ),
        ),
    ];
  }

  Future<_DiscoveryItem> _resolveServiceDetailItem(_DiscoveryItem item) async {
    final providerId = item.backendServiceProviderId;
    if (providerId == null) {
      return item;
    }
    try {
      final backendProfile = await _UserAppApi.fetchServiceProviderProfile(
        providerId,
        categoryId: item.backendCategoryId,
        subcategoryId: item.backendSubcategoryId,
      );
      final selectedOption =
          backendProfile.serviceOptions
              .where(
                (option) => option.subcategoryId == item.backendSubcategoryId,
              )
              .firstOrNull ??
          backendProfile.serviceOptions.firstOrNull;
      final serviceLabels = backendProfile.serviceOptions.isNotEmpty
          ? backendProfile.serviceOptions
                .map((option) => option.subcategoryName.trim())
                .where((label) => label.isNotEmpty)
                .toSet()
                .toList(growable: false)
          : (backendProfile.serviceItems.isNotEmpty
                ? backendProfile.serviceItems
                : item.serviceItems);
      final selectedTileLabel =
          selectedOption?.subcategoryName.trim().isNotEmpty == true
          ? selectedOption!.subcategoryName.trim()
          : _deriveSelectedServiceTileLabel(
              backendProfile.provider.copyWith(
                title: item.title,
                serviceTileLabel: item.serviceTileLabel.isNotEmpty
                    ? item.serviceTileLabel
                    : item.title,
                serviceItems: serviceLabels,
              ),
            );
      return backendProfile.provider.copyWith(
        title: backendProfile.provider.subtitle,
        subtitle: selectedOption?.categoryName.trim().isNotEmpty == true
            ? selectedOption!.categoryName.trim()
            : (item.subtitle.trim().isNotEmpty ? item.subtitle : 'Service'),
        price: selectedOption?.visitingChargeLabel.trim().isNotEmpty == true
            ? selectedOption!.visitingChargeLabel.trim()
            : backendProfile.provider.price,
        serviceItems: serviceLabels,
        serviceOptions: backendProfile.serviceOptions,
        serviceTileLabel: selectedTileLabel,
        backendCategoryId:
            selectedOption?.categoryId ??
            item.backendCategoryId ??
            backendProfile.provider.backendCategoryId,
        backendSubcategoryId:
            selectedOption?.subcategoryId ??
            item.backendSubcategoryId ??
            backendProfile.provider.backendSubcategoryId,
        isDisabled: item.isDisabled,
        disabledLabel: item.disabledLabel,
      );
    } catch (_) {
      return item.copyWith(
        title: item.subtitle,
        subtitle: item.title,
        serviceTileLabel: _deriveSelectedServiceTileLabel(item),
      );
    }
  }

  Future<void> _openCard(_DiscoveryItem item, _HomeMode mode) async {
    if (_discoveryDetailNavigationInFlight) {
      return;
    }
    _discoveryDetailNavigationInFlight = true;
    try {
      if (item.isDisabled) {
        if (mode == _HomeMode.shop) {
          _showCartSnack(
            item.disabledLabel.trim().isEmpty
                ? '${item.title} is unavailable right now.'
                : '${item.title} is ${item.disabledLabel.toLowerCase()} right now.',
          );
          return;
        }
      }
      if (mode == _HomeMode.shop) {
        _openShopProfile(item);
        return;
      }
      final detailItem = switch (mode) {
        _HomeMode.labour => await _resolveLabourDetailItem(item),
        _HomeMode.service => await _resolveServiceDetailItem(item),
        _ => item,
      };
      if (!mounted) {
        return;
      }
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => _DiscoveryDetailPage(
            item: detailItem,
            mode: mode,
            isAuthenticated: _isAuthenticated,
            isWishlisted: _isWishlisted(detailItem),
            isFavourited: _isFavourited(detailItem),
            onWishlistToggle: () => _toggleWishlist(detailItem),
            onFavouriteToggle: () => _toggleFavourite(detailItem),
            onPrimaryAction:
                (
                  labourBookingPeriod,
                  labourCategoryId,
                  serviceCategoryId,
                  serviceSubcategoryId,
                ) => _handlePrimaryAction(
                  detailItem,
                  mode,
                  labourBookingPeriod: labourBookingPeriod,
                  labourCategoryId: labourCategoryId,
                  serviceCategoryId: serviceCategoryId,
                  serviceSubcategoryId: serviceSubcategoryId,
                ),
          ),
        ),
      );
      if (mounted) {
        await _hydrateRemoteState(silent: true);
      }
    } finally {
      _discoveryDetailNavigationInFlight = false;
    }
  }

  Future<_DiscoveryItem> _resolveLabourDetailItem(_DiscoveryItem item) async {
    final labourId = item.backendLabourId;
    if (labourId == null) {
      return item;
    }
    try {
      final backendProfile = await _UserAppApi.fetchLabourProfile(labourId);
      return _buildLabourProfileDetailItem(
        backendProfile.copyWith(
          backendCategoryId:
              item.backendCategoryId ?? backendProfile.backendCategoryId,
          isDisabled: item.isDisabled,
          disabledLabel: item.disabledLabel,
        ),
      );
    } catch (_) {
      return _buildLabourProfileDetailItem(item);
    }
  }

  _DiscoveryItem _buildLabourProfileDetailItem(_DiscoveryItem item) {
    if (item.backendLabourId == null) {
      return item;
    }
    final matchingProfiles = _labourRemoteProfiles
        .where((profile) => profile.backendLabourId == item.backendLabourId)
        .toList(growable: false);
    final sourceProfiles = <_DiscoveryItem>[
      item,
      ...matchingProfiles.where(
        (profile) =>
            profile.backendCategoryId != item.backendCategoryId ||
            profile.labourCategoryPricing.isNotEmpty,
      ),
    ];
    final categoryPricing = <_LabourCategoryPricing>[];
    final seenCategoryIds = <int?>{};
    for (final profile in sourceProfiles) {
      final pricingEntries = profile.labourCategoryPricing.isNotEmpty
          ? profile.labourCategoryPricing
          : <_LabourCategoryPricing>[
              _LabourCategoryPricing(
                categoryId: profile.backendCategoryId,
                label: profile.subtitle,
                halfDayPrice: profile.labourHalfDayPrice,
                fullDayPrice: profile.labourFullDayPrice,
              ),
            ];
      for (final pricing in pricingEntries) {
        final resolvedCategoryId =
            pricing.categoryId ?? profile.backendCategoryId;
        final normalizedLabel =
            _labourCategoryLabelForId(resolvedCategoryId) ??
            pricing.label
                .trim()
                .split(',')
                .map((part) => part.trim())
                .firstWhere(
                  (part) => part.isNotEmpty,
                  orElse: () => profile.subtitle.trim(),
                );
        if (!seenCategoryIds.add(resolvedCategoryId)) {
          continue;
        }
        categoryPricing.add(
          _LabourCategoryPricing(
            categoryId: resolvedCategoryId,
            label: normalizedLabel,
            halfDayPrice: pricing.halfDayPrice,
            fullDayPrice: pricing.fullDayPrice,
          ),
        );
      }
    }
    if (categoryPricing.isEmpty) {
      return item;
    }
    final selectedCategory = sourceProfiles.firstWhere(
      (profile) =>
          profile.backendCategoryId == item.backendCategoryId ||
          profile.labourCategoryPricing.any(
            (pricing) => pricing.categoryId == item.backendCategoryId,
          ),
      orElse: () => item,
    );
    final selectedCategoryLabel =
        _labourCategoryLabelForId(selectedCategory.backendCategoryId) ??
        categoryPricing
            .where(
              (pricing) =>
                  pricing.categoryId == selectedCategory.backendCategoryId,
            )
            .map((pricing) => pricing.label.trim())
            .firstWhere(
              (label) => label.isNotEmpty,
              orElse: () => selectedCategory.subtitle,
            );
    final selectedPricing = categoryPricing.firstWhere(
      (pricing) => pricing.categoryId == selectedCategory.backendCategoryId,
      orElse: () =>
          categoryPricing.firstOrNull ??
          _LabourCategoryPricing(
            categoryId: selectedCategory.backendCategoryId,
            label: selectedCategoryLabel,
            halfDayPrice: selectedCategory.labourHalfDayPrice,
            fullDayPrice: selectedCategory.labourFullDayPrice,
          ),
    );
    return selectedCategory.copyWith(
      subtitle: selectedCategoryLabel,
      labourHalfDayPrice: selectedPricing.halfDayPrice,
      labourFullDayPrice: selectedPricing.fullDayPrice,
      labourCategoryPricing: categoryPricing,
    );
  }

  Future<void> _openRestaurantListing(_RestaurantListingItem listing) async {
    if (listing.item.isDisabled) {
      _showCartSnack('${listing.item.title} is closed right now.');
      return;
    }
    if (listing.item.backendProductId != null) {
      await _openShopItemFromHome(listing.item);
      return;
    }
    final shopId = listing.item.backendShopId;
    if (shopId == null) {
      _openShopProfile(listing.item);
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _RemoteRestaurantShopPage(
          shopId: shopId,
          fallbackTitle: listing.item.title,
          onOpenCart: _openCartPage,
          onCartUpdated: (cart) {
            setState(() {
              _cartShopName = cart.shopName;
              _cartItems
                ..clear()
                ..addAll(cart.items);
            });
          },
          onWishlistToggle: (item) => _toggleWishlist(item),
        ),
      ),
    );
    if (mounted) {
      await _hydrateRemoteState();
    }
  }

  Future<void> _openShopItemFromHome(_DiscoveryItem item) async {
    final itemCategory = _shopCategoryForItem(item);
    if (_shopComingSoonCategories.contains(itemCategory)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$itemCategory is coming soon.')));
      return;
    }
    if (item.isDisabled) {
      _showCartSnack(
        item.disabledLabel.trim().isEmpty
            ? '${item.subtitle} is unavailable right now.'
            : '${item.subtitle} is ${item.disabledLabel.toLowerCase()} right now.',
      );
      return;
    }
    final isFashionItem = itemCategory == 'Fashion';
    final isFootwearItem = itemCategory == 'Footwear';
    final isGroceryItem = itemCategory == 'Groceries';
    final isPharmacyItem = itemCategory == 'Pharmacy';
    final isGiftItem = itemCategory == 'Gift';
    final isRestaurantItem = itemCategory == 'Restaurant';
    final navigator = Navigator.of(context);
    bool? added;
    if (isFashionItem) {
      added = await navigator.push<bool>(
        MaterialPageRoute<bool>(
          builder: (_) => _ShopItemDetailPage(
            item: item,
            supportsColorVariants: true,
            useFoodPopupStyle: false,
            returnToShopOnBackAfterAdd: true,
            onAddToCart: () => _handleShopCartAdd(item),
            onOpenCart: _openCartPage,
            onWishlistTap: () => _toggleWishlist(item),
            onShareTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Share link for ${item.title} will be connected next.',
                  ),
                ),
              );
            },
          ),
        ),
      );
    } else if (isFootwearItem) {
      added = await navigator.push<bool>(
        MaterialPageRoute<bool>(
          builder: (_) => _FootwearItemDetailPage(
            item: item,
            returnToShopOnBackAfterAdd: true,
            onAddToCart: () => _handleShopCartAdd(item),
            onOpenCart: _openCartPage,
            onWishlistTap: () => _toggleWishlist(item),
            onShareTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Share link for ${item.title} will be connected next.',
                  ),
                ),
              );
            },
          ),
        ),
      );
    } else if (isGroceryItem) {
      added = await navigator.push<bool>(
        MaterialPageRoute<bool>(
          builder: (_) => _GroceryItemDetailPage(
            item: item,
            returnToShopOnBackAfterAdd: true,
            onAddToCart: () => _handleShopCartAdd(item),
            onOpenCart: _openCartPage,
            onWishlistTap: () => _toggleWishlist(item),
            onShareTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Share link for ${item.title} will be connected next.',
                  ),
                ),
              );
            },
          ),
        ),
      );
    } else if (isPharmacyItem) {
      added = await navigator.push<bool>(
        MaterialPageRoute<bool>(
          builder: (_) => _PharmacyItemDetailPage(
            item: item,
            returnToShopOnBackAfterAdd: true,
            onAddToCart: () => _handleShopCartAdd(item),
            onOpenCart: _openCartPage,
            onWishlistTap: () => _toggleWishlist(item),
            onShareTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Share link for ${item.title} will be connected next.',
                  ),
                ),
              );
            },
          ),
        ),
      );
    } else if (isGiftItem) {
      added = await navigator.push<bool>(
        MaterialPageRoute<bool>(
          builder: (_) => _GiftItemDetailPage(
            item: item,
            returnToShopOnBackAfterAdd: true,
            onAddToCart: () => _handleShopCartAdd(item),
            onOpenCart: _openCartPage,
            onGiftNow: () => _handleShopCartAdd(item, openCartAfterAdd: true),
            onWishlistTap: () => _toggleWishlist(item),
            onShareTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Share link for ${item.title} will be connected next.',
                  ),
                ),
              );
            },
          ),
        ),
      );
    } else {
      added = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: Colors.transparent,
        barrierColor: Colors.black.withValues(alpha: 0.52),
        builder: (_) => _ShopItemDetailPage(
          item: item,
          supportsColorVariants: false,
          useFoodPopupStyle: isRestaurantItem,
          returnToShopOnBackAfterAdd: true,
          onAddToCart: () => _handleShopCartAdd(item),
          onOpenCart: _openCartPage,
          onWishlistTap: () => _toggleWishlist(item),
          onShareTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Share link for ${item.title} will be connected next.',
                ),
              ),
            );
          },
        ),
      );
    }
    if (added == true && mounted) {
      if (isFashionItem && item.backendShopId != null) {
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => _RemoteFashionShopPage(
              shopId: item.backendShopId!,
              fallbackTitle: item.extra.isEmpty ? item.subtitle : item.extra,
              onOpenCart: _openCartPage,
              onCartUpdated: (cart) {
                setState(() {
                  _cartShopName = cart.shopName;
                  _cartItems
                    ..clear()
                    ..addAll(cart.items);
                });
              },
              isWishlisted: _isWishlisted,
              onWishlistToggle: (target) => _toggleWishlist(target),
            ),
          ),
        );
      } else if (isFootwearItem && item.backendShopId != null) {
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => _RemoteFootwearShopPage(
              shopId: item.backendShopId!,
              fallbackTitle: item.extra.isEmpty ? item.subtitle : item.extra,
              onOpenCart: _openCartPage,
              onCartUpdated: (cart) {
                setState(() {
                  _cartShopName = cart.shopName;
                  _cartItems
                    ..clear()
                    ..addAll(cart.items);
                });
              },
              isWishlisted: _isWishlisted,
              onWishlistToggle: (target) => _toggleWishlist(target),
            ),
          ),
        );
      } else if (isGiftItem && item.backendShopId != null) {
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => _RemoteGiftShopPage(
              shopId: item.backendShopId!,
              fallbackTitle: item.extra.isEmpty ? item.subtitle : item.extra,
              onOpenCart: _openCartPage,
              onCartUpdated: (cart) {
                setState(() {
                  _cartShopName = cart.shopName;
                  _cartItems
                    ..clear()
                    ..addAll(cart.items);
                });
              },
              isWishlisted: _isWishlisted,
              onWishlistToggle: (target) => _toggleWishlist(target),
            ),
          ),
        );
      } else if (isGroceryItem && item.backendShopId != null) {
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => _RemoteGroceryShopPage(
              shopId: item.backendShopId!,
              fallbackTitle: item.extra.isEmpty ? item.subtitle : item.extra,
              onOpenCart: _openCartPage,
              onCartUpdated: (cart) {
                setState(() {
                  _cartShopName = cart.shopName;
                  _cartItems
                    ..clear()
                    ..addAll(cart.items);
                });
              },
              isWishlisted: _isWishlisted,
              onWishlistToggle: (target) => _toggleWishlist(target),
            ),
          ),
        );
      } else if (isPharmacyItem && item.backendShopId != null) {
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => _RemotePharmacyShopPage(
              shopId: item.backendShopId!,
              fallbackTitle: item.extra.isEmpty ? item.subtitle : item.extra,
              onOpenCart: _openCartPage,
              onCartUpdated: (cart) {
                setState(() {
                  _cartShopName = cart.shopName;
                  _cartItems
                    ..clear()
                    ..addAll(cart.items);
                });
              },
              isWishlisted: _isWishlisted,
              onWishlistToggle: (target) => _toggleWishlist(target),
            ),
          ),
        );
      } else if (isRestaurantItem && item.backendShopId != null) {
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => _RemoteRestaurantShopPage(
              shopId: item.backendShopId!,
              fallbackTitle: item.subtitle,
              onOpenCart: _openCartPage,
              onCartUpdated: (cart) {
                setState(() {
                  _cartShopName = cart.shopName;
                  _cartItems
                    ..clear()
                    ..addAll(cart.items);
                });
              },
              onWishlistToggle: (target) => _toggleWishlist(target),
            ),
          ),
        );
      } else {
        _openShopProfile(item);
      }
    }
  }

  Future<void> _openCartItemFromCart(_DiscoveryItem item) async {
    final itemCategory = _shopCategoryForItem(item);
    if (item.isDisabled) {
      _showCartSnack(
        item.disabledLabel.trim().isEmpty
            ? '${item.subtitle} is unavailable right now.'
            : '${item.subtitle} is ${item.disabledLabel.toLowerCase()} right now.',
      );
      return;
    }
    final isFashionItem = itemCategory == 'Fashion';
    final isFootwearItem = itemCategory == 'Footwear';
    final isGroceryItem = itemCategory == 'Groceries';
    final isPharmacyItem = itemCategory == 'Pharmacy';
    final isGiftItem = itemCategory == 'Gift';
    final isRestaurantItem = itemCategory == 'Restaurant';
    final navigator = Navigator.of(context);
    if (isFashionItem) {
      await navigator.push<bool>(
        MaterialPageRoute<bool>(
          builder: (_) => _ShopItemDetailPage(
            item: item,
            supportsColorVariants: true,
            useFoodPopupStyle: false,
            returnToShopOnBackAfterAdd: false,
            onAddToCart: () => _handleShopCartAdd(item),
            onOpenCart: () => Navigator.of(context).pop(),
            onWishlistTap: () => _toggleWishlist(item),
            onShareTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Share link for ${item.title} will be connected next.',
                  ),
                ),
              );
            },
          ),
        ),
      );
    } else if (isFootwearItem) {
      await navigator.push<bool>(
        MaterialPageRoute<bool>(
          builder: (_) => _FootwearItemDetailPage(
            item: item,
            returnToShopOnBackAfterAdd: false,
            onAddToCart: () => _handleShopCartAdd(item),
            onOpenCart: () => Navigator.of(context).pop(),
            onWishlistTap: () => _toggleWishlist(item),
            onShareTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Share link for ${item.title} will be connected next.',
                  ),
                ),
              );
            },
          ),
        ),
      );
    } else if (isGroceryItem) {
      await navigator.push<bool>(
        MaterialPageRoute<bool>(
          builder: (_) => _GroceryItemDetailPage(
            item: item,
            returnToShopOnBackAfterAdd: false,
            onAddToCart: () => _handleShopCartAdd(item),
            onOpenCart: () => Navigator.of(context).pop(),
            onWishlistTap: () => _toggleWishlist(item),
            onShareTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Share link for ${item.title} will be connected next.',
                  ),
                ),
              );
            },
          ),
        ),
      );
    } else if (isPharmacyItem) {
      await navigator.push<bool>(
        MaterialPageRoute<bool>(
          builder: (_) => _PharmacyItemDetailPage(
            item: item,
            returnToShopOnBackAfterAdd: false,
            onAddToCart: () => _handleShopCartAdd(item),
            onOpenCart: () => Navigator.of(context).pop(),
            onWishlistTap: () => _toggleWishlist(item),
            onShareTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Share link for ${item.title} will be connected next.',
                  ),
                ),
              );
            },
          ),
        ),
      );
    } else if (isGiftItem) {
      await navigator.push<bool>(
        MaterialPageRoute<bool>(
          builder: (_) => _GiftItemDetailPage(
            item: item,
            returnToShopOnBackAfterAdd: false,
            onAddToCart: () => _handleShopCartAdd(item),
            onOpenCart: () => Navigator.of(context).pop(),
            onGiftNow: () => _handleShopCartAdd(item, openCartAfterAdd: true),
            onWishlistTap: () => _toggleWishlist(item),
            onShareTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Share link for ${item.title} will be connected next.',
                  ),
                ),
              );
            },
          ),
        ),
      );
    } else {
      await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: Colors.transparent,
        barrierColor: Colors.black.withValues(alpha: 0.52),
        builder: (_) => _ShopItemDetailPage(
          item: item,
          supportsColorVariants: false,
          useFoodPopupStyle: isRestaurantItem,
          returnToShopOnBackAfterAdd: false,
          onAddToCart: () => _handleShopCartAdd(item),
          onOpenCart: () => Navigator.of(context).pop(),
          onWishlistTap: () => _toggleWishlist(item),
          onShareTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Share link for ${item.title} will be connected next.',
                ),
              ),
            );
          },
        ),
      );
    }
    if (mounted && _isAuthenticated) {
      await _hydrateRemoteState(silent: true);
    }
  }

  void _openShopProfile(_DiscoveryItem item, {bool autoAddItem = false}) {
    final inferredCategory = _selectedShopCategory == 'All Deals'
        ? _shopCategoryForItem(item)
        : _selectedShopCategory;
    if (_shopComingSoonCategories.contains(inferredCategory)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$inferredCategory is coming soon.')),
      );
      return;
    }
    if (item.isDisabled) {
      _showCartSnack(
        item.disabledLabel.trim().isEmpty
            ? '${item.subtitle} is unavailable right now.'
            : '${item.subtitle} is ${item.disabledLabel.toLowerCase()} right now.',
      );
      return;
    }
    if (inferredCategory == 'Fashion' && item.backendShopId != null) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => _RemoteFashionShopPage(
            shopId: item.backendShopId!,
            fallbackTitle: item.extra.isEmpty ? item.subtitle : item.extra,
            onOpenCart: _openCartPage,
            onCartUpdated: (cart) {
              setState(() {
                _cartShopName = cart.shopName;
                _cartItems
                  ..clear()
                  ..addAll(cart.items);
              });
            },
            isWishlisted: _isWishlisted,
            onWishlistToggle: _toggleWishlist,
          ),
        ),
      );
      return;
    }
    if (inferredCategory == 'Footwear' && item.backendShopId != null) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => _RemoteFootwearShopPage(
            shopId: item.backendShopId!,
            fallbackTitle: item.extra.isEmpty ? item.subtitle : item.extra,
            onOpenCart: _openCartPage,
            onCartUpdated: (cart) {
              setState(() {
                _cartShopName = cart.shopName;
                _cartItems
                  ..clear()
                  ..addAll(cart.items);
              });
            },
            isWishlisted: _isWishlisted,
            onWishlistToggle: _toggleWishlist,
          ),
        ),
      );
      return;
    }
    if (inferredCategory == 'Gift' && item.backendShopId != null) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => _RemoteGiftShopPage(
            shopId: item.backendShopId!,
            fallbackTitle: item.extra.isEmpty ? item.subtitle : item.extra,
            onOpenCart: _openCartPage,
            onCartUpdated: (cart) {
              setState(() {
                _cartShopName = cart.shopName;
                _cartItems
                  ..clear()
                  ..addAll(cart.items);
              });
            },
            isWishlisted: _isWishlisted,
            onWishlistToggle: _toggleWishlist,
          ),
        ),
      );
      return;
    }
    if (inferredCategory == 'Groceries' && item.backendShopId != null) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => _RemoteGroceryShopPage(
            shopId: item.backendShopId!,
            fallbackTitle: item.extra.isEmpty ? item.subtitle : item.extra,
            onOpenCart: _openCartPage,
            onCartUpdated: (cart) {
              setState(() {
                _cartShopName = cart.shopName;
                _cartItems
                  ..clear()
                  ..addAll(cart.items);
              });
            },
            isWishlisted: _isWishlisted,
            onWishlistToggle: _toggleWishlist,
          ),
        ),
      );
      return;
    }
    if (inferredCategory == 'Pharmacy' && item.backendShopId != null) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => _RemotePharmacyShopPage(
            shopId: item.backendShopId!,
            fallbackTitle: item.extra.isEmpty ? item.subtitle : item.extra,
            onOpenCart: _openCartPage,
            onCartUpdated: (cart) {
              setState(() {
                _cartShopName = cart.shopName;
                _cartItems
                  ..clear()
                  ..addAll(cart.items);
              });
            },
            isWishlisted: _isWishlisted,
            onWishlistToggle: _toggleWishlist,
          ),
        ),
      );
      return;
    }
    if (inferredCategory == 'Groceries') {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => _GroceryProfilePage(
            item: item,
            initialCategory: _selectedShopSubCategory != 'All'
                ? _selectedShopSubCategory
                : 'Biscuits',
            isWishlisted: _isWishlisted,
            onWishlistToggle: _toggleWishlist,
            onAddToCart: (selectedItem) =>
                _handleShopCartAdd(selectedItem, openCartAfterAdd: autoAddItem),
            onOpenCart: _openCartPage,
            autoAddItem: autoAddItem,
          ),
        ),
      );
      return;
    }
    if (inferredCategory == 'Pharmacy') {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => _PharmacyProfilePage(
            item: item,
            initialCategory: _selectedShopSubCategory != 'All'
                ? _selectedShopSubCategory
                : 'Wellness',
            isWishlisted: _isWishlisted,
            onWishlistToggle: _toggleWishlist,
            onAddToCart: (selectedItem) =>
                _handleShopCartAdd(selectedItem, openCartAfterAdd: autoAddItem),
            onOpenCart: _openCartPage,
            autoAddItem: autoAddItem,
          ),
        ),
      );
      return;
    }
    if (inferredCategory == 'Gift') {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => _GiftProfilePage(
            item: item,
            initialCategory: _selectedShopSubCategory != 'All'
                ? _selectedShopSubCategory
                : 'Birthday',
            isWishlisted: _isWishlisted,
            onWishlistToggle: _toggleWishlist,
            onAddToCart: (selectedItem) =>
                _handleShopCartAdd(selectedItem, openCartAfterAdd: autoAddItem),
            onOpenCart: _openCartPage,
            autoAddItem: autoAddItem,
          ),
        ),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _ShopProfilePage(
          item: item,
          shopCategory: inferredCategory,
          initialFashionSubcategory:
              (inferredCategory == 'Fashion' ||
                      inferredCategory == 'Footwear') &&
                  _selectedShopSubCategory != 'All'
              ? _selectedShopSubCategory
              : 'All',
          isWishlisted: _isWishlisted,
          onWishlistToggle: _toggleWishlist,
          onAddToCart: (selectedItem) =>
              _handleShopCartAdd(selectedItem, openCartAfterAdd: autoAddItem),
          onOpenCart: _openCartPage,
          autoAddItem: autoAddItem,
        ),
      ),
    );
  }

  Future<void> _openProfilePage() async {
    if (!_isAuthenticated) {
      final canContinue = await _ensureAuthenticated();
      if (!mounted || !canContinue) {
        return;
      }
      await _hydrateRemoteState(silent: true);
      return;
    }
    final initialProfile =
        _cachedUserProfile ?? await _readCachedProfilePreview();
    if (!mounted) {
      return;
    }
    if (_cachedUserProfile == null && initialProfile != null) {
      setState(() {
        _cachedUserProfile = initialProfile;
        _headerProfilePhotoDataUri = initialProfile.profilePhotoDataUri.trim();
        _headerProfilePhotoObjectKey = initialProfile.profilePhotoObjectKey
            .trim();
      });
    }
    final updatedProfile = await Navigator.of(context).push<_UserProfileData>(
      MaterialPageRoute<_UserProfileData>(
        builder: (_) => _ProfilePage(
          phoneNumber: _currentPhoneNumber,
          initialProfile: initialProfile,
          onLogout: () async {
            await _NotificationBootstrap.deactivateCurrentToken();
            await _LocalSessionStore.clear();
            if (!mounted) {
              return;
            }
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute<void>(builder: (_) => const UserHomePage()),
              (route) => false,
            );
          },
        ),
      ),
    );
    if (mounted && updatedProfile != null) {
      setState(() {
        _cachedUserProfile = updatedProfile;
        _headerProfilePhotoDataUri = updatedProfile.profilePhotoDataUri.trim();
        _headerProfilePhotoObjectKey = updatedProfile.profilePhotoObjectKey
            .trim();
      });
      await _LocalSessionStore.saveProfileCache(
        jsonEncode(updatedProfile.toJson()),
      );
    }
    await _refreshNotificationPreview(silent: true);
    await _hydrateRemoteState(silent: true);
  }

  Future<void> _openNotificationsPage() async {
    final canContinue = await _ensureAuthenticated();
    if (!mounted || !canContinue) {
      return;
    }
    await Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const _NotificationsPage()));
    await _refreshNotificationPreview(silent: true);
  }

  Future<void> _openCartPage() async {
    if (_cartPageOpening) {
      return;
    }
    _cartPageOpening = true;
    try {
      if (_isAuthenticated) {
        await _hydrateRemoteState();
        if (!mounted) {
          return;
        }
      }
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => _CartPage(
            shopName: _cartShopName ?? 'Your cart',
            items: List<_DiscoveryItem>.unmodifiable(_cartItems),
            isAuthenticated: _isAuthenticated,
            onCheckout: _checkoutFromCartPage,
            onBrowseItems: () => Navigator.of(context).pop(),
            onRequireLogin: _ensureAuthenticated,
            onItemTap: _openCartItemFromCart,
          ),
        ),
      );
      if (mounted) {
        await _hydrateRemoteState(silent: true);
      }
    } finally {
      _cartPageOpening = false;
    }
  }

  Future<void> _checkoutFromCartPage(int? addressId) async {
    final canContinue = await _ensureAuthenticated();
    if (!mounted || !canContinue) {
      return;
    }
    await _syncLocalCartToBackend();
    try {
      final preview = await _UserAppApi.previewCheckout(addressId: addressId);
      if (!preview.canPlaceOrder) {
        if (!mounted) {
          return;
        }
        _showCartSnack(
          preview.issues.isEmpty
              ? 'This order cannot be placed right now.'
              : preview.issues.join(' • '),
        );
        return;
      }
      final order = await _UserAppApi.placeOrder(
        fulfillmentType: preview.fulfillmentType,
        addressId: preview.addressId ?? addressId,
      );
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop();
      final paymentResult = await _PaymentFlow.start(
        context,
        paymentCode: order.paymentCode,
        title: 'Pay for ${preview.shopName}',
      );
      if (!mounted) {
        return;
      }
      await _hydrateRemoteState(silent: true);
      if (!mounted) {
        return;
      }
      await _PaymentFlow.showOutcome(
        context,
        result: paymentResult,
        successTitle: 'Order confirmed',
        failureTitle: 'Order payment incomplete',
        extraLines: [
          'Order code: ${order.orderCode}',
          'Amount: ${order.totalAmount}',
          preview.addressLine.isEmpty
              ? 'Default delivery address was used.'
              : 'Delivering to ${preview.addressLine}',
        ],
      );
    } on _UserAppApiException catch (error) {
      if (!mounted) {
        return;
      }
      _showCartSnack(error.message);
    }
  }

  Future<bool> _handlePrimaryAction(
    _DiscoveryItem item,
    _HomeMode mode, {
    String? labourBookingPeriod,
    int? labourCategoryId,
    int? serviceCategoryId,
    int? serviceSubcategoryId,
  }) async {
    await _refreshSessionPhoneFromStore();
    if ((mode == _HomeMode.labour || mode == _HomeMode.service) &&
        !_isAuthenticated) {
      final loggedIn = await _ensureAuthenticated();
      if (!loggedIn) {
        return false;
      }
      if (!mounted) {
        return false;
      }
    }
    if (item.isDisabled) {
      _showCartSnack(
        item.disabledLabel.trim().isEmpty
            ? '${item.title} is unavailable right now.'
            : '${item.title} is ${item.disabledLabel.toLowerCase()} right now.',
      );
      return false;
    }
    switch (mode) {
      case _HomeMode.shop:
        await _handleShopCartAdd(item, openCartAfterAdd: true);
        return false;
      case _HomeMode.labour:
        if (item.backendLabourId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${item.title} is not connected to live labour booking yet.',
              ),
            ),
          );
          return false;
        }
        return _startLabourBookingRequestFlow(
          labourCategoryId == null
              ? item
              : item.copyWith(backendCategoryId: labourCategoryId),
          labourBookingPeriod ?? 'Full Day',
        );
      case _HomeMode.service:
        if (item.backendServiceProviderId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${item.title} is not connected to live service booking yet.',
              ),
            ),
          );
          return false;
        }
        await _startServiceBookingRequestFlow(
          item.copyWith(
            backendCategoryId: serviceCategoryId ?? item.backendCategoryId,
            backendSubcategoryId:
                serviceSubcategoryId ?? item.backendSubcategoryId,
          ),
        );
        return false;
      case _HomeMode.all:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Open ${item.title} from its mode to continue.'),
          ),
        );
        return false;
    }
  }

  Future<bool> _startLabourBookingRequestFlow(
    _DiscoveryItem item,
    String bookingPeriod, {
    int? retryAddressId,
  }) async {
    var bookingLocked = false;
    try {
      int? bookingAddressId = retryAddressId;
      if (bookingAddressId == null) {
        final confirmed = await _confirmBookingLocationUsage(
          bookingLabel: 'labour',
        );
        if (!mounted || !confirmed) {
          return false;
        }
        final selectedLocation =
            _selectedLocationChoice ?? _currentLocationChoice;
        if (selectedLocation != null &&
            !_isLabourWithinSelectedRange(item, selectedLocation)) {
          final radiusKm = item.labourRadiusKm;
          final radiusLabel = radiusKm == null || radiusKm <= 0
              ? ''
              : ' within ${radiusKm.toStringAsFixed(radiusKm >= 10 ? 0 : 1)} km';
          _showCartSnack(
            'Labour is out of range for this address. Please choose a nearer address or another labour$radiusLabel.',
          );
          return false;
        }
        bookingAddressId = await _ensureBookingAddressIdForServiceOrLabour(
          bookingLabel: 'labour',
        );
      }
      if (bookingAddressId == null) {
        return false;
      }
      if (!mounted) {
        return false;
      }
      final request = await _UserAppApi.bookLabourDirect(
        item: item,
        bookingPeriod: bookingPeriod,
        addressId: bookingAddressId,
      );
      if (!mounted) {
        return false;
      }
      final status = await _waitForLabourAcceptance(
        request,
        retryRequest: () => _UserAppApi.bookLabourDirect(
          item: item,
          bookingPeriod: bookingPeriod,
          addressId: bookingAddressId,
        ),
        candidates: _labourWaitCandidates(<_DiscoveryItem>[
          item,
        ], bookingPeriod),
      );
      if (!mounted) {
        return false;
      }
      if (status == null || !status.canMakePayment) {
        await _showLabourRequestStateDialog(request: request, status: status);
        return false;
      }
      setState(() {
        _upsertActiveBookingStatus(
          _activeBookingStatusFromLabourRequest(
            request: request,
            status: status,
          ),
        );
      });
      if (item.backendLabourId != null) {
        _markLabourBookedLocally(item.backendLabourId!);
      }
      bookingLocked = true;
      final invoiceResult = await _showAcceptedLabourInvoiceDialog(
        request: request,
        status: status,
        requestedCount: 1,
        categoryLabel: _selectedLabourCategory,
        periodLabel: bookingPeriod,
      );
      if (!mounted || invoiceResult == null) {
        return bookingLocked;
      }
      final payment = invoiceResult.payment;
      final paymentResult = invoiceResult.paymentFlowResult;
      if (!mounted) {
        return bookingLocked;
      }
      await _hydrateRemoteState(silent: true);
      if (!mounted) {
        return bookingLocked;
      }
      await _PaymentFlow.showOutcome(
        context,
        result: paymentResult,
        successTitle: 'Labour booking confirmed',
        failureTitle: 'Labour payment incomplete',
        extraLines: [
          'Booking code: ${payment.bookingCode}',
          'Labour: ${status.providerName.trim().isNotEmpty ? status.providerName : request.labourName}',
          'Amount: ${payment.amountLabel}',
        ],
      );
      return bookingLocked;
    } on _UserAppApiException catch (error) {
      if (mounted) {
        if (_isLabourAvailabilityChangedError(error.message)) {
          await _hydrateRemoteState(silent: true);
          if (!mounted) {
            return false;
          }
          _showCartSnack(
            'This labour is no longer available. Availability has been refreshed.',
          );
          return false;
        }
        _showCartSnack(error.message);
      }
    }
    return bookingLocked;
  }

  Future<void> _startQuickLabourBookingFlow({int? retryAddressId}) async {
    final categoryId = _labourCategoryIdForLabel(_selectedLabourCategory);
    if (categoryId == null) {
      _showCartSnack('Please select a labour category first.');
      return;
    }
    if (_selectedSingleLabourPeriod == 'All') {
      return;
    }
    if (retryAddressId == null && !_isAuthenticated) {
      final loggedIn = await _ensureAuthenticated();
      if (!mounted || !loggedIn) {
        return;
      }
    }
    int? bookingAddressId = retryAddressId;
    if (bookingAddressId == null) {
      final confirmed = await _confirmBookingLocationUsage(
        bookingLabel: 'labour',
      );
      if (!mounted || !confirmed) {
        return;
      }
      bookingAddressId = await _ensureBookingAddressIdForServiceOrLabour(
        bookingLabel: 'labour',
      );
    }
    if (bookingAddressId == null || !mounted) {
      return;
    }
    try {
      final result = await _UserAppApi.requestGroupLabourBooking(
        categoryId: categoryId,
        bookingPeriod: _selectedSingleLabourPeriod,
        maxPrice: _selectedSingleLabourMaxPrice.trim().isEmpty
            ? _singleLabourQuickBookOpenBudget
            : _selectedSingleLabourMaxPrice,
        labourCount: 1,
        addressId: bookingAddressId,
      );
      if (!mounted) {
        return;
      }
      final request = _RemoteLabourBookingResult(
        requestId: result.requestId,
        requestCode: result.requestCode,
        requestStatus: 'OPEN',
        quotedPriceAmount: result.platformAmountDue,
        labourName: 'nearby labour',
      );
      final status = await _waitForLabourAcceptance(
        request,
        timeoutSeconds: 45,
        requestedCount: 1,
        retryRequest: () async {
          final refreshed = await _UserAppApi.requestGroupLabourBooking(
            categoryId: categoryId,
            bookingPeriod: _selectedSingleLabourPeriod,
            maxPrice: _selectedSingleLabourMaxPrice.trim().isEmpty
                ? _singleLabourQuickBookOpenBudget
                : _selectedSingleLabourMaxPrice,
            labourCount: 1,
            addressId: bookingAddressId,
          );
          return _RemoteLabourBookingResult(
            requestId: refreshed.requestId,
            requestCode: refreshed.requestCode,
            requestStatus: 'OPEN',
            quotedPriceAmount: refreshed.platformAmountDue,
            labourName: 'nearby labour',
          );
        },
        candidates: _labourWaitCandidates(
          _filteredSingleLabourProfiles,
          _selectedSingleLabourPeriod,
        ),
      );
      if (!mounted) {
        return;
      }
      if (status == null || !status.canMakePayment) {
        await _showLabourRequestStateDialog(request: request, status: status);
        return;
      }
      setState(() {
        _upsertActiveBookingStatus(
          _activeBookingStatusFromLabourRequest(
            request: request,
            status: status,
          ),
        );
      });
      final invoiceResult = await _showAcceptedLabourInvoiceDialog(
        request: request,
        status: status,
        requestedCount: 1,
        categoryLabel: _selectedLabourCategory,
        periodLabel: _selectedSingleLabourPeriod,
      );
      if (!mounted || invoiceResult == null) {
        return;
      }
      final payment = invoiceResult.payment;
      final paymentResult = invoiceResult.paymentFlowResult;
      if (!mounted) {
        return;
      }
      await _hydrateRemoteState(silent: true);
      if (!mounted) {
        return;
      }
      await _PaymentFlow.showOutcome(
        context,
        result: paymentResult,
        successTitle: 'Labour booking confirmed',
        failureTitle: 'Labour payment incomplete',
        extraLines: [
          'Booking code: ${payment.bookingCode}',
          'Labour: ${status.providerName.trim().isNotEmpty ? status.providerName : request.labourName}',
          'Amount: ${payment.amountLabel}',
        ],
      );
    } on _UserAppApiException catch (error) {
      if (mounted) {
        _showCartSnack(error.message);
      }
    }
  }

  bool _isLabourWithinSelectedRange(
    _DiscoveryItem item,
    _HomeLocationChoice selectedLocation,
  ) {
    final radiusKm = item.labourRadiusKm;
    final workLatitude = item.labourWorkLatitude;
    final workLongitude = item.labourWorkLongitude;
    if (radiusKm == null ||
        radiusKm <= 0 ||
        workLatitude == null ||
        workLongitude == null) {
      return true;
    }
    final distanceMeters = Geolocator.distanceBetween(
      workLatitude,
      workLongitude,
      selectedLocation.latitude,
      selectedLocation.longitude,
    );
    return distanceMeters <= (radiusKm * 1000);
  }

  bool _isLabourAvailabilityChangedError(String message) {
    final normalized = message.toLowerCase();
    return normalized.contains('labour') &&
        (normalized.contains('offline') ||
            normalized.contains('booked') ||
            normalized.contains('not available') ||
            normalized.contains('unavailable'));
  }

  LatLng _bookingWaitCenter() {
    final selectedLocation = _selectedLocationChoice ?? _currentLocationChoice;
    if (selectedLocation != null) {
      return LatLng(selectedLocation.latitude, selectedLocation.longitude);
    }
    final latitude = _selectedLatitude;
    final longitude = _selectedLongitude;
    if (latitude != null && longitude != null) {
      return LatLng(latitude, longitude);
    }
    return const LatLng(26.8467, 80.9462);
  }

  List<_BookingWaitCandidate> _labourWaitCandidates(
    Iterable<_DiscoveryItem> items,
    String bookingPeriod,
  ) {
    final center = _bookingWaitCenter();
    final normalizedPeriod = bookingPeriod.trim().toUpperCase();
    return items
        .where((item) => !item.isDisabled)
        .take(24)
        .toList(growable: false)
        .asMap()
        .entries
        .map((entry) {
          final item = entry.value;
          final priceLabel = normalizedPeriod == 'HALF DAY'
              ? item.labourHalfDayPrice
              : normalizedPeriod == 'FULL DAY'
              ? item.labourFullDayPrice
              : (item.labourFullDayPrice.trim().isNotEmpty
                    ? item.labourFullDayPrice
                    : item.labourHalfDayPrice);
          return _BookingWaitCandidate(
            label: item.title.trim().isEmpty ? 'Labour' : item.title.trim(),
            priceLabel: priceLabel.trim().isEmpty
                ? 'Price on accept'
                : priceLabel,
            location: _candidateLocationOrOffset(
              center: center,
              index: entry.key,
              latitude: item.labourWorkLatitude,
              longitude: item.labourWorkLongitude,
            ),
            color: const Color(0xFFF2A13D),
          );
        })
        .toList(growable: false);
  }

  List<_BookingWaitCandidate> _serviceWaitCandidates(
    Iterable<_DiscoveryItem> items,
  ) {
    final center = _bookingWaitCenter();
    return items
        .where((item) => !item.isDisabled)
        .take(24)
        .toList(growable: false)
        .asMap()
        .entries
        .map((entry) {
          final item = entry.value;
          final label = item.serviceTileLabel.trim().isNotEmpty
              ? item.serviceTileLabel.trim()
              : item.title.trim();
          return _BookingWaitCandidate(
            label: label.isEmpty ? 'Service' : label,
            priceLabel: item.price.trim().isEmpty
                ? 'Visit on accept'
                : item.price.trim(),
            location: _candidateLocationOrOffset(
              center: center,
              index: entry.key,
              latitude: item.serviceLatitude,
              longitude: item.serviceLongitude,
            ),
            color: _serviceSubcategoryVisual(label).$2,
          );
        })
        .toList(growable: false);
  }

  LatLng _candidateLocationOrOffset({
    required LatLng center,
    required int index,
    double? latitude,
    double? longitude,
  }) {
    if (latitude != null &&
        longitude != null &&
        latitude != 0 &&
        longitude != 0) {
      return LatLng(latitude, longitude);
    }
    final ring = 0.006 + ((index % 4) * 0.0025);
    final angle = (index * 47) * math.pi / 180;
    return LatLng(
      center.latitude + (math.sin(angle) * ring),
      center.longitude + (math.cos(angle) * ring),
    );
  }

  Future<_RemoteLabourBookingRequestStatus?> _waitForLabourAcceptance(
    _RemoteLabourBookingResult request, {
    int timeoutSeconds = 45,
    int requestedCount = 1,
    bool isGroupRequest = false,
    Future<_RemoteLabourBookingResult> Function()? retryRequest,
    List<_BookingWaitCandidate> candidates = const <_BookingWaitCandidate>[],
  }) async {
    var currentRequest = request;
    final remainingSeconds = ValueNotifier<int>(timeoutSeconds);
    final snapshot = ValueNotifier<_BookingWaitSnapshot>(
      _BookingWaitSnapshot(
        title: isGroupRequest
            ? 'Waiting for labour responses'
            : 'Waiting for labour to accept',
        message: isGroupRequest
            ? 'Your request was sent to nearby matching labour.'
            : '${currentRequest.labourName} has received your booking request.',
      ),
    );
    Completer<_BookingWaitAction> actionCompleter =
        Completer<_BookingWaitAction>();
    _BookingWaitAction? selectedAction;
    void completeAction(_BookingWaitAction action) {
      selectedAction ??= action;
      if (!actionCompleter.isCompleted) {
        actionCompleter.complete(action);
      }
    }

    void resetWaitingState() {
      snapshot.value = _BookingWaitSnapshot(
        title: isGroupRequest
            ? 'Waiting for labour responses'
            : 'Waiting for labour to accept',
        message: isGroupRequest
            ? 'Your request was sent to nearby matching labour.'
            : '${currentRequest.labourName} has received your booking request.',
      );
      selectedAction = null;
      actionCompleter = Completer<_BookingWaitAction>();
    }

    var deadline = DateTime.now().add(Duration(seconds: timeoutSeconds));
    var dialogVisible = true;
    Timer? timer;
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final remaining = deadline.difference(DateTime.now()).inSeconds + 1;
      remainingSeconds.value = remaining.clamp(0, timeoutSeconds);
      if (remainingSeconds.value <= 0) {
        timer?.cancel();
      }
    });
    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => PopScope(
          canPop: false,
          child: _BookingRequestWaitSheet(
            candidates: candidates,
            center: _bookingWaitCenter(),
            remainingSeconds: remainingSeconds,
            totalSeconds: timeoutSeconds,
            snapshot: snapshot,
            showAcceptedProvidersList: isGroupRequest,
            accent: const Color(0xFFF2A13D),
            onCancel: () {
              completeAction(_BookingWaitAction.cancel);
              dialogVisible = false;
              Navigator.of(dialogContext).pop();
            },
            onPay: () {
              completeAction(_BookingWaitAction.pay);
              dialogVisible = false;
              Navigator.of(dialogContext).pop();
            },
            onRetry: () {
              completeAction(_BookingWaitAction.retry);
            },
          ),
        ),
      ).whenComplete(() => dialogVisible = false),
    );
    await Future<void>.delayed(Duration.zero);

    _RemoteLabourBookingRequestStatus? status;
    try {
      retryLoop:
      while (true) {
        deadline = DateTime.now().add(Duration(seconds: timeoutSeconds));
        remainingSeconds.value = timeoutSeconds;
        resetWaitingState();
        status = null;
        while (DateTime.now().isBefore(deadline)) {
          if (selectedAction == _BookingWaitAction.cancel) {
            await _UserAppApi.cancelLabourBookingRequest(
              currentRequest.requestId,
              reason:
                  'You cancelled this booking request while we were still finding a matching labour.',
            );
            status = await _UserAppApi.fetchLabourBookingRequestStatus(
              currentRequest.requestId,
            );
            return status;
          }
          status = await _UserAppApi.fetchLabourBookingRequestStatus(
            currentRequest.requestId,
          );
          if (isGroupRequest) {
            final acceptedCount = status.acceptedProviderCount;
            final enoughAccepted = acceptedCount >= requestedCount;
            final allCandidatesResolved = status.pendingProviderCount <= 0;
            final someAccepted = acceptedCount > 0;
            final closedWithoutAcceptance =
                _isClosedLabourRequestStatus(status.requestStatus) &&
                allCandidatesResolved &&
                !someAccepted;
            final resolvedWithPartialAcceptance =
                allCandidatesResolved && someAccepted;
            final finalAcceptedState =
                enoughAccepted || resolvedWithPartialAcceptance;
            snapshot.value = snapshot.value.copyWith(
              accepted: finalAcceptedState,
              timedOut: false,
              acceptedProviders: status.acceptedProviders,
              title: someAccepted
                  ? '$acceptedCount labour accepted'
                  : 'Waiting for labour responses',
              message: someAccepted
                  ? finalAcceptedState
                        ? acceptedCount >= requestedCount
                              ? 'All requested labour accepted. Tap Go to payment to continue.'
                              : '$acceptedCount of $requestedCount labour accepted. Tap Go to payment to continue for the accepted labour.'
                        : '$acceptedCount of $requestedCount labour accepted so far. We are still waiting for more responses.'
                  : 'Your request was sent to nearby matching labour.',
            );
            if (finalAcceptedState) {
              timer.cancel();
              final action = await actionCompleter.future;
              if (action == _BookingWaitAction.retry && retryRequest != null) {
                currentRequest = await retryRequest();
                continue retryLoop;
              }
              return status;
            }
            if (closedWithoutAcceptance) {
              break;
            }
          } else {
            snapshot.value = snapshot.value.copyWith(
              accepted:
                  status.canMakePayment || status.acceptedProviderCount > 0,
              acceptedProviders: status.acceptedProviders,
              title: status.canMakePayment || status.acceptedProviderCount > 0
                  ? 'Labour accepted'
                  : null,
              message: status.canMakePayment || status.acceptedProviderCount > 0
                  ? 'Tap Go to payment to continue this booking.'
                  : null,
            );
            final accepted =
                status.canMakePayment || status.acceptedProviderCount > 0;
            if (accepted) {
              timer.cancel();
              final action = await actionCompleter.future;
              if (action == _BookingWaitAction.retry && retryRequest != null) {
                currentRequest = await retryRequest();
                continue retryLoop;
              }
              return status;
            }
            if (status.canMakePayment ||
                _isClosedLabourRequestStatus(status.requestStatus)) {
              break;
            }
          }
          await Future<void>.delayed(const Duration(seconds: 2));
        }
        if (isGroupRequest &&
            status != null &&
            status.acceptedProviderCount > 0) {
          timer.cancel();
          snapshot.value = snapshot.value.copyWith(
            accepted: true,
            timedOut: false,
            acceptedProviders: status.acceptedProviders,
            title: '${status.acceptedProviderCount} labour accepted',
            message: status.acceptedProviderCount >= requestedCount
                ? 'All requested labour accepted. Tap Go to payment to continue.'
                : 'Only ${status.acceptedProviderCount} of $requestedCount labour accepted within 1 minute. Tap Go to payment to continue for the accepted labour.',
          );
          final action = await actionCompleter.future;
          if (action == _BookingWaitAction.retry && retryRequest != null) {
            currentRequest = await retryRequest();
            continue;
          }
          return status;
        }
        if (status == null ||
            (!status.canMakePayment && status.acceptedProviderCount <= 0)) {
          snapshot.value = snapshot.value.copyWith(
            timedOut: true,
            title: 'No acceptance yet',
            message:
                'You can retry with matching providers or cancel this request.',
          );
          final action = await actionCompleter.future;
          if (action == _BookingWaitAction.retry) {
            if (status == null || status.acceptedProviderCount <= 0) {
              await _UserAppApi.cancelLabourBookingRequest(
                currentRequest.requestId,
                reason:
                    'You retried this booking request after no labour accepted in time.',
              );
            }
            if (retryRequest != null) {
              currentRequest = await retryRequest();
              continue;
            }
            return null;
          }
          if (action == _BookingWaitAction.cancel) {
            await _UserAppApi.cancelLabourBookingRequest(
              currentRequest.requestId,
              reason:
                  'You cancelled this booking request after no labour accepted in time.',
            );
            status = await _UserAppApi.fetchLabourBookingRequestStatus(
              currentRequest.requestId,
            );
            return status;
          }
        }
        if (!isGroupRequest && (status == null || !status.canMakePayment)) {
          await _UserAppApi.cancelLabourBookingRequest(
            currentRequest.requestId,
            reason: 'Labour did not accept within $timeoutSeconds seconds.',
          );
          status = await _UserAppApi.fetchLabourBookingRequestStatus(
            currentRequest.requestId,
          );
        } else if (isGroupRequest &&
            (status == null || status.acceptedProviderCount <= 0)) {
          await _UserAppApi.cancelLabourBookingRequest(
            currentRequest.requestId,
            reason: 'No labour accepted within $timeoutSeconds seconds.',
          );
          status = await _UserAppApi.fetchLabourBookingRequestStatus(
            currentRequest.requestId,
          );
        }
        return status;
      }
    } finally {
      timer.cancel();
      remainingSeconds.dispose();
      snapshot.dispose();
      if (mounted && dialogVisible) {
        final navigator = Navigator.of(context, rootNavigator: true);
        if (navigator.canPop()) {
          navigator.pop();
        }
      }
    }
  }

  bool _isClosedLabourRequestStatus(String requestStatus) {
    switch (requestStatus.trim().toUpperCase()) {
      case 'CANCELLED':
      case 'EXPIRED':
      case 'REJECTED':
        return true;
      default:
        return false;
    }
  }

  Future<void> _showLabourRequestStateDialog({
    required _RemoteLabourBookingResult request,
    _RemoteLabourBookingRequestStatus? status,
    bool isGroupRequest = false,
    int requestedCount = 1,
  }) async {
    final normalized =
        status?.requestStatus.trim().toUpperCase() ??
        request.requestStatus.trim().toUpperCase();
    final title = normalized == 'OPEN'
        ? 'Still waiting'
        : 'Booking request update';
    final acceptedCount = status?.acceptedProviderCount ?? 0;
    final message = isGroupRequest
        ? switch (acceptedCount) {
            <= 0 =>
              'No labour accepted your booking yet. Please try again, or choose another labour type available near you.',
            _ =>
              'Only $acceptedCount of $requestedCount labour accepted your booking. You can make payment to confirm the accepted labour, then try again for the remaining requirement.',
          }
        : switch (normalized) {
            'CANCELLED' =>
              'This labour did not accept your request in time. Please select a different labour available near you.',
            'EXPIRED' =>
              'This labour did not accept your request within 45 seconds. Please select a different labour available near you.',
            'REJECTED' =>
              'This labour rejected your booking request. Please select a different labour available near you.',
            _ =>
              'Waiting for labour to accept the booking. Please try again in a moment.',
          };
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<_InvoicePaymentResult<_RemoteLabourBookingPaymentResult>?>
  _showAcceptedLabourInvoiceDialog({
    required _RemoteLabourBookingResult request,
    required _RemoteLabourBookingRequestStatus status,
    required int requestedCount,
    required String categoryLabel,
    String periodLabel = '',
    bool isGroupRequest = false,
  }) {
    final providerName = status.providerName.trim().isNotEmpty
        ? status.providerName
        : request.labourName;
    final acceptedCount = status.acceptedProviderCount <= 0
        ? 1
        : status.acceptedProviderCount;
    final totalAcceptedPriceLabel = isGroupRequest
        ? (status.totalAcceptedQuotedPriceAmount.trim().isNotEmpty
              ? status.totalAcceptedQuotedPriceAmount
              : 'As accepted')
        : status.quotedPriceAmount;
    final bookingChargeLabel = isGroupRequest
        ? (status.totalAcceptedBookingChargeAmount.trim().isNotEmpty
              ? status.totalAcceptedBookingChargeAmount
              : request.quotedPriceAmount)
        : _formatRupee(
            _amountFromLabel(status.quotedPriceAmount) *
                (_amountFromLabel(_labourBookingChargePerLabour) / 100),
          );
    final bookingCode = status.bookingCode.trim().isNotEmpty
        ? status.bookingCode
        : request.requestCode;
    final heading = isGroupRequest ? 'Group labour invoice' : 'Labour invoice';
    final subtitle = isGroupRequest
        ? '$acceptedCount labour accepted'
        : providerName;
    final invoiceMessage = isGroupRequest
        ? acceptedCount < requestedCount
              ? 'Only $acceptedCount of $requestedCount accepted within the payment window. You can confirm these accepted labour now.'
              : 'All requested labour accepted. Please confirm the booking payment.'
        : 'Review the booking fee before opening payment.';
    return _showBookingPaymentInvoice<_RemoteLabourBookingPaymentResult>(
      title: heading,
      subtitle: subtitle,
      message: invoiceMessage,
      note:
          'Labour charge is paid to labour after work confirmation. Only booking fee and any platform fee are charged here.',
      preparePayment: () =>
          _UserAppApi.initiateLabourBookingPayment(status.requestId),
      paymentCode: (payment) => payment.paymentCode,
      paymentTitle: isGroupRequest
          ? 'Confirm group labour booking'
          : 'Confirm labour booking',
      totalLabel: (payment) => payment.amountLabel,
      detailLines: <_PaymentInvoiceLine>[
        _PaymentInvoiceLine(
          label: 'Category',
          value: categoryLabel.trim().isEmpty
              ? 'Labour booking'
              : categoryLabel,
        ),
        if (periodLabel.trim().isNotEmpty)
          _PaymentInvoiceLine(label: 'Booking type', value: periodLabel),
        _PaymentInvoiceLine(label: 'Booking code', value: bookingCode),
        _PaymentInvoiceLine(
          label: isGroupRequest ? 'Accepted labour charge' : 'Labour charge',
          value: totalAcceptedPriceLabel,
        ),
      ],
      chargeLinesBuilder: (payment) => <_PaymentInvoiceLine>[
        _PaymentInvoiceLine(label: 'Booking fee', value: bookingChargeLabel),
        _PaymentInvoiceLine(
          label: 'Platform fee',
          value: _differenceAmountLabel(
            payment.amountLabel,
            bookingChargeLabel,
          ),
        ),
      ],
    );
  }

  Future<void> _startServiceBookingRequestFlow(
    _DiscoveryItem item, {
    int? retryAddressId,
  }) async {
    try {
      int? bookingAddressId = retryAddressId;
      if (bookingAddressId == null) {
        final confirmed = await _confirmBookingLocationUsage(
          bookingLabel: 'service',
        );
        if (!mounted || !confirmed) {
          return;
        }
        bookingAddressId = await _ensureBookingAddressIdForServiceOrLabour(
          bookingLabel: 'service',
        );
      }
      if (bookingAddressId == null) {
        return;
      }
      if (!mounted) {
        return;
      }
      final request = await _UserAppApi.bookServiceDirect(
        item: item,
        addressId: bookingAddressId,
      );
      if (!mounted) {
        return;
      }
      final status = await _waitForServiceAcceptance(
        request,
        retryRequest: () => _UserAppApi.bookServiceDirect(
          item: item,
          addressId: bookingAddressId,
        ),
        candidates: _serviceWaitCandidates(<_DiscoveryItem>[item]),
      );
      if (!mounted) {
        return;
      }
      if (status == null || !status.canMakePayment) {
        await _showServiceRequestStateDialog(request: request, status: status);
        return;
      }
      setState(() {
        _upsertActiveBookingStatus(
          _activeBookingStatusFromServiceRequest(
            request: request,
            status: status,
          ),
        );
      });
      final invoiceResult = await _showAcceptedServiceInvoiceDialog(
        request: request,
        status: status,
      );
      if (!mounted || invoiceResult == null) {
        return;
      }
      final payment = invoiceResult.payment;
      final paymentResult = invoiceResult.paymentFlowResult;
      if (!mounted) {
        return;
      }
      await _hydrateRemoteState(silent: true);
      if (!mounted) {
        return;
      }
      await _PaymentFlow.showOutcome(
        context,
        result: paymentResult,
        successTitle: 'Service booking confirmed',
        failureTitle: 'Service payment incomplete',
        extraLines: [
          'Booking code: ${payment.bookingCode}',
          'Provider: ${status.providerName.trim().isNotEmpty ? status.providerName : request.providerName}',
          'Amount: ${payment.amountLabel}',
        ],
      );
    } on _UserAppApiException catch (error) {
      if (mounted) {
        _showCartSnack(error.message);
      }
    }
  }

  Future<void> _startRandomServiceBookingFlow({int? retryAddressId}) async {
    if (retryAddressId == null) {
      final canContinue = await _ensureAuthenticated();
      if (!mounted) {
        return;
      }
      if (!canContinue) {
        _showCartSnack('Please log in to continue service booking.');
        return;
      }
    }

    final categoryId = _serviceCategoryIdForLabel(_selectedServiceCategory);
    final subcategoryId = _serviceSubcategoryIdForSelection(
      _selectedServiceCategory,
      _selectedServiceSubCategory,
    );
    if (categoryId == null && subcategoryId == null) {
      _showCartSnack('Please choose a service category or subcategory first.');
      return;
    }

    try {
      int? bookingAddressId = retryAddressId;
      if (bookingAddressId == null) {
        final confirmed = await _confirmBookingLocationUsage(
          bookingLabel: 'service',
        );
        if (!mounted || !confirmed) {
          return;
        }
        bookingAddressId = await _ensureBookingAddressIdForServiceOrLabour(
          bookingLabel: 'service',
        );
      }
      if (bookingAddressId == null || !mounted) {
        return;
      }
      final request = await _UserAppApi.bookServiceRandom(
        categoryId: categoryId,
        subcategoryId: subcategoryId,
        serviceName: _selectedServiceBookingLabel,
        addressId: bookingAddressId,
      );
      if (!mounted) {
        return;
      }
      final status = await _waitForServiceAcceptance(
        request,
        candidates: _serviceWaitCandidates(_filteredServiceProviders),
        timeoutSeconds: 45,
        retryRequest: () => _UserAppApi.bookServiceRandom(
          categoryId: categoryId,
          subcategoryId: subcategoryId,
          serviceName: _selectedServiceBookingLabel,
          addressId: bookingAddressId,
        ),
      );
      if (!mounted) {
        return;
      }
      if (status == null || !status.canMakePayment) {
        await _showServiceRequestStateDialog(request: request, status: status);
        return;
      }
      setState(() {
        _upsertActiveBookingStatus(
          _activeBookingStatusFromServiceRequest(
            request: request,
            status: status,
          ),
        );
      });
      final invoiceResult = await _showAcceptedServiceInvoiceDialog(
        request: request,
        status: status,
      );
      if (!mounted || invoiceResult == null) {
        return;
      }
      final payment = invoiceResult.payment;
      final paymentResult = invoiceResult.paymentFlowResult;
      if (!mounted) {
        return;
      }
      await _hydrateRemoteState(silent: true);
      if (!mounted) {
        return;
      }
      await _PaymentFlow.showOutcome(
        context,
        result: paymentResult,
        successTitle: 'Service booking confirmed',
        failureTitle: 'Service payment incomplete',
        extraLines: [
          'Booking code: ${payment.bookingCode}',
          'Provider: ${status.providerName.trim().isNotEmpty ? status.providerName : request.providerName}',
          'Amount: ${payment.amountLabel}',
        ],
      );
    } on _UserAppApiException catch (error) {
      if (mounted) {
        _showCartSnack(error.message);
      }
    }
  }

  Future<int?> _ensureBookingAddressIdForServiceOrLabour({
    required String bookingLabel,
  }) async {
    final selectedLocation = _selectedLocationChoice ?? _currentLocationChoice;
    if (!_isAuthenticated || selectedLocation == null) {
      return selectedLocation?.addressId;
    }
    if (_savedAddresses.isNotEmpty) {
      if (selectedLocation.addressId != null) {
        return selectedLocation.addressId;
      }
      if (_savedAddresses.length == 1) {
        final onlyAddress = _locationChoiceFromAddress(_savedAddresses.first);
        if (mounted) {
          setState(() {
            _selectedLocationChoice = onlyAddress;
          });
        }
        return onlyAddress.addressId;
      }
      final selectedAddress = await _promptSelectSavedAddressForBooking(
        bookingLabel: bookingLabel,
      );
      if (!mounted || selectedAddress == null) {
        return null;
      }
      setState(() {
        _selectedLocationChoice = selectedAddress;
      });
      return selectedAddress.addressId;
    }
    final saved = await _promptAddAddressForBooking(bookingLabel: bookingLabel);
    if (!saved || !mounted) {
      return null;
    }
    final updatedLocation = _selectedLocationChoice ?? _currentLocationChoice;
    return updatedLocation?.addressId;
  }

  Future<_HomeLocationChoice?> _promptSelectSavedAddressForBooking({
    required String bookingLabel,
  }) async {
    var addresses = _savedAddresses;
    if (_isAuthenticated) {
      try {
        final latestAddresses = await _UserAppApi.fetchAddresses();
        if (mounted) {
          setState(() {
            _savedAddresses = latestAddresses;
          });
        } else {
          _savedAddresses = latestAddresses;
        }
        addresses = latestAddresses;
      } catch (_) {
        addresses = _savedAddresses;
      }
    }
    final options = addresses
        .map(_locationChoiceFromAddress)
        .toList(growable: false);
    if (options.isEmpty) {
      return null;
    }
    if (!mounted) {
      return null;
    }
    _HomeLocationChoice? pendingSelection =
        _selectedLocationChoice?.addressId != null
        ? options.cast<_HomeLocationChoice?>().firstWhere(
            (option) => option?.addressId == _selectedLocationChoice?.addressId,
            orElse: () => options.isNotEmpty ? options.first : null,
          )
        : (options.isNotEmpty ? options.first : null);
    final currentPickedLocation =
        _selectedLocationChoice ?? _currentLocationChoice;
    final result = await showModalBottomSheet<Object?>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) => SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.16),
                    blurRadius: 26,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 46,
                        height: 5,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE4D7D0),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Select address for booking',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF22314D),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Choose one of your saved addresses for this $bookingLabel booking.',
                      style: const TextStyle(
                        color: Color(0xFF66748C),
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: options.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final option = options[index];
                          final isSelected =
                              pendingSelection?.addressId != null &&
                              pendingSelection!.addressId == option.addressId;
                          return _HomeLocationOptionTile(
                            option: option,
                            selected: isSelected,
                            onTap: () => setSheetState(() {
                              pendingSelection = option;
                            }),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFD48E78),
                          side: const BorderSide(color: Color(0xFFD48E78)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        onPressed: () => Navigator.of(sheetContext).pop('add'),
                        icon: const Icon(Icons.add_location_alt_rounded),
                        label: const Text(
                          'Add new address',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF22314D),
                              side: const BorderSide(color: Color(0xFFD9CCC5)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            onPressed: () => Navigator.of(sheetContext).pop(),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFFD48E78),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            onPressed: pendingSelection == null
                                ? null
                                : () => Navigator.of(
                                    sheetContext,
                                  ).pop(pendingSelection),
                            child: const Text(
                              'Continue',
                              style: TextStyle(fontWeight: FontWeight.w900),
                            ),
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
      ),
    );
    if (result is _HomeLocationChoice) {
      return result;
    }
    if (result == 'add') {
      final saved = await Navigator.of(context).push<bool>(
        MaterialPageRoute<bool>(
          builder: (_) => _AddressesPage(
            autoOpenEditor: true,
            closeAfterSave: true,
            initialLocationChoice: currentPickedLocation,
          ),
        ),
      );
      if (saved != true || !mounted) {
        return null;
      }
      await _loadHomeLocationOptions();
      await _reloadAddressAwareDiscovery(silent: true);
      final updatedLocation = _selectedLocationChoice ?? _currentLocationChoice;
      if (updatedLocation?.addressId != null) {
        return updatedLocation;
      }
      final refreshedOptions = _savedAddresses
          .map(_locationChoiceFromAddress)
          .toList(growable: false);
      if (refreshedOptions.isEmpty) {
        return null;
      }
      return refreshedOptions.firstWhere(
        (option) =>
            currentPickedLocation != null &&
            (option.latitude - currentPickedLocation.latitude).abs() <
                0.00001 &&
            (option.longitude - currentPickedLocation.longitude).abs() <
                0.00001,
        orElse: () => refreshedOptions.last,
      );
    }
    return null;
  }

  Future<bool> _promptAddAddressForBooking({
    required String bookingLabel,
  }) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.16),
                  blurRadius: 26,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 46,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE4D7D0),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Save address to continue',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF22314D),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Please add a saved address before booking $bookingLabel. Once you save it, we will use that address for the booking.',
                    style: const TextStyle(
                      color: Color(0xFF66748C),
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF22314D),
                            side: const BorderSide(color: Color(0xFFD9CCC5)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          onPressed: () =>
                              Navigator.of(sheetContext).pop('cancel'),
                          child: const Text(
                            'Not now',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFCB6E5B),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          onPressed: () =>
                              Navigator.of(sheetContext).pop('add'),
                          child: const Text(
                            'Add address',
                            style: TextStyle(fontWeight: FontWeight.w900),
                          ),
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
    );
    if (!mounted || action != 'add') {
      return false;
    }
    _markDiscoveryPending();
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            const _AddressesPage(autoOpenEditor: true, closeAfterSave: true),
      ),
    );
    await _loadHomeLocationOptions();
    await _reloadAddressAwareDiscovery(silent: true);
    final updatedLocation = _selectedLocationChoice ?? _currentLocationChoice;
    if (updatedLocation?.addressId != null) {
      return true;
    }
    if (mounted) {
      _showCartSnack(
        'Please add an address to continue booking $bookingLabel.',
      );
    }
    return false;
  }

  Future<bool> _confirmBookingLocationUsage({
    required String bookingLabel,
  }) async {
    var selectedLocation = _selectedLocationChoice ?? _currentLocationChoice;
    if (_isAuthenticated && _savedAddresses.length > 1) {
      final selectedAddress = await _promptSelectSavedAddressForBooking(
        bookingLabel: bookingLabel,
      );
      if (!mounted || selectedAddress == null) {
        return false;
      }
      setState(() {
        _selectedLocationChoice = selectedAddress;
      });
      return true;
    }
    if (_isAuthenticated &&
        _savedAddresses.isNotEmpty &&
        (selectedLocation == null || selectedLocation.addressId == null)) {
      final selectedAddress = await _promptSelectSavedAddressForBooking(
        bookingLabel: bookingLabel,
      );
      if (!mounted || selectedAddress == null) {
        return false;
      }
      setState(() {
        _selectedLocationChoice = selectedAddress;
      });
      return true;
    }
    if (_isAuthenticated && _savedAddresses.isEmpty) {
      return _promptAddAddressForBooking(bookingLabel: bookingLabel);
    }
    if (selectedLocation == null) {
      await _openHomeLocationSelector(showManageAddresses: _isAuthenticated);
      if (!mounted) {
        return false;
      }
      selectedLocation = _selectedLocationChoice ?? _currentLocationChoice;
      if (selectedLocation == null) {
        _showCartSnack(
          'Please choose a location before booking $bookingLabel.',
        );
        return false;
      }
    }

    final locationTitle = selectedLocation.isCurrentLocation
        ? 'Current location'
        : (selectedLocation.title.trim().isEmpty
              ? 'Selected location'
              : selectedLocation.title.trim());
    final locationSubtitle = selectedLocation.subtitle.trim().isEmpty
        ? 'We will use your detected location for this booking.'
        : selectedLocation.subtitle.trim();

    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.16),
                  blurRadius: 26,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 46,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE4D7D0),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Booking at detected location',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF22314D),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'We will use this current location for your $bookingLabel booking. It will not be saved to your address book unless you save it manually.',
                    style: const TextStyle(
                      color: Color(0xFF66748C),
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F3F0),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE6D7CF)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          locationTitle,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF22314D),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          locationSubtitle,
                          style: const TextStyle(
                            color: Color(0xFF66748C),
                            fontWeight: FontWeight.w700,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF22314D),
                            side: const BorderSide(color: Color(0xFFD9CCC5)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          onPressed: () =>
                              Navigator.of(sheetContext).pop('change'),
                          child: const Text(
                            'Change',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFD48E78),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          onPressed: () =>
                              Navigator.of(sheetContext).pop('continue'),
                          child: const Text(
                            'Continue',
                            style: TextStyle(fontWeight: FontWeight.w900),
                          ),
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
    );

    if (!mounted) {
      return false;
    }
    if (action == 'change') {
      await _openHomeLocationSelector(showManageAddresses: _isAuthenticated);
      if (!mounted) {
        return false;
      }
      final updatedLocation = _selectedLocationChoice ?? _currentLocationChoice;
      if (updatedLocation == null) {
        return false;
      }
      if (updatedLocation.addressId == selectedLocation.addressId &&
          updatedLocation.latitude == selectedLocation.latitude &&
          updatedLocation.longitude == selectedLocation.longitude &&
          updatedLocation.title == selectedLocation.title &&
          updatedLocation.subtitle == selectedLocation.subtitle) {
        return false;
      }
      return _confirmBookingLocationUsage(bookingLabel: bookingLabel);
    }
    return action == 'continue';
  }

  Future<_RemoteServiceBookingRequestStatus?> _waitForServiceAcceptance(
    _RemoteServiceBookingResult request, {
    List<_BookingWaitCandidate> candidates = const <_BookingWaitCandidate>[],
    int timeoutSeconds = 45,
    Future<_RemoteServiceBookingResult> Function()? retryRequest,
  }) async {
    var currentRequest = request;
    final remainingSeconds = ValueNotifier<int>(timeoutSeconds);
    final snapshot = ValueNotifier<_BookingWaitSnapshot>(
      _BookingWaitSnapshot(
        title: currentRequest.isBroadcast
            ? 'Waiting for a provider to accept'
            : 'Waiting for provider to accept',
        message: currentRequest.isBroadcast
            ? ''
            : '${currentRequest.providerName} has received your service booking request.',
      ),
    );
    Completer<_BookingWaitAction> actionCompleter =
        Completer<_BookingWaitAction>();
    _BookingWaitAction? selectedAction;
    void completeAction(_BookingWaitAction action) {
      selectedAction ??= action;
      if (!actionCompleter.isCompleted) {
        actionCompleter.complete(action);
      }
    }

    void resetWaitingState() {
      snapshot.value = _BookingWaitSnapshot(
        title: currentRequest.isBroadcast
            ? 'Waiting for a provider to accept'
            : 'Waiting for provider to accept',
        message: currentRequest.isBroadcast
            ? ''
            : '${currentRequest.providerName} has received your service booking request.',
      );
      selectedAction = null;
      actionCompleter = Completer<_BookingWaitAction>();
    }

    var dialogVisible = true;
    var deadline = DateTime.now().add(Duration(seconds: timeoutSeconds));
    Timer? timer;
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final remaining = deadline.difference(DateTime.now()).inSeconds + 1;
      remainingSeconds.value = remaining.clamp(0, timeoutSeconds);
      if (remainingSeconds.value <= 0) {
        snapshot.value = snapshot.value.copyWith(
          timedOut: true,
          title: 'No acceptance yet',
          message:
              'You can retry with matching providers or cancel this request.',
        );
        timer?.cancel();
      }
    });
    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => PopScope(
          canPop: false,
          child: _BookingRequestWaitSheet(
            candidates: candidates,
            center: _bookingWaitCenter(),
            remainingSeconds: remainingSeconds,
            totalSeconds: timeoutSeconds,
            snapshot: snapshot,
            showAcceptedProvidersList: false,
            accent: const Color(0xFFE36C93),
            onCancel: () {
              completeAction(_BookingWaitAction.cancel);
              dialogVisible = false;
              Navigator.of(dialogContext).pop();
            },
            onPay: () {
              completeAction(_BookingWaitAction.pay);
              dialogVisible = false;
              Navigator.of(dialogContext).pop();
            },
            onRetry: () {
              completeAction(_BookingWaitAction.retry);
            },
          ),
        ),
      ).whenComplete(() => dialogVisible = false),
    );
    await Future<void>.delayed(Duration.zero);

    _RemoteServiceBookingRequestStatus? status;
    try {
      retryLoop:
      while (true) {
        deadline = DateTime.now().add(Duration(seconds: timeoutSeconds));
        remainingSeconds.value = timeoutSeconds;
        resetWaitingState();
        status = null;
        final maxAttempts = (timeoutSeconds / 3).ceil();
        for (int attempt = 0; attempt < maxAttempts; attempt++) {
          if (selectedAction == _BookingWaitAction.cancel) {
            await _UserAppApi.cancelServiceBookingRequest(
              currentRequest.requestId,
              reason:
                  'You cancelled this service request while we were still finding a matching provider.',
            );
            status = await _UserAppApi.fetchServiceBookingRequestStatus(
              currentRequest.requestId,
            );
            return status;
          }
          status = await _UserAppApi.fetchServiceBookingRequestStatus(
            currentRequest.requestId,
          );
          snapshot.value = snapshot.value.copyWith(
            accepted: status.canMakePayment,
            acceptedProviders: status.acceptedProviders,
            title: status.canMakePayment ? 'Provider accepted' : null,
            message: status.canMakePayment
                ? 'Tap Go to payment to continue this service booking.'
                : null,
          );
          if (status.canMakePayment ||
              _isClosedServiceRequestStatus(status.requestStatus)) {
            break;
          }
          await Future<void>.delayed(const Duration(seconds: 3));
        }
        if (status != null && status.canMakePayment) {
          timer.cancel();
          final action = await actionCompleter.future;
          if (action == _BookingWaitAction.retry && retryRequest != null) {
            currentRequest = await retryRequest();
            continue retryLoop;
          }
          return status;
        }
        snapshot.value = snapshot.value.copyWith(
          timedOut: true,
          title: 'No acceptance yet',
          message:
              'You can retry with matching providers or cancel this request.',
        );
        final action = await actionCompleter.future;
        if (action == _BookingWaitAction.retry) {
          await _UserAppApi.cancelServiceBookingRequest(
            currentRequest.requestId,
            reason:
                'You retried this service request after no provider accepted in time.',
          );
          if (retryRequest != null) {
            currentRequest = await retryRequest();
            continue;
          }
          return null;
        } else if (action == _BookingWaitAction.cancel) {
          await _UserAppApi.cancelServiceBookingRequest(
            currentRequest.requestId,
            reason:
                'You cancelled this service request after no provider accepted in time.',
          );
          status = await _UserAppApi.fetchServiceBookingRequestStatus(
            currentRequest.requestId,
          );
        }
        return status;
      }
    } finally {
      timer.cancel();
      remainingSeconds.dispose();
      snapshot.dispose();
      if (mounted) {
        final navigator = Navigator.of(context, rootNavigator: true);
        if (dialogVisible && navigator.canPop()) {
          navigator.pop();
        }
      }
    }
  }

  bool _isClosedServiceRequestStatus(String requestStatus) {
    switch (requestStatus.trim().toUpperCase()) {
      case 'CANCELLED':
      case 'EXPIRED':
      case 'REJECTED':
        return true;
      default:
        return false;
    }
  }

  Future<void> _showServiceRequestStateDialog({
    required _RemoteServiceBookingResult request,
    _RemoteServiceBookingRequestStatus? status,
  }) async {
    final normalized =
        status?.requestStatus.trim().toUpperCase() ??
        request.requestStatus.trim().toUpperCase();
    final title = normalized == 'OPEN'
        ? 'Still waiting'
        : 'Booking request update';
    final message = switch (normalized) {
      'CANCELLED' =>
        request.isBroadcast
            ? 'No matching provider accepted your service booking request.'
            : 'No provider accepted your service booking request.',
      'EXPIRED' =>
        request.isBroadcast
            ? 'This request timed out before any matching provider accepted it.'
            : 'This service booking request timed out before any provider accepted it.',
      'REJECTED' => 'The service provider rejected this booking request.',
      _ =>
        request.isBroadcast
            ? 'Waiting for a matching provider to accept the booking. Please try again in a moment.'
            : 'Waiting for the provider to accept the booking. Please try again in a moment.',
    };
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<_InvoicePaymentResult<_RemoteServiceBookingPaymentResult>?>
  _showAcceptedServiceInvoiceDialog({
    required _RemoteServiceBookingResult request,
    required _RemoteServiceBookingRequestStatus status,
  }) {
    final providerName = status.providerName.trim().isNotEmpty
        ? status.providerName
        : request.providerName;
    return _showBookingPaymentInvoice<_RemoteServiceBookingPaymentResult>(
      title: 'Service invoice',
      subtitle: providerName,
      message: 'Please review the service visit amount before payment.',
      preparePayment: () =>
          _UserAppApi.initiateServiceBookingPayment(status.requestId),
      paymentCode: (payment) => payment.paymentCode,
      paymentTitle: 'Confirm service booking',
      totalLabel: (payment) => payment.amountLabel,
      detailLines: <_PaymentInvoiceLine>[
        _PaymentInvoiceLine(
          label: 'Category',
          value: request.serviceName.trim().isEmpty
              ? 'Service booking'
              : request.serviceName,
        ),
        _PaymentInvoiceLine(
          label: 'Booking code',
          value: status.bookingCode.trim().isNotEmpty
              ? status.bookingCode
              : request.requestCode,
        ),
      ],
      chargeLinesBuilder: (payment) => <_PaymentInvoiceLine>[
        _PaymentInvoiceLine(
          label: 'Visiting fee',
          value: status.quotedPriceAmount,
        ),
        _PaymentInvoiceLine(
          label: 'Platform fee',
          value: _differenceAmountLabel(
            payment.amountLabel,
            status.quotedPriceAmount,
          ),
        ),
      ],
    );
  }

  Future<_InvoicePaymentResult<_RemoteServiceBookingPaymentResult>?>
  _showActiveServiceInvoiceDialog({required _ActiveBookingStatus status}) {
    final categoryLabel = status.categoryLabel.trim().isNotEmpty
        ? status.categoryLabel.trim()
        : (status.subcategoryLabel.trim().isNotEmpty
              ? status.subcategoryLabel.trim()
              : 'Service booking');
    return _showBookingPaymentInvoice<_RemoteServiceBookingPaymentResult>(
      title: 'Service invoice',
      subtitle: status.providerName.trim().isEmpty
          ? 'Service provider'
          : status.providerName,
      message: 'Please review the service visit amount before payment.',
      preparePayment: () =>
          _UserAppApi.initiateServiceBookingPayment(status.requestId),
      paymentCode: (payment) => payment.paymentCode,
      paymentTitle: 'Confirm service booking',
      totalLabel: (payment) => payment.amountLabel,
      detailLines: <_PaymentInvoiceLine>[
        _PaymentInvoiceLine(label: 'Category', value: categoryLabel),
        _PaymentInvoiceLine(label: 'Booking code', value: status.bookingCode),
      ],
      chargeLinesBuilder: (payment) => <_PaymentInvoiceLine>[
        _PaymentInvoiceLine(
          label: 'Visiting fee',
          value: status.quotedPriceAmount,
        ),
        _PaymentInvoiceLine(
          label: 'Platform fee',
          value: _differenceAmountLabel(
            payment.amountLabel,
            status.quotedPriceAmount,
          ),
        ),
      ],
    );
  }

  Future<_InvoicePaymentResult<_RemoteLabourBookingPaymentResult>?>
  _showActiveLabourInvoiceDialog({required _ActiveBookingStatus status}) {
    final categoryLabel = status.categoryLabel.trim().isNotEmpty
        ? status.categoryLabel.trim()
        : 'Labour booking';
    final periodLabel = status.labourPricingModel.trim();
    final labourAmountLabel =
        status.totalAcceptedQuotedPriceAmount.trim().isNotEmpty
        ? status.totalAcceptedQuotedPriceAmount.trim()
        : status.quotedPriceAmount.trim();
    final bookingFeeLabel =
        status.totalAcceptedBookingChargeAmount.trim().isNotEmpty
        ? status.totalAcceptedBookingChargeAmount.trim()
        : _formatRupee(
            _amountFromLabel(status.quotedPriceAmount) *
                (_amountFromLabel(_labourBookingChargePerLabour) / 100),
          );
    return _showBookingPaymentInvoice<_RemoteLabourBookingPaymentResult>(
      title: 'Labour invoice',
      subtitle: status.providerName.trim().isEmpty
          ? 'Accepted labour'
          : status.providerName,
      message: 'Review the booking fee before opening payment.',
      note:
          'Labour charge is paid to labour after work confirmation. Only booking fee and any platform fee are charged here.',
      preparePayment: () =>
          _UserAppApi.initiateLabourBookingPayment(status.requestId),
      paymentCode: (payment) => payment.paymentCode,
      paymentTitle: 'Confirm labour booking',
      totalLabel: (payment) => payment.amountLabel,
      detailLines: <_PaymentInvoiceLine>[
        _PaymentInvoiceLine(label: 'Category', value: categoryLabel),
        if (periodLabel.isNotEmpty)
          _PaymentInvoiceLine(label: 'Booking type', value: periodLabel),
        _PaymentInvoiceLine(label: 'Booking code', value: status.bookingCode),
        _PaymentInvoiceLine(
          label: 'Labour charge',
          value: labourAmountLabel.trim().isEmpty ? '-' : labourAmountLabel,
        ),
      ],
      chargeLinesBuilder: (payment) => <_PaymentInvoiceLine>[
        _PaymentInvoiceLine(label: 'Booking fee', value: bookingFeeLabel),
        _PaymentInvoiceLine(
          label: 'Platform fee',
          value: _differenceAmountLabel(payment.amountLabel, bookingFeeLabel),
        ),
      ],
    );
  }

  Future<_InvoicePaymentResult<T>?> _showBookingPaymentInvoice<T>({
    required String title,
    required String subtitle,
    String message = '',
    String note = '',
    required Future<T> Function() preparePayment,
    required String Function(T payment) paymentCode,
    required String paymentTitle,
    required String Function(T payment) totalLabel,
    required List<_PaymentInvoiceLine> detailLines,
    required List<_PaymentInvoiceLine> Function(T payment) chargeLinesBuilder,
  }) {
    var activeFuture = preparePayment();
    String? paymentLaunchError;
    bool startingPayment = false;
    return showDialog<_InvoicePaymentResult<T>?>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => PopScope(
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
                child: FutureBuilder<T>(
                  future: activeFuture,
                  builder: (invoiceContext, snapshot) {
                    return Column(
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
                            padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                            child:
                                snapshot.connectionState != ConnectionState.done
                                ? _buildInvoiceLoadingView(
                                    title: title,
                                    subtitle: subtitle,
                                    onClose: () =>
                                        Navigator.of(dialogContext).pop(),
                                  )
                                : snapshot.hasError || !snapshot.hasData
                                ? _buildInvoiceErrorView(
                                    title: title,
                                    subtitle: subtitle,
                                    message:
                                        snapshot.error is _UserAppApiException
                                        ? (snapshot.error
                                                  as _UserAppApiException)
                                              .message
                                        : 'Unable to prepare the payment invoice right now.',
                                    onClose: () =>
                                        Navigator.of(dialogContext).pop(),
                                    onRetry: () {
                                      setDialogState(() {
                                        paymentLaunchError = null;
                                        startingPayment = false;
                                        activeFuture = preparePayment();
                                      });
                                    },
                                  )
                                : _buildInvoiceReadyView(
                                    dialogContext: dialogContext,
                                    title: title,
                                    subtitle: subtitle,
                                    message: message,
                                    note: note,
                                    payableLabel: totalLabel(
                                      snapshot.data as T,
                                    ),
                                    detailLines: detailLines,
                                    chargeLines: chargeLinesBuilder(
                                      snapshot.data as T,
                                    ),
                                    paymentButtonLabel:
                                        paymentLaunchError == null
                                        ? 'Payment'
                                        : 'Retry',
                                    paymentErrorMessage: paymentLaunchError,
                                    startingPayment: startingPayment,
                                    onPay: () async {
                                      if (startingPayment) {
                                        return;
                                      }
                                      setDialogState(() {
                                        startingPayment = true;
                                        paymentLaunchError = null;
                                      });
                                      final payment = snapshot.data as T;
                                      try {
                                        final paymentFlowResult =
                                            await _PaymentFlow.start(
                                              context,
                                              paymentCode: paymentCode(payment),
                                              title: paymentTitle,
                                            );
                                        if (!mounted) {
                                          return;
                                        }
                                        Navigator.of(dialogContext).pop(
                                          _InvoicePaymentResult<T>(
                                            payment: payment,
                                            paymentFlowResult:
                                                paymentFlowResult,
                                          ),
                                        );
                                      } on _UserAppApiException catch (error) {
                                        setDialogState(() {
                                          startingPayment = false;
                                          paymentLaunchError = error.message;
                                        });
                                      } catch (_) {
                                        setDialogState(() {
                                          startingPayment = false;
                                          paymentLaunchError =
                                              'Payment could not be started right now. Please try again.';
                                        });
                                      }
                                    },
                                  ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInvoiceLoadingView({
    required String title,
    required String subtitle,
    required VoidCallback onClose,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInvoiceHeader(title: title, subtitle: subtitle),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Text(
                'Opening payment details',
                style: const TextStyle(
                  color: Color(0xFF22314D),
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            IconButton(
              onPressed: onClose,
              icon: const Icon(Icons.close_rounded),
              color: const Color(0xFF6A7587),
            ),
          ],
        ),
        const SizedBox(height: 6),
        const Text(
          'Please wait while we prepare the payment breakup.',
          style: TextStyle(
            color: Color(0xFF66748C),
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 18),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInvoiceLoadingCard(lines: 4),
                const SizedBox(height: 14),
                _buildInvoiceLoadingCard(lines: 3),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF6EE),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: const Color(0xFFF0D5BF)),
                  ),
                  child: const Row(
                    children: [
                      Expanded(child: _LoadingSheenBox(height: 16, width: 110)),
                      SizedBox(width: 12),
                      _LoadingSheenBox(height: 22, width: 92),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: onClose,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: const Text('Close'),
          ),
        ),
      ],
    );
  }

  Widget _buildInvoiceErrorView({
    required String title,
    required String subtitle,
    required String message,
    required VoidCallback onClose,
    required VoidCallback onRetry,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInvoiceHeader(title: title, subtitle: subtitle),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: Text(
                'Payment details unavailable',
                style: const TextStyle(
                  color: Color(0xFF22314D),
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            IconButton(
              onPressed: onClose,
              icon: const Icon(Icons.close_rounded),
              color: const Color(0xFF6A7587),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          message,
          style: const TextStyle(
            color: Color(0xFF526071),
            fontWeight: FontWeight.w700,
            height: 1.4,
          ),
        ),
        const Spacer(),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onClose,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: const Text('Close'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: onRetry,
                child: const Text('Retry'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInvoiceReadyView({
    required BuildContext dialogContext,
    required String title,
    required String subtitle,
    required String message,
    required String note,
    required String payableLabel,
    required List<_PaymentInvoiceLine> detailLines,
    required List<_PaymentInvoiceLine> chargeLines,
    required String paymentButtonLabel,
    required String? paymentErrorMessage,
    required bool startingPayment,
    required Future<void> Function() onPay,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildInvoiceHeader(title: title, subtitle: subtitle),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              icon: const Icon(Icons.close_rounded),
              color: const Color(0xFF6A7587),
            ),
          ],
        ),
        if (message.trim().isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              color: Color(0xFF526071),
              fontWeight: FontWeight.w700,
              height: 1.4,
            ),
          ),
        ],
        if (paymentErrorMessage != null &&
            paymentErrorMessage.trim().isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            paymentErrorMessage,
            style: const TextStyle(
              color: Color(0xFFB84B4B),
              fontWeight: FontWeight.w800,
              height: 1.35,
            ),
          ),
        ],
        const SizedBox(height: 18),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInvoiceSection(
                  title: 'Booking details',
                  lines: detailLines,
                ),
                const SizedBox(height: 14),
                _buildInvoiceSection(title: 'Payable now', lines: chargeLines),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF6EE),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: const Color(0xFFF0D5BF)),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Amount to pay',
                          style: TextStyle(
                            color: Color(0xFF22314D),
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      Text(
                        payableLabel,
                        style: const TextStyle(
                          color: Color(0xFFCB6E5B),
                          fontSize: 21,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                if (note.trim().isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Text(
                    note,
                    style: const TextStyle(
                      color: Color(0xFF6A7587),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: const Text('Later'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: startingPayment ? null : onPay,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFCB6E5B),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: Text(paymentButtonLabel),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInvoiceLoadingCard({required int lines}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE8E2DA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _LoadingSheenBox(height: 18, width: 132),
          const SizedBox(height: 14),
          for (var index = 0; index < lines; index++) ...[
            Row(
              children: [
                const Expanded(child: _LoadingSheenBox(height: 14)),
                const SizedBox(width: 14),
                _LoadingSheenBox(height: 14, width: index.isEven ? 96 : 74),
              ],
            ),
            if (index < lines - 1) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  Widget _buildInvoiceHeader({
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF2E6), Color(0xFFFFF8EF), Color(0xFFFFF2E6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF22314D),
              fontSize: 23,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (subtitle.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: const TextStyle(
                color: Color(0xFFCB6E5B),
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInvoiceSection({
    required String title,
    required List<_PaymentInvoiceLine> lines,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE8E2DA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF22314D),
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          for (var index = 0; index < lines.length; index++) ...[
            if (index > 0) const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    lines[index].label,
                    style: const TextStyle(
                      color: Color(0xFF6A7587),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    lines[index].value,
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      color: const Color(0xFF22314D),
                      fontWeight: FontWeight.w900,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _differenceAmountLabel(String totalLabel, String componentLabel) {
    final difference =
        _amountFromLabel(totalLabel) - _amountFromLabel(componentLabel);
    return _formatRupee(difference > 0 ? difference : 0);
  }

  bool _isWishlisted(_DiscoveryItem item) =>
      _wishlistedItems.contains('${item.subtitle}:${item.title}');

  bool _isFavourited(_DiscoveryItem item) =>
      _favouriteProfiles.contains(item.title);

  void _toggleWishlist(_DiscoveryItem item) {
    final key = '${item.subtitle}:${item.title}';
    setState(() {
      if (_wishlistedItems.contains(key)) {
        _wishlistedItems.remove(key);
      } else {
        _wishlistedItems.add(key);
      }
    });
  }

  void _toggleFavourite(_DiscoveryItem item) {
    setState(() {
      if (_favouriteProfiles.contains(item.title)) {
        _favouriteProfiles.remove(item.title);
      } else {
        _favouriteProfiles.add(item.title);
      }
    });
  }

  Future<bool> _handleShopCartAdd(
    _DiscoveryItem item, {
    bool openCartAfterAdd = false,
  }) async {
    if (item.isDisabled) {
      _showCartSnack(
        item.disabledLabel.trim().isEmpty
            ? '${item.subtitle} is unavailable right now.'
            : '${item.subtitle} is ${item.disabledLabel.toLowerCase()} right now.',
      );
      return false;
    }
    final shopName = item.subtitle;
    final category = _shopCategoryForItem(item);
    if (_isAuthenticated && item.backendProductId != null) {
      try {
        final remoteCart = await _UserAppApi.addItemToCart(item);
        if (!mounted) {
          return false;
        }
        setState(() {
          _cartShopName = remoteCart.shopName;
          _cartItems
            ..clear()
            ..addAll(remoteCart.items);
          _localCartNeedsSync = false;
        });
        _showCartSnack(
          '${item.title} added to cart from ${remoteCart.shopName}.',
        );
        if (openCartAfterAdd) {
          unawaited(_openCartPage());
        }
        return true;
      } on _UserAppApiException catch (error) {
        if (mounted) {
          _showCartSnack(error.message);
        }
        return false;
      } catch (_) {
        if (mounted) {
          _showCartSnack('Could not add ${item.title} right now.');
        }
        return false;
      }
    }
    if (_isShopItemOutOfStock(item)) {
      _showCartSnack('${item.title} is out of stock right now.');
      return false;
    }
    final shopTiming = _shopTimingFor(shopName, category);
    if (!shopTiming.acceptsOrders) {
      _showCartSnack(
        shopTiming.isOpen
            ? '$shopName has stopped receiving orders for today.'
            : '$shopName is closed right now.',
      );
      return false;
    }
    if (_cartShopName == null || _cartShopName == shopName) {
      setState(() {
        _cartShopName = shopName;
        _cartItems.add(item);
        if (item.backendProductId != null) {
          _localCartNeedsSync = true;
        }
      });
      _showCartSnack('${item.title} added to cart from $shopName.');
      if (openCartAfterAdd) {
        _openCartPage();
      }
      return true;
    }

    final replace = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Replace existing cart?'),
          content: Text(
            'Your current cart has items from $_cartShopName. If you continue, existing items will be removed and ${item.title} from $shopName will be added.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('No'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFCB6E5B),
                foregroundColor: Colors.white,
              ),
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );

    if (replace == true) {
      setState(() {
        _cartShopName = shopName;
        _cartItems
          ..clear()
          ..add(item);
        _localCartNeedsSync = item.backendProductId != null;
      });
      _showCartSnack('Cart replaced. ${item.title} added from $shopName.');
      if (openCartAfterAdd) {
        _openCartPage();
      }
      return true;
    }
    return false;
  }

  void _showCartSnack(String message) {
    if (_looksLikeExpiredSessionMessage(message)) {
      unawaited(_clearExpiredSessionAndReset());
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _clearExpiredSessionAndReset() async {
    if (_clearingExpiredSession) {
      return;
    }
    _clearingExpiredSession = true;
    try {
      try {
        await _NotificationBootstrap.deactivateCurrentToken();
      } catch (_) {
        // Ignore token cleanup failures when the session is already invalid.
      }
      await _LocalSessionStore.clear();
      if (!mounted) {
        return;
      }
      setState(() {
        _sessionPhoneNumber = null;
        _headerProfilePhotoDataUri = '';
        _headerProfilePhotoObjectKey = '';
        _cachedUserProfile = null;
        _notificationUnreadCount = 0;
        _savedAddresses = const <_UserAddressData>[];
        _activeBookingStatuses = const <_ActiveBookingStatus>[];
        _activeBookingIndex = 0;
        _activeBookingPopupPositionInitialized = false;
      });
      final messenger = ScaffoldMessenger.of(context);
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        const SnackBar(content: Text('Session expired. Please login again.')),
      );
    } finally {
      _clearingExpiredSession = false;
    }
  }
}

class _ActiveBookingAvatar extends StatelessWidget {
  const _ActiveBookingAvatar({required this.status, required this.size});

  final _ActiveBookingStatus status;
  final double size;

  @override
  Widget build(BuildContext context) {
    final imageUrl = status.providerPhotoUrl.trim();
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.32)),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl.isEmpty
          ? Icon(Icons.person_rounded, color: Colors.white, size: size * 0.58)
          : Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Icon(
                Icons.person_rounded,
                color: Colors.white,
                size: size * 0.58,
              ),
            ),
    );
  }
}

class _ActiveBookingsOverviewPage extends StatelessWidget {
  const _ActiveBookingsOverviewPage({
    required this.statuses,
    required this.statusLabelBuilder,
    required this.paymentLabelBuilder,
    required this.titleBuilder,
    required this.onOpenDetails,
  });

  final List<_ActiveBookingStatus> statuses;
  final String Function(_ActiveBookingStatus status) statusLabelBuilder;
  final String Function(_ActiveBookingStatus status) paymentLabelBuilder;
  final String Function(_ActiveBookingStatus status) titleBuilder;
  final Future<void> Function(_ActiveBookingStatus status) onOpenDetails;

  Future<void> _handleOpenDetails(
    BuildContext context,
    _ActiveBookingStatus status,
  ) async {
    Navigator.of(context).pop();
    await onOpenDetails(status);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F2EC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F2EC),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF22314D)),
        ),
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Live bookings',
              style: TextStyle(
                color: Color(0xFF22314D),
                fontWeight: FontWeight.w900,
                fontSize: 20,
              ),
            ),
            Text(
              '${statuses.length} booking${statuses.length == 1 ? '' : 's'} active right now',
              style: const TextStyle(
                color: Color(0xFF6B7487),
                fontWeight: FontWeight.w700,
                fontSize: 12.4,
              ),
            ),
          ],
        ),
      ),
      body: statuses.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No live bookings right now.',
                  style: TextStyle(
                    color: Color(0xFF5F6E85),
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
              itemCount: statuses.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final activeStatus = statuses[index];
                return _ActiveBookingOverviewCard(
                  key: ValueKey<int>(activeStatus.requestId),
                  status: activeStatus,
                  statusLabel: statusLabelBuilder(activeStatus),
                  paymentLabel: paymentLabelBuilder(activeStatus),
                  title: activeStatus.providerName.trim().isNotEmpty
                      ? activeStatus.providerName
                      : titleBuilder(activeStatus),
                  onOpenDetails: () =>
                      unawaited(_handleOpenDetails(context, activeStatus)),
                );
              },
            ),
    );
  }
}

class _ActiveBookingOverviewCard extends StatefulWidget {
  const _ActiveBookingOverviewCard({
    super.key,
    required this.status,
    required this.title,
    required this.statusLabel,
    required this.paymentLabel,
    this.onOpenDetails,
    this.selected = false,
    this.initiallyExpanded = false,
    this.onExpansionChanged,
    this.showOpenDetailsButton = true,
  });

  final _ActiveBookingStatus status;
  final String title;
  final String statusLabel;
  final String paymentLabel;
  final VoidCallback? onOpenDetails;
  final bool selected;
  final bool initiallyExpanded;
  final ValueChanged<bool>? onExpansionChanged;
  final bool showOpenDetailsButton;

  @override
  State<_ActiveBookingOverviewCard> createState() =>
      _ActiveBookingOverviewCardState();
}

class _ActiveBookingOverviewCardState
    extends State<_ActiveBookingOverviewCard> {
  Color _paymentColor(String label) {
    switch (label.trim().toUpperCase()) {
      case 'PAID':
        return const Color(0xFF177245);
      case 'FAILED':
        return const Color(0xFFB84B4B);
      case 'REFUNDED':
        return const Color(0xFF8552D8);
      default:
        return const Color(0xFFC67A1F);
    }
  }

  String _bookingTypeLabel(_ActiveBookingStatus status) {
    return status.bookingType.trim().toUpperCase() == 'SERVICE'
        ? 'Service'
        : 'Labour';
  }

  String _providerLabel(_ActiveBookingStatus status) {
    return status.bookingType.trim().toUpperCase() == 'SERVICE'
        ? 'Servicemen'
        : 'Labour';
  }

  String _bookingAmountLabel(_ActiveBookingStatus status) {
    final total = status.totalAcceptedQuotedPriceAmount.trim();
    if (total.isNotEmpty) {
      return total;
    }
    final quoted = status.quotedPriceAmount.trim();
    if (quoted.isNotEmpty) {
      return quoted;
    }
    return '-';
  }

  String _categoryLabel(_ActiveBookingStatus status) {
    final category = status.categoryLabel.trim();
    final subcategory = status.subcategoryLabel.trim();
    if (category.isNotEmpty) {
      return category;
    }
    if (subcategory.isNotEmpty) {
      return subcategory;
    }
    return _bookingTypeLabel(status);
  }

  String _subcategoryLabel(_ActiveBookingStatus status) {
    final category = status.categoryLabel.trim();
    final subcategory = status.subcategoryLabel.trim();
    if (subcategory.isEmpty) {
      return '';
    }
    if (subcategory == category) {
      return '';
    }
    return subcategory;
  }

  bool _canDialPhone(String phone) {
    final trimmed = phone.trim();
    if (trimmed.isEmpty ||
        trimmed.contains('*') ||
        trimmed.toLowerCase().contains('x')) {
      return false;
    }
    final digits = trimmed.replaceAll(RegExp(r'[^0-9+]'), '');
    return digits.replaceAll('+', '').length >= 7;
  }

  Future<void> _callProviderPhone(String phone) async {
    final digits = phone.trim().replaceAll(RegExp(r'[^0-9+]'), '');
    if (digits.isEmpty) {
      return;
    }
    await launchUrl(
      Uri(scheme: 'tel', path: digits),
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.status;
    final amountLabel = _bookingAmountLabel(status);
    final paymentColor = _paymentColor(widget.paymentLabel);
    final providerLabel = _providerLabel(status);
    final categoryLabel = _categoryLabel(status);
    final subcategoryLabel = _subcategoryLabel(status);
    final canDialPhone = _canDialPhone(status.providerPhone);
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF6D8D1), Color(0xFFFFF2D8), Color(0xFFFFFFFF)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: widget.selected
              ? const Color(0xFFD48E78)
              : const Color(0xFFE7D8D0),
          width: widget.selected ? 1.3 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0x161F2430),
            blurRadius: 18,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    status.bookingCode.trim().isNotEmpty
                        ? status.bookingCode
                        : status.requestCode,
                    style: const TextStyle(
                      color: Color(0xFFBE6F5D),
                      fontWeight: FontWeight.w900,
                      fontSize: 12.4,
                      letterSpacing: 0.28,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  widget.paymentLabel,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    color: paymentColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 11.8,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 11),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.96),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFF0E1D9)),
              ),
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
                              providerLabel,
                              style: const TextStyle(
                                color: Color(0xFF6E7A8E),
                                fontWeight: FontWeight.w600,
                                fontSize: 11.8,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF22314D),
                                fontWeight: FontWeight.w600,
                                fontSize: 14.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      _ActiveBookingAvatar(status: status, size: 40),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'Amount',
                            style: TextStyle(
                              color: Color(0xFF6E7A8E),
                              fontWeight: FontWeight.w800,
                              fontSize: 11.4,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            amountLabel,
                            textAlign: TextAlign.end,
                            style: TextStyle(
                              color: status.canMakePayment
                                  ? const Color(0xFFC67A1F)
                                  : const Color(0xFF177245),
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              categoryLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF22314D),
                                fontWeight: FontWeight.w700,
                                fontSize: 14.2,
                              ),
                            ),
                            if (subcategoryLabel.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                subcategoryLabel,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFF7D889A),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11.8,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Mobile',
                            style: TextStyle(
                              color: canDialPhone
                                  ? const Color(0xFFBE6F5D)
                                  : const Color(0xFF8D8A86),
                              fontWeight: FontWeight.w700,
                              fontSize: 11.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          InkWell(
                            onTap: canDialPhone
                                ? () => unawaited(
                                    _callProviderPhone(status.providerPhone),
                                  )
                                : null,
                            borderRadius: BorderRadius.circular(999),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: canDialPhone
                                    ? const Color(0xFFFFF5F2)
                                    : const Color(0xFFF7F3F0),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: canDialPhone
                                      ? const Color(0xFFE8B7AA)
                                      : const Color(0xFFE6D9D1),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (canDialPhone) ...[
                                    const Icon(
                                      Icons.call_rounded,
                                      size: 13,
                                      color: Color(0xFFBE6F5D),
                                    ),
                                    const SizedBox(width: 4),
                                  ],
                                  Text(
                                    status.providerPhone.trim().isEmpty
                                        ? '-'
                                        : status.providerPhone.trim(),
                                    style: TextStyle(
                                      color: canDialPhone
                                          ? const Color(0xFF22314D)
                                          : const Color(0xFF7D889A),
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (widget.showOpenDetailsButton) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: widget.onOpenDetails,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFD48E78),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                  icon: const Icon(Icons.open_in_new_rounded, size: 18),
                  label: const Text(
                    'Open details',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BookingWaitCandidate {
  const _BookingWaitCandidate({
    required this.label,
    required this.priceLabel,
    required this.location,
    required this.color,
  });

  final String label;
  final String priceLabel;
  final LatLng location;
  final Color color;
}

class _BookingWaitSnapshot {
  const _BookingWaitSnapshot({
    required this.title,
    required this.message,
    this.accepted = false,
    this.timedOut = false,
    this.acceptedProviders = const <_RemoteAcceptedProvider>[],
  });

  final String title;
  final String message;
  final bool accepted;
  final bool timedOut;
  final List<_RemoteAcceptedProvider> acceptedProviders;

  _BookingWaitSnapshot copyWith({
    String? title,
    String? message,
    bool? accepted,
    bool? timedOut,
    List<_RemoteAcceptedProvider>? acceptedProviders,
  }) {
    return _BookingWaitSnapshot(
      title: title ?? this.title,
      message: message ?? this.message,
      accepted: accepted ?? this.accepted,
      timedOut: timedOut ?? this.timedOut,
      acceptedProviders: acceptedProviders ?? this.acceptedProviders,
    );
  }
}

enum _BookingWaitAction { cancel, pay, retry }

class _BookingRequestWaitSheet extends StatefulWidget {
  const _BookingRequestWaitSheet({
    required this.candidates,
    required this.center,
    required this.remainingSeconds,
    required this.totalSeconds,
    required this.snapshot,
    required this.showAcceptedProvidersList,
    required this.accent,
    required this.onCancel,
    required this.onPay,
    required this.onRetry,
  });

  final List<_BookingWaitCandidate> candidates;
  final LatLng center;
  final ValueNotifier<int> remainingSeconds;
  final int totalSeconds;
  final ValueNotifier<_BookingWaitSnapshot> snapshot;
  final bool showAcceptedProvidersList;
  final Color accent;
  final VoidCallback onCancel;
  final VoidCallback onPay;
  final VoidCallback onRetry;

  @override
  State<_BookingRequestWaitSheet> createState() =>
      _BookingRequestWaitSheetState();
}

class _BookingRequestWaitSheetState extends State<_BookingRequestWaitSheet> {
  BitmapDescriptor? _scooterIcon;

  @override
  void initState() {
    super.initState();
    unawaited(_loadScooterIcon());
  }

  Future<void> _loadScooterIcon() async {
    final icon = await _buildScooterMapMarker();
    if (!mounted) {
      return;
    }
    setState(() => _scooterIcon = icon);
  }

  Set<Marker> _markers() {
    final markers = <Marker>{};
    for (var index = 0; index < widget.candidates.length; index++) {
      final candidate = widget.candidates[index];
      markers.add(
        Marker(
          markerId: MarkerId('booking_wait_candidate_$index'),
          position: candidate.location,
          infoWindow: InfoWindow(
            title: candidate.label,
            snippet: candidate.priceLabel,
          ),
          icon:
              _scooterIcon ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        ),
      );
    }
    return markers;
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final sheetHeight = media.size.height - media.padding.top;
    return SafeArea(
      bottom: true,
      child: Align(
        alignment: Alignment.topCenter,
        child: Material(
          color: Colors.transparent,
          child: Container(
            height: sheetHeight,
            width: double.infinity,
            decoration: const BoxDecoration(color: Colors.white),
            child: ClipRect(
              child: Column(
                children: [
                  SizedBox(
                    height: sheetHeight * 0.58,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: widget.center,
                              zoom: widget.candidates.length <= 1 ? 13.5 : 12.2,
                            ),
                            myLocationEnabled: true,
                            myLocationButtonEnabled: false,
                            zoomControlsEnabled: false,
                            compassEnabled: false,
                            mapToolbarEnabled: false,
                            markers: _markers(),
                          ),
                        ),
                        Positioned(
                          left: 14,
                          top: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.92),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              '${widget.candidates.length} matching nearby',
                              style: const TextStyle(
                                color: Color(0xFF22314D),
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFFF0E4DC)),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x14000000),
                              blurRadius: 18,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ValueListenableBuilder<_BookingWaitSnapshot>(
                          valueListenable: widget.snapshot,
                          builder: (context, snapshot, child) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        snapshot.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Color(0xFF17233C),
                                          fontSize: 18,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                    if (!snapshot.accepted)
                                      ValueListenableBuilder<int>(
                                        valueListenable:
                                            widget.remainingSeconds,
                                        builder: (context, seconds, child) {
                                          return Text(
                                            '${seconds}s',
                                            style: TextStyle(
                                              color: widget.accent,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          );
                                        },
                                      ),
                                  ],
                                ),
                                if (!snapshot.accepted) ...[
                                  const SizedBox(height: 14),
                                  ValueListenableBuilder<int>(
                                    valueListenable: widget.remainingSeconds,
                                    builder: (context, seconds, child) {
                                      final elapsed = widget.totalSeconds <= 0
                                          ? 1.0
                                          : ((widget.totalSeconds - seconds) /
                                                    widget.totalSeconds)
                                                .clamp(0.0, 1.0);
                                      return LayoutBuilder(
                                        builder: (context, constraints) {
                                          return Container(
                                            height: 25,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFEEEEEE),
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                            clipBehavior: Clip.antiAlias,
                                            child: Stack(
                                              children: [
                                                if (elapsed > 0)
                                                  AnimatedContainer(
                                                    duration: const Duration(
                                                      milliseconds: 500,
                                                    ),
                                                    curve: Curves.easeInOut,
                                                    width:
                                                        constraints.maxWidth *
                                                        elapsed,
                                                    height: double.infinity,
                                                    decoration: BoxDecoration(
                                                      gradient:
                                                          const LinearGradient(
                                                            begin: Alignment
                                                                .centerLeft,
                                                            end: Alignment
                                                                .centerRight,
                                                            colors: [
                                                              Color(0xFF006400),
                                                              Color(0xFF90EE90),
                                                              Color(0xFFFFFF00),
                                                              Color(0xFFFF0000),
                                                              Color(0xFF006400),
                                                            ],
                                                            stops: [
                                                              0.0,
                                                              0.25,
                                                              0.50,
                                                              0.75,
                                                              1.0,
                                                            ],
                                                          ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            15,
                                                          ),
                                                    ),
                                                  ),
                                                Positioned.fill(
                                                  child: DecoratedBox(
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        begin:
                                                            Alignment.topCenter,
                                                        end: Alignment
                                                            .bottomCenter,
                                                        colors: [
                                                          Colors.white
                                                              .withValues(
                                                                alpha: 0.22,
                                                              ),
                                                          Colors.transparent,
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 8,
                                                  right: 8,
                                                  top: 4,
                                                  child: Container(
                                                    height: 4,
                                                    decoration: BoxDecoration(
                                                      color: Colors.white
                                                          .withValues(
                                                            alpha: 0.28,
                                                          ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            15,
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ],
                                if (snapshot.message.trim().isNotEmpty) ...[
                                  const SizedBox(height: 10),
                                  Text(
                                    snapshot.message,
                                    maxLines: snapshot.acceptedProviders.isEmpty
                                        ? 2
                                        : 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Color(0xFF66748C),
                                      fontSize: 12.8,
                                      fontWeight: FontWeight.w700,
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                                if (snapshot.acceptedProviders.isNotEmpty &&
                                    widget.showAcceptedProvidersList) ...[
                                  const SizedBox(height: 12),
                                  Text(
                                    snapshot.accepted
                                        ? 'Accepted providers'
                                        : 'Accepted so far',
                                    style: TextStyle(
                                      color: widget.accent,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    height: 156,
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF7F9FC),
                                        borderRadius: BorderRadius.circular(18),
                                        border: Border.all(
                                          color: const Color(0xFFE3E9F2),
                                        ),
                                      ),
                                      child: ListView.separated(
                                        padding: EdgeInsets.zero,
                                        itemCount:
                                            snapshot.acceptedProviders.length,
                                        separatorBuilder: (context, index) =>
                                            const SizedBox(height: 8),
                                        itemBuilder: (context, index) {
                                          final provider =
                                              snapshot.acceptedProviders[index];
                                          return Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 10,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                            ),
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: 34,
                                                  height: 34,
                                                  decoration: BoxDecoration(
                                                    color: widget.accent
                                                        .withValues(
                                                          alpha: 0.14,
                                                        ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  child: Icon(
                                                    Icons.check_rounded,
                                                    color: widget.accent,
                                                    size: 20,
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: Text(
                                                    provider.providerName,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      color: Color(0xFF17233C),
                                                      fontSize: 13.5,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                    ),
                                                  ),
                                                ),
                                                if (provider.quotedPriceAmount
                                                    .trim()
                                                    .isNotEmpty)
                                                  Text(
                                                    provider.quotedPriceAmount,
                                                    style: TextStyle(
                                                      color: widget.accent,
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w900,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ] else if (snapshot
                                    .acceptedProviders
                                    .isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  Text(
                                    snapshot
                                        .acceptedProviders
                                        .first
                                        .providerName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: widget.accent,
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ] else
                                  const Spacer(),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    if (snapshot.timedOut) ...[
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed: widget.onRetry,
                                          icon: const Icon(
                                            Icons.refresh_rounded,
                                            size: 18,
                                          ),
                                          label: const Text('Retry'),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                    ],
                                    Expanded(
                                      child: FilledButton.icon(
                                        onPressed: snapshot.accepted
                                            ? widget.onPay
                                            : widget.onCancel,
                                        style: FilledButton.styleFrom(
                                          backgroundColor: snapshot.accepted
                                              ? const Color(0xFF2E8E45)
                                              : const Color(0xFFD84A4A),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 13,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                        ),
                                        icon: Icon(
                                          snapshot.accepted
                                              ? Icons.payments_rounded
                                              : Icons.close_rounded,
                                          size: 18,
                                        ),
                                        label: Text(
                                          snapshot.accepted
                                              ? 'Go to payment'
                                              : 'Cancel',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActiveBookingDetailsSheet extends StatefulWidget {
  const _ActiveBookingDetailsSheet({
    required this.initialStatus,
    required this.onPayNow,
    required this.onStatusChanged,
    this.onOpenProviderProfile,
  });

  final _ActiveBookingStatus initialStatus;
  final Future<void> Function(_ActiveBookingStatus status) onPayNow;
  final ValueChanged<_ActiveBookingStatus?> onStatusChanged;
  final Future<void> Function(_ActiveBookingStatus status)?
  onOpenProviderProfile;

  @override
  State<_ActiveBookingDetailsSheet> createState() =>
      _ActiveBookingDetailsSheetState();
}

class _ActiveBookingDetailsSheetState
    extends State<_ActiveBookingDetailsSheet> {
  static final RegExp _sixDigitOtpRegex = RegExp(r'^\d{6}$');
  static const String _androidDirectionsApiKey =
      'AIzaSyA51i0ow9o6wBQzJ1km94Hv_9g2rzesgRA';
  static const String _iosDirectionsApiKey =
      'AIzaSyBSV5mUsHDu_XcocYqRaFfGOERKsggAdyQ';
  final TextEditingController _startWorkOtpController = TextEditingController();
  final TextEditingController _mutualCancelOtpController =
      TextEditingController();
  BitmapDescriptor? _providerScooterMarkerIcon;
  _ActiveBookingStatus? _status;
  Timer? _liveTrackingPollTimer;
  Timer? _countdownUiTimer;
  _TrackingRouteSnapshot? _routeSnapshot;
  bool _loadingRouteSnapshot = false;
  DateTime? _lastRouteFetchedAt;
  LatLng? _lastRouteOrigin;
  LatLng? _lastRouteDestination;
  bool _loading = false;
  bool _verifyingStart = false;
  bool _generatingCompleteOtp = false;
  bool _requestingMutualCancel = false;
  bool _verifyingMutualCancel = false;
  bool _cancellingNoShow = false;
  bool _paying = false;
  bool _reviewDialogOpen = false;
  String? _startOtpError;
  String? _mutualCancelOtpError;
  String? _completeWorkOtpError;
  String? _cancelActionError;
  String? _statusBannerMessage;
  bool _statusBannerIsError = false;
  String? _completeWorkOtpCode;
  bool _mutualCancelRequested = false;
  final Set<int> _reviewPromptedBookingIds = <int>{};

  @override
  void initState() {
    super.initState();
    _status = widget.initialStatus;
    _syncLiveTrackingPolling();
    _syncCountdownTimer();
    unawaited(_loadProviderScooterMarkerIcon());
    unawaited(_refreshTrackingRoute(force: true));
  }

  @override
  void dispose() {
    _liveTrackingPollTimer?.cancel();
    _countdownUiTimer?.cancel();
    _startWorkOtpController.dispose();
    _mutualCancelOtpController.dispose();
    super.dispose();
  }

  Future<_ActiveBookingStatus?> _loadMatchingStatus() async {
    final currentRequestId =
        _status?.requestId ?? widget.initialStatus.requestId;
    final statuses = await _UserAppApi.fetchActiveBookingStatuses();
    for (final status in statuses) {
      if (status.requestId == currentRequestId) {
        return status;
      }
    }
    return null;
  }

  Future<_ActiveBookingStatus?> _loadMatchingHistoryStatus() async {
    final currentRequestId =
        _status?.requestId ?? widget.initialStatus.requestId;
    final statuses = await _UserAppApi.fetchBookingHistoryStatuses();
    for (final status in statuses) {
      if (status.requestId == currentRequestId) {
        return status;
      }
    }
    return null;
  }

  String _reviewHistoryStatus(_ActiveBookingStatus status) {
    final explicit = status.historyStatus.trim().toUpperCase();
    if (explicit.isNotEmpty) {
      return explicit;
    }
    final bookingStatus = status.bookingStatus.trim().toUpperCase();
    if (bookingStatus == 'CANCELLED' &&
        status.paymentStatus.trim().toUpperCase() == 'FAILED') {
      return 'PAYMENT_FAILED';
    }
    return bookingStatus;
  }

  bool _canPromptForReview(_ActiveBookingStatus? status) {
    if (status == null || status.bookingId <= 0 || status.reviewSubmitted) {
      return false;
    }
    final normalized = _reviewHistoryStatus(status);
    return normalized == 'COMPLETED' || normalized == 'CANCELLED';
  }

  Future<void> _maybePromptForReview(_ActiveBookingStatus? status) async {
    if (!_canPromptForReview(status) || !mounted || _reviewDialogOpen) {
      return;
    }
    final bookingId = status!.bookingId;
    if (_reviewPromptedBookingIds.contains(bookingId)) {
      return;
    }
    _reviewPromptedBookingIds.add(bookingId);
    _reviewDialogOpen = true;
    final submitted = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => _BookingReviewDialog(
        status: status,
        onSubmit: (rating, comment) => _UserAppApi.submitBookingReview(
          bookingId: status.bookingId,
          rating: rating,
          comment: comment,
        ),
      ),
    );
    _reviewDialogOpen = false;
    if (submitted == true) {
      if (!mounted) {
        return;
      }
      setState(() {
        _status = null;
        _completeWorkOtpCode = null;
      });
      widget.onStatusChanged(null);
      Navigator.of(context).pop();
    }
  }

  Future<void> _reload({bool promptForReview = false}) async {
    setState(() => _loading = true);
    try {
      final previousStatus = _status;
      final latest = await _loadMatchingStatus();
      _ActiveBookingStatus? reviewCandidate;
      if (promptForReview ||
          (latest == null &&
              previousStatus?.bookingId != null &&
              previousStatus!.bookingId > 0)) {
        reviewCandidate = await _loadMatchingHistoryStatus();
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _status = latest;
        _startOtpError = null;
        _mutualCancelOtpError = null;
        if (latest?.bookingStatus.toUpperCase() != 'IN_PROGRESS') {
          _completeWorkOtpCode = null;
        }
      });
      _syncLiveTrackingPolling();
      _syncCountdownTimer();
      unawaited(_refreshTrackingRoute(force: true));
      widget.onStatusChanged(latest);
      if (promptForReview || reviewCandidate != null) {
        await _maybePromptForReview(reviewCandidate);
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _loadProviderScooterMarkerIcon() async {
    final marker = await _buildScooterMapMarker();
    if (!mounted) {
      return;
    }
    setState(() => _providerScooterMarkerIcon = marker);
  }

  bool _shouldPollLiveTracking(_ActiveBookingStatus? status) {
    if (status == null || status.bookingId <= 0) {
      return false;
    }
    final bookingStatus = status.bookingStatus.trim().toUpperCase();
    return bookingStatus != 'COMPLETED' && bookingStatus != 'CANCELLED';
  }

  void _syncLiveTrackingPolling() {
    if (!_shouldPollLiveTracking(_status)) {
      _liveTrackingPollTimer?.cancel();
      _liveTrackingPollTimer = null;
      return;
    }
    _liveTrackingPollTimer ??= Timer.periodic(const Duration(seconds: 6), (_) {
      if (!mounted || _loading || !_shouldPollLiveTracking(_status)) {
        return;
      }
      unawaited(_reloadLiveTrackingSilently());
    });
  }

  void _syncCountdownTimer() {
    final status = _status;
    final needsCountdown =
        status != null &&
        ((status.paymentDueAt != null &&
                _currentUtcTime().isBefore(status.paymentDueAt!)) ||
            (status.reachByAt != null &&
                _currentUtcTime().isBefore(status.reachByAt!)));
    if (!needsCountdown) {
      _countdownUiTimer?.cancel();
      _countdownUiTimer = null;
      return;
    }
    _countdownUiTimer ??= Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) {
        return;
      }
      final currentStatus = _status;
      final stillNeeded =
          currentStatus != null &&
          ((currentStatus.paymentDueAt != null &&
                  _currentUtcTime().isBefore(currentStatus.paymentDueAt!)) ||
              (currentStatus.reachByAt != null &&
                  _currentUtcTime().isBefore(currentStatus.reachByAt!)));
      if (!stillNeeded) {
        _countdownUiTimer?.cancel();
        _countdownUiTimer = null;
      }
      setState(() {});
    });
  }

  Future<void> _reloadLiveTrackingSilently() async {
    try {
      final previousStatus = _status;
      final latest = await _loadMatchingStatus();
      _ActiveBookingStatus? reviewCandidate;
      if (latest == null &&
          previousStatus?.bookingId != null &&
          previousStatus!.bookingId > 0) {
        reviewCandidate = await _loadMatchingHistoryStatus();
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _status = latest;
        if (latest?.bookingStatus.toUpperCase() != 'IN_PROGRESS') {
          _completeWorkOtpCode = null;
        }
      });
      _syncLiveTrackingPolling();
      unawaited(_refreshTrackingRoute());
      widget.onStatusChanged(latest);
      if (reviewCandidate != null) {
        await _maybePromptForReview(reviewCandidate);
      }
    } catch (_) {
      if (!mounted) {
        return;
      }
    }
  }

  Future<void> _refreshTrackingRoute({bool force = false}) async {
    final status = _status;
    final origin = status == null ? null : _providerTrackingLatLng(status);
    final destination = status == null
        ? null
        : _destinationTrackingLatLng(status);
    if (origin == null || destination == null) {
      if (mounted && _routeSnapshot != null) {
        setState(() => _routeSnapshot = null);
      }
      return;
    }
    if (_loadingRouteSnapshot) {
      return;
    }
    final now = DateTime.now();
    if (!force &&
        _lastRouteFetchedAt != null &&
        now.difference(_lastRouteFetchedAt!).inSeconds < 15 &&
        _lastRouteOrigin != null &&
        _lastRouteDestination != null) {
      final movedMeters = Geolocator.distanceBetween(
        _lastRouteOrigin!.latitude,
        _lastRouteOrigin!.longitude,
        origin.latitude,
        origin.longitude,
      );
      final destinationMovedMeters = Geolocator.distanceBetween(
        _lastRouteDestination!.latitude,
        _lastRouteDestination!.longitude,
        destination.latitude,
        destination.longitude,
      );
      if (movedMeters < 20 && destinationMovedMeters < 5) {
        return;
      }
    }

    final apiKey = _directionsApiKey();
    if (apiKey.isEmpty) {
      return;
    }

    _loadingRouteSnapshot = true;
    try {
      final route = await _fetchTrackingRoute(
        origin: origin,
        destination: destination,
        apiKey: apiKey,
      );
      if (!mounted) {
        return;
      }
      setState(() => _routeSnapshot = route);
      _lastRouteFetchedAt = now;
      _lastRouteOrigin = origin;
      _lastRouteDestination = destination;
    } catch (_) {
      if (!mounted) {
        return;
      }
    } finally {
      _loadingRouteSnapshot = false;
    }
  }

  String _directionsApiKey() {
    return switch (Theme.of(context).platform) {
      TargetPlatform.iOS => _iosDirectionsApiKey,
      _ => _androidDirectionsApiKey,
    };
  }

  Future<_TrackingRouteSnapshot> _fetchTrackingRoute({
    required LatLng origin,
    required LatLng destination,
    required String apiKey,
  }) async {
    final uri = Uri.https(
      'maps.googleapis.com',
      '/maps/api/directions/json',
      <String, String>{
        'origin': '${origin.latitude},${origin.longitude}',
        'destination': '${destination.latitude},${destination.longitude}',
        'mode': 'driving',
        'key': apiKey,
      },
    );
    final response = await http.get(uri);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Could not load route right now.');
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Unexpected directions response.');
    }
    final routes = (decoded['routes'] as List?) ?? const [];
    if (routes.isEmpty) {
      throw Exception('No route found.');
    }
    final route = Map<String, dynamic>.from(routes.first as Map);
    final polyline = Map<String, dynamic>.from(
      (route['overview_polyline'] as Map?) ?? const {},
    );
    final legs = (route['legs'] as List?) ?? const [];
    final firstLeg = legs.isEmpty
        ? const <String, dynamic>{}
        : Map<String, dynamic>.from(legs.first as Map);
    final distance = Map<String, dynamic>.from(
      (firstLeg['distance'] as Map?) ?? const {},
    );
    final duration = Map<String, dynamic>.from(
      (firstLeg['duration'] as Map?) ?? const {},
    );
    return _TrackingRouteSnapshot(
      polylinePoints: _decodeGooglePolyline('${polyline['points'] ?? ''}'),
      distanceLabel: '${distance['text'] ?? ''}'.trim(),
      durationLabel: '${duration['text'] ?? ''}'.trim(),
    );
  }

  List<LatLng> _decodeGooglePolyline(String encoded) {
    if (encoded.isEmpty) {
      return const <LatLng>[];
    }
    final points = <LatLng>[];
    int index = 0;
    int lat = 0;
    int lng = 0;
    while (index < encoded.length) {
      int shift = 0;
      int result = 0;
      int byte;
      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1f) << shift;
        shift += 5;
      } while (byte >= 0x20);
      lat += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);

      shift = 0;
      result = 0;
      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1f) << shift;
        shift += 5;
      } while (byte >= 0x20);
      lng += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }

  Future<void> _verifyStartWorkOtp() async {
    final status = _status;
    final otp = _startWorkOtpController.text.trim();
    if (status == null || status.bookingId <= 0 || _verifyingStart) {
      return;
    }
    if (!_sixDigitOtpRegex.hasMatch(otp)) {
      setState(
        () => _startOtpError = 'Enter the 6-digit OTP shared by labour.',
      );
      return;
    }
    setState(() {
      _verifyingStart = true;
      _startOtpError = null;
      _statusBannerMessage = null;
    });
    try {
      await _UserAppApi.verifyBookingOtp(
        bookingId: status.bookingId,
        purpose: 'START_WORK',
        otpCode: otp,
      );
      _startWorkOtpController.clear();
      await _reload();
      if (mounted) {
        _showSheetStatusMessage('Work is now in progress.');
      }
    } on _UserAppApiException catch (error) {
      if (mounted) {
        setState(() {
          _startOtpError = error.message;
          _statusBannerMessage = null;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _verifyingStart = false);
      }
    }
  }

  Future<void> _generateCompleteWorkOtp() async {
    final status = _status;
    if (status == null || status.bookingId <= 0 || _generatingCompleteOtp) {
      return;
    }
    setState(() {
      _generatingCompleteOtp = true;
      _completeWorkOtpError = null;
      _statusBannerMessage = null;
    });
    try {
      final otp = await _UserAppApi.generateBookingOtp(
        bookingId: status.bookingId,
        purpose: 'COMPLETE_WORK',
      );
      if (mounted) {
        setState(() {
          _completeWorkOtpCode = otp;
          _completeWorkOtpError = null;
        });
      }
    } on _UserAppApiException catch (error) {
      if (mounted) {
        setState(() => _completeWorkOtpError = error.message);
      }
    } finally {
      if (mounted) {
        setState(() => _generatingCompleteOtp = false);
      }
    }
  }

  Future<void> _requestMutualCancelOtp() async {
    final status = _status;
    if (status == null || status.bookingId <= 0 || _requestingMutualCancel) {
      return;
    }
    setState(() {
      _requestingMutualCancel = true;
      _mutualCancelOtpError = null;
      _statusBannerMessage = null;
    });
    try {
      await _UserAppApi.generateBookingOtp(
        bookingId: status.bookingId,
        purpose: 'MUTUAL_CANCEL',
      );
      if (!mounted) {
        return;
      }
      setState(() => _mutualCancelRequested = true);
      _showSheetStatusMessage('Mutual cancel OTP sent to labour.');
    } on _UserAppApiException catch (error) {
      if (mounted) {
        setState(() => _mutualCancelOtpError = error.message);
      }
    } finally {
      if (mounted) {
        setState(() => _requestingMutualCancel = false);
      }
    }
  }

  Future<void> _verifyMutualCancelOtp() async {
    final status = _status;
    final otp = _mutualCancelOtpController.text.trim();
    if (status == null || status.bookingId <= 0 || _verifyingMutualCancel) {
      return;
    }
    if (!_sixDigitOtpRegex.hasMatch(otp)) {
      setState(
        () => _mutualCancelOtpError = 'Enter the 6-digit OTP shared by labour.',
      );
      return;
    }
    setState(() {
      _verifyingMutualCancel = true;
      _mutualCancelOtpError = null;
      _statusBannerMessage = null;
    });
    try {
      await _UserAppApi.verifyBookingOtp(
        bookingId: status.bookingId,
        purpose: 'MUTUAL_CANCEL',
        otpCode: otp,
      );
      _mutualCancelOtpController.clear();
      await _reload(promptForReview: true);
      if (mounted) {
        _showSheetStatusMessage('Booking cancelled mutually.');
      }
    } on _UserAppApiException catch (error) {
      if (mounted) {
        setState(() => _mutualCancelOtpError = error.message);
      }
    } finally {
      if (mounted) {
        setState(() => _verifyingMutualCancel = false);
      }
    }
  }

  Future<void> _cancelAfterReachDeadline() async {
    final status = _status;
    if (status == null ||
        status.bookingId <= 0 ||
        !_canCancelAfterReachDeadline(status) ||
        _cancellingNoShow) {
      return;
    }
    setState(() {
      _cancellingNoShow = true;
      _cancelActionError = null;
      _statusBannerMessage = null;
    });
    try {
      await _UserAppApi.cancelBookingByUser(
        bookingId: status.bookingId,
        reason: 'Provider did not reach within the configured reach timeline.',
      );
      await _reload(promptForReview: true);
      if (mounted) {
        _showSheetStatusMessage(
          status.bookingType.toUpperCase() == 'SERVICE'
              ? 'Booking cancelled because service provider did not reach in time.'
              : 'Booking cancelled because labour did not reach in time.',
        );
      }
    } on _UserAppApiException catch (error) {
      if (mounted) {
        setState(() => _cancelActionError = error.message);
      }
    } finally {
      if (mounted) {
        setState(() => _cancellingNoShow = false);
      }
    }
  }

  void _showSheetStatusMessage(String message, {bool isError = false}) {
    if (!mounted) {
      return;
    }
    setState(() {
      _statusBannerMessage = message;
      _statusBannerIsError = isError;
    });
  }

  @override
  Widget build(BuildContext context) {
    final status = _status;
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.78,
      minChildSize: 0.5,
      maxChildSize: 0.94,
      builder: (context, controller) => AnimatedPadding(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.only(bottom: keyboardInset > 0 ? 12 : 0),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF7F2EC),
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: status == null
              ? _emptyState(controller)
              : ListView(
                  controller: controller,
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.fromLTRB(
                    18,
                    12,
                    18,
                    keyboardInset > 0 ? keyboardInset + 36 : 28,
                  ),
                  children: [
                    Center(
                      child: Container(
                        width: 54,
                        height: 5,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4C6BA),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _header(status),
                    const SizedBox(height: 14),
                    if (_loading) const LinearProgressIndicator(minHeight: 3),
                    if (_statusBannerMessage != null &&
                        _statusBannerMessage!.trim().isNotEmpty) ...[
                      if (_loading) const SizedBox(height: 12),
                      _buildInlineStatusBanner(
                        _statusBannerMessage!,
                        isError: _statusBannerIsError,
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (status.canMakePayment) _paymentPendingAction(status),
                    if (!status.canMakePayment &&
                        status.bookingStatus.trim().toUpperCase() ==
                            'PAYMENT_PENDING') ...[
                      _paymentProcessingCard(status),
                      const SizedBox(height: 12),
                    ],
                    if (!status.canMakePayment && status.bookingId <= 0)
                      _waitingForAcceptanceCard(status),
                    if (!status.canMakePayment && status.bookingId > 0) ...[
                      if (status.bookingStatus.toUpperCase() ==
                          'IN_PROGRESS') ...[
                        _completionOtpCard(status),
                        const SizedBox(height: 12),
                      ],
                      _summaryDetailsCard(status),
                      const SizedBox(height: 12),
                      _liveLocationCard(status),
                      const SizedBox(height: 12),
                      _arrivalOtpCard(status),
                      const SizedBox(height: 12),
                      if (status.bookingStatus.toUpperCase() !=
                          'IN_PROGRESS') ...[
                        _completionOtpCard(status),
                        const SizedBox(height: 12),
                      ],
                      _cancelCard(status),
                    ],
                  ],
                ),
        ),
      ),
    );
  }

  Widget _waitingForAcceptanceCard(_ActiveBookingStatus status) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _whiteCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Waiting for labour response',
            style: TextStyle(
              color: Color(0xFF22314D),
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Request ID: ${status.requestCode.trim().isEmpty ? '#${status.requestId}' : status.requestCode}',
            style: const TextStyle(
              color: Color(0xFF66748C),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _loading ? null : _reload,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(ScrollController controller) {
    return ListView(
      controller: controller,
      padding: const EdgeInsets.all(24),
      children: const [
        SizedBox(height: 24),
        Icon(Icons.check_circle_rounded, color: Color(0xFF7AA81E), size: 54),
        SizedBox(height: 12),
        Text(
          'No live booking right now.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF22314D),
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
      ],
    );
  }

  Widget _header(_ActiveBookingStatus status) {
    final isService = status.bookingType.trim().toUpperCase() == 'SERVICE';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF22314D), Color(0xFF3E587D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: widget.onOpenProviderProfile == null
                ? null
                : () => unawaited(widget.onOpenProviderProfile!(status)),
            borderRadius: BorderRadius.circular(999),
            child: _ActiveBookingAvatar(status: status, size: 58),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _providerTitle(status),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Once ${isService ? 'servicemen' : 'labour'} arrived receive OTP and start work.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.84),
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentPendingAction(_ActiveBookingStatus status) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _whiteCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Confirm your booking',
            style: TextStyle(
              color: Color(0xFF22314D),
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          if (status.paymentDueAt != null) ...[
            const SizedBox(height: 6),
            Text(
              'Payment due by ${_timeOnly(status.paymentDueAt)}',
              style: const TextStyle(
                color: Color(0xFFCB6E5B),
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _paying
                ? null
                : () async {
                    setState(() => _paying = true);
                    await widget.onPayNow(status);
                    if (mounted) {
                      setState(() => _paying = false);
                    }
                  },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFCB6E5B),
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: _paying
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.6,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('Go to payment'),
          ),
        ],
      ),
    );
  }

  Widget _paymentProcessingCard(_ActiveBookingStatus status) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _whiteCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Waiting for payment confirmation',
            style: TextStyle(
              color: Color(0xFF22314D),
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your payment is still pending. Please wait up to 5 minutes for the payment to complete. If it does not complete, the booking will return to the previous state.',
            style: TextStyle(
              color: Color(0xFF66748C),
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
          if (status.paymentDueAt != null) ...[
            const SizedBox(height: 10),
            Text(
              'Payment window ends by ${_timeOnly(status.paymentDueAt)}',
              style: const TextStyle(
                color: Color(0xFFCB6E5B),
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _loading ? null : _reload,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Refresh payment status'),
          ),
        ],
      ),
    );
  }

  Widget _summaryDetailsCard(_ActiveBookingStatus status) {
    final providerLabel = status.bookingType.trim().toUpperCase() == 'SERVICE'
        ? 'Servicemen'
        : 'Labour';
    final categoryLabel = status.categoryLabel.trim().isNotEmpty
        ? status.categoryLabel.trim()
        : (status.subcategoryLabel.trim().isNotEmpty
              ? status.subcategoryLabel.trim()
              : _pricingModelLabel(status));
    final subcategoryLabel =
        status.subcategoryLabel.trim().isNotEmpty &&
            status.subcategoryLabel.trim() != status.categoryLabel.trim()
        ? status.subcategoryLabel.trim()
        : '';
    final amountLabel = status.totalAcceptedQuotedPriceAmount.trim().isNotEmpty
        ? status.totalAcceptedQuotedPriceAmount.trim()
        : (status.quotedPriceAmount.trim().isNotEmpty
              ? status.quotedPriceAmount.trim()
              : 'As quoted');
    final phone = status.providerPhone.trim();
    final digits = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    final canDialPhone =
        phone.isNotEmpty &&
        !phone.contains('*') &&
        !phone.toLowerCase().contains('x') &&
        digits.replaceAll('+', '').length >= 7;
    final amountColor = status.paymentStatus.trim().toUpperCase() == 'PAID'
        ? const Color(0xFF177245)
        : const Color(0xFFC67A1F);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _whiteCardDecoration(),
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
                      providerLabel,
                      style: const TextStyle(
                        color: Color(0xFF6E7A8E),
                        fontWeight: FontWeight.w600,
                        fontSize: 11.8,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _providerTitle(status),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF22314D),
                        fontWeight: FontWeight.w600,
                        fontSize: 14.8,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              _ActiveBookingAvatar(status: status, size: 40),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Amount',
                    style: TextStyle(
                      color: Color(0xFF6E7A8E),
                      fontWeight: FontWeight.w800,
                      fontSize: 11.4,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    amountLabel,
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      color: amountColor,
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      categoryLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF22314D),
                        fontWeight: FontWeight.w700,
                        fontSize: 14.2,
                      ),
                    ),
                    if (subcategoryLabel.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subcategoryLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF7D889A),
                          fontWeight: FontWeight.w600,
                          fontSize: 11.8,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Mobile',
                    style: TextStyle(
                      color: canDialPhone
                          ? const Color(0xFFBE6F5D)
                          : const Color(0xFF8D8A86),
                      fontWeight: FontWeight.w700,
                      fontSize: 11.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  InkWell(
                    onTap: canDialPhone
                        ? () => unawaited(
                            launchUrl(
                              Uri(scheme: 'tel', path: digits),
                              mode: LaunchMode.externalApplication,
                            ),
                          )
                        : null,
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: canDialPhone
                            ? const Color(0xFFFFF5F2)
                            : const Color(0xFFF7F3F0),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: canDialPhone
                              ? const Color(0xFFE8B7AA)
                              : const Color(0xFFE6D9D1),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (canDialPhone) ...[
                            const Icon(
                              Icons.call_rounded,
                              size: 13,
                              color: Color(0xFFBE6F5D),
                            ),
                            const SizedBox(width: 4),
                          ],
                          Text(
                            phone.isEmpty ? '-' : phone,
                            style: TextStyle(
                              color: canDialPhone
                                  ? const Color(0xFF22314D)
                                  : const Color(0xFF7D889A),
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _liveLocationCard(_ActiveBookingStatus status) {
    final providerLocation = _providerTrackingLatLng(status);
    final destinationLocation = _destinationTrackingLatLng(status);
    final hasMap = providerLocation != null || destinationLocation != null;
    final routeDistanceLabel = _trackingRouteDistanceLabel(status);
    final routeEtaLabel = _trackingRouteEtaLabel();
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _whiteCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text(
                'Live trip tracking',
                style: TextStyle(
                  color: Color(0xFF22314D),
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
              if (routeDistanceLabel != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE9F7FF),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: const Color(0xFFB9DDF3)),
                  ),
                  child: Text(
                    'Route $routeDistanceLabel',
                    style: const TextStyle(
                      color: Color(0xFF14516E),
                      fontWeight: FontWeight.w700,
                      fontSize: 12.2,
                    ),
                  ),
                ),
              if (routeEtaLabel != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEFE7),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: const Color(0xFFF1C6B4)),
                  ),
                  child: Text(
                    'ETA $routeEtaLabel',
                    style: const TextStyle(
                      color: Color(0xFF9A432E),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
            ],
          ),
          if (routeDistanceLabel == null && _loadingRouteSnapshot) ...[
            const SizedBox(height: 8),
            const Text(
              'Calculating route...',
              style: TextStyle(
                color: Color(0xFF66748C),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Container(
            height: 138,
            decoration: BoxDecoration(
              color: const Color(0xFFEDE3DA),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE0D1C7)),
            ),
            clipBehavior: Clip.antiAlias,
            child: hasMap
                ? Stack(
                    children: [
                      IgnorePointer(
                        ignoring: true,
                        child: GoogleMap(
                          initialCameraPosition: _trackingCameraPosition(
                            status,
                          ),
                          markers: _trackingMarkers(status),
                          circles: _trackingCircles(status),
                          polylines: _trackingPolylines(status),
                          zoomControlsEnabled: false,
                          myLocationButtonEnabled: false,
                          liteModeEnabled: true,
                        ),
                      ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _openFullMap(status),
                            borderRadius: BorderRadius.circular(999),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.92),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.12),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.zoom_out_map_rounded,
                                color: Color(0xFF13A044),
                                size: 21,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : const Center(
                    child: Text(
                      'Waiting for live location.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF66748C),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _arrivalOtpCard(_ActiveBookingStatus status) {
    final bookingStatus = status.bookingStatus.toUpperCase();
    final canEnterOtp =
        bookingStatus == 'PAYMENT_COMPLETED' || bookingStatus == 'ARRIVED';
    final alreadyStarted = bookingStatus == 'IN_PROGRESS';
    final cardTitle = alreadyStarted
        ? 'Work in progress'
        : 'Enter start work OTP';
    final hintText = canEnterOtp
        ? 'Start work OTP'
        : 'Unlocks after payment confirmation';
    final actionLabel = 'Confirm OTP and start work';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _whiteCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            cardTitle,
            style: const TextStyle(
              color: Color(0xFF22314D),
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          if (!alreadyStarted) ...[
            const SizedBox(height: 10),
            Builder(
              builder: (fieldContext) => TextField(
                controller: _startWorkOtpController,
                enabled: canEnterOtp && !_verifyingStart,
                keyboardType: TextInputType.number,
                scrollPadding: const EdgeInsets.only(bottom: 120),
                onTap: () => _ensureFieldVisibleAboveKeyboard(fieldContext),
                maxLength: 6,
                decoration: InputDecoration(
                  counterText: '',
                  hintText: hintText,
                  errorText: _startOtpError,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: canEnterOtp && !_verifyingStart
                  ? _verifyStartWorkOtp
                  : null,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF7AA81E),
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(_verifyingStart ? 'Verifying...' : actionLabel),
            ),
          ],
        ],
      ),
    );
  }

  Widget _completionOtpCard(_ActiveBookingStatus status) {
    if (status.bookingStatus.toUpperCase() != 'IN_PROGRESS') {
      return const SizedBox.shrink();
    }
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _whiteCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Completion OTP',
            style: TextStyle(
              color: Color(0xFF22314D),
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          if (_completeWorkOtpCode != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF22314D),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                _completeWorkOtpCode!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 28,
                  letterSpacing: 5,
                ),
              ),
            )
          else
            const SizedBox.shrink(),
          const SizedBox(height: 10),
          FilledButton(
            onPressed: _generatingCompleteOtp ? null : _generateCompleteWorkOtp,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFCB6E5B),
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              _generatingCompleteOtp
                  ? 'Generating...'
                  : 'Generate completion OTP',
            ),
          ),
          if (_completeWorkOtpError != null &&
              _completeWorkOtpError!.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              _completeWorkOtpError!,
              style: const TextStyle(
                color: Color(0xFFD53F4B),
                fontWeight: FontWeight.w800,
                fontSize: 12.4,
                height: 1.3,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _cancelCard(_ActiveBookingStatus status) {
    final bookingStatus = status.bookingStatus.toUpperCase();
    final showNoShowCancel = bookingStatus == 'PAYMENT_COMPLETED';
    final showMutualCancel = bookingStatus == 'IN_PROGRESS';
    final canNoShowCancel = _canCancelAfterReachDeadline(status);
    if (!showNoShowCancel &&
        !showMutualCancel &&
        !_mutualCancelRequested &&
        _mutualCancelOtpError == null) {
      return const SizedBox.shrink();
    }
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _whiteCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  showMutualCancel
                      ? 'Mutual cancellation'
                      : (status.bookingType.toUpperCase() == 'SERVICE'
                            ? 'Cancel if service provider does not reach'
                            : 'Cancel if labour does not reach'),
                  style: const TextStyle(
                    color: Color(0xFF22314D),
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ),
              if (showNoShowCancel)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: canNoShowCancel
                        ? const Color(0xFF1FA855)
                        : const Color(0xFFF2A13D),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    _reachCountdownLabel(status),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (showNoShowCancel) ...[
            Text(
              canNoShowCancel
                  ? (status.bookingType.toUpperCase() == 'SERVICE'
                        ? 'Service provider did not reach in time.'
                        : 'Labour did not reach in time.')
                  : 'This button unlocks after the full reach timer ends.',
              style: const TextStyle(
                color: Color(0xFF66748C),
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: canNoShowCancel && !_cancellingNoShow
                  ? _cancelAfterReachDeadline
                  : null,
              style: OutlinedButton.styleFrom(
                foregroundColor: canNoShowCancel
                    ? const Color(0xFFB03737)
                    : const Color(0xFF8F8781),
                disabledForegroundColor: const Color(0xFF8F8781),
                minimumSize: const Size.fromHeight(46),
                side: BorderSide(
                  color: canNoShowCancel
                      ? const Color(0xFFB03737)
                      : const Color(0xFFD1C7C0),
                  width: canNoShowCancel ? 1.2 : 1,
                ),
                backgroundColor: canNoShowCancel
                    ? const Color(0xFFFFF7F7)
                    : const Color(0xFFE8E2DD),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    canNoShowCancel
                        ? Icons.cancel_outlined
                        : Icons.lock_clock_rounded,
                    size: 18,
                    color: canNoShowCancel
                        ? const Color(0xFFB03737)
                        : const Color(0xFF8F8781),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _cancellingNoShow
                        ? 'Cancelling...'
                        : _cancelButtonLabel(status),
                  ),
                ],
              ),
            ),
            if (_cancelActionError != null &&
                _cancelActionError!.trim().isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                _cancelActionError!,
                style: const TextStyle(
                  color: Color(0xFFD53F4B),
                  fontWeight: FontWeight.w800,
                  fontSize: 12.4,
                  height: 1.3,
                ),
              ),
            ],
          ],
          if (showMutualCancel) ...[
            const Text(
              'Paid charges will not be refunded after work starts.',
              style: TextStyle(
                color: Color(0xFF9B433B),
                fontWeight: FontWeight.w800,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: !_requestingMutualCancel
                  ? _requestMutualCancelOtp
                  : null,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFB03737),
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(46),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                _requestingMutualCancel
                    ? 'Requesting...'
                    : 'Request mutual cancel OTP',
              ),
            ),
          ],
          if (showMutualCancel &&
              (_mutualCancelRequested || _mutualCancelOtpError != null)) ...[
            const SizedBox(height: 12),
            Builder(
              builder: (fieldContext) => TextField(
                controller: _mutualCancelOtpController,
                enabled: !_verifyingMutualCancel,
                keyboardType: TextInputType.number,
                scrollPadding: const EdgeInsets.only(bottom: 120),
                onTap: () => _ensureFieldVisibleAboveKeyboard(fieldContext),
                maxLength: 6,
                decoration: InputDecoration(
                  counterText: '',
                  hintText: 'OTP from labour',
                  errorText: _mutualCancelOtpError,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            FilledButton(
              onPressed: _verifyingMutualCancel ? null : _verifyMutualCancelOtp,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFB03737),
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(46),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                _verifyingMutualCancel
                    ? 'Cancelling...'
                    : 'Confirm mutual cancellation',
              ),
            ),
          ],
        ],
      ),
    );
  }

  BoxDecoration _whiteCardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: const Color(0xFFE8DCD6)),
      boxShadow: [
        BoxShadow(
          color: const Color(0x0F22314D),
          blurRadius: 18,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }

  Widget _buildInlineStatusBanner(String message, {required bool isError}) {
    final backgroundColor = isError
        ? const Color(0xFFFFECEE)
        : const Color(0xFFEAF7EE);
    final borderColor = isError
        ? const Color(0xFFF2B9C0)
        : const Color(0xFFB9DFC4);
    final textColor = isError
        ? const Color(0xFFB43A49)
        : const Color(0xFF1E7A43);
    final icon = isError
        ? Icons.error_outline_rounded
        : Icons.check_circle_outline_rounded;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: textColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w800,
                fontSize: 12.8,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _canCancelAfterReachDeadline(_ActiveBookingStatus status) {
    final reachByAt = status.reachByAt;
    return status.bookingStatus.toUpperCase() == 'PAYMENT_COMPLETED' &&
        reachByAt != null &&
        !_currentUtcTime().isBefore(reachByAt);
  }

  String _cancelButtonLabel(_ActiveBookingStatus status) {
    return 'Cancel';
  }

  String _reachCountdownLabel(_ActiveBookingStatus status) {
    final reachByAt = status.reachByAt;
    if (reachByAt == null) {
      return '--:--';
    }
    final remaining = reachByAt.difference(_currentUtcTime());
    if (remaining.isNegative || remaining.inSeconds <= 0) {
      return '00:00';
    }
    final totalHours = remaining.inHours;
    final minutes = remaining.inMinutes
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    final seconds = remaining.inSeconds
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    if (totalHours > 0) {
      return '${totalHours.toString().padLeft(2, '0')}:$minutes:$seconds';
    }
    return '${remaining.inMinutes.toString().padLeft(2, '0')}:$seconds';
  }

  String _providerTitle(_ActiveBookingStatus status) {
    final name = status.providerName.trim();
    if (name.isNotEmpty) {
      return name;
    }
    return status.bookingType.toUpperCase() == 'SERVICE'
        ? 'Service provider'
        : 'Labour';
  }

  String _pricingModelLabel(_ActiveBookingStatus status) {
    final raw = status.labourPricingModel.trim().toUpperCase();
    if (raw == 'HALF_DAY') {
      return 'Half Day';
    }
    if (raw == 'FULL_DAY') {
      return 'Full Day';
    }
    return status.bookingType.toUpperCase() == 'SERVICE'
        ? 'Service visit'
        : 'Labour booking';
  }

  String _timeOnly(DateTime? value) {
    final ist = _asIstDisplayTime(value);
    if (ist == null) {
      return '';
    }
    final hour = ist.hour.toString().padLeft(2, '0');
    final minute = ist.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _openFullMap(_ActiveBookingStatus status) {
    final initialProviderLocation = _providerTrackingLatLng(status);
    final initialDestinationLocation = _destinationTrackingLatLng(status);
    if (initialProviderLocation == null && initialDestinationLocation == null) {
      return;
    }
    GoogleMapController? dialogMapController;
    Timer? dialogRefreshTimer;

    Future<void> focusTrackingRoute({
      _ActiveBookingStatus? currentStatus,
    }) async {
      final controller = dialogMapController;
      if (controller == null) {
        return;
      }
      final liveStatus = currentStatus ?? _status ?? status;
      final providerLocation = _providerTrackingLatLng(liveStatus);
      final destinationLocation = _destinationTrackingLatLng(liveStatus);
      if (providerLocation != null && destinationLocation != null) {
        final southWest = LatLng(
          math.min(providerLocation.latitude, destinationLocation.latitude),
          math.min(providerLocation.longitude, destinationLocation.longitude),
        );
        final northEast = LatLng(
          math.max(providerLocation.latitude, destinationLocation.latitude),
          math.max(providerLocation.longitude, destinationLocation.longitude),
        );
        await controller.animateCamera(
          CameraUpdate.newLatLngBounds(
            LatLngBounds(southwest: southWest, northeast: northEast),
            80,
          ),
        );
        return;
      }
      final focus = providerLocation ?? destinationLocation;
      if (focus != null) {
        await controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: focus, zoom: 15.6),
          ),
        );
      }
    }

    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          dialogRefreshTimer ??= Timer.periodic(const Duration(seconds: 2), (
            _,
          ) {
            if (!dialogContext.mounted) {
              return;
            }
            setDialogState(() {});
          });
          final liveStatus = _status ?? status;
          final providerLocation = _providerTrackingLatLng(liveStatus);
          final destinationLocation = _destinationTrackingLatLng(liveStatus);
          final fallbackTarget =
              providerLocation ??
              destinationLocation ??
              const LatLng(26.8467, 80.9462);
          final etaLabel = _trackingRouteEtaLabel() ?? '';
          final distanceLabel = _trackingRouteDistanceLabel(liveStatus) ?? '';
          final bookingStatus = liveStatus.bookingStatus.trim().toUpperCase();
          final labourArrived =
              bookingStatus == 'ARRIVED' ||
              bookingStatus == 'IN_PROGRESS' ||
              bookingStatus == 'COMPLETED';
          final destinationName = _trackingDestinationName(liveStatus);
          return Dialog(
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            clipBehavior: Clip.antiAlias,
            child: SizedBox(
              height: MediaQuery.sizeOf(dialogContext).height * 0.78,
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 18, 18, 22),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: <Color>[
                          Color(0xFFD48E78),
                          Color(0xFFC9785F),
                          Color(0xFFB95E53),
                        ],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.place_rounded,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        destinationName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 12.8,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            InkWell(
                              onTap: () {
                                dialogRefreshTimer?.cancel();
                                dialogRefreshTimer = null;
                                Navigator.of(dialogContext).pop();
                              },
                              borderRadius: BorderRadius.circular(999),
                              child: Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.14),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _trackingArrivalHeadline(
                            liveStatus,
                            arrived: labourArrived,
                          ),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 17,
                            letterSpacing: -0.4,
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          labourArrived
                              ? 'Arrival confirmed'
                              : (etaLabel.trim().isNotEmpty
                                    ? 'Arriving in $etaLabel'
                                    : (distanceLabel.isNotEmpty
                                          ? distanceLabel
                                          : 'Live route updating')),
                          style: const TextStyle(
                            color: Color(0xFFFFF3EE),
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.sizeOf(dialogContext).height * 0.58,
                    child: Stack(
                      children: [
                        GoogleMap(
                          onMapCreated: (controller) {
                            dialogMapController = controller;
                            unawaited(
                              focusTrackingRoute(currentStatus: liveStatus),
                            );
                          },
                          initialCameraPosition: CameraPosition(
                            target:
                                providerLocation != null &&
                                    destinationLocation != null
                                ? LatLng(
                                    (providerLocation.latitude +
                                            destinationLocation.latitude) /
                                        2,
                                    (providerLocation.longitude +
                                            destinationLocation.longitude) /
                                        2,
                                  )
                                : fallbackTarget,
                            zoom:
                                providerLocation != null &&
                                    destinationLocation != null
                                ? 13
                                : 15.2,
                          ),
                          myLocationButtonEnabled: false,
                          zoomControlsEnabled: false,
                          compassEnabled: true,
                          markers: _trackingMarkers(liveStatus),
                          circles: _trackingCircles(liveStatus),
                          polylines: _trackingPolylines(liveStatus),
                        ),
                        Positioned(
                          top: 18,
                          right: 18,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => unawaited(
                                focusTrackingRoute(currentStatus: liveStatus),
                              ),
                              borderRadius: BorderRadius.circular(999),
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.18,
                                      ),
                                      blurRadius: 12,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.my_location_rounded,
                                  color: Color(0xFF11913C),
                                  size: 22,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 14,
                          bottom: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.88),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF2ED35A),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      distanceLabel.isNotEmpty
                                          ? 'BOOKING DESTINATION $distanceLabel'
                                          : 'BOOKING DESTINATION',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 10.8,
                                        letterSpacing: 0.4,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _trackingArrivalHeadline(
                                    status,
                                    arrived: labourArrived,
                                  ),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 12.2,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  labourArrived
                                      ? 'Arrival confirmed'
                                      : (etaLabel.isNotEmpty
                                            ? 'Arriving in $etaLabel'
                                            : (distanceLabel.isNotEmpty
                                                  ? distanceLabel
                                                  : 'Live route updating')),
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
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
    ).whenComplete(() {
      dialogRefreshTimer?.cancel();
      dialogRefreshTimer = null;
    });
  }

  LatLng? _providerTrackingLatLng(_ActiveBookingStatus status) {
    final lat = status.providerLatitude;
    final lng = status.providerLongitude;
    if (lat == null || lng == null) {
      return null;
    }
    return LatLng(lat, lng);
  }

  LatLng? _destinationTrackingLatLng(_ActiveBookingStatus status) {
    final lat = status.destinationLatitude;
    final lng = status.destinationLongitude;
    if (lat == null || lng == null) {
      return null;
    }
    return LatLng(lat, lng);
  }

  CameraPosition _trackingCameraPosition(_ActiveBookingStatus status) {
    final provider = _providerTrackingLatLng(status);
    final destination = _destinationTrackingLatLng(status);
    if (provider != null && destination != null) {
      return CameraPosition(
        target: LatLng(
          (provider.latitude + destination.latitude) / 2,
          (provider.longitude + destination.longitude) / 2,
        ),
        zoom: 12.8,
      );
    }
    final focus = provider ?? destination ?? const LatLng(26.8467, 80.9462);
    return CameraPosition(target: focus, zoom: 15.8);
  }

  double? _providerTrackingRotation(_ActiveBookingStatus status) {
    final polylinePoints = _routeSnapshot?.polylinePoints ?? const <LatLng>[];
    if (polylinePoints.length >= 2) {
      return _scooterMarkerRotationDegrees(
        polylinePoints.first,
        polylinePoints[1],
      );
    }
    final provider = _providerTrackingLatLng(status);
    final destination = _destinationTrackingLatLng(status);
    if (provider != null && destination != null) {
      return _scooterMarkerRotationDegrees(provider, destination);
    }
    return null;
  }

  Set<Marker> _trackingMarkers(_ActiveBookingStatus status) {
    final markers = <Marker>{};
    final provider = _providerTrackingLatLng(status);
    final destination = _destinationTrackingLatLng(status);
    final providerRotation = _providerTrackingRotation(status);
    if (provider != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('provider_live_location'),
          position: provider,
          infoWindow: InfoWindow(
            title: _providerTitle(status),
            snippet: 'Live labour location',
          ),
          flat: true,
          anchor: const Offset(0.5, 0.22),
          rotation: providerRotation ?? 0,
          icon:
              _providerScooterMarkerIcon ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    }
    if (destination != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('destination_location'),
          position: destination,
          infoWindow: const InfoWindow(title: 'Your location'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose),
        ),
      );
    }
    return markers;
  }

  Set<Polyline> _trackingPolylines(_ActiveBookingStatus status) {
    final provider = _providerTrackingLatLng(status);
    final destination = _destinationTrackingLatLng(status);
    if (provider == null || destination == null) {
      return const <Polyline>{};
    }
    final routePoints = _routeSnapshot?.polylinePoints ?? const <LatLng>[];
    return <Polyline>{
      Polyline(
        polylineId: const PolylineId('provider_to_destination'),
        points: routePoints.length >= 2
            ? routePoints
            : <LatLng>[provider, destination],
        width: 5,
        color: const Color(0xFFCB6E5B),
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
      ),
    };
  }

  Set<Circle> _trackingCircles(_ActiveBookingStatus status) {
    final destination = _destinationTrackingLatLng(status);
    if (destination == null) {
      return const <Circle>{};
    }
    final bookingStatus = status.bookingStatus.trim().toUpperCase();
    final arrived =
        bookingStatus == 'ARRIVED' ||
        bookingStatus == 'IN_PROGRESS' ||
        bookingStatus == 'COMPLETED';
    final baseStroke = arrived
        ? const Color(0xFFD12F2F)
        : const Color(0xFFE25555);
    final baseFill = arrived
        ? const Color(0x26D12F2F)
        : const Color(0x20E25555);
    return <Circle>{
      Circle(
        circleId: const CircleId('destination_geofence_outer'),
        center: destination,
        radius: 100,
        strokeWidth: 2,
        strokeColor: baseStroke,
        fillColor: baseFill,
      ),
      Circle(
        circleId: const CircleId('destination_geofence_mid'),
        center: destination,
        radius: 66,
        strokeWidth: 1,
        strokeColor: baseStroke.withValues(alpha: 0.55),
        fillColor: baseStroke.withValues(alpha: 0.10),
      ),
      Circle(
        circleId: const CircleId('destination_geofence_inner'),
        center: destination,
        radius: 34,
        strokeWidth: 1,
        strokeColor: baseStroke.withValues(alpha: 0.34),
        fillColor: baseStroke.withValues(alpha: 0.16),
      ),
    };
  }

  String? _trackingRouteDistanceLabel(_ActiveBookingStatus status) {
    final routeDistance = _routeSnapshot?.distanceLabel.trim() ?? '';
    if (routeDistance.isNotEmpty) {
      return routeDistance;
    }
    final provider = _providerTrackingLatLng(status);
    final destination = _destinationTrackingLatLng(status);
    if (provider == null || destination == null) {
      return null;
    }
    final distanceMeters = Geolocator.distanceBetween(
      provider.latitude,
      provider.longitude,
      destination.latitude,
      destination.longitude,
    );
    final distanceKm = distanceMeters / 1000;
    if (distanceKm >= 10) {
      return '${distanceKm.toStringAsFixed(0)} km';
    }
    return '${distanceKm.toStringAsFixed(1)} km';
  }

  String? _trackingRouteEtaLabel() {
    final value = _routeSnapshot?.durationLabel.trim() ?? '';
    return value.isEmpty ? null : value;
  }

  String _trackingDestinationName(_ActiveBookingStatus status) {
    final bookingType = status.bookingType.trim().toUpperCase();
    if (bookingType == 'SERVICE') {
      return 'Service destination';
    }
    return 'Your selected location';
  }

  String _trackingArrivalHeadline(
    _ActiveBookingStatus status, {
    required bool arrived,
  }) {
    final isService = status.bookingType.trim().toUpperCase() == 'SERVICE';
    if (arrived) {
      return isService ? 'Service has arrived' : 'Labour has arrived';
    }
    return isService
        ? 'Your service is on the way'
        : 'Your labour is on the way';
  }
}

class _BookingReviewDialog extends StatefulWidget {
  const _BookingReviewDialog({required this.status, required this.onSubmit});

  final _ActiveBookingStatus status;
  final Future<void> Function(int rating, String comment) onSubmit;

  @override
  State<_BookingReviewDialog> createState() => _BookingReviewDialogState();
}

class _BookingReviewDialogState extends State<_BookingReviewDialog> {
  final TextEditingController _commentController = TextEditingController();
  int _selectedRating = 0;
  bool _submitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  (String, Color) get _ratingTone {
    switch (_selectedRating) {
      case 1:
        return ('Very bad :(', const Color(0xFF8B1E1E));
      case 2:
        return ('Bad :/', const Color(0xFFE53935));
      case 3:
        return ('Okay :|', const Color(0xFFE7B928));
      case 4:
        return ('Good :)', const Color(0xFF53B96A));
      case 5:
        return ('Excellent :D', const Color(0xFF0B7A3B));
      default:
        return ('', const Color(0xFF22314D));
    }
  }

  @override
  Widget build(BuildContext context) {
    final (ratingLabel, ratingColor) = _ratingTone;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8F3),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.16),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Rate your booking',
                        style: TextStyle(
                          color: Color(0xFF22314D),
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.status.providerName.trim().isEmpty
                            ? 'Share your experience'
                            : 'How was ${widget.status.providerName}?',
                        style: const TextStyle(
                          color: Color(0xFF6D7A91),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: _submitting
                      ? null
                      : () => Navigator.of(context).pop(),
                  icon: const Icon(
                    Icons.close_rounded,
                    color: Color(0xFF6D7A91),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: List.generate(5, (index) {
                final star = index + 1;
                final selected = star <= _selectedRating;
                return InkWell(
                  onTap: _submitting
                      ? null
                      : () => setState(() => _selectedRating = star),
                  borderRadius: BorderRadius.circular(999),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Icon(
                      selected ? Icons.star_rounded : Icons.star_border_rounded,
                      size: 34,
                      color: selected ? ratingColor : const Color(0xFFD1C4B8),
                    ),
                  ),
                );
              }),
            ),
            if (ratingLabel.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                ratingLabel,
                style: TextStyle(
                  color: ratingColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
            const SizedBox(height: 14),
            TextField(
              controller: _commentController,
              maxLines: 4,
              minLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Add a comment',
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.all(14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(color: Color(0xFFE5D9D0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(color: Color(0xFFE5D9D0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(
                    color: Color(0xFFCB6E5B),
                    width: 1.3,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitting || _selectedRating <= 0
                    ? null
                    : () async {
                        final navigator = Navigator.of(context);
                        final messenger = ScaffoldMessenger.of(context);
                        setState(() => _submitting = true);
                        try {
                          await widget.onSubmit(
                            _selectedRating,
                            _commentController.text.trim(),
                          );
                          if (!mounted) {
                            return;
                          }
                          navigator.pop(true);
                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text('Thanks for sharing your rating.'),
                            ),
                          );
                        } on _UserAppApiException catch (error) {
                          if (!mounted) {
                            return;
                          }
                          messenger.showSnackBar(
                            SnackBar(content: Text(error.message)),
                          );
                        } finally {
                          if (mounted) {
                            setState(() => _submitting = false);
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFCB6E5B),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: Text(
                  _submitting ? 'Submitting...' : 'Submit rating',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrackingRouteSnapshot {
  const _TrackingRouteSnapshot({
    required this.polylinePoints,
    required this.distanceLabel,
    required this.durationLabel,
  });

  final List<LatLng> polylinePoints;
  final String distanceLabel;
  final String durationLabel;
}

class _HomeLocationOptionTile extends StatelessWidget {
  const _HomeLocationOptionTile({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final _HomeLocationChoice option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFFCEAE5) : const Color(0xFFF8F4EF),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected
                  ? const Color(0xFFCB6E5B)
                  : const Color(0xFFE9DED5),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: selected ? const Color(0xFFCB6E5B) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  option.isCurrentLocation
                      ? Icons.my_location_rounded
                      : Icons.location_on_outlined,
                  color: selected ? Colors.white : const Color(0xFF22314D),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF22314D),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      option.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF6E7B91),
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              if (selected)
                const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFFCB6E5B),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeLocationSelectorSheet extends StatefulWidget {
  const _HomeLocationSelectorSheet({
    required this.options,
    required this.selectedLocation,
    required this.canManageAddresses,
    required this.searchSuggestions,
    required this.resolveSuggestion,
    required this.sameChoice,
  });

  final List<_HomeLocationChoice> options;
  final _HomeLocationChoice? selectedLocation;
  final bool canManageAddresses;
  final Future<List<_HomeLocationSearchSuggestion>> Function(String query)
  searchSuggestions;
  final Future<_HomeLocationChoice?> Function(
    _HomeLocationSearchSuggestion suggestion,
  )
  resolveSuggestion;
  final bool Function(_HomeLocationChoice left, _HomeLocationChoice right)
  sameChoice;

  @override
  State<_HomeLocationSelectorSheet> createState() =>
      _HomeLocationSelectorSheetState();
}

class _HomeLocationSelectorSheetState
    extends State<_HomeLocationSelectorSheet> {
  static const double _defaultMapZoom = 17;
  static const double _savedAddressTileHeight = 58;
  static const double _savedAddressTileGap = 8;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<_HomeLocationSearchSuggestion> _searchResults =
      const <_HomeLocationSearchSuggestion>[];
  bool _searching = false;
  String? _searchError;
  Timer? _searchDebounce;
  GoogleMapController? _mapController;
  _HomeLocationChoice? _previewLocation;
  _HomeLocationChoice? _resolvedPreviewLocation;
  bool _resolvingPreviewAddress = false;
  bool _searchMode = false;
  LatLng? _pendingCameraTarget;
  double _currentMapZoom = _defaultMapZoom;

  _HomeLocationChoice _mapPickedLocationFrom(
    _HomeLocationChoice? source, {
    required double latitude,
    required double longitude,
    String? title,
    String? subtitle,
    String? city,
  }) {
    return _HomeLocationChoice(
      title: title ?? source?.title ?? 'Selected location',
      subtitle:
          subtitle ??
          source?.subtitle ??
          'Lat ${latitude.toStringAsFixed(5)}, Lng ${longitude.toStringAsFixed(5)}',
      city: city ?? source?.city ?? '',
      latitude: latitude,
      longitude: longitude,
      isCurrentLocation: true,
    );
  }

  @override
  void initState() {
    super.initState();
    final initialLocation =
        widget.selectedLocation ??
        widget.options
            .where((option) => option.isCurrentLocation)
            .firstOrNull ??
        widget.options.firstOrNull;
    _previewLocation = initialLocation;
    _resolvedPreviewLocation = initialLocation;
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  void _enterSearchMode() {
    if (_searchMode) {
      return;
    }
    setState(() {
      _searchMode = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _searchFocusNode.requestFocus();
    });
  }

  void _exitSearchMode({bool clearQuery = false}) {
    _searchDebounce?.cancel();
    FocusScope.of(context).unfocus();
    setState(() {
      _searchMode = false;
      _searching = false;
      _searchError = null;
      _searchResults = clearQuery
          ? const <_HomeLocationSearchSuggestion>[]
          : _searchResults;
      if (clearQuery) {
        _searchController.clear();
      }
    });
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    final query = value.trim();
    if (query.isEmpty) {
      setState(() {
        _searchResults = const <_HomeLocationSearchSuggestion>[];
        _searchError = null;
      });
      return;
    }
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      unawaited(_runSearch());
    });
  }

  Future<void> _runSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      if (!mounted) {
        return;
      }
      setState(() {
        _searchResults = const <_HomeLocationSearchSuggestion>[];
        _searchError = null;
        _searching = false;
      });
      return;
    }
    setState(() {
      _searching = true;
      _searchError = null;
    });
    try {
      final results = await widget.searchSuggestions(query);
      if (!mounted) {
        return;
      }
      setState(() {
        _searchResults = results;
        _searchError = results.isEmpty
            ? 'No matching place found for that search.'
            : null;
        _searching = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _searchResults = const <_HomeLocationSearchSuggestion>[];
        _searchError = 'Could not search places right now.';
        _searching = false;
      });
    }
  }

  Future<void> _selectSearchResult(
    _HomeLocationSearchSuggestion suggestion,
  ) async {
    setState(() {
      _resolvingPreviewAddress = true;
      _searchError = null;
    });
    try {
      final option = await widget.resolveSuggestion(suggestion);
      if (!mounted) {
        return;
      }
      if (option == null) {
        setState(() {
          _searchError = 'Could not resolve that place right now.';
          _resolvingPreviewAddress = false;
        });
        return;
      }
      setState(() {
        _searchMode = false;
        _searchController.clear();
        _searchResults = const <_HomeLocationSearchSuggestion>[];
        _previewLocation = option;
        _resolvedPreviewLocation = option;
        _resolvingPreviewAddress = true;
        _searchError = null;
        _currentMapZoom = _defaultMapZoom;
      });
      FocusScope.of(context).unfocus();
      await _moveMapCamera(
        option.latitude,
        option.longitude,
        zoom: _defaultMapZoom,
      );
      await _resolvePreviewLocation(
        option.latitude,
        option.longitude,
        fallback: option,
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _searchError = 'Could not resolve that place right now.';
        _resolvingPreviewAddress = false;
      });
    }
  }

  Future<void> _moveMapCamera(
    double latitude,
    double longitude, {
    double? zoom,
  }) async {
    final controller = _mapController;
    if (controller == null) {
      return;
    }
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(latitude, longitude),
          zoom: zoom ?? _currentMapZoom,
        ),
      ),
    );
  }

  Future<void> _goToCurrentLocation() async {
    final currentLocation = widget.options
        .where((option) => option.isCurrentLocation)
        .firstOrNull;
    if (currentLocation == null) {
      setState(() {
        _searchError = 'Current location is not available right now.';
      });
      return;
    }
    setState(() {
      _previewLocation = currentLocation;
      _resolvedPreviewLocation = currentLocation;
      _resolvingPreviewAddress = true;
      _searchError = null;
      _searchMode = false;
      _currentMapZoom = _defaultMapZoom;
    });
    await _moveMapCamera(
      currentLocation.latitude,
      currentLocation.longitude,
      zoom: _defaultMapZoom,
    );
    await _resolvePreviewLocation(
      currentLocation.latitude,
      currentLocation.longitude,
      fallback: currentLocation,
    );
  }

  Future<void> _resolvePreviewLocation(
    double latitude,
    double longitude, {
    _HomeLocationChoice? fallback,
  }) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (!mounted) {
        return;
      }
      final placemark = placemarks.firstOrNull;
      final titleParts = <String>[
        if ((placemark?.name ?? '').trim().isNotEmpty) placemark!.name!.trim(),
        if ((placemark?.subLocality ?? '').trim().isNotEmpty)
          placemark!.subLocality!.trim(),
        if ((placemark?.locality ?? '').trim().isNotEmpty)
          placemark!.locality!.trim(),
      ];
      final subtitleParts = <String>[
        if ((placemark?.thoroughfare ?? '').trim().isNotEmpty)
          placemark!.thoroughfare!.trim(),
        if ((placemark?.subAdministrativeArea ?? '').trim().isNotEmpty)
          placemark!.subAdministrativeArea!.trim(),
        if ((placemark?.administrativeArea ?? '').trim().isNotEmpty)
          placemark!.administrativeArea!.trim(),
        if ((placemark?.postalCode ?? '').trim().isNotEmpty)
          placemark!.postalCode!.trim(),
      ];
      setState(() {
        _resolvedPreviewLocation = _mapPickedLocationFrom(
          fallback,
          title: titleParts.isEmpty
              ? (fallback?.title ?? 'Selected location')
              : titleParts.join(', '),
          subtitle: subtitleParts.isEmpty
              ? (fallback?.subtitle ??
                    'Lat ${latitude.toStringAsFixed(5)}, Lng ${longitude.toStringAsFixed(5)}')
              : subtitleParts.join(', '),
          city:
              (placemark?.locality ??
                      placemark?.subAdministrativeArea ??
                      fallback?.city ??
                      '')
                  .trim(),
          latitude: latitude,
          longitude: longitude,
        );
        _resolvingPreviewAddress = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _resolvedPreviewLocation = _mapPickedLocationFrom(
          fallback,
          title: fallback?.title ?? 'Selected location',
          subtitle:
              fallback?.subtitle ??
              'Lat ${latitude.toStringAsFixed(5)}, Lng ${longitude.toStringAsFixed(5)}',
          city: fallback?.city ?? '',
          latitude: latitude,
          longitude: longitude,
        );
        _resolvingPreviewAddress = false;
      });
    }
  }

  Future<void> _updatePreviewPin(LatLng position) async {
    final previous = _resolvedPreviewLocation ?? _previewLocation;
    setState(() {
      _previewLocation = _mapPickedLocationFrom(
        previous,
        latitude: position.latitude,
        longitude: position.longitude,
      );
      _resolvedPreviewLocation = previous == null
          ? null
          : _mapPickedLocationFrom(
              previous,
              latitude: position.latitude,
              longitude: position.longitude,
            );
      _resolvingPreviewAddress = true;
    });
    await _resolvePreviewLocation(
      position.latitude,
      position.longitude,
      fallback: previous,
    );
  }

  List<_HomeLocationChoice> get _savedAddressOptions => widget.options
      .where((option) => !option.isCurrentLocation && option.addressId != null)
      .toList(growable: false);

  List<_HomeLocationChoice> _footerAddressOptions(
    _HomeLocationChoice previewLocation,
  ) {
    final options = <_HomeLocationChoice>[
      _mapPickedLocationFrom(
        previewLocation,
        title: previewLocation.title,
        subtitle: previewLocation.subtitle,
        city: previewLocation.city,
        latitude: previewLocation.latitude,
        longitude: previewLocation.longitude,
      ),
    ];
    for (final option in _savedAddressOptions) {
      final sameCoordinates =
          (option.latitude - previewLocation.latitude).abs() < 0.000001 &&
          (option.longitude - previewLocation.longitude).abs() < 0.000001;
      if (sameCoordinates) {
        continue;
      }
      options.add(option);
    }
    return options;
  }

  double _savedAddressListHeightFor(int count) {
    if (count <= 0) {
      return 0;
    }
    if (count == 1) {
      return _savedAddressTileHeight;
    }
    return (_savedAddressTileHeight * 2) + _savedAddressTileGap;
  }

  Future<void> _selectSavedAddressOption(_HomeLocationChoice option) async {
    setState(() {
      _previewLocation = option;
      _resolvedPreviewLocation = option;
      _resolvingPreviewAddress = true;
      _searchError = null;
      _searchMode = false;
    });
    FocusScope.of(context).unfocus();
    await _moveMapCamera(option.latitude, option.longitude);
    await _resolvePreviewLocation(
      option.latitude,
      option.longitude,
      fallback: option,
    );
  }

  Widget _buildSearchResultsView(double safeTop, double safeBottom) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, safeTop + 8, 16, safeBottom + 12),
      child: Column(
        children: [
          Container(
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFE3DAEE)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => _exitSearchMode(clearQuery: true),
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Color(0xFF5A2A8D),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    textInputAction: TextInputAction.search,
                    onChanged: _onSearchChanged,
                    onSubmitted: (_) => unawaited(_runSearch()),
                    decoration: const InputDecoration(
                      hintText: 'Search for area, street name...',
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(
                      color: Color(0xFF202435),
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (_searching)
                  const Padding(
                    padding: EdgeInsets.only(right: 16),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2.2),
                    ),
                  )
                else
                  IconButton(
                    onPressed: () {
                      _searchController.clear();
                      _onSearchChanged('');
                    },
                    icon: const Icon(
                      Icons.cancel_outlined,
                      color: Color(0xFF7D4BA4),
                      size: 30,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F1FA),
                borderRadius: BorderRadius.circular(28),
              ),
              child: _searchResults.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          _searchError ??
                              'Type an area, street, landmark, or city to see matching places.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF6E6480),
                            fontWeight: FontWeight.w700,
                            height: 1.4,
                          ),
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
                      itemCount: _searchResults.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final item = _searchResults[index];
                        return _HomeLocationSuggestionTile(
                          suggestion: item,
                          onTap: () => unawaited(_selectSearchResult(item)),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapConfirmView(
    BuildContext context,
    _HomeLocationChoice previewLocation,
    double safeTop,
    double safeBottom,
  ) {
    final footerOptions = _footerAddressOptions(previewLocation);
    return Stack(
      children: [
        Positioned.fill(
          child: GoogleMap(
            onMapCreated: (controller) {
              _mapController = controller;
              unawaited(
                _moveMapCamera(
                  previewLocation.latitude,
                  previewLocation.longitude,
                  zoom: _currentMapZoom,
                ),
              );
            },
            initialCameraPosition: CameraPosition(
              target: LatLng(
                previewLocation.latitude,
                previewLocation.longitude,
              ),
              zoom: _currentMapZoom,
            ),
            mapType: MapType.normal,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            markers: const <Marker>{},
            onCameraMove: (position) {
              _pendingCameraTarget = position.target;
              _currentMapZoom = position.zoom;
            },
            onCameraIdle: () {
              final target = _pendingCameraTarget;
              if (target == null) {
                return;
              }
              final current = _resolvedPreviewLocation ?? _previewLocation;
              if (current != null) {
                final latitudeChanged =
                    (current.latitude - target.latitude).abs() > 0.000001;
                final longitudeChanged =
                    (current.longitude - target.longitude).abs() > 0.000001;
                if (!latitudeChanged && !longitudeChanged) {
                  return;
                }
              }
              unawaited(_updatePreviewPin(target));
            },
          ),
        ),
        Positioned(
          top: safeTop + 18,
          left: 22,
          child: InkWell(
            onTap: () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(999),
            child: const Padding(
              padding: EdgeInsets.all(7),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Color(0xFF5A2A8D),
                size: 18,
              ),
            ),
          ),
        ),
        Positioned(
          top: safeTop + 12,
          left: 68,
          right: 34,
          child: Material(
            color: Colors.white,
            elevation: 8,
            shadowColor: Colors.black.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: _enterSearchMode,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: const Row(
                  children: [
                    Icon(
                      Icons.search_rounded,
                      color: Color(0xFF7D4BA4),
                      size: 23,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Search for area, street name...',
                        style: TextStyle(
                          color: Color(0xFF9C8AB8),
                          fontSize: 13.4,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const Center(
          child: IgnorePointer(
            child: Padding(
              padding: EdgeInsets.only(bottom: 28),
              child: Icon(
                Icons.place_rounded,
                size: 58,
                color: Color(0xFFD93025),
              ),
            ),
          ),
        ),
        Positioned(
          right: 20,
          bottom: 244,
          child: Material(
            color: Colors.white,
            elevation: 6,
            shadowColor: Color(0x2E000000),
            borderRadius: BorderRadius.circular(18),
            child: InkWell(
              onTap: () => unawaited(_goToCurrentLocation()),
              borderRadius: BorderRadius.circular(18),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE3DAEE)),
                ),
                child: const Icon(
                  Icons.my_location_rounded,
                  color: Color(0xFFD48E78),
                  size: 26,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            padding: EdgeInsets.fromLTRB(20, 6, 20, safeBottom + 14),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: _savedAddressListHeightFor(footerOptions.length),
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: footerOptions.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final option = footerOptions[index];
                      final isSelected = widget.sameChoice(
                        previewLocation,
                        option,
                      );
                      return Material(
                        color: isSelected
                            ? const Color(0xFFF6E7E2)
                            : const Color(0xFFF7F6FA),
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          onTap: () =>
                              unawaited(_selectSavedAddressOption(option)),
                          borderRadius: BorderRadius.circular(16),
                          child: Ink(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFFD48E78)
                                    : const Color(0xFFE6E1EF),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                12,
                                10,
                                12,
                                10,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 34,
                                    height: 34,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? const Color(0xFFD48E78)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.location_on_rounded,
                                      color: isSelected
                                          ? Colors.white
                                          : const Color(0xFFD48E78),
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          option.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Color(0xFF2E185C),
                                            fontWeight: FontWeight.w800,
                                            fontSize: 13.2,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          option.subtitle,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Color(0xFF6F6A7A),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 11.6,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isSelected)
                                    const Icon(
                                      Icons.check_circle_rounded,
                                      color: Color(0xFFD48E78),
                                      size: 20,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (_resolvingPreviewAddress) ...[
                  const SizedBox(height: 10),
                  const Text(
                    'Updating the address for the current map pin...',
                    style: TextStyle(
                      color: Color(0xFF7D4BA4),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(previewLocation),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFD48E78),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text(
                      'Select Address',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final safeTop = MediaQuery.paddingOf(context).top;
    final safeBottom = MediaQuery.paddingOf(context).bottom > 12
        ? MediaQuery.paddingOf(context).bottom
        : 12.0;
    final previewLocation = _resolvedPreviewLocation ?? _previewLocation;
    return Container(
      width: double.infinity,
      color: Colors.white,
      child: SafeArea(
        top: false,
        child: previewLocation == null
            ? const Center(child: CircularProgressIndicator())
            : (_searchMode
                  ? _buildSearchResultsView(safeTop, safeBottom)
                  : _buildMapConfirmView(
                      context,
                      previewLocation,
                      safeTop,
                      safeBottom,
                    )),
      ),
    );
  }
}

class _HomeLocationSuggestionTile extends StatelessWidget {
  const _HomeLocationSuggestionTile({
    required this.suggestion,
    required this.onTap,
  });

  final _HomeLocationSearchSuggestion suggestion;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final subtitle = suggestion.subtitle.trim().isEmpty
        ? suggestion.description.trim()
        : suggestion.subtitle.trim();
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F3FC),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.location_on_outlined,
                  color: Color(0xFF5A2A8D),
                  size: 30,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      suggestion.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF2E185C),
                        fontWeight: FontWeight.w900,
                        fontSize: 15.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF6F6A7A),
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CurvedBodyTransition extends StatelessWidget {
  const _CurvedBodyTransition({
    required this.colors,
    this.compact = false,
    this.foreground,
    this.foregroundHeight = 0,
  });

  final List<Color> colors;
  final bool compact;
  final Widget? foreground;
  final double foregroundHeight;

  @override
  Widget build(BuildContext context) {
    final hasForeground = foreground != null;
    final transitionHeight = hasForeground
        ? foregroundHeight + 34
        : (compact ? 54.0 : 84.0);
    final waveHeight = compact ? 44.0 : 72.0;

    return SizedBox(
      height: transitionHeight,
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [colors.first, colors[1], colors[2], colors[2]],
                  stops: const [0, 0.36, 0.84, 1],
                ),
              ),
            ),
          ),
          Positioned(
            left: -24,
            right: -24,
            bottom: 0,
            child: ClipPath(
              clipper: _HeaderWaveClipper(),
              child: Container(
                height: waveHeight,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 20,
                      offset: Offset(0, -4),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (hasForeground)
            Positioned(left: 0, right: 0, bottom: 8, child: foreground!),
        ],
      ),
    );
  }
}

class _HeaderWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()..lineTo(0, size.height * 0.82);
    path.cubicTo(
      size.width * 0.20,
      size.height * 0.82,
      size.width * 0.30,
      size.height * 0.18,
      size.width * 0.50,
      size.height * 0.18,
    );
    path.cubicTo(
      size.width * 0.70,
      size.height * 0.18,
      size.width * 0.80,
      size.height * 0.82,
      size.width,
      size.height * 0.82,
    );
    path
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

part of '../../main.dart';

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

class UserHomePage extends StatefulWidget {
  const UserHomePage({
    super.key,
    this.phoneNumber,
  });

  final String? phoneNumber;

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  static const Set<String> _shopComingSoonCategories = <String>{};
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final Set<String> _favouriteProfiles = <String>{};
  final Set<String> _wishlistedItems = <String>{};
  final List<_DiscoveryItem> _cartItems = <_DiscoveryItem>[];
  final List<_DiscoveryItem> _backendTopProducts = <_DiscoveryItem>[];
  final List<_DiscoveryItem> _labourRemoteProfiles = <_DiscoveryItem>[];
  final List<_DiscoveryItem> _serviceRemoteProviders = <_DiscoveryItem>[];
  final List<_DiscoveryItem> _restaurantRemoteProducts = <_DiscoveryItem>[];
  final List<_FashionRemoteProduct> _fashionRemoteProducts = <_FashionRemoteProduct>[];
  final List<_FootwearRemoteProduct> _footwearRemoteProducts = <_FootwearRemoteProduct>[];
  final List<_RestaurantRemoteShopSummary> _restaurantRemoteShops = <_RestaurantRemoteShopSummary>[];
  final List<_FashionRemoteShopSummary> _fashionRemoteShops = <_FashionRemoteShopSummary>[];
  final List<_FootwearRemoteShopSummary> _footwearRemoteShops = <_FootwearRemoteShopSummary>[];
  final List<_GiftRemoteProduct> _giftRemoteProducts = <_GiftRemoteProduct>[];
  final List<_GiftRemoteShopSummary> _giftRemoteShops = <_GiftRemoteShopSummary>[];
  final List<_GroceryRemoteProduct> _groceryRemoteProducts = <_GroceryRemoteProduct>[];
  final List<_GroceryRemoteShopSummary> _groceryRemoteShops = <_GroceryRemoteShopSummary>[];
  final List<_PharmacyRemoteProduct> _pharmacyRemoteProducts = <_PharmacyRemoteProduct>[];
  final List<_PharmacyRemoteShopSummary> _pharmacyRemoteShops = <_PharmacyRemoteShopSummary>[];

  _HomeMode _mode = _HomeMode.all;
  _LabourViewMode _labourViewMode = _LabourViewMode.individual;
  _ShopBrowseMode _shopBrowseMode = _ShopBrowseMode.itemWise;
  String _selectedServiceCategory = 'Automobile';
  String _selectedServiceSubCategory = 'All';
  String _selectedShopCategory = 'All Deals';
  String _selectedShopSubCategory = 'All';
  String _selectedRestaurantCuisine = 'All';
  String _selectedLabourCategory = 'All labour';
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
  List<_ActiveBookingStatus> _activeBookingStatuses = const <_ActiveBookingStatus>[];
  int _activeBookingIndex = 0;
  Offset _activeBookingPopupOffset = Offset.zero;
  bool _activeBookingPopupPositionInitialized = false;
  bool _activeBookingPopupDragMoved = false;
  List<_UserAddressData> _savedAddresses = const <_UserAddressData>[];
  _HomeLocationChoice? _currentLocationChoice;
  _HomeLocationChoice? _selectedLocationChoice;
  bool _homeLocationLoading = true;
  String? _homeLocationError;
  bool _showScrollToTop = false;
  bool _remoteSyncInFlight = false;
  String? _homeBootstrapError;
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
  List<_RemoteLabourCategory> _labourRemoteCategories = const <_RemoteLabourCategory>[];
  List<_RemoteServiceCategory> _serviceRemoteCategories = const <_RemoteServiceCategory>[];
  List<_RestaurantCuisineItem> _restaurantRemoteCuisines = const <_RestaurantCuisineItem>[];
  List<_FashionRemoteCategory> _fashionRemoteCategories = const <_FashionRemoteCategory>[];
  List<_FootwearRemoteCategory> _footwearRemoteCategories = const <_FootwearRemoteCategory>[];
  List<_GiftRemoteCategory> _giftRemoteCategories = const <_GiftRemoteCategory>[];
  List<_GroceryRemoteCategory> _groceryRemoteCategories = const <_GroceryRemoteCategory>[];
  List<_PharmacyRemoteCategory> _pharmacyRemoteCategories = const <_PharmacyRemoteCategory>[];
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
  bool _guestLocationPromptShown = false;
  String _headerProfilePhotoDataUri = '';
  String? _sessionPhoneNumber;
  StreamSubscription<_NotificationEvent>? _notificationEventSubscription;
  int _discoveryBatchInFlightCount = 0;
  bool _initialDiscoveryBatchResolved = false;

  static const int _fashionProductBatchSize = 20;
  static const int _fashionProductTotalCount = 120;
  static const int _footwearProductBatchSize = 20;
  static const int _footwearProductTotalCount = 120;

  @override
  void initState() {
    super.initState();
    _sessionPhoneNumber = widget.phoneNumber?.trim();
    _scrollController.addListener(_handleScroll);
    _notificationEventSubscription = _NotificationBootstrap.events.listen(_handleNotificationEvent);
    unawaited(_hydrateRemoteState());
    unawaited(_loadLabourBookingPolicy());
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
    _notificationEventSubscription?.cancel();
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    _searchController.dispose();
    super.dispose();
  }

  _ActiveBookingStatus? get _activeBookingStatus {
    if (_activeBookingStatuses.isEmpty) {
      return null;
    }
    final safeIndex = _activeBookingIndex.clamp(0, _activeBookingStatuses.length - 1);
    return _activeBookingStatuses[safeIndex];
  }

  void _setActiveBookingStatuses(List<_ActiveBookingStatus> statuses) {
    _activeBookingStatuses = statuses;
    if (_activeBookingStatuses.isEmpty) {
      _activeBookingIndex = 0;
      _activeBookingPopupPositionInitialized = false;
      return;
    }
    _activeBookingIndex = _activeBookingIndex.clamp(0, _activeBookingStatuses.length - 1);
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
    final matchIndex = updated.indexWhere((entry) => entry.requestId == status.requestId);
    if (matchIndex >= 0) {
      updated[matchIndex] = status;
      _activeBookingIndex = matchIndex;
    } else {
      updated.insert(0, status);
      _activeBookingIndex = 0;
    }
    _setActiveBookingStatuses(updated);
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


  Future<void> _hydrateRemoteState({bool silent = true}) async {
  if (_remoteSyncInFlight) {
    return;
  }
  if (mounted) {
    setState(() {
      _remoteSyncInFlight = true;
      _homeBootstrapError = null;
    });
  } else {
    _remoteSyncInFlight = true;
    _homeBootstrapError = null;
  }
  try {
    final remoteProducts = await _UserAppApi.fetchHomeTopProducts();
    _RemoteCartState? remoteCart;
    List<_ActiveBookingStatus> activeBookings = const <_ActiveBookingStatus>[];
    String profilePhotoDataUri = '';
    if (_isAuthenticated) {
      final results = await Future.wait<dynamic>([
        _UserAppApi.fetchCart(),
        _loadActiveBookingStatusesSafe(),
        _loadProfilePhotoPreviewSafe(),
      ]);
      remoteCart = results[0] as _RemoteCartState;
      activeBookings = results[1] as List<_ActiveBookingStatus>;
      profilePhotoDataUri = results[2] as String;
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _backendTopProducts
        ..clear()
        ..addAll(remoteProducts);
      if (remoteCart != null) {
        _cartShopName = remoteCart.shopName.isEmpty ? null : remoteCart.shopName;
        _cartItems
          ..clear()
          ..addAll(remoteCart.items);
        _localCartNeedsSync = false;
      }
      _headerProfilePhotoDataUri = _isAuthenticated ? profilePhotoDataUri : '';
      _setActiveBookingStatuses(_isAuthenticated ? activeBookings : const <_ActiveBookingStatus>[]);
      _homeBootstrapError = null;
    });
    if (_isAuthenticated) {
      unawaited(_refreshNotificationPreview(silent: true));
    }
  } on _UserAppApiException catch (error) {
    if (mounted) {
      setState(() {
        _homeBootstrapError = error.message;
      });
    } else {
      _homeBootstrapError = error.message;
    }
    if (!silent && mounted) {
      _showCartSnack(error.message);
    }
  } catch (_) {
    if (mounted) {
      setState(() {
        _homeBootstrapError = 'Could not refresh live user app data right now.';
      });
    } else {
      _homeBootstrapError = 'Could not refresh live user app data right now.';
    }
    if (!silent && mounted) {
      _showCartSnack('Could not refresh live user app data right now.');
    }
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
    if (!event.openedApp && _BookingUpdateSoundPlayer.shouldPlayForUserEvent(event.type)) {
      unawaited(_BookingUpdateSoundPlayer.play());
    }
    await _refreshNotificationPreview(silent: true);
    await _hydrateRemoteState(silent: true);
    if (!mounted) {
      return;
    }

    if (event.openedApp) {
      if (event.isOrderRelated) {
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const _OrdersPage(),
          ),
        );
        await _refreshNotificationPreview(silent: true);
      } else if (event.isBookingRelated) {
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const _MyBookingsPage(),
          ),
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
              Text(
                event.body,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        action: SnackBarAction(
          label: 'View',
          onPressed: () {
            if (event.isOrderRelated) {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const _OrdersPage(),
                ),
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
      final notifications = await _UserAppApi.fetchNotifications(page: 0, size: 1);
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
  final savedPhoneNumber = (await _LocalSessionStore.readPhoneNumber())?.trim() ?? '';
  if (!mounted || savedPhoneNumber == _currentPhoneNumber) {
    return;
  }
  setState(() {
    _sessionPhoneNumber = savedPhoneNumber.isEmpty ? null : savedPhoneNumber;
  });
}

Future<String> _loadProfilePhotoPreviewSafe() async {
  try {
    final profile = await _UserAppApi.fetchProfile();
    return profile.profilePhotoDataUri.trim();
  } catch (_) {
    return '';
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
      _showCartSnack('Login completed, but the session could not be restored.');
    }
    return false;
  }
  if (!mounted) {
    return true;
  }
  setState(() {
    _sessionPhoneNumber = savedPhoneNumber.trim();
  });
  await _NotificationBootstrap.ensureRegistered();
  await _loadHomeLocationOptions();
  await _reloadAddressAwareDiscovery(silent: true);
  await _hydrateRemoteState(silent: true);
  await _refreshNotificationPreview(silent: true);
  return true;
}

Future<void> _syncLocalCartToBackend() async {
  if (!_isAuthenticated || !_localCartNeedsSync) {
    return;
  }
  final syncableItems = _cartItems.where((item) => item.backendProductId != null).toList(growable: false);
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
      _cartShopName = remoteCart!.shopName.isEmpty ? null : remoteCart.shopName;
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
      await _enforceHomePermissions();
      await _loadHomeLocationOptions(forceCurrentSelection: true);
      if (!_isAuthenticated && !_guestLocationPromptShown && mounted) {
        _guestLocationPromptShown = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            unawaited(_openHomeLocationSelector(showManageAddresses: false));
          }
        });
      }
      await _NotificationBootstrap.ensureRegistered();
      await _reloadAddressAwareDiscovery();
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


Future<void> _loadHomeLocationOptions({bool forceCurrentSelection = false}) async {
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
    final previousSelection = _selectedLocationChoice;
    _HomeLocationChoice? selectedLocation;
    if (forceCurrentSelection && currentLocation != null) {
      selectedLocation = currentLocation;
    } else {
      selectedLocation = previousSelection;
      if (selectedLocation != null && !selectedLocation.isCurrentLocation) {
        final selectedAddress = addresses.where((item) => item.id == selectedLocation!.addressId).firstOrNull;
        if (selectedAddress != null) {
          selectedLocation = _locationChoiceFromAddress(selectedAddress);
        } else {
          selectedLocation = null;
        }
      } else if (selectedLocation?.isCurrentLocation == true) {
        selectedLocation = currentLocation;
      }
      selectedLocation ??= currentLocation;
      selectedLocation ??= addresses.where((item) => item.isDefault).map(_locationChoiceFromAddress).firstOrNull;
      selectedLocation ??= addresses.map(_locationChoiceFromAddress).firstOrNull;
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
    final placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
    final placemark = placemarks.isEmpty ? null : placemarks.first;
    final city = (placemark?.locality ?? placemark?.subAdministrativeArea ?? '').trim();
    final subtitleParts = <String>[
      if ((placemark?.subLocality ?? '').trim().isNotEmpty) placemark!.subLocality!.trim(),
      if ((placemark?.locality ?? '').trim().isNotEmpty) placemark!.locality!.trim(),
      if ((placemark?.administrativeArea ?? '').trim().isNotEmpty) placemark!.administrativeArea!.trim(),
      if ((placemark?.postalCode ?? '').trim().isNotEmpty) placemark!.postalCode!.trim(),
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

  Future<void> _openHomeLocationSelector({bool? showManageAddresses}) async {
    final canManageAddresses = showManageAddresses ?? _isAuthenticated;
    final result = await showModalBottomSheet<Object?>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        final options = <_HomeLocationChoice>[
          ...?_currentLocationChoice == null ? null : <_HomeLocationChoice>[_currentLocationChoice!],
          ..._savedAddresses.map(_locationChoiceFromAddress),
        ];
        final safeBottom = MediaQuery.viewPaddingOf(context).bottom > 12
            ? MediaQuery.viewPaddingOf(context).bottom
            : 12.0;
        return Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(18, 16, 18, safeBottom + 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
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
                const SizedBox(height: 16),
                const Text(
                  'Choose delivery location',
                  style: TextStyle(
                    color: Color(0xFF202435),
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Nearby shops will refresh from the location you choose here.',
                  style: TextStyle(
                    color: const Color(0xFF202435).withValues(alpha: 0.65),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        for (final option in options)
                          _HomeLocationOptionTile(
                            option: option,
                            selected: option.addressId == _selectedLocationChoice?.addressId &&
                                option.isCurrentLocation == _selectedLocationChoice?.isCurrentLocation,
                            onTap: () => Navigator.of(context).pop(option),
                          ),
                      ],
                    ),
                  ),
                ),
                if (canManageAddresses) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).pop('manage'),
                      icon: const Icon(Icons.edit_location_alt_rounded),
                      label: const Text('Manage saved addresses'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
    if (!mounted || result == null) {
      return;
    }
    if (result == 'manage') {
      final canContinue = await _ensureAuthenticated();
      if (!mounted || !canContinue) {
        return;
      }
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const _AddressesPage(),
        ),
      );
      await _loadHomeLocationOptions();
      await _reloadAddressAwareDiscovery(silent: false);
      return;
    }
    if (result is _HomeLocationChoice) {
      setState(() {
        _selectedLocationChoice = result;
      });
      await _reloadAddressAwareDiscovery(silent: false);
    }
  }

  Future<void> _reloadAddressAwareDiscovery({bool silent = true}) async {
    if (mounted) {
      setState(() {
        _discoveryBatchInFlightCount++;
      });
    } else {
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
          _discoveryBatchInFlightCount = math.max(0, _discoveryBatchInFlightCount - 1);
          _initialDiscoveryBatchResolved = true;
        });
      } else {
        _discoveryBatchInFlightCount = math.max(0, _discoveryBatchInFlightCount - 1);
        _initialDiscoveryBatchResolved = true;
      }
    }
  }

  Future<void> _refreshVisiblePage() async {
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
        _maxGroupLabourCount = policy.maxGroupLabourCount <= 0 ? 7 : policy.maxGroupLabourCount;
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
    final labels = landing.categories.map((item) => item.label).toList(growable: false);
    setState(() {
      _labourRemoteCategories = landing.categories;
      _labourRemoteProfiles
        ..clear()
        ..addAll(landing.profiles);
      _labourRemoteReady = true;
      _labourRemoteError = null;
      if (!labels.contains(_selectedLabourCategory)) {
        _selectedLabourCategory = labels.isEmpty ? 'All labour' : labels.first;
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
          _selectedLabourCategory = 'All labour';
        });
      } else {
        _labourRemoteReady = true;
        _labourRemoteCategories = const <_RemoteLabourCategory>[];
        _labourRemoteProfiles.clear();
        _labourRemoteError = null;
        _selectedLabourCategory = 'All labour';
      }
      return;
    }
    if (mounted) {
      setState(() {
        _labourRemoteError = error.message;
      });
    } else {
      _labourRemoteError = error.message;
    }
    if (!silent && mounted) {
      _showCartSnack(error.message);
    }
  } catch (_) {
    if (mounted) {
      setState(() {
        _labourRemoteError = 'Could not load labour profiles right now.';
      });
    } else {
      _labourRemoteError = 'Could not load labour profiles right now.';
    }
    if (!silent && mounted) {
      _showCartSnack('Could not load labour profiles right now.');
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
      final categoryLabels = landing.categories.map((item) => item.label).toList(growable: false);
      setState(() {
        _serviceRemoteCategories = landing.categories;
        _serviceRemoteProviders
          ..clear()
          ..addAll(landing.providers);
        _serviceRemoteReady = true;
        _serviceRemoteError = null;
        if (!categoryLabels.contains(_selectedServiceCategory)) {
          _selectedServiceCategory = categoryLabels.isEmpty ? 'Automobile' : categoryLabels.first;
        }
        final subcategoryOptions = _selectedServiceSubcategories;
        if (!subcategoryOptions.contains(_selectedServiceSubCategory)) {
          _selectedServiceSubCategory = subcategoryOptions.isEmpty ? 'All' : subcategoryOptions.first;
        }
      });
    } on _UserAppApiException catch (error) {
      if (_shouldTreatAsEmptyResults(error.message)) {
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
      if (!silent && mounted) {
        _showCartSnack(error.message);
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _serviceRemoteError = 'Could not load service providers right now.';
        });
      } else {
        _serviceRemoteError = 'Could not load service providers right now.';
      }
      if (!silent && mounted) {
        _showCartSnack('Could not load service providers right now.');
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
      if (_shouldTreatAsEmptyResults(error.message)) {
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
      if (!silent && mounted) {
        _showCartSnack(error.message);
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _restaurantRemoteError = 'Could not load restaurant data right now.';
        });
      } else {
        _restaurantRemoteError = 'Could not load restaurant data right now.';
      }
      if (!silent && mounted) {
        _showCartSnack('Could not load restaurant data right now.');
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
        productPage = await _UserAppApi.fetchFashionProducts(categoryId: selectedCategoryId);
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
      if (_shouldTreatAsEmptyResults(error.message)) {
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
      if (mounted) {
        setState(() {
          _fashionRemoteError = error.message;
        });
      } else {
        _fashionRemoteError = error.message;
      }
      if (!silent && mounted) {
        _showCartSnack(error.message);
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _fashionRemoteError = 'Could not load fashion data right now.';
        });
      } else {
        _fashionRemoteError = 'Could not load fashion data right now.';
      }
      if (!silent && mounted) {
        _showCartSnack('Could not load fashion data right now.');
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
        productPage = await _UserAppApi.fetchFootwearProducts(categoryId: selectedCategoryId);
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
      if (_shouldTreatAsEmptyResults(error.message)) {
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
      if (mounted) {
        setState(() {
          _footwearRemoteError = error.message;
        });
      } else {
        _footwearRemoteError = error.message;
      }
      if (!silent && mounted) {
        _showCartSnack(error.message);
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _footwearRemoteError = 'Could not load footwear data right now.';
        });
      } else {
        _footwearRemoteError = 'Could not load footwear data right now.';
      }
      if (!silent && mounted) {
        _showCartSnack('Could not load footwear data right now.');
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
      final selectedCategoryId = _giftCategoryIdForLabel(_selectedShopSubCategory, categories: landing.categories);
      if (_selectedShopSubCategory != 'All' && selectedCategoryId != null) {
        productPage = await _UserAppApi.fetchGiftProducts(categoryId: selectedCategoryId);
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
      if (_shouldTreatAsEmptyResults(error.message)) {
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
      if (mounted) {
        setState(() {
          _giftRemoteError = error.message;
        });
      } else {
        _giftRemoteError = error.message;
      }
      if (!silent && mounted) {
        _showCartSnack(error.message);
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _giftRemoteError = 'Could not load gift data right now.';
        });
      } else {
        _giftRemoteError = 'Could not load gift data right now.';
      }
      if (!silent && mounted) {
        _showCartSnack('Could not load gift data right now.');
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
      final selectedCategoryId =
          _groceryCategoryIdForLabel(_selectedShopSubCategory, categories: landing.categories);
      if (_selectedShopSubCategory != 'All' && selectedCategoryId != null) {
        productPage = await _UserAppApi.fetchGroceryProducts(categoryId: selectedCategoryId);
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
      if (_shouldTreatAsEmptyResults(error.message)) {
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
      if (mounted) {
        setState(() {
          _groceryRemoteError = error.message;
        });
      } else {
        _groceryRemoteError = error.message;
      }
      if (!silent && mounted) {
        _showCartSnack(error.message);
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _groceryRemoteError = 'Could not load grocery data right now.';
        });
      } else {
        _groceryRemoteError = 'Could not load grocery data right now.';
      }
      if (!silent && mounted) {
        _showCartSnack('Could not load grocery data right now.');
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
      final selectedCategoryId =
          _pharmacyCategoryIdForLabel(_selectedShopSubCategory, categories: landing.categories);
      if (_selectedShopSubCategory != 'All' && selectedCategoryId != null) {
        productPage = await _UserAppApi.fetchPharmacyProducts(categoryId: selectedCategoryId);
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
      if (_shouldTreatAsEmptyResults(error.message)) {
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
      if (mounted) {
        setState(() {
          _pharmacyRemoteError = error.message;
        });
      } else {
        _pharmacyRemoteError = error.message;
      }
      if (!silent && mounted) {
        _showCartSnack(error.message);
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _pharmacyRemoteError = 'Could not load pharmacy data right now.';
        });
      } else {
        _pharmacyRemoteError = 'Could not load pharmacy data right now.';
      }
      if (!silent && mounted) {
        _showCartSnack('Could not load pharmacy data right now.');
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

  Future<int?> _resolveGroupLabourCategoryId() async {
    final selectedId = _labourCategoryIdForLabel(_selectedLabourCategory);
    if (selectedId != null) {
      return selectedId;
    }
    final options = _labourRemoteCategories
        .where((category) => category.backendCategoryId != null)
        .toList(growable: false);
    if (options.isEmpty) {
      return null;
    }
    final selected = await showModalBottomSheet<_RemoteLabourCategory>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
        decoration: const BoxDecoration(
          color: Color(0xFFF7F2EC),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFD8C7BC),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Select labour type',
              style: TextStyle(
                color: Color(0xFF22314D),
                fontWeight: FontWeight.w900,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Group request will go to all matching labour in this type and in your selected range.',
              style: TextStyle(
                color: Color(0xFF66748C),
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 14),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: options.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final category = options[index];
                  return ListTile(
                    onTap: () => Navigator.of(context).pop(category),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    tileColor: Colors.white,
                    leading: const Icon(Icons.engineering_rounded, color: Color(0xFFCB6E5B)),
                    title: Text(
                      category.label,
                      style: const TextStyle(
                        color: Color(0xFF22314D),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
    if (selected == null) {
      return null;
    }
    if (mounted) {
      setState(() {
        _selectedLabourCategory = selected.label;
        _showLabourCountError = false;
        _labourCountErrorText = null;
      });
      unawaited(_loadLabourLanding(silent: false));
    }
    return selected.backendCategoryId;
  }

  int _availableLabourCountForGroupCategory(int? categoryId) {
    final profiles = categoryId == null
        ? _labourRemoteProfiles
        : _labourRemoteProfiles.where((item) => item.backendCategoryId == categoryId);
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

  int? _serviceSubcategoryIdForSelection(String categoryLabel, String subcategoryLabel) {
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

Future<void> _selectFashionSubcategory(String value, {bool silent = true}) async {
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
    if (_fashionRemoteLoading || !_fashionRemoteReady || !_fashionRemoteHasMore) {
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

  Future<void> _selectFootwearSubcategory(String value, {bool silent = true}) async {
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

  Future<void> _selectGiftSubcategory(String value, {bool silent = true}) async {
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

  Future<void> _selectGrocerySubcategory(String value, {bool silent = true}) async {
    setState(() {
      _selectedShopSubCategory = value;
      _groceryRemoteLoading = true;
      _groceryRemoteProducts.clear();
      _groceryRemoteError = null;
    });
    final categoryId = _groceryCategoryIdForLabel(value);
    try {
      final page = await _UserAppApi.fetchGroceryProducts(categoryId: categoryId);
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

  Future<void> _selectPharmacySubcategory(String value, {bool silent = true}) async {
    setState(() {
      _selectedShopSubCategory = value;
      _pharmacyRemoteLoading = true;
      _pharmacyRemoteProducts.clear();
      _pharmacyRemoteError = null;
    });
    final categoryId = _pharmacyCategoryIdForLabel(value);
    try {
      final page = await _UserAppApi.fetchPharmacyProducts(categoryId: categoryId);
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
    if (_footwearRemoteLoading || !_footwearRemoteReady || !_footwearRemoteHasMore) {
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
    if (_groceryRemoteLoading || !_groceryRemoteReady || !_groceryRemoteHasMore) return;
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
    if (_pharmacyRemoteLoading || !_pharmacyRemoteReady || !_pharmacyRemoteHasMore) return;
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

  int? _giftCategoryIdForLabel(String label, {List<_GiftRemoteCategory>? categories}) {
    for (final item in categories ?? _giftRemoteCategories) {
      if (item.label == label) return item.backendCategoryId;
    }
    return null;
  }

  int? _groceryCategoryIdForLabel(String label, {List<_GroceryRemoteCategory>? categories}) {
    for (final item in categories ?? _groceryRemoteCategories) {
      if (item.label == label) return item.backendCategoryId;
    }
    return null;
  }

  int? _pharmacyCategoryIdForLabel(String label, {List<_PharmacyRemoteCategory>? categories}) {
    for (final item in categories ?? _pharmacyRemoteCategories) {
      if (item.label == label) return item.backendCategoryId;
    }
    return null;
  }

  void _handleScroll() {
    final next = _scrollController.offset > 320;
    final shouldLoadMoreFashion = _mode == _HomeMode.shop &&
        _shopBrowseMode == _ShopBrowseMode.itemWise &&
        _selectedShopCategory == 'Fashion' &&
        (_fashionRemoteReady
            ? (_fashionRemoteHasMore && !_fashionRemoteLoading)
            : (_fashionVisibleProductCount < _fashionProductTotalCount && !_fashionLoadMoreQueued)) &&
        _scrollController.position.extentAfter < 700;
    final shouldLoadMoreFootwear = _mode == _HomeMode.shop &&
        _shopBrowseMode == _ShopBrowseMode.itemWise &&
        _selectedShopCategory == 'Footwear' &&
        (_footwearRemoteReady
            ? (_footwearRemoteHasMore && !_footwearRemoteLoading)
            : (_footwearVisibleProductCount < _footwearProductTotalCount && !_footwearLoadMoreQueued)) &&
        _scrollController.position.extentAfter < 700;
    final shouldLoadMoreGift = _mode == _HomeMode.shop &&
        _shopBrowseMode == _ShopBrowseMode.itemWise &&
        _selectedShopCategory == 'Gift' &&
        _giftRemoteReady &&
        _giftRemoteHasMore &&
        !_giftRemoteLoading &&
        _scrollController.position.extentAfter < 700;
    final shouldLoadMoreGrocery = _mode == _HomeMode.shop &&
        _shopBrowseMode == _ShopBrowseMode.itemWise &&
        _selectedShopCategory == 'Groceries' &&
        _groceryRemoteReady &&
        _groceryRemoteHasMore &&
        !_groceryRemoteLoading &&
        _scrollController.position.extentAfter < 700;
    final shouldLoadMorePharmacy = _mode == _HomeMode.shop &&
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
            (_fashionVisibleProductCount + _fashionProductBatchSize).clamp(0, _fashionProductTotalCount).toInt();
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
            (_footwearVisibleProductCount + _footwearProductBatchSize).clamp(0, _footwearProductTotalCount).toInt();
        _footwearLoadMoreQueued = false;
      });
    });
  }

  Future<void> _openShopSortSheet() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        const options = ['Popular', 'Low to High', 'High to Low', 'Newly Added'];
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
                initialGender: _selectedShopSubCategory == 'All' ? 'Men' : _selectedShopSubCategory,
              )
            : _selectedShopCategory == 'Gift'
                ? _ShopGiftFilterPage(
                    initialCategory: _selectedShopSubCategory == 'All' ? 'Flowers' : _selectedShopSubCategory,
                  )
            : _selectedShopCategory == 'Groceries'
                ? _ShopGroceryFilterPage(
                    initialCategory: _selectedShopSubCategory == 'All' ? 'Biscuits' : _selectedShopSubCategory,
                  )
                : _selectedShopCategory == 'Pharmacy'
                    ? _ShopPharmacyFilterPage(
                        initialCategory: _selectedShopSubCategory == 'All' ? 'Wellness' : _selectedShopSubCategory,
                      )
                : _ShopFilterPage(
                    initialGender: _selectedShopSubCategory == 'All' ? 'Men' : _selectedShopSubCategory,
                  ),
      ),
    );
    if (applied == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Filters applied. API filtering will connect with backend pagination next.')),
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
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
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
    String message = 'We are opening this around your selected location. Please check again soon.',
  }) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFFF5E8),
                Color(0xFFFDF1F8),
                Color(0xFFEFF7FF),
              ],
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: const Color(0xFFF0D7B0),
            ),
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
                child: Icon(
                  icon,
                  color: const Color(0xFFCB6E5B),
                  size: 28,
                ),
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
              const SizedBox(height: 8),
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
  if (_labourRemoteLoading && _labourRemoteProfiles.isEmpty) {
    return _buildRemoteStateSliver(
      icon: Icons.engineering_rounded,
      title: 'Loading labour nearby',
      message: 'We are fetching the latest available labour profiles for you.',
      loading: true,
    );
  }
  if (_labourRemoteError != null && _labourRemoteProfiles.isEmpty) {
    return _buildRemoteStateSliver(
      icon: Icons.cloud_off_rounded,
      title: 'Could not load labour',
      message: _labourRemoteError!,
      actionLabel: 'Try Again',
      onAction: () => unawaited(_loadLabourLanding(silent: false)),
    );
  }
  if (_labourRemoteReady && _labourRemoteProfiles.isEmpty) {
    final selectedCategoryName = _selectedLabourCategory.trim().isEmpty ? 'labour category' : _selectedLabourCategory;
    final isAllCategory = selectedCategoryName == 'All labour';
    return _buildAreaComingSoonSliver(
      icon: Icons.engineering_rounded,
      title: isAllCategory ? 'Coming soon in your area....!' : 'No labour available yet',
      message: isAllCategory
          ? 'We are onboarding more labour partners near your selected location every day. Please check again soon.'
          : 'No labour is available yet for $selectedCategoryName. Every day we are onboarding more labour partners to help them get jobs and help you get work done faster.',
    );
  }
  return null;
}

List<_DiscoveryItem> get _filteredSingleLabourProfiles {
  final period = _selectedSingleLabourPeriod.trim().toUpperCase();
  final maxPrice = _parseMoneyAmount(_selectedSingleLabourMaxPrice);
  return _labourRemoteProfiles.where((item) {
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
  }).toList(growable: false);
}

double _parseMoneyAmount(String value) {
  final normalized = value.replaceAll(RegExp(r'[^0-9.]'), '');
  return double.tryParse(normalized) ?? 0;
}

Widget? _buildServiceStateSliver() {
    if (_serviceRemoteLoading && _serviceRemoteProviders.isEmpty) {
      return _buildRemoteStateSliver(
        icon: Icons.handyman_rounded,
        title: 'Loading service providers',
        message: 'We are fetching live providers for the category you selected.',
        loading: true,
      );
    }
    if (_serviceRemoteError != null && _serviceRemoteProviders.isEmpty) {
      return _buildRemoteStateSliver(
        icon: Icons.cloud_off_rounded,
        title: 'Could not load services',
        message: _serviceRemoteError!,
        actionLabel: 'Try Again',
        onAction: () => unawaited(_loadServiceLanding(silent: false)),
      );
    }
    if (_serviceRemoteReady && _serviceRemoteProviders.isEmpty) {
      return _buildAreaComingSoonSliver(
        icon: Icons.handyman_rounded,
        message: 'No service provider is registered within your selected range yet.',
      );
    }
    return null;
  }

  Widget? _buildShopRemoteStateSliver() {
    if (_showShopAllLanding) {
      final hasAnyShopData = _restaurantRemoteProducts.isNotEmpty ||
          _restaurantRemoteShops.isNotEmpty ||
          (_fashionRemoteReady &&
              (_fashionRemoteProducts.isNotEmpty || _fashionRemoteShops.isNotEmpty)) ||
          (_footwearRemoteReady &&
              (_footwearRemoteProducts.isNotEmpty || _footwearRemoteShops.isNotEmpty)) ||
          (_giftRemoteReady && (_giftRemoteProducts.isNotEmpty || _giftRemoteShops.isNotEmpty)) ||
          (_groceryRemoteReady &&
              (_groceryRemoteProducts.isNotEmpty || _groceryRemoteShops.isNotEmpty)) ||
          (_pharmacyRemoteReady &&
              (_pharmacyRemoteProducts.isNotEmpty || _pharmacyRemoteShops.isNotEmpty));
      if (!hasAnyShopData) {
        return _buildAreaComingSoonSliver(
          icon: Icons.storefront_rounded,
          message: 'No shop is registered within your selected range yet.',
        );
      }
      return null;
    }
    if (_showShopRestaurantLanding) {
      final hasData = _restaurantRemoteProducts.isNotEmpty ||
          _restaurantRemoteShops.isNotEmpty ||
          _restaurantRemoteCuisines.isNotEmpty;
      if (_restaurantRemoteLoading && !hasData) {
        return _buildRemoteStateSliver(
          icon: Icons.restaurant_menu_rounded,
          title: 'Loading restaurants',
          message: 'We are bringing in live restaurants, cuisines, and shop listings.',
          loading: true,
        );
      }
      if (_restaurantRemoteError != null && !hasData) {
        return _buildRemoteStateSliver(
          icon: Icons.cloud_off_rounded,
          title: 'Could not load restaurants',
          message: _restaurantRemoteError!,
          actionLabel: 'Try Again',
          onAction: () => unawaited(_loadRestaurantLanding(silent: false)),
        );
      }
      if (!hasData) {
        return _buildAreaComingSoonSliver(
          icon: Icons.restaurant_menu_rounded,
          message: 'No restaurant is registered within your selected range yet.',
        );
      }
      return null;
    }

    switch (_selectedShopCategory) {
      case 'Fashion':
        final hasData = _fashionRemoteProducts.isNotEmpty || _fashionRemoteShops.isNotEmpty;
        if (_fashionRemoteLoading && !hasData) {
          return _buildRemoteStateSliver(
            icon: Icons.checkroom_rounded,
            title: 'Loading fashion items',
            message: 'We are fetching the latest items and nearby fashion shops.',
            loading: true,
          );
        }
        if (_fashionRemoteError != null && !hasData) {
          return _buildRemoteStateSliver(
            icon: Icons.cloud_off_rounded,
            title: 'Could not load fashion',
            message: _fashionRemoteError!,
            actionLabel: 'Try Again',
            onAction: () => unawaited(_loadFashionLanding(silent: false)),
          );
        }
        if (_fashionRemoteReady && !hasData) {
          return _buildAreaComingSoonSliver(
            icon: Icons.checkroom_rounded,
            message: 'No fashion shop is registered within your selected range yet.',
          );
        }
        return null;
      case 'Footwear':
        final hasData = _footwearRemoteProducts.isNotEmpty || _footwearRemoteShops.isNotEmpty;
        if (_footwearRemoteLoading && !hasData) {
          return _buildRemoteStateSliver(
            icon: Icons.shopping_bag_outlined,
            title: 'Loading footwear',
            message: 'We are fetching the latest footwear items and shop listings.',
            loading: true,
          );
        }
        if (_footwearRemoteError != null && !hasData) {
          return _buildRemoteStateSliver(
            icon: Icons.cloud_off_rounded,
            title: 'Could not load footwear',
            message: _footwearRemoteError!,
            actionLabel: 'Try Again',
            onAction: () => unawaited(_loadFootwearLanding(silent: false)),
          );
        }
        if (_footwearRemoteReady && !hasData) {
          return _buildAreaComingSoonSliver(
            icon: Icons.shopping_bag_outlined,
            message: 'No footwear shop is registered within your selected range yet.',
          );
        }
        return null;
      case 'Gift':
        final hasData = _giftRemoteProducts.isNotEmpty || _giftRemoteShops.isNotEmpty;
        if (_giftRemoteLoading && !hasData) {
          return _buildRemoteStateSliver(
            icon: Icons.redeem_rounded,
            title: 'Loading gifts',
            message: 'We are fetching gift items and shop picks for this selection.',
            loading: true,
          );
        }
        if (_giftRemoteError != null && !hasData) {
          return _buildRemoteStateSliver(
            icon: Icons.cloud_off_rounded,
            title: 'Could not load gifts',
            message: _giftRemoteError!,
            actionLabel: 'Try Again',
            onAction: () => unawaited(_loadGiftLanding(silent: false)),
          );
        }
        if (_giftRemoteReady && !hasData) {
          return _buildAreaComingSoonSliver(
            icon: Icons.redeem_rounded,
            message: 'No gift shop is registered within your selected range yet.',
          );
        }
        return null;
      case 'Groceries':
        final hasData = _groceryRemoteProducts.isNotEmpty || _groceryRemoteShops.isNotEmpty;
        if (_groceryRemoteLoading && !hasData) {
          return _buildRemoteStateSliver(
            icon: Icons.local_grocery_store_rounded,
            title: 'Loading groceries',
            message: 'We are fetching grocery items and nearby shop listings.',
            loading: true,
          );
        }
        if (_groceryRemoteError != null && !hasData) {
          return _buildRemoteStateSliver(
            icon: Icons.cloud_off_rounded,
            title: 'Could not load groceries',
            message: _groceryRemoteError!,
            actionLabel: 'Try Again',
            onAction: () => unawaited(_loadGroceryLanding(silent: false)),
          );
        }
        if (_groceryRemoteReady && !hasData) {
          return _buildAreaComingSoonSliver(
            icon: Icons.local_grocery_store_rounded,
            message: 'No grocery shop is registered within your selected range yet.',
          );
        }
        return null;
      case 'Pharmacy':
        final hasData = _pharmacyRemoteProducts.isNotEmpty || _pharmacyRemoteShops.isNotEmpty;
        if (_pharmacyRemoteLoading && !hasData) {
          return _buildRemoteStateSliver(
            icon: Icons.local_pharmacy_rounded,
            title: 'Loading pharmacy items',
            message: 'We are fetching live pharmacy inventory and nearby shops.',
            loading: true,
          );
        }
        if (_pharmacyRemoteError != null && !hasData) {
          return _buildRemoteStateSliver(
            icon: Icons.cloud_off_rounded,
            title: 'Could not load pharmacy',
            message: _pharmacyRemoteError!,
            actionLabel: 'Try Again',
            onAction: () => unawaited(_loadPharmacyLanding(silent: false)),
          );
        }
        if (_pharmacyRemoteReady && !hasData) {
          return _buildAreaComingSoonSliver(
            icon: Icons.local_pharmacy_rounded,
            message: 'No pharmacy shop is registered within your selected range yet.',
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

  void _ensureShopSelectionIsVisible() {
    if (_mode != _HomeMode.shop) {
      return;
    }
    final availableCategories = _availableShopCategories;
    final fallbackCategory =
        availableCategories.isEmpty ? 'All Deals' : availableCategories.first;
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
            ? _labourRemoteCategories.map((item) => item.label).toList(growable: false)
            : const <String>[];
      case _HomeMode.service:
        return _serviceRemoteCategories.isNotEmpty
            ? _serviceRemoteCategories.map((item) => item.label).toList(growable: false)
            : const <String>[];
      case _HomeMode.shop:
        return _availableShopCategories;
    }
  }


  List<String> get _selectedServiceSubcategories =>
      _serviceRemoteCategories.isNotEmpty
          ? _serviceRemoteCategories
              .where((category) => category.label == _selectedServiceCategory)
              .expand((category) => category.subcategories)
              .map((subcategory) => subcategory.label)
              .toList(growable: false)
          : const <String>['All'];

  List<_DiscoveryItem> get _filteredServiceProviders {
    return _serviceRemoteProviders;
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
              disabledLabel: (!shop.acceptsOrders || shop.eta == 'Closed') ? 'Closed' : '',
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
                    : (shop.closesAt.isEmpty ? 'Open now' : 'Closes ${shop.closesAt}'))
                : 'Closed',
            extra: 'Fashion shop',
            shopCategory: 'Fashion',
            backendShopId: shop.shopId,
            isDisabled: !shop.openNow || !shop.acceptsOrders,
            disabledLabel: (!shop.openNow || !shop.acceptsOrders) ? 'Closed' : '',
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
                    : (shop.closesAt.isEmpty ? 'Open now' : 'Closes ${shop.closesAt}'))
                : 'Closed',
            extra: 'Footwear shop',
            shopCategory: 'Footwear',
            backendShopId: shop.shopId,
            isDisabled: !shop.openNow || !shop.acceptsOrders,
            disabledLabel: (!shop.openNow || !shop.acceptsOrders) ? 'Closed' : '',
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
          ? _fashionRemoteCategories.map((item) => item.label).toList(growable: false)
          : _selectedShopCategory == 'Footwear' && _footwearRemoteCategories.isNotEmpty
              ? _footwearRemoteCategories.map((item) => item.label).toList(growable: false)
              : _selectedShopCategory == 'Gift' && _giftRemoteCategories.isNotEmpty
                  ? _giftRemoteCategories.map((item) => item.label).toList(growable: false)
                  : _selectedShopCategory == 'Groceries' && _groceryRemoteCategories.isNotEmpty
                      ? _groceryRemoteCategories.map((item) => item.label).toList(growable: false)
                      : _selectedShopCategory == 'Pharmacy' && _pharmacyRemoteCategories.isNotEmpty
                          ? _pharmacyRemoteCategories.map((item) => item.label).toList(growable: false)
                          : const <String>['All'];

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    const pinnedSearchHeaderHeight = 58.0;
    const pinnedModeHeaderHeight = 44.0;
    const pinnedFilterHeaderHeight = 58.0;

    _ensureShopSelectionIsVisible();
    final showActiveBookingPopup = _activeBookingStatus != null && (_mode == _HomeMode.all || _mode == _HomeMode.labour);

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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _HomeHeader(
                                title: _selectedLocationChoice?.title ?? 'Choose location',
                                subtitle: _selectedLocationChoice?.subtitle ??
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
                          padding: const EdgeInsets.fromLTRB(18, 4, 18, 6),
                          child: _PinnedSearchHeader(
                            controller: _searchController,
                            hint: _searchHint,
                            tint: _modeTint(_mode),
                          onNotificationTap: _openNotificationsPage,
                          onProfileTap: _openProfilePage,
                          onCartTap: _openCartPage,
                          unreadNotificationCount: _notificationUnreadCount,
                          profilePhotoDataUri: _headerProfilePhotoDataUri,
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 2),
                              _ModeSwitcher(
                                mode: _mode,
                                onModeSelected: (mode) {
                                  setState(() {
                                    if (mode == _HomeMode.labour && _mode != mode) {
                                      _selectedLabourCategory = 'All labour';
                                    }
                                    _mode = mode;
                                  });
                                  if (mode == _HomeMode.labour) {
                                    unawaited(_loadLabourLanding(silent: false));
                                  } else if (mode == _HomeMode.service) {
                                    unawaited(_loadServiceLanding(silent: false));
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (_mode != _HomeMode.all && _modeFilters.isNotEmpty)
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
                                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
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
                        foregroundHeight: _mode == _HomeMode.shop &&
                                _shopBrowseMode == _ShopBrowseMode.itemWise &&
                                _selectedShopSubcategories.length > 1
                            ? 116
                            : 76,
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
    final title = status.providerName.trim().isNotEmpty
        ? status.providerName
        : status.bookingType.toUpperCase() == 'SERVICE'
            ? 'Service booking'
            : 'Labour booking';
    final canShowPrevious = _activeBookingIndex > 0;
    final canShowNext = _activeBookingIndex < _activeBookingStatuses.length - 1;
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
    final maxTop = math.max(minTop, screenSize.height - bottomInset - cardHeight - 12);
    final boundedLeft = (_activeBookingPopupPositionInitialized
            ? _activeBookingPopupOffset.dx
            : maxLeft)
        .clamp(minLeft, maxLeft)
        .toDouble();
    final boundedTop = (_activeBookingPopupPositionInitialized
            ? _activeBookingPopupOffset.dy
            : defaultTop)
        .clamp(minTop, maxTop)
        .toDouble();

    return Positioned(
      left: boundedLeft,
      top: boundedTop,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onPanStart: (_) {
          _activeBookingPopupDragMoved = false;
        },
        onPanUpdate: (details) {
          _activeBookingPopupDragMoved = true;
          setState(() {
            _activeBookingPopupOffset = Offset(
              (boundedLeft + details.delta.dx).clamp(minLeft, maxLeft).toDouble(),
              (boundedTop + details.delta.dy).clamp(minTop, maxTop).toDouble(),
            );
            _activeBookingPopupPositionInitialized = true;
          });
        },
        onHorizontalDragEnd: (details) {
          final velocity = details.primaryVelocity ?? 0;
          if (velocity < -120 && canShowNext) {
            setState(() => _activeBookingIndex++);
          } else if (velocity > 120 && canShowPrevious) {
            setState(() => _activeBookingIndex--);
          }
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
                    if (_activeBookingStatuses.length > 1)
                      _activeBookingSwitcherButton(
                        icon: Icons.chevron_left_rounded,
                        enabled: canShowPrevious,
                        onTap: canShowPrevious ? () => setState(() => _activeBookingIndex--) : null,
                      ),
                    if (_activeBookingStatuses.length > 1) const SizedBox(width: 8),
                    Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          if (_activeBookingPopupDragMoved) {
                            return;
                          }
                          _openActiveBookingSheet(status);
                        },
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
                                      _liveBookingStatusLabel(status),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.88),
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
                    ),
                    const SizedBox(width: 8),
                    if (_activeBookingStatuses.length > 1) ...[
                      _activeBookingSwitcherButton(
                        icon: Icons.chevron_right_rounded,
                        enabled: canShowNext,
                        onTap: canShowNext ? () => setState(() => _activeBookingIndex++) : null,
                      ),
                      const SizedBox(width: 8),
                    ],
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(999),
                        onTap: () {
                          if (_activeBookingPopupDragMoved) {
                            return;
                          }
                          _openActiveBookingSheet(status);
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
                if (_activeBookingStatuses.length > 1) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _activeBookingStatuses.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        width: index == _activeBookingIndex ? 16 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: index == _activeBookingIndex
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.38),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _activeBookingSwitcherButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: enabled ? Colors.white.withValues(alpha: 0.18) : Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Icon(
          icon,
          color: enabled ? Colors.white : Colors.white.withValues(alpha: 0.42),
          size: 18,
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
        return _selectedServiceCategory;
      case _HomeMode.shop:
        return _modeFilters.contains(_selectedShopCategory)
            ? _selectedShopCategory
            : (_modeFilters.isEmpty ? _selectedShopCategory : _modeFilters.first);
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


List<_ActiveBookingStatus> _filterVisibleActiveBookings(List<_ActiveBookingStatus> statuses) {
  return statuses.where((status) {
    final requestStatus = status.requestStatus.trim().toUpperCase();
    return !(requestStatus == 'OPEN' && !status.canMakePayment && status.bookingId <= 0);
  }).toList(growable: false);
}

Future<List<_ActiveBookingStatus>> _loadActiveBookingStatusesSafe() async {
  if (!_isAuthenticated) {
    return const <_ActiveBookingStatus>[];
  }
  try {
    return _filterVisibleActiveBookings(await _UserAppApi.fetchActiveBookingStatuses());
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
      ),
    );
  }

  String _liveBookingStatusLabel(_ActiveBookingStatus status) {
    if (status.canMakePayment) {
      return 'Accepted. Pay booking charges.';
    }
    final bookingStatus = status.bookingStatus.trim().toUpperCase();
    switch (bookingStatus) {
      case 'PAYMENT_COMPLETED':
        return 'Payment done. Track labour arrival.';
      case 'ARRIVED':
        return 'Labour arrived. Enter OTP to start.';
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
        final payment = await _UserAppApi.initiateServiceBookingPayment(status.requestId);
        if (!mounted) {
          return;
        }
        final paymentResult = await _PaymentFlow.start(
          context,
          paymentCode: payment.paymentCode,
          title: 'Confirm service booking',
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
          successTitle: 'Service booking confirmed',
          failureTitle: 'Service payment incomplete',
          extraLines: [
            'Booking code: ${payment.bookingCode}',
            if (status.providerName.trim().isNotEmpty) 'Provider: ${status.providerName}',
            if (status.distanceLabel.trim().isNotEmpty) 'Distance: ${status.distanceLabel}',
            'Amount: ${payment.amountLabel}',
          ],
        );
        return;
      }
      final payment = await _UserAppApi.initiateLabourBookingPayment(status.requestId);
      if (!mounted) {
        return;
      }
      final paymentResult = await _PaymentFlow.start(
        context,
        paymentCode: payment.paymentCode,
        title: 'Confirm labour booking',
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
        successTitle: 'Labour booking confirmed',
        failureTitle: 'Labour payment incomplete',
        extraLines: [
          'Booking code: ${payment.bookingCode}',
          if (status.providerName.trim().isNotEmpty) 'Labour: ${status.providerName}',
          if (status.distanceLabel.trim().isNotEmpty) 'Distance: ${status.distanceLabel}',
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
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
          child: Row(
            children: [
              Expanded(
                child: _LabourModeCard(
                  label: 'Single booking',
                  icon: Icons.engineering_rounded,
                  selected: _labourViewMode == _LabourViewMode.individual,
                  onTap: () => setState(() => _labourViewMode = _LabourViewMode.individual),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: _LabourModeCard(
                  label: 'Group booking',
                  icon: Icons.groups_2_rounded,
                  selected: _labourViewMode == _LabourViewMode.group,
                  onTap: () => setState(() => _labourViewMode = _LabourViewMode.group),
                ),
              ),
            ],
          ),
        );
      case _HomeMode.service:
        return Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
          child: _ServiceSubcategoryFilter(
            selectedCategory: _selectedServiceCategory,
            options: _selectedServiceSubcategories,
            selected: _selectedServiceSubCategory,
            onSelected: (value) {
              setState(() => _selectedServiceSubCategory = value);
              if (_serviceRemoteCategories.isNotEmpty) {
                unawaited(_loadServiceLanding(silent: false));
              }
            },
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
                      unawaited(_selectFashionSubcategory(value, silent: false));
                      return;
                    }
                    if (_selectedShopCategory == 'Footwear') {
                      unawaited(_selectFootwearSubcategory(value, silent: false));
                      return;
                    }
                    if (_selectedShopCategory == 'Gift') {
                      unawaited(_selectGiftSubcategory(value, silent: false));
                      return;
                    }
                    if (_selectedShopCategory == 'Groceries') {
                      unawaited(_selectGrocerySubcategory(value, silent: false));
                      return;
                    }
                    if (_selectedShopCategory == 'Pharmacy') {
                      unawaited(_selectPharmacySubcategory(value, silent: false));
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
    final hasAnyLiveSection = _backendTopProducts.isNotEmpty ||
        _labourRemoteProfiles.isNotEmpty ||
        _serviceRemoteProviders.isNotEmpty ||
        _restaurantRemoteProducts.isNotEmpty ||
        _effectiveRestaurantListings.isNotEmpty ||
        nearbyShopProfiles.isNotEmpty;
    final slivers = <Widget>[];

    if (_anyHomeRemoteLoading && _backendTopProducts.isEmpty && !hasAnyLiveSection) {
      slivers.add(
        _buildRemoteStateSliver(
          icon: Icons.storefront_rounded,
          title: 'Loading nearby options',
          message: 'We are checking live shops, labour, and services around your selected location.',
          loading: true,
        ),
      );
    } else if (_homeBootstrapError != null && _backendTopProducts.isEmpty && !hasAnyLiveSection) {
      slivers.add(
        _buildRemoteStateSliver(
          icon: Icons.cloud_off_rounded,
          title: 'Could not load live shop picks',
          message: _homeBootstrapError!,
          actionLabel: 'Try Again',
          onAction: () => unawaited(_hydrateRemoteState(silent: false)),
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
            onAddToCart: (item) => _handleShopCartAdd(item, openCartAfterAdd: true),
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
          itemCount: nearbyShopProfiles.length > 4 ? 4 : nearbyShopProfiles.length,
          itemBuilder: (context, index) => _VerticalShopCard(
            item: nearbyShopProfiles[index],
            isWishlisted: _isWishlisted(nearbyShopProfiles[index]),
            onWishlistToggle: () => _toggleWishlist(nearbyShopProfiles[index]),
            onTap: () => _openShopProfile(nearbyShopProfiles[index]),
          ),
        ),
      );
    }

    if (_labourRemoteProfiles.isNotEmpty) {
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
      slivers.add(
        SliverToBoxAdapter(
          child: _AllServiceSection(
            title: 'Service nearby',
            items: _serviceRemoteProviders,
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

    if (_initialDiscoveryBatchResolved && !hasAnyLiveSection && !_anyHomeRemoteLoading) {
      slivers.add(
        _buildAreaComingSoonSliver(
          icon: Icons.location_city_rounded,
          message: 'No labour, service, or shop is registered within your selected range yet.',
        ),
      );
    }

    return slivers;
  }

  List<Widget> _buildLabourMode({bool includeTopControls = true}) {
    final labourStateSliver = _buildLabourStateSliver();
    final visibleLabourProfiles = _filteredSingleLabourProfiles;
    final selectedGroupCategoryId = _labourCategoryIdForLabel(_selectedLabourCategory);
    final groupAvailableLabour = _availableLabourCountForGroupCategory(selectedGroupCategoryId);
    return [
      if (includeTopControls)
        SliverToBoxAdapter(child: _buildCurveForeground()),
      if (labourStateSliver != null)
        labourStateSliver
      else
      if (_labourViewMode == _LabourViewMode.individual)
        ...[
          SliverToBoxAdapter(
            child: _SingleLabourFilterBar(
              selectedPeriod: _selectedSingleLabourPeriod,
              maxPrice: _selectedSingleLabourMaxPrice,
              onPeriodSelected: (value) => setState(() => _selectedSingleLabourPeriod = value),
              onMaxPriceChanged: (value) => setState(() => _selectedSingleLabourMaxPrice = value),
            ),
          ),
          if (visibleLabourProfiles.isEmpty)
            _buildRemoteStateSliver(
              icon: Icons.filter_alt_off_rounded,
              title: 'No labour matched this filter',
              message: 'Try changing Half Day / Full Day or increasing your price range.',
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
        ]
      else
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 6, 18, 0),
            child: _GroupBookingCard(
              availableLabour: groupAvailableLabour,
              selectedLabourType: _selectedLabourCategory,
              needsLabourTypeSelection: selectedGroupCategoryId == null,
              selectedMaxPrice: _selectedLabourPrice,
              selectedPricePeriod: _selectedLabourPricePeriod,
              selectedCount: _selectedLabourCount,
              maxSelectableCount: _maxGroupLabourCount,
              bookingChargePerLabour: _labourBookingChargePerLabour,
              showPriceError: _showLabourPriceError,
              showCountError: _showLabourCountError,
              countErrorText: _labourCountErrorText,
              onLabourTypeSelected: () => unawaited(_resolveGroupLabourCategoryId()),
              onPriceSelected: (value) => setState(() {
                _selectedLabourPrice = value;
                if (value.trim().isNotEmpty) {
                  _showLabourPriceError = false;
                }
              }),
              onPricePeriodSelected: (value) => setState(() => _selectedLabourPricePeriod = value),
              onCountSelected: (value) => setState(() {
                _selectedLabourCount = value;
                if (value > 0 && value > groupAvailableLabour) {
                  _showLabourCountError = true;
                  _labourCountErrorText = 'Only $groupAvailableLabour labour available';
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
                  _showCartSnack('Enter the maximum budget for each labour first.');
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
                    _labourCountErrorText = 'Only $groupAvailableLabour labour available';
                  });
                  return;
                }
                setState(() {
                  _showLabourPriceError = false;
                  _showLabourCountError = false;
                  _labourCountErrorText = null;
                });
                final categoryId = await _resolveGroupLabourCategoryId();
                if (!mounted) {
                  return;
                }
                if (categoryId == null) {
                  _showCartSnack('Please select a labour type first.');
                  return;
                }
                final selectedTypeAvailableLabour = _availableLabourCountForGroupCategory(categoryId);
                if (_selectedLabourCount > selectedTypeAvailableLabour) {
                  setState(() {
                    _showLabourCountError = true;
                    _labourCountErrorText = 'Only $selectedTypeAvailableLabour labour available';
                  });
                  return;
                }
                if (!_isAuthenticated) {
                  final loggedIn = await _ensureAuthenticated();
                  if (!loggedIn) {
                    return;
                  }
                }
                try {
                  final result = await _UserAppApi.requestGroupLabourBooking(
                    categoryId: categoryId,
                    bookingPeriod: _selectedLabourPricePeriod,
                    maxPrice: _selectedLabourPrice,
                    labourCount: _selectedLabourCount,
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
                  );
                  if (!mounted) {
                    return;
                  }
                  if (status == null || !status.canMakePayment || status.acceptedProviderCount <= 0) {
                    await _showLabourRequestStateDialog(
                      request: request,
                      status: status,
                      isGroupRequest: true,
                      requestedCount: result.requestedCount,
                    );
                    return;
                  }
                  final shouldPay = await _showAcceptedLabourDialog(
                    request: request,
                    status: status,
                    requestedCount: result.requestedCount,
                    isGroupRequest: true,
                  );
                  if (!mounted || !shouldPay) {
                    return;
                  }
                  final acceptedPayments = math.max(1, status.acceptedProviderCount);
                  final payment = await _UserAppApi.initiateLabourBookingPayment(status.requestId);
                  if (!mounted) {
                    return;
                  }
                  final paymentResult = await _PaymentFlow.start(
                    context,
                    paymentCode: payment.paymentCode,
                    title: 'Confirm group labour booking',
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
    final serviceStateSliver = _buildServiceStateSliver();
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
      else
      if (_showShopAllLanding) ...[
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
            itemCount: allNearbyShopProfiles.length > 6 ? 6 : allNearbyShopProfiles.length,
            itemBuilder: (context, index) => _VerticalShopCard(
              item: allNearbyShopProfiles[index],
              isWishlisted: _isWishlisted(allNearbyShopProfiles[index]),
              onWishlistToggle: () => _toggleWishlist(allNearbyShopProfiles[index]),
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
        const SliverToBoxAdapter(
          child: _RestaurantFilterRow(),
        ),
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
      ] else if (_shopBrowseMode == _ShopBrowseMode.itemWise && _selectedShopCategory == 'Gift') ...[
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
                onWishlistToggle: () => _toggleWishlist(_effectiveGiftShopCards[index]),
                onTap: () => _openShopProfile(_effectiveGiftShopCards[index]),
              ),
            ),
      ] else if (_shopBrowseMode == _ShopBrowseMode.itemWise && _selectedShopCategory == 'Groceries') ...[
        if (_groceryRemoteReady)
          if (_groceryRemoteProducts.isNotEmpty)
            SliverToBoxAdapter(
              child: _RemoteGroceryShowcase(
                items: _groceryRemoteProducts,
                selectedCategory: _selectedShopSubCategory,
                onItemTap: _openShopItemFromHome,
                onAddToCart: (item) => _openShopProfile(item, autoAddItem: true),
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
                onWishlistToggle: () => _toggleWishlist(_effectiveGroceryShopCards[index]),
                onTap: () => _openShopProfile(_effectiveGroceryShopCards[index]),
              ),
            ),
      ] else if (_shopBrowseMode == _ShopBrowseMode.itemWise && _selectedShopCategory == 'Pharmacy') ...[
        if (_pharmacyRemoteReady)
          if (_pharmacyRemoteProducts.isNotEmpty)
            SliverToBoxAdapter(
              child: _RemotePharmacyShowcase(
                items: _pharmacyRemoteProducts,
                selectedCategory: _selectedShopSubCategory,
                onItemTap: _openShopItemFromHome,
                onAddToCart: (item) => _openShopProfile(item, autoAddItem: true),
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
                onWishlistToggle: () => _toggleWishlist(_effectivePharmacyShopCards[index]),
                onTap: () => _openShopProfile(_effectivePharmacyShopCards[index]),
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
              onWishlistToggle: () => _toggleWishlist(_effectiveFashionShopCards[index]),
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
              onWishlistToggle: () => _toggleWishlist(_effectiveFootwearShopCards[index]),
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
            onWishlistToggle: () => _toggleWishlist(_effectiveGroceryShopCards[index]),
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
            onWishlistToggle: () => _toggleWishlist(_effectivePharmacyShopCards[index]),
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
            onWishlistToggle: () => _toggleWishlist(_effectiveGiftShopCards[index]),
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
            onWishlistToggle: () => _toggleWishlist(_effectiveFashionShopCards[index]),
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
            onWishlistToggle: () => _toggleWishlist(_effectiveFootwearShopCards[index]),
            onTap: () => _openShopProfile(_effectiveFootwearShopCards[index]),
          ),
        ),
    ];
  }

  Future<void> _openCard(_DiscoveryItem item, _HomeMode mode) async {
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
    final detailItem = mode == _HomeMode.labour ? _buildLabourProfileDetailItem(item) : item;
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
          onPrimaryAction: (labourBookingPeriod, labourCategoryId) => _handlePrimaryAction(
            detailItem,
            mode,
            labourBookingPeriod: labourBookingPeriod,
            labourCategoryId: labourCategoryId,
          ),
        ),
      ),
    );
    if (mounted) {
      await _hydrateRemoteState(silent: true);
    }
  }

  _DiscoveryItem _buildLabourProfileDetailItem(_DiscoveryItem item) {
    if (item.backendLabourId == null) {
      return item;
    }
    if (item.labourCategoryPricing.length > 1) {
      final selectedPricing = item.labourCategoryPricing.firstWhere(
        (pricing) => pricing.categoryId == item.backendCategoryId,
        orElse: () => item.labourCategoryPricing.first,
      );
      return item.copyWith(
        subtitle: selectedPricing.label.trim().isEmpty ? item.subtitle : selectedPricing.label.trim(),
        labourHalfDayPrice: selectedPricing.halfDayPrice,
        labourFullDayPrice: selectedPricing.fullDayPrice,
      );
    }
    final matchingProfiles = _labourRemoteProfiles
        .where((profile) => profile.backendLabourId == item.backendLabourId)
        .toList(growable: false);
    if (matchingProfiles.isEmpty) {
      return item;
    }
    final categoryPricing = <_LabourCategoryPricing>[];
    final seenCategoryIds = <int?>{};
    for (final profile in matchingProfiles) {
      final pricing = profile.labourCategoryPricing
              .where((entry) => entry.categoryId == profile.backendCategoryId)
              .firstOrNull ??
          profile.labourCategoryPricing.firstOrNull ??
          _LabourCategoryPricing(
            categoryId: profile.backendCategoryId,
            label: profile.subtitle,
            halfDayPrice: profile.labourHalfDayPrice,
            fullDayPrice: profile.labourFullDayPrice,
          );
      final normalizedLabel =
          _labourCategoryLabelForId(pricing.categoryId) ??
          _labourCategoryLabelForId(profile.backendCategoryId) ??
          pricing.label.trim().split(',').map((part) => part.trim()).firstWhere(
                (part) => part.isNotEmpty,
                orElse: () => profile.subtitle.trim(),
              );
      if (seenCategoryIds.add(pricing.categoryId)) {
        categoryPricing.add(
          _LabourCategoryPricing(
            categoryId: pricing.categoryId,
            label: normalizedLabel,
            halfDayPrice: pricing.halfDayPrice,
            fullDayPrice: pricing.fullDayPrice,
          ),
        );
      }
    }
    final selectedCategory = matchingProfiles.firstWhere(
      (profile) => profile.backendCategoryId == item.backendCategoryId,
      orElse: () => matchingProfiles.first,
    );
    final selectedCategoryLabel =
        _labourCategoryLabelForId(selectedCategory.backendCategoryId) ??
        categoryPricing
            .where((pricing) => pricing.categoryId == selectedCategory.backendCategoryId)
            .map((pricing) => pricing.label.trim())
            .firstWhere((label) => label.isNotEmpty, orElse: () => selectedCategory.subtitle);
    final selectedPricing = categoryPricing.firstWhere(
      (pricing) => pricing.categoryId == selectedCategory.backendCategoryId,
      orElse: () => categoryPricing.firstOrNull ?? _LabourCategoryPricing(
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$itemCategory is coming soon.')),
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
                    SnackBar(content: Text('Share link for ${item.title} will be connected next.')),
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
                    SnackBar(content: Text('Share link for ${item.title} will be connected next.')),
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
                    SnackBar(content: Text('Share link for ${item.title} will be connected next.')),
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
                    SnackBar(content: Text('Share link for ${item.title} will be connected next.')),
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
                    SnackBar(content: Text('Share link for ${item.title} will be connected next.')),
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
              SnackBar(content: Text('Share link for ${item.title} will be connected next.')),
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
              SnackBar(content: Text('Share link for ${item.title} will be connected next.')),
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
              SnackBar(content: Text('Share link for ${item.title} will be connected next.')),
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
              SnackBar(content: Text('Share link for ${item.title} will be connected next.')),
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
              SnackBar(content: Text('Share link for ${item.title} will be connected next.')),
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
              SnackBar(content: Text('Share link for ${item.title} will be connected next.')),
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
            SnackBar(content: Text('Share link for ${item.title} will be connected next.')),
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
    final inferredCategory =
        _selectedShopCategory == 'All Deals' ? _shopCategoryForItem(item) : _selectedShopCategory;
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
            initialCategory: _selectedShopSubCategory != 'All' ? _selectedShopSubCategory : 'Biscuits',
            isWishlisted: _isWishlisted,
            onWishlistToggle: _toggleWishlist,
            onAddToCart: (selectedItem) => _handleShopCartAdd(selectedItem, openCartAfterAdd: autoAddItem),
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
            initialCategory: _selectedShopSubCategory != 'All' ? _selectedShopSubCategory : 'Wellness',
            isWishlisted: _isWishlisted,
            onWishlistToggle: _toggleWishlist,
            onAddToCart: (selectedItem) => _handleShopCartAdd(selectedItem, openCartAfterAdd: autoAddItem),
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
            initialCategory: _selectedShopSubCategory != 'All' ? _selectedShopSubCategory : 'Birthday',
            isWishlisted: _isWishlisted,
            onWishlistToggle: _toggleWishlist,
            onAddToCart: (selectedItem) => _handleShopCartAdd(selectedItem, openCartAfterAdd: autoAddItem),
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
          initialFashionSubcategory: (inferredCategory == 'Fashion' || inferredCategory == 'Footwear') &&
                  _selectedShopSubCategory != 'All'
              ? _selectedShopSubCategory
              : 'All',
          isWishlisted: _isWishlisted,
          onWishlistToggle: _toggleWishlist,
          onAddToCart: (selectedItem) => _handleShopCartAdd(selectedItem, openCartAfterAdd: autoAddItem),
          onOpenCart: _openCartPage,
          autoAddItem: autoAddItem,
        ),
      ),
    );
  }


Future<void> _openProfilePage() async {
  final canContinue = await _ensureAuthenticated();
  if (!mounted || !canContinue) {
    return;
  }
  await Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => _ProfilePage(
        phoneNumber: _currentPhoneNumber,
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
  await _refreshNotificationPreview(silent: true);
  await _hydrateRemoteState(silent: true);
}

Future<void> _openNotificationsPage() async {
  final canContinue = await _ensureAuthenticated();
  if (!mounted || !canContinue) {
    return;
  }
  await Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => const _NotificationsPage(),
    ),
  );
  await _refreshNotificationPreview(silent: true);
}

Future<void> _openCartPage() async {
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
  }) async {
    await _refreshSessionPhoneFromStore();
    if ((mode == _HomeMode.labour || mode == _HomeMode.service) && !_isAuthenticated) {
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
            SnackBar(content: Text('${item.title} is not connected to live labour booking yet.')),
          );
          return false;
        }
        return _startLabourBookingRequestFlow(
          labourCategoryId == null ? item : item.copyWith(backendCategoryId: labourCategoryId),
          labourBookingPeriod ?? 'Full Day',
        );
      case _HomeMode.service:
        if (item.backendServiceProviderId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${item.title} is not connected to live service booking yet.')),
          );
          return false;
        }
        await _startServiceBookingRequestFlow(item);
        return false;
      case _HomeMode.all:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Open ${item.title} from its mode to continue.')),
        );
        return false;
    }
  }

  Future<bool> _startLabourBookingRequestFlow(
    _DiscoveryItem item,
    String bookingPeriod,
  ) async {
    var bookingLocked = false;
    try {
      final confirmed = await _confirmBookingLocationUsage(bookingLabel: 'labour');
      if (!mounted || !confirmed) {
        return false;
      }
      final selectedLocation = _selectedLocationChoice ?? _currentLocationChoice;
      if (selectedLocation != null && !_isLabourWithinSelectedRange(item, selectedLocation)) {
        final radiusKm = item.labourRadiusKm;
        final radiusLabel = radiusKm == null || radiusKm <= 0
            ? ''
            : ' within ${radiusKm.toStringAsFixed(radiusKm >= 10 ? 0 : 1)} km';
        _showCartSnack('Labour is out of range for this address. Please choose a nearer address or another labour$radiusLabel.');
        return false;
      }
      final bookingAddressId = await _ensureBookingAddressIdForServiceOrLabour();
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
      final status = await _waitForLabourAcceptance(request);
      if (!mounted) {
        return false;
      }
      if (status == null || !status.canMakePayment) {
        await _showLabourRequestStateDialog(
          request: request,
          status: status,
        );
        return false;
      }
      if (item.backendLabourId != null) {
        _markLabourBookedLocally(item.backendLabourId!);
      }
      bookingLocked = true;
      final shouldPay = await _showAcceptedLabourDialog(
        request: request,
        status: status,
        requestedCount: 1,
      );
      if (!mounted || !shouldPay) {
        return bookingLocked;
      }
      final payment = await _UserAppApi.initiateLabourBookingPayment(status.requestId);
      if (!mounted) {
        return bookingLocked;
      }
      final paymentResult = await _PaymentFlow.start(
        context,
        paymentCode: payment.paymentCode,
        title: 'Confirm labour booking',
      );
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
          if (status.distanceLabel.trim().isNotEmpty) 'Distance: ${status.distanceLabel}',
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
          _showCartSnack('This labour is no longer available. Availability has been refreshed.');
          return false;
        }
        _showCartSnack(error.message);
      }
    }
    return bookingLocked;
  }

  bool _isLabourWithinSelectedRange(_DiscoveryItem item, _HomeLocationChoice selectedLocation) {
    final radiusKm = item.labourRadiusKm;
    final workLatitude = item.labourWorkLatitude;
    final workLongitude = item.labourWorkLongitude;
    if (radiusKm == null || radiusKm <= 0 || workLatitude == null || workLongitude == null) {
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

  Future<_RemoteLabourBookingRequestStatus?> _waitForLabourAcceptance(
    _RemoteLabourBookingResult request, {
    int timeoutSeconds = 45,
    int requestedCount = 1,
    bool isGroupRequest = false,
  }) async {
    final remainingSeconds = ValueNotifier<int>(timeoutSeconds);
    final dragOffset = ValueNotifier<Offset>(Offset.zero);
    final cancelledByUser = Completer<bool>();
    final deadline = DateTime.now().add(Duration(seconds: timeoutSeconds));
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
          child: ValueListenableBuilder<Offset>(
            valueListenable: dragOffset,
            builder: (context, offset, child) => Transform.translate(
              offset: offset,
              child: Dialog(
                insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 24),
                backgroundColor: Colors.transparent,
                elevation: 0,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.16),
                          blurRadius: 30,
                          offset: const Offset(0, 18),
                        ),
                      ],
                    ),
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onPanUpdate: (details) {
                        dragOffset.value = dragOffset.value + details.delta;
                      },
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 52,
                              height: 5,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE5D9D2),
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    isGroupRequest ? 'Waiting for labour responses' : 'Waiting for labour to accept',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF22314D),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                ValueListenableBuilder<int>(
                                  valueListenable: remainingSeconds,
                                  builder: (context, seconds, child) => Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF2A13D),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      '${seconds}s',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            ValueListenableBuilder<int>(
                              valueListenable: remainingSeconds,
                              builder: (context, seconds, child) {
                                final progress = timeoutSeconds <= 0
                                    ? 0.0
                                    : (seconds / timeoutSeconds).clamp(0.0, 1.0);
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(999),
                                  child: LinearProgressIndicator(
                                    value: progress,
                                    minHeight: 9,
                                    backgroundColor: const Color(0xFFFBE8C8),
                                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF2A13D)),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 18),
                            const SizedBox(
                              width: 34,
                              height: 34,
                              child: CircularProgressIndicator(strokeWidth: 3.2),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              isGroupRequest
                                  ? 'Your request was sent to nearby matching labour.'
                                  : '${request.labourName} has received your booking request.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF22314D),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              isGroupRequest
                                  ? 'We will wait 1 minute and show how many labour accepted.'
                                  : 'Please wait while the labour accepts or rejects it.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFF66748C),
                                fontWeight: FontWeight.w700,
                                height: 1.35,
                              ),
                            ),
                            const SizedBox(height: 18),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor: const Color(0xFFD84A4A),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                onPressed: () {
                                  if (!cancelledByUser.isCompleted) {
                                    cancelledByUser.complete(true);
                                  }
                                  dialogVisible = false;
                                  Navigator.of(dialogContext).pop();
                                },
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(fontWeight: FontWeight.w900),
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
            ),
          ),
        ),
      ).whenComplete(() => dialogVisible = false),
    );
    await Future<void>.delayed(Duration.zero);

    _RemoteLabourBookingRequestStatus? status;
    try {
      while (DateTime.now().isBefore(deadline)) {
        if (cancelledByUser.isCompleted) {
          await _UserAppApi.cancelLabourBookingRequest(
            request.requestId,
            reason: 'User cancelled the waiting request.',
          );
          status = await _UserAppApi.fetchLabourBookingRequestStatus(request.requestId);
          return status;
        }
        status = await _UserAppApi.fetchLabourBookingRequestStatus(request.requestId);
        if (isGroupRequest) {
          final enoughAccepted = status.acceptedProviderCount >= requestedCount;
          final closedWithoutAcceptance =
              _isClosedLabourRequestStatus(status.requestStatus) && status.acceptedProviderCount <= 0;
          if (enoughAccepted || closedWithoutAcceptance) {
            break;
          }
        } else if (status.canMakePayment || _isClosedLabourRequestStatus(status.requestStatus)) {
          break;
        }
        await Future<void>.delayed(const Duration(seconds: 2));
      }
      if (!isGroupRequest && (status == null || !status.canMakePayment)) {
        await _UserAppApi.cancelLabourBookingRequest(
          request.requestId,
          reason: 'Labour did not accept within $timeoutSeconds seconds.',
        );
        status = await _UserAppApi.fetchLabourBookingRequestStatus(request.requestId);
      } else if (isGroupRequest && (status == null || status.acceptedProviderCount <= 0)) {
        await _UserAppApi.cancelLabourBookingRequest(
          request.requestId,
          reason: 'No labour accepted within $timeoutSeconds seconds.',
        );
        status = await _UserAppApi.fetchLabourBookingRequestStatus(request.requestId);
      }
      return status;
    } finally {
      timer.cancel();
      remainingSeconds.dispose();
      dragOffset.dispose();
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
    final normalized = status?.requestStatus.trim().toUpperCase() ?? request.requestStatus.trim().toUpperCase();
    final title = normalized == 'OPEN' ? 'Still waiting' : 'Booking request update';
    final acceptedCount = status?.acceptedProviderCount ?? 0;
    final message = isGroupRequest
        ? switch (acceptedCount) {
            <= 0 => 'No labour accepted your booking yet. Please try again, or choose another labour type available near you.',
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
            _ => 'Waiting for labour to accept the booking. Please try again in a moment.',
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

  Future<bool> _showAcceptedLabourDialog({
    required _RemoteLabourBookingResult request,
    required _RemoteLabourBookingRequestStatus status,
    required int requestedCount,
    bool isGroupRequest = false,
  }) async {
    final providerName = status.providerName.trim().isNotEmpty ? status.providerName : request.labourName;
    final acceptedCount = status.acceptedProviderCount <= 0 ? 1 : status.acceptedProviderCount;
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
    final shouldPay = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Text(isGroupRequest ? 'Labour accepted' : 'Booking accepted'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isGroupRequest ? '$acceptedCount labour accepted' : providerName,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
            ),
            const SizedBox(height: 10),
            if (isGroupRequest && acceptedCount < requestedCount)
              Text(
                'You requested $requestedCount labour. Only $acceptedCount accepted within 1 minute. Make payment to confirm these $acceptedCount, then you can try again for the remaining labour.',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            if (isGroupRequest && acceptedCount >= requestedCount)
              Text(
                'All requested labour accepted. Make payment to confirm the booking.',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            if (isGroupRequest) const SizedBox(height: 10),
            if (status.distanceLabel.trim().isNotEmpty) Text('Distance: ${status.distanceLabel}'),
            if (status.providerPhone.trim().isNotEmpty) Text('Phone: ${status.providerPhone}'),
            const SizedBox(height: 10),
            Text('Booking code: ${status.bookingCode.trim().isNotEmpty ? status.bookingCode : request.requestCode}'),
            Text(isGroupRequest ? 'Accepted labour amount: $totalAcceptedPriceLabel' : 'Labour amount: ${status.quotedPriceAmount}'),
            Text('Booking charges: $bookingChargeLabel'),
            const SizedBox(height: 12),
            const Text(
              'Booking fee is separate and will not be deducted from the labour amount. You still pay the full labour charge for Half Day or Full Day work.',
              style: TextStyle(fontWeight: FontWeight.w700, height: 1.35),
            ),
            const SizedBox(height: 12),
            const Text(
              'Confirm booking by making booking charges.',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Later'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Make payment'),
          ),
        ],
      ),
    );
    return shouldPay ?? false;
  }


  Future<void> _startServiceBookingRequestFlow(_DiscoveryItem item) async {
    try {
      final confirmed = await _confirmBookingLocationUsage(bookingLabel: 'service');
      if (!mounted || !confirmed) {
        return;
      }
      final bookingAddressId = await _ensureBookingAddressIdForServiceOrLabour();
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
      final status = await _waitForServiceAcceptance(request);
      if (!mounted) {
        return;
      }
      if (status == null || !status.canMakePayment) {
        await _showServiceRequestStateDialog(
          request: request,
          status: status,
        );
        return;
      }
      final shouldPay = await _showAcceptedServiceDialog(
        request: request,
        status: status,
      );
      if (!mounted || !shouldPay) {
        return;
      }
      final payment = await _UserAppApi.initiateServiceBookingPayment(status.requestId);
      if (!mounted) {
        return;
      }
      final paymentResult = await _PaymentFlow.start(
        context,
        paymentCode: payment.paymentCode,
        title: 'Confirm service booking',
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
        successTitle: 'Service booking confirmed',
        failureTitle: 'Service payment incomplete',
        extraLines: [
          'Booking code: ${payment.bookingCode}',
          'Provider: ${status.providerName.trim().isNotEmpty ? status.providerName : request.providerName}',
          if (status.distanceLabel.trim().isNotEmpty) 'Distance: ${status.distanceLabel}',
          'Amount: ${payment.amountLabel}',
        ],
      );
    } on _UserAppApiException catch (error) {
      if (mounted) {
        _showCartSnack(error.message);
      }
    }
  }

  Future<int?> _ensureBookingAddressIdForServiceOrLabour() async {
    final selectedLocation = _selectedLocationChoice ?? _currentLocationChoice;
    if (!_isAuthenticated || selectedLocation == null) {
      return selectedLocation?.addressId;
    }
    if (selectedLocation.addressId != null) {
      return selectedLocation.addressId;
    }

    final placemarks = await placemarkFromCoordinates(
      selectedLocation.latitude,
      selectedLocation.longitude,
    );
    final placemark = placemarks.isEmpty ? null : placemarks.first;
    final city = (placemark?.locality ?? placemark?.subAdministrativeArea ?? selectedLocation.city).trim();
    final state = (placemark?.administrativeArea ?? city).trim();
    final country = (placemark?.country ?? 'India').trim();
    final postalCode = (placemark?.postalCode ?? '').trim().isNotEmpty ? placemark!.postalCode!.trim() : '000000';
    final addressLine1Parts = <String>[
      if ((placemark?.name ?? '').trim().isNotEmpty) placemark!.name!.trim(),
      if ((placemark?.thoroughfare ?? '').trim().isNotEmpty) placemark!.thoroughfare!.trim(),
      if ((placemark?.subLocality ?? '').trim().isNotEmpty) placemark!.subLocality!.trim(),
    ];
    final addressLine2Parts = <String>[
      if ((placemark?.locality ?? '').trim().isNotEmpty) placemark!.locality!.trim(),
      if ((placemark?.administrativeArea ?? '').trim().isNotEmpty) placemark!.administrativeArea!.trim(),
    ];
    final createdAddress = await _UserAppApi.createTemporaryBookingAddress(
      _UserAddressInput(
        label: selectedLocation.isCurrentLocation ? 'Current booking location' : (selectedLocation.title.trim().isEmpty ? 'Booking location' : selectedLocation.title.trim()),
        addressLine1: addressLine1Parts.isEmpty
            ? (selectedLocation.subtitle.trim().isEmpty ? 'Current location' : selectedLocation.subtitle.trim())
            : addressLine1Parts.join(', '),
        addressLine2: addressLine2Parts.join(', '),
        landmark: (placemark?.subLocality ?? '').trim(),
        city: city.isEmpty ? 'Current City' : city,
        stateId: null,
        state: state.isEmpty ? 'Unknown State' : state,
        countryId: null,
        country: country.isEmpty ? 'India' : country,
        postalCode: postalCode,
        latitude: selectedLocation.latitude,
        longitude: selectedLocation.longitude,
        isDefault: false,
      ),
    );
    return createdAddress.id;
  }

  Future<bool> _confirmBookingLocationUsage({required String bookingLabel}) async {
    var selectedLocation = _selectedLocationChoice ?? _currentLocationChoice;
    if (selectedLocation == null) {
      await _openHomeLocationSelector(showManageAddresses: _isAuthenticated);
      if (!mounted) {
        return false;
      }
      selectedLocation = _selectedLocationChoice ?? _currentLocationChoice;
      if (selectedLocation == null) {
        _showCartSnack('Please choose a location before booking $bookingLabel.');
        return false;
      }
    }

    final locationTitle = selectedLocation.isCurrentLocation
        ? 'Current location'
        : (selectedLocation.title.trim().isEmpty ? 'Selected location' : selectedLocation.title.trim());
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
                          onPressed: () => Navigator.of(sheetContext).pop('change'),
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
                            backgroundColor: const Color(0xFF7A3FF2),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          onPressed: () => Navigator.of(sheetContext).pop('continue'),
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
    _RemoteServiceBookingResult request,
  ) async {
    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => PopScope(
          canPop: false,
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: const Text('Waiting for provider to accept'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(strokeWidth: 3),
                ),
                const SizedBox(height: 16),
                Text(
                  '${request.providerName} has received your service booking request.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Please wait while the provider accepts or rejects it.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await Future<void>.delayed(Duration.zero);

    _RemoteServiceBookingRequestStatus? status;
    try {
      for (int attempt = 0; attempt < 18; attempt++) {
        status = await _UserAppApi.fetchServiceBookingRequestStatus(request.requestId);
        if (status.canMakePayment || _isClosedServiceRequestStatus(status.requestStatus)) {
          break;
        }
        await Future<void>.delayed(const Duration(seconds: 3));
      }
      return status;
    } finally {
      if (mounted) {
        final navigator = Navigator.of(context, rootNavigator: true);
        if (navigator.canPop()) {
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
    final normalized = status?.requestStatus.trim().toUpperCase() ?? request.requestStatus.trim().toUpperCase();
    final title = normalized == 'OPEN' ? 'Still waiting' : 'Booking request update';
    final message = switch (normalized) {
      'CANCELLED' => 'No provider accepted your service booking request.',
      'EXPIRED' => 'This service booking request timed out before any provider accepted it.',
      'REJECTED' => 'The service provider rejected this booking request.',
      _ => 'Waiting for the provider to accept the booking. Please try again in a moment.',
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

  Future<bool> _showAcceptedServiceDialog({
    required _RemoteServiceBookingResult request,
    required _RemoteServiceBookingRequestStatus status,
  }) async {
    final providerName = status.providerName.trim().isNotEmpty ? status.providerName : request.providerName;
    final shouldPay = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text('Booking accepted'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(providerName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
            const SizedBox(height: 6),
            if (request.serviceName.trim().isNotEmpty) Text(request.serviceName),
            const SizedBox(height: 10),
            if (status.distanceLabel.trim().isNotEmpty) Text('Distance: ${status.distanceLabel}'),
            if (status.providerPhone.trim().isNotEmpty) Text('Phone: ${status.providerPhone}'),
            const SizedBox(height: 10),
            Text('Booking code: ${status.bookingCode.trim().isNotEmpty ? status.bookingCode : request.requestCode}'),
            Text('Booking charges: ${status.quotedPriceAmount}'),
            const SizedBox(height: 12),
            const Text(
              'Confirm booking by making booking charges.',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Later'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Make payment'),
          ),
        ],
      ),
    );
    return shouldPay ?? false;
  }
  bool _isWishlisted(_DiscoveryItem item) => _wishlistedItems.contains('${item.subtitle}:${item.title}');

  bool _isFavourited(_DiscoveryItem item) => _favouriteProfiles.contains(item.title);

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


Future<bool> _handleShopCartAdd(_DiscoveryItem item, {bool openCartAfterAdd = false}) async {
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
      _showCartSnack('${item.title} added to cart from ${remoteCart.shopName}.');
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _ActiveBookingAvatar extends StatelessWidget {
  const _ActiveBookingAvatar({
    required this.status,
    required this.size,
  });

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
              errorBuilder: (_, _, _) => Icon(Icons.person_rounded, color: Colors.white, size: size * 0.58),
            ),
    );
  }
}

class _ActiveBookingDetailsSheet extends StatefulWidget {
  const _ActiveBookingDetailsSheet({
    required this.initialStatus,
    required this.onPayNow,
    required this.onStatusChanged,
  });

  final _ActiveBookingStatus initialStatus;
  final Future<void> Function(_ActiveBookingStatus status) onPayNow;
  final ValueChanged<_ActiveBookingStatus?> onStatusChanged;

  @override
  State<_ActiveBookingDetailsSheet> createState() => _ActiveBookingDetailsSheetState();
}

class _ActiveBookingDetailsSheetState extends State<_ActiveBookingDetailsSheet> {
  static final RegExp _sixDigitOtpRegex = RegExp(r'^\d{6}$');
  static const String _androidDirectionsApiKey = 'AIzaSyA51i0ow9o6wBQzJ1km94Hv_9g2rzesgRA';
  static const String _iosDirectionsApiKey = 'AIzaSyBSV5mUsHDu_XcocYqRaFfGOERKsggAdyQ';
  final TextEditingController _startWorkOtpController = TextEditingController();
  final TextEditingController _mutualCancelOtpController = TextEditingController();
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
    final currentRequestId = _status?.requestId ?? widget.initialStatus.requestId;
    final statuses = await _UserAppApi.fetchActiveBookingStatuses();
    for (final status in statuses) {
      if (status.requestId == currentRequestId) {
        return status;
      }
    }
    return null;
  }

  Future<_ActiveBookingStatus?> _loadMatchingHistoryStatus() async {
    final currentRequestId = _status?.requestId ?? widget.initialStatus.requestId;
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
    if (bookingStatus == 'CANCELLED' && status.paymentStatus.trim().toUpperCase() == 'FAILED') {
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
    await showDialog<void>(
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
  }

  Future<void> _reload({bool promptForReview = false}) async {
    setState(() => _loading = true);
    try {
      final previousStatus = _status;
      final latest = await _loadMatchingStatus();
      _ActiveBookingStatus? reviewCandidate;
      if (promptForReview || (latest == null && previousStatus?.bookingId != null && previousStatus!.bookingId > 0)) {
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
    final needsCountdown = status != null &&
        ((status.paymentDueAt != null && DateTime.now().isBefore(status.paymentDueAt!)) ||
            (status.reachByAt != null && DateTime.now().isBefore(status.reachByAt!)));
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
      final stillNeeded = currentStatus != null &&
          ((currentStatus.paymentDueAt != null && DateTime.now().isBefore(currentStatus.paymentDueAt!)) ||
              (currentStatus.reachByAt != null && DateTime.now().isBefore(currentStatus.reachByAt!)));
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
      if (latest == null && previousStatus?.bookingId != null && previousStatus!.bookingId > 0) {
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
    final destination = status == null ? null : _destinationTrackingLatLng(status);
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
    final uri = Uri.https('maps.googleapis.com', '/maps/api/directions/json', <String, String>{
      'origin': '${origin.latitude},${origin.longitude}',
      'destination': '${destination.latitude},${destination.longitude}',
      'mode': 'driving',
      'key': apiKey,
    });
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
    final polyline = Map<String, dynamic>.from((route['overview_polyline'] as Map?) ?? const {});
    final legs = (route['legs'] as List?) ?? const [];
    final firstLeg = legs.isEmpty ? const <String, dynamic>{} : Map<String, dynamic>.from(legs.first as Map);
    final distance = Map<String, dynamic>.from((firstLeg['distance'] as Map?) ?? const {});
    final duration = Map<String, dynamic>.from((firstLeg['duration'] as Map?) ?? const {});
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
      setState(() => _startOtpError = 'Enter the 6-digit OTP shared by labour.');
      return;
    }
    setState(() {
      _verifyingStart = true;
      _startOtpError = null;
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Work is now in progress.')),
        );
      }
    } on _UserAppApiException catch (error) {
      if (mounted) {
        setState(() => _startOtpError = error.message);
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
    setState(() => _generatingCompleteOtp = true);
    try {
      final otp = await _UserAppApi.generateBookingOtp(
        bookingId: status.bookingId,
        purpose: 'COMPLETE_WORK',
      );
      if (mounted) {
        setState(() => _completeWorkOtpCode = otp);
      }
    } on _UserAppApiException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mutual cancel OTP sent to labour.')),
      );
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
      setState(() => _mutualCancelOtpError = 'Enter the 6-digit OTP shared by labour.');
      return;
    }
    setState(() {
      _verifyingMutualCancel = true;
      _mutualCancelOtpError = null;
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking cancelled mutually.')),
        );
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
    if (status == null || status.bookingId <= 0 || !_canCancelAfterReachDeadline(status) || _cancellingNoShow) {
      return;
    }
    setState(() => _cancellingNoShow = true);
    try {
      await _UserAppApi.cancelBookingByUser(
        bookingId: status.bookingId,
        reason: 'Provider did not reach within the configured reach timeline.',
      );
      await _reload(promptForReview: true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking cancelled because labour did not reach in time.')),
        );
      }
    } on _UserAppApiException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
      }
    } finally {
      if (mounted) {
        setState(() => _cancellingNoShow = false);
      }
    }
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
        padding: EdgeInsets.only(bottom: keyboardInset > 0 ? 8 : 0),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF7F2EC),
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: status == null
              ? _emptyState(controller)
              : ListView(
                  controller: controller,
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.fromLTRB(
                    18,
                    12,
                    18,
                    28,
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
                    if (status.canMakePayment) _paymentPendingAction(status),
                    if (!status.canMakePayment && status.bookingId <= 0) _waitingForAcceptanceCard(status),
                    if (!status.canMakePayment && status.bookingId > 0) ...[
                      if (status.bookingStatus.toUpperCase() == 'IN_PROGRESS') ...[
                        _completionOtpCard(status),
                        const SizedBox(height: 12),
                      ],
                      _detailsCard(status),
                      const SizedBox(height: 12),
                      _liveLocationCard(status),
                      const SizedBox(height: 12),
                      _arrivalOtpCard(status),
                      const SizedBox(height: 12),
                      if (status.bookingStatus.toUpperCase() != 'IN_PROGRESS') ...[
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
            style: TextStyle(color: Color(0xFF22314D), fontWeight: FontWeight.w900, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            'Request ID: ${status.requestCode.trim().isEmpty ? '#${status.requestId}' : status.requestCode}',
            style: const TextStyle(color: Color(0xFF66748C), fontWeight: FontWeight.w800),
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
          style: TextStyle(color: Color(0xFF22314D), fontWeight: FontWeight.w900, fontSize: 18),
        ),
      ],
    );
  }

  Widget _header(_ActiveBookingStatus status) {
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
          _ActiveBookingAvatar(status: status, size: 58),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _providerTitle(status),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18),
                ),
                const SizedBox(height: 4),
                Text(
                  _statusLabel(status),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.84),
                    fontWeight: FontWeight.w700,
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
            style: TextStyle(color: Color(0xFF22314D), fontWeight: FontWeight.w900, fontSize: 18),
          ),
          if (status.paymentDueAt != null) ...[
            const SizedBox(height: 6),
            Text(
              'Payment due by ${_timeOnly(status.paymentDueAt)}',
              style: const TextStyle(color: Color(0xFFCB6E5B), fontWeight: FontWeight.w900),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
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
                : const Text('Make payment'),
          ),
        ],
      ),
    );
  }

  Widget _detailsCard(_ActiveBookingStatus status) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _whiteCardDecoration(),
      child: Column(
        children: [
          _infoRow('Booking ID', status.bookingCode.trim().isEmpty ? '#${status.bookingId}' : status.bookingCode),
          _infoRow('Labour name', _providerTitle(status)),
          _infoRow('Labour phone', status.providerPhone.trim().isEmpty ? 'Visible after payment' : status.providerPhone),
          _infoRow('Booking type', _pricingModelLabel(status)),
          _infoRow(
            'Labour amount',
            status.totalAcceptedQuotedPriceAmount.trim().isNotEmpty
                ? status.totalAcceptedQuotedPriceAmount
                : (status.quotedPriceAmount.trim().isEmpty ? 'As quoted' : status.quotedPriceAmount),
          ),
          _infoRow(
            'Booking fees',
            status.totalAcceptedBookingChargeAmount.trim().isNotEmpty
                ? status.totalAcceptedBookingChargeAmount
                : 'Pending',
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
          const Text(
            'Live trip tracking',
            style: TextStyle(color: Color(0xFF22314D), fontWeight: FontWeight.w900, fontSize: 16),
          ),
          if (routeDistanceLabel != null) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE9F7FF),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: const Color(0xFFB9DDF3)),
                  ),
                  child: Text(
                    'Route $routeDistanceLabel',
                    style: const TextStyle(color: Color(0xFF14516E), fontWeight: FontWeight.w900),
                  ),
                ),
                if (routeEtaLabel != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEFE7),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: const Color(0xFFF1C6B4)),
                    ),
                    child: Text(
                      'ETA $routeEtaLabel',
                      style: const TextStyle(color: Color(0xFF9A432E), fontWeight: FontWeight.w900),
                    ),
                  ),
              ],
            ),
          ] else if (_loadingRouteSnapshot) ...[
            const SizedBox(height: 8),
            const Text(
              'Calculating route...',
              style: TextStyle(color: Color(0xFF66748C), fontWeight: FontWeight.w700),
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
                          initialCameraPosition: _trackingCameraPosition(status),
                          markers: _trackingMarkers(status),
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
                      style: TextStyle(color: Color(0xFF66748C), fontWeight: FontWeight.w700),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _arrivalOtpCard(_ActiveBookingStatus status) {
    final bookingStatus = status.bookingStatus.toUpperCase();
    final canEnterOtp = bookingStatus == 'ARRIVED';
    final alreadyStarted = bookingStatus == 'IN_PROGRESS';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _whiteCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            alreadyStarted ? 'Work in progress' : 'Confirm labour arrival',
            style: const TextStyle(color: Color(0xFF22314D), fontWeight: FontWeight.w900, fontSize: 16),
          ),
          if (!alreadyStarted) ...[
            const SizedBox(height: 10),
            TextField(
              controller: _startWorkOtpController,
              enabled: canEnterOtp && !_verifyingStart,
              keyboardType: TextInputType.number,
              scrollPadding: const EdgeInsets.only(bottom: 24),
              maxLength: 6,
              decoration: InputDecoration(
                counterText: '',
                hintText: canEnterOtp ? 'Arrival OTP' : 'Unlocks after labour arrives',
                errorText: _startOtpError,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: canEnterOtp && !_verifyingStart ? _verifyStartWorkOtp : null,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF7AA81E),
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(_verifyingStart ? 'Verifying...' : 'Confirm arrival and start work'),
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
            style: TextStyle(color: Color(0xFF22314D), fontWeight: FontWeight.w900, fontSize: 16),
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
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 28, letterSpacing: 5),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Text(_generatingCompleteOtp ? 'Generating...' : 'Generate completion OTP'),
          ),
        ],
      ),
    );
  }

  Widget _cancelCard(_ActiveBookingStatus status) {
    final bookingStatus = status.bookingStatus.toUpperCase();
    final showNoShowCancel = bookingStatus == 'PAYMENT_COMPLETED';
    final showMutualCancel = bookingStatus == 'IN_PROGRESS';
    final canNoShowCancel = _canCancelAfterReachDeadline(status);
    if (!showNoShowCancel && !showMutualCancel && !_mutualCancelRequested && _mutualCancelOtpError == null) {
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
                  showMutualCancel ? 'Mutual cancellation' : 'Cancel if labour does not reach',
                  style: const TextStyle(color: Color(0xFF22314D), fontWeight: FontWeight.w900, fontSize: 16),
                ),
              ),
              if (showNoShowCancel)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: canNoShowCancel ? const Color(0xFF1FA855) : const Color(0xFFF2A13D),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    canNoShowCancel ? 'Enabled now' : _reachCountdownLabel(status),
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
                  ? 'Labour did not reach in time.'
                  : 'Cancel unlocks after the reach timer.',
              style: const TextStyle(color: Color(0xFF66748C), fontWeight: FontWeight.w700, height: 1.35),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: canNoShowCancel && !_cancellingNoShow ? _cancelAfterReachDeadline : null,
              style: OutlinedButton.styleFrom(
                foregroundColor: canNoShowCancel ? const Color(0xFFB03737) : const Color(0xFF9C948E),
                disabledForegroundColor: const Color(0xFF9C948E),
                minimumSize: const Size.fromHeight(46),
                side: BorderSide(color: canNoShowCancel ? const Color(0xFFB03737) : const Color(0xFFD8C7BC)),
                backgroundColor: canNoShowCancel ? const Color(0xFFFFF7F7) : const Color(0xFFF4EFEA),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(_cancellingNoShow ? 'Cancelling...' : _cancelButtonLabel(status)),
            ),
          ],
          if (showMutualCancel) ...[
            const Text(
              'Booking fees will not be refunded after work starts.',
              style: TextStyle(color: Color(0xFF9B433B), fontWeight: FontWeight.w800, height: 1.3),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: !_requestingMutualCancel ? _requestMutualCancelOtp : null,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFB03737),
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(46),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(_requestingMutualCancel ? 'Requesting...' : 'Request mutual cancel OTP'),
            ),
          ],
          if (showMutualCancel && (_mutualCancelRequested || _mutualCancelOtpError != null)) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _mutualCancelOtpController,
              enabled: !_verifyingMutualCancel,
              keyboardType: TextInputType.number,
              scrollPadding: const EdgeInsets.only(bottom: 24),
              maxLength: 6,
              decoration: InputDecoration(
                counterText: '',
                hintText: 'OTP from labour',
                errorText: _mutualCancelOtpError,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 10),
            FilledButton(
                onPressed: _verifyingMutualCancel ? null : _verifyMutualCancelOtp,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFB03737),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(46),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(_verifyingMutualCancel ? 'Cancelling...' : 'Confirm mutual cancellation')),
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

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 112,
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF8C7E73), fontWeight: FontWeight.w700),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Color(0xFF22314D), fontWeight: FontWeight.w900),
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
        !DateTime.now().isBefore(reachByAt);
  }

  String _cancelButtonLabel(_ActiveBookingStatus status) {
    final reachByAt = status.reachByAt;
    if (_canCancelAfterReachDeadline(status)) {
      return 'Cancel because labour did not reach';
    }
    if (reachByAt != null) {
      return 'Cancel enabled after ${_timeOnly(reachByAt)}';
    }
    return 'Cancel enabled after admin reach timeline';
  }

  String _reachCountdownLabel(_ActiveBookingStatus status) {
    final reachByAt = status.reachByAt;
    if (reachByAt == null) {
      return '--:--';
    }
    final remaining = reachByAt.difference(DateTime.now());
    if (remaining.isNegative || remaining.inSeconds <= 0) {
      return '00:00';
    }
    final totalHours = remaining.inHours;
    final minutes = remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
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
    return status.bookingType.toUpperCase() == 'SERVICE' ? 'Service provider' : 'Labour';
  }

  String _statusLabel(_ActiveBookingStatus status) {
    final bookingStatus = status.bookingStatus.toUpperCase();
    return switch (bookingStatus) {
      'PAYMENT_COMPLETED' => 'Payment done. Labour is on the way.',
      'ARRIVED' => 'Labour reached. Enter OTP to start work.',
      'IN_PROGRESS' => 'Work in progress.',
      'COMPLETED' => 'Booking completed.',
      _ => status.canMakePayment ? 'Accepted. Payment is pending.' : _titleCase(status.requestStatus),
    };
  }

  String _pricingModelLabel(_ActiveBookingStatus status) {
    final raw = status.labourPricingModel.trim().toUpperCase();
    if (raw == 'HALF_DAY') {
      return 'Half Day';
    }
    if (raw == 'FULL_DAY') {
      return 'Full Day';
    }
    return status.bookingType.toUpperCase() == 'SERVICE' ? 'Service visit' : 'Labour booking';
  }

  String _timeOnly(DateTime? value) {
    if (value == null) {
      return '';
    }
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _openFullMap(_ActiveBookingStatus status) {
    final providerLocation = _providerTrackingLatLng(status);
    final destinationLocation = _destinationTrackingLatLng(status);
    if (providerLocation == null && destinationLocation == null) {
      return;
    }
    final fallbackTarget = providerLocation ?? destinationLocation ?? const LatLng(26.8467, 80.9462);
    final etaLabel = _trackingRouteEtaLabel() ?? '';
    final distanceLabel = _trackingRouteDistanceLabel(status) ?? '';
    final destinationName = _trackingDestinationName(status);
    GoogleMapController? dialogMapController;

    Future<void> focusTrackingRoute() async {
      final controller = dialogMapController;
      if (controller == null) {
        return;
      }
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
      builder: (dialogContext) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
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
                    colors: <Color>[Color(0xFF19B34A), Color(0xFF11913C)],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.place_rounded, color: Colors.white, size: 16),
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
                          onTap: () => Navigator.of(dialogContext).pop(),
                          borderRadius: BorderRadius.circular(999),
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.14),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Your labour is on the way',
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
                      etaLabel.trim().isNotEmpty
                          ? 'Arriving in $etaLabel'
                          : (distanceLabel.isNotEmpty ? distanceLabel : 'Live route updating'),
                      style: const TextStyle(
                        color: Color(0xFFE9FFE9),
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
                        unawaited(focusTrackingRoute());
                      },
                      initialCameraPosition: CameraPosition(
                        target: providerLocation != null && destinationLocation != null
                            ? LatLng(
                                (providerLocation.latitude + destinationLocation.latitude) / 2,
                                (providerLocation.longitude + destinationLocation.longitude) / 2,
                              )
                            : fallbackTarget,
                        zoom: providerLocation != null && destinationLocation != null ? 13 : 15.2,
                      ),
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: false,
                      compassEnabled: true,
                      markers: _trackingMarkers(status),
                      polylines: _trackingPolylines(status),
                    ),
                    Positioned(
                      top: 18,
                      right: 18,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => unawaited(focusTrackingRoute()),
                          borderRadius: BorderRadius.circular(999),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.18),
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
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                                const Text(
                                  'BOOKING DESTINATION',
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
                              distanceLabel.isNotEmpty ? 'Arriving in $etaLabel • $distanceLabel' : 'Arriving in $etaLabel',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.w700,
                                fontSize: 11.6,
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
      ),
    );
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

  Set<Marker> _trackingMarkers(_ActiveBookingStatus status) {
    final markers = <Marker>{};
    final provider = _providerTrackingLatLng(status);
    final destination = _destinationTrackingLatLng(status);
    if (provider != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('provider_live_location'),
          position: provider,
          infoWindow: InfoWindow(title: _providerTitle(status), snippet: 'Live labour location'),
          icon: _providerScooterMarkerIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
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
        points: routePoints.length >= 2 ? routePoints : <LatLng>[provider, destination],
        width: 5,
        color: const Color(0xFFCB6E5B),
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
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
}

class _BookingReviewDialog extends StatefulWidget {
  const _BookingReviewDialog({
    required this.status,
    required this.onSubmit,
  });

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
        return ('Terrible', const Color(0xFFD62828));
      case 2:
        return ('Bad', const Color(0xFF8B1E1E));
      case 3:
        return ('Average', const Color(0xFFB68A00));
      case 4:
        return ('Good', const Color(0xFF4AAE4F));
      case 5:
        return ('Exceptional', const Color(0xFF177245));
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
                  onPressed: _submitting ? null : () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded, color: Color(0xFF6D7A91)),
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
                  onTap: _submitting ? null : () => setState(() => _selectedRating = star),
                  borderRadius: BorderRadius.circular(999),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Icon(
                      selected ? Icons.star_rounded : Icons.star_border_rounded,
                      size: 34,
                      color: selected ? const Color(0xFFF2A13D) : const Color(0xFFD1C4B8),
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
                  borderSide: const BorderSide(color: Color(0xFFCB6E5B), width: 1.3),
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
                          await widget.onSubmit(_selectedRating, _commentController.text.trim());
                          if (!mounted) {
                            return;
                          }
                          navigator.pop();
                          messenger.showSnackBar(
                            const SnackBar(content: Text('Thanks for sharing your rating.')),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
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
              color: selected ? const Color(0xFFCB6E5B) : const Color(0xFFE9DED5),
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
    final transitionHeight = hasForeground ? foregroundHeight + 34 : (compact ? 54.0 : 84.0);
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
                  colors: [
                    colors.first,
                    colors[1],
                    colors[2],
                    colors[2],
                  ],
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
            Positioned(
              left: 0,
              right: 0,
              bottom: 8,
              child: foreground!,
            ),
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

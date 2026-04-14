part of '../../main.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({
    super.key,
    required this.phoneNumber,
  });

  final String phoneNumber;

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
  String _selectedShopCategory = 'All';
  String _selectedShopSubCategory = 'All';
  String _selectedRestaurantCuisine = 'All';
  String _selectedAllQuickCategory = 'Kitchen';
  String _selectedLabourCategory = 'All labour';
  String _selectedLabourPrice = '40';
  String _selectedLabourPricePeriod = 'Full Day';
  int _selectedLabourCount = 4;
  String? _cartShopName;
  int _notificationUnreadCount = 0;
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
  StreamSubscription<_NotificationEvent>? _notificationEventSubscription;

  static const int _fashionProductBatchSize = 20;
  static const int _fashionProductTotalCount = 120;
  static const int _footwearProductBatchSize = 20;
  static const int _footwearProductTotalCount = 120;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    unawaited(_NotificationBootstrap.ensureRegistered());
    _notificationEventSubscription = _NotificationBootstrap.events.listen(_handleNotificationEvent);
    unawaited(_hydrateRemoteState());
    unawaited(_loadLabourLanding());
    unawaited(_loadServiceLanding());
    unawaited(_loadRestaurantLanding());
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
      final results = await Future.wait<dynamic>([
        _UserAppApi.fetchHomeTopProducts(),
        _UserAppApi.fetchCart(),
      ]);
      if (!mounted) {
        return;
      }
      final remoteProducts = (results[0] as List<_DiscoveryItem>);
      final remoteCart = results[1] as _RemoteCartState;
      setState(() {
        _backendTopProducts
          ..clear()
          ..addAll(remoteProducts);
        _cartShopName = remoteCart.shopName.isEmpty ? null : remoteCart.shopName;
        _cartItems
          ..clear()
          ..addAll(remoteCart.items);
        _homeBootstrapError = null;
      });
      unawaited(_refreshNotificationPreview(silent: true));
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
        _labourRemoteReady = landing.profiles.isNotEmpty || landing.categories.isNotEmpty;
        _labourRemoteError = null;
        if (!labels.contains(_selectedLabourCategory)) {
          _selectedLabourCategory = labels.isEmpty ? 'All labour' : labels.first;
        }
      });
    } on _UserAppApiException catch (error) {
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
        _serviceRemoteReady = landing.providers.isNotEmpty || landing.categories.isNotEmpty;
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
      final landing = await _UserAppApi.fetchRestaurantLanding();
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
      final landing = await _UserAppApi.fetchFashionLanding();
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
      final landing = await _UserAppApi.fetchFootwearLanding();
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
      final landing = await _UserAppApi.fetchGiftLanding();
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
      final landing = await _UserAppApi.fetchGroceryLanding();
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
      final landing = await _UserAppApi.fetchPharmacyLanding();
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
    } catch (_) {
      if (mounted) {
        _showCartSnack('Could not refresh restaurant items right now.');
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
          ? (await _UserAppApi.fetchFashionLanding()).products
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
    });
    if (!_footwearRemoteReady && value == 'All') {
      await _loadFootwearLanding(silent: silent);
      return;
    }
    final categoryId = _footwearCategoryIdForLabel(value);
    try {
      final page = value == 'All' && !_footwearRemoteReady
          ? (await _UserAppApi.fetchFootwearLanding()).products
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
    } catch (_) {
      if (!silent && mounted) {
        _showCartSnack('Could not refresh footwear items right now.');
      }
    }
  }

  Future<void> _selectGiftSubcategory(String value, {bool silent = true}) async {
    setState(() => _selectedShopSubCategory = value);
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
    } catch (_) {
      if (!silent && mounted) {
        _showCartSnack('Could not refresh gift items right now.');
      }
    }
  }

  Future<void> _selectGrocerySubcategory(String value, {bool silent = true}) async {
    setState(() => _selectedShopSubCategory = value);
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
    } catch (_) {
      if (!silent && mounted) {
        _showCartSnack('Could not refresh grocery items right now.');
      }
    }
  }

  Future<void> _selectPharmacySubcategory(String value, {bool silent = true}) async {
    setState(() => _selectedShopSubCategory = value);
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
    } catch (_) {
      if (!silent && mounted) {
        _showCartSnack('Could not refresh pharmacy items right now.');
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
      return _buildRemoteStateSliver(
        icon: Icons.person_search_rounded,
        title: 'No labour available right now',
        message: 'Try another labour category or check again in a little while.',
        actionLabel: 'Refresh',
        onAction: () => unawaited(_loadLabourLanding(silent: false)),
      );
    }
    return null;
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
      return _buildRemoteStateSliver(
        icon: Icons.search_off_rounded,
        title: 'No providers found',
        message: 'Try another service category or remove a narrow filter.',
        actionLabel: 'Refresh',
        onAction: () => unawaited(_loadServiceLanding(silent: false)),
      );
    }
    return null;
  }

  Widget? _buildShopRemoteStateSliver() {
    if (_showShopAllLanding) {
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
        return _buildRemoteStateSliver(
          icon: Icons.no_meals_rounded,
          title: 'No restaurants found',
          message: 'There are no restaurant results to show right now for this area.',
          actionLabel: 'Refresh',
          onAction: () => unawaited(_loadRestaurantLanding(silent: false)),
        );
      }
      return null;
    }

    final itemWise = _shopBrowseMode == _ShopBrowseMode.itemWise;
    switch (_selectedShopCategory) {
      case 'Fashion':
        final hasData = itemWise ? _fashionRemoteProducts.isNotEmpty : _fashionRemoteShops.isNotEmpty;
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
          return _buildRemoteStateSliver(
            icon: Icons.search_off_rounded,
            title: 'No fashion results found',
            message: 'Try another filter, subcategory, or sort option.',
            actionLabel: 'Refresh',
            onAction: () => unawaited(_loadFashionLanding(silent: false)),
          );
        }
        return null;
      case 'Footwear':
        final hasData = itemWise ? _footwearRemoteProducts.isNotEmpty : _footwearRemoteShops.isNotEmpty;
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
          return _buildRemoteStateSliver(
            icon: Icons.search_off_rounded,
            title: 'No footwear results found',
            message: 'Try another footwear category or remove a narrow filter.',
            actionLabel: 'Refresh',
            onAction: () => unawaited(_loadFootwearLanding(silent: false)),
          );
        }
        return null;
      case 'Gift':
        final hasData = itemWise ? _giftRemoteProducts.isNotEmpty : _giftRemoteShops.isNotEmpty;
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
          return _buildRemoteStateSliver(
            icon: Icons.search_off_rounded,
            title: 'No gift results found',
            message: 'Try another occasion or refresh to see the latest gift inventory.',
            actionLabel: 'Refresh',
            onAction: () => unawaited(_loadGiftLanding(silent: false)),
          );
        }
        return null;
      case 'Groceries':
        final hasData = itemWise ? _groceryRemoteProducts.isNotEmpty : _groceryRemoteShops.isNotEmpty;
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
          return _buildRemoteStateSliver(
            icon: Icons.search_off_rounded,
            title: 'No grocery results found',
            message: 'Try another grocery category or refresh to load the latest items.',
            actionLabel: 'Refresh',
            onAction: () => unawaited(_loadGroceryLanding(silent: false)),
          );
        }
        return null;
      case 'Pharmacy':
        final hasData = itemWise ? _pharmacyRemoteProducts.isNotEmpty : _pharmacyRemoteShops.isNotEmpty;
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
          return _buildRemoteStateSliver(
            icon: Icons.search_off_rounded,
            title: 'No pharmacy results found',
            message: 'Try another pharmacy category or refresh to load current stock.',
            actionLabel: 'Refresh',
            onAction: () => unawaited(_loadPharmacyLanding(silent: false)),
          );
        }
        return null;
      default:
        return null;
    }
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
        return ['All', 'Fresh', 'Repair', 'Groceries', 'Dining', 'Pharmacy'];
      case _HomeMode.labour:
        return _labourRemoteCategories.isNotEmpty
            ? _labourRemoteCategories.map((item) => item.label).toList(growable: false)
            : ['All labour', 'Helpers', 'Loaders', 'Cleaners', 'Drivers'];
      case _HomeMode.service:
        return _serviceRemoteCategories.isNotEmpty
            ? _serviceRemoteCategories.map((item) => item.label).toList(growable: false)
            : ['Automobile', 'Plumber', 'AC Repair', 'Appliance', 'Electrician'];
      case _HomeMode.shop:
        return [
          ..._shopCategorySortOrder.where(_shopComingSoonCategories.contains),
          ..._shopCategorySortOrder.where((category) => !_shopComingSoonCategories.contains(category)),
        ];
    }
  }

  List<String> get _shopCategorySortOrder =>
      const ['All', 'Restaurant', 'Fashion', 'Footwear', 'Groceries', 'Pharmacy', 'Gift'];

  List<_DiscoverySection> get _allSections => [
        _DiscoverySection(
          title: 'Most shopped',
          caption: 'Sorted by range, promotion, rating and stock',
          items: [
            _DiscoveryItem(
              title: 'Farm Fresh Veg Box',
              subtitle: 'Green Basket',
              accent: Color(0xFF4DAF50),
              icon: Icons.local_grocery_store_rounded,
              price: '₹149',
              rating: '4.9',
              distance: '1.1 km',
              extra: 'Groceries',
              maskedPhone: '93xxxxxx40',
            ),
            _DiscoveryItem(
              title: 'Premium Fruit Mix',
              subtitle: 'Daily Mart',
              accent: Color(0xFFFF954A),
              icon: Icons.shopping_basket_rounded,
              price: '₹189',
              extra: 'Groceries',
            ),
            _DiscoveryItem(
              title: 'Pharmacy Essentials',
              subtitle: 'Wellness Hub',
              accent: Color(0xFF1FB8A4),
              icon: Icons.local_pharmacy_rounded,
              price: '₹99',
              extra: 'Pharmacy',
            ),
            _DiscoveryItem(
              title: 'Gift Combo',
              subtitle: 'Happy Hands',
              accent: Color(0xFFB45DE8),
              icon: Icons.redeem_rounded,
              price: '₹249',
              extra: 'Gift',
            ),
            _DiscoveryItem(
              title: 'Bakery Picks',
              subtitle: 'Oven Street',
              accent: Color(0xFFD88A43),
              icon: Icons.bakery_dining_rounded,
              price: '₹119',
              extra: 'Bakery',
            ),
            _DiscoveryItem(
              title: 'Kitchen Staples',
              subtitle: 'Neighbour Shop',
              accent: Color(0xFF5C8FD8),
              icon: Icons.storefront_rounded,
              price: '₹210',
              extra: 'Shop',
            ),
            _DiscoveryItem(
              title: 'Dinner Combo',
              subtitle: 'Urban Spoon',
              accent: Color(0xFFFF6E5A),
              icon: Icons.restaurant_rounded,
              price: '₹299',
              extra: 'Dining',
            ),
            _DiscoveryItem(
              title: 'Milk & Bread',
              subtitle: 'Morning Mart',
              accent: Color(0xFF6AB76D),
              icon: Icons.breakfast_dining_rounded,
              price: '₹79',
              extra: 'Essentials',
            ),
          ],
        ),
        _DiscoverySection(
          title: 'Available labour',
          caption: 'Sorted by availability, range, promotion and rating',
          items: _allLabourSectionItems,
        ),
        _DiscoverySection(
          title: 'Repair picks',
          caption: 'Visible only inside service range and sorted by promotion + rating',
          items: _allServiceSectionItems,
        ),
      ];

  List<_DiscoveryItem> get _allLabourSectionItems => _labourRemoteReady && _labourRemoteProfiles.isNotEmpty
      ? _labourRemoteProfiles
      : const [
          _DiscoveryItem(
            title: 'Rakesh Yadav',
            subtitle: 'Loading & shifting',
            accent: Color(0xFFF2A13D),
            icon: Icons.engineering_rounded,
            price: '₹25/hr',
            rating: '4.9',
            distance: '1.2 km',
            extra: '124 jobs done',
          ),
          _DiscoveryItem(
            title: 'Imran Khan',
            subtitle: 'General helper',
            accent: Color(0xFFF2A13D),
            icon: Icons.construction_rounded,
            price: '₹25/hr',
            rating: '4.8',
            distance: '1.5 km',
            extra: '98 jobs done',
          ),
          _DiscoveryItem(
            title: 'Sanjay Mali',
            subtitle: 'Warehouse helper',
            accent: Color(0xFFF2A13D),
            icon: Icons.inventory_2_rounded,
            price: '₹30/hr',
            rating: '4.7',
            distance: '2.1 km',
            extra: '134 jobs done',
          ),
          _DiscoveryItem(
            title: 'Deepak',
            subtitle: 'Delivery support',
            accent: Color(0xFFF2A13D),
            icon: Icons.local_shipping_rounded,
            price: '₹28/hr',
            rating: '4.8',
            distance: '1.7 km',
            extra: '89 jobs done',
          ),
          _DiscoveryItem(
            title: 'Sonu',
            subtitle: 'Cleaner helper',
            accent: Color(0xFFF2A13D),
            icon: Icons.cleaning_services_rounded,
            price: '₹26/hr',
            rating: '4.6',
            distance: '2.4 km',
            extra: '74 jobs done',
          ),
          _DiscoveryItem(
            title: 'Amit',
            subtitle: 'Shift helper',
            accent: Color(0xFFF2A13D),
            icon: Icons.handyman_rounded,
            price: '₹25/hr',
            rating: '4.7',
            distance: '1.9 km',
            extra: '101 jobs done',
          ),
          _DiscoveryItem(
            title: 'Harish',
            subtitle: 'Packing support',
            accent: Color(0xFFF2A13D),
            icon: Icons.work_rounded,
            price: '₹27/hr',
            rating: '4.8',
            distance: '2.0 km',
            extra: '81 jobs done',
          ),
          _DiscoveryItem(
            title: 'Javed',
            subtitle: 'Loader team',
            accent: Color(0xFFF2A13D),
            icon: Icons.groups_rounded,
            price: '₹29/hr',
            rating: '4.9',
            distance: '1.4 km',
            extra: '165 jobs done',
          ),
        ];

  List<_DiscoveryItem> get _labourItems => _labourRemoteReady && _labourRemoteProfiles.isNotEmpty
      ? _labourRemoteProfiles
      : _allSections[1].items;

  List<_AllQuickCategoryItem> get _allQuickCategories {
    final items = <_AllQuickCategoryItem>[];
    final seen = <String>{};
    for (final item in _allSections.first.items) {
      final raw = _allQuickCategoryChipLabelForItem(item);
      if (raw.isEmpty || seen.contains(raw)) {
        continue;
      }
      seen.add(raw);
      items.add(
        _AllQuickCategoryItem(
          label: raw,
          accent: item.accent,
          icon: item.icon,
        ),
      );
    }
    return items.take(6).toList();
  }

  List<_DiscoverySection> get _filteredAllSections {
    final selected = _selectedAllQuickCategory;
    return _allSections.asMap().entries.map((entry) {
      if (entry.key != 0) {
        return entry.value;
      }
      final openItems = entry.value.items
          .where((item) => _shopTimingFor(item.subtitle, _shopCategoryForItem(item)).isOpen)
          .toList();
      final sourceItems = openItems.isEmpty ? entry.value.items : openItems;
      final matchedItems = sourceItems
          .where((item) => _allQuickCategoryLabelForItem(item) == selected)
          .toList();
      final fallbackItems = sourceItems
          .where((item) => _allQuickCategoryLabelForItem(item) != selected)
          .toList();
      final filteredItems = <_DiscoveryItem>[
        ...matchedItems,
        ...fallbackItems,
      ].take(sourceItems.length).toList();
      return _DiscoverySection(
        title: entry.value.title,
        caption: entry.value.caption,
        items: filteredItems.isEmpty ? sourceItems : filteredItems,
      );
    }).toList();
  }

  List<_DiscoveryItem> get _allServiceSectionItems => _serviceRemoteReady && _serviceRemoteProviders.isNotEmpty
      ? _serviceRemoteProviders
      : const [
          _DiscoveryItem(
            title: 'AC Repair',
            subtitle: 'Coolfix Services',
            accent: Color(0xFF5C8FD8),
            icon: Icons.ac_unit_rounded,
            price: '₹199 visit',
            extra: 'Service',
          ),
          _DiscoveryItem(
            title: 'Car Repair',
            subtitle: 'Auto Assist',
            accent: Color(0xFFE55A57),
            icon: Icons.car_repair_rounded,
            price: '₹249 visit',
            extra: 'Automobile',
          ),
          _DiscoveryItem(
            title: 'Plumber Visit',
            subtitle: 'Pipe Point',
            accent: Color(0xFF3F7FE7),
            icon: Icons.plumbing_rounded,
            price: '₹179 visit',
            extra: 'Home repair',
          ),
          _DiscoveryItem(
            title: 'Bike Service',
            subtitle: 'Moto Care',
            accent: Color(0xFF5C8FD8),
            icon: Icons.two_wheeler_rounded,
            price: '₹149 visit',
            extra: 'Automobile',
          ),
          _DiscoveryItem(
            title: 'Appliance Check',
            subtitle: 'Home Works',
            accent: Color(0xFFDF7DA0),
            icon: Icons.kitchen_rounded,
            price: '₹199 visit',
            extra: 'Appliance',
          ),
          _DiscoveryItem(
            title: 'Electrician',
            subtitle: 'Volt Team',
            accent: Color(0xFFF2A13D),
            icon: Icons.electrical_services_rounded,
            price: '₹189 visit',
            extra: 'Electrical',
          ),
          _DiscoveryItem(
            title: 'Water Filter',
            subtitle: 'Pure Flow',
            accent: Color(0xFF1FB8A4),
            icon: Icons.water_drop_rounded,
            price: '₹159 visit',
            extra: 'Service',
          ),
          _DiscoveryItem(
            title: 'Generator Fix',
            subtitle: 'Power Care',
            accent: Color(0xFFCB6E5B),
            icon: Icons.build_circle_rounded,
            price: '₹299 visit',
            extra: 'Repair',
          ),
        ];

  List<_DiscoveryItem> get _serviceProviders => _serviceRemoteReady && _serviceRemoteProviders.isNotEmpty
      ? _serviceRemoteProviders
      : const [
        _DiscoveryItem(
          title: 'Auto Assist',
          subtitle: '2 Wheeler specialist',
          accent: Color(0xFF5C8FD8),
          icon: Icons.two_wheeler_rounded,
          price: '₹149 visit',
          extra: '214 bookings done',
        ),
        _DiscoveryItem(
          title: 'Rickshaw Ready',
          subtitle: '3 Wheeler garage',
          accent: Color(0xFFF2A13D),
          icon: Icons.electric_rickshaw_rounded,
          price: '₹179 visit',
          extra: '148 bookings done',
        ),
        _DiscoveryItem(
          title: 'Car Clinic',
          subtitle: '4 Wheeler service',
          accent: Color(0xFFE55A57),
          icon: Icons.car_repair_rounded,
          price: '₹249 visit',
          extra: '196 bookings done',
        ),
        _DiscoveryItem(
          title: 'Home Restore',
          subtitle: 'Appliance service',
          accent: Color(0xFFDF7DA0),
          icon: Icons.home_repair_service_rounded,
          price: '₹199 visit',
          extra: '182 bookings done',
        ),
        _DiscoveryItem(
          title: 'Pipe Point',
          subtitle: 'Plumbing service',
          accent: Color(0xFF3F7FE7),
          icon: Icons.plumbing_rounded,
          price: '₹179 visit',
          extra: '166 bookings done',
        ),
        _DiscoveryItem(
          title: 'Volt Team',
          subtitle: 'Electric service',
          accent: Color(0xFFF2A13D),
          icon: Icons.electrical_services_rounded,
          price: '₹189 visit',
          extra: '204 bookings done',
        ),
      ];

  List<String> get _selectedServiceSubcategories =>
      _serviceRemoteCategories.isNotEmpty
          ? _serviceRemoteCategories
              .where((category) => category.label == _selectedServiceCategory)
              .expand((category) => category.subcategories)
              .map((subcategory) => subcategory.label)
              .toList(growable: false)
          : _serviceSubcategoriesFor(_selectedServiceCategory);

  List<_DiscoveryItem> get _filteredServiceProviders {
    if (_serviceRemoteReady && _serviceRemoteProviders.isNotEmpty) {
      return _serviceRemoteProviders;
    }
    final subcategories = _selectedServiceSubcategories;
    final selectedSubcategory =
        subcategories.contains(_selectedServiceSubCategory) ? _selectedServiceSubCategory : 'All';
    return _serviceProviders.where((item) {
      if (_serviceCategoryFor(item) != _selectedServiceCategory) {
        return false;
      }
      if (selectedSubcategory == 'All') {
        return true;
      }
      return _serviceSubcategoryFor(item, _selectedServiceCategory) == selectedSubcategory;
    }).toList();
  }

  List<_DiscoverySection> get _shopSections => const [
        _DiscoverySection(
          title: 'Gift items',
          caption: 'Best rated and promoted picks from 8 different shops',
          items: [
            _DiscoveryItem(title: 'Ceramic Mug Box', subtitle: 'Gift Aura', accent: Color(0xFFB45DE8), icon: Icons.redeem_rounded, price: '₹249'),
            _DiscoveryItem(title: 'Soft Toy Combo', subtitle: 'Smile Gifts', accent: Color(0xFFDF7DA0), icon: Icons.toys_rounded, price: '₹399'),
            _DiscoveryItem(title: 'Chocolate Pack', subtitle: 'Sweet Box', accent: Color(0xFFCB6E5B), icon: Icons.card_giftcard_rounded, price: '₹199'),
            _DiscoveryItem(title: 'Mini Lamp Set', subtitle: 'Glow Gifts', accent: Color(0xFF5C8FD8), icon: Icons.light_rounded, price: '₹349'),
            _DiscoveryItem(title: 'Photo Frame', subtitle: 'Craft Spot', accent: Color(0xFF4DAF50), icon: Icons.photo_rounded, price: '₹179'),
            _DiscoveryItem(title: 'Dry Fruit Box', subtitle: 'Nourish Mart', accent: Color(0xFFF2A13D), icon: Icons.inventory_rounded, price: '₹329'),
            _DiscoveryItem(title: 'Perfume Set', subtitle: 'Gift Aura', accent: Color(0xFF1FB8A4), icon: Icons.spa_rounded, price: '₹449'),
            _DiscoveryItem(title: 'Decor Hamper', subtitle: 'House Gift', accent: Color(0xFFFF954A), icon: Icons.celebration_rounded, price: '₹299'),
          ],
        ),
        _DiscoverySection(
          title: 'Grocery items',
          caption: 'Daily groceries from promoted shops',
          items: [
            _DiscoveryItem(title: 'Atta Pack', subtitle: 'Daily Mart', accent: Color(0xFFF2A13D), icon: Icons.inventory_2_rounded, price: '₹259'),
            _DiscoveryItem(title: 'Dal Combo', subtitle: 'Fresh Basket', accent: Color(0xFF4DAF50), icon: Icons.grain_rounded, price: '₹189'),
            _DiscoveryItem(title: 'Rice Bag', subtitle: 'Family Store', accent: Color(0xFFCB6E5B), icon: Icons.rice_bowl_rounded, price: '₹399'),
            _DiscoveryItem(title: 'Milk & Bread', subtitle: 'Morning Mart', accent: Color(0xFF5C8FD8), icon: Icons.breakfast_dining_rounded, price: '₹79'),
            _DiscoveryItem(title: 'Tea Pack', subtitle: 'Tea Corner', accent: Color(0xFF1FB8A4), icon: Icons.emoji_food_beverage_rounded, price: '₹149'),
            _DiscoveryItem(title: 'Snacks Box', subtitle: 'Snack House', accent: Color(0xFFFF954A), icon: Icons.cookie_rounded, price: '₹119'),
            _DiscoveryItem(title: 'Cold Drinks', subtitle: 'Quick Basket', accent: Color(0xFF5C8FD8), icon: Icons.local_drink_rounded, price: '₹99'),
            _DiscoveryItem(title: 'Cooking Oil', subtitle: 'Kitchen Hub', accent: Color(0xFFF2A13D), icon: Icons.water_drop_rounded, price: '₹179'),
          ],
        ),
        _DiscoverySection(
          title: 'Pharmacy items',
          caption: 'Wellness and care essentials from trusted pharmacies',
          items: [
            _DiscoveryItem(title: 'Paracetamol Kit', subtitle: 'Wellness Hub', accent: Color(0xFF1FB8A4), icon: Icons.medication_rounded, price: '₹59'),
            _DiscoveryItem(title: 'Vitamin Pack', subtitle: 'Care Plus', accent: Color(0xFF5C8FD8), icon: Icons.health_and_safety_rounded, price: '₹249'),
            _DiscoveryItem(title: 'Baby Lotion', subtitle: 'Tiny Care', accent: Color(0xFFDF7DA0), icon: Icons.child_friendly_rounded, price: '₹199'),
            _DiscoveryItem(title: 'Face Wash', subtitle: 'Glow Pharmacy', accent: Color(0xFFF2A13D), icon: Icons.spa_rounded, price: '₹149'),
            _DiscoveryItem(title: 'Sanitizer', subtitle: 'Medi Quick', accent: Color(0xFF4DAF50), icon: Icons.clean_hands_rounded, price: '₹99'),
            _DiscoveryItem(title: 'Bandage Pack', subtitle: 'Wellness Hub', accent: Color(0xFFCB6E5B), icon: Icons.healing_rounded, price: '₹89'),
            _DiscoveryItem(title: 'Baby Diapers', subtitle: 'Tiny Care', accent: Color(0xFF5C8FD8), icon: Icons.baby_changing_station_rounded, price: '₹349'),
            _DiscoveryItem(title: 'Protein Drink', subtitle: 'Care Plus', accent: Color(0xFF1FB8A4), icon: Icons.local_drink_rounded, price: '₹399'),
          ],
        ),
        _DiscoverySection(
          title: 'Fashion items',
          caption: 'Popular fashion picks from promoted shops',
          items: [
            _DiscoveryItem(title: 'Cotton Kurta', subtitle: 'Style Studio', accent: Color(0xFFDF7DA0), icon: Icons.checkroom_rounded, price: '₹699'),
            _DiscoveryItem(title: 'Men Shirt', subtitle: 'Urban Wear', accent: Color(0xFF5C8FD8), icon: Icons.dry_cleaning_rounded, price: '₹599'),
            _DiscoveryItem(title: 'Saree Set', subtitle: 'Grace House', accent: Color(0xFFE55A57), icon: Icons.style_rounded, price: '₹1,099'),
            _DiscoveryItem(title: 'Kids Tee', subtitle: 'Tiny Trends', accent: Color(0xFF4DAF50), icon: Icons.child_care_rounded, price: '₹299'),
            _DiscoveryItem(title: 'Handbag', subtitle: 'Carry Charm', accent: Color(0xFFF2A13D), icon: Icons.shopping_bag_rounded, price: '₹899'),
            _DiscoveryItem(title: 'Women Dress', subtitle: 'Bloom Boutique', accent: Color(0xFFDF7DA0), icon: Icons.checkroom_rounded, price: '₹1,249'),
            _DiscoveryItem(title: 'Sneakers', subtitle: 'Step Up', accent: Color(0xFF5C8FD8), icon: Icons.hiking_rounded, price: '₹1,499'),
            _DiscoveryItem(title: 'Watch Combo', subtitle: 'Urban Wear', accent: Color(0xFFCB6E5B), icon: Icons.watch_rounded, price: '₹999'),
          ],
        ),
      ];

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
              : _shopSubcategoriesFor(_selectedShopCategory);

  List<_DiscoverySection> get _filteredShopSections {
    final categorySections = _shopSections.where((section) {
      return _selectedShopCategory == 'All' ||
          _shopCategoryForSection(section) == _selectedShopCategory;
    }).toList();

    final effectiveSections = categorySections.isEmpty ? _shopSections : categorySections;
    final selectedSubcategory = _selectedShopSubcategories.contains(_selectedShopSubCategory)
        ? _selectedShopSubCategory
        : 'All';

    if (selectedSubcategory == 'All') {
      return effectiveSections.map(_sortShopSection).toList();
    }

    final filtered = effectiveSections
        .map(
          (section) => _DiscoverySection(
            title: section.title,
            caption: section.caption,
            items: section.items
                .where(
                  (item) => _shopTimingFor(item.subtitle, _shopCategoryForSection(section)).isOpen,
                )
                .where(
                  (item) => _shopSubcategoryFor(item, _shopCategoryForSection(section)) ==
                      selectedSubcategory,
                )
                .toList(),
          ),
        )
        .where((section) => section.items.isNotEmpty)
        .toList();

    if (selectedSubcategory == 'All') {
      final openSections = effectiveSections
          .map(
            (section) => _DiscoverySection(
              title: section.title,
              caption: section.caption,
              items: section.items
                  .where(
                    (item) => _shopTimingFor(item.subtitle, _shopCategoryForSection(section)).isOpen,
                  )
                  .toList(),
            ),
          )
          .where((section) => section.items.isNotEmpty)
          .toList();
      final sections = openSections.isEmpty ? effectiveSections : openSections;
      return sections.map(_sortShopSection).toList();
    }

    final sections = filtered.isEmpty ? effectiveSections : filtered;
    return sections.map(_sortShopSection).toList();
  }

  _DiscoverySection _sortShopSection(_DiscoverySection section) {
    final sortedItems = _sortShopItems(section.items);
    return _DiscoverySection(
      title: section.title,
      caption: section.caption,
      items: sortedItems,
    );
  }

  List<_DiscoveryItem> _sortShopItems(List<_DiscoveryItem> items) {
    final sorted = [...items];
    switch (_shopSortOption) {
      case 'Low to High':
        sorted.sort((left, right) => _extractAmount(left.price).compareTo(_extractAmount(right.price)));
        break;
      case 'High to Low':
        sorted.sort((left, right) => _extractAmount(right.price).compareTo(_extractAmount(left.price)));
        break;
      case 'Newly Added':
        return sorted.reversed.toList();
      case 'Popular':
      default:
        sorted.sort((left, right) => _ratingScore(right.rating).compareTo(_ratingScore(left.rating)));
        break;
    }
    return sorted;
  }

  double _ratingScore(String rating) =>
      double.tryParse(rating.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;

  List<_DiscoveryItem> get _filteredShopWiseItems {
    final items = _filteredShopSections.expand((section) => section.items).toList();
    final result = items.isEmpty
        ? _shopSections.expand((section) => section.items).take(8).toList()
        : items;
    return _sortShopItems(result);
  }

  bool get _showShopAllLanding =>
      _shopBrowseMode == _ShopBrowseMode.itemWise &&
      _selectedShopCategory == 'All' &&
      _selectedShopSubCategory == 'All';

  bool get _showShopRestaurantLanding => _selectedShopCategory == 'Restaurant';
  bool get _showShopFashionLanding => _selectedShopCategory == 'Fashion';
  bool get _showShopFootwearLanding => _selectedShopCategory == 'Footwear';

  List<_RestaurantCuisineItem> get _effectiveRestaurantCuisines =>
      _restaurantRemoteCuisines.isEmpty ? _restaurantCuisineItems : _restaurantRemoteCuisines;

  List<_RestaurantListingItem> get _effectiveRestaurantListings {
    if (_restaurantRemoteShops.isEmpty) {
      return _restaurantListings;
    }
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
      return _filteredShopWiseItems;
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
          ),
        )
        .toList(growable: false);
  }

  List<_DiscoveryItem> get _effectiveFootwearShopCards {
    if (!_footwearRemoteReady || _footwearRemoteShops.isEmpty) {
      return _filteredShopWiseItems;
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
        ),
      )
      .toList(growable: false);

  List<_DiscoveryItem> get _shopRestaurantItems => const [
        _DiscoveryItem(
          title: 'Paneer Combo',
          subtitle: 'Urban Spoon',
          accent: Color(0xFFE87142),
          icon: Icons.restaurant_rounded,
          price: '₹299',
          rating: '4.8',
          distance: '1.3 km',
        ),
        _DiscoveryItem(
          title: 'Veg Thali',
          subtitle: 'Tadka House',
          accent: Color(0xFF4DAF50),
          icon: Icons.dinner_dining_rounded,
          price: '₹249',
          rating: '4.7',
          distance: '1.5 km',
        ),
        _DiscoveryItem(
          title: 'Burger Box',
          subtitle: 'Snack Street',
          accent: Color(0xFFCB6E5B),
          icon: Icons.lunch_dining_rounded,
          price: '₹179',
          rating: '4.6',
          distance: '1.1 km',
        ),
        _DiscoveryItem(
          title: 'South Meal',
          subtitle: 'Dosa Point',
          accent: Color(0xFFF2A13D),
          icon: Icons.ramen_dining_rounded,
          price: '₹219',
          rating: '4.8',
          distance: '1.9 km',
        ),
        _DiscoveryItem(
          title: 'Pizza Slice',
          subtitle: 'Cheese Town',
          accent: Color(0xFFDF7DA0),
          icon: Icons.local_pizza_rounded,
          price: '₹199',
          rating: '4.5',
          distance: '2.0 km',
        ),
        _DiscoveryItem(
          title: 'Family Pack',
          subtitle: 'Food Court',
          accent: Color(0xFF5C8FD8),
          icon: Icons.takeout_dining_rounded,
          price: '₹349',
          rating: '4.9',
          distance: '2.2 km',
        ),
      ];

  List<_RestaurantCuisineItem> get _restaurantCuisineItems => const [
        _RestaurantCuisineItem(
          label: 'All',
          imageKey: 'veg_thali',
          accent: Color(0xFFF5E1A2),
          icon: Icons.restaurant_menu_rounded,
        ),
        _RestaurantCuisineItem(
          label: 'North Indian',
          imageKey: 'paneer_combo',
          accent: Color(0xFFF7C088),
          icon: Icons.dinner_dining_rounded,
        ),
        _RestaurantCuisineItem(
          label: 'Dessert',
          imageKey: 'skincare_combo',
          accent: Color(0xFFF5B7CC),
          icon: Icons.icecream_rounded,
        ),
        _RestaurantCuisineItem(
          label: 'Burgers',
          imageKey: 'burger_box',
          accent: Color(0xFFE9C07B),
          icon: Icons.lunch_dining_rounded,
        ),
        _RestaurantCuisineItem(
          label: 'Pizzas',
          imageKey: 'pizza_slice',
          accent: Color(0xFFEECF8B),
          icon: Icons.local_pizza_rounded,
        ),
        _RestaurantCuisineItem(
          label: 'South Indian',
          imageKey: 'south_meal',
          accent: Color(0xFFE4BE7D),
          icon: Icons.ramen_dining_rounded,
        ),
        _RestaurantCuisineItem(
          label: 'Meals',
          imageKey: 'veg_thali',
          accent: Color(0xFFD9E9B8),
          icon: Icons.rice_bowl_rounded,
        ),
      ];

  List<_RestaurantListingItem> get _restaurantListings => const [
        _RestaurantListingItem(
          item: _DiscoveryItem(
            title: "Haldiram's",
            subtitle: 'Popular sweets and meals',
            accent: Color(0xFFE5A14B),
            icon: Icons.icecream_rounded,
            rating: '4.4',
            distance: '3.0 km',
          ),
          offer: '₹65 off above ₹399',
          eta: '25-30 mins',
          location: 'Palam, 3.0 km',
          cuisineLine: 'Sweets, South Indian · ₹450 for two',
        ),
        _RestaurantListingItem(
          item: _DiscoveryItem(
            title: 'Dangee Sandwich',
            subtitle: 'Crisp snack combos',
            accent: Color(0xFFCB8A53),
            icon: Icons.breakfast_dining_rounded,
            rating: '4.2',
            distance: '2.1 km',
          ),
          offer: 'Items at ₹99',
          eta: '30-35 mins',
          location: 'Nawada Chowk, 2.1 km',
          cuisineLine: 'Sandwiches, Snacks · ₹250 for two',
        ),
        _RestaurantListingItem(
          item: _DiscoveryItem(
            title: 'Cheese Town',
            subtitle: 'Loaded pizza specials',
            accent: Color(0xFFE46D5E),
            icon: Icons.local_pizza_rounded,
            rating: '4.5',
            distance: '1.9 km',
          ),
          offer: 'Flat ₹120 off',
          eta: '20-25 mins',
          location: 'Pocket C, 1.9 km',
          cuisineLine: 'Pizza, Fast food · ₹380 for two',
        ),
        _RestaurantListingItem(
          item: _DiscoveryItem(
            title: 'Tadka House',
            subtitle: 'Veg thali and curry',
            accent: Color(0xFF5CA86D),
            icon: Icons.dinner_dining_rounded,
            rating: '4.6',
            distance: '1.6 km',
          ),
          offer: 'Free dessert on combos',
          eta: '18-24 mins',
          location: 'Block C, 1.6 km',
          cuisineLine: 'North Indian, Meals · ₹320 for two',
        ),
        _RestaurantListingItem(
          item: _DiscoveryItem(
            title: 'Urban Spoon',
            subtitle: 'Paneer and family platters',
            accent: Color(0xFFE87142),
            icon: Icons.restaurant_rounded,
            rating: '4.3',
            distance: '1.4 km',
          ),
          offer: '20% off above ₹499',
          eta: '22-28 mins',
          location: 'Raghunathpur, 1.4 km',
          cuisineLine: 'North Indian, Chinese · ₹420 for two',
        ),
        _RestaurantListingItem(
          item: _DiscoveryItem(
            title: 'Mr. Shakes',
            subtitle: 'Shakes and quick bites',
            accent: Color(0xFFB96B59),
            icon: Icons.local_cafe_rounded,
            rating: '4.1',
            distance: '2.4 km',
          ),
          offer: '50% off select items',
          eta: '20-25 mins',
          location: 'Salapur Road, 2.4 km',
          cuisineLine: 'Beverages, Sandwiches · ₹280 for two',
        ),
      ];

  List<(String, Color, Color, List<_DiscoveryItem>)> get _shopFashionPanels => const [
        (
          'Men style',
          Color(0xFF8FD0FF),
          Color(0xFF74BFF6),
          [
            _DiscoveryItem(title: 'Casual Shirt', subtitle: 'Men', accent: Color(0xFF5C8FD8), icon: Icons.checkroom_rounded, price: '₹599', rating: '4.7', distance: '1.2 km'),
            _DiscoveryItem(title: 'Denim Jeans', subtitle: 'Men', accent: Color(0xFF5C8FD8), icon: Icons.dry_cleaning_rounded, price: '₹899', rating: '4.6', distance: '1.2 km'),
            _DiscoveryItem(title: 'Classic Tee', subtitle: 'Men', accent: Color(0xFF5C8FD8), icon: Icons.checkroom_rounded, price: '₹399', rating: '4.8', distance: '1.3 km'),
            _DiscoveryItem(title: 'Formal Shoes', subtitle: 'Footwear', accent: Color(0xFF5C8FD8), icon: Icons.hiking_rounded, price: '₹1,299', rating: '4.5', distance: '1.7 km'),
          ],
        ),
        (
          'Women picks',
          Color(0xFFFFB8CE),
          Color(0xFFF38AAA),
          [
            _DiscoveryItem(title: 'Printed Kurta', subtitle: 'Women', accent: Color(0xFFDF7DA0), icon: Icons.checkroom_rounded, price: '₹799', rating: '4.8', distance: '1.4 km'),
            _DiscoveryItem(title: 'Floral Dress', subtitle: 'Women', accent: Color(0xFFDF7DA0), icon: Icons.style_rounded, price: '₹1,199', rating: '4.6', distance: '1.6 km'),
            _DiscoveryItem(title: 'Handbag Set', subtitle: 'Women', accent: Color(0xFFDF7DA0), icon: Icons.shopping_bag_rounded, price: '₹999', rating: '4.7', distance: '1.8 km'),
            _DiscoveryItem(title: 'Heels Pair', subtitle: 'Footwear', accent: Color(0xFFDF7DA0), icon: Icons.hiking_rounded, price: '₹1,149', rating: '4.5', distance: '1.9 km'),
          ],
        ),
        (
          'Kids corner',
          Color(0xFFFFD48C),
          Color(0xFFF2A13D),
          [
            _DiscoveryItem(title: 'Kids Tee', subtitle: 'Kids', accent: Color(0xFFF2A13D), icon: Icons.child_care_rounded, price: '₹299', rating: '4.8', distance: '1.2 km'),
            _DiscoveryItem(title: 'Shorts Pack', subtitle: 'Kids', accent: Color(0xFFF2A13D), icon: Icons.checkroom_rounded, price: '₹349', rating: '4.6', distance: '1.4 km'),
            _DiscoveryItem(title: 'School Shoes', subtitle: 'Footwear', accent: Color(0xFFF2A13D), icon: Icons.hiking_rounded, price: '₹699', rating: '4.7', distance: '1.6 km'),
            _DiscoveryItem(title: 'Party Set', subtitle: 'Kids', accent: Color(0xFFF2A13D), icon: Icons.style_rounded, price: '₹899', rating: '4.5', distance: '1.8 km'),
          ],
        ),
        (
          'Footwear',
          Color(0xFF9DE8D5),
          Color(0xFF39C3A8),
          [
            _DiscoveryItem(title: 'Sneakers', subtitle: 'Footwear', accent: Color(0xFF1FB8A4), icon: Icons.hiking_rounded, price: '₹1,499', rating: '4.8', distance: '1.3 km'),
            _DiscoveryItem(title: 'Sandals', subtitle: 'Footwear', accent: Color(0xFF1FB8A4), icon: Icons.hiking_rounded, price: '₹749', rating: '4.4', distance: '1.5 km'),
            _DiscoveryItem(title: 'Slides', subtitle: 'Footwear', accent: Color(0xFF1FB8A4), icon: Icons.hiking_rounded, price: '₹499', rating: '4.6', distance: '1.8 km'),
            _DiscoveryItem(title: 'Sport Shoes', subtitle: 'Footwear', accent: Color(0xFF1FB8A4), icon: Icons.hiking_rounded, price: '₹1,299', rating: '4.7', distance: '1.9 km'),
          ],
        ),
      ];

  List<(String, Color, Color, List<_DiscoveryItem>)> get _shopFootwearPanels => const [
        (
          'Men',
          Color(0xFFEAF2FF),
          Color(0xFFD5E6FF),
          [
            _DiscoveryItem(title: 'Formal Shoes', subtitle: 'Footwear', accent: Color(0xFF5C8FD8), icon: Icons.hiking_rounded, price: '₹1,299', rating: '4.5', distance: '1.7 km'),
            _DiscoveryItem(title: 'Sneakers', subtitle: 'Footwear', accent: Color(0xFF5C8FD8), icon: Icons.directions_walk_rounded, price: '₹1,499', rating: '4.7', distance: '1.5 km'),
            _DiscoveryItem(title: 'Slippers', subtitle: 'Footwear', accent: Color(0xFF5C8FD8), icon: Icons.airline_seat_legroom_normal_rounded, price: '₹499', rating: '4.3', distance: '1.8 km'),
            _DiscoveryItem(title: 'Loafers', subtitle: 'Footwear', accent: Color(0xFF5C8FD8), icon: Icons.checkroom_rounded, price: '₹1,149', rating: '4.6', distance: '1.6 km'),
          ],
        ),
        (
          'Women',
          Color(0xFFFFEFF5),
          Color(0xFFFFDCE8),
          [
            _DiscoveryItem(title: 'Heels', subtitle: 'Footwear', accent: Color(0xFFDF7DA0), icon: Icons.woman_rounded, price: '₹1,149', rating: '4.5', distance: '1.9 km'),
            _DiscoveryItem(title: 'Sandals', subtitle: 'Footwear', accent: Color(0xFFDF7DA0), icon: Icons.hiking_rounded, price: '₹799', rating: '4.4', distance: '1.5 km'),
            _DiscoveryItem(title: 'Flats', subtitle: 'Footwear', accent: Color(0xFFDF7DA0), icon: Icons.checkroom_rounded, price: '₹649', rating: '4.6', distance: '1.4 km'),
            _DiscoveryItem(title: 'Party Heels', subtitle: 'Footwear', accent: Color(0xFFDF7DA0), icon: Icons.auto_awesome_rounded, price: '₹1,499', rating: '4.7', distance: '1.8 km'),
          ],
        ),
        (
          'Boys',
          Color(0xFFFFF3E1),
          Color(0xFFFFE0AF),
          [
            _DiscoveryItem(title: 'School Shoes', subtitle: 'Footwear', accent: Color(0xFFF2A13D), icon: Icons.hiking_rounded, price: '₹699', rating: '4.7', distance: '1.6 km'),
            _DiscoveryItem(title: 'Sports Shoes', subtitle: 'Footwear', accent: Color(0xFFF2A13D), icon: Icons.directions_run_rounded, price: '₹999', rating: '4.5', distance: '1.7 km'),
            _DiscoveryItem(title: 'Kids Sandals', subtitle: 'Footwear', accent: Color(0xFFF2A13D), icon: Icons.child_friendly_rounded, price: '₹549', rating: '4.4', distance: '1.8 km'),
            _DiscoveryItem(title: 'Slides', subtitle: 'Footwear', accent: Color(0xFFF2A13D), icon: Icons.airline_seat_legroom_normal_rounded, price: '₹399', rating: '4.6', distance: '1.5 km'),
          ],
        ),
        (
          'Girls',
          Color(0xFFFFF0F7),
          Color(0xFFFFDBEA),
          [
            _DiscoveryItem(title: 'Cute Sandals', subtitle: 'Footwear', accent: Color(0xFFE75D93), icon: Icons.girl_rounded, price: '₹699', rating: '4.7', distance: '1.3 km'),
            _DiscoveryItem(title: 'Ballet Flats', subtitle: 'Footwear', accent: Color(0xFFE75D93), icon: Icons.auto_awesome_rounded, price: '₹799', rating: '4.6', distance: '1.4 km'),
            _DiscoveryItem(title: 'School Shoes', subtitle: 'Footwear', accent: Color(0xFFE75D93), icon: Icons.hiking_rounded, price: '₹749', rating: '4.5', distance: '1.7 km'),
            _DiscoveryItem(title: 'Party Sandals', subtitle: 'Footwear', accent: Color(0xFFE75D93), icon: Icons.star_rounded, price: '₹899', rating: '4.8', distance: '1.5 km'),
          ],
        ),
      ];

  List<_DiscoveryItem> get _shopBeautyItems => const [
        _DiscoveryItem(title: 'Glow Face Kit', subtitle: 'Beauty Hub', accent: Color(0xFFDF7DA0), icon: Icons.spa_rounded, price: '₹699', rating: '4.8', distance: '1.1 km'),
        _DiscoveryItem(title: 'Skincare Combo', subtitle: 'Pure Beauty', accent: Color(0xFFCB6E5B), icon: Icons.spa_rounded, price: '₹899', rating: '4.7', distance: '1.4 km'),
        _DiscoveryItem(title: 'Hair Care Pack', subtitle: 'Salon Mart', accent: Color(0xFFF2A13D), icon: Icons.content_cut_rounded, price: '₹649', rating: '4.6', distance: '1.7 km'),
        _DiscoveryItem(title: 'Makeup Edit', subtitle: 'Beauty Hub', accent: Color(0xFFB45DE8), icon: Icons.brush_rounded, price: '₹1,099', rating: '4.9', distance: '1.9 km'),
      ];

  List<_DiscoveryItem> get _shopMedicineItems => const [
        _DiscoveryItem(title: 'Paracetamol', subtitle: 'Medi Quick', accent: Color(0xFF5C8FD8), icon: Icons.medication_rounded, price: '₹28', rating: '4.8', distance: '1.0 km'),
        _DiscoveryItem(title: 'ORS Pack', subtitle: 'Wellness Hub', accent: Color(0xFF1FB8A4), icon: Icons.local_drink_rounded, price: '₹22', rating: '4.7', distance: '1.1 km'),
        _DiscoveryItem(title: 'Cough Syrup', subtitle: 'Care Plus', accent: Color(0xFFCB6E5B), icon: Icons.medication_liquid_rounded, price: '₹76', rating: '4.6', distance: '1.3 km'),
        _DiscoveryItem(title: 'Vitamin C', subtitle: 'Glow Pharmacy', accent: Color(0xFFF2A13D), icon: Icons.health_and_safety_rounded, price: '₹95', rating: '4.9', distance: '1.5 km'),
        _DiscoveryItem(title: 'Pain Relief', subtitle: 'Medi Quick', accent: Color(0xFFDF7DA0), icon: Icons.healing_rounded, price: '₹54', rating: '4.7', distance: '1.2 km'),
        _DiscoveryItem(title: 'Bandage', subtitle: 'Wellness Hub', accent: Color(0xFF4DAF50), icon: Icons.medical_services_rounded, price: '₹35', rating: '4.8', distance: '1.0 km'),
        _DiscoveryItem(title: 'Vapor Rub', subtitle: 'Care Plus', accent: Color(0xFF5C8FD8), icon: Icons.spa_rounded, price: '₹68', rating: '4.5', distance: '1.6 km'),
        _DiscoveryItem(title: 'Antacid', subtitle: 'Glow Pharmacy', accent: Color(0xFF1FB8A4), icon: Icons.medication_rounded, price: '₹48', rating: '4.6', distance: '1.4 km'),
      ];

  List<_GiftOccasionItem> get _giftOccasionItems => const [
        _GiftOccasionItem(
          label: 'Siblings\nDay',
          imageKey: 'siblings_day',
          accent: Color(0xFFFFE98F),
          icon: Icons.card_giftcard_rounded,
        ),
        _GiftOccasionItem(
          label: 'Birthday',
          imageKey: 'birthday',
          accent: Color(0xFFF8E3E6),
          icon: Icons.cake_rounded,
        ),
        _GiftOccasionItem(
          label: 'Anniversary',
          imageKey: 'anniversary',
          accent: Color(0xFFF6E6E8),
          icon: Icons.watch_later_rounded,
        ),
        _GiftOccasionItem(
          label: 'Visiting\nsomeone',
          imageKey: 'visiting_someone',
          accent: Color(0xFFF7E7E1),
          icon: Icons.favorite_border_rounded,
        ),
      ];

  List<_GiftFavouriteTileItem> get _giftFavouriteItems => const [
        _GiftFavouriteTileItem(
          label: 'Cakes\n& Sweets',
          imageKey: 'cakes_sweets',
          accent: Color(0xFFB5C8E5),
          icon: Icons.cake_rounded,
        ),
        _GiftFavouriteTileItem(
          label: 'Gadgets',
          imageKey: 'gadgets',
          accent: Color(0xFFD1D9F2),
          icon: Icons.headphones_rounded,
        ),
        _GiftFavouriteTileItem(
          label: 'Flowers &\nPlants',
          imageKey: 'flowers_plants',
          accent: Color(0xFFDCE6D8),
          icon: Icons.local_florist_rounded,
        ),
        _GiftFavouriteTileItem(
          label: 'Beauty',
          imageKey: 'beauty',
          accent: Color(0xFF8A8456),
          icon: Icons.spa_rounded,
        ),
        _GiftFavouriteTileItem(
          label: 'Games\n& Toys',
          imageKey: 'games_toys',
          accent: Color(0xFFD9D6D0),
          icon: Icons.toys_rounded,
        ),
        _GiftFavouriteTileItem(
          label: 'Home',
          imageKey: 'home',
          accent: Color(0xFFE7D2C1),
          icon: Icons.chair_alt_rounded,
        ),
        _GiftFavouriteTileItem(
          label: 'Fashion',
          imageKey: 'fashion',
          accent: Color(0xFFF1CCC6),
          icon: Icons.checkroom_rounded,
        ),
        _GiftFavouriteTileItem(
          label: 'Books',
          imageKey: 'books',
          accent: Color(0xFFE2D0BC),
          icon: Icons.menu_book_rounded,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    const pinnedSearchHeaderHeight = 58.0;
    const pinnedModeHeaderHeight = 44.0;
    const pinnedFilterHeaderHeight = 58.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
          systemStatusBarContrastEnforced: false,
        ),
        child: Column(
          children: [
            Container(
              height: topInset,
              color: _headerGradient(_mode).first,
            ),
            Expanded(
              child: SafeArea(
                top: false,
                bottom: false,
                child: Container(
                  color: Colors.white,
                  child: CustomScrollView(
                    controller: _scrollController,
                    slivers: [
                    SliverToBoxAdapter(
                      child: Container(
                        color: _headerGradient(_mode).first,
                        child: const Padding(
                          padding: EdgeInsets.fromLTRB(18, 2, 18, 6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _HomeHeader(),
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
                    if (_mode != _HomeMode.all)
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
                                  Colors.white,
                                ],
                                stops: const [0, 0.44, 0.82, 1],
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
                                      selectedTextColor: _modeTint(_mode),
                                      disabledFilters: _mode == _HomeMode.shop ? _shopComingSoonCategories : const {},
                                      onSelected: _handleFilterSelect,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (_mode != _HomeMode.all)
                      SliverToBoxAdapter(
                        child: Container(
                          height: 14,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                _headerGradient(_mode)[2],
                                Colors.white,
                              ],
                            ),
                          ),
                        ),
                      ),
                    if (_mode == _HomeMode.all)
                      SliverToBoxAdapter(
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                _headerGradient(_mode).first,
                                _headerGradient(_mode)[1],
                                _headerGradient(_mode)[2],
                                Colors.white,
                              ],
                              stops: const [0, 0.36, 0.76, 1],
                            ),
                          ),
                        ),
                      ),
                    ..._buildModeSlivers(),
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
          FloatingActionButton(
            heroTag: 'cartFloat',
            onPressed: _openCartPage,
            backgroundColor: const Color(0xFFCB6E5B),
            foregroundColor: Colors.white,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.shopping_cart_checkout_rounded),
                if (_cartItems.isNotEmpty)
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

  String get _selectedFilter {
    switch (_mode) {
      case _HomeMode.all:
        return _modeFilters.first;
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
        return _selectedShopCategory;
    }
  }

  void _handleFilterSelect(String value) {
    if (_mode == _HomeMode.shop && _shopComingSoonCategories.contains(value)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$value is coming soon.')),
      );
      return;
    }
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

  void _openAllQuickCategoryDestination(String value) {
    String targetCategory;
    String targetSubcategory = 'All';
    String targetCuisine = 'All';

    switch (value) {
      case 'Bakery':
        targetCategory = 'Restaurant';
        targetCuisine = 'Dessert';
        break;
      case 'Dining':
        targetCategory = 'Restaurant';
        break;
      case 'Gifting':
        targetCategory = 'Gift';
        break;
      case 'Pharmacy':
        targetCategory = 'Pharmacy';
        break;
      case 'Essentials':
        targetCategory = 'Pharmacy';
        targetSubcategory = 'Essentials';
        break;
      case 'Kitchen':
        targetCategory = 'Groceries';
        break;
      case 'Groceries':
      default:
        targetCategory = 'Groceries';
        break;
    }

    if (_shopComingSoonCategories.contains(targetCategory)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$targetCategory is coming soon.')),
      );
      return;
    }

    setState(() {
      _selectedAllQuickCategory = value;
      _mode = _HomeMode.shop;
      _shopBrowseMode = _ShopBrowseMode.itemWise;
      _selectedShopCategory = targetCategory;
      _selectedShopSubCategory = _shopSubcategoriesFor(targetCategory).contains(targetSubcategory)
          ? targetSubcategory
          : 'All';
      _selectedRestaurantCuisine = targetCuisine;
      _fashionVisibleProductCount = _fashionProductBatchSize;
      _footwearVisibleProductCount = _footwearProductBatchSize;
    });
    if (targetCategory == 'Restaurant') {
      unawaited(_loadRestaurantLanding(silent: false));
    } else if (targetCategory == 'Gift') {
      unawaited(_loadGiftLanding(silent: false));
    } else if (targetCategory == 'Groceries') {
      unawaited(_loadGroceryLanding(silent: false));
    } else if (targetCategory == 'Pharmacy') {
      unawaited(_loadPharmacyLanding(silent: false));
    }
  }

  List<Widget> _buildModeSlivers() {
    switch (_mode) {
      case _HomeMode.all:
        return _buildAllMode();
      case _HomeMode.labour:
        return _buildLabourMode();
      case _HomeMode.service:
        return _buildServiceMode();
      case _HomeMode.shop:
        return _buildShopMode();
    }
  }

  List<Widget> _buildAllMode() {
    final sections = _filteredAllSections;
    final slivers = <Widget>[
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: _AllQuickCategoryStrip(
            items: _allQuickCategories,
            selected: _selectedAllQuickCategory,
            onSelected: _openAllQuickCategoryDestination,
          ),
        ),
      ),
    ];

    if (_remoteSyncInFlight && _backendTopProducts.isEmpty) {
      slivers.add(
        _buildRemoteStateSliver(
          icon: Icons.storefront_rounded,
          title: 'Loading live shop picks',
          message: 'We are fetching fresh products and cart state from the user app API.',
          loading: true,
        ),
      );
    } else if (_homeBootstrapError != null && _backendTopProducts.isEmpty) {
      slivers.add(
        _buildRemoteStateSliver(
          icon: Icons.cloud_off_rounded,
          title: 'Could not load live shop picks',
          message: _homeBootstrapError!,
          actionLabel: 'Try Again',
          onAction: () => unawaited(_hydrateRemoteState(silent: false)),
        ),
      );
    } else if (!_remoteSyncInFlight && _backendTopProducts.isEmpty) {
      slivers.add(
        _buildRemoteStateSliver(
          icon: Icons.inventory_2_outlined,
          title: 'Live shop picks will appear here',
          message: 'As soon as the live catalog returns products, we will show them in this section.',
          actionLabel: 'Refresh',
          onAction: () => unawaited(_hydrateRemoteState(silent: false)),
        ),
      );
    }

    if (_backendTopProducts.isNotEmpty) {
      slivers.add(
        SliverToBoxAdapter(
          child: _HorizontalDiscoverySection(
            title: 'Live shop picks',
            caption: 'Loaded from the new user app API',
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

    for (final section in sections) {
      if (section.title == 'Available labour') {
        slivers.add(
          SliverToBoxAdapter(
            child: _AllLabourSection(
              title: section.title,
              items: section.items,
              isFavourited: _isFavourited,
              onFavouriteToggle: _toggleFavourite,
              onTap: (item) => _openCard(item, _HomeMode.labour),
            ),
          ),
        );
        continue;
      }
      if (section.title == 'Repair picks') {
        slivers.add(
          SliverToBoxAdapter(
            child: _AllServiceSection(
              title: section.title,
              items: section.items,
              onTap: (item) => _openCard(item, _HomeMode.service),
            ),
          ),
        );
        slivers.add(
          SliverToBoxAdapter(
            child: _ShopGiftSection(
              occasions: _giftOccasionItems,
              favourites: _giftFavouriteItems,
              showOccasions: false,
            ),
          ),
        );
        slivers.add(
          const SliverToBoxAdapter(
            child: _AllHouseholdEssentialsSection(),
          ),
        );
        continue;
      }
      slivers.add(
        SliverToBoxAdapter(
          child: _HorizontalDiscoverySection(
            title: section.title,
            caption: section.caption,
            items: section.items,
            onTap: _openShopItemFromHome,
            isWishlisted: _isWishlisted,
            isFavourited: _isFavourited,
            onWishlistToggle: _toggleWishlist,
            onFavouriteToggle: _toggleFavourite,
            onAddToCart: (item) => _openShopProfile(item, autoAddItem: true),
          ),
        ),
      );
    }

    return slivers;
  }

  List<Widget> _buildLabourMode() {
    final labourStateSliver = _buildLabourStateSliver();
    return [
      SliverToBoxAdapter(
        child: ColoredBox(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 6, 18, 8),
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
          ),
        ),
      ),
      if (labourStateSliver != null)
        labourStateSliver
      else
      if (_labourViewMode == _LabourViewMode.individual)
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
          sliver: SliverGrid.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              mainAxisExtent: 246,
            ),
            itemCount: _labourItems.length,
            itemBuilder: (context, index) {
              final item = _labourItems[index];
              return _LabourPortraitTile(
                item: item,
                isFavourited: _isFavourited(item),
                onFavouriteToggle: () => _toggleFavourite(item),
                onTap: () => _openCard(item, _mode),
                compactScale: 0.62,
              );
            },
          ),
        )
      else
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
            child: _GroupBookingCard(
              availableLabour: 10,
              selectedMaxPrice: _selectedLabourPrice,
              selectedPricePeriod: _selectedLabourPricePeriod,
              selectedCount: _selectedLabourCount,
              onPriceSelected: (value) => setState(() => _selectedLabourPrice = value),
              onPricePeriodSelected: (value) => setState(() => _selectedLabourPricePeriod = value),
              onCountSelected: (value) => setState(() => _selectedLabourCount = value),
              onBook: () async {
                final categoryId = _labourCategoryIdForLabel(_selectedLabourCategory);
                if (categoryId == null) {
                  _showCartSnack('Please select a labour category first.');
                  return;
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Request ${result.requestCode} sent to ${result.availableCandidates} matching labour. Platform amount due: ${result.platformAmountDue}.',
                      ),
                    ),
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

  List<Widget> _buildServiceMode() {
    final providers = _filteredServiceProviders;
    final serviceStateSliver = _buildServiceStateSliver();
    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
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
        ),
      ),
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
            onTap: () => _openCard(providers[index], _mode),
          ),
        ),
    ];
  }

  List<Widget> _buildShopMode() {
    final shopSections = _filteredShopSections;
    final shopWiseItems = _filteredShopWiseItems;
    final shopRemoteStateSliver = _buildShopRemoteStateSliver();
    final openTopFoodItems = _restaurantRemoteProducts.isEmpty
        ? _shopRestaurantItems.where((item) => _shopTimingFor(item.subtitle, 'Restaurant').isOpen).toList()
        : _restaurantRemoteProducts;
    final visibleRestaurantListings = _restaurantRemoteShops.isEmpty
        ? _restaurantListings
            .where((listing) => _shopTimingFor(listing.item.subtitle, 'Restaurant').isOpen)
            .toList()
        : _effectiveRestaurantListings;
    return [
      if (!_showShopRestaurantLanding)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
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
        ),
      if (_shopBrowseMode == _ShopBrowseMode.itemWise &&
          _selectedShopSubcategories.length > 1 &&
          _selectedShopCategory != 'Groceries' &&
          _selectedShopCategory != 'Pharmacy')
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
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
        ),
      if (shopRemoteStateSliver != null)
        shopRemoteStateSliver
      else
      if (_showShopAllLanding) ...[
        SliverToBoxAdapter(
          child: _ShopSingleRowSection(
            title: 'Top food',
            items: openTopFoodItems.isEmpty ? _shopRestaurantItems : openTopFoodItems,
            onTap: _openShopProfile,
            isWishlisted: _isWishlisted,
            isFavourited: _isFavourited,
            onWishlistToggle: _toggleWishlist,
            onFavouriteToggle: _toggleFavourite,
            onAddToCart: (item) => _openShopProfile(item, autoAddItem: true),
          ),
        ),
        SliverToBoxAdapter(
          child: _ShopFashionPanelsSection(
            panels: _shopFashionPanels,
            onTap: _openShopProfile,
          ),
        ),
        SliverToBoxAdapter(
          child: _ShopFootwearPanelsSection(
            panels: _shopFootwearPanels,
            onTap: _openShopProfile,
          ),
        ),
        SliverToBoxAdapter(
          child: _ShopBeautySection(
            items: _shopBeautyItems,
            isWishlisted: _isWishlisted,
            onWishlistToggle: _toggleWishlist,
            onTap: _openShopProfile,
          ),
        ),
        SliverToBoxAdapter(
          child: _ShopMedicineSection(
            items: _shopMedicineItems,
            onTap: _openShopProfile,
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
        SliverToBoxAdapter(
          child: _RestaurantRecommendedSection(
            items: (visibleRestaurantListings.isEmpty ? _effectiveRestaurantListings : visibleRestaurantListings)
                .take(6)
                .toList(),
            onTap: (listing) => _openRestaurantListing(listing),
          ),
        ),
        SliverList.builder(
          itemCount: (visibleRestaurantListings.isEmpty ? _effectiveRestaurantListings : visibleRestaurantListings).length,
          itemBuilder: (context, index) {
            final source = visibleRestaurantListings.isEmpty ? _effectiveRestaurantListings : visibleRestaurantListings;
            final listing = source[index];
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
          SliverToBoxAdapter(
            child: _RemoteGiftShowcase(
              items: _giftRemoteProducts,
              onItemTap: _openShopItemFromHome,
            ),
          )
        else
        SliverToBoxAdapter(
          child: _GiftCategoryShowcase(
            selectedCategory: _selectedShopSubCategory,
            sortOption: _shopSortOption,
            onItemTap: _openShopItemFromHome,
            onShopTap: _openShopProfile,
            onAddToCart: (item) => _openShopProfile(item, autoAddItem: true),
            isWishlisted: _isWishlisted,
            onWishlistToggle: _toggleWishlist,
          ),
        ),
      ] else if (_shopBrowseMode == _ShopBrowseMode.itemWise && _selectedShopCategory == 'Groceries') ...[
        if (_groceryRemoteReady)
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
          SliverToBoxAdapter(
            child: _GroceryCategoryShowcase(
              selectedCategory: _selectedShopSubCategory,
              sortOption: _shopSortOption,
              onItemTap: _openShopItemFromHome,
              onShopTap: _openShopProfile,
              onAddToCart: (item) => _openShopProfile(item, autoAddItem: true),
              isWishlisted: _isWishlisted,
              onWishlistToggle: _toggleWishlist,
            ),
          ),
      ] else if (_shopBrowseMode == _ShopBrowseMode.itemWise && _selectedShopCategory == 'Pharmacy') ...[
        if (_pharmacyRemoteReady)
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
          SliverToBoxAdapter(
            child: _PharmacyCategoryShowcase(
              selectedCategory: _selectedShopSubCategory,
              sortOption: _shopSortOption,
              onItemTap: _openShopItemFromHome,
              onShopTap: _openShopProfile,
              onAddToCart: (item) => _openShopProfile(item, autoAddItem: true),
              isWishlisted: _isWishlisted,
              onWishlistToggle: _toggleWishlist,
            ),
          ),
      ] else if (_shopBrowseMode == _ShopBrowseMode.itemWise &&
          _showShopFashionLanding &&
          _fashionRemoteReady) ...[
        SliverToBoxAdapter(
          child: _RemoteFashionShowcase(
            items: _fashionRemoteProducts,
            hasMore: _fashionRemoteHasMore,
            onItemTap: _openShopItemFromHome,
            isWishlisted: _isWishlisted,
            onWishlistToggle: _toggleWishlist,
          ),
        ),
      ] else if (_shopBrowseMode == _ShopBrowseMode.itemWise &&
          _showShopFootwearLanding &&
          _footwearRemoteReady) ...[
        SliverToBoxAdapter(
          child: _RemoteFootwearShowcase(
            items: _footwearRemoteProducts,
            hasMore: _footwearRemoteHasMore,
            onItemTap: _openShopItemFromHome,
            isWishlisted: _isWishlisted,
            onWishlistToggle: _toggleWishlist,
          ),
        ),
      ] else if (_shopBrowseMode == _ShopBrowseMode.itemWise && _selectedShopCategory == 'Fashion') ...[
        SliverToBoxAdapter(
          child: _FashionCategoryShowcase(
            selectedCategory: _selectedShopSubCategory,
            onTap: _openShopProfile,
            onAddToCart: (item) => _openShopProfile(item, autoAddItem: true),
            isWishlisted: _isWishlisted,
            onWishlistToggle: _toggleWishlist,
            visibleFeedCount: _fashionVisibleProductCount,
            sortOption: _shopSortOption,
          ),
        ),
      ] else if (_shopBrowseMode == _ShopBrowseMode.itemWise && _selectedShopCategory == 'Footwear') ...[
        SliverToBoxAdapter(
          child: _FootwearCategoryShowcase(
            selectedCategory: _selectedShopSubCategory,
            onTap: _openShopProfile,
            onAddToCart: (item) => _openShopProfile(item, autoAddItem: true),
            isWishlisted: _isWishlisted,
            onWishlistToggle: _toggleWishlist,
            visibleFeedCount: _footwearVisibleProductCount,
            sortOption: _shopSortOption,
          ),
        ),
      ]
      else if (_shopBrowseMode == _ShopBrowseMode.itemWise)
        ...shopSections.map(
          (section) => SliverToBoxAdapter(
            child: _GridDiscoverySection(
              title: section.title,
              caption: section.caption,
              items: section.items,
              onTap: (item) => _openShopProfile(item),
              isWishlisted: _isWishlisted,
              onWishlistToggle: _toggleWishlist,
              onAddToCart: (item) => _openShopProfile(item, autoAddItem: true),
              hideHeader: _selectedShopCategory == 'Fashion',
            ),
          ),
        ),
      if (_shopBrowseMode == _ShopBrowseMode.shopWise && _selectedShopCategory == 'Groceries')
        SliverToBoxAdapter(
          child: _GroceryShopWiseSection(
            items: _groceryRemoteReady ? _effectiveGroceryShopCards : _filteredShopWiseItems,
            isWishlisted: _isWishlisted,
            onWishlistToggle: _toggleWishlist,
            onTap: _openShopProfile,
          ),
        ),
      if (_shopBrowseMode == _ShopBrowseMode.shopWise && _selectedShopCategory == 'Pharmacy')
        SliverToBoxAdapter(
          child: _PharmacyShopWiseSection(
            items: _pharmacyRemoteReady ? _effectivePharmacyShopCards : _filteredShopWiseItems,
            isWishlisted: _isWishlisted,
            onWishlistToggle: _toggleWishlist,
            onTap: _openShopProfile,
          ),
        ),
      if (_shopBrowseMode == _ShopBrowseMode.shopWise && _selectedShopCategory == 'Gift')
        SliverToBoxAdapter(
          child: _GiftShopWiseSection(
            items: _giftRemoteReady ? _effectiveGiftShopCards : _filteredShopWiseItems,
            isWishlisted: _isWishlisted,
            onWishlistToggle: _toggleWishlist,
            onTap: _openShopProfile,
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
      if (_shopBrowseMode == _ShopBrowseMode.shopWise)
        SliverList.builder(
          itemCount: (_selectedShopCategory == 'Groceries' ||
                  _selectedShopCategory == 'Fashion' ||
                  _selectedShopCategory == 'Footwear' ||
                  _selectedShopCategory == 'Pharmacy' ||
                  _selectedShopCategory == 'Gift')
              ? 0
              : shopWiseItems.length,
          itemBuilder: (context, index) => _VerticalShopCard(
            item: shopWiseItems[index],
            isWishlisted: _isWishlisted(shopWiseItems[index]),
            onWishlistToggle: () => _toggleWishlist(shopWiseItems[index]),
            onTap: () => _openShopProfile(shopWiseItems[index]),
          ),
        ),
    ];
  }

  void _openCard(_DiscoveryItem item, _HomeMode mode) {
    if (mode == _HomeMode.shop) {
      _openShopProfile(item);
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _DiscoveryDetailPage(
          item: item,
          mode: mode,
          isWishlisted: _isWishlisted(item),
          isFavourited: _isFavourited(item),
          onWishlistToggle: () => _toggleWishlist(item),
          onFavouriteToggle: () => _toggleFavourite(item),
          onPrimaryAction: (labourBookingPeriod) => _handlePrimaryAction(
            item,
            mode,
            labourBookingPeriod: labourBookingPeriod,
          ),
        ),
      ),
    );
  }

  Future<void> _openRestaurantListing(_RestaurantListingItem listing) async {
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
    final shopTiming = _shopTimingFor(item.subtitle, itemCategory);
    if (!shopTiming.isOpen) {
      _showCartSnack('${item.subtitle} is closed right now.');
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

  void _openShopProfile(_DiscoveryItem item, {bool autoAddItem = false}) {
    final inferredCategory =
        _selectedShopCategory == 'All' ? _shopCategoryForItem(item) : _selectedShopCategory;
    if (_shopComingSoonCategories.contains(inferredCategory)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$inferredCategory is coming soon.')),
      );
      return;
    }
    final shopTiming = _shopTimingFor(item.subtitle, inferredCategory);
    if (!shopTiming.isOpen) {
      _showCartSnack('${item.subtitle} is closed right now.');
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

  void _openProfilePage() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _ProfilePage(
          phoneNumber: widget.phoneNumber,
          onLogout: () async {
            await _NotificationBootstrap.deactivateCurrentToken();
            await _LocalSessionStore.clear();
            if (!mounted) {
              return;
            }
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute<void>(builder: (_) => const LoginPage()),
              (route) => false,
            );
          },
        ),
      ),
    );
  }

  Future<void> _openNotificationsPage() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const _NotificationsPage(),
      ),
    );
    await _refreshNotificationPreview(silent: true);
  }

  Future<void> _openCartPage() async {
    await _hydrateRemoteState();
    if (!mounted) {
      return;
    }
    if (_cartItems.isEmpty) {
      _showCartSnack('Your cart is empty right now.');
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _CartPage(
          shopName: _cartShopName ?? 'Selected shop',
          items: List<_DiscoveryItem>.unmodifiable(_cartItems),
          onCheckout: _checkoutFromCartPage,
        ),
      ),
    );
  }

  Future<void> _checkoutFromCartPage(int? addressId) async {
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

  Future<void> _handlePrimaryAction(
    _DiscoveryItem item,
    _HomeMode mode, {
    String? labourBookingPeriod,
  }) async {
    switch (mode) {
      case _HomeMode.shop:
        await _handleShopCartAdd(item, openCartAfterAdd: true);
        return;
      case _HomeMode.labour:
        if (item.backendLabourId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${item.title} is not connected to live labour booking yet.')),
          );
          return;
        }
        try {
          final result = await _UserAppApi.bookLabourDirect(
            item: item,
            bookingPeriod: labourBookingPeriod ?? 'Full Day',
          );
          if (!mounted) {
            return;
          }
          final paymentResult = await _PaymentFlow.start(
            context,
            paymentCode: result.paymentCode,
            title: 'Pay labour booking',
          );
          if (!mounted) {
            return;
          }
          await _PaymentFlow.showOutcome(
            context,
            result: paymentResult,
            successTitle: 'Labour booking confirmed',
            failureTitle: 'Labour payment incomplete',
            extraLines: [
              'Booking code: ${result.bookingCode}',
              'Labour: ${result.labourName}',
              'Amount: ${result.payableAmount}',
            ],
          );
        } on _UserAppApiException catch (error) {
          if (mounted) {
            _showCartSnack(error.message);
          }
        }
        return;
      case _HomeMode.service:
        if (item.backendServiceProviderId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${item.title} is not connected to live service booking yet.')),
          );
          return;
        }
        try {
          final result = await _UserAppApi.bookServiceDirect(item: item);
          if (!mounted) {
            return;
          }
          final paymentResult = await _PaymentFlow.start(
            context,
            paymentCode: result.paymentCode,
            title: 'Pay service booking',
          );
          if (!mounted) {
            return;
          }
          await _PaymentFlow.showOutcome(
            context,
            result: paymentResult,
            successTitle: 'Service booking confirmed',
            failureTitle: 'Service payment incomplete',
            extraLines: [
              'Booking code: ${result.bookingCode}',
              'Provider: ${result.providerName}',
              'Amount: ${result.payableAmount}',
            ],
          );
        } on _UserAppApiException catch (error) {
          if (mounted) {
            _showCartSnack(error.message);
          }
        }
        return;
      case _HomeMode.all:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Open ${item.title} from its mode to continue.')),
        );
        return;
    }
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
    final shopName = item.subtitle;
    final category = _shopCategoryForItem(item);
    if (item.backendProductId != null) {
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

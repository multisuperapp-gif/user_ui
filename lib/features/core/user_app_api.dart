part of '../../main.dart';

class _UserAppApi {
  static Uri get _baseUri {
    const configured = String.fromEnvironment('USER_API_BASE_URL', defaultValue: 'http://44.217.176.56:8085');
    final normalized = configured.endsWith('/') ? configured.substring(0, configured.length - 1) : configured;
    return Uri.parse('$normalized/api/v1');
  }

  static Uri get _authBaseUri {
    const configured = String.fromEnvironment('AUTH_BASE_URL', defaultValue: 'http://44.207.68.180:8081');
    final normalized = configured.endsWith('/') ? configured.substring(0, configured.length - 1) : configured;
    return Uri.parse(normalized);
  }

  static String profilePhotoViewUrl(String objectKey) {
    final trimmed = objectKey.trim();
    if (trimmed.isEmpty) {
      return '';
    }
    return _baseUri.replace(
      path: '/api/v1/profile/photo/view',
      queryParameters: <String, String>{'objectKey': trimmed},
    ).toString();
  }

  static Uri get _bookingPaymentBaseUri {
    const configured = String.fromEnvironment(
      'BOOKING_PAYMENT_BASE_URL',
      defaultValue: '',
    );
    final fallback = configured.isNotEmpty
        ? configured
        : _deriveSiblingServiceBaseUrl(
            String.fromEnvironment('USER_API_BASE_URL', defaultValue: ''),
            fallback: 'http://44.217.176.56:8084',
            port: 8084,
          );
    final normalized = fallback.endsWith('/') ? fallback.substring(0, fallback.length - 1) : fallback;
    return Uri.parse(normalized);
  }

  static String _deriveSiblingServiceBaseUrl(
    String configuredBaseUrl, {
    required String fallback,
    required int port,
  }) {
    if (configuredBaseUrl.trim().isEmpty) {
      return fallback;
    }
    final normalized = configuredBaseUrl.endsWith('/') ? configuredBaseUrl.substring(0, configuredBaseUrl.length - 1) : configuredBaseUrl;
    final uri = Uri.tryParse(normalized);
    if (uri == null || uri.host.trim().isEmpty) {
      return fallback;
    }
    return uri.replace(
      port: port,
      path: '',
      query: null,
      fragment: null,
    ).toString();
  }

  static String _publicFileUrl(String objectKey) {
    final trimmed = objectKey.trim();
    if (trimmed.isEmpty) {
      return '';
    }
    return _authBaseUri.replace(
      path: '/public/files/view',
      queryParameters: <String, String>{'objectKey': trimmed},
    ).toString();
  }

  static Future<_OtpDispatchResult> sendUserOtp(String phoneNumber) async {
    final response = await _postAbsolute(
      _authBaseUri.replace(path: '/user/auth/send-otp'),
      body: <String, dynamic>{
        'channel': 'SMS',
        'target': phoneNumber,
        'purpose': 'USER_APP_AUTH',
      },
    );
    final data = Map<String, dynamic>.from((response['data'] as Map?) ?? const {});
    final requestId = '${data['requestId'] ?? ''}';
    if (requestId.isEmpty) {
      throw const _UserAppApiException('OTP request id was not returned by auth service.');
    }
    return _OtpDispatchResult(
      requestId: requestId,
      expiresInSeconds: (data['expiresInSeconds'] as num?)?.toInt() ?? 0,
    );
  }

  static Future<_VerifiedUserSession> verifyUserOtp({
    required String phoneNumber,
    required String otp,
    required String requestId,
  }) async {
    final deviceToken = await _LocalSessionStore.ensureDeviceToken();
    final response = await _postAbsolute(
      _authBaseUri.replace(path: '/user/auth/verify-otp'),
      body: <String, dynamic>{
        'requestId': requestId,
        'target': phoneNumber,
        'otp': otp,
        'appContext': 'USER_APP',
        'deviceType': Platform.isIOS ? 'IOS' : 'ANDROID',
        'deviceToken': deviceToken,
      },
    );
    final data = Map<String, dynamic>.from((response['data'] as Map?) ?? const {});
    final user = Map<String, dynamic>.from((data['user'] as Map?) ?? const {});
    final userId = (user['id'] as num?)?.toInt() ?? 0;
    if (userId <= 0) {
      throw const _UserAppApiException('Auth service did not return a valid user session.');
    }
    return _VerifiedUserSession(
      accessToken: '${data['accessToken'] ?? ''}',
      refreshToken: '${data['refreshToken'] ?? ''}',
      userId: userId,
      publicUserId: '${user['publicUserId'] ?? ''}',
    );
  }

  static Future<List<_DiscoveryItem>> fetchHomeTopProducts() async {
    final response = await _get(
      '/public/home/bootstrap',
      queryParameters: const {
        'page': '0',
        'size': '8',
      },
    );
    final items = ((response['data'] as Map<String, dynamic>?)?['topProducts'] as Map<String, dynamic>?)?['items'];
    if (items is! List) {
      return const <_DiscoveryItem>[];
    }
    return items
        .whereType<Map<dynamic, dynamic>>()
        .map((raw) => _mapProductCard(Map<String, dynamic>.from(raw)))
        .toList(growable: false);
  }

  static Future<_RemoteCartState> fetchCart() async {
    final response = await _get('/cart', authenticated: true);
    final data = Map<String, dynamic>.from((response['data'] as Map?) ?? const {});
    return _mapCart(data);
  }

  static Future<_UserProfileData> fetchProfile() async {
    final response = await _get('/profile', authenticated: true);
    final data = Map<String, dynamic>.from((response['data'] as Map?) ?? const {});
    return _UserProfileData(
      userId: (data['userId'] as num?)?.toInt() ?? 0,
      publicUserId: '${data['publicUserId'] ?? ''}',
      phone: '${data['phone'] ?? ''}',
      fullName: '${data['fullName'] ?? 'MSA User'}',
      profilePhotoDataUri: '${data['profilePhotoDataUri'] ?? ''}',
      profilePhotoObjectKey: '${data['profilePhotoObjectKey'] ?? ''}',
      gender: '${data['gender'] ?? ''}',
      dob: _parseDate('${data['dob'] ?? ''}'),
      languageCode: '${data['languageCode'] ?? 'en'}',
    );
  }

  static Future<_UserProfileData> updateProfile({
    required String fullName,
    required String profilePhotoDataUri,
    String gender = '',
    DateTime? dob,
    String? languageCode,
  }) async {
    final body = <String, dynamic>{
      'fullName': fullName,
      'profilePhotoDataUri': profilePhotoDataUri,
      'gender': gender,
      'languageCode': languageCode,
    };
    if (dob != null) {
      body['dob'] =
          '${dob.year.toString().padLeft(4, '0')}-${dob.month.toString().padLeft(2, '0')}-${dob.day.toString().padLeft(2, '0')}';
    }
    final response = await _patch(
      '/profile',
      authenticated: true,
      body: body,
      timeout: const Duration(seconds: 20),
    );
    final data = Map<String, dynamic>.from((response['data'] as Map?) ?? const {});
    return _UserProfileData(
      userId: (data['userId'] as num?)?.toInt() ?? 0,
      publicUserId: '${data['publicUserId'] ?? ''}',
      phone: '${data['phone'] ?? ''}',
      fullName: '${data['fullName'] ?? 'MSA User'}',
      profilePhotoDataUri: '${data['profilePhotoDataUri'] ?? ''}',
      profilePhotoObjectKey: '${data['profilePhotoObjectKey'] ?? ''}',
      gender: '${data['gender'] ?? ''}',
      dob: _parseDate('${data['dob'] ?? ''}'),
      languageCode: '${data['languageCode'] ?? 'en'}',
    );
  }

  static Future<List<_UserAddressData>> fetchAddresses() async {
    final response = await _get('/profile/addresses', authenticated: true);
    final data = (response['data'] as List? ?? const []);
    return data
        .whereType<Map<dynamic, dynamic>>()
        .map((raw) => _mapUserAddress(Map<String, dynamic>.from(raw)))
        .toList(growable: false);
  }

  static Future<List<_ServiceCountryOption>> fetchServiceCountries() async {
    final response = await _getAbsolute(
      _authBaseUri.replace(path: '/locations/countries'),
    );
    final data = (response['data'] as List? ?? const []);
    return data
        .whereType<Map<dynamic, dynamic>>()
        .map(
          (raw) => _ServiceCountryOption(
            id: (raw['id'] as num?)?.toInt() ?? 0,
            name: '${raw['name'] ?? ''}'.trim(),
          ),
        )
        .where((entry) => entry.id > 0 && entry.name.isNotEmpty)
        .toList(growable: false);
  }

  static Future<List<_ServiceStateOption>> fetchServiceStates({required int countryId}) async {
    final response = await _getAbsolute(
      _authBaseUri.replace(
        path: '/locations/states',
        queryParameters: <String, String>{'countryId': '$countryId'},
      ),
    );
    final data = (response['data'] as List? ?? const []);
    return data
        .whereType<Map<dynamic, dynamic>>()
        .map(
          (raw) => _ServiceStateOption(
            id: (raw['id'] as num?)?.toInt() ?? 0,
            countryId: (raw['countryId'] as num?)?.toInt() ?? 0,
            name: '${raw['name'] ?? ''}'.trim(),
          ),
        )
        .where((entry) => entry.id > 0 && entry.countryId > 0 && entry.name.isNotEmpty)
        .toList(growable: false);
  }

  static Future<_UserAddressData> createAddress(_UserAddressInput input) async {
    final response = await _post(
      '/profile/addresses',
      authenticated: true,
      body: input.toJson(),
    );
    final data = Map<String, dynamic>.from((response['data'] as Map?) ?? const {});
    return _mapUserAddress(data);
  }

  static Future<_UserAddressData> createTemporaryBookingAddress(_UserAddressInput input) async {
    final response = await _post(
      '/profile/addresses/temporary-booking',
      authenticated: true,
      body: input.toJson(),
    );
    final data = Map<String, dynamic>.from((response['data'] as Map?) ?? const {});
    return _mapUserAddress(data);
  }

  static Future<_UserAddressData> updateAddress(int addressId, _UserAddressInput input) async {
    final response = await _put(
      '/profile/addresses/$addressId',
      authenticated: true,
      body: input.toJson(),
    );
    final data = Map<String, dynamic>.from((response['data'] as Map?) ?? const {});
    return _mapUserAddress(data);
  }

  static Future<void> deleteAddress(int addressId) async {
    await _delete('/profile/addresses/$addressId', authenticated: true);
  }

  static Future<_UserAddressData> setDefaultAddress(int addressId) async {
    final response = await _post(
      '/profile/addresses/$addressId/default',
      authenticated: true,
      body: const <String, dynamic>{},
    );
    final data = Map<String, dynamic>.from((response['data'] as Map?) ?? const {});
    return _mapUserAddress(data);
  }

  static Future<_RemoteNotificationList> fetchNotifications({
    int page = 0,
    int size = 20,
    bool unreadOnly = false,
  }) async {
    final response = await _get(
      '/profile/notifications',
      authenticated: true,
      queryParameters: {
        'page': '$page',
        'size': '$size',
        'unreadOnly': '$unreadOnly',
      },
    );
    final data = Map<String, dynamic>.from((response['data'] as Map?) ?? const {});
    final items = (data['items'] as List? ?? const [])
        .whereType<Map<dynamic, dynamic>>()
        .map((raw) => _mapNotification(Map<String, dynamic>.from(raw)))
        .toList(growable: false);
    return _RemoteNotificationList(
      items: items,
      unreadCount: (data['unreadCount'] as num?)?.toInt() ?? 0,
    );
  }

  static Future<List<_UserOrderSummary>> fetchMyOrders({
    int page = 0,
    int size = 20,
  }) async {
    final response = await _get(
      '/orders',
      authenticated: true,
      queryParameters: {
        'page': '$page',
        'size': '$size',
      },
    );
    final data = (response['data'] as List? ?? const []);
    return data
        .whereType<Map<dynamic, dynamic>>()
        .map((raw) => _mapOrderSummary(Map<String, dynamic>.from(raw)))
        .toList(growable: false);
  }

  static Future<_UserOrderDetail> fetchOrderDetail(int orderId) async {
    final response = await _get(
      '/orders/$orderId',
      authenticated: true,
    );
    final data = Map<String, dynamic>.from((response['data'] as Map?) ?? const {});
    return _mapOrderDetail(data);
  }

  static Future<void> cancelOrder(int orderId, {String? reason}) async {
    await _post(
      '/orders/$orderId/cancel',
      authenticated: true,
      body: <String, dynamic>{
        'reason': reason,
      },
    );
  }

  static Future<void> markNotificationRead(int notificationId) async {
    await _patch(
      '/profile/notifications/$notificationId/read',
      authenticated: true,
    );
  }

  static Future<void> markAllNotificationsRead() async {
    await _patch(
      '/profile/notifications/read-all',
      authenticated: true,
    );
  }

  static Future<void> registerPushToken({
    required String pushToken,
    required String deviceToken,
    required String platform,
    required String pushProvider,
    String? appVersion,
    String? osVersion,
  }) async {
    await _post(
      '/profile/push-tokens',
      authenticated: true,
      body: <String, dynamic>{
        'deviceToken': deviceToken,
        'appVersion': appVersion,
        'osVersion': osVersion,
        'platform': platform,
        'pushProvider': pushProvider,
        'pushToken': pushToken,
      },
    );
  }

  static Future<void> deactivatePushToken(String pushToken) async {
    await _patch(
      '/profile/push-tokens/deactivate',
      authenticated: true,
      body: <String, dynamic>{
        'pushToken': pushToken,
      },
    );
  }

  static Future<void> registerBookingPushToken({
    required String pushToken,
    required String deviceToken,
    required String platform,
    required String pushProvider,
  }) async {
    await _postAbsoluteAuthenticated(
      _bookingPaymentBaseUri.replace(path: '/booking-notifications/push-tokens'),
      body: <String, dynamic>{
        'deviceToken': deviceToken,
        'platform': platform,
        'pushProvider': pushProvider,
        'appContext': 'USER_APP',
        'pushToken': pushToken,
      },
    );
  }

  static Future<void> deactivateBookingPushToken(String pushToken) async {
    await _patchAbsoluteAuthenticated(
      _bookingPaymentBaseUri.replace(path: '/booking-notifications/push-tokens/deactivate'),
      body: <String, dynamic>{
        'pushToken': pushToken,
      },
    );
  }


  static Future<_CheckoutPreviewData> previewCheckout({
    String fulfillmentType = 'DELIVERY',
    int? addressId,
  }) async {
    final response = await _post(
      '/orders/checkout-preview',
      authenticated: true,
      body: <String, dynamic>{
        'addressId': addressId,
        'fulfillmentType': fulfillmentType,
      },
    );
    final data = Map<String, dynamic>.from((response['data'] as Map?) ?? const {});
    return _CheckoutPreviewData(
      addressId: (data['addressId'] as num?)?.toInt(),
      shopName: '${data['shopName'] ?? ''}',
      addressLabel: '${data['addressLabel'] ?? ''}',
      addressLine: '${data['addressLine'] ?? ''}',
      fulfillmentType: '${data['fulfillmentType'] ?? 'DELIVERY'}',
      itemCount: (data['itemCount'] as num?)?.toInt() ?? 0,
      subtotal: _money(data['subtotal']),
      deliveryFee: _money(data['deliveryFee']),
      platformFee: _money(data['platformFee']),
      totalAmount: _money(data['totalAmount']),
      shopOpen: (data['shopOpen'] as bool?) ?? false,
      closingSoon: (data['closingSoon'] as bool?) ?? false,
      acceptsOrders: (data['acceptsOrders'] as bool?) ?? false,
      canPlaceOrder: (data['canPlaceOrder'] as bool?) ?? false,
      issues: (data['issues'] as List? ?? const [])
          .map((entry) => '$entry')
          .where((entry) => entry.trim().isNotEmpty)
          .toList(growable: false),
    );
  }

  static Future<_PlacedOrderData> placeOrder({
    String fulfillmentType = 'DELIVERY',
    int? addressId,
  }) async {
    final response = await _post(
      '/orders/place',
      authenticated: true,
      body: <String, dynamic>{
        'addressId': addressId,
        'fulfillmentType': fulfillmentType,
      },
    );
    final data = Map<String, dynamic>.from((response['data'] as Map?) ?? const {});
    return _PlacedOrderData(
      orderId: (data['orderId'] as num?)?.toInt() ?? 0,
      orderCode: '${data['orderCode'] ?? ''}',
      paymentId: (data['paymentId'] as num?)?.toInt() ?? 0,
      paymentCode: '${data['paymentCode'] ?? ''}',
      totalAmount: _money(data['totalAmount']),
      currencyCode: '${data['currencyCode'] ?? 'INR'}',
      nextAction: '${data['nextAction'] ?? ''}',
    );
  }

  static Future<_PaymentInitiationData> initiatePayment(
    String paymentCode, {
    String gatewayName = 'RAZORPAY',
  }) async {
    final response = await _post(
      '/payments/$paymentCode/initiate',
      authenticated: true,
      body: <String, dynamic>{
        'gatewayName': gatewayName,
      },
    );
    final data = Map<String, dynamic>.from((response['data'] as Map?) ?? const {});
    return _PaymentInitiationData(
      paymentId: (data['paymentId'] as num?)?.toInt() ?? 0,
      paymentCode: '${data['paymentCode'] ?? paymentCode}',
      gatewayName: '${data['gatewayName'] ?? gatewayName}',
      gatewayOrderId: '${data['gatewayOrderId'] ?? ''}',
      gatewayKeyId: '${data['gatewayKeyId'] ?? ''}',
      amountValue: _amountValue(data['amount']),
      amountLabel: _money(data['amount']),
      currencyCode: '${data['currencyCode'] ?? 'INR'}',
      paymentStatus: '${data['paymentStatus'] ?? 'PENDING'}',
    );
  }

  static Future<_PaymentStatusData> fetchPaymentStatus(String paymentCode) async {
    final response = await _get(
      '/payments/$paymentCode',
      authenticated: true,
    );
    final data = Map<String, dynamic>.from((response['data'] as Map?) ?? const {});
    return _PaymentStatusData(
      paymentId: (data['paymentId'] as num?)?.toInt() ?? 0,
      paymentCode: '${data['paymentCode'] ?? paymentCode}',
      payableType: '${data['payableType'] ?? ''}',
      payableId: (data['payableId'] as num?)?.toInt() ?? 0,
      paymentStatus: '${data['paymentStatus'] ?? ''}',
      amountLabel: _money(data['amount']),
      currencyCode: '${data['currencyCode'] ?? 'INR'}',
      gatewayName: '${data['gatewayName'] ?? ''}',
      gatewayOrderId: '${data['gatewayOrderId'] ?? ''}',
    );
  }

  static Future<_PaymentStatusData> verifyPayment(
    String paymentCode, {
    required String gatewayOrderId,
    required String gatewayPaymentId,
    required String razorpaySignature,
  }) async {
    final response = await _post(
      '/payments/$paymentCode/verify',
      authenticated: true,
      body: <String, dynamic>{
        'gatewayOrderId': gatewayOrderId,
        'gatewayPaymentId': gatewayPaymentId,
        'razorpaySignature': razorpaySignature,
      },
    );
    final data = Map<String, dynamic>.from((response['data'] as Map?) ?? const {});
    return _PaymentStatusData(
      paymentId: (data['paymentId'] as num?)?.toInt() ?? 0,
      paymentCode: '${data['paymentCode'] ?? paymentCode}',
      payableType: '${data['payableType'] ?? ''}',
      payableId: (data['payableId'] as num?)?.toInt() ?? 0,
      paymentStatus: '${data['paymentStatus'] ?? ''}',
      amountLabel: _money(data['amount']),
      currencyCode: '${data['currencyCode'] ?? 'INR'}',
      gatewayName: '${data['gatewayName'] ?? ''}',
      gatewayOrderId: '${data['gatewayOrderId'] ?? ''}',
    );
  }

  static Future<_PaymentStatusData> failPayment(
    String paymentCode, {
    String? gatewayOrderId,
    String? failureCode,
    String? failureMessage,
  }) async {
    final response = await _post(
      '/payments/$paymentCode/failure',
      authenticated: true,
      body: <String, dynamic>{
        'gatewayOrderId': gatewayOrderId,
        'failureCode': failureCode,
        'failureMessage': failureMessage,
      },
    );
    final data = Map<String, dynamic>.from((response['data'] as Map?) ?? const {});
    return _PaymentStatusData(
      paymentId: (data['paymentId'] as num?)?.toInt() ?? 0,
      paymentCode: '${data['paymentCode'] ?? paymentCode}',
      payableType: '${data['payableType'] ?? ''}',
      payableId: (data['payableId'] as num?)?.toInt() ?? 0,
      paymentStatus: '${data['paymentStatus'] ?? ''}',
      amountLabel: _money(data['amount']),
      currencyCode: '${data['currencyCode'] ?? 'INR'}',
      gatewayName: '${data['gatewayName'] ?? ''}',
      gatewayOrderId: '${data['gatewayOrderId'] ?? ''}',
    );
  }

  static Future<_RemoteCartState> addItemToCart(_DiscoveryItem item, {int quantity = 1}) async {
    if (item.backendProductId == null) {
      throw _UserAppApiException('This item is not connected to the backend yet.');
    }
    final response = await _post(
      '/cart/items',
      authenticated: true,
      body: <String, dynamic>{
        'productId': item.backendProductId,
        'variantId': item.backendVariantId,
        'quantity': quantity,
        'optionIds': const <int>[],
        'cookingRequest': null,
      },
    );
    final data = Map<String, dynamic>.from((response['data'] as Map?) ?? const {});
    return _mapCart(data);
  }

  static Future<_RemoteLabourLandingData> fetchLabourLanding({
    int? categoryId,
    String? city,
    double? latitude,
    double? longitude,
  }) async {
    final response = await _get(
      '/public/labour/landing',
      authenticated: await _hasUsableSession(),
      queryParameters: {
        if (categoryId != null) 'categoryId': '$categoryId',
        if (city != null && city.trim().isNotEmpty) 'city': city.trim(),
        if (latitude != null) 'latitude': '$latitude',
        if (longitude != null) 'longitude': '$longitude',
        'page': '0',
        'size': '100',
      },
    );
    final data = Map<String, dynamic>.from((response['data'] as Map?) ?? const {});
    final categories = (data['categories'] as List? ?? const [])
        .whereType<Map<dynamic, dynamic>>()
        .map((raw) => _mapLabourCategory(Map<String, dynamic>.from(raw)))
        .toList(growable: false);
    final profiles = (((data['profiles'] as Map?)?['items']) as List? ?? const [])
        .whereType<Map<dynamic, dynamic>>()
        .map((raw) => _mapLabourProfile(Map<String, dynamic>.from(raw)))
        .toList(growable: false);
    return _RemoteLabourLandingData(
      categories: [
        const _RemoteLabourCategory(label: 'All labour', backendCategoryId: null),
        ...categories,
      ],
      profiles: profiles,
    );
  }

  static Future<_DiscoveryItem> fetchLabourProfile(int labourId) async {
    final response = await _get(
      '/public/labour/profiles/$labourId',
      authenticated: await _hasUsableSession(),
    );
    final data = Map<String, dynamic>.from((response['data'] as Map?) ?? const {});
    final rawProfile = Map<String, dynamic>.from((data['profile'] as Map?) ?? const {});
    final item = _mapLabourProfile(rawProfile);
    final skills = (data['skills'] as List? ?? const [])
        .map((entry) => entry?.toString().trim() ?? '')
        .where((entry) => entry.isNotEmpty)
        .toList(growable: false);
    if (skills.isEmpty) {
      return item;
    }
    return item.copyWith(
      extra: skills.join(', '),
    );
  }

  static Future<_RemoteLabourBookingPolicy> fetchLabourBookingPolicy() async {
    final response = await _get(
      '/public/labour/booking-policy',
      authenticated: false,
    );
    final data = Map<String, dynamic>.from((response['data'] as Map?) ?? const {});
    final bookingCharge = _percent(data['bookingChargePercent']);
    return _RemoteLabourBookingPolicy(
      bookingChargePerLabour: bookingCharge.isEmpty ? '5%' : bookingCharge,
      currencyCode: '${data['currencyCode'] ?? 'INR'}',
      maxGroupLabourCount: (data['maxGroupLabourCount'] as num?)?.toInt() ?? 7,
    );
  }

  static Future<_RemoteLabourBookingResult> bookLabourDirect({
    required _DiscoveryItem item,
    required String bookingPeriod,
    int? addressId,
  }) async {
    if (item.backendLabourId == null) {
      throw const _UserAppApiException('This labour profile is not connected to the backend yet.');
    }
    final body = <String, dynamic>{
      'labourId': item.backendLabourId,
      'categoryId': item.backendCategoryId,
      'bookingPeriod': bookingPeriod,
    };
    if (addressId != null) {
      body['addressId'] = addressId;
    }
    final response = await _post(
      '/labour/bookings/direct',
      authenticated: true,
      body: body,
    );
    final data = Map<String, dynamic>.from((response['data'] as Map?) ?? const {});
    return _RemoteLabourBookingResult(
      requestId: (data['requestId'] as num?)?.toInt() ?? 0,
      requestCode: '${data['requestCode'] ?? ''}',
      requestStatus: '${data['requestStatus'] ?? 'OPEN'}',
      quotedPriceAmount: _money(data['quotedPriceAmount']),
      labourName: '${data['labourName'] ?? item.title}',
    );
  }

  static Future<_RemoteLabourBookingRequestStatus> fetchLabourBookingRequestStatus(
    int requestId,
  ) async {
    final response = await _get(
      '/labour/booking-requests/$requestId',
      authenticated: true,
    );
    final data = Map<String, dynamic>.from((response['data'] as Map?) ?? const {});
    return _RemoteLabourBookingRequestStatus(
      requestId: (data['requestId'] as num?)?.toInt() ?? requestId,
      requestCode: '${data['requestCode'] ?? ''}',
      requestStatus: '${data['requestStatus'] ?? 'OPEN'}',
      providerName: '${data['providerName'] ?? ''}',
      providerPhone: '${data['providerPhone'] ?? ''}',
      quotedPriceAmount: _money(data['quotedPriceAmount']),
      totalAcceptedQuotedPriceAmount: _money(data['totalAcceptedQuotedPriceAmount']),
      totalAcceptedBookingChargeAmount: _money(data['totalAcceptedBookingChargeAmount']),
      distanceLabel: _distance(data['distanceKm']),
      requestedProviderCount: (data['requestedProviderCount'] as num?)?.toInt() ?? 1,
      acceptedProviderCount: (data['acceptedProviderCount'] as num?)?.toInt() ?? 0,
      pendingProviderCount: (data['pendingProviderCount'] as num?)?.toInt() ?? 0,
      bookingId: (data['bookingId'] as num?)?.toInt() ?? 0,
      bookingCode: '${data['bookingCode'] ?? ''}',
      bookingStatus: '${data['bookingStatus'] ?? ''}',
      paymentStatus: '${data['paymentStatus'] ?? ''}',
      canMakePayment: (data['canMakePayment'] as bool?) ?? false,
    );
  }

  static Future<_RemoteLabourBookingPaymentResult> initiateLabourBookingPayment(
    int requestId,
  ) async {
    final response = await _post(
      '/labour/booking-requests/$requestId/payment/initiate',
      authenticated: true,
      body: const <String, dynamic>{},
    );
    final data = Map<String, dynamic>.from((response['data'] as Map?) ?? const {});
    return _RemoteLabourBookingPaymentResult(
      bookingId: (data['bookingId'] as num?)?.toInt() ?? 0,
      bookingCode: '${data['bookingCode'] ?? ''}',
      paymentCode: '${data['paymentCode'] ?? ''}',
      amountLabel: _money(data['amount']),
      currencyCode: '${data['currencyCode'] ?? 'INR'}',
    );
  }

  static Future<void> cancelLabourBookingRequest(
    int requestId, {
    required String reason,
  }) async {
    await _post(
      '/labour/booking-requests/$requestId/cancel',
      authenticated: true,
      body: <String, dynamic>{'reason': reason},
    );
  }

  static Future<_RemoteLabourGroupBookingResult> requestGroupLabourBooking({
    required int categoryId,
    required String bookingPeriod,
    required String maxPrice,
    required int labourCount,
    int? addressId,
  }) async {
    final response = await _post(
      '/labour/bookings/group-request',
      authenticated: true,
      body: <String, dynamic>{
        'categoryId': categoryId,
        'addressId': addressId,
        'bookingPeriod': bookingPeriod,
        'maxPrice': _extractAmount(maxPrice),
        'labourCount': labourCount,
      },
    );
    final data = Map<String, dynamic>.from((response['data'] as Map?) ?? const {});
    return _RemoteLabourGroupBookingResult(
      requestId: (data['requestId'] as num?)?.toInt() ?? 0,
      requestCode: '${data['requestCode'] ?? ''}',
      availableCandidates: (data['availableCandidates'] as num?)?.toInt() ?? 0,
      requestedCount: (data['requestedCount'] as num?)?.toInt() ?? labourCount,
      bookingChargePerLabour: _percent(data['bookingChargePercent']),
      estimatedLabourAmount: _money(data['estimatedLabourAmount']),
      platformAmountDue: _money(data['platformAmountDue']),
    );
  }

  static Future<_RemoteServiceLandingData> fetchServiceLanding({
    int? categoryId,
    int? subcategoryId,
    String? city,
    double? latitude,
    double? longitude,
  }) async {
    final response = await _get(
      '/public/service/landing',
      queryParameters: {
        if (categoryId != null) 'categoryId': '$categoryId',
        if (subcategoryId != null) 'subcategoryId': '$subcategoryId',
        if (city != null && city.trim().isNotEmpty) 'city': city.trim(),
        if (latitude != null) 'latitude': '$latitude',
        if (longitude != null) 'longitude': '$longitude',
        'page': '0',
        'size': '20',
      },
    );
    final data = Map<String, dynamic>.from((response['data'] as Map?) ?? const {});
    final categories = (data['categories'] as List? ?? const [])
        .whereType<Map<dynamic, dynamic>>()
        .map((raw) => _mapServiceCategory(Map<String, dynamic>.from(raw)))
        .toList(growable: false);
    final providers = (((data['providers'] as Map?)?['items']) as List? ?? const [])
        .whereType<Map<dynamic, dynamic>>()
        .map((raw) => _mapServiceProvider(Map<String, dynamic>.from(raw)))
        .toList(growable: false);
    return _RemoteServiceLandingData(
      categories: categories,
      providers: providers,
    );
  }

  static Future<_RemoteServiceProviderProfile> fetchServiceProviderProfile(
    int providerId, {
    int? categoryId,
    int? subcategoryId,
  }) async {
    final response = await _get(
      '/public/service/providers/$providerId',
      queryParameters: {
        if (categoryId != null) 'categoryId': '$categoryId',
        if (subcategoryId != null) 'subcategoryId': '$subcategoryId',
      },
    );
    final data = Map<String, dynamic>.from((response['data'] as Map?) ?? const {});
    final providerRaw = Map<String, dynamic>.from((data['provider'] as Map?) ?? const {});
    final serviceItems = (data['serviceItems'] as List? ?? const [])
        .map((entry) => '$entry'.trim())
        .where((entry) => entry.isNotEmpty)
        .toList(growable: false);
    return _RemoteServiceProviderProfile(
      provider: _mapServiceProvider(providerRaw).copyWith(
        serviceItems: serviceItems,
        serviceTileLabel: serviceItems.firstOrNull ?? '',
      ),
      serviceItems: serviceItems,
    );
  }

  static Future<_RemoteServiceBookingResult> bookServiceDirect({
    required _DiscoveryItem item,
    int? addressId,
  }) async {
    if (item.backendServiceProviderId == null) {
      throw const _UserAppApiException('This service provider is not connected to the backend yet.');
    }
    final body = <String, dynamic>{
      'providerId': item.backendServiceProviderId,
      'categoryId': item.backendCategoryId,
      'subcategoryId': item.backendSubcategoryId,
    };
    if (addressId != null) {
      body['addressId'] = addressId;
    }
    final response = await _post(
      '/service/bookings/direct',
      authenticated: true,
      body: body,
    );
    final data = Map<String, dynamic>.from((response['data'] as Map?) ?? const {});
    return _RemoteServiceBookingResult(
      requestId: (data['requestId'] as num?)?.toInt() ?? 0,
      requestCode: '${data['requestCode'] ?? ''}',
      requestStatus: '${data['requestStatus'] ?? 'OPEN'}',
      quotedPriceAmount: _money(data['quotedPriceAmount']),
      providerName: '${data['providerName'] ?? item.title}',
      serviceName: '${data['serviceName'] ?? item.subtitle}',
    );
  }

  static Future<_RemoteServiceBookingRequestStatus> fetchServiceBookingRequestStatus(
    int requestId,
  ) async {
    final response = await _get(
      '/service/booking-requests/$requestId',
      authenticated: true,
    );
    final data = Map<String, dynamic>.from((response['data'] as Map?) ?? const {});
    return _RemoteServiceBookingRequestStatus(
      requestId: (data['requestId'] as num?)?.toInt() ?? requestId,
      requestCode: '${data['requestCode'] ?? ''}',
      requestStatus: '${data['requestStatus'] ?? 'OPEN'}',
      providerName: '${data['providerName'] ?? ''}',
      providerPhone: '${data['providerPhone'] ?? ''}',
      quotedPriceAmount: _money(data['quotedPriceAmount']),
      distanceLabel: _distance(data['distanceKm']),
      bookingId: (data['bookingId'] as num?)?.toInt() ?? 0,
      bookingCode: '${data['bookingCode'] ?? ''}',
      bookingStatus: '${data['bookingStatus'] ?? ''}',
      paymentStatus: '${data['paymentStatus'] ?? ''}',
      canMakePayment: (data['canMakePayment'] as bool?) ?? false,
    );
  }

  static Future<_RemoteServiceBookingPaymentResult> initiateServiceBookingPayment(
    int requestId,
  ) async {
    final response = await _post(
      '/service/booking-requests/$requestId/payment/initiate',
      authenticated: true,
      body: const <String, dynamic>{},
    );
    final data = Map<String, dynamic>.from((response['data'] as Map?) ?? const {});
    return _RemoteServiceBookingPaymentResult(
      bookingId: (data['bookingId'] as num?)?.toInt() ?? 0,
      bookingCode: '${data['bookingCode'] ?? ''}',
      paymentCode: '${data['paymentCode'] ?? ''}',
      amountLabel: _money(data['amount']),
      currencyCode: '${data['currencyCode'] ?? 'INR'}',
    );
  }

  static Future<List<_ActiveBookingStatus>> fetchActiveBookingStatuses() async {
    final response = await _getAbsolute(
      _bookingPaymentBaseUri.replace(path: '/booking-requests/active'),
      authenticated: true,
    );
    final raw = response['data'];
    if (raw is! List) {
      return const <_ActiveBookingStatus>[];
    }
    return raw
        .whereType<Map<dynamic, dynamic>>()
        .map((entry) => _mapActiveBookingStatus(Map<String, dynamic>.from(entry)))
        .whereType<_ActiveBookingStatus>()
        .toList(growable: false);
  }

  static Future<List<_ActiveBookingStatus>> fetchBookingHistoryStatuses() async {
    final response = await _getAbsolute(
      _bookingPaymentBaseUri.replace(path: '/booking-requests/history'),
      authenticated: true,
    );
    final raw = response['data'];
    if (raw is! List) {
      return const <_ActiveBookingStatus>[];
    }
    return raw
        .whereType<Map<dynamic, dynamic>>()
        .map((entry) => _mapActiveBookingStatus(Map<String, dynamic>.from(entry)))
        .whereType<_ActiveBookingStatus>()
        .toList(growable: false);
  }

  static _ActiveBookingStatus? _mapActiveBookingStatus(Map<String, dynamic> data) {
    final requestIdValue = (data['requestId'] as num?)?.toInt() ?? 0;
    if (requestIdValue <= 0) {
      return null;
    }
    final bookingStatus = '${data['bookingStatus'] ?? ''}';
    final paymentStatus = '${data['paymentStatus'] ?? ''}';
    return _ActiveBookingStatus(
      requestId: requestIdValue,
      requestCode: '${data['requestCode'] ?? ''}',
      bookingType: '${data['bookingType'] ?? ''}',
      requestStatus: '${data['requestStatus'] ?? 'OPEN'}',
      historyStatus: '${data['historyStatus'] ?? ''}',
      providerName: '${data['providerName'] ?? ''}',
      providerPhone: '${data['providerPhone'] ?? ''}',
      quotedPriceAmount: _money(data['quotedPriceAmount']),
      totalAcceptedQuotedPriceAmount: _money(data['totalAcceptedQuotedPriceAmount']),
      totalAcceptedBookingChargeAmount: _money(data['totalAcceptedBookingChargeAmount']),
      distanceLabel: _distance(data['distanceKm']),
      providerPhotoUrl: _publicFileUrl('${data['providerPhotoObjectKey'] ?? ''}'),
      providerLatitude: _parseDouble(data['providerLatitude']),
      providerLongitude: _parseDouble(data['providerLongitude']),
      destinationLatitude: _parseDouble(data['destinationLatitude']),
      destinationLongitude: _parseDouble(data['destinationLongitude']),
      paymentDueAt: _parseDateTime(data['paymentDueAt']),
      reachByAt: _parseDateTime(data['reachByAt']),
      labourPricingModel: '${data['labourPricingModel'] ?? ''}',
      bookingId: (data['bookingId'] as num?)?.toInt() ?? 0,
      bookingCode: '${data['bookingCode'] ?? ''}',
      bookingStatus: bookingStatus,
      paymentStatus: paymentStatus,
      createdAt: _parseDateTime(data['createdAt']),
      canMakePayment: bookingStatus.toUpperCase() == 'PAYMENT_PENDING' &&
          (paymentStatus.isEmpty || paymentStatus.toUpperCase() == 'UNPAID'),
      reviewSubmitted: data['reviewSubmitted'] == true,
    );
  }

  static Future<void> verifyBookingOtp({
    required int bookingId,
    required String purpose,
    required String otpCode,
  }) async {
    await _postAbsoluteAuthenticated(
      _bookingPaymentBaseUri.replace(path: '/bookings/otp/verify'),
      body: {
        'bookingId': bookingId,
        'purpose': purpose,
        'otpCode': otpCode,
      },
    );
  }

  static Future<String> generateBookingOtp({
    required int bookingId,
    required String purpose,
  }) async {
    final response = await _postAbsoluteAuthenticated(
      _bookingPaymentBaseUri.replace(path: '/bookings/otp/generate'),
      body: {
        'bookingId': bookingId,
        'purpose': purpose,
      },
    );
    final data = Map<String, dynamic>.from((response['data'] as Map?) ?? const {});
    return '${data['otpCode'] ?? ''}';
  }

  static Future<void> cancelBookingByUser({
    required int bookingId,
    required String reason,
  }) async {
    await _postAbsoluteAuthenticated(
      _bookingPaymentBaseUri.replace(path: '/bookings/cancel/user'),
      body: {
        'bookingId': bookingId,
        'reason': reason,
      },
    );
  }

  static Future<void> submitBookingReview({
    required int bookingId,
    required int rating,
    required String comment,
  }) async {
    await _postAbsoluteAuthenticated(
      _bookingPaymentBaseUri.replace(path: '/bookings/review'),
      body: {
        'bookingId': bookingId,
        'rating': rating,
        'comment': comment.trim(),
      },
    );
  }

  static Future<_RestaurantLandingData> fetchRestaurantLanding({
    double? latitude,
    double? longitude,
  }) async {
    final response = await _get(
      '/public/restaurant/landing',
      queryParameters: {
        if (latitude != null) 'latitude': '$latitude',
        if (longitude != null) 'longitude': '$longitude',
        'page': '0',
        'size': '20',
      },
    );
    final data = Map<String, dynamic>.from((response['data'] as Map?) ?? const {});
    final categories = (data['categories'] as List? ?? const [])
        .whereType<Map<dynamic, dynamic>>()
        .map((raw) => _mapRestaurantCuisine(Map<String, dynamic>.from(raw)))
        .toList(growable: false);
    final products = (((data['products'] as Map?)?['items']) as List? ?? const [])
        .whereType<Map<dynamic, dynamic>>()
        .map((raw) => _mapProductCard(Map<String, dynamic>.from(raw)))
        .toList(growable: false);
    final shops = (((data['shops'] as Map?)?['items']) as List? ?? const [])
        .whereType<Map<dynamic, dynamic>>()
        .map((raw) => _mapRestaurantShop(Map<String, dynamic>.from(raw)))
        .toList(growable: false);
    return _RestaurantLandingData(
      cuisines: [
        const _RestaurantCuisineItem(
          label: 'All',
          imageKey: 'all',
          accent: Color(0xFFF6D7A8),
          icon: Icons.restaurant_menu_rounded,
          backendCategoryId: null,
        ),
        ...categories,
      ],
      products: products,
      shops: shops,
    );
  }

  static Future<List<_DiscoveryItem>> fetchRestaurantProducts({int? categoryId}) async {
    final response = await _get(
      '/public/restaurant/products',
      queryParameters: {
        if (categoryId != null) 'categoryId': '$categoryId',
        'page': '0',
        'size': '20',
      },
    );
    final items = (((response['data'] as Map?)?['items']) as List? ?? const []);
    return items
        .whereType<Map<dynamic, dynamic>>()
        .map((raw) => _mapProductCard(Map<String, dynamic>.from(raw)))
        .toList(growable: false);
  }

  static Future<_RestaurantShopProfileData> fetchRestaurantShopProfile(
    int shopId, {
    int? categoryId,
  }) async {
    final response = await _get(
      '/public/restaurant/shops/$shopId',
      queryParameters: {
        if (categoryId != null) 'categoryId': '$categoryId',
        'page': '0',
        'size': '20',
      },
    );
    final data = Map<String, dynamic>.from((response['data'] as Map?) ?? const {});
    final shop = Map<String, dynamic>.from((data['shop'] as Map?) ?? const {});
    final categories = (data['categories'] as List? ?? const [])
        .whereType<Map<dynamic, dynamic>>()
        .map((raw) => _mapRestaurantCuisine(Map<String, dynamic>.from(raw)))
        .toList(growable: false);
    final products = (((data['products'] as Map?)?['items']) as List? ?? const [])
        .whereType<Map<dynamic, dynamic>>()
        .map((raw) => _mapProductCard(Map<String, dynamic>.from(raw)))
        .toList(growable: false);
    return _RestaurantShopProfileData(
      shopId: (shop['shopId'] as num?)?.toInt() ?? shopId,
      shopName: '${shop['shopName'] ?? 'Restaurant'}',
      city: '${shop['city'] ?? ''}',
      rating: _rating(shop['avgRating']),
      closesAt: '${shop['closesAt'] ?? ''}',
      openNow: (shop['openNow'] as bool?) ?? false,
      acceptsOrders: (shop['acceptsOrders'] as bool?) ?? false,
      cuisines: [
        const _RestaurantCuisineItem(
          label: 'All',
          imageKey: 'all',
          accent: Color(0xFFF6D7A8),
          icon: Icons.restaurant_menu_rounded,
          backendCategoryId: null,
        ),
        ...categories,
      ],
      products: products,
    );
  }

  static Future<_FashionLandingData> fetchFashionLanding({
    double? latitude,
    double? longitude,
  }) async {
    final response = await _get(
      '/public/fashion/landing',
      queryParameters: {
        if (latitude != null) 'latitude': '$latitude',
        if (longitude != null) 'longitude': '$longitude',
        'page': '0',
        'size': '20',
      },
    );
    final data = Map<String, dynamic>.from((response['data'] as Map?) ?? const {});
    final categories = (data['categories'] as List? ?? const [])
        .whereType<Map<dynamic, dynamic>>()
        .map((raw) => _mapFashionCategory(Map<String, dynamic>.from(raw)))
        .toList(growable: false);
    final products = _mapFashionProductPage(
      Map<String, dynamic>.from((data['products'] as Map?) ?? const {}),
    );
    final shops = (((data['shops'] as Map?)?['items']) as List? ?? const [])
        .whereType<Map<dynamic, dynamic>>()
        .map((raw) => _mapFashionShop(Map<String, dynamic>.from(raw)))
        .toList(growable: false);
    return _FashionLandingData(
      categories: [
        const _FashionRemoteCategory(label: 'All'),
        ...categories,
      ],
      products: products,
      shops: shops,
    );
  }

  static Future<_FashionProductPage> fetchFashionProducts({
    int? categoryId,
    int page = 0,
    int size = 20,
  }) async {
    final response = await _get(
      '/public/fashion/products',
      queryParameters: {
        if (categoryId != null) 'categoryId': '$categoryId',
        'page': '$page',
        'size': '$size',
      },
    );
    return _mapFashionProductPage(
      Map<String, dynamic>.from((response['data'] as Map?) ?? const {}),
    );
  }

  static Future<_FashionShopProfileData> fetchFashionShopProfile(
    int shopId, {
    int? categoryId,
    int page = 0,
    int size = 20,
  }) async {
    final response = await _get(
      '/public/fashion/shops/$shopId',
      queryParameters: {
        if (categoryId != null) 'categoryId': '$categoryId',
        'page': '$page',
        'size': '$size',
      },
    );
    final data = Map<String, dynamic>.from((response['data'] as Map?) ?? const {});
    final shop = Map<String, dynamic>.from((data['shop'] as Map?) ?? const {});
    final categories = (data['categories'] as List? ?? const [])
        .whereType<Map<dynamic, dynamic>>()
        .map((raw) => _mapFashionCategory(Map<String, dynamic>.from(raw)))
        .toList(growable: false);
    final products = _mapFashionProductPage(
      Map<String, dynamic>.from((data['products'] as Map?) ?? const {}),
    );
    return _FashionShopProfileData(
      shopId: (shop['shopId'] as num?)?.toInt() ?? shopId,
      shopName: '${shop['shopName'] ?? 'Fashion shop'}',
      city: '${shop['city'] ?? ''}',
      rating: _rating(shop['avgRating']),
      closesAt: '${shop['closesAt'] ?? ''}',
      openNow: (shop['openNow'] as bool?) ?? false,
      acceptsOrders: (shop['acceptsOrders'] as bool?) ?? false,
      categories: [
        const _FashionRemoteCategory(label: 'All'),
        ...categories,
      ],
      products: products,
    );
  }

  static Future<_FootwearLandingData> fetchFootwearLanding({
    double? latitude,
    double? longitude,
  }) async {
    final response = await _get(
      '/public/footwear/landing',
      queryParameters: {
        if (latitude != null) 'latitude': '$latitude',
        if (longitude != null) 'longitude': '$longitude',
        'page': '0',
        'size': '20',
      },
    );
    final data = Map<String, dynamic>.from((response['data'] as Map?) ?? const {});
    final categories = (data['categories'] as List? ?? const [])
        .whereType<Map<dynamic, dynamic>>()
        .map((raw) => _mapFootwearCategory(Map<String, dynamic>.from(raw)))
        .toList(growable: false);
    final products = _mapFootwearProductPage(
      Map<String, dynamic>.from((data['products'] as Map?) ?? const {}),
    );
    final shops = (((data['shops'] as Map?)?['items']) as List? ?? const [])
        .whereType<Map<dynamic, dynamic>>()
        .map((raw) => _mapFootwearShop(Map<String, dynamic>.from(raw)))
        .toList(growable: false);
    return _FootwearLandingData(
      categories: [
        const _FootwearRemoteCategory(label: 'All'),
        ...categories,
      ],
      products: products,
      shops: shops,
    );
  }

  static Future<_FootwearProductPage> fetchFootwearProducts({
    int? categoryId,
    int page = 0,
    int size = 20,
  }) async {
    final response = await _get(
      '/public/footwear/products',
      queryParameters: {
        if (categoryId != null) 'categoryId': '$categoryId',
        'page': '$page',
        'size': '$size',
      },
    );
    return _mapFootwearProductPage(
      Map<String, dynamic>.from((response['data'] as Map?) ?? const {}),
    );
  }

  static Future<_FootwearShopProfileData> fetchFootwearShopProfile(
    int shopId, {
    int? categoryId,
    int page = 0,
    int size = 20,
  }) async {
    final response = await _get(
      '/public/footwear/shops/$shopId',
      queryParameters: {
        if (categoryId != null) 'categoryId': '$categoryId',
        'page': '$page',
        'size': '$size',
      },
    );
    final data = Map<String, dynamic>.from((response['data'] as Map?) ?? const {});
    final shop = Map<String, dynamic>.from((data['shop'] as Map?) ?? const {});
    final categories = (data['categories'] as List? ?? const [])
        .whereType<Map<dynamic, dynamic>>()
        .map((raw) => _mapFootwearCategory(Map<String, dynamic>.from(raw)))
        .toList(growable: false);
    final products = _mapFootwearProductPage(
      Map<String, dynamic>.from((data['products'] as Map?) ?? const {}),
    );
    return _FootwearShopProfileData(
      shopId: (shop['shopId'] as num?)?.toInt() ?? shopId,
      shopName: '${shop['shopName'] ?? 'Footwear shop'}',
      city: '${shop['city'] ?? ''}',
      rating: _rating(shop['avgRating']),
      closesAt: '${shop['closesAt'] ?? ''}',
      openNow: (shop['openNow'] as bool?) ?? false,
      acceptsOrders: (shop['acceptsOrders'] as bool?) ?? false,
      categories: [
        const _FootwearRemoteCategory(label: 'All'),
        ...categories,
      ],
      products: products,
    );
  }

  static Future<_GiftLandingData> fetchGiftLanding({
    double? latitude,
    double? longitude,
  }) async {
    final response = await _get(
      '/public/gift/landing',
      queryParameters: {
        if (latitude != null) 'latitude': '$latitude',
        if (longitude != null) 'longitude': '$longitude',
        'page': '0',
        'size': '20',
      },
    );
    final data = Map<String, dynamic>.from((response['data'] as Map?) ?? const {});
    final categories = (data['categories'] as List? ?? const [])
        .whereType<Map<dynamic, dynamic>>()
        .map((raw) => _mapGiftCategory(Map<String, dynamic>.from(raw)))
        .toList(growable: false);
    final products = _mapGiftProductPage(
      Map<String, dynamic>.from((data['products'] as Map?) ?? const {}),
    );
    final shops = (((data['shops'] as Map?)?['items']) as List? ?? const [])
        .whereType<Map<dynamic, dynamic>>()
        .map((raw) => _mapGiftShop(Map<String, dynamic>.from(raw)))
        .toList(growable: false);
    return _GiftLandingData(
      categories: [
        const _GiftRemoteCategory(label: 'All'),
        ...categories,
      ],
      products: products,
      shops: shops,
    );
  }

  static Future<_GiftProductPage> fetchGiftProducts({
    int? categoryId,
    int page = 0,
    int size = 20,
  }) async {
    final response = await _get(
      '/public/gift/products',
      queryParameters: {
        if (categoryId != null) 'categoryId': '$categoryId',
        'page': '$page',
        'size': '$size',
      },
    );
    return _mapGiftProductPage(
      Map<String, dynamic>.from((response['data'] as Map?) ?? const {}),
    );
  }

  static Future<_GiftShopProfileData> fetchGiftShopProfile(
    int shopId, {
    int? categoryId,
    int page = 0,
    int size = 20,
  }) async {
    final response = await _get(
      '/public/gift/shops/$shopId',
      queryParameters: {
        if (categoryId != null) 'categoryId': '$categoryId',
        'page': '$page',
        'size': '$size',
      },
    );
    final data = Map<String, dynamic>.from((response['data'] as Map?) ?? const {});
    final shop = Map<String, dynamic>.from((data['shop'] as Map?) ?? const {});
    final categories = (data['categories'] as List? ?? const [])
        .whereType<Map<dynamic, dynamic>>()
        .map((raw) => _mapGiftCategory(Map<String, dynamic>.from(raw)))
        .toList(growable: false);
    final products = _mapGiftProductPage(
      Map<String, dynamic>.from((data['products'] as Map?) ?? const {}),
    );
    return _GiftShopProfileData(
      shopId: (shop['shopId'] as num?)?.toInt() ?? shopId,
      shopName: '${shop['shopName'] ?? 'Gift store'}',
      city: '${shop['city'] ?? ''}',
      rating: _rating(shop['avgRating']),
      closesAt: '${shop['closesAt'] ?? ''}',
      openNow: (shop['openNow'] as bool?) ?? false,
      acceptsOrders: (shop['acceptsOrders'] as bool?) ?? false,
      categories: [
        const _GiftRemoteCategory(label: 'All'),
        ...categories,
      ],
      products: products,
    );
  }

  static Future<_GroceryLandingData> fetchGroceryLanding({
    double? latitude,
    double? longitude,
  }) async {
    final response = await _get(
      '/public/grocery/landing',
      queryParameters: {
        if (latitude != null) 'latitude': '$latitude',
        if (longitude != null) 'longitude': '$longitude',
        'page': '0',
        'size': '20',
      },
    );
    final data = Map<String, dynamic>.from((response['data'] as Map?) ?? const {});
    final categories = (data['categories'] as List? ?? const [])
        .whereType<Map<dynamic, dynamic>>()
        .map((raw) => _mapGroceryCategory(Map<String, dynamic>.from(raw)))
        .toList(growable: false);
    final products = _mapGroceryProductPage(
      Map<String, dynamic>.from((data['products'] as Map?) ?? const {}),
    );
    final shops = (((data['shops'] as Map?)?['items']) as List? ?? const [])
        .whereType<Map<dynamic, dynamic>>()
        .map((raw) => _mapGroceryShop(Map<String, dynamic>.from(raw)))
        .toList(growable: false);
    return _GroceryLandingData(
      categories: [
        const _GroceryRemoteCategory(label: 'All'),
        ...categories,
      ],
      products: products,
      shops: shops,
    );
  }

  static Future<_GroceryProductPage> fetchGroceryProducts({
    int? categoryId,
    int page = 0,
    int size = 20,
  }) async {
    final response = await _get(
      '/public/grocery/products',
      queryParameters: {
        if (categoryId != null) 'categoryId': '$categoryId',
        'page': '$page',
        'size': '$size',
      },
    );
    return _mapGroceryProductPage(
      Map<String, dynamic>.from((response['data'] as Map?) ?? const {}),
    );
  }

  static Future<_GroceryShopProfileData> fetchGroceryShopProfile(
    int shopId, {
    int? categoryId,
    int page = 0,
    int size = 20,
  }) async {
    final response = await _get(
      '/public/grocery/shops/$shopId',
      queryParameters: {
        if (categoryId != null) 'categoryId': '$categoryId',
        'page': '$page',
        'size': '$size',
      },
    );
    final data = Map<String, dynamic>.from((response['data'] as Map?) ?? const {});
    final shop = Map<String, dynamic>.from((data['shop'] as Map?) ?? const {});
    final categories = (data['categories'] as List? ?? const [])
        .whereType<Map<dynamic, dynamic>>()
        .map((raw) => _mapGroceryCategory(Map<String, dynamic>.from(raw)))
        .toList(growable: false);
    final products = _mapGroceryProductPage(
      Map<String, dynamic>.from((data['products'] as Map?) ?? const {}),
    );
    return _GroceryShopProfileData(
      shopId: (shop['shopId'] as num?)?.toInt() ?? shopId,
      shopName: '${shop['shopName'] ?? 'Grocery shop'}',
      city: '${shop['city'] ?? ''}',
      rating: _rating(shop['avgRating']),
      closesAt: '${shop['closesAt'] ?? ''}',
      openNow: (shop['openNow'] as bool?) ?? false,
      acceptsOrders: (shop['acceptsOrders'] as bool?) ?? false,
      categories: [
        const _GroceryRemoteCategory(label: 'All'),
        ...categories,
      ],
      products: products,
    );
  }

  static Future<_PharmacyLandingData> fetchPharmacyLanding({
    double? latitude,
    double? longitude,
  }) async {
    final response = await _get(
      '/public/pharmacy/landing',
      queryParameters: {
        if (latitude != null) 'latitude': '$latitude',
        if (longitude != null) 'longitude': '$longitude',
        'page': '0',
        'size': '20',
      },
    );
    final data = Map<String, dynamic>.from((response['data'] as Map?) ?? const {});
    final categories = (data['categories'] as List? ?? const [])
        .whereType<Map<dynamic, dynamic>>()
        .map((raw) => _mapPharmacyCategory(Map<String, dynamic>.from(raw)))
        .toList(growable: false);
    final products = _mapPharmacyProductPage(
      Map<String, dynamic>.from((data['products'] as Map?) ?? const {}),
    );
    final shops = (((data['shops'] as Map?)?['items']) as List? ?? const [])
        .whereType<Map<dynamic, dynamic>>()
        .map((raw) => _mapPharmacyShop(Map<String, dynamic>.from(raw)))
        .toList(growable: false);
    return _PharmacyLandingData(
      categories: [
        const _PharmacyRemoteCategory(label: 'All'),
        ...categories,
      ],
      products: products,
      shops: shops,
    );
  }

  static Future<_PharmacyProductPage> fetchPharmacyProducts({
    int? categoryId,
    int page = 0,
    int size = 20,
  }) async {
    final response = await _get(
      '/public/pharmacy/products',
      queryParameters: {
        if (categoryId != null) 'categoryId': '$categoryId',
        'page': '$page',
        'size': '$size',
      },
    );
    return _mapPharmacyProductPage(
      Map<String, dynamic>.from((response['data'] as Map?) ?? const {}),
    );
  }

  static Future<_PharmacyShopProfileData> fetchPharmacyShopProfile(
    int shopId, {
    int? categoryId,
    int page = 0,
    int size = 20,
  }) async {
    final response = await _get(
      '/public/pharmacy/shops/$shopId',
      queryParameters: {
        if (categoryId != null) 'categoryId': '$categoryId',
        'page': '$page',
        'size': '$size',
      },
    );
    final data = Map<String, dynamic>.from((response['data'] as Map?) ?? const {});
    final shop = Map<String, dynamic>.from((data['shop'] as Map?) ?? const {});
    final categories = (data['categories'] as List? ?? const [])
        .whereType<Map<dynamic, dynamic>>()
        .map((raw) => _mapPharmacyCategory(Map<String, dynamic>.from(raw)))
        .toList(growable: false);
    final products = _mapPharmacyProductPage(
      Map<String, dynamic>.from((data['products'] as Map?) ?? const {}),
    );
    return _PharmacyShopProfileData(
      shopId: (shop['shopId'] as num?)?.toInt() ?? shopId,
      shopName: '${shop['shopName'] ?? 'Pharmacy store'}',
      city: '${shop['city'] ?? ''}',
      rating: _rating(shop['avgRating']),
      closesAt: '${shop['closesAt'] ?? ''}',
      openNow: (shop['openNow'] as bool?) ?? false,
      acceptsOrders: (shop['acceptsOrders'] as bool?) ?? false,
      categories: [
        const _PharmacyRemoteCategory(label: 'All'),
        ...categories,
      ],
      products: products,
    );
  }

  static Future<Map<String, dynamic>> _get(
    String path, {
    Map<String, String>? queryParameters,
    bool authenticated = false,
  }) async {
    final headers = await _headers(authenticated: authenticated);
    final uri = _baseUri.replace(
      path: '${_baseUri.path}$path',
      queryParameters: queryParameters,
    );
    final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 8));
    return await _decodeResponse(response);
  }

  static Future<Map<String, dynamic>> _getAbsolute(
    Uri uri, {
    bool authenticated = false,
  }) async {
    final headers = await _headers(authenticated: authenticated);
    final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 8));
    return await _decodeResponse(response);
  }

  static Future<Map<String, dynamic>> _post(
    String path, {
    required Map<String, dynamic> body,
    bool authenticated = false,
  }) async {
    final headers = await _headers(authenticated: authenticated, includeJson: true);
    final uri = _baseUri.replace(path: '${_baseUri.path}$path');
    final response = await http
        .post(uri, headers: headers, body: jsonEncode(body))
        .timeout(const Duration(seconds: 8));
    return await _decodeResponse(response);
  }

  static Future<Map<String, dynamic>> _patch(
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = false,
    Duration timeout = const Duration(seconds: 8),
  }) async {
    final headers = await _headers(authenticated: authenticated, includeJson: body != null);
    final uri = _baseUri.replace(path: '${_baseUri.path}$path');
    late final http.Response response;
    try {
      response = await http
          .patch(
            uri,
            headers: headers,
            body: body == null ? null : jsonEncode(body),
          )
          .timeout(timeout);
    } on TimeoutException {
      throw const _UserAppApiException(
        'Saving took too long. Please try again with a smaller photo or retry once.',
      );
    }
    return await _decodeResponse(response);
  }

  static Future<Map<String, dynamic>> _put(
    String path, {
    required Map<String, dynamic> body,
    bool authenticated = false,
  }) async {
    final headers = await _headers(authenticated: authenticated, includeJson: true);
    final uri = _baseUri.replace(path: '${_baseUri.path}$path');
    final response = await http
        .put(uri, headers: headers, body: jsonEncode(body))
        .timeout(const Duration(seconds: 8));
    return await _decodeResponse(response);
  }

  static Future<Map<String, dynamic>> _delete(
    String path, {
    bool authenticated = false,
  }) async {
    final headers = await _headers(authenticated: authenticated);
    final uri = _baseUri.replace(path: '${_baseUri.path}$path');
    final response = await http.delete(uri, headers: headers).timeout(const Duration(seconds: 8));
    return await _decodeResponse(response);
  }

  static Future<Map<String, String>> _headers({
    required bool authenticated,
    bool includeJson = false,
  }) async {
    final headers = <String, String>{};
    if (includeJson) {
      headers['Content-Type'] = 'application/json';
    }
    if (authenticated) {
      final userId = await _LocalSessionStore.readUserId();
      final accessToken = await _LocalSessionStore.readAccessToken();
      if (userId == null) {
        throw const _UserAppApiException('User session not found. Please login again.');
      }
      if (accessToken == null || accessToken.trim().isEmpty) {
        throw const _UserAppApiException('Access token not found. Please login again.');
      }
      if (_isJwtExpired(accessToken)) {
        await _LocalSessionStore.clear();
        throw const _UserSessionExpiredApiException('Session expired. Please login again.');
      }
      headers['X-User-Id'] = '$userId';
      headers['Authorization'] = 'Bearer $accessToken';
    }
    return headers;
  }

  static Future<bool> _hasUsableSession() async {
    final userId = await _LocalSessionStore.readUserId();
    final accessToken = await _LocalSessionStore.readAccessToken();
    return userId != null && accessToken != null && accessToken.trim().isNotEmpty;
  }

  static Future<Map<String, dynamic>> _postAbsolute(
    Uri uri, {
    required Map<String, dynamic> body,
  }) async {
    final response = await http
        .post(
          uri,
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 8));
    return await _decodeResponse(response);
  }

  static Future<Map<String, dynamic>> _postAbsoluteAuthenticated(
    Uri uri, {
    required Map<String, dynamic> body,
  }) async {
    final headers = await _headers(authenticated: true, includeJson: true);
    final response = await http
        .post(
          uri,
          headers: headers,
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 8));
    return await _decodeResponse(response);
  }

  static Future<Map<String, dynamic>> _patchAbsoluteAuthenticated(
    Uri uri, {
    required Map<String, dynamic> body,
  }) async {
    final headers = await _headers(authenticated: true, includeJson: true);
    final response = await http
        .patch(
          uri,
          headers: headers,
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 8));
    return await _decodeResponse(response);
  }

  static Future<Map<String, dynamic>> _decodeResponse(http.Response response) async {
    final decoded = _decodeResponseBody(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }
    final message = _extractResponseMessage(decoded) ??
        'Request failed with status ${response.statusCode}.';
    if (response.statusCode == 401 || _looksLikeExpiredSessionMessage(message)) {
      await _LocalSessionStore.clear();
      throw const _UserSessionExpiredApiException('Session expired. Please login again.');
    }
    throw _UserAppApiException(message);
  }

  static Map<String, dynamic> _decodeResponseBody(String body) {
    if (body.trim().isEmpty) {
      return <String, dynamic>{};
    }
    final dynamic decoded = jsonDecode(body);
    if (decoded is Map) {
      return Map<String, dynamic>.from(decoded);
    }
    if (decoded is String) {
      final reparsed = jsonDecode(decoded);
      if (reparsed is Map) {
        return Map<String, dynamic>.from(reparsed);
      }
      return <String, dynamic>{'message': decoded};
    }
    return <String, dynamic>{};
  }

  static String? _extractResponseMessage(Map<String, dynamic> decoded) {
    final direct = '${decoded['message'] ?? ''}'.trim();
    if (direct.isNotEmpty) {
      final nested = _extractNestedJsonMessage(direct);
      return nested ?? direct;
    }
    final error = decoded['error'];
    if (error is Map) {
      final nested = _extractResponseMessage(Map<String, dynamic>.from(error));
      if (nested != null && nested.trim().isNotEmpty) {
        return nested.trim();
      }
    }
    return null;
  }

  static String? _extractNestedJsonMessage(String raw) {
    if (!raw.startsWith('{') || !raw.endsWith('}')) {
      return null;
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        final nested = '${decoded['message'] ?? ''}'.trim();
        if (nested.isNotEmpty) {
          return nested;
        }
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  static _RemoteCartState _mapCart(Map<String, dynamic> data) {
    final items = (data['items'] as List? ?? const [])
        .whereType<Map<dynamic, dynamic>>()
        .map(
          (raw) => _DiscoveryItem(
            title: '${raw['productName'] ?? 'Item'}',
            subtitle: '${data['shopName'] ?? 'Selected shop'}',
            accent: const Color(0xFFCB6E5B),
            icon: Icons.shopping_bag_rounded,
            price: _money(raw['unitPrice']),
            extra: '${raw['variantName'] ?? ''}'.trim(),
            backendProductId: (raw['productId'] as num?)?.toInt(),
            backendVariantId: (raw['variantId'] as num?)?.toInt(),
            backendShopId: (data['shopId'] as num?)?.toInt(),
          ),
        )
        .toList(growable: false);
    return _RemoteCartState(
      shopName: '${data['shopName'] ?? 'Selected shop'}',
      itemCount: (data['itemCount'] as num?)?.toInt() ?? items.length,
      items: items,
    );
  }

  static _DiscoveryItem _mapProductCard(Map<String, dynamic> raw) {
    final title = '${raw['productName'] ?? 'Product'}';
    final subtitle = '${raw['shopName'] ?? 'Shop'}';
    final category = _normalizeCategory(
      '${raw['categoryName'] ?? raw['productType'] ?? title}',
    );
    return _DiscoveryItem(
      title: title,
      subtitle: subtitle,
      accent: _categoryAccent(category),
      icon: _categoryIcon(category),
      price: _money(raw['sellingPrice']),
      rating: _rating(raw['avgRating']),
      extra: '${raw['brandName'] ?? raw['shortDescription'] ?? ''}'.trim(),
      shopCategory: category,
      backendProductId: (raw['productId'] as num?)?.toInt(),
      backendVariantId: (raw['variantId'] as num?)?.toInt(),
      backendShopId: (raw['shopId'] as num?)?.toInt(),
    );
  }

  static _RemoteLabourCategory _mapLabourCategory(Map<String, dynamic> raw) {
    return _RemoteLabourCategory(
      label: '${raw['name'] ?? 'Labour'}',
      backendCategoryId: (raw['id'] as num?)?.toInt(),
    );
  }

  static _RemoteNotificationItem _mapNotification(Map<String, dynamic> raw) {
    return _RemoteNotificationItem(
      id: (raw['id'] as num?)?.toInt() ?? 0,
      channel: '${raw['channel'] ?? ''}',
      notificationType: '${raw['notificationType'] ?? ''}',
      title: '${raw['title'] ?? ''}',
      body: '${raw['body'] ?? ''}',
      status: '${raw['status'] ?? ''}',
      payloadJson: '${raw['payloadJson'] ?? ''}',
      sentAt: _parseDateTime(raw['sentAt']),
      readAt: _parseDateTime(raw['readAt']),
      createdAt: _parseDateTime(raw['createdAt']),
    );
  }

  static _UserAddressData _mapUserAddress(Map<String, dynamic> raw) {
    return _UserAddressData(
      id: (raw['id'] as num?)?.toInt() ?? 0,
      label: '${raw['label'] ?? 'Address'}',
      addressLine1: '${raw['addressLine1'] ?? ''}',
      addressLine2: '${raw['addressLine2'] ?? ''}',
      landmark: '${raw['landmark'] ?? ''}',
      city: '${raw['city'] ?? ''}',
      stateId: (raw['stateId'] as num?)?.toInt(),
      state: '${raw['state'] ?? ''}',
      countryId: (raw['countryId'] as num?)?.toInt(),
      country: '${raw['country'] ?? ''}',
      postalCode: '${raw['postalCode'] ?? ''}',
      latitude: double.tryParse('${raw['latitude'] ?? ''}') ?? 0,
      longitude: double.tryParse('${raw['longitude'] ?? ''}') ?? 0,
      isDefault: (raw['isDefault'] as bool?) ?? false,
    );
  }

  static _UserOrderSummary _mapOrderSummary(Map<String, dynamic> raw) {
    return _UserOrderSummary(
      orderId: (raw['orderId'] as num?)?.toInt() ?? 0,
      orderCode: '${raw['orderCode'] ?? ''}',
      shopId: (raw['shopId'] as num?)?.toInt() ?? 0,
      shopName: '${raw['shopName'] ?? 'Shop'}',
      primaryItemName: '${raw['primaryItemName'] ?? 'Order item'}',
      primaryImageFileId: '${raw['primaryImageFileId'] ?? ''}',
      itemCount: (raw['itemCount'] as num?)?.toInt() ?? 0,
      orderStatus: '${raw['orderStatus'] ?? ''}',
      paymentStatus: '${raw['paymentStatus'] ?? ''}',
      totalAmount: _money(raw['totalAmount']),
      currencyCode: '${raw['currencyCode'] ?? 'INR'}',
      cancellable: (raw['cancellable'] as bool?) ?? false,
      refundPresent: (raw['refundPresent'] as bool?) ?? false,
      latestRefundStatus: '${raw['latestRefundStatus'] ?? ''}',
      createdAt: _parseDateTime(raw['createdAt']),
      updatedAt: _parseDateTime(raw['updatedAt']),
    );
  }

  static _UserOrderDetail _mapOrderDetail(Map<String, dynamic> raw) {
    final items = (raw['items'] as List? ?? const [])
        .whereType<Map<dynamic, dynamic>>()
        .map(
          (entry) => _UserOrderItem(
            orderItemId: (entry['orderItemId'] as num?)?.toInt() ?? 0,
            productId: (entry['productId'] as num?)?.toInt() ?? 0,
            variantId: (entry['variantId'] as num?)?.toInt(),
            productName: '${entry['productName'] ?? 'Item'}',
            variantName: '${entry['variantName'] ?? ''}',
            imageFileId: '${entry['imageFileId'] ?? ''}',
            quantity: (entry['quantity'] as num?)?.toInt() ?? 0,
            unitPrice: _money(entry['unitPrice']),
            lineTotal: _money(entry['lineTotal']),
          ),
        )
        .toList(growable: false);
    final timeline = (raw['timeline'] as List? ?? const [])
        .whereType<Map<dynamic, dynamic>>()
        .map(
          (entry) => _UserOrderTimelineEvent(
            oldStatus: '${entry['oldStatus'] ?? ''}',
            newStatus: '${entry['newStatus'] ?? ''}',
            reason: '${entry['reason'] ?? ''}',
            changedAt: _parseDateTime(entry['changedAt']),
          ),
        )
        .toList(growable: false);
    final refundRaw = raw['refund'];
    return _UserOrderDetail(
      orderId: (raw['orderId'] as num?)?.toInt() ?? 0,
      orderCode: '${raw['orderCode'] ?? ''}',
      shopId: (raw['shopId'] as num?)?.toInt() ?? 0,
      shopName: '${raw['shopName'] ?? 'Shop'}',
      orderStatus: '${raw['orderStatus'] ?? ''}',
      paymentStatus: '${raw['paymentStatus'] ?? ''}',
      paymentCode: '${raw['paymentCode'] ?? ''}',
      fulfillmentType: '${raw['fulfillmentType'] ?? ''}',
      addressLabel: '${raw['addressLabel'] ?? ''}',
      addressLine: '${raw['addressLine'] ?? ''}',
      subtotalAmount: _money(raw['subtotalAmount']),
      deliveryFeeAmount: _money(raw['deliveryFeeAmount']),
      platformFeeAmount: _money(raw['platformFeeAmount']),
      totalAmount: _money(raw['totalAmount']),
      currencyCode: '${raw['currencyCode'] ?? 'INR'}',
      cancellable: (raw['cancellable'] as bool?) ?? false,
      createdAt: _parseDateTime(raw['createdAt']),
      updatedAt: _parseDateTime(raw['updatedAt']),
      items: items,
      timeline: timeline,
      refund: refundRaw is Map
          ? _UserOrderRefund(
              refundCode: '${refundRaw['refundCode'] ?? ''}',
              refundStatus: '${refundRaw['refundStatus'] ?? ''}',
              requestedAmount: _money(refundRaw['requestedAmount']),
              approvedAmount: _money(refundRaw['approvedAmount']),
              reason: '${refundRaw['reason'] ?? ''}',
              initiatedAt: _parseDateTime(refundRaw['initiatedAt']),
              completedAt: _parseDateTime(refundRaw['completedAt']),
            )
          : null,
    );
  }

  static _DiscoveryItem _mapLabourProfile(Map<String, dynamic> raw) {
    final category = '${raw['categoryName'] ?? 'Labour'}';
    final hourly = _money(raw['hourlyRate']);
    final halfDay = _money(raw['halfDayRate']);
    final fullDay = _money(raw['fullDayRate']);
    final categoryPricings = (raw['categoryPricings'] as List? ?? const [])
        .whereType<Map<dynamic, dynamic>>()
        .map((entry) {
          final map = Map<String, dynamic>.from(entry);
          return _LabourCategoryPricing(
            categoryId: (map['categoryId'] as num?)?.toInt(),
            label: '${map['categoryName'] ?? category}',
            halfDayPrice: _money(map['halfDayRate']),
            fullDayPrice: _money(map['fullDayRate']),
          );
        })
        .where((entry) => entry.categoryId != null || entry.label.trim().isNotEmpty)
        .toList(growable: false);
    final availableNow = (raw['availableNow'] as bool?) ?? false;
    final availabilityStatus = '${raw['availabilityStatus'] ?? ''}'.toUpperCase();
    final disabledLabel = switch (availabilityStatus) {
      'BOOKED' => 'Booked',
      'OFFLINE' => 'Offline',
      _ => '',
    };
    return _DiscoveryItem(
      title: '${raw['fullName'] ?? 'Labour'}',
      subtitle: category,
      accent: const Color(0xFFF2A13D),
      icon: Icons.engineering_rounded,
      price: hourly.isEmpty ? '₹0/hr' : '$hourly/hr',
      rating: ((raw['completedJobs'] as num?)?.toInt() ?? 0) > 0 ? _rating(raw['rating']) : '',
      distance: _distance(raw['distanceKm']),
      extra: '${(raw['completedJobs'] as num?)?.toInt() ?? 0} jobs done',
      maskedPhone: '${raw['maskedPhone'] ?? ''}',
      backendLabourId: (raw['labourId'] as num?)?.toInt(),
      backendCategoryId: (raw['categoryId'] as num?)?.toInt(),
      profileImageUrl: _publicFileUrl('${raw['photoObjectKey'] ?? ''}'),
      isDisabled: !availableNow,
      disabledLabel: disabledLabel,
      labourHalfDayPrice: halfDay,
      labourFullDayPrice: fullDay,
      experienceYears: (raw['experienceYears'] as num?)?.toInt(),
      completedJobsCount: (raw['completedJobs'] as num?)?.toInt(),
      labourRadiusKm: (raw['radiusKm'] as num?)?.toDouble(),
      labourWorkLatitude: (raw['workLatitude'] as num?)?.toDouble(),
      labourWorkLongitude: (raw['workLongitude'] as num?)?.toDouble(),
      labourCategoryPricing: categoryPricings.isNotEmpty
          ? categoryPricings
          : [
              _LabourCategoryPricing(
                categoryId: (raw['categoryId'] as num?)?.toInt(),
                label: category,
                halfDayPrice: halfDay,
                fullDayPrice: fullDay,
              ),
            ],
    );
  }

  static _RemoteServiceCategory _mapServiceCategory(Map<String, dynamic> raw) {
    final subcategories = (raw['subcategories'] as List? ?? const [])
        .whereType<Map<dynamic, dynamic>>()
        .map(
          (entry) => _RemoteServiceSubcategory(
            label: '${entry['name'] ?? 'All'}',
            backendSubcategoryId: (entry['id'] as num?)?.toInt(),
          ),
        )
        .toList(growable: false);
    return _RemoteServiceCategory(
      label: '${raw['name'] ?? 'Service'}',
      backendCategoryId: (raw['id'] as num?)?.toInt(),
      subcategories: [
        const _RemoteServiceSubcategory(label: 'All', backendSubcategoryId: null),
        ...subcategories,
      ],
    );
  }

  static _DiscoveryItem _mapServiceProvider(Map<String, dynamic> raw) {
    final category = '${raw['categoryName'] ?? 'Service'}';
    final serviceLabel = '${raw['serviceName'] ?? raw['subcategoryName'] ?? category}';
    final providerName = '${raw['providerName'] ?? 'Service provider'}';
    final availableNow = (raw['availableNow'] as bool?) ?? false;
    final availabilityStatus = '${raw['availabilityStatus'] ?? ''}'.toUpperCase();
    final disabledLabel = switch (availabilityStatus) {
      'BOOKED' => 'Booked',
      'OFFLINE' => 'Offline',
      _ => '',
    };
    final serviceItems = (raw['serviceItems'] as List? ?? const [])
        .map((entry) => '$entry'.trim())
        .where((entry) => entry.isNotEmpty)
        .toList(growable: false);
    return _DiscoveryItem(
      title: serviceLabel,
      subtitle: providerName,
      accent: _serviceAccent(category),
      icon: _serviceIcon(category),
      price: '${_money(raw['visitingCharge'])} visit',
      rating: _rating(raw['rating']),
      distance: _distance(raw['distanceKm']),
      extra: '${(raw['completedJobs'] as num?)?.toInt() ?? 0} bookings done',
      maskedPhone: '${raw['maskedPhone'] ?? ''}',
      backendServiceProviderId: (raw['providerId'] as num?)?.toInt(),
      backendCategoryId: (raw['categoryId'] as num?)?.toInt(),
      backendSubcategoryId: (raw['subcategoryId'] as num?)?.toInt(),
      profileImageUrl: _publicFileUrl('${raw['photoObjectKey'] ?? ''}'),
      isDisabled: !availableNow,
      disabledLabel: disabledLabel,
      serviceItems: serviceItems,
      serviceTileLabel: serviceLabel,
      completedJobsCount: (raw['completedJobs'] as num?)?.toInt(),
    );
  }

  static _RestaurantCuisineItem _mapRestaurantCuisine(Map<String, dynamic> raw) {
    final label = '${raw['name'] ?? 'Category'}';
    final category = _normalizeCategory(label);
    return _RestaurantCuisineItem(
      label: label,
      imageKey: label,
      accent: _categoryAccent(category),
      icon: _categoryIcon(category),
      backendCategoryId: (raw['id'] as num?)?.toInt(),
    );
  }

  static _RestaurantRemoteShopSummary _mapRestaurantShop(Map<String, dynamic> raw) {
    final shopName = '${raw['shopName'] ?? 'Restaurant'}';
    final city = '${raw['city'] ?? ''}'.trim();
    final minOrderAmount = _money(raw['minOrderAmount']);
    final deliveryFee = _money(raw['deliveryFee']);
    final offer = deliveryFee.isEmpty || deliveryFee == '₹0'
        ? 'Free delivery'
        : minOrderAmount.isNotEmpty
            ? 'Above $minOrderAmount'
            : 'Delivery $deliveryFee';
    final eta = (raw['openNow'] as bool? ?? false)
        ? ((raw['closingSoon'] as bool? ?? false)
            ? 'Closing soon'
            : 'Open now')
        : 'Closed';
    final cuisineLine = [
      if (city.isNotEmpty) city,
      if ('${raw['deliveryType'] ?? ''}'.trim().isNotEmpty) '${raw['deliveryType']}',
    ].join(' · ');
    return _RestaurantRemoteShopSummary(
      shopId: (raw['shopId'] as num?)?.toInt() ?? 0,
      shopName: shopName,
      city: city,
      rating: _rating(raw['avgRating']),
      offer: offer,
      eta: eta,
      cuisineLine: cuisineLine,
      acceptsOrders: (raw['acceptsOrders'] as bool?) ?? false,
    );
  }

  static _FashionRemoteCategory _mapFashionCategory(Map<String, dynamic> raw) {
    return _FashionRemoteCategory(
      label: '${raw['name'] ?? 'Category'}',
      backendCategoryId: (raw['id'] as num?)?.toInt(),
    );
  }

  static _FashionProductPage _mapFashionProductPage(Map<String, dynamic> raw) {
    final items = (raw['items'] as List? ?? const [])
        .whereType<Map<dynamic, dynamic>>()
        .map((entry) => _mapFashionProduct(Map<String, dynamic>.from(entry)))
        .toList(growable: false);
    final page = (raw['page'] as num?)?.toInt() ?? 0;
    final size = (raw['size'] as num?)?.toInt() ?? items.length;
    final totalElements = (raw['totalElements'] as num?)?.toInt() ?? items.length;
    final hasMore = ((page + 1) * (size <= 0 ? items.length : size)) < totalElements;
    return _FashionProductPage(
      items: items,
      page: page,
      hasMore: hasMore,
    );
  }

  static _FashionRemoteProduct _mapFashionProduct(Map<String, dynamic> raw) {
    final sellingPrice = _money(raw['sellingPrice']);
    final mrp = _money(raw['mrp']);
    final item = _DiscoveryItem(
      title: '${raw['productName'] ?? 'Fashion item'}',
      subtitle: '${raw['brandName'] ?? raw['shopName'] ?? 'Fashion'}',
      accent: const Color(0xFFCB6E5B),
      icon: Icons.checkroom_rounded,
      price: sellingPrice,
      rating: _rating(raw['avgRating']),
      extra: '${raw['shopName'] ?? ''}'.trim(),
      shopCategory: 'Fashion',
      backendProductId: (raw['productId'] as num?)?.toInt(),
      backendVariantId: (raw['variantId'] as num?)?.toInt(),
      backendShopId: (raw['shopId'] as num?)?.toInt(),
    );
    return _FashionRemoteProduct(
      item: item,
      oldPrice: mrp != sellingPrice ? mrp : '',
      couponPrice: sellingPrice,
      discount: _discountLabel(raw['mrp'], raw['sellingPrice']),
      votes: _countLabel((raw['totalReviews'] as num?)?.toInt() ?? 0),
      promoted: ((raw['promotionScore'] as num?)?.toInt() ?? 0) > 0,
    );
  }

  static _FashionRemoteShopSummary _mapFashionShop(Map<String, dynamic> raw) {
    return _FashionRemoteShopSummary(
      shopId: (raw['shopId'] as num?)?.toInt() ?? 0,
      shopName: '${raw['shopName'] ?? 'Fashion shop'}',
      city: '${raw['city'] ?? ''}'.trim(),
      rating: _rating(raw['avgRating']),
      openNow: (raw['openNow'] as bool?) ?? false,
      closingSoon: (raw['closingSoon'] as bool?) ?? false,
      acceptsOrders: (raw['acceptsOrders'] as bool?) ?? false,
      closesAt: '${raw['closesAt'] ?? ''}',
    );
  }

  static _FootwearRemoteCategory _mapFootwearCategory(Map<String, dynamic> raw) {
    return _FootwearRemoteCategory(
      label: '${raw['name'] ?? 'Category'}',
      backendCategoryId: (raw['id'] as num?)?.toInt(),
    );
  }

  static _FootwearProductPage _mapFootwearProductPage(Map<String, dynamic> raw) {
    final items = (raw['items'] as List? ?? const [])
        .whereType<Map<dynamic, dynamic>>()
        .map((entry) => _mapFootwearProduct(Map<String, dynamic>.from(entry)))
        .toList(growable: false);
    final page = (raw['page'] as num?)?.toInt() ?? 0;
    final size = (raw['size'] as num?)?.toInt() ?? items.length;
    final totalElements = (raw['totalElements'] as num?)?.toInt() ?? items.length;
    final hasMore = ((page + 1) * (size <= 0 ? items.length : size)) < totalElements;
    return _FootwearProductPage(
      items: items,
      page: page,
      hasMore: hasMore,
    );
  }

  static _FootwearRemoteProduct _mapFootwearProduct(Map<String, dynamic> raw) {
    final sellingPrice = _money(raw['sellingPrice']);
    final mrp = _money(raw['mrp']);
    final item = _DiscoveryItem(
      title: '${raw['productName'] ?? 'Footwear item'}',
      subtitle: '${raw['brandName'] ?? raw['shopName'] ?? 'Footwear'}',
      accent: const Color(0xFF5C8FD8),
      icon: Icons.hiking_rounded,
      price: sellingPrice,
      rating: _rating(raw['avgRating']),
      extra: '${raw['shopName'] ?? ''}'.trim(),
      shopCategory: 'Footwear',
      backendProductId: (raw['productId'] as num?)?.toInt(),
      backendVariantId: (raw['variantId'] as num?)?.toInt(),
      backendShopId: (raw['shopId'] as num?)?.toInt(),
    );
    return _FootwearRemoteProduct(
      item: item,
      oldPrice: mrp != sellingPrice ? mrp : '',
      couponPrice: sellingPrice,
      discount: _discountLabel(raw['mrp'], raw['sellingPrice']),
      votes: _countLabel((raw['totalReviews'] as num?)?.toInt() ?? 0),
      promoted: ((raw['promotionScore'] as num?)?.toInt() ?? 0) > 0,
    );
  }

  static _FootwearRemoteShopSummary _mapFootwearShop(Map<String, dynamic> raw) {
    return _FootwearRemoteShopSummary(
      shopId: (raw['shopId'] as num?)?.toInt() ?? 0,
      shopName: '${raw['shopName'] ?? 'Footwear shop'}',
      city: '${raw['city'] ?? ''}'.trim(),
      rating: _rating(raw['avgRating']),
      openNow: (raw['openNow'] as bool?) ?? false,
      closingSoon: (raw['closingSoon'] as bool?) ?? false,
      acceptsOrders: (raw['acceptsOrders'] as bool?) ?? false,
      closesAt: '${raw['closesAt'] ?? ''}',
    );
  }

  static _GiftRemoteCategory _mapGiftCategory(Map<String, dynamic> raw) {
    return _GiftRemoteCategory(
      label: '${raw['name'] ?? 'Category'}',
      backendCategoryId: (raw['id'] as num?)?.toInt(),
    );
  }

  static _GiftProductPage _mapGiftProductPage(Map<String, dynamic> raw) {
    final items = (raw['items'] as List? ?? const [])
        .whereType<Map<dynamic, dynamic>>()
        .map((entry) => _mapGiftProduct(Map<String, dynamic>.from(entry)))
        .toList(growable: false);
    final page = (raw['page'] as num?)?.toInt() ?? 0;
    final size = (raw['size'] as num?)?.toInt() ?? items.length;
    final totalElements = (raw['totalElements'] as num?)?.toInt() ?? items.length;
    final hasMore = ((page + 1) * (size <= 0 ? items.length : size)) < totalElements;
    return _GiftProductPage(items: items, page: page, hasMore: hasMore);
  }

  static _GiftRemoteProduct _mapGiftProduct(Map<String, dynamic> raw) {
    return _GiftRemoteProduct(
      item: _DiscoveryItem(
        title: '${raw['productName'] ?? 'Gift item'}',
        subtitle: '${raw['shopName'] ?? 'Gift store'}',
        accent: const Color(0xFFB76AA3),
        icon: Icons.redeem_rounded,
        price: _money(raw['sellingPrice']),
        rating: _rating(raw['avgRating']),
        extra: '${raw['brandName'] ?? raw['shortDescription'] ?? ''}'.trim(),
        shopCategory: 'Gift',
        backendProductId: (raw['productId'] as num?)?.toInt(),
        backendVariantId: (raw['variantId'] as num?)?.toInt(),
        backendShopId: (raw['shopId'] as num?)?.toInt(),
      ),
      categoryLabel: '${raw['categoryName'] ?? 'All'}',
    );
  }

  static _GiftRemoteShopSummary _mapGiftShop(Map<String, dynamic> raw) {
    return _GiftRemoteShopSummary(
      shopId: (raw['shopId'] as num?)?.toInt() ?? 0,
      shopName: '${raw['shopName'] ?? 'Gift store'}',
      city: '${raw['city'] ?? ''}'.trim(),
      rating: _rating(raw['avgRating']),
      openNow: (raw['openNow'] as bool?) ?? false,
      closingSoon: (raw['closingSoon'] as bool?) ?? false,
      acceptsOrders: (raw['acceptsOrders'] as bool?) ?? false,
      closesAt: '${raw['closesAt'] ?? ''}',
    );
  }

  static _GroceryRemoteCategory _mapGroceryCategory(Map<String, dynamic> raw) {
    return _GroceryRemoteCategory(
      label: '${raw['name'] ?? 'Category'}',
      backendCategoryId: (raw['id'] as num?)?.toInt(),
    );
  }

  static _GroceryProductPage _mapGroceryProductPage(Map<String, dynamic> raw) {
    final items = (raw['items'] as List? ?? const [])
        .whereType<Map<dynamic, dynamic>>()
        .map((entry) => _mapGroceryProduct(Map<String, dynamic>.from(entry)))
        .toList(growable: false);
    final page = (raw['page'] as num?)?.toInt() ?? 0;
    final size = (raw['size'] as num?)?.toInt() ?? items.length;
    final totalElements = (raw['totalElements'] as num?)?.toInt() ?? items.length;
    final hasMore = ((page + 1) * (size <= 0 ? items.length : size)) < totalElements;
    return _GroceryProductPage(items: items, page: page, hasMore: hasMore);
  }

  static _GroceryRemoteProduct _mapGroceryProduct(Map<String, dynamic> raw) {
    return _GroceryRemoteProduct(
      item: _DiscoveryItem(
        title: '${raw['productName'] ?? 'Grocery item'}',
        subtitle: '${raw['shopName'] ?? 'Grocery shop'}',
        accent: const Color(0xFF7AA81E),
        icon: Icons.local_grocery_store_rounded,
        price: _money(raw['sellingPrice']),
        rating: _rating(raw['avgRating']),
        extra: '${raw['brandName'] ?? raw['shortDescription'] ?? ''}'.trim(),
        shopCategory: 'Groceries',
        backendProductId: (raw['productId'] as num?)?.toInt(),
        backendVariantId: (raw['variantId'] as num?)?.toInt(),
        backendShopId: (raw['shopId'] as num?)?.toInt(),
      ),
      categoryLabel: '${raw['categoryName'] ?? 'All'}',
    );
  }

  static _GroceryRemoteShopSummary _mapGroceryShop(Map<String, dynamic> raw) {
    return _GroceryRemoteShopSummary(
      shopId: (raw['shopId'] as num?)?.toInt() ?? 0,
      shopName: '${raw['shopName'] ?? 'Grocery shop'}',
      city: '${raw['city'] ?? ''}'.trim(),
      rating: _rating(raw['avgRating']),
      openNow: (raw['openNow'] as bool?) ?? false,
      closingSoon: (raw['closingSoon'] as bool?) ?? false,
      acceptsOrders: (raw['acceptsOrders'] as bool?) ?? false,
      closesAt: '${raw['closesAt'] ?? ''}',
    );
  }

  static _PharmacyRemoteCategory _mapPharmacyCategory(Map<String, dynamic> raw) {
    return _PharmacyRemoteCategory(
      label: '${raw['name'] ?? 'Category'}',
      backendCategoryId: (raw['id'] as num?)?.toInt(),
    );
  }

  static _PharmacyProductPage _mapPharmacyProductPage(Map<String, dynamic> raw) {
    final items = (raw['items'] as List? ?? const [])
        .whereType<Map<dynamic, dynamic>>()
        .map((entry) => _mapPharmacyProduct(Map<String, dynamic>.from(entry)))
        .toList(growable: false);
    final page = (raw['page'] as num?)?.toInt() ?? 0;
    final size = (raw['size'] as num?)?.toInt() ?? items.length;
    final totalElements = (raw['totalElements'] as num?)?.toInt() ?? items.length;
    final hasMore = ((page + 1) * (size <= 0 ? items.length : size)) < totalElements;
    return _PharmacyProductPage(items: items, page: page, hasMore: hasMore);
  }

  static _PharmacyRemoteProduct _mapPharmacyProduct(Map<String, dynamic> raw) {
    return _PharmacyRemoteProduct(
      item: _DiscoveryItem(
        title: '${raw['productName'] ?? 'Pharmacy item'}',
        subtitle: '${raw['shopName'] ?? 'Pharmacy store'}',
        accent: const Color(0xFF268B9C),
        icon: Icons.local_pharmacy_rounded,
        price: _money(raw['sellingPrice']),
        rating: _rating(raw['avgRating']),
        extra: '${raw['brandName'] ?? raw['shortDescription'] ?? ''}'.trim(),
        shopCategory: 'Pharmacy',
        backendProductId: (raw['productId'] as num?)?.toInt(),
        backendVariantId: (raw['variantId'] as num?)?.toInt(),
        backendShopId: (raw['shopId'] as num?)?.toInt(),
      ),
      categoryLabel: '${raw['categoryName'] ?? 'All'}',
    );
  }

  static _PharmacyRemoteShopSummary _mapPharmacyShop(Map<String, dynamic> raw) {
    return _PharmacyRemoteShopSummary(
      shopId: (raw['shopId'] as num?)?.toInt() ?? 0,
      shopName: '${raw['shopName'] ?? 'Pharmacy store'}',
      city: '${raw['city'] ?? ''}'.trim(),
      rating: _rating(raw['avgRating']),
      openNow: (raw['openNow'] as bool?) ?? false,
      closingSoon: (raw['closingSoon'] as bool?) ?? false,
      acceptsOrders: (raw['acceptsOrders'] as bool?) ?? false,
      closesAt: '${raw['closesAt'] ?? ''}',
    );
  }

  static String _normalizeCategory(String raw) {
    final text = raw.toLowerCase();
    if (text.contains('shoe') || text.contains('footwear') || text.contains('sandal') || text.contains('slipper')) {
      return 'Footwear';
    }
    if (text.contains('fashion') ||
        text.contains('shirt') ||
        text.contains('jean') ||
        text.contains('kurti') ||
        text.contains('dress') ||
        text.contains('saree')) {
      return 'Fashion';
    }
    if (text.contains('gift') || text.contains('flower') || text.contains('cake') || text.contains('plant')) {
      return 'Gift';
    }
    if (text.contains('pharmacy') || text.contains('tablet') || text.contains('wellness') || text.contains('care')) {
      return 'Pharmacy';
    }
    if (text.contains('grocery') || text.contains('rice') || text.contains('atta') || text.contains('biscuit')) {
      return 'Groceries';
    }
    if (text.contains('pizza') ||
        text.contains('restaurant') ||
        text.contains('food') ||
        text.contains('burger') ||
        text.contains('cake') ||
        text.contains('dessert')) {
      return 'Restaurant';
    }
    return 'Restaurant';
  }

  static Color _categoryAccent(String category) {
    switch (category) {
      case 'Fashion':
        return const Color(0xFFCB6E5B);
      case 'Footwear':
        return const Color(0xFF5C8FD8);
      case 'Gift':
        return const Color(0xFFB76AA3);
      case 'Pharmacy':
        return const Color(0xFF4DAF50);
      case 'Groceries':
        return const Color(0xFF7AA81E);
      case 'Restaurant':
      default:
        return const Color(0xFFF28B3C);
    }
  }

  static IconData _categoryIcon(String category) {
    switch (category) {
      case 'Fashion':
        return Icons.checkroom_rounded;
      case 'Footwear':
        return Icons.hiking_rounded;
      case 'Gift':
        return Icons.redeem_rounded;
      case 'Pharmacy':
        return Icons.local_pharmacy_rounded;
      case 'Groceries':
        return Icons.local_grocery_store_rounded;
      case 'Restaurant':
      default:
        return Icons.restaurant_rounded;
    }
  }

  static String _money(Object? value) {
    if (value == null) {
      return '';
    }
    final amount = double.tryParse('$value') ?? 0;
    return amount.truncateToDouble() == amount
        ? '₹${amount.toStringAsFixed(0)}'
        : '₹${amount.toStringAsFixed(2)}';
  }

  static String _percent(Object? value) {
    if (value == null) {
      return '';
    }
    final numeric = switch (value) {
      num number => number.toDouble(),
      String text => double.tryParse(text.trim()),
      _ => null,
    };
    if (numeric == null) {
      return '';
    }
    if (numeric.truncateToDouble() == numeric) {
      return '${numeric.toStringAsFixed(0)}%';
    }
    return '${numeric.toStringAsFixed(2)}%';
  }

  static double _amountValue(Object? value) {
    return double.tryParse('${value ?? ''}') ?? 0;
  }

  static String _distance(Object? value) {
    final number = value is num ? value.toDouble() : double.tryParse('${value ?? ''}');
    if (number == null || number <= 0) {
      return 'Nearby';
    }
    return '${number.toStringAsFixed(number < 10 ? 1 : 0)} km';
  }

  static Color _serviceAccent(String category) {
    switch (category.toLowerCase()) {
      case 'automobile':
        return const Color(0xFF5C8FD8);
      case 'plumber':
        return const Color(0xFF3F7FE7);
      case 'ac repair':
        return const Color(0xFF74BFF6);
      case 'appliance':
      case 'home appliance':
        return const Color(0xFFDF7DA0);
      case 'electrician':
        return const Color(0xFFF2A13D);
      default:
        return const Color(0xFFCB6E5B);
    }
  }

  static IconData _serviceIcon(String category) {
    switch (category.toLowerCase()) {
      case 'automobile':
        return Icons.directions_car_filled_rounded;
      case 'plumber':
        return Icons.plumbing_rounded;
      case 'ac repair':
        return Icons.ac_unit_rounded;
      case 'appliance':
      case 'home appliance':
        return Icons.kitchen_rounded;
      case 'electrician':
        return Icons.electrical_services_rounded;
      default:
        return Icons.miscellaneous_services_rounded;
    }
  }

  static String _rating(Object? value) {
    final parsed = double.tryParse('$value');
    if (parsed == null || parsed <= 0) {
      return '';
    }
    return parsed.toStringAsFixed(1);
  }

  static String _discountLabel(Object? mrpValue, Object? sellingValue) {
    final mrp = double.tryParse('$mrpValue') ?? 0;
    final selling = double.tryParse('$sellingValue') ?? 0;
    if (mrp <= 0 || selling <= 0 || mrp <= selling) {
      return '';
    }
    final discount = (((mrp - selling) / mrp) * 100).round();
    return '$discount% OFF';
  }

  static String _countLabel(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(count % 1000 == 0 ? 0 : 1)}k';
    }
    return '$count';
  }

  static DateTime? _parseDateTime(Object? value) {
    final raw = '${value ?? ''}'.trim();
    if (raw.isEmpty) {
      return null;
    }
    return DateTime.tryParse(raw)?.toLocal();
  }

  static double? _parseDouble(Object? value) {
    if (value is num) {
      return value.toDouble();
    }
    final raw = '${value ?? ''}'.trim();
    if (raw.isEmpty) {
      return null;
    }
    return double.tryParse(raw);
  }

  static DateTime? _parseDate(String raw) {
    if (raw.trim().isEmpty) {
      return null;
    }
    return DateTime.tryParse(raw);
  }
}

class _ActiveBookingStatus {
  const _ActiveBookingStatus({
    required this.requestId,
    required this.requestCode,
    required this.bookingType,
    required this.requestStatus,
    required this.historyStatus,
    required this.providerName,
    required this.providerPhone,
    required this.quotedPriceAmount,
    required this.totalAcceptedQuotedPriceAmount,
    required this.totalAcceptedBookingChargeAmount,
    required this.distanceLabel,
    required this.providerPhotoUrl,
    required this.providerLatitude,
    required this.providerLongitude,
    required this.destinationLatitude,
    required this.destinationLongitude,
    required this.paymentDueAt,
    required this.reachByAt,
    required this.labourPricingModel,
    required this.bookingId,
    required this.bookingCode,
    required this.bookingStatus,
    required this.paymentStatus,
    required this.createdAt,
    required this.canMakePayment,
    required this.reviewSubmitted,
  });

  final int requestId;
  final String requestCode;
  final String bookingType;
  final String requestStatus;
  final String historyStatus;
  final String providerName;
  final String providerPhone;
  final String quotedPriceAmount;
  final String totalAcceptedQuotedPriceAmount;
  final String totalAcceptedBookingChargeAmount;
  final String distanceLabel;
  final String providerPhotoUrl;
  final double? providerLatitude;
  final double? providerLongitude;
  final double? destinationLatitude;
  final double? destinationLongitude;
  final DateTime? paymentDueAt;
  final DateTime? reachByAt;
  final String labourPricingModel;
  final int bookingId;
  final String bookingCode;
  final String bookingStatus;
  final String paymentStatus;
  final DateTime? createdAt;
  final bool canMakePayment;
  final bool reviewSubmitted;
}

class _RemoteCartState {
  const _RemoteCartState({
    required this.shopName,
    required this.itemCount,
    required this.items,
  });

  final String shopName;
  final int itemCount;
  final List<_DiscoveryItem> items;
}

class _RemoteNotificationList {
  const _RemoteNotificationList({
    required this.items,
    required this.unreadCount,
  });

  final List<_RemoteNotificationItem> items;
  final int unreadCount;
}

class _UserProfileData {
  const _UserProfileData({
    required this.userId,
    required this.publicUserId,
    required this.phone,
    required this.fullName,
    required this.profilePhotoDataUri,
    required this.profilePhotoObjectKey,
    required this.gender,
    required this.dob,
    required this.languageCode,
  });

  final int userId;
  final String publicUserId;
  final String phone;
  final String fullName;
  final String profilePhotoDataUri;
  final String profilePhotoObjectKey;
  final String gender;
  final DateTime? dob;
  final String languageCode;

  String get profilePhotoUrl => _UserAppApi.profilePhotoViewUrl(profilePhotoObjectKey);

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'userId': userId,
      'publicUserId': publicUserId,
      'phone': phone,
      'fullName': fullName,
      'profilePhotoDataUri': profilePhotoDataUri,
      'profilePhotoObjectKey': profilePhotoObjectKey,
      'gender': gender,
      'dob': dob?.toIso8601String(),
      'languageCode': languageCode,
    };
  }

  factory _UserProfileData.fromJson(Map<String, dynamic> json) {
    final rawDob = json['dob']?.toString().trim() ?? '';
    return _UserProfileData(
      userId: (json['userId'] as num?)?.toInt() ?? 0,
      publicUserId: json['publicUserId']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? 'MSA User',
      profilePhotoDataUri: json['profilePhotoDataUri']?.toString() ?? '',
      profilePhotoObjectKey: json['profilePhotoObjectKey']?.toString() ?? '',
      gender: json['gender']?.toString() ?? '',
      dob: rawDob.isEmpty ? null : DateTime.tryParse(rawDob),
      languageCode: json['languageCode']?.toString() ?? 'en',
    );
  }
}

class _UserAddressData {
  const _UserAddressData({
    required this.id,
    required this.label,
    required this.addressLine1,
    required this.addressLine2,
    required this.landmark,
    required this.city,
    required this.stateId,
    required this.state,
    required this.countryId,
    required this.country,
    required this.postalCode,
    required this.latitude,
    required this.longitude,
    required this.isDefault,
  });

  final int id;
  final String label;
  final String addressLine1;
  final String addressLine2;
  final String landmark;
  final String city;
  final int? stateId;
  final String state;
  final int? countryId;
  final String country;
  final String postalCode;
  final double latitude;
  final double longitude;
  final bool isDefault;

  String get fullAddress {
    final parts = <String>[
      addressLine1.trim(),
      if (addressLine2.trim().isNotEmpty) addressLine2.trim(),
    ];
    return parts.join(', ');
  }

  String get latitudeLabel => latitude.toStringAsFixed(6);
  String get longitudeLabel => longitude.toStringAsFixed(6);
}

class _UserAddressInput {
  const _UserAddressInput({
    required this.label,
    required this.addressLine1,
    required this.addressLine2,
    required this.landmark,
    required this.city,
    required this.stateId,
    required this.state,
    required this.countryId,
    required this.country,
    required this.postalCode,
    required this.latitude,
    required this.longitude,
    required this.isDefault,
  });

  final String label;
  final String addressLine1;
  final String addressLine2;
  final String landmark;
  final String city;
  final int? stateId;
  final String state;
  final int? countryId;
  final String country;
  final String postalCode;
  final double latitude;
  final double longitude;
  final bool isDefault;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'label': label,
      'addressLine1': addressLine1,
      'addressLine2': addressLine2.isEmpty ? null : addressLine2,
      'landmark': landmark.isEmpty ? null : landmark,
      'city': city,
      'stateId': stateId,
      'state': state,
      'countryId': countryId,
      'country': country,
      'postalCode': postalCode,
      'latitude': latitude,
      'longitude': longitude,
      'isDefault': isDefault,
    };
  }
}

class _ServiceCountryOption {
  const _ServiceCountryOption({
    required this.id,
    required this.name,
  });

  final int id;
  final String name;
}

class _ServiceStateOption {
  const _ServiceStateOption({
    required this.id,
    required this.countryId,
    required this.name,
  });

  final int id;
  final int countryId;
  final String name;
}

class _RemoteNotificationItem {
  const _RemoteNotificationItem({
    required this.id,
    required this.channel,
    required this.notificationType,
    required this.title,
    required this.body,
    required this.status,
    required this.payloadJson,
    required this.sentAt,
    required this.readAt,
    required this.createdAt,
  });

  final int id;
  final String channel;
  final String notificationType;
  final String title;
  final String body;
  final String status;
  final String payloadJson;
  final DateTime? sentAt;
  final DateTime? readAt;
  final DateTime? createdAt;

  bool get isRead => readAt != null;
}

class _UserOrderSummary {
  const _UserOrderSummary({
    required this.orderId,
    required this.orderCode,
    required this.shopId,
    required this.shopName,
    required this.primaryItemName,
    required this.primaryImageFileId,
    required this.itemCount,
    required this.orderStatus,
    required this.paymentStatus,
    required this.totalAmount,
    required this.currencyCode,
    required this.cancellable,
    required this.refundPresent,
    required this.latestRefundStatus,
    required this.createdAt,
    required this.updatedAt,
  });

  final int orderId;
  final String orderCode;
  final int shopId;
  final String shopName;
  final String primaryItemName;
  final String primaryImageFileId;
  final int itemCount;
  final String orderStatus;
  final String paymentStatus;
  final String totalAmount;
  final String currencyCode;
  final bool cancellable;
  final bool refundPresent;
  final String latestRefundStatus;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}

class _UserOrderDetail {
  const _UserOrderDetail({
    required this.orderId,
    required this.orderCode,
    required this.shopId,
    required this.shopName,
    required this.orderStatus,
    required this.paymentStatus,
    required this.paymentCode,
    required this.fulfillmentType,
    required this.addressLabel,
    required this.addressLine,
    required this.subtotalAmount,
    required this.deliveryFeeAmount,
    required this.platformFeeAmount,
    required this.totalAmount,
    required this.currencyCode,
    required this.cancellable,
    required this.createdAt,
    required this.updatedAt,
    required this.items,
    required this.timeline,
    required this.refund,
  });

  final int orderId;
  final String orderCode;
  final int shopId;
  final String shopName;
  final String orderStatus;
  final String paymentStatus;
  final String paymentCode;
  final String fulfillmentType;
  final String addressLabel;
  final String addressLine;
  final String subtotalAmount;
  final String deliveryFeeAmount;
  final String platformFeeAmount;
  final String totalAmount;
  final String currencyCode;
  final bool cancellable;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<_UserOrderItem> items;
  final List<_UserOrderTimelineEvent> timeline;
  final _UserOrderRefund? refund;

  bool get paymentRetryAllowed {
    final normalizedPayment = paymentStatus.trim().toUpperCase();
    final normalizedOrder = orderStatus.trim().toUpperCase();
    return paymentCode.trim().isNotEmpty &&
        (normalizedPayment == 'PENDING' ||
            normalizedPayment == 'FAILED' ||
            normalizedPayment == 'INITIATED') &&
        normalizedOrder != 'CANCELLED' &&
        normalizedOrder != 'DELIVERED';
  }
}

class _UserOrderItem {
  const _UserOrderItem({
    required this.orderItemId,
    required this.productId,
    required this.variantId,
    required this.productName,
    required this.variantName,
    required this.imageFileId,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
  });

  final int orderItemId;
  final int productId;
  final int? variantId;
  final String productName;
  final String variantName;
  final String imageFileId;
  final int quantity;
  final String unitPrice;
  final String lineTotal;
}

class _UserOrderTimelineEvent {
  const _UserOrderTimelineEvent({
    required this.oldStatus,
    required this.newStatus,
    required this.reason,
    required this.changedAt,
  });

  final String oldStatus;
  final String newStatus;
  final String reason;
  final DateTime? changedAt;
}

class _UserOrderRefund {
  const _UserOrderRefund({
    required this.refundCode,
    required this.refundStatus,
    required this.requestedAmount,
    required this.approvedAmount,
    required this.reason,
    required this.initiatedAt,
    required this.completedAt,
  });

  final String refundCode;
  final String refundStatus;
  final String requestedAmount;
  final String approvedAmount;
  final String reason;
  final DateTime? initiatedAt;
  final DateTime? completedAt;

  bool get hasApprovedAmount => approvedAmount.trim().isNotEmpty && approvedAmount.trim() != '₹0';
}

class _CheckoutPreviewData {
  const _CheckoutPreviewData({
    required this.addressId,
    required this.shopName,
    required this.addressLabel,
    required this.addressLine,
    required this.fulfillmentType,
    required this.itemCount,
    required this.subtotal,
    required this.deliveryFee,
    required this.platformFee,
    required this.totalAmount,
    required this.shopOpen,
    required this.closingSoon,
    required this.acceptsOrders,
    required this.canPlaceOrder,
    required this.issues,
  });

  final int? addressId;
  final String shopName;
  final String addressLabel;
  final String addressLine;
  final String fulfillmentType;
  final int itemCount;
  final String subtotal;
  final String deliveryFee;
  final String platformFee;
  final String totalAmount;
  final bool shopOpen;
  final bool closingSoon;
  final bool acceptsOrders;
  final bool canPlaceOrder;
  final List<String> issues;
}

class _PlacedOrderData {
  const _PlacedOrderData({
    required this.orderId,
    required this.orderCode,
    required this.paymentId,
    required this.paymentCode,
    required this.totalAmount,
    required this.currencyCode,
    required this.nextAction,
  });

  final int orderId;
  final String orderCode;
  final int paymentId;
  final String paymentCode;
  final String totalAmount;
  final String currencyCode;
  final String nextAction;
}

class _PaymentInitiationData {
  const _PaymentInitiationData({
    required this.paymentId,
    required this.paymentCode,
    required this.gatewayName,
    required this.gatewayOrderId,
    required this.gatewayKeyId,
    required this.amountValue,
    required this.amountLabel,
    required this.currencyCode,
    required this.paymentStatus,
  });

  final int paymentId;
  final String paymentCode;
  final String gatewayName;
  final String gatewayOrderId;
  final String gatewayKeyId;
  final double amountValue;
  final String amountLabel;
  final String currencyCode;
  final String paymentStatus;

  int get amountMinorUnits => (amountValue * 100).round();
}

class _PaymentStatusData {
  const _PaymentStatusData({
    required this.paymentId,
    required this.paymentCode,
    required this.payableType,
    required this.payableId,
    required this.paymentStatus,
    required this.amountLabel,
    required this.currencyCode,
    required this.gatewayName,
    required this.gatewayOrderId,
  });

  final int paymentId;
  final String paymentCode;
  final String payableType;
  final int payableId;
  final String paymentStatus;
  final String amountLabel;
  final String currencyCode;
  final String gatewayName;
  final String gatewayOrderId;

  bool get isSuccess => paymentStatus.toUpperCase() == 'SUCCESS';
}

class _RestaurantLandingData {
  const _RestaurantLandingData({
    required this.cuisines,
    required this.products,
    required this.shops,
  });

  final List<_RestaurantCuisineItem> cuisines;
  final List<_DiscoveryItem> products;
  final List<_RestaurantRemoteShopSummary> shops;
}

class _RestaurantRemoteShopSummary {
  const _RestaurantRemoteShopSummary({
    required this.shopId,
    required this.shopName,
    required this.city,
    required this.rating,
    required this.offer,
    required this.eta,
    required this.cuisineLine,
    required this.acceptsOrders,
  });

  final int shopId;
  final String shopName;
  final String city;
  final String rating;
  final String offer;
  final String eta;
  final String cuisineLine;
  final bool acceptsOrders;
}

class _RestaurantShopProfileData {
  const _RestaurantShopProfileData({
    required this.shopId,
    required this.shopName,
    required this.city,
    required this.rating,
    required this.closesAt,
    required this.openNow,
    required this.acceptsOrders,
    required this.cuisines,
    required this.products,
  });

  final int shopId;
  final String shopName;
  final String city;
  final String rating;
  final String closesAt;
  final bool openNow;
  final bool acceptsOrders;
  final List<_RestaurantCuisineItem> cuisines;
  final List<_DiscoveryItem> products;
}

class _FashionLandingData {
  const _FashionLandingData({
    required this.categories,
    required this.products,
    required this.shops,
  });

  final List<_FashionRemoteCategory> categories;
  final _FashionProductPage products;
  final List<_FashionRemoteShopSummary> shops;
}

class _FashionRemoteCategory {
  const _FashionRemoteCategory({
    required this.label,
    this.backendCategoryId,
  });

  final String label;
  final int? backendCategoryId;
}

class _FashionRemoteProduct {
  const _FashionRemoteProduct({
    required this.item,
    required this.oldPrice,
    required this.couponPrice,
    required this.discount,
    required this.votes,
    required this.promoted,
  });

  final _DiscoveryItem item;
  final String oldPrice;
  final String couponPrice;
  final String discount;
  final String votes;
  final bool promoted;
}

class _FashionProductPage {
  const _FashionProductPage({
    required this.items,
    required this.page,
    required this.hasMore,
  });

  final List<_FashionRemoteProduct> items;
  final int page;
  final bool hasMore;
}

class _FashionRemoteShopSummary {
  const _FashionRemoteShopSummary({
    required this.shopId,
    required this.shopName,
    required this.city,
    required this.rating,
    required this.openNow,
    required this.closingSoon,
    required this.acceptsOrders,
    required this.closesAt,
  });

  final int shopId;
  final String shopName;
  final String city;
  final String rating;
  final bool openNow;
  final bool closingSoon;
  final bool acceptsOrders;
  final String closesAt;
}

class _FashionShopProfileData {
  const _FashionShopProfileData({
    required this.shopId,
    required this.shopName,
    required this.city,
    required this.rating,
    required this.closesAt,
    required this.openNow,
    required this.acceptsOrders,
    required this.categories,
    required this.products,
  });

  final int shopId;
  final String shopName;
  final String city;
  final String rating;
  final String closesAt;
  final bool openNow;
  final bool acceptsOrders;
  final List<_FashionRemoteCategory> categories;
  final _FashionProductPage products;
}

class _FootwearLandingData {
  const _FootwearLandingData({
    required this.categories,
    required this.products,
    required this.shops,
  });

  final List<_FootwearRemoteCategory> categories;
  final _FootwearProductPage products;
  final List<_FootwearRemoteShopSummary> shops;
}

class _FootwearRemoteCategory {
  const _FootwearRemoteCategory({
    required this.label,
    this.backendCategoryId,
  });

  final String label;
  final int? backendCategoryId;
}

class _FootwearRemoteProduct {
  const _FootwearRemoteProduct({
    required this.item,
    required this.oldPrice,
    required this.couponPrice,
    required this.discount,
    required this.votes,
    required this.promoted,
  });

  final _DiscoveryItem item;
  final String oldPrice;
  final String couponPrice;
  final String discount;
  final String votes;
  final bool promoted;
}

class _FootwearProductPage {
  const _FootwearProductPage({
    required this.items,
    required this.page,
    required this.hasMore,
  });

  final List<_FootwearRemoteProduct> items;
  final int page;
  final bool hasMore;
}

class _FootwearRemoteShopSummary {
  const _FootwearRemoteShopSummary({
    required this.shopId,
    required this.shopName,
    required this.city,
    required this.rating,
    required this.openNow,
    required this.closingSoon,
    required this.acceptsOrders,
    required this.closesAt,
  });

  final int shopId;
  final String shopName;
  final String city;
  final String rating;
  final bool openNow;
  final bool closingSoon;
  final bool acceptsOrders;
  final String closesAt;
}

class _FootwearShopProfileData {
  const _FootwearShopProfileData({
    required this.shopId,
    required this.shopName,
    required this.city,
    required this.rating,
    required this.closesAt,
    required this.openNow,
    required this.acceptsOrders,
    required this.categories,
    required this.products,
  });

  final int shopId;
  final String shopName;
  final String city;
  final String rating;
  final String closesAt;
  final bool openNow;
  final bool acceptsOrders;
  final List<_FootwearRemoteCategory> categories;
  final _FootwearProductPage products;
}

class _GiftLandingData {
  const _GiftLandingData({
    required this.categories,
    required this.products,
    required this.shops,
  });

  final List<_GiftRemoteCategory> categories;
  final _GiftProductPage products;
  final List<_GiftRemoteShopSummary> shops;
}

class _GiftRemoteCategory {
  const _GiftRemoteCategory({
    required this.label,
    this.backendCategoryId,
  });

  final String label;
  final int? backendCategoryId;
}

class _GiftRemoteProduct {
  const _GiftRemoteProduct({
    required this.item,
    required this.categoryLabel,
  });

  final _DiscoveryItem item;
  final String categoryLabel;
}

class _GiftProductPage {
  const _GiftProductPage({
    required this.items,
    required this.page,
    required this.hasMore,
  });

  final List<_GiftRemoteProduct> items;
  final int page;
  final bool hasMore;
}

class _GiftRemoteShopSummary {
  const _GiftRemoteShopSummary({
    required this.shopId,
    required this.shopName,
    required this.city,
    required this.rating,
    required this.openNow,
    required this.closingSoon,
    required this.acceptsOrders,
    required this.closesAt,
  });

  final int shopId;
  final String shopName;
  final String city;
  final String rating;
  final bool openNow;
  final bool closingSoon;
  final bool acceptsOrders;
  final String closesAt;
}

class _GiftShopProfileData {
  const _GiftShopProfileData({
    required this.shopId,
    required this.shopName,
    required this.city,
    required this.rating,
    required this.closesAt,
    required this.openNow,
    required this.acceptsOrders,
    required this.categories,
    required this.products,
  });

  final int shopId;
  final String shopName;
  final String city;
  final String rating;
  final String closesAt;
  final bool openNow;
  final bool acceptsOrders;
  final List<_GiftRemoteCategory> categories;
  final _GiftProductPage products;
}

class _GroceryLandingData {
  const _GroceryLandingData({
    required this.categories,
    required this.products,
    required this.shops,
  });

  final List<_GroceryRemoteCategory> categories;
  final _GroceryProductPage products;
  final List<_GroceryRemoteShopSummary> shops;
}

class _GroceryRemoteCategory {
  const _GroceryRemoteCategory({
    required this.label,
    this.backendCategoryId,
  });

  final String label;
  final int? backendCategoryId;
}

class _GroceryRemoteProduct {
  const _GroceryRemoteProduct({
    required this.item,
    required this.categoryLabel,
  });

  final _DiscoveryItem item;
  final String categoryLabel;
}

class _GroceryProductPage {
  const _GroceryProductPage({
    required this.items,
    required this.page,
    required this.hasMore,
  });

  final List<_GroceryRemoteProduct> items;
  final int page;
  final bool hasMore;
}

class _GroceryRemoteShopSummary {
  const _GroceryRemoteShopSummary({
    required this.shopId,
    required this.shopName,
    required this.city,
    required this.rating,
    required this.openNow,
    required this.closingSoon,
    required this.acceptsOrders,
    required this.closesAt,
  });

  final int shopId;
  final String shopName;
  final String city;
  final String rating;
  final bool openNow;
  final bool closingSoon;
  final bool acceptsOrders;
  final String closesAt;
}

class _GroceryShopProfileData {
  const _GroceryShopProfileData({
    required this.shopId,
    required this.shopName,
    required this.city,
    required this.rating,
    required this.closesAt,
    required this.openNow,
    required this.acceptsOrders,
    required this.categories,
    required this.products,
  });

  final int shopId;
  final String shopName;
  final String city;
  final String rating;
  final String closesAt;
  final bool openNow;
  final bool acceptsOrders;
  final List<_GroceryRemoteCategory> categories;
  final _GroceryProductPage products;
}

class _PharmacyLandingData {
  const _PharmacyLandingData({
    required this.categories,
    required this.products,
    required this.shops,
  });

  final List<_PharmacyRemoteCategory> categories;
  final _PharmacyProductPage products;
  final List<_PharmacyRemoteShopSummary> shops;
}

class _PharmacyRemoteCategory {
  const _PharmacyRemoteCategory({
    required this.label,
    this.backendCategoryId,
  });

  final String label;
  final int? backendCategoryId;
}

class _PharmacyRemoteProduct {
  const _PharmacyRemoteProduct({
    required this.item,
    required this.categoryLabel,
  });

  final _DiscoveryItem item;
  final String categoryLabel;
}

class _PharmacyProductPage {
  const _PharmacyProductPage({
    required this.items,
    required this.page,
    required this.hasMore,
  });

  final List<_PharmacyRemoteProduct> items;
  final int page;
  final bool hasMore;
}

class _PharmacyRemoteShopSummary {
  const _PharmacyRemoteShopSummary({
    required this.shopId,
    required this.shopName,
    required this.city,
    required this.rating,
    required this.openNow,
    required this.closingSoon,
    required this.acceptsOrders,
    required this.closesAt,
  });

  final int shopId;
  final String shopName;
  final String city;
  final String rating;
  final bool openNow;
  final bool closingSoon;
  final bool acceptsOrders;
  final String closesAt;
}

class _PharmacyShopProfileData {
  const _PharmacyShopProfileData({
    required this.shopId,
    required this.shopName,
    required this.city,
    required this.rating,
    required this.closesAt,
    required this.openNow,
    required this.acceptsOrders,
    required this.categories,
    required this.products,
  });

  final int shopId;
  final String shopName;
  final String city;
  final String rating;
  final String closesAt;
  final bool openNow;
  final bool acceptsOrders;
  final List<_PharmacyRemoteCategory> categories;
  final _PharmacyProductPage products;
}

class _OtpDispatchResult {
  const _OtpDispatchResult({
    required this.requestId,
    required this.expiresInSeconds,
  });

  final String requestId;
  final int expiresInSeconds;
}

class _VerifiedUserSession {
  const _VerifiedUserSession({
    required this.accessToken,
    required this.refreshToken,
    required this.userId,
    required this.publicUserId,
  });

  final String accessToken;
  final String refreshToken;
  final int userId;
  final String publicUserId;
}

class _UserAppApiException implements Exception {
  const _UserAppApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class _UserSessionExpiredApiException extends _UserAppApiException {
  const _UserSessionExpiredApiException(super.message);
}

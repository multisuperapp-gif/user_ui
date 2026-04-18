part of '../../main.dart';

class _NotificationBootstrap {
  static Future<void>? _registrationFuture;
  static StreamSubscription<String>? _tokenRefreshSubscription;
  static StreamSubscription<RemoteMessage>? _foregroundMessageSubscription;
  static StreamSubscription<RemoteMessage>? _messageOpenedSubscription;
  static final StreamController<_NotificationEvent> _events = StreamController<_NotificationEvent>.broadcast();
  static _NotificationEvent? _pendingOpenEvent;

  static Stream<_NotificationEvent> get events => _events.stream;

  static _NotificationEvent? takePendingOpenEvent() {
    final event = _pendingOpenEvent;
    _pendingOpenEvent = null;
    return event;
  }

  static Future<void> ensureRegistered() {
    return _registrationFuture ??= _registerBestEffort();
  }

  static Future<void> deactivateCurrentToken() async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null || token.trim().isEmpty) {
        return;
      }
      await _UserAppApi.deactivatePushToken(token);
      await _UserAppApi.deactivateBookingPushToken(token);
    } catch (_) {
      // Ignore logout cleanup if Firebase is not configured on this build.
    }
  }

  static Future<void> _registerBestEffort() async {
    try {
      final userId = await _LocalSessionStore.readUserId();
      if (userId == null) {
        return;
      }
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }
      final messaging = FirebaseMessaging.instance;
      if (Platform.isIOS) {
        await messaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );
      }
      final token = await messaging.getToken();
      if (token == null || token.trim().isEmpty) {
        return;
      }
      final deviceToken = await _LocalSessionStore.ensureDeviceToken();
      await _UserAppApi.registerPushToken(
        pushToken: token,
        deviceToken: deviceToken,
        platform: _platform,
        pushProvider: 'FCM',
        appVersion: '1.0.0+1',
        osVersion: _compactOsVersion(),
      );
      await _UserAppApi.registerBookingPushToken(
        pushToken: token,
        deviceToken: deviceToken,
        platform: _platform,
        pushProvider: 'FCM',
      );
      await _ensureMessageListeners(messaging);
      _tokenRefreshSubscription ??= messaging.onTokenRefresh.listen((freshToken) {
        unawaited(_registerRefreshedToken(freshToken));
      });
    } catch (_) {
      // Firebase is not configured yet in this workspace, so skip silently.
    } finally {
      _registrationFuture = null;
    }
  }

  static String get _platform {
    if (Platform.isIOS) {
      return 'IOS';
    }
    if (Platform.isAndroid) {
      return 'ANDROID';
    }
    return 'WEB';
  }

  static String _compactOsVersion() {
    final version = Platform.operatingSystemVersion.trim().replaceAll('\n', ' ');
    if (version.length <= 50) {
      return version;
    }
    return version.substring(0, 50);
  }

  static Future<void> _registerRefreshedToken(String freshToken) async {
    final deviceToken = await _LocalSessionStore.ensureDeviceToken();
    await _UserAppApi.registerPushToken(
      pushToken: freshToken,
      deviceToken: deviceToken,
      platform: _platform,
      pushProvider: 'FCM',
      appVersion: '1.0.0+1',
      osVersion: _compactOsVersion(),
    );
    await _UserAppApi.registerBookingPushToken(
      pushToken: freshToken,
      deviceToken: deviceToken,
      platform: _platform,
      pushProvider: 'FCM',
    );
  }

  static Future<void> _ensureMessageListeners(FirebaseMessaging messaging) async {
    _foregroundMessageSubscription ??= FirebaseMessaging.onMessage.listen((message) {
      _events.add(_NotificationEvent.fromRemoteMessage(message, openedApp: false));
    });
    _messageOpenedSubscription ??= FirebaseMessaging.onMessageOpenedApp.listen((message) {
      final event = _NotificationEvent.fromRemoteMessage(message, openedApp: true);
      _pendingOpenEvent = event;
      _events.add(event);
    });

    final initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      final event = _NotificationEvent.fromRemoteMessage(initialMessage, openedApp: true);
      _pendingOpenEvent = event;
    }
  }
}

class _NotificationEvent {
  static const Set<String> _allowedUserBookingTypes = <String>{
    'BOOKING_ACCEPTED',
    'BOOKING_PAYMENT_SUCCESS',
    'BOOKING_WORK_STARTED',
    'BOOKING_COMPLETED',
    'BOOKING_CANCELLED',
  };

  const _NotificationEvent({
    required this.title,
    required this.body,
    required this.data,
    required this.openedApp,
  });

  final String title;
  final String body;
  final Map<String, String> data;
  final bool openedApp;

  factory _NotificationEvent.fromRemoteMessage(RemoteMessage message, {required bool openedApp}) {
    return _NotificationEvent(
      title: message.notification?.title?.trim() ?? '',
      body: message.notification?.body?.trim() ?? '',
      data: Map<String, String>.from(message.data),
      openedApp: openedApp,
    );
  }

  String get type => (data['type'] ?? '').trim().toUpperCase();

  bool get isOrderRelated =>
      data.containsKey('orderId') ||
      data.containsKey('orderCode') ||
      type.startsWith('SHOP_ORDER_');

  bool get isBookingRelated =>
      data.containsKey('bookingId') ||
      data.containsKey('bookingCode') ||
      data.containsKey('requestId') ||
      data.containsKey('requestCode') ||
      type.startsWith('BOOKING_');

  bool get isVisibleInUserApp {
    if (!isBookingRelated) {
      return true;
    }
    return _allowedUserBookingTypes.contains(type);
  }

  bool get hasVisibleContent => title.isNotEmpty || body.isNotEmpty;
}

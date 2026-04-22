part of '../../main.dart';

class _LocalSessionStore {
  static const _phoneKey = 'saved_phone_number';
  static const _userIdKey = 'saved_user_id';
  static const _accessTokenKey = 'saved_access_token';
  static const _refreshTokenKey = 'saved_refresh_token';
  static const _publicUserIdKey = 'saved_public_user_id';
  static const _deviceTokenKey = 'saved_device_token';
  static const _profileCacheKey = 'cached_user_profile';

  static Future<void> saveUserSession({
    required String phoneNumber,
    required int userId,
    String? accessToken,
    String? refreshToken,
    String? publicUserId,
  }) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_phoneKey, phoneNumber);
    await preferences.setInt(_userIdKey, userId);
    if (accessToken != null) {
      await preferences.setString(_accessTokenKey, accessToken);
    }
    if (refreshToken != null) {
      await preferences.setString(_refreshTokenKey, refreshToken);
    }
    if (publicUserId != null) {
      await preferences.setString(_publicUserIdKey, publicUserId);
    }
  }

  static Future<String?> readPhoneNumber() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_phoneKey);
  }

  static Future<int?> readUserId() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getInt(_userIdKey);
  }

  static Future<String?> readAccessToken() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_accessTokenKey);
  }

  static Future<String> ensureDeviceToken() async {
    final preferences = await SharedPreferences.getInstance();
    final existing = preferences.getString(_deviceTokenKey);
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }
    final created = 'msa-user-${Platform.operatingSystem}-${DateTime.now().microsecondsSinceEpoch}';
    await preferences.setString(_deviceTokenKey, created);
    return created;
  }

  static Future<void> saveProfileCache(String value) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_profileCacheKey, value);
  }

  static Future<String?> readProfileCache() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_profileCacheKey);
  }

  static Future<void> clear() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_phoneKey);
    await preferences.remove(_userIdKey);
    await preferences.remove(_accessTokenKey);
    await preferences.remove(_refreshTokenKey);
    await preferences.remove(_publicUserIdKey);
    await preferences.remove(_profileCacheKey);
  }
}

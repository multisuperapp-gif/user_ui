// ignore_for_file: unnecessary_library_name

library msa_user_app;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'features/core/session_store.dart';
part 'features/core/user_app_api.dart';
part 'features/core/notification_bootstrap.dart';
part 'features/payment/payment_flow.dart';
part 'features/shared/made_with_love_footer.dart';
part 'features/shared/scroll_to_top_button.dart';
part 'features/shared/async_state_widgets.dart';
part 'features/auth/auth_feature.dart';
part 'features/home/home_models.dart';
part 'features/home/home_page.dart';
part 'features/home/home_widgets.dart';
part 'features/home/home_timing_widgets.dart';
part 'features/home/home_header_widgets.dart';
part 'features/home/home_search_widgets.dart';
part 'features/home/home_quick_category_widgets.dart';
part 'features/home/home_discovery_section_widgets.dart';
part 'features/home/home_common_widgets.dart';
part 'features/profile/profile_page.dart';
part 'features/profile/addresses_page.dart';
part 'features/profile/notifications_page.dart';
part 'features/profile/orders_page.dart';
part 'features/detail/discovery_detail_page.dart';
part 'features/cart/cart_page.dart';

part 'features/labour/labour_feature.dart';
part 'features/labour/labour_remote_feature.dart';
part 'features/service/service_feature.dart';
part 'features/service/service_remote_feature.dart';
part 'features/shop/core/shop_core_feature.dart';
part 'features/shop/profile/shop_profile_feature.dart';
part 'features/shop/profile/shop_profile_menu_widgets.dart';
part 'features/shop/profile/shop_item_detail_page.dart';
part 'features/shop/profile/shop_menu_models.dart';
part 'features/shop/restaurant/restaurant_feature.dart';
part 'features/shop/restaurant/restaurant_remote_feature.dart';
part 'features/shop/fashion/fashion_feature.dart';
part 'features/shop/fashion/fashion_remote_feature.dart';
part 'features/shop/footwear/footwear_feature.dart';
part 'features/shop/footwear/footwear_remote_feature.dart';
part 'features/shop/footwear/footwear_filter_page.dart';
part 'features/shop/footwear/footwear_cards.dart';
part 'features/shop/footwear/footwear_item_detail_page.dart';
part 'features/shop/gift/gift_home_feature.dart';
part 'features/shop/gift/gift_remote_feature.dart';
part 'features/shop/grocery/grocery.dart';
part 'features/shop/grocery/grocery_remote_feature.dart';
part 'features/shop/grocery/grocery_profile_page.dart';
part 'features/shop/grocery/grocery_item_detail_page.dart';
part 'features/shop/grocery/grocery_widgets.dart';
part 'features/shop/grocery/grocery_data.dart';
part 'features/shop/gift/gift.dart';
part 'features/shop/gift/gift_profile_page.dart';
part 'features/shop/gift/gift_item_detail_page.dart';
part 'features/shop/gift/gift_widgets.dart';
part 'features/shop/gift/gift_data.dart';
part 'features/shop/pharmacy/pharmacy.dart';
part 'features/shop/pharmacy/pharmacy_remote_feature.dart';
part 'features/shop/pharmacy/pharmacy_profile_page.dart';
part 'features/shop/pharmacy/pharmacy_item_detail_page.dart';
part 'features/shop/pharmacy/pharmacy_widgets.dart';
part 'features/shop/pharmacy/pharmacy_data.dart';

void main() {
  runApp(const MsaUserApp());
}

const String _defaultMapLatitude = '22.7196';
const String _defaultMapLongitude = '75.8577';

String _formatMapCoordinate(double value) => value.toStringAsFixed(6);


class MsaUserApp extends StatelessWidget {
  const MsaUserApp({super.key});

  @override
  Widget build(BuildContext context) {
    const rose = Color(0xFFCB6E5B);
    const ivory = Color(0xFFF7F2EC);
    const ink = Color(0xFF18213A);

    return MaterialApp(
      title: 'MSA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: const ColorScheme.light(
          primary: rose,
          secondary: Color(0xFF7AA81E),
          surface: ivory,
        ),
        scaffoldBackgroundColor: ivory,
        useMaterial3: true,
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.w900,
            color: ink,
            letterSpacing: -1.4,
            height: 0.95,
          ),
          headlineMedium: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: -0.8,
            height: 1.02,
          ),
          titleLarge: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: ink,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF555555),
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF666666),
          ),
        ),
      ),
      home: const LaunchSplashPage(),
    );
  }
}

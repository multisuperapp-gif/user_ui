// ignore_for_file: unnecessary_library_name

library msa_user_app;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
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

Uint8List? _decodePhotoDataUriOrBase64(String rawValue) {
  final value = rawValue.trim();
  if (value.isEmpty) {
    return null;
  }
  final commaIndex = value.indexOf(',');
  final encoded = commaIndex >= 0 && commaIndex < value.length - 1
      ? value.substring(commaIndex + 1).trim()
      : value;
  if (encoded.isEmpty) {
    return null;
  }
  try {
    return base64Decode(encoded);
  } catch (_) {
    return null;
  }
}

Map<String, dynamic>? _decodeJwtPayload(String token) {
  final parts = token.trim().split('.');
  if (parts.length < 2) {
    return null;
  }
  try {
    final normalized = base64Url.normalize(parts[1]);
    final decoded = utf8.decode(base64Url.decode(normalized));
    final map = jsonDecode(decoded);
    return map is Map<String, dynamic> ? map : null;
  } catch (_) {
    return null;
  }
}

bool _isJwtExpired(String? token, {Duration clockSkew = const Duration(seconds: 30)}) {
  final trimmed = token?.trim() ?? '';
  if (trimmed.isEmpty) {
    return true;
  }
  final payload = _decodeJwtPayload(trimmed);
  final expSeconds = (payload?['exp'] as num?)?.toInt();
  if (expSeconds == null || expSeconds <= 0) {
    return false;
  }
  final expiry = DateTime.fromMillisecondsSinceEpoch(expSeconds * 1000, isUtc: true);
  return DateTime.now().toUtc().isAfter(expiry.subtract(clockSkew));
}

bool _looksLikeExpiredSessionMessage(String message) {
  final normalized = message.trim().toLowerCase();
  if (normalized.isEmpty) {
    return false;
  }
  return normalized.contains('session expired') ||
      normalized.contains('access token expired') ||
      normalized.contains('token expired') ||
      normalized.contains('jwt expired') ||
      normalized.contains('invalid token') ||
      normalized.contains('unauthorized') ||
      normalized.contains('login again');
}

void _ensureFieldVisibleAboveKeyboard(
  BuildContext context, {
  double alignment = 0.84,
}) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    Future<void>.delayed(const Duration(milliseconds: 110), () async {
      if (!context.mounted || Scrollable.maybeOf(context) == null) {
        return;
      }
      try {
        await Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          alignment: alignment,
          alignmentPolicy: ScrollPositionAlignmentPolicy.explicit,
        );
      } catch (_) {
        return;
      }
    });
  });
}

class _CroppedImageData {
  const _CroppedImageData({
    required this.bytes,
    required this.width,
    required this.height,
  });

  final Uint8List bytes;
  final int width;
  final int height;
}

class _CropMetrics {
  const _CropMetrics({
    required this.viewportWidth,
    required this.viewportHeight,
    required this.renderWidth,
    required this.renderHeight,
    required this.left,
    required this.top,
    required this.scale,
    required this.offset,
  });

  final double viewportWidth;
  final double viewportHeight;
  final double renderWidth;
  final double renderHeight;
  final double left;
  final double top;
  final double scale;
  final Offset offset;
}

Future<ui.Image> _decodeUiImage(Uint8List bytes) async {
  final codec = await ui.instantiateImageCodec(bytes);
  final frame = await codec.getNextFrame();
  return frame.image;
}

Offset _clampCropOffset({
  required Offset offset,
  required double renderWidth,
  required double renderHeight,
  required double viewportWidth,
  required double viewportHeight,
}) {
  final baseLeft = (viewportWidth - renderWidth) / 2;
  final baseTop = (viewportHeight - renderHeight) / 2;
  final minDx = math.min(baseLeft, -baseLeft);
  final maxDx = math.max(baseLeft, -baseLeft);
  final minDy = math.min(baseTop, -baseTop);
  final maxDy = math.max(baseTop, -baseTop);
  return Offset(
    offset.dx.clamp(minDx, maxDx),
    offset.dy.clamp(minDy, maxDy),
  );
}

_CropMetrics _buildCropMetrics({
  required double viewportWidth,
  required double viewportHeight,
  required int sourceWidth,
  required int sourceHeight,
  required double zoom,
  required Offset offset,
}) {
  final safeViewportWidth = viewportWidth <= 0 ? 1.0 : viewportWidth;
  final safeViewportHeight = viewportHeight <= 0 ? 1.0 : viewportHeight;
  final safeSourceWidth = sourceWidth <= 0 ? 1 : sourceWidth;
  final safeSourceHeight = sourceHeight <= 0 ? 1 : sourceHeight;
  final safeZoom = zoom <= 0 ? 1.0 : zoom;
  final baseScale = math.max(
    safeViewportWidth / safeSourceWidth,
    safeViewportHeight / safeSourceHeight,
  );
  final scale = baseScale * safeZoom;
  final renderWidth = safeSourceWidth * scale;
  final renderHeight = safeSourceHeight * scale;
  final clampedOffset = _clampCropOffset(
    offset: offset,
    renderWidth: renderWidth,
    renderHeight: renderHeight,
    viewportWidth: safeViewportWidth,
    viewportHeight: safeViewportHeight,
  );
  final left = (safeViewportWidth - renderWidth) / 2 + clampedOffset.dx;
  final top = (safeViewportHeight - renderHeight) / 2 + clampedOffset.dy;
  return _CropMetrics(
    viewportWidth: safeViewportWidth,
    viewportHeight: safeViewportHeight,
    renderWidth: renderWidth,
    renderHeight: renderHeight,
    left: left,
    top: top,
    scale: scale,
    offset: clampedOffset,
  );
}

Future<_CroppedImageData> _cropImageBytes({
  required ui.Image image,
  required _CropMetrics metrics,
}) async {
  final safeScale = metrics.scale <= 0 ? 1.0 : metrics.scale;
  final srcLeft = (-metrics.left / safeScale).clamp(0.0, image.width.toDouble());
  final srcTop = (-metrics.top / safeScale).clamp(0.0, image.height.toDouble());
  final srcWidth = (metrics.viewportWidth / safeScale).clamp(1.0, image.width - srcLeft);
  final srcHeight = (metrics.viewportHeight / safeScale).clamp(1.0, image.height - srcTop);

  final outputWidth = srcWidth.round();
  final outputHeight = srcHeight.round();
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  canvas.drawImageRect(
    image,
    Rect.fromLTWH(srcLeft, srcTop, srcWidth, srcHeight),
    Rect.fromLTWH(0, 0, outputWidth.toDouble(), outputHeight.toDouble()),
    Paint()..filterQuality = FilterQuality.high,
  );
  final picture = recorder.endRecording();
  final cropped = await picture.toImage(outputWidth, outputHeight);
  final byteData = await cropped.toByteData(format: ui.ImageByteFormat.png);
  return _CroppedImageData(
    bytes: byteData!.buffer.asUint8List(),
    width: outputWidth,
    height: outputHeight,
  );
}

Future<BitmapDescriptor> _buildScooterMapMarker({
  Color accentColor = const Color(0xFFCB6E5B),
  Color iconColor = Colors.white,
  IconData icon = Icons.electric_scooter_rounded,
}) async {
  try {
    final byteData = await rootBundle.load('assets/images/labour_scooter.png');
    final codec = await ui.instantiateImageCodec(
      byteData.buffer.asUint8List(),
      targetWidth: 96,
      targetHeight: 96,
    );
    final frame = await codec.getNextFrame();
    final pngBytes = await frame.image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.bytes(
      pngBytes!.buffer.asUint8List(),
      width: 32,
      height: 32,
    );
  } catch (_) {
    const double width = 96;
    const double bubbleDiameter = 72;
    const double tailHeight = 20;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final bubbleCenter = const Offset(width / 2, bubbleDiameter / 2);

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.16)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(bubbleCenter.translate(0, 6), bubbleDiameter / 2 - 4, shadowPaint);

    final tailPath = Path()
      ..moveTo(width / 2 - 10, bubbleDiameter - 6)
      ..lineTo(width / 2 + 10, bubbleDiameter - 6)
      ..lineTo(width / 2, bubbleDiameter + tailHeight)
      ..close();
    canvas.drawPath(tailPath, Paint()..color = accentColor);

    canvas.drawCircle(
      bubbleCenter,
      bubbleDiameter / 2,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      bubbleCenter,
      bubbleDiameter / 2 - 5,
      Paint()..color = accentColor,
    );

    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: String.fromCharCode(icon.codePoint),
      style: TextStyle(
        fontSize: 34,
        fontFamily: icon.fontFamily,
        package: icon.fontPackage,
        color: iconColor,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        bubbleCenter.dx - textPainter.width / 2,
        bubbleCenter.dy - textPainter.height / 2,
      ),
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(width.toInt(), (bubbleDiameter + tailHeight).toInt());
    final fallbackBytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.bytes(
      fallbackBytes!.buffer.asUint8List(),
      width: width,
      height: bubbleDiameter + tailHeight,
    );
  }
}

double _normalizeMapRotation(double degrees) {
  final normalized = degrees % 360;
  return normalized < 0 ? normalized + 360 : normalized;
}

double _bearingBetweenLatLng(LatLng from, LatLng to) {
  final fromLat = from.latitude * math.pi / 180.0;
  final toLat = to.latitude * math.pi / 180.0;
  final deltaLng = (to.longitude - from.longitude) * math.pi / 180.0;
  final y = math.sin(deltaLng) * math.cos(toLat);
  final x = math.cos(fromLat) * math.sin(toLat) -
      math.sin(fromLat) * math.cos(toLat) * math.cos(deltaLng);
  final bearing = math.atan2(y, x) * 180.0 / math.pi;
  return _normalizeMapRotation(bearing);
}

double _scooterMarkerRotationDegrees(LatLng from, LatLng to) {
  // The scooter asset faces right/east by default, so shift map bearing by 90 deg.
  return _normalizeMapRotation(_bearingBetweenLatLng(from, to) - 90.0);
}

Future<_CroppedImageData?> _openSquareCropperDialog(
  BuildContext context, {
  required Uint8List bytes,
  required String title,
  Color accentColor = const Color(0xFFCB6E5B),
}) async {
  final decodedImage = await _decodeUiImage(bytes);
  if (!context.mounted) {
    decodedImage.dispose();
    return null;
  }

  try {
    return await showDialog<_CroppedImageData>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        double zoom = 1;
        Offset offset = Offset.zero;
        bool isCropping = false;
        String? cropError;
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final screenSize = MediaQuery.sizeOf(context);
                  final maxDialogWidth = constraints.maxWidth.isFinite
                      ? constraints.maxWidth - 28
                      : screenSize.width - 64;
                  final viewportSize = math.min(math.max(220.0, maxDialogWidth), 320.0);
                  final metrics = _buildCropMetrics(
                    viewportWidth: viewportSize,
                    viewportHeight: viewportSize,
                    sourceWidth: decodedImage.width,
                    sourceHeight: decodedImage.height,
                    zoom: zoom,
                    offset: offset,
                  );
                  offset = metrics.offset;

                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Crop profile photo',
                            style: TextStyle(
                              color: Color(0xFF22314D),
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Move and zoom the image to crop $title.',
                            style: const TextStyle(
                              color: Color(0xFF66748C),
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              height: 1.45,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Center(
                            child: GestureDetector(
                              onPanUpdate: (details) {
                                setState(() {
                                  offset = _clampCropOffset(
                                    offset: offset + details.delta,
                                    renderWidth: metrics.renderWidth,
                                    renderHeight: metrics.renderHeight,
                                    viewportWidth: viewportSize,
                                    viewportHeight: viewportSize,
                                  );
                                });
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  width: viewportSize,
                                  height: viewportSize,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF3F5F9),
                                    border: Border.all(
                                      color: accentColor.withValues(alpha: 0.35),
                                      width: 2,
                                    ),
                                  ),
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        left: metrics.left,
                                        top: metrics.top,
                                        width: metrics.renderWidth,
                                        height: metrics.renderHeight,
                                        child: RawImage(
                                          image: decodedImage,
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Icon(Icons.zoom_in_rounded, size: 18, color: accentColor),
                              Expanded(
                                child: Slider(
                                  value: zoom,
                                  min: 1,
                                  max: 3,
                                  activeColor: accentColor,
                                  onChanged: (value) {
                                    setState(() {
                                      zoom = value;
                                      offset = _clampCropOffset(
                                        offset: offset,
                                        renderWidth: decodedImage.width *
                                            math.max(viewportSize / decodedImage.width, viewportSize / decodedImage.height) *
                                            zoom,
                                        renderHeight: decodedImage.height *
                                            math.max(viewportSize / decodedImage.width, viewportSize / decodedImage.height) *
                                            zoom,
                                        viewportWidth: viewportSize,
                                        viewportHeight: viewportSize,
                                      );
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          if (cropError != null) ...[
                            const SizedBox(height: 6),
                            Text(
                              cropError!,
                              style: const TextStyle(
                                color: Color(0xFFD63D5C),
                                fontWeight: FontWeight.w700,
                                fontSize: 12.5,
                              ),
                            ),
                          ],
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () => Navigator.of(dialogContext).pop(),
                                child: const Text('Cancel'),
                              ),
                              const SizedBox(width: 8),
                              FilledButton(
                                onPressed: isCropping
                                    ? null
                                    : () async {
                                        setState(() {
                                          isCropping = true;
                                          cropError = null;
                                        });
                                        try {
                                          final cropped = await _cropImageBytes(
                                            image: decodedImage,
                                            metrics: metrics,
                                          );
                                          if (!dialogContext.mounted) {
                                            return;
                                          }
                                          Navigator.of(dialogContext).pop(cropped);
                                        } catch (_) {
                                          if (!dialogContext.mounted) {
                                            return;
                                          }
                                          setState(() {
                                            isCropping = false;
                                            cropError = 'Unable to crop this image. Try another JPG or PNG photo.';
                                          });
                                        }
                                      },
                                child: Text(isCropping ? 'Cropping...' : 'Use crop'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  } finally {
    decodedImage.dispose();
  }
}


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
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFFFFF4F0),
          contentTextStyle: const TextStyle(
            color: ink,
            fontWeight: FontWeight.w700,
            fontSize: 13.5,
            height: 1.35,
          ),
          actionTextColor: rose,
          disabledActionTextColor: const Color(0xFFC89E93),
          elevation: 0,
          insetPadding: const EdgeInsets.fromLTRB(20, 0, 20, 260),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(
              color: Color(0xFFF0C7BD),
              width: 1.2,
            ),
          ),
        ),
      ),
      home: const LaunchSplashPage(),
    );
  }
}

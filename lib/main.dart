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
import 'package:url_launcher/url_launcher.dart';

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
}) async {
  const double width = 56;
  const double height = 42;
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final double sx = width / 800;
  final double sy = height / 500;

  Offset pt(double x, double y) => Offset(x * sx, y * sy);

  final averageScale = (sx + sy) / 2;
  final bodyPaint = Paint()
    ..color = accentColor
    ..style = PaintingStyle.fill;
  final brightBodyPaint = Paint()
    ..color = const Color(0xFFFF7447)
    ..style = PaintingStyle.fill;
  final framePaint = Paint()
    ..color = const Color(0xFF333333)
    ..style = PaintingStyle.fill;
  final wheelFillPaint = Paint()
    ..color = const Color(0xFFE0E0E0)
    ..style = PaintingStyle.fill;
  final wheelStrokePaint = Paint()
    ..color = const Color(0xFF222222)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 18 * averageScale;
  final hubPaint = Paint()
    ..color = const Color(0xFF555555)
    ..style = PaintingStyle.fill;
  final archPaint = Paint()
    ..color = accentColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = 12 * averageScale
    ..strokeCap = StrokeCap.round;
  final trimPaint = Paint()
    ..color = const Color(0xFF111111)
    ..style = PaintingStyle.fill;
  final forkPaint = Paint()
    ..color = const Color(0xFFCCCCCC)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 10 * averageScale
    ..strokeCap = StrokeCap.round;
  final shadowPaint = Paint()
    ..color = Colors.black.withValues(alpha: 0.16)
    ..style = PaintingStyle.fill;
  final skinPaint = Paint()
    ..color = const Color(0xFFF4C2C2)
    ..style = PaintingStyle.fill;
  final lampPaint = Paint()
    ..color = const Color(0xFFFFDB58)
    ..style = PaintingStyle.fill;
  final beamPaint = Paint()
    ..color = Colors.white.withValues(alpha: 0.22)
    ..style = PaintingStyle.fill;

  void drawWheel(double cx, double cy) {
    final center = pt(cx, cy);
    final radius = 50 * averageScale;
    canvas.drawCircle(center.translate(0, 4 * sy), radius * 0.96, shadowPaint);
    canvas.drawCircle(center, radius, wheelFillPaint);
    canvas.drawCircle(center, radius, wheelStrokePaint);
    canvas.drawCircle(center, 12 * averageScale, hubPaint);
  }

  drawWheel(250, 380);
  drawWheel(550, 380);

  final rearArch = Path()
    ..moveTo(pt(190, 380).dx, pt(190, 380).dy)
    ..arcToPoint(pt(310, 380), radius: Radius.circular(60 * averageScale), clockwise: false);
  final frontArch = Path()
    ..moveTo(pt(490, 380).dx, pt(490, 380).dy)
    ..arcToPoint(pt(610, 380), radius: Radius.circular(60 * averageScale), clockwise: false);
  canvas.drawPath(rearArch, archPaint);
  canvas.drawPath(frontArch, archPaint);

  final rearBody = Path()
    ..moveTo(pt(220, 380).dx, pt(220, 380).dy)
    ..quadraticBezierTo(pt(220, 280).dx, pt(220, 280).dy, pt(280, 280).dx, pt(280, 280).dy)
    ..lineTo(pt(400, 280).dx, pt(400, 280).dy)
    ..lineTo(pt(450, 380).dx, pt(450, 380).dy)
    ..close();
  canvas.drawShadow(rearBody, Colors.black.withValues(alpha: 0.18), 5 * averageScale, false);
  canvas.drawPath(rearBody, bodyPaint);
  canvas.drawRect(Rect.fromLTRB(pt(250, 350).dx, pt(250, 350).dy, pt(350, 380).dx, pt(350, 380).dy), framePaint);
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTRB(pt(360, 360).dx, pt(360, 360).dy, pt(500, 375).dx, pt(500, 375).dy),
      Radius.circular(5 * averageScale),
    ),
    Paint()..color = const Color(0xFF222222),
  );

  final frontBody = Path()
    ..moveTo(pt(480, 380).dx, pt(480, 380).dy)
    ..lineTo(pt(520, 230).dx, pt(520, 230).dy)
    ..lineTo(pt(560, 230).dx, pt(560, 230).dy)
    ..lineTo(pt(580, 380).dx, pt(580, 380).dy)
    ..close();
  canvas.drawPath(frontBody, bodyPaint);

  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTRB(pt(250, 270).dx, pt(250, 270).dy, pt(370, 295).dx, pt(370, 295).dy),
      Radius.circular(10 * averageScale),
    ),
    trimPaint,
  );

  final backBoxRect = Rect.fromLTRB(pt(130, 140).dx, pt(130, 140).dy, pt(250, 270).dx, pt(250, 270).dy);
  canvas.drawShadow(
    Path()..addRRect(RRect.fromRectAndRadius(backBoxRect, Radius.circular(10 * averageScale))),
    Colors.black.withValues(alpha: 0.16),
    4 * averageScale,
    false,
  );
  canvas.drawRRect(
    RRect.fromRectAndRadius(backBoxRect, Radius.circular(10 * averageScale)),
    brightBodyPaint,
  );
  canvas.drawRRect(
    RRect.fromRectAndRadius(backBoxRect, Radius.circular(10 * averageScale)),
    Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5 * averageScale,
  );

  if (iconColor.a > 0) {
    final markPaint = Paint()
      ..color = iconColor
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(pt(150, 184).dx, pt(150, 184).dy, pt(191, 194).dx, pt(191, 194).dy),
        Radius.circular(3 * averageScale),
      ),
      markPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(pt(170, 200).dx, pt(170, 200).dy, pt(210, 210).dx, pt(210, 210).dy),
        Radius.circular(3 * averageScale),
      ),
      markPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(pt(186, 216).dx, pt(186, 216).dy, pt(226, 226).dx, pt(226, 226).dy),
        Radius.circular(3 * averageScale),
      ),
      markPaint,
    );
  }

  canvas.drawRect(Rect.fromLTRB(pt(150, 270).dx, pt(150, 270).dy, pt(230, 285).dx, pt(230, 285).dy), framePaint);
  canvas.drawLine(
    pt(250, 200),
    pt(310, 200),
    Paint()
      ..color = const Color(0xFF222222)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4 * averageScale
      ..strokeCap = StrokeCap.round,
  );

  final deckPath = Path()
    ..moveTo(pt(320, 270).dx, pt(320, 270).dy)
    ..lineTo(pt(420, 270).dx, pt(420, 270).dy)
    ..lineTo(pt(450, 350).dx, pt(450, 350).dy)
    ..lineTo(pt(410, 350).dx, pt(410, 350).dy)
    ..lineTo(pt(370, 290).dx, pt(370, 290).dy)
    ..close();
  canvas.drawPath(deckPath, framePaint);
  canvas.drawOval(Rect.fromCenter(center: pt(435, 355), width: 50 * sx, height: 24 * sy), trimPaint);

  final riderTorso = Path()
    ..moveTo(pt(290, 270).dx, pt(290, 270).dy)
    ..lineTo(pt(330, 140).dx, pt(330, 140).dy)
    ..lineTo(pt(420, 160).dx, pt(420, 160).dy)
    ..lineTo(pt(370, 270).dx, pt(370, 270).dy)
    ..close();
  canvas.drawPath(riderTorso, bodyPaint);

  final riderLeg = Path()
    ..moveTo(pt(290, 270).dx, pt(290, 270).dy)
    ..lineTo(pt(330, 140).dx, pt(330, 140).dy)
    ..lineTo(pt(360, 145).dx, pt(360, 145).dy)
    ..lineTo(pt(340, 270).dx, pt(340, 270).dy)
    ..close();
  canvas.drawPath(riderLeg, brightBodyPaint);
  canvas.drawRect(Rect.fromLTRB(pt(360, 125).dx, pt(360, 125).dy, pt(385, 145).dx, pt(385, 145).dy), skinPaint);

  final headPath = Path()
    ..moveTo(pt(330, 130).dx, pt(330, 130).dy)
    ..cubicTo(pt(330, 60).dx, pt(330, 60).dy, pt(420, 70).dx, pt(420, 70).dy, pt(410, 130).dx, pt(410, 130).dy)
    ..close();
  final helmetPath = Path()
    ..moveTo(pt(375, 100).dx, pt(375, 100).dy)
    ..cubicTo(pt(375, 100).dx, pt(375, 100).dy, pt(425, 100).dx, pt(425, 100).dy, pt(415, 130).dx, pt(415, 130).dy)
    ..lineTo(pt(375, 130).dx, pt(375, 130).dy)
    ..quadraticBezierTo(pt(365, 130).dx, pt(365, 130).dy, pt(375, 100).dx, pt(375, 100).dy)
    ..close();
  canvas.drawPath(headPath, bodyPaint);
  canvas.drawPath(helmetPath, trimPaint);

  canvas.drawPath(
    Path()
      ..moveTo(pt(370, 160).dx, pt(370, 160).dy)
      ..lineTo(pt(460, 210).dx, pt(460, 210).dy)
      ..lineTo(pt(490, 200).dx, pt(490, 200).dy),
    Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 24 * averageScale
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.drawCircle(pt(495, 195), 12 * averageScale, skinPaint);

  canvas.drawLine(pt(540, 230), pt(500, 190), forkPaint);
  canvas.drawLine(
    pt(510, 200),
    pt(480, 190),
    Paint()
      ..color = const Color(0xFF111111)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14 * averageScale
      ..strokeCap = StrokeCap.round,
  );

  canvas.drawCircle(pt(560, 230), 15 * averageScale, lampPaint);
  final beamPath = Path()
    ..moveTo(pt(570, 230).dx, pt(570, 230).dy)
    ..lineTo(pt(650, 190).dx, pt(650, 190).dy)
    ..lineTo(pt(650, 270).dx, pt(650, 270).dy)
    ..close();
  canvas.drawPath(beamPath, beamPaint);

  final picture = recorder.endRecording();
  final image = await picture.toImage(width.toInt(), height.toInt());
  final markerBytes = await image.toByteData(format: ui.ImageByteFormat.png);
  return BitmapDescriptor.bytes(
    markerBytes!.buffer.asUint8List(),
    width: width,
    height: height,
  );
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

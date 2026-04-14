part of '../../../main.dart';

class _ShopMenuSection {
  const _ShopMenuSection({
    required this.title,
    required this.items,
  });

  final String title;
  final List<_DiscoveryItem> items;
}

class _ShopMenuSectionHeader extends StatelessWidget {
  const _ShopMenuSectionHeader({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 6),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF202A3E),
          fontSize: 15.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _ShopMenuOverlayEntry {
  const _ShopMenuOverlayEntry({
    required this.title,
    required this.count,
    required this.key,
    this.highlighted = false,
    this.items = const [],
  });

  final String title;
  final int count;
  final GlobalKey key;
  final bool highlighted;
  final List<_DiscoveryItem> items;
}

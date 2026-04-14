part of '../../main.dart';

class _ShopTimingState {
  const _ShopTimingState({
    required this.isOpen,
    required this.acceptsOrders,
    required this.isClosingSoon,
    required this.minutesUntilClose,
    required this.closeLabel,
  });

  final bool isOpen;
  final bool acceptsOrders;
  final bool isClosingSoon;
  final int minutesUntilClose;
  final String closeLabel;

  bool get shouldHighlight => !acceptsOrders || isClosingSoon;

  String get message {
    if (!isOpen) {
      return 'Closed now';
    }
    if (!acceptsOrders) {
      return 'Orders closed · closes at $closeLabel';
    }
    if (isClosingSoon) {
      return 'Closing soon · closes at $closeLabel';
    }
    return 'Open now · closes at $closeLabel';
  }

  Color get accent {
    if (!isOpen || !acceptsOrders) {
      return const Color(0xFFD8483A);
    }
    if (isClosingSoon) {
      return const Color(0xFFD98B1D);
    }
    return const Color(0xFF2C9D59);
  }

  Color get background {
    if (!isOpen || !acceptsOrders) {
      return const Color(0xFFFFECE8);
    }
    if (isClosingSoon) {
      return const Color(0xFFFFF3DE);
    }
    return const Color(0xFFE8F8ED);
  }
}

String _formatShopClock(int totalMinutes) {
  final normalized = ((totalMinutes % (24 * 60)) + (24 * 60)) % (24 * 60);
  final hour24 = normalized ~/ 60;
  final minute = normalized % 60;
  final suffix = hour24 >= 12 ? 'PM' : 'AM';
  final hour12 = switch (hour24 % 12) {
    0 => 12,
    final value => value,
  };
  final minuteText = minute.toString().padLeft(2, '0');
  return '$hour12:$minuteText $suffix';
}

(int, int) _shopOperatingHours(String shopName, String category) {
  final normalizedCategory = category.trim();
  final base = switch (normalizedCategory) {
    'Restaurant' => (9 * 60, 23 * 60),
    'Gift' => (8 * 60, 21 * 60),
    'Pharmacy' => (8 * 60, 22 * 60),
    'Groceries' => (7 * 60, 22 * 60),
    'Fashion' => (10 * 60, 21 * 60),
    'Footwear' => (10 * 60, 21 * 60),
    _ => (9 * 60, 21 * 60),
  };
  final seed = shopName.trim().toLowerCase().codeUnits.fold<int>(0, (sum, value) => sum + value);
  final openOffset = (seed % 3) * 15;
  final closeOffset = (seed % 4) * 15;
  final openMinutes = base.$1 + openOffset;
  final closeMinutes = (base.$2 - closeOffset).clamp(openMinutes + 180, 23 * 60 + 30);
  return (openMinutes, closeMinutes);
}

_ShopTimingState _shopTimingFor(String shopName, String category, {DateTime? now}) {
  final current = now ?? DateTime.now();
  final currentMinutes = current.hour * 60 + current.minute;
  final hours = _shopOperatingHours(shopName, category);
  final isOpen = currentMinutes >= hours.$1 && currentMinutes < hours.$2;
  final minutesUntilClose = isOpen ? hours.$2 - currentMinutes : -1;
  final acceptsOrders = isOpen && minutesUntilClose > 30;
  final isClosingSoon = isOpen && minutesUntilClose <= 60;
  return _ShopTimingState(
    isOpen: isOpen,
    acceptsOrders: acceptsOrders,
    isClosingSoon: isClosingSoon,
    minutesUntilClose: minutesUntilClose,
    closeLabel: _formatShopClock(hours.$2),
  );
}

class _ShopTimingPill extends StatelessWidget {
  const _ShopTimingPill({required this.state});

  final _ShopTimingState state;

  @override
  Widget build(BuildContext context) {
    final icon = !state.isOpen || !state.acceptsOrders
        ? Icons.lock_clock_rounded
        : Icons.schedule_rounded;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: state.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: state.accent),
          const SizedBox(width: 6),
          Text(
            state.message,
            style: TextStyle(
              color: state.accent,
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

bool _isShopItemOutOfStock(_DiscoveryItem item) {
  final normalized = item.title
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  const soldOutTitles = <String>{
    'cooking oil',
    'atta pack',
    'face wash',
    'cotton roll',
    'garden of eden',
    'classic handbag',
    'formal trouser',
    'sneakers',
    'soft toy combo',
    'gift combo',
  };
  return soldOutTitles.contains(normalized);
}

class _OutOfStockBadge extends StatelessWidget {
  const _OutOfStockBadge({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 7 : 9,
        vertical: compact ? 4 : 5,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFD8483A).withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD8483A).withValues(alpha: 0.22),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        'Out of stock',
        style: TextStyle(
          color: Colors.white,
          fontSize: compact ? 9.4 : 10.4,
          fontWeight: FontWeight.w900,
          height: 1,
        ),
      ),
    );
  }
}

part of '../../main.dart';

class _DiscoveryDetailPage extends StatefulWidget {
  const _DiscoveryDetailPage({
    required this.item,
    required this.mode,
    required this.isWishlisted,
    required this.isFavourited,
    required this.onWishlistToggle,
    required this.onFavouriteToggle,
    required this.onPrimaryAction,
  });

  final _DiscoveryItem item;
  final _HomeMode mode;
  final bool isWishlisted;
  final bool isFavourited;
  final VoidCallback onWishlistToggle;
  final VoidCallback onFavouriteToggle;
  final Future<void> Function(String? labourBookingPeriod) onPrimaryAction;

  @override
  State<_DiscoveryDetailPage> createState() => _DiscoveryDetailPageState();
}

class _DiscoveryDetailPageState extends State<_DiscoveryDetailPage> {
  String? _selectedLabourBookingPeriod;

  String get _primaryAction {
    switch (widget.mode) {
      case _HomeMode.labour:
        return 'Book labour';
      case _HomeMode.service:
        return 'Pay visiting charge';
      case _HomeMode.shop:
        return 'Add item to cart';
      case _HomeMode.all:
        return 'Continue';
    }
  }

  String get _description {
    switch (widget.mode) {
      case _HomeMode.labour:
        return 'Full mobile number will be visible only after the labour is booked and payment is completed.';
      case _HomeMode.service:
        return 'Book after checking category, rating, visit charge and service range. If provider does not reach in time, visiting charge can be refunded.';
      case _HomeMode.shop:
        return 'Add items from the same shop in one cart. If you try a different shop, the app will warn before replacing the cart.';
      case _HomeMode.all:
        return 'Open the profile and continue with booking, service or shopping based on the selected category.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final mode = widget.mode;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F2EC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          item.title,
          style: const TextStyle(color: Color(0xFF22314D), fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            onPressed: mode == _HomeMode.shop ? widget.onWishlistToggle : widget.onFavouriteToggle,
            icon: Icon(
              mode == _HomeMode.shop
                  ? (widget.isWishlisted ? Icons.bookmark_rounded : Icons.bookmark_border_rounded)
                  : (widget.isFavourited ? Icons.favorite_rounded : Icons.favorite_border_rounded),
              color: mode == _HomeMode.shop
                  ? const Color(0xFF4DAF50)
                  : const Color(0xFFCB6E5B),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 32),
        children: [
          Container(
            height: mode == _HomeMode.labour ? 176 : 240,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  item.accent.withValues(alpha: 0.18),
                  item.accent.withValues(alpha: 0.6),
                ],
              ),
              borderRadius: BorderRadius.circular(28),
            ),
            clipBehavior: Clip.antiAlias,
            child: mode == _HomeMode.labour
                ? Center(
                    child: AspectRatio(
                      aspectRatio: 0.72,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          _LabourPortraitImage(
                            item: item,
                            fit: BoxFit.cover,
                            scale: 1,
                            alignment: Alignment.topCenter,
                          ),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.05),
                                  Colors.black.withValues(alpha: 0.44),
                                ],
                                stops: const [0.48, 0.72, 1],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Center(
                    child: Icon(item.icon, size: 88, color: Colors.white),
                  ),
            ),
          const SizedBox(height: 20),
          Text(
            item.title,
            style: TextStyle(
              color: const Color(0xFF22314D),
              fontSize: mode == _HomeMode.labour ? 24 : 28,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: mode == _HomeMode.labour ? 5 : 8),
          Text(
            item.subtitle,
            style: TextStyle(
              color: const Color(0xFF6D7A91),
              fontWeight: FontWeight.w700,
              fontSize: mode == _HomeMode.labour ? 14 : 16,
            ),
          ),
          SizedBox(height: mode == _HomeMode.labour ? 10 : 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _MetaPill(icon: Icons.star_rounded, value: item.rating, color: _ratingColor(item.rating)),
              _MetaPill(icon: Icons.place_rounded, value: item.distance, color: const Color(0xFF5C8FD8)),
              if (item.price.isNotEmpty && mode != _HomeMode.labour)
                _MetaPill(icon: Icons.currency_rupee_rounded, value: item.price, color: item.accent),
            ],
          ),
          if (mode == _HomeMode.labour) ...[
            const SizedBox(height: 10),
            _labourBookingPeriodSelector(),
          ],
          SizedBox(height: mode == _HomeMode.labour ? 12 : 18),
          Container(
            padding: EdgeInsets.all(mode == _HomeMode.labour ? 12 : 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Profile details',
                  style: TextStyle(
                    color: Color(0xFF22314D),
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: mode == _HomeMode.labour ? 9 : 12),
                if (mode != _HomeMode.labour) _detailRow('Name', item.title),
                if (mode != _HomeMode.labour && mode != _HomeMode.service) ...[
                  _detailRow('Rating', item.rating),
                  _detailRow('Distance', item.distance),
                  _detailRow('Price', item.price.isEmpty ? 'As per profile' : item.price),
                ],
                _detailRow('Experience', '5+ years'),
                _detailRow('Booking success', item.extra.isEmpty ? '124 successful' : item.extra),
                _detailRow(mode == _HomeMode.labour ? 'Masked mobile no.' : 'Mobile no.', item.maskedPhone),
              ],
            ),
          ),
          if (mode == _HomeMode.shop) ...[
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cart and delivery notes',
                    style: TextStyle(
                      color: Color(0xFF22314D),
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _detailRow('Cart rule', 'Same shop only'),
                  _detailRow('Delivery', 'Based on shop threshold'),
                  _detailRow('Platform fee', 'Added at checkout'),
                  _detailRow('Cancellation', 'Allowed before out for delivery'),
                ],
              ),
            ),
          ],
          if (mode != _HomeMode.labour && mode != _HomeMode.service) ...[
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                _description,
                style: const TextStyle(
                  color: Color(0xFF66748C),
                  height: 1.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
          SizedBox(height: mode == _HomeMode.labour || mode == _HomeMode.service ? 12 : 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                if (mode == _HomeMode.labour && _selectedLabourBookingPeriod == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select Half Day or Full Day to book labour.')),
                  );
                  return;
                }
                await widget.onPrimaryAction(_selectedLabourBookingPeriod);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFCB6E5B),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  vertical: mode == _HomeMode.labour || mode == _HomeMode.service ? 14 : 18,
                ),
                shape: const RoundedRectangleBorder(),
              ),
              child: Text(
                mode != _HomeMode.labour || _selectedLabourBookingPeriod == null
                    ? _primaryAction
                    : 'Book $_selectedLabourBookingPeriod labour',
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
              ),
            ),
          ),
          if (mode == _HomeMode.labour || mode == _HomeMode.service) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                _description,
                style: const TextStyle(
                  color: Color(0xFF66748C),
                  height: 1.35,
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                ),
              ),
            ),
          ],
          const SizedBox(height: 26),
          const _MadeWithLoveFooter(),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF7A879B),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF22314D),
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _labourBookingPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEED8CF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select booking duration',
            style: TextStyle(
              color: Color(0xFF22314D),
              fontSize: 13,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              _labourBookingPeriodOption(
                label: 'Half Day',
                value: _halfDayRate(widget.item.price),
                icon: Icons.wb_twilight_rounded,
                color: const Color(0xFFF2A13D),
              ),
              const SizedBox(width: 10),
              _labourBookingPeriodOption(
                label: 'Full Day',
                value: _fullDayRate(widget.item.price),
                icon: Icons.wb_sunny_rounded,
                color: const Color(0xFFCB6E5B),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _labourBookingPeriodOption({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final selected = _selectedLabourBookingPeriod == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedLabourBookingPeriod = label),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          decoration: BoxDecoration(
            color: selected ? color.withValues(alpha: 0.16) : const Color(0xFFFFFAF7),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? color : const Color(0xFFE8DCD6),
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 7),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: selected ? color : const Color(0xFF22314D),
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: const TextStyle(
                        color: Color(0xFF22314D),
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
              if (selected)
                Icon(Icons.check_circle_rounded, color: color, size: 17),
            ],
          ),
        ),
      ),
    );
  }

}

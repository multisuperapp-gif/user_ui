part of '../../main.dart';

class _CartPage extends StatefulWidget {
  const _CartPage({
    required this.shopName,
    required this.items,
    required this.onCheckout,
  });

  final String shopName;
  final List<_DiscoveryItem> items;
  final Future<void> Function(int? addressId) onCheckout;

  @override
  State<_CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<_CartPage> {
  bool _loadingAddresses = true;
  String? _addressError;
  List<_UserAddressData> _addresses = const <_UserAddressData>[];
  int? _selectedAddressId;

  double get _itemsTotal {
    return widget.items.fold<double>(0, (total, item) => total + _extractAmount(item.price));
  }

  double get _deliveryCharge => _itemsTotal >= 500 ? 0 : 35;

  double get _platformFee => 12;

  double get _grandTotal => _itemsTotal + _deliveryCharge + _platformFee;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  static double _extractAmount(String price) {
    final match = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(price);
    return double.tryParse(match?.group(1) ?? '') ?? 0;
  }

  String _money(double amount) => '₹${amount.toStringAsFixed(amount.truncateToDouble() == amount ? 0 : 2)}';

  Future<void> _loadAddresses() async {
    setState(() {
      _loadingAddresses = true;
      _addressError = null;
    });
    try {
      final addresses = await _UserAppApi.fetchAddresses();
      int? selectedAddressId;
      for (final address in addresses) {
        if (address.isDefault) {
          selectedAddressId = address.id;
          break;
        }
      }
      selectedAddressId ??= addresses.isEmpty ? null : addresses.first.id;
      if (!mounted) {
        return;
      }
      setState(() {
        _addresses = addresses;
        _selectedAddressId = selectedAddressId;
        _loadingAddresses = false;
        _addressError = null;
      });
    } on _UserAppApiException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _addresses = const <_UserAddressData>[];
        _selectedAddressId = null;
        _loadingAddresses = false;
        _addressError = error.message;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _addresses = const <_UserAddressData>[];
        _selectedAddressId = null;
        _loadingAddresses = false;
        _addressError = 'Could not load saved addresses right now.';
      });
    }
  }

  Future<void> _openAddressManager() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const _AddressesPage(),
      ),
    );
    await _loadAddresses();
  }

  @override
  Widget build(BuildContext context) {
    _UserAddressData? selectedAddress;
    for (final address in _addresses) {
      if (address.id == _selectedAddressId) {
        selectedAddress = address;
        break;
      }
    }
    return Scaffold(
      backgroundColor: const Color(0xFFF7F2EC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Your cart',
          style: TextStyle(
            color: Color(0xFF22314D),
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF4DAF50),
                  Color(0xFF85C86B),
                ],
              ),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.shopName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${widget.items.length} items from the same shop are ready for checkout.',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          ...widget.items.map(
            (item) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: item.accent.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(item.icon, color: item.accent),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: const TextStyle(
                            color: Color(0xFF22314D),
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.subtitle,
                          style: const TextStyle(
                            color: Color(0xFF6D7A91),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    item.price.isEmpty ? '₹0' : item.price,
                    style: const TextStyle(
                      color: Color(0xFF22314D),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                _summaryRow('Items total', _money(_itemsTotal)),
                _summaryRow('Delivery charges', _deliveryCharge == 0 ? 'Free' : _money(_deliveryCharge)),
                _summaryRow('Platform fee', _money(_platformFee)),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1),
                ),
                _summaryRow('To pay', _money(_grandTotal), highlight: true),
              ],
            ),
          ),
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
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Delivery address',
                        style: TextStyle(
                          color: Color(0xFF22314D),
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _openAddressManager,
                      child: const Text('Manage'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (_loadingAddresses)
                  const _AsyncStateCard(
                    icon: Icons.location_on_outlined,
                    title: 'Loading saved addresses',
                    message: 'We are fetching your real delivery addresses for this order.',
                    dense: true,
                    loading: true,
                  )
                else if (_addressError != null)
                  _AsyncStateCard(
                    icon: Icons.location_off_outlined,
                    title: 'Could not load addresses',
                    message: _addressError!,
                    actionLabel: 'Try Again',
                    onAction: _loadAddresses,
                    dense: true,
                  )
                else if (_addresses.isEmpty)
                  const _AsyncStateCard(
                    icon: Icons.add_location_alt_outlined,
                    title: 'No saved address yet',
                    message: 'Add one address first so checkout can use a real delivery location.',
                    dense: true,
                  )
                else ...[
                  if (selectedAddress != null)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F4EF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            selectedAddress.isDefault
                                ? '${selectedAddress.label} · Default'
                                : selectedAddress.label,
                            style: const TextStyle(
                              color: Color(0xFF22314D),
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            selectedAddress.fullAddress,
                            style: const TextStyle(
                              color: Color(0xFF4F5C73),
                              fontWeight: FontWeight.w700,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${selectedAddress.city}, ${selectedAddress.state} · ${selectedAddress.postalCode}',
                            style: const TextStyle(
                              color: Color(0xFF6D7A91),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const Text(
                    'Choose another saved address for this order:',
                    style: TextStyle(
                      color: Color(0xFF6D7A91),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _addresses
                        .map(
                          (address) => ChoiceChip(
                            label: Text(address.label),
                            selected: address.id == _selectedAddressId,
                            onSelected: (_) => setState(() {
                              _selectedAddressId = address.id;
                            }),
                          ),
                        )
                        .toList(growable: false),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _loadingAddresses || _addresses.isEmpty ? null : () => widget.onCheckout(_selectedAddressId),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFCB6E5B),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: const RoundedRectangleBorder(),
              ),
              child: Text(
                'Proceed to pay ${_money(_grandTotal)}',
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Orders can be cancelled only before they go out for delivery. Platform fee and service charges are non-refundable.',
            style: TextStyle(
              color: Color(0xFF7A879B),
              fontWeight: FontWeight.w700,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          const _MadeWithLoveFooter(),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: highlight ? const Color(0xFF22314D) : const Color(0xFF6D7A91),
                fontWeight: highlight ? FontWeight.w900 : FontWeight.w700,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: const Color(0xFF22314D),
              fontWeight: highlight ? FontWeight.w900 : FontWeight.w800,
              fontSize: highlight ? 18 : 15,
            ),
          ),
        ],
      ),
    );
  }
}

part of '../../../main.dart';

const List<String> _giftFilterCategoryOptions = [
  'Flowers',
  'Cakes',
  'Plants',
  'Personalised',
  'Chocolates',
  'Home Decor',
];

const List<String> _giftSortOptions = [
  'Popular',
  'Low to High',
  'High to Low',
  'Newly Added',
];

const List<String> _giftOccasionOptions = [
  'Birthday',
  'Anniversary',
  'Reception',
  'Festival',
];

const Set<String> _giftKnownShopNames = {
  'Luxe',
  'Petal Story',
  'Bloom Basket',
  'Cake For You',
  'Gift Aura',
  'Plant Nest',
  'HomeGlow',
};

class _ShopGiftFilterPage extends StatefulWidget {
  const _ShopGiftFilterPage({required this.initialCategory});

  final String initialCategory;

  @override
  State<_ShopGiftFilterPage> createState() => _ShopGiftFilterPageState();
}

class _ShopGiftFilterPageState extends State<_ShopGiftFilterPage> {
  late String _category = _normalizedCategory(widget.initialCategory);
  String _sort = 'Popular';
  double _minPrice = 399;
  double _maxPrice = 3499;

  static String _normalizedCategory(String value) =>
      _giftFilterCategoryOptions.contains(value) ? value : 'Flowers';

  void _reset() {
    setState(() {
      _category = 'Flowers';
      _sort = 'Popular';
      _minPrice = 399;
      _maxPrice = 3499;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFCF7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFCF7),
        elevation: 0,
        foregroundColor: const Color(0xFF1F2430),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        title: const Text(
          'Filter gifts',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          TextButton(
            onPressed: _reset,
            child: const Text(
              'Reset',
              style: TextStyle(
                color: Color(0xFF8A8B2E),
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 120),
        children: [
          _ShopFilterCard(
            title: 'Category',
            subtitle: 'Gift categories inside the selected store',
            child: _ShopFilterWrap(
              values: _giftFilterCategoryOptions,
              selected: _category,
              onSelected: (value) => setState(() => _category = value),
            ),
          ),
          _ShopFilterCard(
            title: 'Sort',
            child: _ShopFilterWrap(
              values: _giftSortOptions,
              selected: _sort,
              onSelected: (value) => setState(() => _sort = value),
            ),
          ),
          _ShopFilterCard(
            title: 'Price range',
            subtitle: '₹${_minPrice.round()} - ₹${_maxPrice.round()}',
            child: RangeSlider(
              values: RangeValues(_minPrice, _maxPrice),
              min: 99,
              max: 6000,
              divisions: 59,
              activeColor: const Color(0xFF8A8B2E),
              inactiveColor: const Color(0xFFE7E3C2),
              labels: RangeLabels('₹${_minPrice.round()}', '₹${_maxPrice.round()}'),
              onChanged: (value) => setState(() {
                _minPrice = value.start;
                _maxPrice = value.end;
              }),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(18, 10, 18, 18),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(false),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF202435),
                  side: const BorderSide(color: Color(0xFFD8CCC4)),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF8A8B2E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
                child: const Text(
                  'Apply filters',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

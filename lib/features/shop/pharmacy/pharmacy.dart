part of '../../../main.dart';

const List<String> _pharmacyCategoryOptions = [
  'All',
  'Wellness',
  'Baby care',
  'Personal care',
  'Essentials',
];

class _ShopPharmacyFilterPage extends StatefulWidget {
  const _ShopPharmacyFilterPage({required this.initialCategory});

  final String initialCategory;

  @override
  State<_ShopPharmacyFilterPage> createState() => _ShopPharmacyFilterPageState();
}

class _ShopPharmacyFilterPageState extends State<_ShopPharmacyFilterPage> {
  late String _category = _normalizedCategory(widget.initialCategory);
  String _sort = 'Popular';
  double _minPrice = 29;
  double _maxPrice = 1499;

  static const List<String> _categories = [
    'Wellness',
    'Baby care',
    'Personal care',
    'Essentials',
  ];
  static const List<String> _sortOptions = [
    'Popular',
    'Low to High',
    'High to Low',
    'Newly Added',
  ];

  static String _normalizedCategory(String value) =>
      _categories.contains(value) ? value : 'Wellness';

  void _reset() {
    setState(() {
      _category = 'Wellness';
      _sort = 'Popular';
      _minPrice = 29;
      _maxPrice = 1499;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7FAFC),
        elevation: 0,
        foregroundColor: const Color(0xFF202435),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        title: const Text(
          'Filter pharmacy',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          TextButton(
            onPressed: _reset,
            child: const Text(
              'Reset',
              style: TextStyle(
                color: Color(0xFF268B9C),
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
            subtitle: 'Dynamic pharmacy categories from selected listing',
            child: _ShopFilterWrap(
              values: _categories,
              selected: _category,
              onSelected: (value) => setState(() => _category = value),
            ),
          ),
          _ShopFilterCard(
            title: 'Sort',
            child: _ShopFilterWrap(
              values: _sortOptions,
              selected: _sort,
              onSelected: (value) => setState(() => _sort = value),
            ),
          ),
          _ShopFilterCard(
            title: 'Price range',
            subtitle: '₹${_minPrice.round()} - ₹${_maxPrice.round()}',
            child: RangeSlider(
              values: RangeValues(_minPrice, _maxPrice),
              min: 1,
              max: 2000,
              divisions: 80,
              activeColor: const Color(0xFF268B9C),
              inactiveColor: const Color(0xFFD8EBF0),
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
                  backgroundColor: const Color(0xFF268B9C),
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

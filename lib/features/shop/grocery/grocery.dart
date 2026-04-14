part of '../../../main.dart';

const List<String> _groceryCategoryOptions = [
  'All',
  'Biscuits',
  'Noodles',
  'Rice',
  'Chips',
  'Household',
];

class _ShopGroceryFilterPage extends StatefulWidget {
  const _ShopGroceryFilterPage({required this.initialCategory});

  final String initialCategory;

  @override
  State<_ShopGroceryFilterPage> createState() => _ShopGroceryFilterPageState();
}

class _ShopGroceryFilterPageState extends State<_ShopGroceryFilterPage> {
  late String _category = _normalizedCategory(widget.initialCategory);
  String _sort = 'Popular';
  double _minPrice = 29;
  double _maxPrice = 799;

  static const List<String> _categories = [
    'Biscuits',
    'Noodles',
    'Rice',
    'Chips',
    'Household',
  ];
  static const List<String> _sortOptions = [
    'Popular',
    'Low to High',
    'High to Low',
    'Newly Added',
  ];

  static String _normalizedCategory(String value) =>
      _categories.contains(value) ? value : 'Biscuits';

  void _reset() {
    setState(() {
      _category = 'Biscuits';
      _sort = 'Popular';
      _minPrice = 29;
      _maxPrice = 799;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5EF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F5EF),
        elevation: 0,
        foregroundColor: const Color(0xFF202435),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        title: const Text(
          'Filter groceries',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          TextButton(
            onPressed: _reset,
            child: const Text(
              'Reset',
              style: TextStyle(
                color: Color(0xFF2E8E45),
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
            subtitle: 'Dynamic grocery categories from selected listing',
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
              max: 1500,
              divisions: 60,
              activeColor: const Color(0xFF2E8E45),
              inactiveColor: const Color(0xFFDDEAD9),
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
                  backgroundColor: const Color(0xFF2E8E45),
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

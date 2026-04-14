part of '../../../main.dart';

class _ShopFootwearFilterPage extends StatefulWidget {
  const _ShopFootwearFilterPage({required this.initialGender});

  final String initialGender;

  @override
  State<_ShopFootwearFilterPage> createState() => _ShopFootwearFilterPageState();
}

class _ShopFootwearFilterPageState extends State<_ShopFootwearFilterPage> {
  late String _gender = _normalizeGender(widget.initialGender);
  String _category = 'Shoes';
  String _occasion = 'Casual';
  String _color = 'Black';
  String _size = '8';
  String _brand = 'All brands';
  double _minPrice = 299;
  double _maxPrice = 2999;
  int _rating = 4;

  static const List<String> _genders = ['Men', 'Women', 'Boys', 'Girls'];
  static const List<String> _occasions = ['Casual', 'Formal', 'Party Wear', 'Sports', 'Daily Wear'];
  static const List<String> _colors = ['Black', 'White', 'Blue', 'Brown', 'Tan', 'Pink', 'Beige', 'Green'];
  static const List<String> _sizes = ['5', '6', '7', '8', '9', '10', '11'];
  static const List<String> _brands = ['All brands', 'Roadster', 'Arrow Walk', 'Urban Steps', 'Step Aura', 'Tiny Steps', 'Sole Studio'];

  List<String> get _categories => switch (_gender) {
        'Women' => ['Heels', 'Sandals', 'Flats', 'Party Heels', 'Slippers', 'Shoes'],
        'Boys' => ['School Shoes', 'Sports Shoes', 'Sandals', 'Slides', 'Slippers'],
        'Girls' => ['Cute Sandals', 'Ballet Flats', 'Party Sandals', 'School Shoes', 'Slides'],
        _ => ['Shoes', 'Sneakers', 'Loafers', 'Slippers', 'Sandals', 'Boots'],
      };

  static String _normalizeGender(String value) => _genders.contains(value) ? value : 'Men';

  void _setGender(String value) {
    setState(() {
      _gender = value;
      _category = _categories.first;
    });
  }

  void _reset() {
    setState(() {
      _gender = 'Men';
      _category = _categories.first;
      _occasion = 'Casual';
      _color = 'Black';
      _size = '8';
      _brand = 'All brands';
      _minPrice = 299;
      _maxPrice = 2999;
      _rating = 4;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FBFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7FBFA),
        elevation: 0,
        foregroundColor: const Color(0xFF202435),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        title: const Text(
          'Filter footwear',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          TextButton(
            onPressed: _reset,
            child: const Text(
              'Reset',
              style: TextStyle(
                color: Color(0xFF13907D),
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 6, 18, 120),
        children: [
          _ShopFilterCard(
            title: 'Gender',
            child: _ShopFilterWrap(
              values: _genders,
              selected: _gender,
              onSelected: _setGender,
            ),
          ),
          _ShopFilterCard(
            title: 'Category',
            subtitle: 'Footwear type changes based on selected gender',
            child: _ShopFilterWrap(
              values: _categories,
              selected: _category,
              onSelected: (value) => setState(() => _category = value),
            ),
          ),
          _ShopFilterCard(
            title: 'Occasion',
            child: _ShopFilterWrap(
              values: _occasions,
              selected: _occasion,
              onSelected: (value) => setState(() => _occasion = value),
            ),
          ),
          _ShopFilterCard(
            title: 'Color',
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _colors
                  .map(
                    (color) => _ColorFilterChip(
                      label: color,
                      selected: _color == color,
                      onTap: () => setState(() => _color = color),
                    ),
                  )
                  .toList(),
            ),
          ),
          _ShopFilterCard(
            title: 'Size',
            child: _ShopFilterWrap(
              values: _sizes,
              selected: _size,
              onSelected: (value) => setState(() => _size = value),
            ),
          ),
          _ShopFilterCard(
            title: 'Rating',
            child: Row(
              children: List.generate(
                5,
                (index) {
                  final star = index + 1;
                  final selected = star <= _rating;
                  return GestureDetector(
                    onTap: () => setState(() => _rating = star),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Icon(
                        selected ? Icons.star_rounded : Icons.star_border_rounded,
                        color: selected ? const Color(0xFFF2A13D) : const Color(0xFFC8C2BA),
                        size: 32,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          _ShopFilterCard(
            title: 'Brand',
            child: _ShopFilterWrap(
              values: _brands,
              selected: _brand,
              onSelected: (value) => setState(() => _brand = value),
            ),
          ),
          _ShopFilterCard(
            title: 'Price range',
            subtitle: '₹${_minPrice.round()} - ₹${_maxPrice.round()}',
            child: RangeSlider(
              values: RangeValues(_minPrice, _maxPrice),
              min: 199,
              max: 5000,
              divisions: 48,
              activeColor: const Color(0xFF13907D),
              inactiveColor: const Color(0xFFD9ECE7),
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
                  backgroundColor: const Color(0xFF13907D),
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

class _ShopFilterCard extends StatelessWidget {
  const _ShopFilterCard({
    required this.title,
    required this.child,
    this.subtitle = '',
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF202435),
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                color: Color(0xFF7E8491),
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _ShopFilterWrap extends StatelessWidget {
  const _ShopFilterWrap({
    required this.values,
    required this.selected,
    required this.onSelected,
  });

  final List<String> values;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: values
          .map(
            (value) => _FilterPill(
              label: value,
              selected: selected == value,
              onTap: () => onSelected(value),
            ),
          )
          .toList(),
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFFEFE8) : const Color(0xFFF7F4F0),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? const Color(0xFFCB6E5B) : const Color(0xFFE6DED7),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? const Color(0xFFCB6E5B) : const Color(0xFF4D5362),
            fontSize: 12.5,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _ColorFilterChip extends StatelessWidget {
  const _ColorFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  Color get _color => switch (label) {
        'Black' => const Color(0xFF202435),
        'White' => Colors.white,
        'Blue' => const Color(0xFF3E7BD6),
        'Red' => const Color(0xFFE34E54),
        'Green' => const Color(0xFF36A269),
        'Yellow' => const Color(0xFFF2C64B),
        'Pink' => const Color(0xFFE75D93),
        'Brown' => const Color(0xFF8B5E3C),
        _ => const Color(0xFFCB6E5B),
      };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.fromLTRB(8, 7, 12, 7),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFFEFE8) : const Color(0xFFF7F4F0),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? const Color(0xFFCB6E5B) : const Color(0xFFE6DED7),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: _color,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFD8CCC4)),
              ),
            ),
            const SizedBox(width: 7),
            Text(
              label,
              style: TextStyle(
                color: selected ? const Color(0xFFCB6E5B) : const Color(0xFF4D5362),
                fontSize: 12.5,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

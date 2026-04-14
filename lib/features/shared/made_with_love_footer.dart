part of '../../main.dart';

String _assetSlug(String value) {
  final normalized = value
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'_+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');
  return normalized.isEmpty ? 'placeholder' : normalized;
}

class _MadeWithLoveFooter extends StatelessWidget {
  const _MadeWithLoveFooter();

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: const TextSpan(
        style: TextStyle(
          color: Color(0xFF69768D),
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
        children: [
          TextSpan(text: 'Made with '),
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 1.5),
              child: Icon(Icons.favorite_rounded, size: 18, color: Color(0xFFCB6E5B)),
            ),
          ),
          TextSpan(text: ' in '),
          TextSpan(
            text: 'Rural Bharat',
            style: TextStyle(
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

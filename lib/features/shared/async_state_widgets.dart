part of '../../main.dart';

class _AsyncStateCard extends StatelessWidget {
  const _AsyncStateCard({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.loading = false,
    this.dense = false,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool loading;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(dense ? 18 : 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE9E0D8)),
        boxShadow: [
          BoxShadow(
            color: const Color(0x12000000),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: dense ? 42 : 48,
                height: dense ? 42 : 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0EA),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: loading
                    ? const Padding(
                        padding: EdgeInsets.all(10),
                        child: CircularProgressIndicator(
                          strokeWidth: 2.6,
                          color: Color(0xFFCB6E5B),
                        ),
                      )
                    : Icon(
                        icon,
                        color: const Color(0xFFCB6E5B),
                        size: dense ? 20 : 24,
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: const Color(0xFF22314D),
                    fontWeight: FontWeight.w900,
                    fontSize: dense ? 16 : 18,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(
              color: Color(0xFF5F6D84),
              fontWeight: FontWeight.w700,
              height: 1.5,
            ),
          ),
          if (onAction != null && actionLabel != null) ...[
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(actionLabel!),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFCB6E5B),
                side: const BorderSide(color: Color(0xFFCB6E5B)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

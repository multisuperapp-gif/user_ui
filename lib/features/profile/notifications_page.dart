part of '../../main.dart';

class _NotificationsPage extends StatefulWidget {
  const _NotificationsPage();

  @override
  State<_NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<_NotificationsPage> {
  bool _loading = true;
  bool _markingAll = false;
  int _unreadCount = 0;
  List<_RemoteNotificationItem> _items = const <_RemoteNotificationItem>[];

  @override
  void initState() {
    super.initState();
    unawaited(_loadNotifications());
  }

  Future<void> _loadNotifications() async {
    setState(() => _loading = true);
    try {
      final result = await _UserAppApi.fetchNotifications();
      if (!mounted) {
        return;
      }
        setState(() {
        _items = result.items;
        _unreadCount = result.unreadCount;
      });
    } on _UserAppApiException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _markAllRead() async {
    if (_markingAll || _unreadCount == 0) {
      return;
    }
    setState(() => _markingAll = true);
    try {
      await _UserAppApi.markAllNotificationsRead();
      if (!mounted) {
        return;
      }
      setState(() {
        _unreadCount = 0;
        _items = _items
            .map(
              (item) => _RemoteNotificationItem(
                id: item.id,
                channel: item.channel,
                notificationType: item.notificationType,
                title: item.title,
                body: item.body,
                status: item.status,
                payloadJson: item.payloadJson,
                sentAt: item.sentAt,
                readAt: DateTime.now(),
                createdAt: item.createdAt,
              ),
            )
            .toList(growable: false);
      });
    } on _UserAppApiException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } finally {
      if (mounted) {
        setState(() => _markingAll = false);
      }
    }
  }

  Future<void> _markRead(_RemoteNotificationItem item) async {
    if (item.isRead) {
      return;
    }
    try {
      await _UserAppApi.markNotificationRead(item.id);
      if (!mounted) {
        return;
      }
      setState(() {
        _items = _items
            .map(
              (entry) => entry.id == item.id
                  ? _RemoteNotificationItem(
                      id: entry.id,
                      channel: entry.channel,
                      notificationType: entry.notificationType,
                      title: entry.title,
                      body: entry.body,
                      status: entry.status,
                      payloadJson: entry.payloadJson,
                      sentAt: entry.sentAt,
                      readAt: DateTime.now(),
                      createdAt: entry.createdAt,
                    )
                  : entry,
            )
            .toList(growable: false);
        _unreadCount = (_unreadCount - 1).clamp(0, 9999);
      });
    } on _UserAppApiException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F2EC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Color(0xFF202435),
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _unreadCount == 0 || _markingAll ? null : _markAllRead,
            child: Text(
              _markingAll ? 'Saving...' : 'Mark all read',
              style: const TextStyle(
                color: Color(0xFFCB6E5B),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadNotifications,
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFFCB6E5B)))
            : _items.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(height: 140),
                      Center(
                        child: Text(
                          'No notifications yet.',
                          style: TextStyle(
                            color: Color(0xFF202435),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  )
                : ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                    itemCount: _items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      return InkWell(
                        onTap: () => _markRead(item),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: item.isRead ? Colors.white : const Color(0xFFFFF2ED),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: item.isRead
                                  ? const Color(0xFFEDE4DA)
                                  : const Color(0xFFF4C5B8),
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x11000000),
                                blurRadius: 18,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.title,
                                      style: const TextStyle(
                                        color: Color(0xFF202435),
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  if (!item.isRead)
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFCB6E5B),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                item.body,
                                style: const TextStyle(
                                  color: Color(0xFF5C6270),
                                  fontSize: 14,
                                  height: 1.35,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF5E3D9),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      _notificationTypeLabel(item.notificationType),
                                      style: const TextStyle(
                                        color: Color(0xFF9C4D3E),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    _notificationTimeLabel(item.createdAt ?? item.sentAt),
                                    style: const TextStyle(
                                      color: Color(0xFF8C8F98),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }

  String _notificationTypeLabel(String raw) {
    final label = raw.trim();
    if (label.isEmpty) {
      return 'UPDATE';
    }
    return label.replaceAll('_', ' ').toUpperCase();
  }

  String _notificationTimeLabel(DateTime? value) {
    if (value == null) {
      return 'Just now';
    }
    final now = DateTime.now();
    final diff = now.difference(value);
    if (diff.inMinutes < 1) {
      return 'Just now';
    }
    if (diff.inHours < 1) {
      return '${diff.inMinutes} min ago';
    }
    if (diff.inDays < 1) {
      return '${diff.inHours} hr ago';
    }
    if (diff.inDays < 7) {
      return '${diff.inDays} day ago';
    }
    return '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';
  }
}

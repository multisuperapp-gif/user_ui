part of '../../main.dart';

class _ProfilePage extends StatefulWidget {
  const _ProfilePage({
    required this.phoneNumber,
    required this.onLogout,
  });

  final String phoneNumber;
  final Future<void> Function() onLogout;

  @override
  State<_ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<_ProfilePage> {
  _UserProfileData? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _UserAppApi.fetchProfile();
      if (!mounted) {
        return;
      }
      setState(() {
        _profile = profile;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _profile = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayName = _profile?.fullName.trim().isNotEmpty == true ? _profile!.fullName : 'MSA User';
    final publicUserId = _profile?.publicUserId.trim() ?? '';
    return Scaffold(
      backgroundColor: const Color(0xFFF7F2EC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ),
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE7EEF8),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person_rounded, size: 42, color: Color(0xFF324360)),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: const BoxDecoration(
                          color: Color(0xFFCB6E5B),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt_rounded, size: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Center(
                child: Text(
                  displayName,
                  style: const TextStyle(
                    color: Color(0xFF22314D),
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Center(
                child: Text(
                  '+91 ${widget.phoneNumber}',
                  style: const TextStyle(
                    color: Color(0xFF6E7B91),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (publicUserId.isNotEmpty) ...[
                const SizedBox(height: 4),
                Center(
                  child: Text(
                    publicUserId,
                    style: const TextStyle(
                      color: Color(0xFF9A8E84),
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              _DrawerAction(
                icon: Icons.receipt_long_rounded,
                label: 'My orders',
                onTap: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const _OrdersPage(),
                    ),
                  );
                },
              ),
              const _DrawerAction(icon: Icons.star_border_rounded, label: 'Ratings & reviews'),
              _DrawerAction(
                icon: Icons.location_on_outlined,
                label: 'Saved addresses',
                onTap: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const _AddressesPage(),
                    ),
                  );
                  await _loadProfile();
                },
              ),
              const _DrawerAction(icon: Icons.favorite_border_rounded, label: 'Favourite labour'),
              const _DrawerAction(icon: Icons.bookmark_border_rounded, label: 'Wishlist items'),
              const _DrawerAction(icon: Icons.support_agent_rounded, label: 'Help & support'),
              _DrawerAction(
                icon: Icons.logout_rounded,
                label: 'Logout',
                onTap: () async {
                  Navigator.of(context).pop();
                  await widget.onLogout();
                },
              ),
              const Spacer(),
              const Center(child: _MadeWithLoveFooter()),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerAction extends StatelessWidget {
  const _DrawerAction({
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final Future<void> Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap == null ? null : () async => onTap!(),
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFFCB6E5B)),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF22314D),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

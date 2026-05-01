part of '../../main.dart';

class _ProfilePage extends StatefulWidget {
  const _ProfilePage({
    required this.phoneNumber,
    this.initialProfile,
    required this.onLogout,
  });

  final String phoneNumber;
  final _UserProfileData? initialProfile;
  final Future<void> Function() onLogout;

  @override
  State<_ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<_ProfilePage> {
  _UserProfileData? _profile;
  bool _savingProfile = false;
  static const int _maxProfilePhotoBytes = 5 * 1024 * 1024;
  static const List<String> _genderOptions = ['Male', 'Female', 'Other'];

  @override
  void initState() {
    super.initState();
    _profile = widget.initialProfile;
    if (_profile == null) {
      unawaited(_primeProfile());
    }
  }

  Future<_UserProfileData?> _readCachedProfile() async {
    final raw = await _LocalSessionStore.readProfileCache();
    if (raw == null || raw.trim().isEmpty) {
      return null;
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }
      return _UserProfileData.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  Future<void> _primeProfile() async {
    final cached = await _readCachedProfile();
    if (!mounted) {
      return;
    }
    if (cached != null) {
      setState(() {
        _profile = cached;
      });
      return;
    }
    await _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _UserAppApi.fetchProfile();
      await _LocalSessionStore.saveProfileCache(jsonEncode(profile.toJson()));
      if (!mounted) {
        return;
      }
      setState(() {
        _profile = profile;
      });
    } on _UserSessionExpiredApiException {
      if (!mounted) {
        return;
      }
      await widget.onLogout();
    } catch (_) {
      if (!mounted) {
        return;
      }
      if (_profile == null) {
        setState(() {
          _profile = null;
        });
      }
    }
  }

  Uint8List? get _profilePhotoBytes {
    return _decodePhotoDataUriOrBase64(_profile?.profilePhotoDataUri ?? '');
  }

  String get _profilePhotoUrl => _profile?.profilePhotoUrl ?? '';

  String _profilePhotoMimeType(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) {
      return 'image/png';
    }
    if (lower.endsWith('.webp')) {
      return 'image/webp';
    }
    return 'image/jpeg';
  }

  bool _isPhotoTooLarge(Uint8List bytes) => bytes.length > _maxProfilePhotoBytes;

  void _showProfilePhotoError(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _profilePhotoDataUriFromBytes(Uint8List bytes, {String mimeType = 'image/png'}) {
    return 'data:$mimeType;base64,${base64Encode(bytes)}';
  }

  Future<void> _pickAndApplyDraftPhoto({
    required bool saving,
    required ValueSetter<String> setDraftPhotoDataUri,
    required ValueSetter<Uint8List?> setDraftPhotoBytes,
    ValueSetter<String>? onError,
  }) async {
    if (saving) {
      return;
    }
    try {
      final picked = await _pickProfilePhotoDraft(onError: onError);
      if (picked == null) {
        return;
      }
      final cropped = await _cropProfilePhotoDraft(picked.bytes, onError: onError);
      if (cropped == null) {
        return;
      }
      setDraftPhotoDataUri(cropped.dataUri);
      setDraftPhotoBytes(cropped.bytes);
    } catch (_) {
      final message = 'Could not open this image. Please choose a JPG, PNG, or WEBP photo up to 5 MB.';
      if (onError != null) {
        onError(message);
      } else {
        _showProfilePhotoError(message);
      }
    }
  }

  Future<({String dataUri, Uint8List bytes})?> _pickProfilePhotoDraft({
    ValueSetter<String>? onError,
  }) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
    );
    if (picked == null) {
      return null;
    }
    final bytes = await picked.readAsBytes();
    if (_isPhotoTooLarge(bytes)) {
      const message = 'Please choose a photo up to 5 MB.';
      if (onError != null) {
        onError(message);
      } else {
        _showProfilePhotoError(message);
      }
      return null;
    }
    return (
      dataUri: _profilePhotoDataUriFromBytes(bytes, mimeType: _profilePhotoMimeType(picked.path)),
      bytes: bytes,
    );
  }

  Future<({String dataUri, Uint8List bytes})?> _cropProfilePhotoDraft(
    Uint8List currentBytes, {
    ValueSetter<String>? onError,
  }) async {
    final cropped = await _openSquareCropperDialog(
      context,
      bytes: currentBytes,
      title: 'your profile photo',
    );
    if (cropped == null) {
      return null;
    }
    if (_isPhotoTooLarge(cropped.bytes)) {
      const message = 'Please keep the cropped photo within 5 MB.';
      if (onError != null) {
        onError(message);
      } else {
        _showProfilePhotoError(message);
      }
      return null;
    }
    return (
      dataUri: _profilePhotoDataUriFromBytes(cropped.bytes),
      bytes: cropped.bytes,
    );
  }

  String _formatDobLabel(DateTime? date) {
    if (date == null) {
      return 'Select date of birth';
    }
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year.toString().padLeft(4, '0')}';
  }

  Future<void> _openEditProfileSheet() async {
    final nameController = TextEditingController(text: _profile?.fullName.trim().isNotEmpty == true ? _profile!.fullName : '');
    String draftPhotoDataUri = _profile?.profilePhotoDataUri ?? '';
    Uint8List? draftPhotoBytes = _profilePhotoBytes;
    String draftPhotoUrl = _profilePhotoUrl;
    String selectedGender = _profile?.gender.trim() ?? '';
    DateTime? selectedDob = _profile?.dob == null ? null : DateUtils.dateOnly(_profile!.dob!);
    bool saving = false;
    String? photoError;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            Future<void> save() async {
              final trimmedName = nameController.text.trim();
              if (trimmedName.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter your name.')),
                );
                return;
              }
              setSheetState(() => photoError = null);
              setSheetState(() => saving = true);
              setState(() => _savingProfile = true);
              try {
                final updated = await _UserAppApi.updateProfile(
                  fullName: trimmedName,
                  profilePhotoDataUri: draftPhotoDataUri,
                  gender: selectedGender,
                  dob: selectedDob,
                  languageCode: _profile?.languageCode ?? 'en',
                );
                if (!mounted) {
                  return;
                }
                await _LocalSessionStore.saveProfileCache(jsonEncode(updated.toJson()));
                setState(() {
                  _profile = updated;
                });
                Navigator.of(sheetContext).pop();
              } on _UserSessionExpiredApiException {
                if (mounted) {
                  await widget.onLogout();
                }
              } on _UserAppApiException catch (error) {
                if (sheetContext.mounted) {
                  setSheetState(() {
                    photoError = error.message.trim().isEmpty
                        ? 'Could not update your profile right now.'
                        : error.message;
                  });
                }
              } finally {
                if (mounted) {
                  setState(() => _savingProfile = false);
                }
                if (sheetContext.mounted) {
                  setSheetState(() => saving = false);
                }
              }
            }

            return SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  0,
                  0,
                  0,
                  MediaQuery.viewInsetsOf(context).bottom + 12,
                ),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 42,
                          height: 4,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0D7D0),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Edit user profile',
                        style: TextStyle(
                          color: Color(0xFF22314D),
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Stack(
                          children: [
                            InkWell(
                              onTap: () => _pickAndApplyDraftPhoto(
                                saving: saving,
                                setDraftPhotoDataUri: (value) => setSheetState(() {
                                  draftPhotoDataUri = value;
                                  photoError = null;
                                }),
                                setDraftPhotoBytes: (value) => setSheetState(() {
                                  draftPhotoBytes = value;
                                  photoError = null;
                                  if (value != null) {
                                    draftPhotoUrl = '';
                                  }
                                }),
                                onError: (message) => setSheetState(() => photoError = message),
                              ),
                              customBorder: const CircleBorder(),
                              child: Container(
                                width: 92,
                                height: 92,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFE7EEF8),
                                  shape: BoxShape.circle,
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: draftPhotoBytes != null
                                    ? Image.memory(draftPhotoBytes!, fit: BoxFit.cover)
                                    : draftPhotoUrl.trim().isNotEmpty
                                        ? Image.network(
                                            draftPhotoUrl,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, _, _) => const Icon(
                                              Icons.add_a_photo_rounded,
                                              size: 34,
                                              color: Color(0xFF324360),
                                            ),
                                          )
                                        : const Icon(Icons.add_a_photo_rounded, size: 34, color: Color(0xFF324360)),
                              ),
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Material(
                                color: const Color(0xFFCB6E5B),
                                shape: const CircleBorder(),
                                child: InkWell(
                                  customBorder: const CircleBorder(),
                                  onTap: () => _pickAndApplyDraftPhoto(
                                    saving: saving,
                                    setDraftPhotoDataUri: (value) => setSheetState(() {
                                      draftPhotoDataUri = value;
                                      photoError = null;
                                    }),
                                    setDraftPhotoBytes: (value) => setSheetState(() {
                                      draftPhotoBytes = value;
                                      photoError = null;
                                      if (value != null) {
                                        draftPhotoUrl = '';
                                      }
                                    }),
                                    onError: (message) => setSheetState(() => photoError = message),
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.all(9),
                                    child: Icon(Icons.camera_alt_rounded, size: 16, color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (photoError != null) ...[
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              photoError!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFFB94F4F),
                                fontWeight: FontWeight.w700,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ),
                      ],
                      if (draftPhotoDataUri.isNotEmpty || draftPhotoUrl.trim().isNotEmpty)
                        Center(
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            alignment: WrapAlignment.center,
                            children: [
                              TextButton.icon(
                                onPressed: saving || draftPhotoBytes == null
                                    ? null
                                    : () async {
                                        final cropped = await _cropProfilePhotoDraft(
                                          draftPhotoBytes!,
                                          onError: (message) => setSheetState(() => photoError = message),
                                        );
                                        if (cropped == null) {
                                          return;
                                        }
                                        setSheetState(() {
                                          draftPhotoDataUri = cropped.dataUri;
                                          draftPhotoBytes = cropped.bytes;
                                          draftPhotoUrl = '';
                                          photoError = null;
                                        });
                                      },
                                icon: const Icon(Icons.crop_rounded, size: 18),
                                label: const Text('Crop photo'),
                              ),
                              TextButton.icon(
                                onPressed: saving
                                    ? null
                                    : () => _pickAndApplyDraftPhoto(
                                          saving: saving,
                                          setDraftPhotoDataUri: (value) => setSheetState(() {
                                            draftPhotoDataUri = value;
                                            photoError = null;
                                          }),
                                          setDraftPhotoBytes: (value) => setSheetState(() {
                                            draftPhotoBytes = value;
                                            photoError = null;
                                          }),
                                          onError: (message) => setSheetState(() => photoError = message),
                                        ),
                                icon: const Icon(Icons.upload_rounded, size: 18),
                                label: const Text('Upload photo'),
                              ),
                              TextButton(
                                onPressed: saving
                                    ? null
                                    : () => setSheetState(() {
                                          draftPhotoDataUri = '';
                                          draftPhotoBytes = null;
                                          draftPhotoUrl = '';
                                          photoError = null;
                                        }),
                                child: const Text('Remove photo'),
                              ),
                            ],
                          ),
                        ),
                      TextField(
                        controller: nameController,
                        textCapitalization: TextCapitalization.words,
                        scrollPadding: const EdgeInsets.only(bottom: 24),
                        decoration: InputDecoration(
                          labelText: 'Your name',
                          filled: true,
                          fillColor: const Color(0xFFF7F2EC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Gender',
                        style: TextStyle(
                          color: Color(0xFF22314D),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _genderOptions.map((option) {
                          final selected = selectedGender.toLowerCase() == option.toLowerCase();
                          return ChoiceChip(
                            label: Text(option),
                            selected: selected,
                            onSelected: saving
                                ? null
                                : (_) => setSheetState(() {
                                      selectedGender = option;
                                    }),
                            selectedColor: const Color(0xFFF7D7CF),
                            backgroundColor: const Color(0xFFF7F2EC),
                            labelStyle: TextStyle(
                              color: selected ? const Color(0xFF9F4F40) : const Color(0xFF66748C),
                              fontWeight: FontWeight.w800,
                            ),
                            side: BorderSide(
                              color: selected ? const Color(0xFFCB6E5B) : const Color(0xFFE4D8D0),
                            ),
                          );
                        }).toList(growable: false),
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: saving
                            ? null
                            : () async {
                                final now = DateTime.now();
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: selectedDob ?? DateTime(now.year - 20, now.month, now.day),
                                  firstDate: DateTime(1950),
                                  lastDate: now,
                                );
                                if (picked == null) {
                                  return;
                                }
                                setSheetState(() {
                                  selectedDob = DateUtils.dateOnly(picked);
                                });
                              },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7F2EC),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Date of birth',
                                      style: TextStyle(
                                        color: Color(0xFF7A879B),
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _formatDobLabel(selectedDob),
                                      style: const TextStyle(
                                        color: Color(0xFF22314D),
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.calendar_month_rounded, color: Color(0xFF66748C)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: saving ? null : save,
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFCB6E5B),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: saving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Text(
                                  'Save profile',
                                  style: TextStyle(fontWeight: FontWeight.w900),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
    nameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayName = _profile?.fullName.trim().isNotEmpty == true ? _profile!.fullName : 'MSA User';
    final photoBytes = _profilePhotoBytes;
    final photoUrl = _profilePhotoUrl.trim();
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
                  onPressed: () => Navigator.of(context).pop(_profile),
                  icon: const Icon(Icons.close_rounded),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
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
                            clipBehavior: Clip.antiAlias,
                            child: photoBytes != null
                                ? Image.memory(photoBytes, fit: BoxFit.cover)
                                : photoUrl.isNotEmpty
                                    ? Image.network(
                                        photoUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, _, _) => const Icon(
                                          Icons.add_a_photo_rounded,
                                          size: 34,
                                          color: Color(0xFF324360),
                                        ),
                                      )
                                    : const Icon(Icons.add_a_photo_rounded, size: 34, color: Color(0xFF324360)),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Material(
                              color: const Color(0xFFCB6E5B),
                              shape: const CircleBorder(),
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                onTap: _savingProfile ? null : _openEditProfileSheet,
                                child: const Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Icon(Icons.camera_alt_rounded, size: 16, color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (photoBytes == null && photoUrl.isEmpty) ...[
                      const SizedBox(height: 10),
                      Center(
                        child: Text(
                          'Tap the camera to upload your profile photo',
                          style: TextStyle(
                            color: const Color(0xFF8A766A).withValues(alpha: 0.9),
                            fontWeight: FontWeight.w700,
                            fontSize: 12.4,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 18),
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.sizeOf(context).width - 110,
                            ),
                            child: Text(
                              displayName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFF22314D),
                                fontWeight: FontWeight.w900,
                                fontSize: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Material(
                            color: const Color(0xFFF1E2DB),
                            borderRadius: BorderRadius.circular(999),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(999),
                              onTap: _savingProfile ? null : _openEditProfileSheet,
                              child: const Padding(
                                padding: EdgeInsets.all(8),
                                child: Icon(
                                  Icons.edit_rounded,
                                  size: 18,
                                  color: Color(0xFF9F4F40),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    if ((_profile?.gender.trim().isNotEmpty ?? false) || _profile?.dob != null)
                      Center(
                        child: Text(
                          [
                            if (_profile?.gender.trim().isNotEmpty ?? false) _profile!.gender.trim(),
                            if (_profile?.dob != null) _formatDobLabel(_profile!.dob),
                          ].join(' • '),
                          style: const TextStyle(
                            color: Color(0xFF8A766A),
                            fontWeight: FontWeight.w700,
                            fontSize: 12.5,
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
                    _DrawerAction(
                      icon: Icons.local_shipping_outlined,
                      label: 'My booking',
                      onTap: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const _MyBookingsPage(),
                          ),
                        );
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
                    const SizedBox(height: 18),
                    const Center(child: _MadeWithLoveFooter()),
                  ],
                ),
              ),
            ],
          ),
          ),
        ),
    );
  }
}

class _MyBookingsPage extends StatefulWidget {
  const _MyBookingsPage();

  @override
  State<_MyBookingsPage> createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<_MyBookingsPage> {
  static const String _historyPeriodAllTime = 'All time';
  static const String _historyPeriodLastWeek = 'Last week';
  static const String _historyPeriodLastMonth = 'Last month';
  static const String _historyPeriodLastSixMonths = '6 months';
  static const int _historyPageSize = 20;
  bool _loading = true;
  bool _paying = false;
  bool _historyLoadingMore = false;
  bool _historyHasMore = true;
  String? _error;
  _ActiveBookingStatus? _status;
  List<_ActiveBookingStatus> _activeStatuses = const <_ActiveBookingStatus>[];
  List<_ActiveBookingStatus> _historyStatuses = const <_ActiveBookingStatus>[];
  String _selectedBookingStatusFilter = 'All';
  String _selectedBookingTypeFilter = 'All';
  String _selectedPaymentStatusFilter = 'All';
  String _selectedHistoryPeriodFilter = _historyPeriodAllTime;
  int _historyPage = 0;
  final ScrollController _scrollController = ScrollController();
  bool _showHistoryScrollToTop = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    unawaited(_load());
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) {
      return;
    }
    final shouldShowScrollToTop = _scrollController.position.pixels >= 420;
    if (shouldShowScrollToTop != _showHistoryScrollToTop && mounted) {
      setState(() {
        _showHistoryScrollToTop = shouldShowScrollToTop;
      });
    }
    if (_loading || _historyLoadingMore || !_historyHasMore) {
      return;
    }
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 220) {
      unawaited(_loadMoreHistory());
    }
  }

  Future<void> _scrollHistoryToTop() async {
    if (!_scrollController.hasClients) {
      return;
    }
    await _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );
  }

  void _applyActiveBookingStatusUpdate(_ActiveBookingStatus? latestStatus) {
    setState(() {
      if (latestStatus == null) {
        final currentRequestId = _status?.requestId;
        _activeStatuses = _activeStatuses
            .where((item) => item.requestId != currentRequestId)
            .toList(growable: false);
        _status = _activeStatuses.isEmpty ? null : _activeStatuses.first;
        return;
      }
      final updated = List<_ActiveBookingStatus>.from(_activeStatuses);
      final index = updated.indexWhere((item) => item.requestId == latestStatus.requestId);
      if (index >= 0) {
        updated[index] = latestStatus;
      } else {
        updated.insert(0, latestStatus);
      }
      _activeStatuses = updated;
      _status = latestStatus;
    });
    if (latestStatus == null) {
      unawaited(_load());
    }
  }

  Future<void> _openLiveBookingDetails() async {
    final status = _status;
    if (status == null) {
      return;
    }
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ActiveBookingDetailsSheet(
        initialStatus: status,
        onPayNow: (latestStatus) async {
          Navigator.of(context).pop();
          setState(() {
            _status = latestStatus;
          });
          await _makePayment();
        },
        onStatusChanged: _applyActiveBookingStatusUpdate,
      ),
    );
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final activeStatuses = await _UserAppApi.fetchActiveBookingStatuses();
      final historyStatuses = await _UserAppApi.fetchBookingHistoryStatuses(page: 0, size: _historyPageSize);
      if (!mounted) {
        return;
      }
      setState(() {
        _activeStatuses = activeStatuses;
        _historyStatuses = historyStatuses;
        _status = activeStatuses.isEmpty ? null : activeStatuses.first;
        _historyPage = 0;
        _historyHasMore = historyStatuses.length >= _historyPageSize;
      });
    } on _UserAppApiException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = error.message;
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _loadMoreHistory() async {
    if (_loading || _historyLoadingMore || !_historyHasMore) {
      return;
    }
    setState(() {
      _historyLoadingMore = true;
    });
    try {
      final nextPage = _historyPage + 1;
      final nextItems = await _UserAppApi.fetchBookingHistoryStatuses(
        page: nextPage,
        size: _historyPageSize,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        final existingRequestIds = _historyStatuses.map((item) => item.requestId).toSet();
        final merged = List<_ActiveBookingStatus>.from(_historyStatuses)
          ..addAll(nextItems.where((item) => !existingRequestIds.contains(item.requestId)));
        _historyStatuses = merged;
        _historyPage = nextPage;
        _historyHasMore = nextItems.length >= _historyPageSize;
      });
    } on _UserAppApiException {
      if (!mounted) {
        return;
      }
      setState(() {
        _historyHasMore = false;
      });
    } finally {
      if (mounted) {
        setState(() {
          _historyLoadingMore = false;
        });
      }
    }
  }

  List<_ActiveBookingStatus> get _filteredHistoryStatuses {
    final activeIds = _activeStatuses.map((item) => item.requestId).toSet();
    final source = _historyStatuses
        .where((item) => !activeIds.contains(item.requestId))
        .where((item) {
          final status = _normalizedHistoryStatus(item);
          if (!_visibleHistoryStatuses.contains(status)) {
            return false;
          }
          if (_selectedBookingStatusFilter == 'All') {
            return true;
          }
          return status == _historyStatusCodeFromFilter(_selectedBookingStatusFilter);
        })
        .where((item) {
          if (_selectedPaymentStatusFilter == 'All') {
            return true;
          }
          return item.paymentStatus.trim().toUpperCase() == _selectedPaymentStatusFilter.toUpperCase();
        })
        .where((item) {
          if (_selectedBookingTypeFilter == 'All') {
            return true;
          }
          return item.bookingType.trim().toUpperCase() ==
              _bookingTypeCodeFromFilter(_selectedBookingTypeFilter);
        })
        .where((item) {
          return _matchesHistoryPeriod(item.createdAt);
        })
        .toList(growable: false);
    source.sort((a, b) {
      final aTime = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bTime = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bTime.compareTo(aTime);
    });
    return source;
  }

  List<String> get _bookingStatusOptions {
    final available = _historyStatuses
        .map(_normalizedHistoryStatus)
        .where(_visibleHistoryStatuses.contains)
        .toSet();
    const ordered = <String>['COMPLETED', 'CANCELLED', 'NO_SHOW', 'PAYMENT_FAILED'];
    return <String>[
      'All',
      ...ordered.where(available.contains).map(_historyStatusFilterLabel),
    ];
  }

  List<String> get _bookingTypeOptions {
    final values = <String>{'All'};
    for (final item in _historyStatuses) {
      if (!_visibleHistoryStatuses.contains(_normalizedHistoryStatus(item))) {
        continue;
      }
      final bookingType = item.bookingType.trim().toUpperCase();
      if (bookingType == 'LABOUR') {
        values.add('Labour');
      } else if (bookingType == 'SERVICE') {
        values.add('Service');
      }
    }
    return values.toList(growable: false);
  }

  List<String> get _paymentStatusOptions {
    final values = <String>{'All'};
    for (final item in _historyStatuses) {
      if (!_visibleHistoryStatuses.contains(_normalizedHistoryStatus(item))) {
        continue;
      }
      final paymentStatus = item.paymentStatus.trim();
      if (paymentStatus.isNotEmpty) {
        values.add(_titleCase(paymentStatus));
      }
    }
    return values.toList(growable: false);
  }

  static const Set<String> _visibleHistoryStatuses = <String>{
    'COMPLETED',
    'CANCELLED',
    'NO_SHOW',
    'PAYMENT_FAILED',
  };

  String _normalizedHistoryStatus(_ActiveBookingStatus item) {
    final explicit = item.historyStatus.trim().toUpperCase();
    if (explicit.isNotEmpty) {
      return explicit;
    }
    final bookingStatus = item.bookingStatus.trim().toUpperCase();
    if (bookingStatus == 'COMPLETED') {
      return 'COMPLETED';
    }
    if (bookingStatus == 'CANCELLED' && item.paymentStatus.trim().toUpperCase() == 'FAILED') {
      return 'PAYMENT_FAILED';
    }
    if (bookingStatus == 'CANCELLED') {
      return 'CANCELLED';
    }
    return bookingStatus.isNotEmpty ? bookingStatus : item.requestStatus.trim().toUpperCase();
  }

  String _historyStatusFilterLabel(String value) {
    switch (value.toUpperCase()) {
      case 'PAYMENT_FAILED':
        return 'Payment failed';
      case 'NO_SHOW':
        return 'No show';
      case 'CANCELLED':
        return 'Canceled';
      case 'COMPLETED':
        return 'Completed';
      default:
        return _titleCase(value);
    }
  }

  String _historyStatusCodeFromFilter(String value) {
    switch (value.trim().toUpperCase()) {
      case 'PAYMENT FAILED':
        return 'PAYMENT_FAILED';
      case 'NO SHOW':
        return 'NO_SHOW';
      case 'CANCELED':
      case 'CANCELLED':
        return 'CANCELLED';
      case 'COMPLETED':
        return 'COMPLETED';
      default:
        return value.trim().toUpperCase();
    }
  }

  String _bookingTypeCodeFromFilter(String value) {
    switch (value.trim().toUpperCase()) {
      case 'LABOUR':
        return 'LABOUR';
      case 'SERVICE':
        return 'SERVICE';
      default:
        return value.trim().toUpperCase();
    }
  }

  List<String> get _historyPeriodOptions {
    final now = DateTime.now();
    final years = _historyStatuses
        .map((item) => item.createdAt?.year)
        .whereType<int>()
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));
    if (!years.contains(now.year)) {
      years.insert(0, now.year);
    }
    return <String>[
      _historyPeriodLastWeek,
      _historyPeriodLastMonth,
      _historyPeriodLastSixMonths,
      ...years.map((year) => '$year'),
      _historyPeriodAllTime,
    ];
  }

  bool _matchesHistoryPeriod(DateTime? createdAt) {
    if (_selectedHistoryPeriodFilter == _historyPeriodAllTime) {
      return true;
    }
    if (createdAt == null) {
      return false;
    }
    final created = DateUtils.dateOnly(createdAt);
    final today = DateUtils.dateOnly(DateTime.now());
    switch (_selectedHistoryPeriodFilter) {
      case _historyPeriodLastWeek:
        final start = today.subtract(const Duration(days: 7));
        return !created.isBefore(start);
      case _historyPeriodLastMonth:
        final start = DateTime(today.year, today.month - 1, today.day);
        return !created.isBefore(DateUtils.dateOnly(start));
      case _historyPeriodLastSixMonths:
        final start = DateTime(today.year, today.month - 6, today.day);
        return !created.isBefore(DateUtils.dateOnly(start));
      default:
        final year = int.tryParse(_selectedHistoryPeriodFilter);
        return year == null ? true : created.year == year;
    }
  }

  String _historyTitleFor(_ActiveBookingStatus item) {
    if (item.providerName.trim().isNotEmpty) {
      return item.providerName;
    }
    return item.bookingType.toUpperCase() == 'SERVICE' ? 'Service booking' : 'Labour booking';
  }

  Future<void> _makePayment() async {
    final status = _status;
    if (status == null || !status.canMakePayment || _paying) {
      return;
    }
    setState(() {
      _paying = true;
    });
    try {
      if (status.bookingType.toUpperCase() == 'SERVICE') {
        final payment = await _UserAppApi.initiateServiceBookingPayment(status.requestId);
        if (!mounted) {
          return;
        }
        final paymentResult = await _PaymentFlow.start(
          context,
          paymentCode: payment.paymentCode,
          title: 'Confirm service booking',
        );
        if (!mounted) {
          return;
        }
        await _PaymentFlow.showOutcome(
          context,
          result: paymentResult,
          successTitle: 'Service booking confirmed',
          failureTitle: 'Service payment incomplete',
          extraLines: [
            'Booking code: ${payment.bookingCode}',
            'Amount: ${payment.amountLabel}',
          ],
        );
        await _load();
        return;
      }
      final payment = await _UserAppApi.initiateLabourBookingPayment(status.requestId);
      if (!mounted) {
        return;
      }
      final paymentResult = await _PaymentFlow.start(
        context,
        paymentCode: payment.paymentCode,
        title: 'Confirm labour booking',
      );
      if (!mounted) {
        return;
      }
      await _PaymentFlow.showOutcome(
        context,
        result: paymentResult,
        successTitle: 'Labour booking confirmed',
        failureTitle: 'Labour payment incomplete',
        extraLines: [
          'Booking code: ${payment.bookingCode}',
          'Amount: ${payment.amountLabel}',
        ],
      );
      await _load();
    } on _UserAppApiException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message)),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _paying = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F2EC),
      floatingActionButton: _showHistoryScrollToTop
          ? FloatingActionButton.small(
              heroTag: 'booking-history-top',
              onPressed: _scrollHistoryToTop,
              backgroundColor: const Color(0xFFCB6E5B),
              foregroundColor: Colors.white,
              elevation: 6,
              child: const Icon(Icons.keyboard_arrow_up_rounded, size: 24),
            )
          : null,
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F2EC),
        surfaceTintColor: const Color(0xFFF7F2EC),
        title: const Text(
          'My booking',
          style: TextStyle(
            color: Color(0xFF22314D),
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          color: const Color(0xFFCB6E5B),
          child: _loading
              ? ListView(
                  padding: const EdgeInsets.all(24),
                  children: const [
                    _AsyncStateCard(
                      icon: Icons.local_shipping_outlined,
                      title: 'Loading my booking',
                      message: 'Checking your latest and previous booking requests.',
                      loading: true,
                    ),
                  ],
                )
              : _error != null
              ? ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    _AsyncStateCard(
                      icon: Icons.cloud_off_rounded,
                      title: 'Could not load my booking',
                      message: _error!,
                      actionLabel: 'Try Again',
                      onAction: _load,
                    ),
                  ],
                )
              : _status == null && _historyStatuses.isEmpty
              ? ListView(
                  padding: const EdgeInsets.all(24),
                  children: const [
                    _AsyncStateCard(
                      icon: Icons.inbox_outlined,
                      title: 'No booking yet',
                      message: 'Once you create a labour or service booking, it will appear here.',
                    ),
                  ],
                )
              : ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
                  children: [
                    if (_status != null) ...[
                      Text(
                        _activeStatuses.length == 1 ? 'Live booking' : 'Live bookings',
                        style: const TextStyle(
                          color: Color(0xFF22314D),
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _activeStatuses.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final active = _activeStatuses[index];
                          final selected = _status != null && active.requestId == _status!.requestId;
                          return _ProfileLiveBookingListCard(
                            status: active,
                            selected: selected,
                            onSelected: () {
                              setState(() {
                                _status = active;
                              });
                            },
                            onOpenDetails: _openLiveBookingDetails,
                            statusText: active.canMakePayment
                                ? 'Accepted. Confirm booking by making booking charges.'
                                : active.bookingStatus.trim().isNotEmpty
                                    ? _titleCase(active.bookingStatus)
                                    : _titleCase(active.requestStatus),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                    const Text(
                      'Booking history',
                      style: TextStyle(
                        color: Color(0xFF22314D),
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE8DDD4)),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                          PopupMenuButton<String>(
                            initialValue: _selectedBookingStatusFilter,
                            onSelected: (value) => setState(() => _selectedBookingStatusFilter = value),
                            itemBuilder: (context) => _bookingStatusOptions
                                .map((value) => PopupMenuItem<String>(value: value, child: Text(value)))
                                .toList(growable: false),
                            child: _BookingFilterChip(
                              icon: Icons.sell_outlined,
                              label: _selectedBookingStatusFilter == 'All'
                                  ? 'Status'
                                  : _selectedBookingStatusFilter,
                              active: _selectedBookingStatusFilter != 'All',
                            ),
                          ),
                          const SizedBox(width: 8),
                          PopupMenuButton<String>(
                            initialValue: _selectedBookingTypeFilter,
                            onSelected: (value) => setState(() => _selectedBookingTypeFilter = value),
                            itemBuilder: (context) => _bookingTypeOptions
                                .map((value) => PopupMenuItem<String>(value: value, child: Text(value)))
                                .toList(growable: false),
                            child: _BookingFilterChip(
                              icon: Icons.category_outlined,
                              label: _selectedBookingTypeFilter == 'All'
                                  ? 'Booking type'
                                  : _selectedBookingTypeFilter,
                              active: _selectedBookingTypeFilter != 'All',
                            ),
                          ),
                          const SizedBox(width: 8),
                          PopupMenuButton<String>(
                            initialValue: _selectedPaymentStatusFilter,
                            onSelected: (value) => setState(() => _selectedPaymentStatusFilter = value),
                            itemBuilder: (context) => _paymentStatusOptions
                                .map((value) => PopupMenuItem<String>(value: value, child: Text(value)))
                                .toList(growable: false),
                            child: _BookingFilterChip(
                              icon: Icons.payments_outlined,
                              label: _selectedPaymentStatusFilter == 'All'
                                  ? 'Payment'
                                  : _selectedPaymentStatusFilter,
                              active: _selectedPaymentStatusFilter != 'All',
                            ),
                          ),
                          const SizedBox(width: 8),
                          PopupMenuButton<String>(
                            initialValue: _selectedHistoryPeriodFilter,
                            onSelected: (value) => setState(() => _selectedHistoryPeriodFilter = value),
                            itemBuilder: (context) => _historyPeriodOptions
                                .map((value) => PopupMenuItem<String>(value: value, child: Text(value)))
                                .toList(growable: false),
                            child: _BookingFilterChip(
                              icon: Icons.calendar_today_rounded,
                              label: _selectedHistoryPeriodFilter,
                              active: _selectedHistoryPeriodFilter != _historyPeriodAllTime,
                            ),
                          ),
                          if (_selectedHistoryPeriodFilter != _historyPeriodAllTime ||
                              _selectedBookingStatusFilter != 'All' ||
                              _selectedBookingTypeFilter != 'All' ||
                              _selectedPaymentStatusFilter != 'All')
                            ...[
                              const SizedBox(width: 8),
                              InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () => setState(() {
                                  _selectedHistoryPeriodFilter = _historyPeriodAllTime;
                                  _selectedBookingStatusFilter = 'All';
                                  _selectedBookingTypeFilter = 'All';
                                  _selectedPaymentStatusFilter = 'All';
                                }),
                                child: const _BookingFilterChip(
                                icon: Icons.close_rounded,
                                label: 'Clear filters',
                                active: true,
                                showChevron: false,
                                accent: Color(0xFFCB6E5B),
                              ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_filteredHistoryStatuses.isEmpty)
                      const _AsyncStateCard(
                        icon: Icons.history_rounded,
                        title: 'No matching booking history',
                        message: 'Try changing the filters or create a new booking to see it here.',
                      )
                    else
                      ..._filteredHistoryStatuses.map(
                        (item) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _ProfileBookingHistoryCard(
                              key: ValueKey<String>('history-${item.requestId}'),
                              item: item,
                              title: _historyTitleFor(item),
                            ),
                          );
                        },
                      ),
                    if (_historyLoadingMore) ...[
                      const SizedBox(height: 10),
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.4,
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFCB6E5B)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}

class _BookingFilterChip extends StatelessWidget {
  const _BookingFilterChip({
    required this.icon,
    required this.label,
    this.active = false,
    this.showChevron = true,
    this.accent = const Color(0xFF66748C),
  });

  final IconData icon;
  final String label;
  final bool active;
  final bool showChevron;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: active ? accent.withValues(alpha: 0.08) : const Color(0xFFFCFAF7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: active ? accent.withValues(alpha: 0.32) : const Color(0xFFE4D8D0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: accent),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: active ? accent : const Color(0xFF22314D),
              fontWeight: FontWeight.w800,
              fontSize: 12.5,
            ),
          ),
          if (showChevron) ...[
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: accent),
          ],
        ],
      ),
    );
  }
}

class _ProfileBookingInfoRow extends StatelessWidget {
  const _ProfileBookingInfoRow({
    required this.label,
    required this.value,
    this.valueColor = const Color(0xFF22314D),
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 116,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF8C7E73),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: valueColor,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileLiveBookingListCard extends StatelessWidget {
  const _ProfileLiveBookingListCard({
    required this.status,
    required this.selected,
    required this.onSelected,
    required this.onOpenDetails,
    required this.statusText,
  });

  final _ActiveBookingStatus status;
  final bool selected;
  final VoidCallback onSelected;
  final VoidCallback onOpenDetails;
  final String statusText;

  @override
  Widget build(BuildContext context) {
    final bookingTitle = status.providerName.trim().isNotEmpty
        ? status.providerName
        : status.bookingType.toUpperCase() == 'SERVICE'
            ? 'Service provider'
            : 'Labour';
    return _ActiveBookingOverviewCard(
      key: ValueKey<int>(status.requestId),
      status: status,
      title: bookingTitle,
      statusLabel: statusText,
      paymentLabel: status.paymentStatus.trim().isEmpty ? 'Unpaid' : _titleCase(status.paymentStatus),
      selected: selected,
      initiallyExpanded: selected,
      onExpansionChanged: (expanded) {
        if (expanded) {
          onSelected();
        }
      },
      onOpenDetails: () {
        onSelected();
        onOpenDetails();
      },
    );
  }
}

class _ProfileBookingHistoryCard extends StatefulWidget {
  const _ProfileBookingHistoryCard({
    super.key,
    required this.item,
    required this.title,
  });

  final _ActiveBookingStatus item;
  final String title;

  @override
  State<_ProfileBookingHistoryCard> createState() => _ProfileBookingHistoryCardState();
}

class _ProfileBookingHistoryCardState extends State<_ProfileBookingHistoryCard> {
  final TextEditingController _reviewController = TextEditingController();
  final FocusNode _reviewFocusNode = FocusNode();
  int _pendingRating = 0;
  bool _submittingReview = false;
  bool _reviewExpanded = false;
  int? _submittedRating;
  String _submittedReviewComment = '';

  @override
  void initState() {
    super.initState();
    _submittedRating = widget.item.reviewRating;
    _submittedReviewComment = widget.item.reviewComment.trim();
    _reviewFocusNode.addListener(() {
      if (!mounted) {
        return;
      }
      setState(() {
        _reviewExpanded = _reviewFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _reviewController.dispose();
    _reviewFocusNode.dispose();
    super.dispose();
  }

  bool _hasUsefulAmount(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return false;
    }
    final normalized = trimmed.replaceAll(RegExp(r'[^0-9.]'), '');
    final parsed = double.tryParse(normalized);
    return parsed == null ? true : parsed > 0;
  }

  String _amountLabel(_ActiveBookingStatus item) {
    final accepted = item.totalAcceptedQuotedPriceAmount.trim();
    if (_hasUsefulAmount(accepted)) {
      return accepted;
    }
    final quoted = item.quotedPriceAmount.trim();
    if (_hasUsefulAmount(quoted)) {
      return quoted;
    }
    final bookingCharge = item.totalAcceptedBookingChargeAmount.trim();
    if (_hasUsefulAmount(bookingCharge)) {
      return bookingCharge;
    }
    if (accepted.isNotEmpty) {
      return accepted;
    }
    if (quoted.isNotEmpty) {
      return quoted;
    }
    if (bookingCharge.isNotEmpty) {
      return bookingCharge;
    }
    return '-';
  }

  String _bookingTypeLabel(_ActiveBookingStatus item) {
    return item.bookingType.trim().toUpperCase() == 'SERVICE' ? 'Service' : 'Labour';
  }

  String _providerLabel(_ActiveBookingStatus item) {
    return item.bookingType.trim().toUpperCase() == 'SERVICE' ? 'Servicemen' : 'Labour';
  }

  String _categoryLabel(_ActiveBookingStatus item) {
    final category = item.categoryLabel.trim();
    final subcategory = item.subcategoryLabel.trim();
    if (category.isNotEmpty) {
      return category;
    }
    if (subcategory.isNotEmpty) {
      return subcategory;
    }
    return _bookingTypeLabel(item);
  }

  String _subcategoryLabel(_ActiveBookingStatus item) {
    final category = item.categoryLabel.trim().toLowerCase();
    final subcategory = item.subcategoryLabel.trim();
    if (subcategory.isEmpty || subcategory.toLowerCase() == category) {
      return '';
    }
    return subcategory;
  }

  String _paymentLabel(_ActiveBookingStatus item) {
    final paymentStatus = item.paymentStatus.trim();
    return paymentStatus.isEmpty ? 'Unpaid' : _titleCase(paymentStatus);
  }

  String _statusLabel(_ActiveBookingStatus item) {
    final explicit = item.historyStatus.trim().toUpperCase();
    if (explicit == 'PAYMENT_FAILED') {
      return 'Payment failed';
    }
    if (explicit == 'NO_SHOW') {
      return 'No show';
    }
    if (explicit.isNotEmpty) {
      return _titleCase(explicit.replaceAll('_', ' '));
    }
    final bookingStatus = item.bookingStatus.trim();
    return bookingStatus.isEmpty ? _titleCase(item.requestStatus) : _titleCase(bookingStatus);
  }

  String _maskedHistoryPhone(String phone) {
    final trimmed = phone.trim();
    if (trimmed.isEmpty) {
      return '-';
    }
    if (trimmed.contains('*') || trimmed.toLowerCase().contains('x')) {
      return trimmed;
    }
    final digitsOnly = trimmed.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.length < 4) {
      return '****';
    }
    final visibleTail = digitsOnly.substring(digitsOnly.length - 4);
    return '******$visibleTail';
  }

  Color _historyTopTone(_ActiveBookingStatus item) {
    final label = _statusLabel(item).trim().toUpperCase();
    if (label == 'COMPLETED') {
      return const Color(0xFFDDF2E4);
    }
    if (label == 'PAYMENT FAILED') {
      return const Color(0xFFFFE8C7);
    }
    if (label == 'NO SHOW' || label == 'CANCELLED' || label == 'CANCELED') {
      return const Color(0xFFF9E0DA);
    }
    return const Color(0xFFE3EEF9);
  }

  Color _statusColor(_ActiveBookingStatus item) {
    final label = _statusLabel(item).trim().toUpperCase();
    if (label == 'COMPLETED') {
      return const Color(0xFF177245);
    }
    if (label == 'PAYMENT FAILED') {
      return const Color(0xFFC67A1F);
    }
    if (label == 'NO SHOW' || label == 'CANCELLED' || label == 'CANCELED') {
      return const Color(0xFFB84B4B);
    }
    return const Color(0xFF49637D);
  }

  Color _paymentColor(_ActiveBookingStatus item) {
    switch (item.paymentStatus.trim().toUpperCase()) {
      case 'PAID':
        return const Color(0xFF177245);
      case 'FAILED':
        return const Color(0xFFB84B4B);
      case 'REFUNDED':
        return const Color(0xFF8552D8);
      default:
        return const Color(0xFFC67A1F);
    }
  }

  Color _bookingStatusColor(_ActiveBookingStatus item) {
    final normalized = item.bookingStatus.trim().toUpperCase();
    switch (normalized) {
      case 'COMPLETED':
        return const Color(0xFF177245);
      case 'CANCELLED':
        return const Color(0xFFB84B4B);
      case 'IN_PROGRESS':
      case 'ARRIVED':
        return const Color(0xFFCB6E5B);
      case 'PAYMENT_PENDING':
      case 'PAYMENT_COMPLETED':
        return const Color(0xFFC67A1F);
      default:
        return const Color(0xFF49637D);
    }
  }

  (String, Color) _ratingTone(int rating) {
    switch (rating) {
      case 1:
        return ('Bad', const Color(0xFF8B1E1E));
      case 2:
        return ('Poor', const Color(0xFFE53935));
      case 3:
        return ('Okay', const Color(0xFFE7B928));
      case 4:
        return ('Good', const Color(0xFF53B96A));
      case 5:
        return ('Excellent', const Color(0xFF0B7A3B));
      default:
        return ('', const Color(0xFF22314D));
    }
  }

  bool _canSubmitReview(_ActiveBookingStatus item) {
    if (item.bookingId <= 0) {
      return false;
    }
    final paymentStatus = item.paymentStatus.trim().toUpperCase();
    if (paymentStatus == 'FAILED') {
      return false;
    }
    final historyStatus = item.historyStatus.trim().toUpperCase();
    final bookingStatus = item.bookingStatus.trim().toUpperCase();
    return historyStatus == 'COMPLETED' ||
        historyStatus == 'CANCELLED' ||
        historyStatus == 'NO_SHOW' ||
        bookingStatus == 'COMPLETED' ||
        bookingStatus == 'CANCELLED';
  }

  Future<void> _submitReview({required int rating, required String comment}) async {
    final item = widget.item;
    if (rating <= 0 || _submittingReview) {
      return;
    }
    setState(() => _submittingReview = true);
    try {
      await _UserAppApi.submitBookingReview(
        bookingId: item.bookingId,
        rating: rating,
        comment: comment.trim(),
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _submittedRating = rating;
        _submittedReviewComment = comment.trim();
        _submittingReview = false;
        if (_submittedReviewComment.isNotEmpty) {
          _reviewController.text = _submittedReviewComment;
        }
      });
      _reviewFocusNode.unfocus();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            comment.trim().isEmpty ? 'Rating saved.' : 'Review saved.',
          ),
        ),
      );
    } on _UserAppApiException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _submittingReview = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _submittingReview = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not submit review right now.')),
      );
    }
  }

  Future<void> _submitRatingOnly(int rating) async {
    setState(() {
      _pendingRating = rating;
    });
    await _submitReview(
      rating: rating,
      comment: _submittedReviewComment.isNotEmpty ? _submittedReviewComment : _reviewController.text.trim(),
    );
  }

  String _formatCreatedAt(DateTime? value) {
    if (value == null) {
      return '-';
    }
    final local = value.toLocal();
    final months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    final meridiem = local.hour >= 12 ? 'PM' : 'AM';
    return '${local.day} ${months[local.month - 1]} ${local.year}, $hour:$minute $meridiem';
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final amountLabel = _amountLabel(item);
    final providerLabel = _providerLabel(item);
    final categoryLabel = _categoryLabel(item);
    final subcategoryLabel = _subcategoryLabel(item);
    final paymentLabel = _paymentLabel(item);
    final statusLabel = _statusLabel(item);
    final maskedPhone = _maskedHistoryPhone(item.providerPhone);
    final canSubmitReview = _canSubmitReview(item);
    final submittedRating = _submittedRating;
    final submittedReviewComment = _submittedReviewComment.trim();
    final effectiveReviewRating = submittedRating ?? (_pendingRating > 0 ? _pendingRating : null);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _historyTopTone(item),
            const Color(0xFFEAF3FF),
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFDCE4EE)),
        boxShadow: [
          BoxShadow(
            color: const Color(0x161F2430),
            blurRadius: 18,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    item.bookingCode.trim().isNotEmpty ? item.bookingCode : item.requestCode,
                    style: const TextStyle(
                      color: Color(0xFFBE6F5D),
                      fontWeight: FontWeight.w900,
                      fontSize: 12.4,
                      letterSpacing: 0.28,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  statusLabel,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    color: _statusColor(item),
                    fontWeight: FontWeight.w900,
                    fontSize: 11.8,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 11),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.96),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFF0E1D9)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              providerLabel,
                              style: const TextStyle(
                                color: Color(0xFF6E7A8E),
                                fontWeight: FontWeight.w600,
                                fontSize: 11.8,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF22314D),
                                fontWeight: FontWeight.w600,
                                fontSize: 14.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      _ActiveBookingAvatar(status: item, size: 40),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'Amount',
                            style: TextStyle(
                              color: Color(0xFF6E7A8E),
                              fontWeight: FontWeight.w800,
                              fontSize: 11.4,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            amountLabel,
                            textAlign: TextAlign.end,
                            style: TextStyle(
                              color: _paymentColor(item),
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              categoryLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF22314D),
                                fontWeight: FontWeight.w700,
                                fontSize: 14.2,
                              ),
                            ),
                            if (subcategoryLabel.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                subcategoryLabel,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFF7D889A),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11.8,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Mobile',
                            style: const TextStyle(
                              color: Color(0xFF8D8A86),
                              fontWeight: FontWeight.w700,
                              fontSize: 11.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7F3F0),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: const Color(0xFFE6D9D1),
                              ),
                            ),
                            child: Text(
                              maskedPhone,
                              style: const TextStyle(
                                color: Color(0xFF7D889A),
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _ProfileBookingInfoRow(
                    label: 'Booking status',
                    value: item.bookingStatus.trim().isEmpty ? statusLabel : _titleCase(item.bookingStatus),
                    valueColor: _bookingStatusColor(item),
                  ),
                  _ProfileBookingInfoRow(
                    label: 'Payment status',
                    value: paymentLabel,
                    valueColor: _paymentColor(item),
                  ),
                  if (item.cancelReason.trim().isNotEmpty)
                    _ProfileBookingInfoRow(
                      label: 'Cancel reason',
                      value: item.cancelReason.trim(),
                      valueColor: const Color(0xFFB84B4B),
                    ),
                  if (submittedRating != null) ...[
                    Builder(
                      builder: (context) {
                        final (ratingLabel, ratingColor) = _ratingTone(submittedRating);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                width: 116,
                                child: Text(
                                  'Rating',
                                  style: TextStyle(
                                    color: Color(0xFF8C7E73),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Wrap(
                                      spacing: 2,
                                      children: List.generate(5, (index) {
                                        final star = index + 1;
                                        final selected = index < submittedRating;
                                        final (_, tappedColor) = _ratingTone(star);
                                        return InkWell(
                                          onTap: _submittingReview ? null : () => _submitRatingOnly(star),
                                          borderRadius: BorderRadius.circular(999),
                                          child: Icon(
                                            selected ? Icons.star_rounded : Icons.star_border_rounded,
                                            size: 18,
                                            color: selected ? tappedColor : tappedColor.withValues(alpha: 0.38),
                                          ),
                                        );
                                      }),
                                    ),
                                    if (ratingLabel.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        '$submittedRating.0 • $ratingLabel',
                                        style: TextStyle(
                                          color: ratingColor,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ] else if (canSubmitReview) ...[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            width: 116,
                            child: Text(
                              'Rating',
                              style: TextStyle(
                                color: Color(0xFF8C7E73),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Expanded(
                                child: Wrap(
                                  spacing: 4,
                                  children: List.generate(5, (index) {
                                    final star = index + 1;
                                    final (_, ratingColor) = _ratingTone(star);
                                    final selected = star <= _pendingRating;
                                    return InkWell(
                                  onTap: _submittingReview ? null : () => _submitRatingOnly(star),
                                  borderRadius: BorderRadius.circular(999),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 2),
                                    child: Icon(
                                      selected ? Icons.star_rounded : Icons.star_border_rounded,
                                      size: 22,
                                      color: selected ? ratingColor : const Color(0xFFD1C4B8),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (canSubmitReview && submittedReviewComment.isEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            width: 116,
                            child: Text(
                              'Review',
                              style: TextStyle(
                                color: Color(0xFF8C7E73),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 180),
                                        height: _reviewExpanded ? 78 : 40,
                                        curve: Curves.easeOut,
                                        child: TextField(
                                          controller: _reviewController,
                                          focusNode: _reviewFocusNode,
                                          enabled: !_submittingReview,
                                          maxLines: null,
                                          expands: true,
                                          textCapitalization: TextCapitalization.sentences,
                                          onTapOutside: (_) => _reviewFocusNode.unfocus(),
                                          decoration: InputDecoration(
                                            hintText: 'Write review',
                                            hintStyle: const TextStyle(
                                              fontSize: 7.0,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFFB2A79B),
                                            ),
                                            isDense: true,
                                            filled: true,
                                            fillColor: const Color(0xFFFDFCFA),
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(14),
                                              borderSide: const BorderSide(color: Color(0xFFE5D9D0)),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(14),
                                              borderSide: const BorderSide(color: Color(0xFFE5D9D0)),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(14),
                                              borderSide: const BorderSide(color: Color(0xFFCB6E5B), width: 1.2),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    SizedBox(
                                      height: 36,
                                      child: ElevatedButton(
                                        onPressed: (effectiveReviewRating == null || _submittingReview)
                                            ? null
                                            : () => _submitReview(
                                                  rating: effectiveReviewRating,
                                                  comment: _reviewController.text.trim(),
                                                ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFFCB6E5B),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(horizontal: 12),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: Text(
                                          _submittingReview ? 'Saving...' : 'Submit',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 11.8,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (submittedReviewComment.isNotEmpty)
                    _ProfileBookingInfoRow(
                      label: 'Review',
                      value: submittedReviewComment,
                    ),
                  const SizedBox(height: 2),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      _formatCreatedAt(item.createdAt),
                      textAlign: TextAlign.end,
                      style: const TextStyle(
                        color: Color(0xFF8C7E73),
                        fontWeight: FontWeight.w700,
                        fontSize: 11.6,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
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

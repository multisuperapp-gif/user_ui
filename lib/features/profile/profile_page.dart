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
  static const int _maxProfilePhotoBytes = 3 * 1024 * 1024;
  static const List<String> _genderOptions = ['Male', 'Female', 'Other'];

  @override
  void initState() {
    super.initState();
    _profile = widget.initialProfile;
    unawaited(_restoreCachedProfile());
    _loadProfile();
  }

  Future<void> _restoreCachedProfile() async {
    if (_profile != null) {
      return;
    }
    final raw = await _LocalSessionStore.readProfileCache();
    if (raw == null || raw.trim().isEmpty || !mounted) {
      return;
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return;
      }
      setState(() {
        _profile = _UserProfileData.fromJson(decoded);
      });
    } catch (_) {
      return;
    }
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

  String _profilePhotoDataUriFromBytes(Uint8List bytes, {String mimeType = 'image/png'}) {
    return 'data:$mimeType;base64,${base64Encode(bytes)}';
  }

  Future<void> _pickAndApplyDraftPhoto({
    required bool saving,
    required ValueSetter<String> setDraftPhotoDataUri,
    required ValueSetter<Uint8List?> setDraftPhotoBytes,
  }) async {
    if (saving) {
      return;
    }
    final picked = await _pickProfilePhotoDraft();
    if (picked == null) {
      return;
    }
    final cropped = await _cropProfilePhotoDraft(picked.bytes);
    if (cropped != null) {
      setDraftPhotoDataUri(cropped.dataUri);
      setDraftPhotoBytes(cropped.bytes);
      return;
    }
    setDraftPhotoDataUri(picked.dataUri);
    setDraftPhotoBytes(picked.bytes);
  }

  Future<({String dataUri, Uint8List bytes})?> _pickProfilePhotoDraft() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
    );
    if (picked == null) {
      return null;
    }
    final bytes = await picked.readAsBytes();
    if (_isPhotoTooLarge(bytes)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please choose a photo up to 3 MB.')),
        );
      }
      return null;
    }
    return (
      dataUri: _profilePhotoDataUriFromBytes(bytes, mimeType: _profilePhotoMimeType(picked.path)),
      bytes: bytes,
    );
  }

  Future<({String dataUri, Uint8List bytes})?> _cropProfilePhotoDraft(Uint8List currentBytes) async {
    final cropped = await _openSquareCropperDialog(
      context,
      bytes: currentBytes,
      title: 'your profile photo',
    );
    if (cropped == null) {
      return null;
    }
    if (_isPhotoTooLarge(cropped.bytes)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please keep the cropped photo within 3 MB.')),
        );
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
    String selectedGender = _profile?.gender.trim() ?? '';
    DateTime? selectedDob = _profile?.dob == null ? null : DateUtils.dateOnly(_profile!.dob!);
    bool saving = false;

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
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(error.message)),
                  );
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
                                setDraftPhotoDataUri: (value) => setSheetState(() => draftPhotoDataUri = value),
                                setDraftPhotoBytes: (value) => setSheetState(() => draftPhotoBytes = value),
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
                                child: draftPhotoBytes == null
                                    ? const Icon(Icons.add_a_photo_rounded, size: 34, color: Color(0xFF324360))
                                    : Image.memory(draftPhotoBytes!, fit: BoxFit.cover),
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
                                    setDraftPhotoDataUri: (value) => setSheetState(() => draftPhotoDataUri = value),
                                    setDraftPhotoBytes: (value) => setSheetState(() => draftPhotoBytes = value),
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
                      if (draftPhotoDataUri.isNotEmpty)
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
                                        final cropped = await _cropProfilePhotoDraft(draftPhotoBytes!);
                                        if (cropped == null) {
                                          return;
                                        }
                                        setSheetState(() {
                                          draftPhotoDataUri = cropped.dataUri;
                                          draftPhotoBytes = cropped.bytes;
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
                                          setDraftPhotoDataUri: (value) => setSheetState(() => draftPhotoDataUri = value),
                                          setDraftPhotoBytes: (value) => setSheetState(() => draftPhotoBytes = value),
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
                            child: photoBytes == null
                                ? const Icon(Icons.add_a_photo_rounded, size: 34, color: Color(0xFF324360))
                                : Image.memory(photoBytes, fit: BoxFit.cover),
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
                    if (photoBytes == null) ...[
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
  static final RegExp _otpRegex = RegExp(r'^\d{6}$');
  final TextEditingController _startWorkOtpController = TextEditingController();
  bool _loading = true;
  bool _paying = false;
  bool _verifyingStartOtp = false;
  bool _generatingCompleteOtp = false;
  bool _requestingMutualCancelOtp = false;
  String? _error;
  String? _startWorkOtpError;
  String? _completeWorkOtpCode;
  String? _mutualCancelOtpCode;
  _ActiveBookingStatus? _status;
  List<_ActiveBookingStatus> _activeStatuses = const <_ActiveBookingStatus>[];
  List<_ActiveBookingStatus> _historyStatuses = const <_ActiveBookingStatus>[];
  String _selectedBookingStatusFilter = 'All';
  String _selectedBookingTypeFilter = 'All';
  String _selectedPaymentStatusFilter = 'All';
  DateTime? _selectedHistoryStartDate;
  DateTime? _selectedHistoryEndDate;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  @override
  void dispose() {
    _startWorkOtpController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final activeStatuses = await _UserAppApi.fetchActiveBookingStatuses();
      final historyStatuses = await _UserAppApi.fetchBookingHistoryStatuses();
      if (!mounted) {
        return;
      }
      setState(() {
        _activeStatuses = activeStatuses;
        _historyStatuses = historyStatuses;
        _status = activeStatuses.isEmpty ? null : activeStatuses.first;
        _startWorkOtpError = null;
        if (_status?.bookingStatus.toUpperCase() != 'IN_PROGRESS') {
          _completeWorkOtpCode = null;
          _mutualCancelOtpCode = null;
        }
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
          if (item.createdAt == null) {
            return _selectedHistoryStartDate == null && _selectedHistoryEndDate == null;
          }
          final created = DateUtils.dateOnly(item.createdAt!);
          if (_selectedHistoryStartDate != null &&
              created.isBefore(DateUtils.dateOnly(_selectedHistoryStartDate!))) {
            return false;
          }
          if (_selectedHistoryEndDate != null &&
              created.isAfter(DateUtils.dateOnly(_selectedHistoryEndDate!))) {
            return false;
          }
          return true;
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

  Future<void> _pickFilterDate({required bool isStart}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart
          ? (_selectedHistoryStartDate ?? _selectedHistoryEndDate ?? now)
          : (_selectedHistoryEndDate ?? _selectedHistoryStartDate ?? now),
      firstDate: DateTime(now.year - 2),
      lastDate: now,
    );
    if (!mounted || picked == null) {
      return;
    }
    setState(() {
      final normalized = DateUtils.dateOnly(picked);
      if (isStart) {
        _selectedHistoryStartDate = normalized;
        if (_selectedHistoryEndDate != null && normalized.isAfter(_selectedHistoryEndDate!)) {
          _selectedHistoryEndDate = normalized;
        }
      } else {
        _selectedHistoryEndDate = normalized;
        if (_selectedHistoryStartDate != null && normalized.isBefore(_selectedHistoryStartDate!)) {
          _selectedHistoryStartDate = normalized;
        }
      }
    });
  }

  String _formatHistoryDate(DateTime? value) {
    if (value == null) {
      return '';
    }
    return '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year.toString().padLeft(4, '0')}';
  }

  _BookingHistoryStatusStyle _historyStatusStyleFor(_ActiveBookingStatus item) {
    switch (_normalizedHistoryStatus(item)) {
      case 'COMPLETED':
        return const _BookingHistoryStatusStyle(
          label: 'Completed',
          backgroundColor: Color(0xFFE4F6E8),
          textColor: Color(0xFF177245),
        );
      case 'NO_SHOW':
        return const _BookingHistoryStatusStyle(
          label: 'No show',
          backgroundColor: Color(0xFFF7D7D7),
          textColor: Color(0xFF7E1111),
        );
      case 'PAYMENT_FAILED':
        return const _BookingHistoryStatusStyle(
          label: 'Payment failed',
          backgroundColor: Color(0xFFFFF2C9),
          textColor: Color(0xFF8A6400),
        );
      case 'CANCELLED':
      default:
        return const _BookingHistoryStatusStyle(
          label: 'Canceled',
          backgroundColor: Color(0xFFFCE4E2),
          textColor: Color(0xFFB04C4C),
        );
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

  Future<void> _verifyStartWorkOtp() async {
    final status = _status;
    final otp = _startWorkOtpController.text.trim();
    if (status == null || status.bookingId <= 0 || _verifyingStartOtp) {
      return;
    }
    if (!_otpRegex.hasMatch(otp)) {
      setState(() => _startWorkOtpError = 'Enter the 6-digit OTP shared by labour.');
      return;
    }
    setState(() {
      _verifyingStartOtp = true;
      _startWorkOtpError = null;
    });
    try {
      await _UserAppApi.verifyBookingOtp(
        bookingId: status.bookingId,
        purpose: 'START_WORK',
        otpCode: otp,
      );
      if (!mounted) {
        return;
      }
      _startWorkOtpController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Work started successfully.')),
      );
      await _load();
    } on _UserAppApiException catch (error) {
      if (mounted) {
        setState(() => _startWorkOtpError = error.message);
      }
    } finally {
      if (mounted) {
        setState(() => _verifyingStartOtp = false);
      }
    }
  }

  Future<void> _generateCompleteWorkOtp() async {
    final status = _status;
    if (status == null || status.bookingId <= 0 || _generatingCompleteOtp) {
      return;
    }
    setState(() => _generatingCompleteOtp = true);
    try {
      final otp = await _UserAppApi.generateBookingOtp(
        bookingId: status.bookingId,
        purpose: 'COMPLETE_WORK',
      );
      if (!mounted) {
        return;
      }
      setState(() => _completeWorkOtpCode = otp);
    } on _UserAppApiException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
      }
    } finally {
      if (mounted) {
        setState(() => _generatingCompleteOtp = false);
      }
    }
  }

  Future<void> _requestMutualCancelOtp() async {
    final status = _status;
    if (status == null || status.bookingId <= 0 || _requestingMutualCancelOtp) {
      return;
    }
    setState(() => _requestingMutualCancelOtp = true);
    try {
      final otp = await _UserAppApi.generateBookingOtp(
        bookingId: status.bookingId,
        purpose: 'MUTUAL_CANCEL',
      );
      if (!mounted) {
        return;
      }
      setState(() => _mutualCancelOtpCode = otp);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mutual cancel OTP sent to labour.')),
      );
    } on _UserAppApiException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
      }
    } finally {
      if (mounted) {
        setState(() => _requestingMutualCancelOtp = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F2EC),
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
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
                  children: [
                    if (_status != null) ...[
                      const Text(
                        'Latest live booking',
                        style: TextStyle(
                          color: Color(0xFF22314D),
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (_activeStatuses.length > 1) ...[
                        SizedBox(
                          height: 42,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _activeStatuses.length,
                            separatorBuilder: (_, _) => const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              final active = _activeStatuses[index];
                              final selected = active.requestId == _status!.requestId;
                              return ChoiceChip(
                                label: Text(
                                  active.bookingCode.trim().isNotEmpty ? active.bookingCode : active.requestCode,
                                ),
                                selected: selected,
                                onSelected: (_) {
                                  setState(() {
                                    _status = active;
                                  });
                                },
                                selectedColor: const Color(0xFFF7D7CF),
                                backgroundColor: Colors.white,
                                labelStyle: TextStyle(
                                  color: selected ? const Color(0xFF9F4F40) : const Color(0xFF66748C),
                                  fontWeight: FontWeight.w800,
                                ),
                                side: BorderSide(
                                  color: selected ? const Color(0xFFCB6E5B) : const Color(0xFFE4D8D0),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(26),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0x14000000),
                              blurRadius: 20,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                          Text(
                            _status!.providerName.trim().isNotEmpty
                                ? _status!.providerName
                                : _status!.bookingType.toUpperCase() == 'SERVICE'
                                    ? 'Service booking'
                                    : 'Labour booking',
                            style: const TextStyle(
                              color: Color(0xFF22314D),
                              fontWeight: FontWeight.w900,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _status!.canMakePayment
                                ? 'Accepted. Confirm booking by making booking charges.'
                                : _status!.bookingStatus.trim().isNotEmpty
                                    ? _titleCase(_status!.bookingStatus)
                                    : _titleCase(_status!.requestStatus),
                            style: const TextStyle(
                              color: Color(0xFF5F6E85),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 18),
                          _ProfileBookingInfoRow(label: 'Request code', value: _status!.requestCode),
                          if (_status!.bookingCode.trim().isNotEmpty)
                            _ProfileBookingInfoRow(label: 'Booking code', value: _status!.bookingCode),
                          if (_status!.distanceLabel.trim().isNotEmpty)
                            _ProfileBookingInfoRow(label: 'Distance', value: _status!.distanceLabel),
                          if (_status!.providerPhone.trim().isNotEmpty)
                            _ProfileBookingInfoRow(label: 'Phone', value: _status!.providerPhone),
                          if (_status!.totalAcceptedQuotedPriceAmount.trim().isNotEmpty)
                            _ProfileBookingInfoRow(label: 'Labour amount', value: _status!.totalAcceptedQuotedPriceAmount),
                          if (_status!.totalAcceptedBookingChargeAmount.trim().isNotEmpty)
                            _ProfileBookingInfoRow(label: 'Booking fees', value: _status!.totalAcceptedBookingChargeAmount)
                          else if (_status!.quotedPriceAmount.trim().isNotEmpty)
                            _ProfileBookingInfoRow(label: 'Booking fees', value: _status!.quotedPriceAmount),
                          if (_status!.bookingStatus.toUpperCase() == 'ARRIVED') ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF8EA),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: const Color(0xFFE8CA82)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Start work OTP',
                                    style: TextStyle(color: Color(0xFF22314D), fontWeight: FontWeight.w900),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'Enter the OTP shared by labour after reaching your destination.',
                                    style: TextStyle(color: Color(0xFF5F6E85), fontWeight: FontWeight.w700, height: 1.35),
                                  ),
                                  const SizedBox(height: 12),
                                  TextField(
                                    controller: _startWorkOtpController,
                                    keyboardType: TextInputType.number,
                                    scrollPadding: const EdgeInsets.only(bottom: 12),
                                    onTap: () => _ensureFieldVisibleAboveKeyboard(context),
                                    maxLength: 6,
                                    onChanged: (_) {
                                      if (_startWorkOtpError != null) {
                                        setState(() => _startWorkOtpError = null);
                                      }
                                    },
                                    decoration: InputDecoration(
                                      counterText: '',
                                      labelText: '6-digit start OTP',
                                      errorText: _startWorkOtpError,
                                      prefixIcon: const Icon(Icons.password_rounded),
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    child: FilledButton(
                                      onPressed: _verifyingStartOtp ? null : _verifyStartWorkOtp,
                                      style: FilledButton.styleFrom(
                                        backgroundColor: const Color(0xFFCB6E5B),
                                        foregroundColor: Colors.white,
                                        minimumSize: const Size.fromHeight(48),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                      ),
                                      child: Text(_verifyingStartOtp ? 'Verifying...' : 'Start work'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          if (_status!.bookingStatus.toUpperCase() == 'IN_PROGRESS') ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF7FF),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: const Color(0xFFC4DFFF)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Work in progress',
                                    style: TextStyle(color: Color(0xFF22314D), fontWeight: FontWeight.w900),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'When the work is complete, generate an OTP and share it with labour to complete the booking.',
                                    style: TextStyle(color: Color(0xFF5F6E85), fontWeight: FontWeight.w700, height: 1.35),
                                  ),
                                  if ((_completeWorkOtpCode ?? '').trim().isNotEmpty) ...[
                                    const SizedBox(height: 12),
                                    Text(
                                      _completeWorkOtpCode!,
                                      style: const TextStyle(
                                        color: Color(0xFF245FA8),
                                        fontWeight: FontWeight.w900,
                                        fontSize: 26,
                                        letterSpacing: 2,
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    child: FilledButton(
                                      onPressed: _generatingCompleteOtp ? null : _generateCompleteWorkOtp,
                                      style: FilledButton.styleFrom(
                                        backgroundColor: const Color(0xFF245FA8),
                                        foregroundColor: Colors.white,
                                        minimumSize: const Size.fromHeight(48),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                      ),
                                      child: Text(_generatingCompleteOtp ? 'Generating...' : 'Generate completion OTP'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFEBEB),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: const Color(0xFFFFB3B3)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Need mutual cancellation?',
                                    style: TextStyle(color: Color(0xFF8A1212), fontWeight: FontWeight.w900),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'Use this only if both you and labour agree to cancel after work has started.',
                                    style: TextStyle(color: Color(0xFF7A1010), fontWeight: FontWeight.w700, height: 1.35),
                                  ),
                                  if ((_mutualCancelOtpCode ?? '').trim().isNotEmpty) ...[
                                    const SizedBox(height: 12),
                                    Text(
                                      'Cancel OTP: $_mutualCancelOtpCode',
                                      style: const TextStyle(
                                        color: Color(0xFFB42318),
                                        fontWeight: FontWeight.w900,
                                        fontSize: 18,
                                        letterSpacing: 0.6,
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton(
                                      onPressed: _requestingMutualCancelOtp ? null : _requestMutualCancelOtp,
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: const Color(0xFFB42318),
                                        side: const BorderSide(color: Color(0xFFB42318)),
                                        minimumSize: const Size.fromHeight(48),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                      ),
                                      child: Text(_requestingMutualCancelOtp ? 'Sending...' : 'Request mutual cancel OTP'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 18),
                          FilledButton(
                            onPressed: _status!.canMakePayment && !_paying ? _makePayment : null,
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFFCB6E5B),
                              foregroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(50),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                            ),
                            child: Text(_paying ? 'Processing...' : _status!.canMakePayment ? 'Make payment' : 'Waiting for provider'),
                          ),
                          ],
                        ),
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
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
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
                          InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => _pickFilterDate(isStart: true),
                            child: _BookingFilterChip(
                              icon: Icons.calendar_today_rounded,
                              label: _selectedHistoryStartDate == null
                                  ? 'Start date'
                                  : 'From ${_formatHistoryDate(_selectedHistoryStartDate)}',
                              active: _selectedHistoryStartDate != null,
                            ),
                          ),
                          InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => _pickFilterDate(isStart: false),
                            child: _BookingFilterChip(
                              icon: Icons.event_available_rounded,
                              label: _selectedHistoryEndDate == null
                                  ? 'End date'
                                  : 'To ${_formatHistoryDate(_selectedHistoryEndDate)}',
                              active: _selectedHistoryEndDate != null,
                            ),
                          ),
                          if (_selectedHistoryStartDate != null ||
                              _selectedHistoryEndDate != null ||
                              _selectedBookingStatusFilter != 'All' ||
                              _selectedBookingTypeFilter != 'All' ||
                              _selectedPaymentStatusFilter != 'All')
                            InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () => setState(() {
                                _selectedHistoryStartDate = null;
                                _selectedHistoryEndDate = null;
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
                          final historyStyle = _historyStatusStyleFor(item);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          _historyTitleFor(item),
                                          style: const TextStyle(
                                            color: Color(0xFF22314D),
                                            fontWeight: FontWeight.w900,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: historyStyle.backgroundColor,
                                          borderRadius: BorderRadius.circular(999),
                                        ),
                                        child: Text(
                                          historyStyle.label,
                                          style: TextStyle(
                                            color: historyStyle.textColor,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 11.5,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  _ProfileBookingInfoRow(
                                    label: 'Booking code',
                                    value: item.bookingCode.trim().isNotEmpty ? item.bookingCode : item.requestCode,
                                  ),
                                  _ProfileBookingInfoRow(
                                    label: 'Payment',
                                    value: item.paymentStatus.trim().isEmpty ? 'Not started' : _titleCase(item.paymentStatus),
                                  ),
                                  if (item.totalAcceptedBookingChargeAmount.trim().isNotEmpty)
                                    _ProfileBookingInfoRow(
                                      label: 'Booking fees',
                                      value: item.totalAcceptedBookingChargeAmount,
                                    )
                                  else if (item.quotedPriceAmount.trim().isNotEmpty)
                                    _ProfileBookingInfoRow(
                                      label: 'Amount',
                                      value: item.quotedPriceAmount,
                                    ),
                                  if (item.createdAt != null)
                                    _ProfileBookingInfoRow(
                                      label: 'Date',
                                      value: _formatHistoryDate(item.createdAt),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
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

class _BookingHistoryStatusStyle {
  const _BookingHistoryStatusStyle({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  final String label;
  final Color backgroundColor;
  final Color textColor;
}

class _ProfileBookingInfoRow extends StatelessWidget {
  const _ProfileBookingInfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

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
              style: const TextStyle(
                color: Color(0xFF22314D),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
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

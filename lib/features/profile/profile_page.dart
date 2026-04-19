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
                    _DrawerAction(
                      icon: Icons.local_shipping_outlined,
                      label: 'Live bookings',
                      onTap: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const _LiveBookingsPage(),
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

class _LiveBookingsPage extends StatefulWidget {
  const _LiveBookingsPage();

  @override
  State<_LiveBookingsPage> createState() => _LiveBookingsPageState();
}

class _LiveBookingsPageState extends State<_LiveBookingsPage> {
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
      final status = await _UserAppApi.fetchLatestActiveBookingStatus();
      if (!mounted) {
        return;
      }
      setState(() {
        _status = status;
        _startWorkOtpError = null;
        if (status?.bookingStatus.toUpperCase() != 'IN_PROGRESS') {
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
          'Live bookings',
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
                      title: 'Loading live booking',
                      message: 'Checking your latest active booking request.',
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
                      title: 'Could not load live booking',
                      message: _error!,
                      actionLabel: 'Try Again',
                      onAction: _load,
                    ),
                  ],
                )
              : _status == null
              ? ListView(
                  padding: const EdgeInsets.all(24),
                  children: const [
                    _AsyncStateCard(
                      icon: Icons.inbox_outlined,
                      title: 'No live booking',
                      message: 'Once a labour or service booking is active, it will appear here.',
                    ),
                  ],
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
                  children: [
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
                                    scrollPadding: const EdgeInsets.only(bottom: 220),
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
                  ],
                ),
        ),
      ),
    );
  }
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

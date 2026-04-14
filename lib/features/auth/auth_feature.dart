part of '../../main.dart';

class LaunchSplashPage extends StatefulWidget {
  const LaunchSplashPage({super.key});

  @override
  State<LaunchSplashPage> createState() => _LaunchSplashPageState();
}

class _LaunchSplashPageState extends State<LaunchSplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2900),
    )..forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future<void>.delayed(const Duration(milliseconds: 450), () {
          _navigateFromSplash();
        });
      }
    });
  }

  Future<void> _navigateFromSplash() async {
    if (!mounted || _navigated) {
      return;
    }
    _navigated = true;
    final savedPhoneNumber = await _LocalSessionStore.readPhoneNumber();
    final savedUserId = await _LocalSessionStore.readUserId();
    if (savedPhoneNumber != null) {
      if (savedUserId == null) {
        await _LocalSessionStore.clear();
      }
    }
    if (!mounted) {
      return;
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => savedPhoneNumber == null || savedUserId == null
            ? const LoginPage()
            : UserHomePage(phoneNumber: savedPhoneNumber),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Animation<double> _interval(double begin, double end, [Curve curve = Curves.easeOutCubic]) {
    return CurvedAnimation(
      parent: _controller,
      curve: Interval(begin, end, curve: curve),
    );
  }

  @override
  Widget build(BuildContext context) {
    final labourMotion = _interval(0.0, 0.55);
    final serviceMotion = _interval(0.12, 0.65);
    final shopMotion = _interval(0.22, 0.75);

    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF18213A),
                  Color(0xFFCB6E5B),
                  Color(0xFFDF7DA0),
                ],
              ),
            ),
            child: SafeArea(
              child: Stack(
                children: [
                  Positioned(
                    left: -60,
                    top: -40,
                    child: Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.16),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: -40,
                    bottom: 160,
                    child: Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFF5C8FD8).withValues(alpha: 0.24),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 36, 24, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Opacity(
                          opacity: _interval(0.0, 0.28).value,
                          child: Transform.translate(
                            offset: Offset(0, 24 * (1 - _interval(0.0, 0.28).value)),
                            child: const Text(
                              'YOUR CITY,\nONE FAST APP',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 34,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -1.1,
                                height: 0.96,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Opacity(
                          opacity: _interval(0.12, 0.38).value,
                          child: Text(
                            'Labour at work, service on the way, shops opening live.',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.84),
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                        const Spacer(),
                        SizedBox(
                          height: 260,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                left: 0,
                                right: 0,
                                bottom: 18,
                                child: Container(
                                  height: 84,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.white.withValues(alpha: 0.08),
                                        Colors.black.withValues(alpha: 0.18),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 8,
                                bottom: 34,
                                child: _LaunchSceneCard(
                                  title: 'LABOUR',
                                  subtitle: 'Working now',
                                  accent: const Color(0xFFF2A13D),
                                  icon: Icons.engineering_rounded,
                                  progress: labourMotion.value,
                                  tilt: -0.08,
                                ),
                              ),
                              Positioned(
                                left: 120,
                                bottom: 46,
                                child: _LaunchSceneCard(
                                  title: 'SERVICE',
                                  subtitle: 'Serving live',
                                  accent: const Color(0xFF5C8FD8),
                                  icon: Icons.handyman_rounded,
                                  progress: serviceMotion.value,
                                  tilt: 0.03,
                                ),
                              ),
                              Positioned(
                                right: 8,
                                bottom: 34,
                                child: _LaunchSceneCard(
                                  title: 'SHOP',
                                  subtitle: 'Launching now',
                                  accent: const Color(0xFF4DAF50),
                                  icon: Icons.storefront_rounded,
                                  progress: shopMotion.value,
                                  tilt: 0.08,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _FallingBrandLetter(
                              letter: 'M',
                              accent: const Color(0xFFCB6E5B),
                              progress: _interval(0.48, 0.68, Curves.easeOutBack).value,
                            ),
                            const SizedBox(width: 12),
                            _FallingBrandLetter(
                              letter: 'S',
                              accent: const Color(0xFFDF7DA0),
                              progress: _interval(0.58, 0.78, Curves.easeOutBack).value,
                            ),
                            const SizedBox(width: 12),
                            _FallingBrandLetter(
                              letter: 'A',
                              accent: const Color(0xFF5C8FD8),
                              progress: _interval(0.68, 0.88, Curves.easeOutBack).value,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: Opacity(
                            opacity: _interval(0.78, 1.0).value,
                            child: Text(
                              'Multi Super App',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.92),
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                  ),
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
        },
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isSendingOtp = false;

  Future<void> _continueToOtp() async {
    final cleanedPhone = _phoneController.text.trim();
    if (cleanedPhone.isEmpty || cleanedPhone.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid phone number to continue.')),
      );
      return;
    }
    setState(() {
      _isSendingOtp = true;
    });
    try {
      final otpDispatch = await _UserAppApi.sendUserOtp(cleanedPhone);
      if (!mounted) {
        return;
      }
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => OtpVerificationPage(
            phoneNumber: cleanedPhone,
            requestId: otpDispatch.requestId,
          ),
        ),
      );
    } on _UserAppApiException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message)),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not send OTP right now.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSendingOtp = false;
        });
      }
    }
  }

  void _showPolicySheet(String title, String body) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFFF7F2EC),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 46,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD7CEC4),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  body,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF5B544D),
                        height: 1.55,
                        fontSize: 15,
                      ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFD78268), Color(0xFFDF7DA0), Color(0xFFF7F2EC)],
            stops: [0, 0.56, 0.56],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                flex: 5,
                child: const _TopDiscoveryHero(
                  title: 'DISCOVER HELP,\nHOME CARE & SHOPS\nNEAR YOU',
                  subtitle:
                      'Labour, repairs, groceries, dining, pharmacy and many more from one place.',
                ),
              ),
              Expanded(
                flex: 5,
                child: Container(
                  width: double.infinity,
                  color: const Color(0xFFF7F2EC),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _LoginQuickIcon(
                              icon: Icons.engineering_rounded,
                              accent: Color(0xFFF2A13D),
                            ),
                            _LoginQuickIcon(
                              icon: Icons.handyman_rounded,
                              accent: Color(0xFFCB6E5B),
                            ),
                            _LoginQuickIcon(
                              icon: Icons.local_grocery_store_rounded,
                              accent: Color(0xFF4DAF50),
                            ),
                            _LoginQuickIcon(
                              icon: Icons.local_pharmacy_rounded,
                              accent: Color(0xFF1FB8A4),
                            ),
                            _LoginQuickIcon(
                              icon: Icons.restaurant_rounded,
                              accent: Color(0xFFFF954A),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Center(
                          child: Text(
                            'Log in or sign up',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontSize: 19,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF29314A),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            const _CountrySelector(),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _PhoneInputField(controller: _phoneController),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isSendingOtp ? null : _continueToOtp,
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: const Color(0xFFCB6E5B),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: const RoundedRectangleBorder(),
                              textStyle: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            child: Text(_isSendingOtp ? 'Sending OTP...' : 'Continue'),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              Text(
                                'By continuing, you agree to our',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: const Color(0xFF7A736A),
                                ),
                              ),
                              const SizedBox(width: double.infinity),
                              _PolicyLink(
                                label: 'Terms of Service',
                                onTap: () => _showPolicySheet(
                                  'Terms of Service',
                                  'Use of the platform means you agree to provide valid details, maintain lawful conduct, and respect provider and shop service rules. Bookings, cancellations, penalties, refunds and payment timelines will follow the app policies shown during checkout.',
                                ),
                              ),
                              _PolicyLink(
                                label: 'Privacy Policy',
                                onTap: () => _showPolicySheet(
                                  'Privacy Policy',
                                  'We use your phone number, device details, saved addresses and booking activity to help you sign in, place bookings, receive updates and improve trust and safety. Sensitive details are handled only for service delivery, support and compliance.',
                                ),
                              ),
                              _PolicyLink(
                                label: 'Content Policy',
                                onTap: () => _showPolicySheet(
                                  'Content Policy',
                                  'Users, providers and shops must not upload misleading, abusive, unsafe or illegal content. Fraudulent listings, fake bookings, offensive media and harmful behavior can result in suspension or permanent removal from the platform.',
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 22),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OtpVerificationPage extends StatefulWidget {
  const OtpVerificationPage({
    super.key,
    required this.phoneNumber,
    required this.requestId,
  });

  final String phoneNumber;
  final String requestId;

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  static const _resendCooldownSeconds = 60;
  static const _resendLockoutSeconds = 30 * 60;
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  String? _errorText;
  Timer? _resendTimer;
  int _resendCountdownSeconds = _resendCooldownSeconds;
  int _resendAttempts = 0;
  bool _resendHidden = false;
  bool _isVerifying = false;
  late String _requestId;

  String get _enteredOtp => _otpControllers.map((controller) => controller.text).join();

  bool get _canVerify => _enteredOtp.length == 6;
  bool get _canResend => !_resendHidden && _resendCountdownSeconds == 0;

  String get _formattedCountdown {
    final minutes = (_resendCountdownSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_resendCountdownSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void initState() {
    super.initState();
    _requestId = widget.requestId;
    _startResendTimer(
      seconds: _resendCooldownSeconds,
      hideButtonWhileCounting: false,
      resetAttemptsOnComplete: false,
    );
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    for (final controller in _otpControllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onOtpChanged(int index, String value) {
    final digit = value.isEmpty ? '' : value.substring(value.length - 1);
    _otpControllers[index].value = TextEditingValue(
      text: digit,
      selection: TextSelection.collapsed(offset: digit.length),
    );

    if (_errorText != null) {
      setState(() {
        _errorText = null;
      });
    } else {
      setState(() {});
    }

    if (digit.isNotEmpty && index < _focusNodes.length - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    if (digit.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  void _startResendTimer({
    required int seconds,
    required bool hideButtonWhileCounting,
    required bool resetAttemptsOnComplete,
  }) {
    _resendTimer?.cancel();
    _resendCountdownSeconds = seconds;
    _resendHidden = hideButtonWhileCounting;
    setState(() {});

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_resendCountdownSeconds <= 1) {
        timer.cancel();
        setState(() {
          _resendCountdownSeconds = 0;
          _resendHidden = false;
          if (resetAttemptsOnComplete) {
            _resendAttempts = 0;
          }
        });
        return;
      }

      setState(() {
        _resendCountdownSeconds -= 1;
      });
    });
  }

  Future<void> _handleResendOtp() async {
    if (!_canResend) {
      return;
    }
    try {
      final otpDispatch = await _UserAppApi.sendUserOtp(widget.phoneNumber);
      _requestId = otpDispatch.requestId;
      _resendAttempts += 1;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP resent successfully.')),
        );
      }
    } on _UserAppApiException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message)),
        );
      }
      return;
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not resend OTP right now.')),
        );
      }
      return;
    }

    if (_resendAttempts >= 3) {
      _startResendTimer(
        seconds: _resendLockoutSeconds,
        hideButtonWhileCounting: true,
        resetAttemptsOnComplete: true,
      );
      return;
    }

    _startResendTimer(
      seconds: _resendCooldownSeconds,
      hideButtonWhileCounting: false,
      resetAttemptsOnComplete: false,
    );
  }

  Future<void> _verifyOtp() async {
    setState(() {
      _isVerifying = true;
    });
    try {
      final session = await _UserAppApi.verifyUserOtp(
        phoneNumber: widget.phoneNumber,
        otp: _enteredOtp,
        requestId: _requestId,
      );
      await _LocalSessionStore.saveUserSession(
        phoneNumber: widget.phoneNumber,
        userId: session.userId,
        accessToken: session.accessToken,
        refreshToken: session.refreshToken,
        publicUserId: session.publicUserId,
      );
      await _NotificationBootstrap.ensureRegistered();
    } on _UserAppApiException catch (error) {
      setState(() {
        _errorText = error.message;
        _isVerifying = false;
      });
      return;
    } catch (_) {
      setState(() {
        _errorText = 'Could not verify OTP right now.';
        _isVerifying = false;
      });
      return;
    }
    if (!mounted) {
      return;
    }
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => UserHomePage(phoneNumber: widget.phoneNumber),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFD78268), Color(0xFFDF7DA0), Color(0xFFF7F2EC)],
            stops: [0, 0.48, 0.48],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                flex: 8,
                child: Stack(
                  children: [
                    _TopDiscoveryHero(
                      title: 'VERIFY YOUR\nNUMBER',
                      subtitle:
                          'Enter the 6-digit code sent to +91 ${widget.phoneNumber}. Your account will be ready in seconds.',
                    ),
                    Positioned(
                      left: 22,
                      top: 18,
                      child: IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.14),
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.arrow_back_rounded),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 10,
                child: Container(
                  width: double.infinity,
                  color: const Color(0xFFF7F2EC),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(22, 24, 22, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            'OTP Verification',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Center(
                          child: Text(
                            'Use 123456 for now',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFFCB6E5B),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(
                            6,
                            (index) => _OtpDigitBox(
                              controller: _otpControllers[index],
                              focusNode: _focusNodes[index],
                              onChanged: (value) => _onOtpChanged(index, value),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (_errorText != null)
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 14),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFE6E8),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFFFFB7C0)),
                            ),
                            child: Text(
                              _errorText!,
                              style: const TextStyle(
                                color: Color(0xFFC53B52),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: const Color(0xFFE3DBD3)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFCB6E5B).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  Icons.sms_outlined,
                                  color: Color(0xFFCB6E5B),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '+91 ${widget.phoneNumber}',
                                      style: const TextStyle(
                                        color: Color(0xFF171717),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Use this number to complete sign in.',
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: const Color(0xFF7C756E),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Edit'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Text(
                              "Didn't receive the code?",
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: const Color(0xFF766E67),
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (_resendHidden)
                              Expanded(
                                child: Text(
                                  'Resend hidden for now. Try again in $_formattedCountdown',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: const Color(0xFFCB6E5B),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              )
                            else
                              TextButton(
                                onPressed: _canResend ? _handleResendOtp : null,
                                child: Text(
                                  _canResend
                                      ? 'Resend OTP'
                                      : 'Resend in $_formattedCountdown',
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _canVerify && !_isVerifying ? _verifyOtp : null,
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: const Color(0xFFED5F6E),
                              disabledBackgroundColor: const Color(0xFFF6A9B1),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            child: Text(_isVerifying ? 'Verifying...' : 'Verify OTP'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopDiscoveryHero extends StatelessWidget {
  const _TopDiscoveryHero({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFD78268),
            Color(0xFFDF7DA0),
            Color(0xFF5C8FD8),
          ],
          stops: [0, 0.5, 1],
        ),
      ),
      child: Stack(
        children: [
          const Positioned.fill(child: _HeroBackgroundPattern()),
          Positioned(
            left: -40,
            top: -18,
            child: Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.16),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          const Positioned(
            left: 34,
            top: 154,
            child: _HeroLeafSpark(angle: -0.64),
          ),
          const Positioned(
            right: 34,
            top: 146,
            child: _HeroLeafSpark(angle: 0.58),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.10),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.22),
                  ],
                  stops: const [0, 0.42, 1],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.1,
                    shadows: const [
                      Shadow(
                        color: Color(0x38000000),
                        blurRadius: 16,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 270),
                  child: Text(
                    subtitle,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.88),
                      height: 1.34,
                      fontWeight: FontWeight.w600,
                      shadows: const [
                        Shadow(
                          color: Color(0x24000000),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LaunchSceneCard extends StatelessWidget {
  const _LaunchSceneCard({
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.icon,
    required this.progress,
    required this.tilt,
  });

  final String title;
  final String subtitle;
  final Color accent;
  final IconData icon;
  final double progress;
  final double tilt;

  @override
  Widget build(BuildContext context) {
    final lifted = 26 * (1 - progress);
    return Transform.translate(
      offset: Offset(0, lifted),
      child: Transform.rotate(
        angle: tilt,
        child: Opacity(
          opacity: progress.clamp(0, 1),
          child: SizedBox(
            width: 102,
            height: 146,
            child: Stack(
              children: [
                Positioned(
                  left: 14,
                  right: 14,
                  bottom: 0,
                  child: Container(
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.24),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                Positioned(
                  left: 22,
                  right: 22,
                  bottom: 10,
                  child: Container(
                    height: 18,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withValues(alpha: 0.22),
                          accent.withValues(alpha: 0.78),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                Positioned(
                  left: 18,
                  right: 18,
                  bottom: 28,
                  child: Container(
                    height: 72,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withValues(alpha: 0.24),
                          accent,
                          Color.lerp(accent, Colors.black, 0.18)!,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.16),
                          blurRadius: 14,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Icon(icon, color: Colors.white, size: 34),
                  ),
                ),
                Positioned(
                  left: 2,
                  right: 2,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFFFFFEF8), Color(0xFFF3E8DA)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.88)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: accent,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF5E584F),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FallingBrandLetter extends StatelessWidget {
  const _FallingBrandLetter({
    required this.letter,
    required this.accent,
    required this.progress,
  });

  final String letter;
  final Color accent;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final clamped = progress.clamp(0.0, 1.0).toDouble();
    return Transform.translate(
      offset: Offset(0, -38 * (1 - clamped)),
      child: Opacity(
        opacity: clamped,
        child: Container(
          width: 58,
          height: 58,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.34),
                blurRadius: 22,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Text(
            letter,
            style: TextStyle(
              color: accent,
              fontSize: 30,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.8,
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroBackgroundPattern extends StatelessWidget {
  const _HeroBackgroundPattern();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            Positioned(
              left: -38,
              top: -56,
              child: _HeroBackdropSpot(
                size: 172,
                color: Colors.white.withValues(alpha: 0.12),
              ),
            ),
            Positioned(
              right: -54,
              top: 18,
              child: _HeroBackdropSpot(
                size: 154,
                color: const Color(0xFFFFE4C9).withValues(alpha: 0.16),
              ),
            ),
            Positioned(
              left: -26,
              right: -26,
              bottom: -8,
              child: Transform.rotate(
                angle: -0.045,
                child: Container(
                  height: 130,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFC66D5A), Color(0xFFD48E78)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: Container(
                height: 210,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.36),
                      Colors.black.withValues(alpha: 0.18),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            const Positioned(
              left: 24,
              top: 266,
              child: _SceneBubble(
                icon: Icons.engineering_rounded,
                accent: Color(0xFFF2A13D),
                width: 74,
                height: 82,
              ),
            ),
            const Positioned(
              left: 96,
              top: 326,
              child: _SceneBubble(
                icon: Icons.plumbing_rounded,
                accent: Color(0xFF4E9EFF),
                width: 58,
                height: 66,
              ),
            ),
            const Positioned(
              right: 18,
              top: 272,
              child: _SceneBubble(
                icon: Icons.storefront_rounded,
                accent: Color(0xFF53B55E),
                width: 82,
                height: 92,
              ),
            ),
            const Positioned(
              right: 126,
              top: 260,
              child: _SceneBubble(
                icon: Icons.local_pharmacy_rounded,
                accent: Color(0xFF1FB8A4),
                width: 50,
                height: 56,
              ),
            ),
            const Positioned(
              left: 176,
              top: 338,
              child: _SceneBubble(
                icon: Icons.restaurant_rounded,
                accent: Color(0xFFFF954A),
                width: 62,
                height: 70,
              ),
            ),
            const Positioned(
              left: 216,
              top: 252,
              child: _SceneBubble(
                icon: Icons.two_wheeler_rounded,
                accent: Color(0xFF3F63FF),
                width: 44,
                height: 50,
              ),
            ),
            const Positioned(
              left: 252,
              top: 346,
              child: _SceneBubble(
                icon: Icons.directions_car_filled_rounded,
                accent: Color(0xFFE55A57),
                width: 54,
                height: 58,
              ),
            ),
            const Positioned(
              left: 124,
              top: 256,
              child: _SceneBubble(
                icon: Icons.electric_rickshaw_rounded,
                accent: Color(0xFF2EBF6E),
                width: 42,
                height: 48,
              ),
            ),
            const Positioned(
              left: 22,
              top: 214,
              child: _HeroCallout(
                label: 'Labour',
                icon: Icons.engineering_rounded,
                accent: Color(0xFFF2A13D),
                width: 104,
                angle: -0.10,
              ),
            ),
            const Positioned(
              left: 134,
              top: 204,
              child: _HeroCallout(
                label: 'Repairs',
                icon: Icons.plumbing_rounded,
                accent: Color(0xFF4E9EFF),
                width: 110,
                angle: 0.05,
              ),
            ),
            const Positioned(
              right: 20,
              top: 202,
              child: _HeroCallout(
                label: 'All in one',
                icon: Icons.auto_awesome_rounded,
                accent: Color(0xFF5C8FD8),
                width: 124,
                angle: 0.08,
              ),
            ),
            const Positioned(
              left: 28,
              top: 378,
              child: _HeroCallout(
                label: 'Pharmacy',
                icon: Icons.local_pharmacy_rounded,
                accent: Color(0xFF1FB8A4),
                width: 118,
                angle: -0.05,
              ),
            ),
            const Positioned(
              left: 154,
              top: 394,
              child: _HeroCallout(
                label: 'Dining',
                icon: Icons.restaurant_rounded,
                accent: Color(0xFFFF954A),
                width: 106,
                angle: 0.04,
              ),
            ),
            const Positioned(
              left: 26,
              top: 432,
              child: _HeroCallout(
                label: 'Groceries',
                icon: Icons.local_grocery_store_rounded,
                accent: Color(0xFF4DAF50),
                width: 124,
                angle: -0.08,
              ),
            ),
            const Positioned(
              left: 166,
              top: 448,
              child: _HeroCallout(
                label: 'Service',
                icon: Icons.handyman_rounded,
                accent: Color(0xFFCB6E5B),
                width: 112,
                angle: 0.06,
              ),
            ),
            const Positioned(
              right: 18,
              top: 428,
              child: _HeroCallout(
                label: 'Auto',
                icon: Icons.electric_rickshaw_rounded,
                accent: Color(0xFF2EBF6E),
                width: 98,
                angle: 0.09,
              ),
            ),
            Positioned(
              left: -20,
              right: -20,
              bottom: -14,
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.08),
                      Colors.black.withValues(alpha: 0.18),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _HeroBackdropSpot extends StatelessWidget {
  const _HeroBackdropSpot({
    required this.size,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, Colors.transparent],
        ),
      ),
    );
  }
}

class _HeroLeafSpark extends StatelessWidget {
  const _HeroLeafSpark({required this.angle});

  final double angle;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: Container(
        width: 18,
        height: 34,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFC9F352), Color(0xFF5A9D19)],
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(4),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(18),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFB8E444).withValues(alpha: 0.42),
              blurRadius: 12,
              spreadRadius: 1,
            ),
          ],
        ),
      ),
    );
  }
}

class _SceneBubble extends StatelessWidget {
  const _SceneBubble({
    required this.icon,
    required this.accent,
    required this.width,
    required this.height,
  });

  final IconData icon;
  final Color accent;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          Positioned(
            left: width * 0.12,
            right: width * 0.12,
            bottom: 0,
            child: Container(
              height: height * 0.12,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.24),
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.16),
                    blurRadius: 16,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: width * 0.2,
            right: width * 0.2,
            bottom: height * 0.08,
            child: Container(
              height: height * 0.18,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.18),
                    accent.withValues(alpha: 0.52),
                    accent.withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          Positioned(
            left: width * 0.24,
            right: width * 0.24,
            bottom: height * 0.18,
            child: Container(
              height: height * 0.42,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.24),
                    accent.withValues(alpha: 0.92),
                    Color.lerp(accent, Colors.black, 0.18)!,
                  ],
                ),
                borderRadius: BorderRadius.circular(width),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 14,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: width * 0.22,
              ),
            ),
          ),
          Positioned(
            left: width * 0.32,
            right: width * 0.32,
            bottom: height * 0.54,
            child: Container(
              height: height * 0.05,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroCallout extends StatelessWidget {
  const _HeroCallout({
    required this.label,
    required this.icon,
    required this.accent,
    required this.width,
    this.angle = 0,
  });

  final String label;
  final IconData icon;
  final Color accent;
  final double width;
  final double angle;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: width,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFFFEF8), Color(0xFFF4EBDD)],
              ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x24000000),
                  blurRadius: 14,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 13, color: accent),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: accent,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      fontStyle: FontStyle.italic,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 22),
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              color: const Color(0xFFF0E7DA),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ],
      ),
    );
  }
}

class _CountrySelector extends StatelessWidget {
  const _CountrySelector();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 66,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFE2DAD0)),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _IndiaFlagGlyph(),
          SizedBox(width: 8),
          Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF666666)),
        ],
      ),
    );
  }
}

class _IndiaFlagGlyph extends StatelessWidget {
  const _IndiaFlagGlyph();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 16,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFE1D8CF)),
      ),
      child: Column(
        children: [
          Expanded(child: Container(color: const Color(0xFFFF9B2F))),
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(color: Colors.white),
                Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: Color(0xFF2A5EB7),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: Container(color: const Color(0xFF1A9C43))),
        ],
      ),
    );
  }
}

class _PhoneInputField extends StatelessWidget {
  const _PhoneInputField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFE2DAD0)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: [
          const Text(
            '+91',
            style: TextStyle(
              color: Color(0xFF272727),
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 10),
          Container(width: 1, height: 24, color: const Color(0xFFE0D7CE)),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1D1D1D),
              ),
              decoration: const InputDecoration(
                counterText: '',
                border: InputBorder.none,
                hintText: 'Enter Phone Number',
                hintStyle: TextStyle(
                  color: Color(0xFFA19A92),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OtpDigitBox extends StatelessWidget {
  const _OtpDigitBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w900,
          color: Color(0xFF1B1B1B),
        ),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Color(0xFFE1D8D0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Color(0xFFE1D8D0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Color(0xFFED5F6E), width: 1.8),
          ),
        ),
      ),
    );
  }
}

class _PolicyLink extends StatelessWidget {
  const _PolicyLink({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF303030),
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.underline,
              decorationColor: const Color(0xFF303030),
            ),
      ),
    );
  }
}

class _LoginQuickIcon extends StatelessWidget {
  const _LoginQuickIcon({
    required this.icon,
    required this.accent,
  });

  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFE9DDD1)),
      ),
      child: Icon(
        icon,
        size: 24,
        color: accent,
      ),
    );
  }
}

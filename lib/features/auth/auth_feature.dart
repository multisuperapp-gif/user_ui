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
        builder: (_) => UserHomePage(phoneNumber: savedPhoneNumber),
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
                            'Live labour, services and shops around you.',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.84),
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                        const Spacer(),
                        SizedBox(
                          height: 300,
                          child: LayoutBuilder(
                            builder: (context, scene) {
                              final cardWidth = (scene.maxWidth * 0.30).clamp(88.0, 112.0);
                              final cardHeight = cardWidth * 1.43;
                              return Stack(
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
                                    left: 4,
                                    bottom: 34,
                                    child: _LaunchSceneCard(
                                      title: 'LABOUR',
                                      subtitle: 'Working now',
                                      accent: const Color(0xFFF2A13D),
                                      icon: Icons.engineering_rounded,
                                      progress: labourMotion.value,
                                      tilt: -0.08,
                                      width: cardWidth,
                                      height: cardHeight,
                                    ),
                                  ),
                                  Positioned(
                                    left: (scene.maxWidth - cardWidth) / 2,
                                    bottom: 56,
                                    child: _LaunchSceneCard(
                                      title: 'SERVICE',
                                      subtitle: 'Serving live',
                                      accent: const Color(0xFF5C8FD8),
                                      icon: Icons.handyman_rounded,
                                      progress: serviceMotion.value,
                                      tilt: 0.03,
                                      width: cardWidth,
                                      height: cardHeight,
                                    ),
                                  ),
                                  Positioned(
                                    right: 4,
                                    bottom: 34,
                                    child: _LaunchSceneCard(
                                      title: 'SHOP',
                                      subtitle: 'Launching now',
                                      accent: const Color(0xFF4DAF50),
                                      icon: Icons.storefront_rounded,
                                      progress: shopMotion.value,
                                      tilt: 0.08,
                                      width: cardWidth,
                                      height: cardHeight,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 22),
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

class _LaunchSceneCard extends StatelessWidget {
  const _LaunchSceneCard({
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.icon,
    required this.progress,
    required this.tilt,
    required this.width,
    required this.height,
  });

  final String title;
  final String subtitle;
  final Color accent;
  final IconData icon;
  final double progress;
  final double tilt;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final eased = Curves.easeOutBack.transform(progress.clamp(0.0, 1.0));
    return Transform.translate(
      offset: Offset(0, (1 - eased) * 42),
      child: Transform.rotate(
        angle: tilt * (1 - (eased * 0.45)),
        child: Opacity(
          opacity: eased.clamp(0.0, 1.0),
          child: Container(
            width: width,
            height: height,
            padding: EdgeInsets.fromLTRB(width * 0.12, height * 0.10, width * 0.12, height * 0.12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(width * 0.22),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.94),
                  Colors.white.withValues(alpha: 0.78),
                ],
              ),
              border: Border.all(color: Colors.white.withValues(alpha: 0.38)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF18213A).withValues(alpha: 0.16),
                  blurRadius: width * 0.22,
                  offset: Offset(0, height * 0.13),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: width * 0.34,
                  height: width * 0.34,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(width * 0.12),
                  ),
                  alignment: Alignment.center,
                  child: Icon(icon, color: accent, size: width * 0.18),
                ),
                const Spacer(),
                Text(
                  title,
                  style: TextStyle(
                    color: const Color(0xFF22314D),
                    fontSize: width * 0.16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: height * 0.03),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: const Color(0xFF5F6E83),
                    fontSize: width * 0.10,
                    fontWeight: FontWeight.w700,
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

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
    this.embeddedFlow = false,
  });

  final bool embeddedFlow;

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
      final verified = await Navigator.of(context).push<bool>(
        MaterialPageRoute<bool>(
          builder: (_) => OtpVerificationPage(
            phoneNumber: cleanedPhone,
            requestId: otpDispatch.requestId,
            embeddedFlow: widget.embeddedFlow,
          ),
        ),
      );
      if (verified == true && mounted && widget.embeddedFlow) {
        Navigator.of(context).pop(true);
      }
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
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F2EC),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFF8F3),
              Color(0xFFF3E5DB),
              Color(0xFFFFFBF8),
            ],
          ),
        ),
        child: SafeArea(
          child: AnimatedPadding(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.fromLTRB(18, 18, 18, keyboardInset > 0 ? keyboardInset + 16 : 18),
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: const Color(0xFFE8DED7)),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1A2030).withValues(alpha: 0.08),
                          blurRadius: 28,
                          offset: const Offset(0, 16),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFEFEA),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFEBD8CF)),
                              ),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.phone_android_rounded,
                                color: Color(0xFFCB6E5B),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Login to continue',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: const Color(0xFF22314D),
                                  fontWeight: FontWeight.w900,
                                  fontSize: 22,
                                ),
                              ),
                            ),
                            if (widget.embeddedFlow)
                              IconButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                style: IconButton.styleFrom(
                                  backgroundColor: const Color(0xFFF7EFEA),
                                  foregroundColor: const Color(0xFF22314D),
                                ),
                                icon: const Icon(Icons.close_rounded),
                              ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Enter your phone number to continue securely.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF6D7A91),
                            height: 1.42,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _PhoneInputField(
                          controller: _phoneController,
                          compact: false,
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
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            child: Text(_isSendingOtp ? 'Sending OTP...' : 'Continue'),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Center(
                          child: Text(
                            'By continuing, you agree to our',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF7A736A),
                              fontSize: 12.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Center(
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 8,
                            runSpacing: 8,
                            children: [
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
                        const SizedBox(height: 16),
                        const Center(child: _MadeWithLoveFooter()),
                      ],
                    ),
                  ),
                ),
              ),
            ),
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
    this.embeddedFlow = false,
  });

  final String phoneNumber;
  final String requestId;
  final bool embeddedFlow;

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
  bool _isVerifying = false;
  late String _requestId;

  String get _enteredOtp => _otpControllers.map((controller) => controller.text).join();

  bool get _canVerify => _enteredOtp.length == 6;
  bool get _canResend => _resendCountdownSeconds == 0;

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
    required bool resetAttemptsOnComplete,
  }) {
    _resendTimer?.cancel();
    _resendCountdownSeconds = seconds;
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
        resetAttemptsOnComplete: true,
      );
      return;
    }

    _startResendTimer(
      seconds: _resendCooldownSeconds,
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
    if (widget.embeddedFlow) {
      Navigator.of(context).pop(true);
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxHeight < 780 || constraints.maxWidth < 390;
          final horizontalPadding = constraints.maxWidth < 360 ? 16.0 : 22.0;
          final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
          final otpSpacing = compact ? 6.0 : 8.0;

          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1C2742),
                  Color(0xFFCB6E5B),
                  Color(0xFFDF7DA0),
                ],
                stops: [0, 0.56, 1],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(horizontalPadding, compact ? 8 : 12, horizontalPadding, 18),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white.withValues(alpha: 0.14),
                            foregroundColor: Colors.white,
                          ),
                          icon: const Icon(Icons.arrow_back_rounded),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
                          ),
                          child: const Text(
                            'OTP Verification',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                        const Spacer(),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(horizontalPadding, 0, horizontalPadding, compact ? 16 : 22),
                    child: Column(
                      children: [
                        Container(
                          width: compact ? 62 : 70,
                          height: compact ? 62 : 70,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
                          ),
                          child: Icon(
                            Icons.shield_rounded,
                            color: Colors.white,
                            size: compact ? 28 : 32,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Enter the code we sent',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            height: 1.04,
                            fontSize: compact ? 26 : 29,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'We sent a 6-digit verification code to +91 ${widget.phoneNumber}.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.84),
                            height: 1.35,
                            fontSize: compact ? 13 : 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Stack(
                      children: [
                        Positioned(
                          left: 0,
                          right: 0,
                          top: 0,
                          child: Container(
                            height: compact ? 96 : 112,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.white.withValues(alpha: 0.14),
                                  const Color(0xFFFFE8DF).withValues(alpha: 0.38),
                                  Colors.transparent,
                                ],
                                stops: const [0, 0.48, 1],
                              ),
                            ),
                          ),
                        ),
                        Positioned.fill(
                          top: compact ? 22 : 28,
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Color(0xFFFFF8F3),
                                  Color(0xFFF7F2EC),
                                  Colors.white,
                                ],
                                stops: [0, 0.34, 1],
                              ),
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF18213A).withValues(alpha: 0.08),
                                  blurRadius: 28,
                                  offset: const Offset(0, -8),
                                ),
                              ],
                            ),
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              padding: EdgeInsets.fromLTRB(
                                horizontalPadding,
                                compact ? 18 : 22,
                                horizontalPadding,
                                24 + keyboardInset,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Center(
                                    child: Container(
                                      width: 54,
                                      height: 5,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFD7CEC4),
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: compact ? 18 : 20),
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                horizontal: compact ? 14 : 16,
                                vertical: compact ? 12 : 14,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: const Color(0xFFE6DCD2)),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x14000000),
                                    blurRadius: 18,
                                    offset: Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: compact ? 42 : 48,
                                    height: compact ? 42 : 48,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFFF9E2DA), Color(0xFFFFF5F0)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Icon(
                                      Icons.sms_outlined,
                                      color: const Color(0xFFCB6E5B),
                                      size: compact ? 20 : 22,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '+91 ${widget.phoneNumber}',
                                          style: TextStyle(
                                            color: const Color(0xFF171717),
                                            fontSize: compact ? 14 : 16,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          'Use 123456 for now',
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: const Color(0xFFCB6E5B),
                                            fontSize: compact ? 11.5 : 12.5,
                                            fontWeight: FontWeight.w800,
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
                            SizedBox(height: compact ? 18 : 22),
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.fromLTRB(
                                compact ? 14 : 18,
                                compact ? 14 : 16,
                                compact ? 14 : 18,
                                compact ? 14 : 16,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFFFFBF8), Color(0xFFFDF3EE)],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                borderRadius: BorderRadius.circular(26),
                                border: Border.all(color: const Color(0xFFF0DDD4)),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    'Verification code',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      color: const Color(0xFF29314A),
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Enter all 6 digits to continue.',
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: const Color(0xFF7A736A),
                                      fontSize: compact ? 11.5 : 12.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: compact ? 14 : 16),
                                  LayoutBuilder(
                                    builder: (context, otpConstraints) {
                                      final digitWidth =
                                          ((otpConstraints.maxWidth - (otpSpacing * 5)) / 6)
                                              .clamp(38.0, compact ? 44.0 : 50.0);
                                      return Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: List.generate(6, (index) {
                                          return Padding(
                                            padding: EdgeInsets.only(
                                              left: index == 0 ? 0 : otpSpacing,
                                            ),
                                            child: _OtpDigitBox(
                                              controller: _otpControllers[index],
                                              focusNode: _focusNodes[index],
                                              onChanged: (value) => _onOtpChanged(index, value),
                                              width: digitWidth,
                                              compact: compact,
                                            ),
                                          );
                                        }),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            if (_errorText != null) ...[
                              const SizedBox(height: 14),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFE6E8),
                                  borderRadius: BorderRadius.circular(16),
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
                            ],
                            SizedBox(height: compact ? 16 : 18),
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                horizontal: compact ? 14 : 16,
                                vertical: compact ? 12 : 14,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(color: const Color(0xFFE5DBD1)),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Didn't receive the code?",
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            color: const Color(0xFF29314A),
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _canResend
                                              ? 'You can request a fresh OTP now.'
                                              : 'Resend available in $_formattedCountdown',
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: const Color(0xFF7A736A),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  FilledButton.tonal(
                                    onPressed: _canResend ? _handleResendOtp : null,
                                    style: FilledButton.styleFrom(
                                      foregroundColor: const Color(0xFFCB6E5B),
                                      backgroundColor: _canResend
                                          ? const Color(0xFFFFF1EB)
                                          : const Color(0xFFF2ECE8),
                                      disabledForegroundColor: const Color(0xFFB69B91),
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    child: Text(
                                      _canResend ? 'Resend' : _formattedCountdown,
                                      style: const TextStyle(fontWeight: FontWeight.w800),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isVerifying || !_canVerify ? null : _verifyOtp,
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: const Color(0xFFCB6E5B),
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(vertical: compact ? 14 : 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  textStyle: TextStyle(
                                    fontSize: compact ? 14 : 15.5,
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
                ],
              ),
            ),
          );
        },
      ),
    );
  }

}

class _PhoneInputField extends StatelessWidget {
  const _PhoneInputField({
    required this.controller,
    this.compact = false,
  });

  final TextEditingController controller;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final height = compact ? 56.0 : 62.0;
    final textSize = compact ? 14.0 : 15.0;
    final hintSize = compact ? 13.0 : 14.0;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE6D9CF)),
      ),
      padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 7 : 8,
              vertical: compact ? 7 : 8,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFF5EEE8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const _IndiaFlagGlyph(),
                SizedBox(width: compact ? 6 : 7),
                Text(
                  '+91',
                  style: TextStyle(
                    color: const Color(0xFF272727),
                    fontWeight: FontWeight.w800,
                    fontSize: textSize,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: compact ? 8 : 10),
          Text(
            '|',
            style: TextStyle(
              color: const Color(0xFFD6C8BD),
              fontWeight: FontWeight.w600,
              fontSize: compact ? 18 : 20,
            ),
          ),
          SizedBox(width: compact ? 8 : 10),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.phone,
              textAlignVertical: TextAlignVertical.center,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              style: TextStyle(
                fontSize: textSize,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1D1D1D),
              ),
              decoration: InputDecoration(
                isDense: true,
                counterText: '',
                border: InputBorder.none,
                hintText: 'Enter phone number',
                hintStyle: TextStyle(
                  color: const Color(0xFFA19A92),
                  fontSize: hintSize,
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
    this.width = 48,
    this.compact = false,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final double width;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(compact ? 18 : 20);
    return Container(
      width: width,
      decoration: BoxDecoration(
        borderRadius: radius,
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE7D7CD)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFCB6E5B).withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: TextStyle(
          fontSize: compact ? 20 : 24,
          fontWeight: FontWeight.w900,
          color: const Color(0xFF1B1B1B),
        ),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: Colors.transparent,
          hintText: '-',
          hintStyle: TextStyle(
            color: const Color(0xFF1B1B1B).withValues(alpha: 0.22),
            fontSize: compact ? 18 : 22,
            fontWeight: FontWeight.w800,
          ),
          contentPadding: EdgeInsets.symmetric(vertical: compact ? 14 : 18),
          border: OutlineInputBorder(
            borderRadius: radius,
            borderSide: const BorderSide(color: Color(0xFFE8D7CE), width: 1.2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: radius,
            borderSide: const BorderSide(color: Color(0xFFE8D7CE), width: 1.2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: radius,
            borderSide: const BorderSide(color: Color(0xFFCB6E5B), width: 1.8),
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
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF7EFEA),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0xFFE6D9CF)),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF4F4740),
                fontWeight: FontWeight.w700,
                fontSize: 12.5,
              ),
        ),
      ),
    );
  }
}

class _IndiaFlagGlyph extends StatelessWidget {
  const _IndiaFlagGlyph();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 28,
      height: 20,
      child: CustomPaint(painter: _IndiaFlagPainter()),
    );
  }
}

class _IndiaFlagPainter extends CustomPainter {
  const _IndiaFlagPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final radius = Radius.circular(size.height * 0.22);
    final flagRect = Offset.zero & size;
    final clip = RRect.fromRectAndRadius(flagRect, radius);
    canvas.save();
    canvas.clipRRect(clip);

    final stripeHeight = size.height / 3;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, stripeHeight),
      Paint()..color = const Color(0xFFFF8F1F),
    );
    canvas.drawRect(
      Rect.fromLTWH(0, stripeHeight, size.width, stripeHeight),
      Paint()..color = Colors.white,
    );
    canvas.drawRect(
      Rect.fromLTWH(0, stripeHeight * 2, size.width, stripeHeight),
      Paint()..color = const Color(0xFF128807),
    );

    final center = Offset(size.width / 2, size.height / 2);
    final wheelRadius = size.height * 0.15;
    final wheelPaint = Paint()
      ..color = const Color(0xFF1A3F95)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;
    canvas.drawCircle(center, wheelRadius, wheelPaint);
    for (var i = 0; i < 8; i++) {
      final angle = i * 3.141592653589793 / 4;
      final end = Offset(
        center.dx + wheelRadius * 0.9 * math.cos(angle),
        center.dy + wheelRadius * 0.9 * math.sin(angle),
      );
      canvas.drawLine(center, end, wheelPaint);
    }

    canvas.restore();
    canvas.drawRRect(
      clip,
      Paint()
        ..color = const Color(0xFFBFC5CA)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

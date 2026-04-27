import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:duckhat/services/duckhat_api.dart';
import 'package:duckhat/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../shop_main.dart';
import 'app_shell.dart';
import 'forgot_password.dart';
import 'signup.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

enum _AccountType {
  cliente('Cliente', Icons.person_outline, 'CLIENTE'),
  empresa('Empresa', Icons.storefront_outlined, 'PRESTADOR');

  final String label;
  final IconData icon;
  final String apiType;

  const _AccountType(this.label, this.icon, this.apiType);
}

enum _LoginAnimationStage { idle, wave }

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _stackKey = GlobalKey();
  final _buttonKey = GlobalKey();

  late final AnimationController _waveController;

  _AccountType _accountType = _AccountType.cliente;
  bool _hidePassword = true;
  bool _loading = false;
  bool _buttonPressed = false;
  bool _finishingLogin = false;
  String? _error;
  Offset? _waveOrigin;
  _LoginAnimationStage _animationStage = _LoginAnimationStage.idle;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );
  }

  @override
  void dispose() {
    _waveController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (_loading || _finishingLogin) return;

    final emailError = _validateEmail(_emailController.text);
    if (emailError != null) {
      setState(() => _error = emailError);
      return;
    }

    final passwordError = _validatePassword(_passwordController.text);
    if (passwordError != null) {
      setState(() => _error = passwordError);
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    var loginSucceeded = false;

    try {
      final session = await DuckHatApi.instance.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (session.tipo != _accountType.apiType) {
        DuckHatApi.instance.clearSession();
        setState(() {
          _error =
              'Esta conta não pertence ao perfil ${_accountType.label.toLowerCase()}.';
        });
        return;
      }

      loginSucceeded = true;
      if (!mounted) return;
      await _playSuccessSequence();
      if (!mounted) return;
      _openApp();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString().replaceFirst('Exception: ', '').trim();
      });
    } finally {
      if (!loginSucceeded && mounted) {
        setState(() {
          _loading = false;
          _finishingLogin = false;
          _animationStage = _LoginAnimationStage.idle;
        });
      }
      if (!loginSucceeded) {
        _waveController.reset();
      }
    }
  }

  Future<void> _playSuccessSequence() async {
    setState(() {
      _finishingLogin = true;
      _animationStage = _LoginAnimationStage.wave;
    });

    await Future<void>.delayed(const Duration(milliseconds: 70));
    if (!mounted) return;

    _captureWaveOrigin();
    await _waveController.forward(from: 0);
    await Future<void>.delayed(const Duration(milliseconds: 120));
  }

  void _captureWaveOrigin() {
    final stackBox = _stackKey.currentContext?.findRenderObject() as RenderBox?;
    final buttonBox =
        _buttonKey.currentContext?.findRenderObject() as RenderBox?;

    if (stackBox == null || buttonBox == null) {
      _waveOrigin = null;
      return;
    }

    _waveOrigin = buttonBox.localToGlobal(
      buttonBox.size.center(Offset.zero),
      ancestor: stackBox,
    );
  }

  void _openApp() {
    final destination = _accountType == _AccountType.empresa
        ? const ShopMainNavigator()
        : const MainNavigator();

    Navigator.of(context).pushReplacement(
      _InstantRoute(child: _PostLoginTransitionPage(destination: destination)),
    );
  }

  void _showForgotPassword() {
    Navigator.of(context)
        .push<String>(
          MaterialPageRoute(builder: (_) => const ForgotPasswordPage()),
        )
        .then((email) {
          if (email == null || email.isEmpty || !mounted) return;
          setState(() => _emailController.text = email);
        });
  }

  void _openCreateAccount() {
    Navigator.of(context)
        .push<SignupSuccessResult>(
          MaterialPageRoute(builder: (_) => const SignupPage()),
        )
        .then((result) {
          if (result == null || !mounted) return;
          _emailController.text = result.email;
          _passwordController.text = result.password;
          setState(() {
            _accountType = result.accountType == SignupAccountType.cliente
                ? _AccountType.cliente
                : _AccountType.empresa;
            _error = null;
          });
        });
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Informe seu e-mail.';
    if (!email.contains('@') || !email.contains('.')) {
      return 'Digite um e-mail válido.';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) return 'Informe sua senha.';
    if (password.length < 6) {
      return 'A senha precisa ter ao menos 6 caracteres.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFFFFBF8),
        body: Stack(
          key: _stackKey,
          children: [
            const Positioned.fill(child: _LoginBackground()),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 370),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const _Entrance(delayMs: 0, child: _HeaderBlock()),
                        const SizedBox(height: 24),
                        _Entrance(
                          delayMs: 80,
                          child: _AccountTypeRow(
                            selected: _accountType,
                            enabled: !_loading && !_finishingLogin,
                            onChanged: (value) {
                              setState(() {
                                _accountType = value;
                                _error = null;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 22),
                        _Entrance(
                          delayMs: 130,
                          child: _MinimalField(
                            controller: _emailController,
                            hint: 'E-mail',
                            icon: Icons.mail_outline_rounded,
                            keyboardType: TextInputType.emailAddress,
                            enabled: !_loading && !_finishingLogin,
                          ),
                        ),
                        const SizedBox(height: 14),
                        _Entrance(
                          delayMs: 170,
                          child: _MinimalField(
                            controller: _passwordController,
                            hint: 'Password',
                            icon: Icons.lock_outline_rounded,
                            obscureText: _hidePassword,
                            enabled: !_loading && !_finishingLogin,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _submit(),
                            suffix: IconButton(
                              onPressed: _loading || _finishingLogin
                                  ? null
                                  : () {
                                      setState(() {
                                        _hidePassword = !_hidePassword;
                                      });
                                    },
                              tooltip: _hidePassword
                                  ? 'Mostrar senha'
                                  : 'Ocultar senha',
                              icon: Icon(
                                _hidePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: AppColors.textRegular,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (_error != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _ErrorText(message: _error!),
                          ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _loading || _finishingLogin
                                ? null
                                : _showForgotPassword,
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.purple,
                              textStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            child: const Text('Forget Password?'),
                          ),
                        ),
                        const SizedBox(height: 38),
                        _Entrance(
                          delayMs: 220,
                          child: Row(
                            children: [
                              Expanded(
                                child: TextButton(
                                  onPressed: _loading || _finishingLogin
                                      ? null
                                      : _openCreateAccount,
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppColors.textRegular,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                  ),
                                  child: const Text(
                                    'Criar conta',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              _LoginButton(
                                key: _buttonKey,
                                pressed: _buttonPressed,
                                loading: _loading || _finishingLogin,
                                onTapDown: (_) {
                                  setState(() => _buttonPressed = true);
                                },
                                onTapEnd: () {
                                  if (!mounted) return;
                                  setState(() => _buttonPressed = false);
                                },
                                onPressed: _submit,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: _SuccessOverlay(
                  waveController: _waveController,
                  stage: _animationStage,
                  origin: _waveOrigin,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoginBackground extends StatelessWidget {
  const _LoginBackground();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFFCFA), Color(0xFFFFFBF8), Color(0xFFFDF8F3)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -80,
            right: -50,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accent.withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            bottom: 120,
            left: -80,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accent.withValues(alpha: 0.04),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderBlock extends StatelessWidget {
  const _HeaderBlock();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 66,
          height: 66,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withValues(alpha: 0.18),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.contactless_outlined,
            color: Colors.white,
            size: 30,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Hey Rider,\nWelcome Back!',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.secondary,
            fontSize: 32,
            fontWeight: FontWeight.w800,
            height: 1.08,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Login with your credentials to access your account',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textRegular.withValues(alpha: 0.72),
            fontSize: 13,
            fontWeight: FontWeight.w500,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}

class _AccountTypeRow extends StatelessWidget {
  final _AccountType selected;
  final bool enabled;
  final ValueChanged<_AccountType> onChanged;

  const _AccountTypeRow({
    required this.selected,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _AccountType.values.map((type) {
        final isSelected = selected == type;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: type == _AccountType.cliente ? 10 : 0,
            ),
            child: InkWell(
              onTap: enabled ? () => onChanged(type) : null,
              borderRadius: BorderRadius.circular(18),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                height: 44,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.secondary
                      : Colors.white.withValues(alpha: 0.78),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.secondary
                        : AppColors.border.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      type.icon,
                      size: 18,
                      color: isSelected ? Colors.white : AppColors.textRegular,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      type.label,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textBold,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _MinimalField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final bool enabled;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  const _MinimalField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.enabled = true,
    this.suffix,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      enabled: enabled,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
      style: const TextStyle(
        color: AppColors.textBold,
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: AppColors.textMuted,
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: Icon(icon, color: AppColors.textRegular, size: 18),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.92),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: AppColors.border.withValues(alpha: 0.32),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
      ),
    );
  }
}

class _ErrorText extends StatelessWidget {
  final String message;

  const _ErrorText({required this.message});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.error_outline_rounded,
          size: 16,
          color: AppColors.error,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            message,
            style: const TextStyle(
              color: AppColors.error,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _LoginButton extends StatelessWidget {
  final bool pressed;
  final bool loading;
  final GestureTapDownCallback onTapDown;
  final VoidCallback onTapEnd;
  final VoidCallback onPressed;

  const _LoginButton({
    super.key,
    required this.pressed,
    required this.loading,
    required this.onTapDown,
    required this.onTapEnd,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: loading ? null : onTapDown,
      onTapCancel: onTapEnd,
      onTapUp: loading ? null : (_) => onTapEnd(),
      child: AnimatedScale(
        scale: pressed ? 0.95 : 1,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutBack,
        child: SizedBox(
          width: 116,
          height: 52,
          child: FilledButton(
            onPressed: loading ? null : onPressed,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: Colors.white,
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, size: 18),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _SuccessOverlay extends StatelessWidget {
  final AnimationController waveController;
  final _LoginAnimationStage stage;
  final Offset? origin;

  const _SuccessOverlay({
    required this.waveController,
    required this.stage,
    required this.origin,
  });

  @override
  Widget build(BuildContext context) {
    if (stage == _LoginAnimationStage.idle) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        final diameter = math.sqrt(width * width + height * height) * 2.15;
        final center = origin ?? Offset(width - 78, height - 118);

        return AnimatedBuilder(
          animation: waveController,
          builder: (context, _) {
            final waveValue = Curves.easeOutQuart.transform(
              waveController.value,
            );
            final waveSize = lerpDouble(60, diameter, waveValue) ?? 60;

            return Stack(
              children: [
                Positioned.fill(
                  child: ColoredBox(
                    color: AppColors.accent.withValues(
                      alpha: 0.08 + (waveValue * 0.14),
                    ),
                  ),
                ),
                Positioned(
                  left: center.dx - (waveSize / 2),
                  top: center.dy - (waveSize / 2),
                  child: Container(
                    width: waveSize,
                    height: waveSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.accent,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withValues(alpha: 0.22),
                          blurRadius: 44 * waveValue,
                          spreadRadius: 12 * waveValue,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _SuccessBanner extends StatelessWidget {
  const _SuccessBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: const Row(
        children: [
          Icon(Icons.check_circle, color: Color(0xFF27AE60), size: 18),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Login success!',
                  style: TextStyle(
                    color: AppColors.textBold,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'You have logged in successfully!',
                  style: TextStyle(
                    color: AppColors.textRegular,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8),
          Icon(Icons.close, color: AppColors.textMuted, size: 16),
        ],
      ),
    );
  }
}

class _PostLoginTransitionPage extends StatefulWidget {
  final Widget destination;

  const _PostLoginTransitionPage({required this.destination});

  @override
  State<_PostLoginTransitionPage> createState() =>
      _PostLoginTransitionPageState();
}

class _PostLoginTransitionPageState extends State<_PostLoginTransitionPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _overlayVisible = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    _startExit();
  }

  Future<void> _startExit() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await precacheImage(const AssetImage('assets/duck-dance.gif'), context);
      await Future<void>.delayed(const Duration(milliseconds: 360));
      if (!mounted) return;
      await _controller.forward(from: 0);
      if (!mounted) return;
      setState(() => _overlayVisible = false);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: widget.destination),
        if (_overlayVisible)
          Positioned.fill(
            child: IgnorePointer(
              child: _HomeRevealOverlay(controller: _controller),
            ),
          ),
      ],
    );
  }
}

class _HomeRevealOverlay extends StatelessWidget {
  final AnimationController controller;

  const _HomeRevealOverlay({required this.controller});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        final maxDiameter = math.sqrt(width * width + height * height) * 2;

        return AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            final appearProgress = Curves.easeOutBack.transform(
              Interval(0, 0.22).transform(controller.value.clamp(0.0, 1.0)),
            );
            final expandProgress = Curves.easeInOutCubicEmphasized.transform(
              Interval(0.5, 1).transform(controller.value.clamp(0.0, 1.0)),
            );
            final ballSize =
                lerpDouble(0, 132, appearProgress)! +
                lerpDouble(0, maxDiameter - 132, expandProgress)!;
            final ballOpacity = 1 - (expandProgress * 0.96);
            final fadeBlue = 1 - Curves.easeInCubic.transform(expandProgress);
            final gifScale = lerpDouble(0.82, 1, appearProgress)! -
                (expandProgress * 0.18);
            final gifOpacity =
                appearProgress * (1 - Curves.easeInQuad.transform(expandProgress));

            return Stack(
              children: [
                Positioned.fill(
                  child: ColoredBox(
                    color: AppColors.accent.withValues(alpha: fadeBlue),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
                    child: Column(
                      children: [const _SuccessBanner(), const Spacer()],
                    ),
                  ),
                ),
                Center(
                  child: Opacity(
                    opacity: ballOpacity.clamp(0.0, 1.0),
                    child: Container(
                      width: ballSize,
                      height: ballSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0x14000000).withValues(
                              alpha: appearProgress * 0.12,
                            ),
                            blurRadius: 28,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Opacity(
                          opacity: gifOpacity.clamp(0.0, 1.0),
                          child: Transform.scale(
                            scale: gifScale.clamp(0.0, 1.0),
                            child: ClipOval(
                              child: SizedBox(
                                width: 108,
                                height: 108,
                                child: Image.asset(
                                  'assets/duck-dance.gif',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _Entrance extends StatelessWidget {
  final Widget child;
  final int delayMs;

  const _Entrance({required this.child, required this.delayMs});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 420 + delayMs),
      curve: Curves.easeOutCubic,
      child: child,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 18),
            child: child,
          ),
        );
      },
    );
  }
}

class _InstantRoute<T> extends PageRouteBuilder<T> {
  _InstantRoute({required Widget child})
    : super(
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        pageBuilder: (context, animation, secondaryAnimation) => child,
      );
}

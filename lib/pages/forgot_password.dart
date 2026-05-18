import 'package:duckhat/services/duckhat_api.dart';
import 'package:duckhat/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _requestFormKey = GlobalKey<FormState>();
  final _resetFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _loading = false;
  bool _hidePassword = true;
  bool _hideConfirmPassword = true;
  bool _requested = false;
  String? _error;
  String? _demoRecoveryCode;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _requestCode() async {
    FocusScope.of(context).unfocus();
    if (!_requestFormKey.currentState!.validate() || _loading) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response = await DuckHatApi.instance.solicitarRecuperacaoSenha(
        email: _emailController.text.trim(),
      );
      final demoCode = response.codigoRecuperacao;

      if (!mounted) return;
      setState(() {
        _requested = true;
        _demoRecoveryCode = demoCode;
        if (demoCode != null && demoCode.isNotEmpty) {
          _codeController.text = demoCode;
        }
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString().replaceFirst('Exception: ', '').trim();
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resetPassword() async {
    FocusScope.of(context).unfocus();
    if (!_resetFormKey.currentState!.validate() || _loading) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await DuckHatApi.instance.redefinirSenha(
        email: _emailController.text.trim(),
        codigo: _codeController.text.trim(),
        novaSenha: _passwordController.text,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Senha redefinida com sucesso.'),
          backgroundColor: AppColors.accent,
        ),
      );
      Navigator.pop(context, _emailController.text.trim().toLowerCase());
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString().replaceFirst('Exception: ', '').trim();
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _restartFlow() {
    setState(() {
      _requested = false;
      _error = null;
      _demoRecoveryCode = null;
      _codeController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeColors = AppThemeColors.of(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: themeColors.isDark
            ? Brightness.light
            : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: themeColors.isDark
            ? themeColors.background
            : const Color(0xFFFFFBF8),
        body: Stack(
          children: [
            const Positioned.fill(child: _RecoveryBackground()),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 430),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _RecoveryHeader(onBack: () => Navigator.pop(context)),
                        const SizedBox(height: 22),
                        _RecoveryCard(
                          requested: _requested,
                          requestFormKey: _requestFormKey,
                          resetFormKey: _resetFormKey,
                          emailController: _emailController,
                          codeController: _codeController,
                          passwordController: _passwordController,
                          confirmPasswordController: _confirmPasswordController,
                          demoRecoveryCode: _demoRecoveryCode,
                          loading: _loading,
                          hidePassword: _hidePassword,
                          hideConfirmPassword: _hideConfirmPassword,
                          error: _error,
                          onRequestCode: _requestCode,
                          onResetPassword: _resetPassword,
                          onRestart: _restartFlow,
                          onTogglePassword: () {
                            setState(() => _hidePassword = !_hidePassword);
                          },
                          onToggleConfirmPassword: () {
                            setState(
                              () =>
                                  _hideConfirmPassword = !_hideConfirmPassword,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecoveryBackground extends StatelessWidget {
  const _RecoveryBackground();

  @override
  Widget build(BuildContext context) {
    final themeColors = AppThemeColors.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: themeColors.isDark
              ? const [Color(0xFF0B1220), Color(0xFF111827), Color(0xFF172033)]
              : const [Color(0xFFFFFCFA), Color(0xFFFFFBF8), Color(0xFFFDF8F3)],
        ),
      ),
    );
  }
}

class _RecoveryHeader extends StatelessWidget {
  final VoidCallback onBack;

  const _RecoveryHeader({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
            boxShadow: const [
              BoxShadow(
                color: AppColors.cardShadow,
                blurRadius: 12,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back, color: AppColors.textBold),
            tooltip: 'Voltar',
          ),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Recuperar senha',
                style: TextStyle(
                  color: AppColors.textBold,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  height: 1.05,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Informe seu e-mail, valide o código recebido e defina uma nova senha.',
                style: TextStyle(
                  color: AppColors.textRegular,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RecoveryCard extends StatelessWidget {
  final bool requested;
  final GlobalKey<FormState> requestFormKey;
  final GlobalKey<FormState> resetFormKey;
  final TextEditingController emailController;
  final TextEditingController codeController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final String? demoRecoveryCode;
  final bool loading;
  final bool hidePassword;
  final bool hideConfirmPassword;
  final String? error;
  final VoidCallback onRequestCode;
  final VoidCallback onResetPassword;
  final VoidCallback onRestart;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirmPassword;

  const _RecoveryCard({
    required this.requested,
    required this.requestFormKey,
    required this.resetFormKey,
    required this.emailController,
    required this.codeController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.demoRecoveryCode,
    required this.loading,
    required this.hidePassword,
    required this.hideConfirmPassword,
    required this.error,
    required this.onRequestCode,
    required this.onResetPassword,
    required this.onRestart,
    required this.onTogglePassword,
    required this.onToggleConfirmPassword,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: requested
          ? _ResetForm(
              formKey: resetFormKey,
              emailController: emailController,
              codeController: codeController,
              passwordController: passwordController,
              confirmPasswordController: confirmPasswordController,
              demoRecoveryCode: demoRecoveryCode,
              loading: loading,
              hidePassword: hidePassword,
              hideConfirmPassword: hideConfirmPassword,
              error: error,
              onTogglePassword: onTogglePassword,
              onToggleConfirmPassword: onToggleConfirmPassword,
              onSubmit: onResetPassword,
              onRestart: onRestart,
            )
          : _RequestForm(
              formKey: requestFormKey,
              emailController: emailController,
              loading: loading,
              error: error,
              onSubmit: onRequestCode,
            ),
    );
  }
}

class _RequestForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final bool loading;
  final String? error;
  final VoidCallback onSubmit;

  const _RequestForm({
    required this.formKey,
    required this.emailController,
    required this.loading,
    required this.error,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _StepBadge(label: 'Etapa 1 de 2'),
          const SizedBox(height: 12),
          const Text(
            'Receba o código',
            style: TextStyle(
              color: AppColors.textBold,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Use o e-mail cadastrado na sua conta DuckHat.',
            style: TextStyle(
              color: AppColors.textRegular,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 18),
          _BaseField(
            controller: emailController,
            label: 'E-mail',
            hint: 'voce@email.com',
            icon: Icons.mail_outline,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => onSubmit(),
            validator: _validateEmail,
          ),
          if (error != null) ...[
            const SizedBox(height: 14),
            _ErrorBanner(message: error!),
          ],
          const SizedBox(height: 18),
          _PrimaryButton(
            label: 'Enviar código',
            loading: loading,
            onPressed: onSubmit,
          ),
        ],
      ),
    );
  }
}

class _ResetForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController codeController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final String? demoRecoveryCode;
  final bool loading;
  final bool hidePassword;
  final bool hideConfirmPassword;
  final String? error;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirmPassword;
  final VoidCallback onSubmit;
  final VoidCallback onRestart;

  const _ResetForm({
    required this.formKey,
    required this.emailController,
    required this.codeController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.demoRecoveryCode,
    required this.loading,
    required this.hidePassword,
    required this.hideConfirmPassword,
    required this.error,
    required this.onTogglePassword,
    required this.onToggleConfirmPassword,
    required this.onSubmit,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _StepBadge(label: 'Etapa 2 de 2'),
          const SizedBox(height: 12),
          const Text(
            'Defina a nova senha',
            style: TextStyle(
              color: AppColors.textBold,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Código enviado para ${emailController.text.trim().toLowerCase()}.',
            style: const TextStyle(
              color: AppColors.textRegular,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
          if (demoRecoveryCode != null && demoRecoveryCode!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _DemoCodeBanner(code: demoRecoveryCode!),
          ],
          const SizedBox(height: 18),
          _BaseField(
            controller: codeController,
            label: 'Código',
            hint: '000000',
            icon: Icons.password_outlined,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            validator: (value) {
              if ((value ?? '').trim().isEmpty) {
                return 'Informe o código de recuperação.';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          _BaseField(
            controller: passwordController,
            label: 'Nova senha',
            hint: 'Mínimo 6 caracteres',
            icon: Icons.lock_outline,
            obscureText: hidePassword,
            textInputAction: TextInputAction.next,
            suffix: IconButton(
              onPressed: loading ? null : onTogglePassword,
              tooltip: hidePassword ? 'Mostrar senha' : 'Ocultar senha',
              icon: Icon(
                hidePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
            ),
            validator: (value) {
              final password = value ?? '';
              if (password.isEmpty) return 'Informe a nova senha.';
              if (password.length < 6) {
                return 'A senha precisa ter ao menos 6 caracteres.';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          _BaseField(
            controller: confirmPasswordController,
            label: 'Confirmar nova senha',
            hint: 'Repita a senha',
            icon: Icons.verified_user_outlined,
            obscureText: hideConfirmPassword,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => onSubmit(),
            suffix: IconButton(
              onPressed: loading ? null : onToggleConfirmPassword,
              tooltip: hideConfirmPassword ? 'Mostrar senha' : 'Ocultar senha',
              icon: Icon(
                hideConfirmPassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
            ),
            validator: (value) {
              if ((value ?? '').isEmpty) return 'Confirme a nova senha.';
              if (value != passwordController.text) {
                return 'As senhas não conferem.';
              }
              return null;
            },
          ),
          if (error != null) ...[
            const SizedBox(height: 14),
            _ErrorBanner(message: error!),
          ],
          const SizedBox(height: 18),
          _PrimaryButton(
            label: 'Redefinir senha',
            loading: loading,
            onPressed: onSubmit,
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: loading ? null : onRestart,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textRegular,
              textStyle: const TextStyle(fontWeight: FontWeight.w800),
            ),
            child: const Text('Usar outro e-mail'),
          ),
        ],
      ),
    );
  }
}

class _StepBadge extends StatelessWidget {
  final String label;

  const _StepBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.accent.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.accent,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final bool loading;
  final VoidCallback onPressed;

  const _PrimaryButton({
    required this.label,
    required this.loading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: FilledButton(
        onPressed: loading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: Colors.white,
                ),
              )
            : Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
      ),
    );
  }
}

class _BaseField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final String? Function(String?) validator;

  const _BaseField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.validator,
    this.obscureText = false,
    this.suffix,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onFieldSubmitted: onSubmitted,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.accent),
        suffixIcon: suffix,
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.accent, width: 2),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;

  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.35)),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: AppColors.error,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _DemoCodeBanner extends StatelessWidget {
  final String code;

  const _DemoCodeBanner({required this.code});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.accent, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Modo demo: código $code',
              style: const TextStyle(
                color: AppColors.accent,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String? _validateEmail(String? value) {
  final email = value?.trim() ?? '';
  if (email.isEmpty) return 'Informe seu e-mail.';
  if (!email.contains('@') || !email.contains('.')) {
    return 'Digite um e-mail válido.';
  }
  return null;
}

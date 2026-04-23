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
  String? _generatedCode;

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
        email: _emailController.text,
      );

      if (!mounted) return;

      setState(() {
        _requested = true;
        _generatedCode = response.codigoRecuperacao;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString().replaceFirst('Exception: ', '').trim();
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
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
        email: _emailController.text,
        codigo: _codeController.text,
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
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _restartFlow() {
    setState(() {
      _requested = false;
      _generatedCode = null;
      _error = null;
      _codeController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset('assets/ondas.jpg', fit: BoxFit.cover),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 460),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _Header(onBack: () => Navigator.pop(context)),
                        const SizedBox(height: 28),
                        if (_requested)
                          _ResetForm(
                            formKey: _resetFormKey,
                            emailController: _emailController,
                            codeController: _codeController,
                            passwordController: _passwordController,
                            confirmPasswordController:
                                _confirmPasswordController,
                            generatedCode: _generatedCode,
                            loading: _loading,
                            hidePassword: _hidePassword,
                            hideConfirmPassword: _hideConfirmPassword,
                            error: _error,
                            onTogglePassword: () {
                              setState(() => _hidePassword = !_hidePassword);
                            },
                            onToggleConfirmPassword: () {
                              setState(
                                () => _hideConfirmPassword =
                                    !_hideConfirmPassword,
                              );
                            },
                            onSubmit: _resetPassword,
                            onRestart: _restartFlow,
                          )
                        else
                          _RequestForm(
                            formKey: _requestFormKey,
                            emailController: _emailController,
                            loading: _loading,
                            error: _error,
                            onSubmit: _requestCode,
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

class _Header extends StatelessWidget {
  final VoidCallback onBack;

  const _Header({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(14),
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
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  height: 1,
                  shadows: [
                    Shadow(
                      color: Colors.black38,
                      blurRadius: 12,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Solicite um código e redefina a senha pela API do backend.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  shadows: [
                    Shadow(
                      color: Colors.black38,
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
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
          SizedBox(
            height: 54,
            child: FilledButton(
              onPressed: loading ? null : onSubmit,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
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
                  : const Text('Gerar código de recuperação'),
            ),
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
  final String? generatedCode;
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
    required this.generatedCode,
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
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.cardShadow,
                  blurRadius: 14,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'E-mail: ${emailController.text.trim()}',
                  style: const TextStyle(
                    color: AppColors.textBold,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Digite o código recebido e a nova senha.',
                  style: TextStyle(color: AppColors.textRegular),
                ),
                if (generatedCode != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.accent.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Text(
                      'Código de demo: $generatedCode',
                      style: const TextStyle(
                        color: AppColors.textBold,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
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
                return 'As senhas nao conferem.';
              }
              return null;
            },
          ),
          if (error != null) ...[
            const SizedBox(height: 14),
            _ErrorBanner(message: error!),
          ],
          const SizedBox(height: 18),
          SizedBox(
            height: 54,
            child: FilledButton(
              onPressed: loading ? null : onSubmit,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
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
                  : const Text('Redefinir senha'),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: loading ? null : onRestart,
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              textStyle: const TextStyle(fontWeight: FontWeight.w800),
            ),
            child: const Text('Solicitar novo código'),
          ),
        ],
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
        fillColor: Colors.white,
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
        color: Colors.redAccent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4)),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: Colors.redAccent,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

String? _validateEmail(String? value) {
  final email = value?.trim() ?? '';
  if (email.isEmpty) return 'Informe seu e-mail.';
  if (!email.contains('@') || !email.contains('.')) {
    return 'Digite um e-mail valido.';
  }
  return null;
}

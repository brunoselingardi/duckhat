import 'package:duckhat/services/duckhat_api.dart';
import 'package:duckhat/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  _AccountType _accountType = _AccountType.cliente;
  bool _hidePassword = true;
  bool _loading = false;
  bool _devOfflineLogin = true;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate() || _loading) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      if (_devOfflineLogin) {
        await Future<void>.delayed(const Duration(milliseconds: 350));
        if (!mounted) return;
        _openApp();
        return;
      }

      final session = await DuckHatApi.instance.login(
        email: _emailController.text,
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

      if (!mounted) return;
      _openApp();
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

  void _openApp() {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const MainNavigator()));
  }

  void _showForgotPassword() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const ForgotPasswordPage()));
  }

  /*
  void _showForgotPasswordOld() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ForgotPasswordPage()),
    );
    return;

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Recuperar senha'),
          content: const Text(
            'A recuperação de senha ainda não está disponível. Fale com o suporte do DuckHat para redefinir o acesso.',
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Entendi'),
            ),
          ],
        );
      },
    );
  }
  */

  void _openCreateAccount() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const SignupPage()));
  }

  // ignore: unused_element
  void _showCreateAccount() {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Criar conta'),
          content: const Text(
            'O cadastro ainda não tem tela própria. A API já aceita novos usuários, então este link fica pronto para conectar ao próximo passo.',
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Entendi'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset('assets/ondas.jpg', fit: BoxFit.cover),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 720;

                  return Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 22, 24, 28),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: isWide ? 460 : double.infinity,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _HeaderArtwork(
                              isCompact: constraints.maxHeight < 680,
                            ),
                            const SizedBox(height: 28),
                            _LoginForm(
                              formKey: _formKey,
                              emailController: _emailController,
                              passwordController: _passwordController,
                              accountType: _accountType,
                              hidePassword: _hidePassword,
                              loading: _loading,
                              devOfflineLogin: _devOfflineLogin,
                              error: _error,
                              onAccountTypeChanged: (value) {
                                setState(() {
                                  _accountType = value;
                                  _error = null;
                                });
                              },
                              onTogglePassword: () {
                                setState(() => _hidePassword = !_hidePassword);
                              },
                              onDevOfflineLoginChanged: (value) {
                                setState(() {
                                  _devOfflineLogin = value;
                                  _error = null;
                                });
                              },
                              onSubmit: _submit,
                              onForgotPassword: _showForgotPassword,
                              onCreateAccount: _openCreateAccount,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderArtwork extends StatelessWidget {
  final bool isCompact;

  const _HeaderArtwork({required this.isCompact});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: isCompact ? 96 : 118,
          height: isCompact ? 96 : 118,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [
              BoxShadow(
                color: AppColors.cardShadow,
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Image.asset('assets/niceduck.jpg', fit: BoxFit.cover),
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'DuckHat',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 34,
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
        const SizedBox(height: 8),
        const Text(
          'Entre para cuidar dos seus horários',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w500,
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
    );
  }
}

class _LoginForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final _AccountType accountType;
  final bool hidePassword;
  final bool loading;
  final bool devOfflineLogin;
  final String? error;
  final ValueChanged<_AccountType> onAccountTypeChanged;
  final VoidCallback onTogglePassword;
  final ValueChanged<bool> onDevOfflineLoginChanged;
  final VoidCallback onSubmit;
  final VoidCallback onForgotPassword;
  final VoidCallback onCreateAccount;

  const _LoginForm({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.accountType,
    required this.hidePassword,
    required this.loading,
    required this.devOfflineLogin,
    required this.error,
    required this.onAccountTypeChanged,
    required this.onTogglePassword,
    required this.onDevOfflineLoginChanged,
    required this.onSubmit,
    required this.onForgotPassword,
    required this.onCreateAccount,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _AccountTypeSelector(
            selected: accountType,
            enabled: !loading,
            onChanged: onAccountTypeChanged,
          ),
          const SizedBox(height: 12),
          _DevOfflineToggle(
            enabled: !loading,
            value: devOfflineLogin,
            onChanged: onDevOfflineLoginChanged,
          ),
          const SizedBox(height: 18),
          _DuckHatTextField(
            controller: emailController,
            label: 'E-mail',
            hint: 'voce@email.com',
            icon: Icons.mail_outline,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: _validateEmail,
          ),
          const SizedBox(height: 14),
          _DuckHatTextField(
            controller: passwordController,
            label: 'Senha',
            hint: 'Sua senha',
            icon: Icons.lock_outline,
            obscureText: hidePassword,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => onSubmit(),
            suffix: IconButton(
              onPressed: loading ? null : onTogglePassword,
              tooltip: hidePassword ? 'Mostrar senha' : 'Ocultar senha',
              icon: Icon(
                hidePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
            ),
            validator: _validatePassword,
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: error == null
                ? const SizedBox(height: 18)
                : Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 6),
                    child: _ErrorBanner(message: error!),
                  ),
          ),
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
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
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
                  : Text('Entrar como ${accountType.label.toLowerCase()}'),
            ),
          ),
          const SizedBox(height: 14),
          TextButton(
            onPressed: loading ? null : onForgotPassword,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textMuted,
              textStyle: const TextStyle(fontWeight: FontWeight.w600),
            ),
            child: const Text('Esqueci minha senha'),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Flexible(
                child: Text(
                  'Ainda não tem acesso?',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    shadows: [
                      Shadow(
                        color: Colors.black38,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
              TextButton(
                onPressed: loading ? null : onCreateAccount,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontWeight: FontWeight.w800),
                ),
                child: const Text('Criar conta'),
              ),
            ],
          ),
        ],
      ),
    );
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
}

class _AccountTypeSelector extends StatelessWidget {
  final _AccountType selected;
  final bool enabled;
  final ValueChanged<_AccountType> onChanged;

  const _AccountTypeSelector({
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
              borderRadius: BorderRadius.circular(14),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                height: 52,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.accent : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? AppColors.accent : AppColors.border,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      type.icon,
                      size: 20,
                      color: isSelected ? Colors.white : AppColors.accent,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        type.label,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textBold,
                          fontWeight: FontWeight.w700,
                        ),
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

class _DevOfflineToggle extends StatelessWidget {
  final bool enabled;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _DevOfflineToggle({
    required this.enabled,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.code_outlined, color: AppColors.accent, size: 20),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Modo teste sem backend',
              style: TextStyle(
                color: AppColors.textBold,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: enabled ? onChanged : null,
            activeThumbColor: AppColors.accent,
            activeTrackColor: AppColors.accentLight,
          ),
        ],
      ),
    );
  }
}

class _DuckHatTextField extends StatelessWidget {
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

  const _DuckHatTextField({
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
      style: const TextStyle(
        color: AppColors.textBold,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.accent),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent),
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
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.redAccent, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.redAccent,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

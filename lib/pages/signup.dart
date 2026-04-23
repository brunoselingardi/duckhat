import 'package:duckhat/services/duckhat_api.dart';
import 'package:duckhat/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum SignupAccountType {
  cliente('Cliente', Icons.person_outline),
  empresa('Empresa', Icons.storefront_outlined);

  final String label;
  final IconData icon;

  const SignupAccountType(this.label, this.icon);
}

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();
  final _cnpjController = TextEditingController();
  final _empresaController = TextEditingController();
  final _responsavelController = TextEditingController();

  SignupAccountType _accountType = SignupAccountType.cliente;
  bool _hidePassword = true;
  bool _hideConfirmPassword = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    _cnpjController.dispose();
    _empresaController.dispose();
    _responsavelController.dispose();
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
      await DuckHatApi.instance.criarUsuario(
        nome: _accountType == SignupAccountType.cliente
            ? _nomeController.text
            : _empresaController.text,
        email: _emailController.text,
        senha: _senhaController.text,
        telefone: _telefoneController.text,
        tipo: _accountType == SignupAccountType.cliente
            ? 'CLIENTE'
            : 'PRESTADOR',
        cnpj: _accountType == SignupAccountType.empresa
            ? _cnpjController.text
            : null,
        responsavelNome: _accountType == SignupAccountType.empresa
            ? _responsavelController.text
            : null,
      );

      if (!mounted) return;

      Navigator.of(context).pop(
        SignupSuccessResult(
          email: _emailController.text.trim().toLowerCase(),
          password: _senhaController.text,
          accountType: _accountType,
        ),
      );
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
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 720;

                  return Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: isWide ? 500 : double.infinity,
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _SignupHeader(
                                onBack: () => Navigator.pop(context),
                              ),
                              const SizedBox(height: 22),
                              _SignupAccountSelector(
                                selected: _accountType,
                                enabled: !_loading,
                                onChanged: (value) {
                                  setState(() => _accountType = value);
                                },
                              ),
                              const SizedBox(height: 18),
                              if (_accountType == SignupAccountType.cliente)
                                _buildClientFields()
                              else
                                _buildCompanyFields(),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 180),
                                child: _error == null
                                    ? const SizedBox(height: 14)
                                    : Padding(
                                        padding: const EdgeInsets.only(
                                          top: 14,
                                          bottom: 2,
                                        ),
                                        child: _SignupErrorBanner(
                                          message: _error!,
                                        ),
                                      ),
                              ),
                              const SizedBox(height: 14),
                              _SignupTextField(
                                controller: _emailController,
                                label: 'E-mail',
                                hint: 'voce@email.com',
                                icon: Icons.mail_outline,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                validator: _validateEmail,
                              ),
                              const SizedBox(height: 14),
                              _SignupTextField(
                                controller: _telefoneController,
                                label: 'Telefone',
                                hint: '(00) 00000-0000',
                                icon: Icons.phone_outlined,
                                keyboardType: TextInputType.phone,
                                textInputAction: TextInputAction.next,
                                validator: _validatePhone,
                              ),
                              const SizedBox(height: 14),
                              _SignupTextField(
                                controller: _senhaController,
                                label: 'Senha',
                                hint: 'Minimo 6 caracteres',
                                icon: Icons.lock_outline,
                                obscureText: _hidePassword,
                                textInputAction: TextInputAction.next,
                                suffix: IconButton(
                                  onPressed: _loading
                                      ? null
                                      : () {
                                          setState(
                                            () =>
                                                _hidePassword = !_hidePassword,
                                          );
                                        },
                                  tooltip: _hidePassword
                                      ? 'Mostrar senha'
                                      : 'Ocultar senha',
                                  icon: Icon(
                                    _hidePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                  ),
                                ),
                                validator: _validatePassword,
                              ),
                              const SizedBox(height: 14),
                              _SignupTextField(
                                controller: _confirmarSenhaController,
                                label: 'Confirmar senha',
                                hint: 'Repita sua senha',
                                icon: Icons.verified_user_outlined,
                                obscureText: _hideConfirmPassword,
                                textInputAction: TextInputAction.done,
                                onSubmitted: (_) => _submit(),
                                suffix: IconButton(
                                  onPressed: _loading
                                      ? null
                                      : () {
                                          setState(
                                            () => _hideConfirmPassword =
                                                !_hideConfirmPassword,
                                          );
                                        },
                                  tooltip: _hideConfirmPassword
                                      ? 'Mostrar senha'
                                      : 'Ocultar senha',
                                  icon: Icon(
                                    _hideConfirmPassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                  ),
                                ),
                                validator: _validateConfirmPassword,
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                height: 54,
                                child: FilledButton(
                                  onPressed: _loading ? null : _submit,
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
                                  child: _loading
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.4,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Text(
                                          'Criar conta ${_accountType.label.toLowerCase()}',
                                        ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              TextButton(
                                onPressed: _loading
                                    ? null
                                    : () => Navigator.of(context).pop(),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  textStyle: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                child: const Text('Ja tenho conta'),
                              ),
                            ],
                          ),
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

  Widget _buildClientFields() {
    return _SignupTextField(
      controller: _nomeController,
      label: 'Nome completo',
      hint: 'Seu nome',
      icon: Icons.badge_outlined,
      textInputAction: TextInputAction.next,
      validator: _validateRequired,
    );
  }

  Widget _buildCompanyFields() {
    return Column(
      children: [
        _SignupTextField(
          controller: _empresaController,
          label: 'Nome da empresa',
          hint: 'Ex: DuckHat Studio',
          icon: Icons.storefront_outlined,
          textInputAction: TextInputAction.next,
          validator: _validateRequired,
        ),
        const SizedBox(height: 14),
        _SignupTextField(
          controller: _cnpjController,
          label: 'CNPJ',
          hint: '00.000.000/0000-00',
          icon: Icons.apartment_outlined,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: _validateCnpj,
        ),
        const SizedBox(height: 14),
        _SignupTextField(
          controller: _responsavelController,
          label: 'Responsavel',
          hint: 'Nome do responsavel',
          icon: Icons.person_pin_outlined,
          textInputAction: TextInputAction.next,
          validator: _validateRequired,
        ),
      ],
    );
  }

  String? _validateRequired(String? value) {
    if ((value ?? '').trim().isEmpty) return 'Preencha este campo.';
    return null;
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Informe seu e-mail.';
    if (!email.contains('@') || !email.contains('.')) {
      return 'Digite um e-mail valido.';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    final digits = (value ?? '').replaceAll(RegExp(r'\D'), '');
    if (digits.length < 10) return 'Informe um telefone valido.';
    return null;
  }

  String? _validateCnpj(String? value) {
    final digits = (value ?? '').replaceAll(RegExp(r'\D'), '');
    if (digits.length != 14) return 'Informe um CNPJ com 14 digitos.';
    return null;
  }

  String? _validatePassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) return 'Informe uma senha.';
    if (password.length < 6) {
      return 'A senha precisa ter ao menos 6 caracteres.';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if ((value ?? '').isEmpty) return 'Confirme sua senha.';
    if (value != _senhaController.text) return 'As senhas nao conferem.';
    return null;
  }
}

class _SignupHeader extends StatelessWidget {
  final VoidCallback onBack;

  const _SignupHeader({required this.onBack});

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
                'Criar conta',
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
                'Escolha o tipo de acesso e preencha so o necessario.',
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

class _SignupAccountSelector extends StatelessWidget {
  final SignupAccountType selected;
  final bool enabled;
  final ValueChanged<SignupAccountType> onChanged;

  const _SignupAccountSelector({
    required this.selected,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: SignupAccountType.values.map((type) {
        final isSelected = selected == type;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: type == SignupAccountType.cliente ? 10 : 0,
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

class _SignupTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?) validator;

  const _SignupTextField({
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
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onFieldSubmitted: onSubmitted,
      inputFormatters: inputFormatters,
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

class SignupSuccessResult {
  final String email;
  final String password;
  final SignupAccountType accountType;

  const SignupSuccessResult({
    required this.email,
    required this.password,
    required this.accountType,
  });
}

class _SignupErrorBanner extends StatelessWidget {
  final String message;

  const _SignupErrorBanner({required this.message});

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

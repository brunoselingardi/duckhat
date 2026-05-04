import 'dart:async';
import 'dart:io';

import 'package:duckhat/pages/app_shell.dart';
import 'package:duckhat/pages/post_login_transition_page.dart';
import 'package:duckhat/services/duckhat_api.dart';
import 'package:duckhat/shop_main.dart';
import 'package:duckhat/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

enum SignupAccountType {
  cliente('Cliente', Icons.person_outline),
  empresa('Empresa', Icons.storefront_outlined);

  final String label;
  final IconData icon;

  const SignupAccountType(this.label, this.icon);
}

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SignupScaffold(child: _AccountTypeChoicePage());
  }
}

class _AccountTypeChoicePage extends StatelessWidget {
  const _AccountTypeChoicePage();

  void _open(BuildContext context, Widget page) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 520),
        reverseTransitionDuration: const Duration(milliseconds: 260),
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.08),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _SignupScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(
            title: 'Escolha como quer entrar',
            subtitle: 'Cada tipo de conta tem um cadastro proprio.',
            onBack: () => Navigator.of(context).pop(),
          ),
          const SizedBox(height: 28),
          _Entrance(
            delayMs: 80,
            child: _ChoiceButton(
              icon: Icons.person_outline,
              title: 'Sou cliente',
              subtitle: 'Agende servicos e acompanhe seus horarios.',
              onTap: () => _open(context, const ClientSignupPage()),
            ),
          ),
          const SizedBox(height: 14),
          _Entrance(
            delayMs: 160,
            child: _ChoiceButton(
              icon: Icons.storefront_outlined,
              title: 'Sou estabelecimento',
              subtitle: 'Cadastre sua empresa para receber agendamentos.',
              onTap: () => _open(context, const BusinessSignupPage()),
            ),
          ),
          const Spacer(),
          Center(
            child: Image.asset(
              'assets/duck-dance.gif',
              width: 112,
              height: 112,
              gaplessPlayback: true,
            ),
          ),
        ],
      ),
    );
  }
}

class ClientSignupPage extends StatefulWidget {
  const ClientSignupPage({super.key});

  @override
  State<ClientSignupPage> createState() => _ClientSignupPageState();
}

class _ClientSignupPageState extends State<ClientSignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();
  final _imageController = _SignupImageController();

  bool _hidePassword = true;
  bool _hideConfirmPassword = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  Future<void> _pickProfileImage() async {
    final result = await _imageController.pick();
    if (!mounted || result == null) return;
    if (result.error != null) {
      setState(() => _error = result.error);
      return;
    }
    setState(() => _imageController.image = result.image);
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
        nome: _nomeController.text,
        email: _emailController.text,
        senha: _senhaController.text,
        telefone: '',
        tipo: 'CLIENTE',
      );
      await DuckHatApi.instance.login(
        email: _emailController.text.trim(),
        password: _senhaController.text,
      );

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        InstantPageRoute(
          child: const PostLoginTransitionPage(
            destination: MainNavigator(),
            title: 'Conta criada',
            subtitle: 'Seu perfil DuckHat ja esta pronto.',
          ),
        ),
        (_) => false,
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString().replaceFirst('Exception: ', '').trim();
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _SignupScaffold(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Header(
              title: 'Crie seu perfil',
              subtitle: 'Sua foto ajuda os estabelecimentos a reconhecer voce.',
              onBack: () => Navigator.of(context).pop(),
            ),
            const SizedBox(height: 22),
            Center(
              child: _AvatarPickerButton(
                image: _imageController.image,
                enabled: !_loading,
                onPressed: _pickProfileImage,
              ),
            ),
            const SizedBox(height: 24),
            _SignupTextField(
              controller: _nomeController,
              label: 'Nome completo',
              hint: 'Seu nome e sobrenome',
              icon: Icons.badge_outlined,
              textInputAction: TextInputAction.next,
              validator: _validateRequired,
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
              controller: _senhaController,
              label: 'Senha',
              hint: 'Minimo 6 caracteres',
              icon: Icons.lock_outline,
              obscureText: _hidePassword,
              textInputAction: TextInputAction.next,
              suffix: _PasswordToggle(
                hidden: _hidePassword,
                enabled: !_loading,
                onPressed: () {
                  setState(() => _hidePassword = !_hidePassword);
                },
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
              suffix: _PasswordToggle(
                hidden: _hideConfirmPassword,
                enabled: !_loading,
                onPressed: () {
                  setState(() => _hideConfirmPassword = !_hideConfirmPassword);
                },
              ),
              validator: (value) =>
                  _validateConfirmPassword(value, _senhaController.text),
            ),
            _ErrorSlot(message: _error),
            _PrimaryButton(
              label: 'Next',
              loading: _loading,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}

class BusinessSignupPage extends StatefulWidget {
  const BusinessSignupPage({super.key});

  @override
  State<BusinessSignupPage> createState() => _BusinessSignupPageState();
}

class _BusinessSignupPageState extends State<BusinessSignupPage> {
  final _pageController = PageController();
  final _businessFormKey = GlobalKey<FormState>();
  final _responsibleFormKey = GlobalKey<FormState>();
  final _accessFormKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _responsavelController = TextEditingController();
  final _cnpjController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();
  final _imageController = _SignupImageController();

  int _step = 0;
  bool _hidePassword = true;
  bool _hideConfirmPassword = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _pageController.dispose();
    _nomeController.dispose();
    _responsavelController.dispose();
    _cnpjController.dispose();
    _telefoneController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  Future<void> _pickProfileImage() async {
    final result = await _imageController.pick();
    if (!mounted || result == null) return;
    if (result.error != null) {
      setState(() => _error = result.error);
      return;
    }
    setState(() => _imageController.image = result.image);
  }

  Future<void> _next() async {
    FocusScope.of(context).unfocus();
    if (_step == 0 && !_businessFormKey.currentState!.validate()) return;
    if (_step == 1 && !_responsibleFormKey.currentState!.validate()) return;
    if (_step < 2) {
      setState(() {
        _step += 1;
        _error = null;
      });
      await _pageController.animateToPage(
        _step,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
      return;
    }
    await _submit();
  }

  Future<void> _backStep() async {
    if (_step == 0) {
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _step -= 1;
      _error = null;
    });
    await _pageController.animateToPage(
      _step,
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _submit() async {
    if (!_accessFormKey.currentState!.validate() || _loading) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await DuckHatApi.instance.criarUsuario(
        nome: _nomeController.text,
        email: _emailController.text,
        senha: _senhaController.text,
        telefone: _telefoneController.text,
        tipo: 'PRESTADOR',
        cnpj: _cnpjController.text,
        responsavelNome: _responsavelController.text,
      );
      await DuckHatApi.instance.login(
        email: _emailController.text.trim(),
        password: _senhaController.text,
      );

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        InstantPageRoute(
          child: const PostLoginTransitionPage(
            destination: ShopMainNavigator(),
            title: 'Estabelecimento criado',
            subtitle: 'Sua area de empresa ja esta pronta.',
          ),
        ),
        (_) => false,
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString().replaceFirst('Exception: ', '').trim();
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _SignupScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(
            title: 'Cadastro do estabelecimento',
            subtitle: 'Preencha uma etapa por vez.',
            onBack: _backStep,
          ),
          const SizedBox(height: 20),
          _StepIndicator(current: _step, total: 3),
          const SizedBox(height: 20),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                Form(
                  key: _businessFormKey,
                  child: _BusinessDataStep(
                    image: _imageController.image,
                    enabled: !_loading,
                    onPickImage: _pickProfileImage,
                    nameController: _nomeController,
                  ),
                ),
                Form(
                  key: _responsibleFormKey,
                  child: _ResponsibleStep(
                    responsibleController: _responsavelController,
                    cnpjController: _cnpjController,
                    phoneController: _telefoneController,
                  ),
                ),
                Form(
                  key: _accessFormKey,
                  child: _AccessStep(
                    emailController: _emailController,
                    passwordController: _senhaController,
                    confirmPasswordController: _confirmarSenhaController,
                    hidePassword: _hidePassword,
                    hideConfirmPassword: _hideConfirmPassword,
                    loading: _loading,
                    onTogglePassword: () {
                      setState(() => _hidePassword = !_hidePassword);
                    },
                    onToggleConfirmPassword: () {
                      setState(
                        () => _hideConfirmPassword = !_hideConfirmPassword,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          _ErrorSlot(message: _error),
          Row(
            children: [
              if (_step > 0) ...[
                Expanded(
                  child: OutlinedButton(
                    onPressed: _loading ? null : _backStep,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('Voltar'),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                flex: 2,
                child: _PrimaryButton(
                  label: _step == 2 ? 'Criar estabelecimento' : 'Next',
                  loading: _loading,
                  onPressed: _next,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BusinessDataStep extends StatelessWidget {
  final File? image;
  final bool enabled;
  final VoidCallback onPickImage;
  final TextEditingController nameController;

  const _BusinessDataStep({
    required this.image,
    required this.enabled,
    required this.onPickImage,
    required this.nameController,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _StepTitle(
            title: 'Dados do estabelecimento',
            subtitle: 'Comece pela identidade publica da sua empresa.',
          ),
          const SizedBox(height: 20),
          Center(
            child: _AvatarPickerButton(
              image: image,
              enabled: enabled,
              onPressed: onPickImage,
            ),
          ),
          const SizedBox(height: 24),
          _SignupTextField(
            controller: nameController,
            label: 'Nome do estabelecimento',
            hint: 'Ex: DuckHat Studio',
            icon: Icons.storefront_outlined,
            textInputAction: TextInputAction.done,
            validator: _validateRequired,
          ),
        ],
      ),
    );
  }
}

class _ResponsibleStep extends StatelessWidget {
  final TextEditingController responsibleController;
  final TextEditingController cnpjController;
  final TextEditingController phoneController;

  const _ResponsibleStep({
    required this.responsibleController,
    required this.cnpjController,
    required this.phoneController,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _StepTitle(
            title: 'Responsavel e contato',
            subtitle: 'Esses dados ajudam a validar o estabelecimento.',
          ),
          const SizedBox(height: 20),
          _SignupTextField(
            controller: responsibleController,
            label: 'Responsavel',
            hint: 'Nome do responsavel',
            icon: Icons.person_pin_outlined,
            textInputAction: TextInputAction.next,
            validator: _validateRequired,
          ),
          const SizedBox(height: 14),
          _SignupTextField(
            controller: cnpjController,
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
            controller: phoneController,
            label: 'Telefone',
            hint: '(00) 00000-0000',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
            validator: _validateOptionalPhone,
          ),
        ],
      ),
    );
  }
}

class _AccessStep extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool hidePassword;
  final bool hideConfirmPassword;
  final bool loading;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirmPassword;

  const _AccessStep({
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.hidePassword,
    required this.hideConfirmPassword,
    required this.loading,
    required this.onTogglePassword,
    required this.onToggleConfirmPassword,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _StepTitle(
            title: 'Acesso da empresa',
            subtitle: 'Use esse e-mail para entrar na area do estabelecimento.',
          ),
          const SizedBox(height: 20),
          _SignupTextField(
            controller: emailController,
            label: 'E-mail',
            hint: 'empresa@email.com',
            icon: Icons.mail_outline,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: _validateEmail,
          ),
          const SizedBox(height: 14),
          _SignupTextField(
            controller: passwordController,
            label: 'Senha',
            hint: 'Minimo 6 caracteres',
            icon: Icons.lock_outline,
            obscureText: hidePassword,
            textInputAction: TextInputAction.next,
            suffix: _PasswordToggle(
              hidden: hidePassword,
              enabled: !loading,
              onPressed: onTogglePassword,
            ),
            validator: _validatePassword,
          ),
          const SizedBox(height: 14),
          _SignupTextField(
            controller: confirmPasswordController,
            label: 'Confirmar senha',
            hint: 'Repita sua senha',
            icon: Icons.verified_user_outlined,
            obscureText: hideConfirmPassword,
            textInputAction: TextInputAction.done,
            suffix: _PasswordToggle(
              hidden: hideConfirmPassword,
              enabled: !loading,
              onPressed: onToggleConfirmPassword,
            ),
            validator: (value) =>
                _validateConfirmPassword(value, passwordController.text),
          ),
        ],
      ),
    );
  }
}

class _SignupScaffold extends StatelessWidget {
  final Widget child;

  const _SignupScaffold({required this.child});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFFBF5F7),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 720;
              return Center(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isWide ? 500 : double.infinity,
                    ),
                    child: child,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onBack;

  const _Header({
    required this.title,
    required this.subtitle,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [
              BoxShadow(
                color: Color(0x11000000),
                blurRadius: 16,
                offset: Offset(0, 8),
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
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textBold,
                  fontSize: 29,
                  fontWeight: FontWeight.w800,
                  height: 1.05,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.textRegular,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ChoiceButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ChoiceButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0F000000),
                blurRadius: 18,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  color: Color(0xFFEAF3FF),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.accent),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.textBold,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.textRegular,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _AvatarPickerButton extends StatelessWidget {
  final File? image;
  final bool enabled;
  final VoidCallback onPressed;

  const _AvatarPickerButton({
    required this.image,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: enabled ? onPressed : null,
        child: Ink(
          width: 126,
          height: 126,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: AppColors.border, width: 1.5),
            image: image == null
                ? null
                : DecorationImage(image: FileImage(image!), fit: BoxFit.cover),
            boxShadow: const [
              BoxShadow(
                color: Color(0x18000000),
                blurRadius: 18,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: image == null
              ? const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_a_photo_outlined,
                      color: AppColors.accent,
                      size: 26,
                    ),
                    SizedBox(height: 7),
                    Text(
                      'Adicionar foto',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textBold,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                )
              : Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 15,
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int current;
  final int total;

  const _StepIndicator({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (index) {
        final active = index <= current;
        return Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            height: 5,
            margin: EdgeInsets.only(right: index == total - 1 ? 0 : 7),
            decoration: BoxDecoration(
              color: active ? AppColors.accent : AppColors.border,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
        );
      }),
    );
  }
}

class _StepTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _StepTitle({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textBold,
            fontSize: 21,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: const TextStyle(
            color: AppColors.textRegular,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
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
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.accent, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
    );
  }
}

class _PasswordToggle extends StatelessWidget {
  final bool hidden;
  final bool enabled;
  final VoidCallback onPressed;

  const _PasswordToggle({
    required this.hidden,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: enabled ? onPressed : null,
      tooltip: hidden ? 'Mostrar senha' : 'Ocultar senha',
      icon: Icon(
        hidden ? Icons.visibility_outlined : Icons.visibility_off_outlined,
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
      height: 56,
      child: FilledButton(
        onPressed: loading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
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
            : Text(label),
      ),
    );
  }
}

class _ErrorSlot extends StatelessWidget {
  final String? message;

  const _ErrorSlot({required this.message});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      child: message == null
          ? const SizedBox(height: 18)
          : Padding(
              padding: const EdgeInsets.only(top: 16),
              child: _SignupErrorBanner(message: message!),
            ),
    );
  }
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

class _SignupImageController {
  final _picker = ImagePicker();
  File? image;

  Future<_ImagePickResult?> pick() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1800,
        imageQuality: 86,
      );
      if (picked == null) return null;
      return _ImagePickResult(image: File(picked.path));
    } on PlatformException catch (error) {
      return _ImagePickResult(
        error: error.message ?? 'Nao foi possivel abrir a galeria do aparelho.',
      );
    }
  }
}

class _ImagePickResult {
  final File? image;
  final String? error;

  const _ImagePickResult({this.image, this.error});
}

class _Entrance extends StatefulWidget {
  final Widget child;
  final int delayMs;

  const _Entrance({required this.child, required this.delayMs});

  @override
  State<_Entrance> createState() => _EntranceState();
}

class _EntranceState extends State<_Entrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    _timer = Timer(Duration(milliseconds: widget.delayMs), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
        ).animate(curved),
        child: widget.child,
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

String? _validatePassword(String? value) {
  final password = value ?? '';
  if (password.isEmpty) return 'Informe uma senha.';
  if (password.length < 6) {
    return 'A senha precisa ter ao menos 6 caracteres.';
  }
  return null;
}

String? _validateConfirmPassword(String? value, String password) {
  if ((value ?? '').isEmpty) return 'Confirme sua senha.';
  if (value != password) return 'As senhas nao conferem.';
  return null;
}

String? _validateCnpj(String? value) {
  final digits = (value ?? '').replaceAll(RegExp(r'\D'), '');
  if (digits.length != 14) return 'Informe um CNPJ com 14 digitos.';
  return null;
}

String? _validateOptionalPhone(String? value) {
  final digits = (value ?? '').replaceAll(RegExp(r'\D'), '');
  if (digits.isNotEmpty && digits.length < 10) {
    return 'Informe um telefone valido.';
  }
  return null;
}

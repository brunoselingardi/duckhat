import 'dart:async';
import 'dart:io';

import 'package:duckhat/pages/app_shell.dart';
import 'package:duckhat/pages/post_login_transition_page.dart';
import 'package:duckhat/services/duckhat_api.dart';
import 'package:duckhat/shop_main.dart';
import 'package:duckhat/theme.dart';
import 'package:duckhat/models/usuario_perfil.dart';
import 'package:duckhat/utils/image_base64.dart';
import 'package:duckhat/utils/profile_validators.dart';
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
  final _profileFormKey = GlobalKey<FormState>();
  final _servicesFormKey = GlobalKey<FormState>();
  final _responsibleFormKey = GlobalKey<FormState>();
  final _accessFormKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _hoursController = TextEditingController(
    text: 'Segunda a sexta 9h - 20h',
  );
  final _responsavelController = TextEditingController();
  final _cnpjController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();
  final _bannerController = _SignupImageController();
  final List<_SignupServiceDraft> _services = [_SignupServiceDraft()];

  int _step = 0;
  bool _hidePassword = true;
  bool _hideConfirmPassword = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _pageController.dispose();
    _nomeController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    _hoursController.dispose();
    _responsavelController.dispose();
    _cnpjController.dispose();
    _telefoneController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    for (final service in _services) {
      service.dispose();
    }
    super.dispose();
  }

  Future<void> _pickBannerImage() async {
    final result = await _bannerController.pick();
    if (!mounted || result == null) return;
    if (result.error != null) {
      setState(() => _error = result.error);
      return;
    }
    setState(() => _bannerController.image = result.image);
  }

  Future<void> _next() async {
    FocusScope.of(context).unfocus();
    if (_step == 0 && !_businessFormKey.currentState!.validate()) return;
    if (_step == 1 && !_profileFormKey.currentState!.validate()) return;
    if (_step == 2 && !_servicesFormKey.currentState!.validate()) return;
    if (_step == 3 && !_responsibleFormKey.currentState!.validate()) return;
    if (_step < 4) {
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
      final bannerBase64 = await encodeImageFileAsBase64(
        _bannerController.image,
      );
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

      var vitrineCompleta = true;
      try {
        final session = DuckHatApi.instance.currentSession;
        if (session != null) {
          await DuckHatApi.instance.atualizarMeuPerfil(
            UsuarioPerfil(
              id: session.id,
              nome: _nomeController.text,
              email: _emailController.text,
              telefone: _telefoneController.text,
              cnpj: ProfileValidators.digitsOnly(_cnpjController.text),
              responsavelNome: _responsavelController.text,
              dataNascimento: null,
              endereco: _addressController.text,
              descricao: _descriptionController.text,
              horarioAtendimento: _hoursController.text,
              bannerImagemBase64: bannerBase64,
              tipo: 'PRESTADOR',
            ),
          );
        }

        for (final service in _services) {
          await DuckHatApi.instance.criarServico(
            nome: service.nameController.text,
            descricao: service.descriptionController.text,
            duracaoMin: service.durationMin,
            preco: service.priceValue!,
            ativo: true,
          );
        }
      } catch (_) {
        vitrineCompleta = false;
      }

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        InstantPageRoute(
          child: PostLoginTransitionPage(
            destination: const ShopMainNavigator(),
            title: 'Estabelecimento criado',
            subtitle: vitrineCompleta
                ? 'Sua vitrine e seus servicos iniciais ja estao prontos.'
                : 'Sua conta foi criada. Revise a vitrine e os servicos no perfil.',
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
          _StepIndicator(current: _step, total: 5),
          const SizedBox(height: 20),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                Form(
                  key: _businessFormKey,
                  child: _BusinessDataStep(
                    image: _bannerController.image,
                    enabled: !_loading,
                    onPickImage: _pickBannerImage,
                    nameController: _nomeController,
                  ),
                ),
                Form(
                  key: _profileFormKey,
                  child: _BusinessProfileStep(
                    addressController: _addressController,
                    descriptionController: _descriptionController,
                    hoursController: _hoursController,
                  ),
                ),
                Form(
                  key: _servicesFormKey,
                  child: _BusinessServicesStep(
                    services: _services,
                    onAddService: () {
                      setState(() => _services.add(_SignupServiceDraft()));
                    },
                    onRemoveService: (index) {
                      if (_services.length == 1) return;
                      setState(() => _services.removeAt(index).dispose());
                    },
                    onChanged: () => setState(() {}),
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
                  label: _step == 4 ? 'Criar estabelecimento' : 'Next',
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
            subtitle:
                'Comece pela identidade publica e pelo banner da vitrine.',
          ),
          const SizedBox(height: 20),
          _BannerPickerButton(
            image: image,
            enabled: enabled,
            onPressed: onPickImage,
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

class _BusinessProfileStep extends StatelessWidget {
  final TextEditingController addressController;
  final TextEditingController descriptionController;
  final TextEditingController hoursController;

  const _BusinessProfileStep({
    required this.addressController,
    required this.descriptionController,
    required this.hoursController,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _StepTitle(
            title: 'Descricao da vitrine',
            subtitle:
                'Escreva como o cliente vai entender seu estabelecimento.',
          ),
          const SizedBox(height: 20),
          _SignupTextField(
            controller: descriptionController,
            label: 'Descricao do estabelecimento',
            hint: 'Ambiente, especialidade e diferenciais',
            icon: Icons.notes_rounded,
            textInputAction: TextInputAction.next,
            maxLines: 4,
            validator: _validateBusinessDescription,
          ),
          const SizedBox(height: 14),
          _SignupTextField(
            controller: addressController,
            label: 'Endereço',
            hint: 'Rua, numero, bairro',
            icon: Icons.location_on_outlined,
            textInputAction: TextInputAction.next,
            validator: ProfileValidators.address,
          ),
          const SizedBox(height: 14),
          _SignupTextField(
            controller: hoursController,
            label: 'Horario de atendimento',
            hint: 'Segunda a sexta 9h - 20h',
            icon: Icons.access_time_rounded,
            textInputAction: TextInputAction.done,
            validator: _validateOptionalShortText,
          ),
        ],
      ),
    );
  }
}

class _BusinessServicesStep extends StatelessWidget {
  final List<_SignupServiceDraft> services;
  final VoidCallback onAddService;
  final ValueChanged<int> onRemoveService;
  final VoidCallback onChanged;

  const _BusinessServicesStep({
    required this.services,
    required this.onAddService,
    required this.onRemoveService,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _StepTitle(
            title: 'Servicos iniciais',
            subtitle:
                'Cadastre os servicos que ja podem aparecer na sua vitrine.',
          ),
          const SizedBox(height: 18),
          _SignupServiceSummary(total: services.length),
          const SizedBox(height: 14),
          for (var index = 0; index < services.length; index++) ...[
            _SignupServiceCard(
              draft: services[index],
              index: index,
              canRemove: services.length > 1,
              onRemove: () => onRemoveService(index),
              onChanged: onChanged,
            ),
            const SizedBox(height: 12),
          ],
          OutlinedButton.icon(
            onPressed: services.length >= 5 ? null : onAddService,
            icon: const Icon(Icons.add_circle_outline),
            label: const Text('Adicionar serviço'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.accent,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SignupServiceSummary extends StatelessWidget {
  final int total;

  const _SignupServiceSummary({required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF3FF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.storefront_outlined,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              total == 1
                  ? 'Comece com o serviço principal da sua vitrine.'
                  : '$total serviços iniciais serão publicados após criar a conta.',
              style: const TextStyle(
                color: AppColors.textBold,
                fontSize: 12,
                height: 1.35,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SignupServiceCard extends StatelessWidget {
  final _SignupServiceDraft draft;
  final int index;
  final bool canRemove;
  final VoidCallback onRemove;
  final VoidCallback onChanged;

  const _SignupServiceCard({
    required this.draft,
    required this.index,
    required this.canRemove,
    required this.onRemove,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.11),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.design_services_outlined,
                  color: AppColors.accent,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Serviço ${index + 1}',
                      style: const TextStyle(
                        color: AppColors.textBold,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const _SignupServicePill(
                      icon: Icons.visibility_outlined,
                      label: 'Serviço ativo',
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: canRemove ? onRemove : null,
                tooltip: 'Remover serviço',
                icon: const Icon(Icons.delete_outline),
                color: AppColors.error,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SignupTextField(
            controller: draft.nameController,
            label: 'Nome do serviço',
            hint: 'Ex: Corte masculino',
            icon: Icons.design_services_outlined,
            textInputAction: TextInputAction.next,
            validator: _validateRequired,
          ),
          const SizedBox(height: 12),
          _SignupTextField(
            controller: draft.descriptionController,
            label: 'Descrição do serviço',
            hint: 'Explique o que está incluso',
            icon: Icons.short_text_rounded,
            textInputAction: TextInputAction.next,
            maxLines: 3,
            validator: _validateServiceDescription,
          ),
          const SizedBox(height: 14),
          const _ServiceSubsectionLabel(
            icon: Icons.tune_rounded,
            label: 'Duração e preço',
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _DurationStepper(
                  durationMin: draft.durationMin,
                  onChanged: (value) {
                    draft.durationMin = value;
                    onChanged();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SignupTextField(
                  controller: draft.priceController,
                  label: 'Preço',
                  hint: '0,00',
                  icon: Icons.payments_outlined,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textInputAction: TextInputAction.done,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d,.]')),
                    LengthLimitingTextInputFormatter(9),
                  ],
                  validator: _validatePrice,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SignupServicePill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SignupServicePill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.success),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textBold,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceSubsectionLabel extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ServiceSubsectionLabel({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.accent, size: 17),
        const SizedBox(width: 7),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textBold,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _DurationStepper extends StatelessWidget {
  final int durationMin;
  final ValueChanged<int> onChanged;

  const _DurationStepper({required this.durationMin, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: durationMin <= 10
                ? null
                : () => onChanged(durationMin - 5),
            icon: const Icon(Icons.remove_circle_outline),
            color: AppColors.accent,
            tooltip: 'Reduzir duração',
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$durationMin min',
                  style: const TextStyle(
                    color: AppColors.textBold,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Text(
                  'Duração',
                  style: TextStyle(
                    color: AppColors.textRegular,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: durationMin >= 240
                ? null
                : () => onChanged(durationMin + 5),
            icon: const Icon(Icons.add_circle_outline),
            color: AppColors.accent,
            tooltip: 'Aumentar duração',
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

class _BannerPickerButton extends StatelessWidget {
  final File? image;
  final bool enabled;
  final VoidCallback onPressed;

  const _BannerPickerButton({
    required this.image,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: enabled ? onPressed : null,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          height: 166,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
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
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (image != null)
                DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.04),
                        Colors.black.withValues(alpha: 0.34),
                      ],
                    ),
                  ),
                ),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.add_photo_alternate_outlined,
                        color: AppColors.accent,
                        size: 21,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        image == null ? 'Adicionar banner' : 'Trocar banner',
                        style: const TextStyle(
                          color: AppColors.textBold,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
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
  final int maxLines;

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
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      maxLines: obscureText ? 1 : maxLines,
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
        maxWidth: 1400,
        imageQuality: 78,
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

class _SignupServiceDraft {
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  int durationMin = 30;

  double? get priceValue => _parsePrice(priceController.text);

  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
  }
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
  return ProfileValidators.phone(value);
}

String? _validateBusinessDescription(String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return 'Descreva seu estabelecimento.';
  if (text.length > 500) return 'Use ate 500 caracteres.';
  return null;
}

String? _validateServiceDescription(String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return 'Descreva o serviço.';
  if (text.length > 1000) return 'Use ate 1000 caracteres.';
  return null;
}

String? _validateOptionalShortText(String? value) {
  final text = value?.trim() ?? '';
  if (text.length > 160) return 'Use ate 160 caracteres.';
  return null;
}

String? _validatePrice(String? value) {
  final price = _parsePrice(value ?? '');
  if (price == null) return 'Informe um preço valido.';
  if (price <= 0) return 'O preço precisa ser maior que zero.';
  if (price > 99999.99) return 'Use um preço menor.';
  return null;
}

double? _parsePrice(String value) {
  final trimmed = value.trim();
  final normalized = trimmed.contains(',')
      ? trimmed.replaceAll('.', '').replaceAll(',', '.')
      : trimmed;
  if (normalized.isEmpty) return null;
  return double.tryParse(normalized);
}

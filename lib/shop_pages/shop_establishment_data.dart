import 'dart:convert';
import 'dart:io';

import 'package:duckhat/models/usuario_perfil.dart';
import 'package:duckhat/models/horario_funcionamento.dart';
import 'package:duckhat/services/duckhat_api.dart';
import 'package:duckhat/utils/image_base64.dart';
import 'package:duckhat/utils/profile_validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:duckhat/theme.dart';
import '../shop_components/shop_ui.dart';

class ShopEstablishmentDataPage extends StatefulWidget {
  const ShopEstablishmentDataPage({super.key});

  @override
  State<ShopEstablishmentDataPage> createState() =>
      _ShopEstablishmentDataPageState();
}

class _ShopEstablishmentDataPageState extends State<ShopEstablishmentDataPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _cnpjController = TextEditingController();
  final _responsavelController = TextEditingController();
  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imagePicker = ImagePicker();

  HorarioFuncionamento _horario = HorarioFuncionamento();
  UsuarioPerfil? _perfil;
  File? _coverImage;
  File? _logoImage;
  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _hydrateFromSession();
    _loadProfile();
  }

  void _hydrateFromSession() {
    final session = DuckHatApi.instance.currentSession;
    if (session == null) return;

    _applyProfile(
      UsuarioPerfil(
        id: session.id,
        nome: session.nome,
        email: session.email,
        telefone: session.telefone,
        cnpj: session.cnpj,
        responsavelNome: session.responsavelNome,
        dataNascimento: session.dataNascimento,
        endereco: session.endereco,
        descricao: session.descricao,
        horarioAtendimento: session.horarioAtendimento,
        bannerImagemBase64: session.bannerImagemBase64,
        tipo: session.tipo,
      ),
    );
  }

  Future<void> _loadProfile() async {
    setState(() {
      _loading = _perfil == null;
      _error = null;
    });

    try {
      final perfil = await DuckHatApi.instance.carregarMeuPerfil();
      if (!mounted) return;
      setState(() {
        _applyProfile(perfil);
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error.toString().replaceFirst('Exception: ', '').trim();
      });
    }
  }

  void _applyProfile(UsuarioPerfil perfil) {
    _perfil = perfil;
    _nameController.text = perfil.nome;
    _phoneController.text = perfil.telefone ?? '';
    _emailController.text = perfil.email;
    _cnpjController.text = perfil.cnpj ?? '';
    _responsavelController.text = perfil.responsavelNome ?? '';
    _addressController.text = perfil.endereco ?? '';
    _descriptionController.text = perfil.descricao ?? '';
    _horario = HorarioFuncionamento.parseFromText(perfil.horarioAtendimento);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _cnpjController.dispose();
    _responsavelController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String? _validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo obrigatório';
    }

    return null;
  }

  String? _validateOptionalLongText(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    if (value.trim().length > 500) {
      return 'O texto deve ter no máximo 500 caracteres';
    }

    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Telefone obrigatório';
    }

    final digits = value.replaceAll(RegExp(r'\D'), '');

    if (digits.length < 10 || digits.length > 11) {
      return 'Telefone inválido';
    }

    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'E-mail obrigatório';
    }

    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

    if (!emailRegex.hasMatch(value.trim())) {
      return 'E-mail inválido';
    }

    return null;
  }

  String? _validateCnpj(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'CNPJ obrigatório';
    }

    final digits = value.replaceAll(RegExp(r'\D'), '');

    if (digits.length != 14) {
      return 'CNPJ inválido';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: buildShopAppBar(
        context,
        title: 'Dados do Estabelecimento',
        actions: [
          TextButton(
            onPressed: _saving || _loading ? null : () => _save(context),
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'Salvar',
                    style: TextStyle(
                      color: AppColors.accent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadProfile,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      if (_error != null) ...[
                        _ErrorBanner(message: _error!),
                        const SizedBox(height: 16),
                      ],
                      _PublicProfilePreview(
                        coverImage: _coverImage,
                        coverImageBase64: _perfil?.bannerImagemBase64,
                        logoImage: _logoImage,
                        name: _nameController.text.trim().isEmpty
                            ? 'Nome do estabelecimento'
                            : _nameController.text.trim(),
                        address: _addressController.text.trim().isEmpty
                            ? 'Endereco do estabelecimento'
                            : _addressController.text.trim(),
                        hours: _horario.toHorarioAtendimento(),
                        description: _descriptionController.text.trim().isEmpty
                            ? 'Descreva a experiencia que o cliente encontra no seu estabelecimento.'
                            : _descriptionController.text.trim(),
                        onPickCover: _saving
                            ? null
                            : () => _pickImage(_EstablishmentImageSlot.cover),
                        onPickLogo: _saving
                            ? null
                            : () => _pickImage(_EstablishmentImageSlot.logo),
                      ),
                      const SizedBox(height: 16),
                      _FormSection(
                        title: 'Perfil publico',
                        subtitle:
                            'Essas informacoes aparecem para o cliente na pagina do estabelecimento.',
                        children: [
                          _buildTextField(
                            'Nome do estabelecimento',
                            _nameController,
                            Icons.storefront_outlined,
                            validator: _validateRequired,
                          ),
                          const SizedBox(height: 14),
                          _buildTextField(
                            'Endereço',
                            _addressController,
                            Icons.location_on_outlined,
                            validator: _validateOptionalLongText,
                          ),
                          const SizedBox(height: 14),
                          _buildHorarioField(),
                          const SizedBox(height: 14),
                          _buildTextField(
                            'Descricao para clientes',
                            _descriptionController,
                            Icons.notes_rounded,
                            maxLines: 4,
                            validator: _validateOptionalLongText,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _FormSection(
                        title: 'Dados legais e contato',
                        subtitle:
                            'Dados usados para gestao da conta e validacao interna.',
                        children: [
                          _buildTextField(
                            'Telefone',
                            _phoneController,
                            Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            validator: _validatePhone,
                          ),
                          const SizedBox(height: 14),
                          _buildTextField(
                            'E-mail',
                            _emailController,
                            Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: _validateEmail,
                          ),
                          const SizedBox(height: 14),
                          _buildTextField(
                            'CNPJ',
                            _cnpjController,
                            Icons.apartment_outlined,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            validator: _validateCnpj,
                          ),
                          const SizedBox(height: 14),
                          _buildTextField(
                            'Responsavel',
                            _responsavelController,
                            Icons.person_pin_outlined,
                            validator: _validateRequired,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: buildShopCardDecoration(radius: 12).boxShadow,
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        validator: validator,
        enabled: !_saving,
        maxLines: maxLines,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.textMuted),
          prefixIcon: Icon(icon, color: AppColors.accent),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: AppColors.cardBackground,
        ),
      ),
    );
  }

  Widget _buildHorarioField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: buildShopCardDecoration(radius: 12).boxShadow,
      ),
      child: ListTile(
        leading: const Icon(Icons.access_time_rounded, color: AppColors.accent),
        title: const Text(
          'Horario de funcionamento',
          style: TextStyle(color: AppColors.textMuted, fontSize: 12),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            _horario.resumo,
            style: const TextStyle(
              color: AppColors.textBold,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: AppColors.accent),
        onTap: _saving ? null : () => _openHorarioEditor(),
      ),
    );
  }

  Future<void> _openHorarioEditor() async {
    final resultado = await showModalBottomSheet<HorarioFuncionamento>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _HorarioEditorSheet(horario: _horario),
    );

    if (resultado != null) {
      setState(() => _horario = resultado);
    }
  }

  Future<void> _pickImage(_EstablishmentImageSlot slot) async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: slot == _EstablishmentImageSlot.cover ? 1800 : 900,
        imageQuality: 86,
      );
      if (image == null || !mounted) return;

      setState(() {
        if (slot == _EstablishmentImageSlot.cover) {
          _coverImage = File(image.path);
        } else {
          _logoImage = File(image.path);
        }
      });
    } on PlatformException catch (error) {
      if (!mounted) return;
      setState(() {
        _error =
            error.message ?? 'Nao foi possivel abrir a galeria do aparelho.';
      });
    }
  }

  Future<void> _save(BuildContext context) async {
    FocusScope.of(context).unfocus();
    final current = _perfil;
    if (current == null || _saving || !_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final bannerBase64 = _coverImage == null
          ? current.bannerImagemBase64
          : await encodeImageFileAsBase64(_coverImage);

      await DuckHatApi.instance.atualizarMeuPerfil(
        UsuarioPerfil(
          id: current.id,
          nome: _nameController.text,
          email: _emailController.text,
          telefone: _phoneController.text,
          cnpj: ProfileValidators.digitsOnly(_cnpjController.text),
          responsavelNome: _responsavelController.text,
          dataNascimento: current.dataNascimento,
          endereco: _addressController.text,
          descricao: _descriptionController.text,
          horarioAtendimento: _horario.toHorarioAtendimento(),
          bannerImagemBase64: bannerBase64,
          tipo: current.tipo,
        ),
      );

      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Dados salvos no banco')));
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString().replaceFirst('Exception: ', '').trim();
      });
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }
}

enum _EstablishmentImageSlot { cover, logo }

class _PublicProfilePreview extends StatelessWidget {
  final File? coverImage;
  final String? coverImageBase64;
  final File? logoImage;
  final String name;
  final String address;
  final String hours;
  final String description;
  final VoidCallback? onPickCover;
  final VoidCallback? onPickLogo;

  const _PublicProfilePreview({
    required this.coverImage,
    required this.coverImageBase64,
    required this.logoImage,
    required this.name,
    required this.address,
    required this.hours,
    required this.description,
    required this.onPickCover,
    required this.onPickLogo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: buildShopCardDecoration(radius: 24),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 210,
            child: Stack(
              fit: StackFit.expand,
              children: [
                _CoverImage(image: coverImage, imageBase64: coverImageBase64),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.08),
                        Colors.black.withValues(alpha: 0.36),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  right: 14,
                  bottom: 14,
                  child: _ImageEditChip(
                    icon: Icons.photo_camera_outlined,
                    label: coverImage == null
                        ? 'Adicionar capa'
                        : 'Trocar capa',
                    onTap: onPickCover,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Transform.translate(
                  offset: const Offset(0, -34),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _LogoPicker(image: logoImage, onTap: onPickLogo),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textBold,
                              fontSize: 20,
                              height: 1.1,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Transform.translate(
                  offset: const Offset(0, -18),
                  child: Column(
                    children: [
                      _PreviewInfoRow(
                        icon: Icons.location_on_outlined,
                        text: address,
                      ),
                      const SizedBox(height: 10),
                      _PreviewInfoRow(
                        icon: Icons.access_time_rounded,
                        text: hours,
                      ),
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFF),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFE6EDFF)),
                        ),
                        child: Text(
                          description,
                          style: const TextStyle(
                            color: AppColors.textRegular,
                            fontSize: 13,
                            height: 1.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CoverImage extends StatelessWidget {
  final File? image;
  final String? imageBase64;

  const _CoverImage({required this.image, required this.imageBase64});

  @override
  Widget build(BuildContext context) {
    if (image != null) {
      return Image.file(image!, fit: BoxFit.cover);
    }
    final savedImage = imageBase64?.trim();
    if (savedImage != null && savedImage.isNotEmpty) {
      return Image.memory(
        base64Decode(savedImage),
        fit: BoxFit.cover,
        gaplessPlayback: true,
      );
    }
    return Image.asset(
      'assets/barbie.jpg',
      fit: BoxFit.cover,
      cacheWidth: 800,
      filterQuality: FilterQuality.medium,
    );
  }
}

class _LogoPicker extends StatelessWidget {
  final File? image;
  final VoidCallback? onTap;

  const _LogoPicker({required this.image, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 92,
              height: 92,
              padding: EdgeInsets.all(image == null ? 8 : 0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.14),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: image == null
                    ? Image.asset('assets/barbielogo.jpg', fit: BoxFit.cover)
                    : Image.file(image!, fit: BoxFit.cover),
              ),
            ),
            Positioned(
              right: -4,
              bottom: -4,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: const Icon(
                  Icons.photo_camera_outlined,
                  color: Colors.white,
                  size: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageEditChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _ImageEditChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.94),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
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
          ),
        ),
      ),
    );
  }
}

class _PreviewInfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _PreviewInfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, size: 16, color: AppColors.accent),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13.5,
              height: 1.45,
              color: AppColors.textRegular,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _FormSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> children;

  const _FormSection({
    required this.title,
    required this.subtitle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: buildShopCardDecoration(radius: 18),
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
          const SizedBox(height: 5),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppColors.textRegular,
              fontSize: 12,
              height: 1.35,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

class _HorarioEditorSheet extends StatefulWidget {
  final HorarioFuncionamento horario;

  const _HorarioEditorSheet({required this.horario});

  @override
  State<_HorarioEditorSheet> createState() => _HorarioEditorSheetState();
}

class _HorarioEditorSheetState extends State<_HorarioEditorSheet> {
  late HorarioFuncionamento _horario;

  @override
  void initState() {
    super.initState();
    _horario = widget.horario;
  }

  String _nomeExibicao(String dia) {
    return {
      'SEGUNDA': 'Seg',
      'TERCA': 'Ter',
      'QUARTA': 'Qua',
      'QUINTA': 'Qui',
      'SEXTA': 'Sex',
      'SABADO': 'Sáb',
      'DOMINGO': 'Dom',
    }[dia] ?? dia;
  }

  Future<void> _selecionarHora(bool isAbertura) async {
    final partes = isAbertura
        ? _horario.horaAbertura.split(':')
        : _horario.horaFechamento.split(':');
    final horaInicial = int.parse(partes[0]);
    final minutoInicial = int.parse(partes[1]);

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: horaInicial, minute: minutoInicial),
    );

    if (picked != null) {
      setState(() {
        final horaFormatada =
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
        if (isAbertura) {
          _horario = _horario.copyWith(horaAbertura: horaFormatada);
        } else {
          _horario = _horario.copyWith(horaFechamento: horaFormatada);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textMuted,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Horário de Funcionamento',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textBold,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, _horario),
                      child: const Text(
                        'Salvar',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Dias da semana',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textRegular,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _horario.dias.entries.map((entry) {
                    return FilterChip(
                      label: Text(_nomeExibicao(entry.key)),
                      selected: entry.value,
                      selectedColor: AppColors.accent.withValues(alpha: 0.2),
                      checkmarkColor: AppColors.accent,
                      onSelected: (selected) {
                        setState(() {
                          final novosDias =
                              Map<String, bool>.from(_horario.dias);
                          novosDias[entry.key] = selected;
                          _horario = _horario.copyWith(dias: novosDias);
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Horário',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textRegular,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _selecionarHora(true),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(_horario.horaAbertura),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('até'),
                    ),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _selecionarHora(false),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(_horario.horaFechamento),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SwitchListTile(
                  title: const Text('24 horas'),
                  subtitle: const Text('Aberto o dia todo'),
                  value: _horario.vinteQuatroHoras,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (value) {
                    setState(() {
                      _horario = _horario.copyWith(vinteQuatroHoras: value);
                      if (value) {
                        _horario = _horario.copyWith(fechado: false);
                      }
                    });
                  },
                ),
                SwitchListTile(
                  title: const Text('Fechado'),
                  subtitle: const Text('Não atende'),
                  value: _horario.fechado,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (value) {
                    setState(() {
                      _horario = _horario.copyWith(fechado: value);
                      if (value) {
                        _horario = _horario.copyWith(vinteQuatroHoras: false);
                      }
                    });
                  },
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Resumo',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _horario.resumo,
                        style: const TextStyle(color: AppColors.textRegular),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
              ],
            ),
          ),
        ],
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
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.error,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

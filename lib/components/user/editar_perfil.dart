import 'dart:convert';
import 'dart:io';

import 'package:duckhat/models/usuario_perfil.dart';
import 'package:duckhat/services/duckhat_api.dart';
import 'package:duckhat/theme.dart' show AppColors, AppThemeColors;
import 'package:duckhat/utils/image_base64.dart';
import 'package:duckhat/utils/profile_validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class EditarPerfilPage extends StatefulWidget {
  const EditarPerfilPage({super.key});

  @override
  State<EditarPerfilPage> createState() => _EditarPerfilPageState();
}

class _EditarPerfilPageState extends State<EditarPerfilPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _cnpjController = TextEditingController();
  final _responsavelController = TextEditingController();
  final _dataNascimentoController = TextEditingController();
  final _enderecoController = TextEditingController();

  UsuarioPerfil? _perfil;
  bool _loading = true;
  bool _saving = false;
  String? _error;
  File? _profileImage;

  bool get _isPrestador => _perfil?.tipo == 'PRESTADOR';

  @override
  void initState() {
    super.initState();
    _hydrateFromSession();
    _loadProfile();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    _cnpjController.dispose();
    _responsavelController.dispose();
    _dataNascimentoController.dispose();
    _enderecoController.dispose();
    super.dispose();
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
        categoria: session.categoria,
        categoriaLabel: session.categoriaLabel,
        descricao: session.descricao,
        horarioAtendimento: session.horarioAtendimento,
        bannerImagemBase64: session.bannerImagemBase64,
        fotoPerfilBase64: session.fotoPerfilBase64,
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
    _nomeController.text = perfil.nome;
    _emailController.text = perfil.email;
    _telefoneController.text = perfil.telefone ?? '';
    _cnpjController.text = perfil.cnpj ?? '';
    _responsavelController.text = perfil.responsavelNome ?? '';
    _dataNascimentoController.text = ProfileValidators.formatDate(
      perfil.dataNascimento,
    );
    _enderecoController.text = perfil.endereco ?? '';
  }

  Future<void> _pickProfileImage() async {
    if (_saving) return;

    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 82,
        maxWidth: 1200,
      );
      if (!mounted || image == null) return;
      setState(() {
        _profileImage = File(image.path);
        _error = null;
      });
    } on PlatformException catch (error) {
      if (!mounted) return;
      setState(() {
        _error =
            error.message ?? 'Não foi possível abrir a galeria do aparelho.';
      });
    }
  }

  Future<void> _save() async {
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
      final fotoPerfilBase64 = _profileImage == null
          ? current.fotoPerfilBase64
          : await encodeImageFileAsBase64(_profileImage);
      if (!mounted) return;

      await DuckHatApi.instance.atualizarMeuPerfil(
        UsuarioPerfil(
          id: current.id,
          nome: _nomeController.text,
          email: _emailController.text,
          telefone: _telefoneController.text,
          cnpj: _isPrestador
              ? ProfileValidators.digitsOnly(_cnpjController.text)
              : null,
          responsavelNome: _isPrestador ? _responsavelController.text : null,
          dataNascimento: ProfileValidators.parseBirthDate(
            _dataNascimentoController.text,
          ),
          endereco: _enderecoController.text,
          categoria: current.categoria,
          categoriaLabel: current.categoriaLabel,
          descricao: current.descricao,
          horarioAtendimento: current.horarioAtendimento,
          bannerImagemBase64: current.bannerImagemBase64,
          fotoPerfilBase64: fotoPerfilBase64,
          tipo: current.tipo,
        ),
      );

      if (!mounted) return;
      setState(() => _profileImage = null);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Perfil salvo no banco')));
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

  @override
  Widget build(BuildContext context) {
    final title = _isPrestador ? 'Editar Estabelecimento' : 'Editar Perfil';

    return Scaffold(
      backgroundColor: AppThemeColors.of(context).background,
      appBar: AppBar(
        backgroundColor: AppThemeColors.of(context).surface,
        elevation: 1,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.accent),
          onPressed: _saving ? null : () => Navigator.pop(context, false),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: AppColors.accent,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saving || _loading ? null : _save,
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
                key: const PageStorageKey('edit-profile-scroll'),
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildAvatar(),
                      const SizedBox(height: 24),
                      if (_error != null) ...[
                        _ErrorBanner(message: _error!),
                        const SizedBox(height: 16),
                      ],
                      _buildTextField(
                        'Nome',
                        _nomeController,
                        Icons.person_outline,
                        validator: ProfileValidators.requiredText,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        'Email',
                        _emailController,
                        Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: ProfileValidators.email,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        'Telefone',
                        _telefoneController,
                        Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        validator: ProfileValidators.phone,
                      ),
                      if (_isPrestador) ...[
                        const SizedBox(height: 16),
                        _buildTextField(
                          'CNPJ',
                          _cnpjController,
                          Icons.apartment_outlined,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: ProfileValidators.cnpj,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          'Responsavel',
                          _responsavelController,
                          Icons.person_pin_outlined,
                          validator: ProfileValidators.requiredText,
                        ),
                      ],
                      const SizedBox(height: 16),
                      _buildTextField(
                        'Data de Nascimento',
                        _dataNascimentoController,
                        Icons.cake_outlined,
                        hint: 'DD/MM/AAAA',
                        keyboardType: TextInputType.datetime,
                        inputFormatters: [_BirthDateInputFormatter()],
                        validator: ProfileValidators.birthDate,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        'Endereço',
                        _enderecoController,
                        Icons.location_on_outlined,
                        validator: ProfileValidators.address,
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildAvatar() {
    final name = _nomeController.text.trim();
    final letter = name.isEmpty ? 'D' : name[0].toUpperCase();
    final savedImage = _perfil?.fotoPerfilBase64?.trim();

    return Center(
      child: Semantics(
        button: true,
        label: 'Alterar foto do perfil',
        child: InkWell(
          onTap: _saving ? null : _pickProfileImage,
          borderRadius: BorderRadius.circular(999),
          child: Stack(
            children: [
              Container(
                width: 108,
                height: 108,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  color: AppColors.accent,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: _profileImage != null
                      ? Image.file(_profileImage!, fit: BoxFit.cover)
                      : _SavedProfileImage(
                          base64Value: savedImage,
                          fallbackLetter: letter,
                        ),
                ),
              ),
              Positioned(
                right: 2,
                bottom: 2,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.accent, width: 1.5),
                  ),
                  child: const Icon(
                    Icons.camera_alt_outlined,
                    size: 17,
                    color: AppColors.accent,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    String? hint,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    final themeColors = AppThemeColors.of(context);

    return Container(
      decoration: BoxDecoration(
        color: themeColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: themeColors.shadow.withValues(
              alpha: themeColors.isDark ? 0.30 : 0.18,
            ),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        validator: validator,
        enabled: !_saving,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: TextStyle(color: themeColors.mutedText),
          hintStyle: TextStyle(
            color: themeColors.mutedText.withValues(alpha: 0.7),
          ),
          prefixIcon: Icon(icon, color: themeColors.accent),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: themeColors.surface,
        ),
      ),
    );
  }
}

class _SavedProfileImage extends StatelessWidget {
  final String? base64Value;
  final String fallbackLetter;

  const _SavedProfileImage({
    required this.base64Value,
    required this.fallbackLetter,
  });

  @override
  Widget build(BuildContext context) {
    final value = base64Value;
    if (value != null && value.isNotEmpty) {
      try {
        return Image.memory(base64Decode(value), fit: BoxFit.cover);
      } on FormatException {
        return _ProfileInitials(fallbackLetter: fallbackLetter);
      }
    }

    return _ProfileInitials(fallbackLetter: fallbackLetter);
  }
}

class _ProfileInitials extends StatelessWidget {
  final String fallbackLetter;

  const _ProfileInitials({required this.fallbackLetter});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.accent,
      child: Center(
        child: Text(
          fallbackLetter,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 40,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _BirthDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final formatted = ProfileValidators.formatBirthDateInput(newValue.text);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
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

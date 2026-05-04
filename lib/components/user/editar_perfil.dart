import 'package:duckhat/models/usuario_perfil.dart';
import 'package:duckhat/services/duckhat_api.dart';
import 'package:duckhat/theme.dart' show AppColors;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    _dataNascimentoController.text = _formatDate(perfil.dataNascimento);
    _enderecoController.text = perfil.endereco ?? '';
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
      await DuckHatApi.instance.atualizarMeuPerfil(
        UsuarioPerfil(
          id: current.id,
          nome: _nomeController.text,
          email: _emailController.text,
          telefone: _telefoneController.text,
          cnpj: _isPrestador ? _digitsOnly(_cnpjController.text) : null,
          responsavelNome: _isPrestador ? _responsavelController.text : null,
          dataNascimento: _parseDate(_dataNascimentoController.text),
          endereco: _enderecoController.text,
          tipo: current.tipo,
        ),
      );

      if (!mounted) return;
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
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
                        validator: _validateRequired,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        'Email',
                        _emailController,
                        Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: _validateEmail,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        'Telefone',
                        _telefoneController,
                        Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        validator: _validatePhone,
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
                          validator: _validateCnpj,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          'Responsavel',
                          _responsavelController,
                          Icons.person_pin_outlined,
                          validator: _validateRequired,
                        ),
                      ],
                      const SizedBox(height: 16),
                      _buildTextField(
                        'Data de Nascimento',
                        _dataNascimentoController,
                        Icons.cake_outlined,
                        hint: 'AAAA-MM-DD',
                        keyboardType: TextInputType.datetime,
                        validator: _validateDate,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        'Endereco',
                        _enderecoController,
                        Icons.location_on_outlined,
                        validator: _validateOptionalLongText,
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

    return Center(
      child: Stack(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              color: AppColors.accent,
            ),
            child: Center(
              child: Text(
                letter,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Positioned(
            right: 2,
            bottom: 2,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.accent, width: 1.5),
              ),
              child: const Icon(
                Icons.camera_alt_outlined,
                size: 16,
                color: AppColors.accent,
              ),
            ),
          ),
        ],
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
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
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
          labelStyle: const TextStyle(color: AppColors.textMuted),
          hintStyle: TextStyle(
            color: AppColors.textMuted.withValues(alpha: 0.5),
          ),
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
    final digits = _digitsOnly(value ?? '');
    if (digits.isEmpty) return null;
    if (digits.length < 10) return 'Informe um telefone valido.';
    return null;
  }

  String? _validateCnpj(String? value) {
    final digits = _digitsOnly(value ?? '');
    if (digits.length != 14) return 'Informe um CNPJ com 14 digitos.';
    return null;
  }

  String? _validateDate(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    if (_parseDate(text) == null) return 'Use uma data valida em AAAA-MM-DD.';
    return null;
  }

  String? _validateOptionalLongText(String? value) {
    final text = value?.trim() ?? '';
    if (text.length > 255) return 'Use ate 255 caracteres.';
    return null;
  }

  DateTime? _parseDate(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;

    final iso = DateTime.tryParse(trimmed);
    if (iso != null) return DateTime(iso.year, iso.month, iso.day);

    final match = RegExp(r'^(\d{2})/(\d{2})/(\d{4})$').firstMatch(trimmed);
    if (match == null) return null;

    final day = int.parse(match.group(1)!);
    final month = int.parse(match.group(2)!);
    final year = int.parse(match.group(3)!);
    final parsed = DateTime(year, month, day);
    if (parsed.day != day || parsed.month != month || parsed.year != year) {
      return null;
    }
    return parsed;
  }

  String _formatDate(DateTime? value) {
    if (value == null) return '';
    final year = value.year.toString().padLeft(4, '0');
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  String _digitsOnly(String value) => value.replaceAll(RegExp(r'\D'), '');
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

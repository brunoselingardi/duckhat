import 'package:duckhat/models/usuario_perfil.dart';
import 'package:duckhat/services/duckhat_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  UsuarioPerfil? _perfil;
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
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _cnpjController.dispose();
    _responsavelController.dispose();
    _addressController.dispose();
    super.dispose();
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
                      _buildTextField(
                        'Nome do Estabelecimento',
                        _nameController,
                        Icons.store,
                        validator: _validateRequired,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        'Telefone',
                        _phoneController,
                        Icons.phone,
                        keyboardType: TextInputType.phone,
                        validator: _validatePhone,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        'E-mail',
                        _emailController,
                        Icons.email,
                        keyboardType: TextInputType.emailAddress,
                        validator: _validateEmail,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        'CNPJ',
                        _cnpjController,
                        Icons.apartment,
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
                        Icons.person_pin,
                        validator: _validateRequired,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        'Endereço',
                        _addressController,
                        Icons.location_on,
                        validator: _validateOptionalLongText,
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
      await DuckHatApi.instance.atualizarMeuPerfil(
        UsuarioPerfil(
          id: current.id,
          nome: _nameController.text,
          email: _emailController.text,
          telefone: _phoneController.text,
          cnpj: _digitsOnly(_cnpjController.text),
          responsavelNome: _responsavelController.text,
          dataNascimento: current.dataNascimento,
          endereco: _addressController.text,
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

  String? _validateRequired(String? value) {
    if ((value ?? '').trim().isEmpty) return 'Preencha este campo.';
    return null;
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Informe o e-mail.';
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

  String? _validateOptionalLongText(String? value) {
    final text = value?.trim() ?? '';
    if (text.length > 255) return 'Use ate 255 caracteres.';
    return null;
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

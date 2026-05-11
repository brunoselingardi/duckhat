import 'package:duckhat/models/servico_catalogo.dart';
import 'package:duckhat/services/duckhat_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:duckhat/theme.dart';
import '../shop_components/shop_ui.dart';

class ShopServiceDurationPage extends StatefulWidget {
  const ShopServiceDurationPage({super.key});

  @override
  State<ShopServiceDurationPage> createState() =>
      _ShopServiceDurationPageState();
}

class _ShopServiceDurationPageState extends State<ShopServiceDurationPage> {
  final _formKey = GlobalKey<FormState>();
  final DuckHatApi _api = DuckHatApi.instance;
  List<_EditableShopService> _services = [];
  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  @override
  void dispose() {
    for (final service in _services) {
      service.dispose();
    }
    super.dispose();
  }

  Future<void> _loadServices() async {
    setState(() {
      _loading = _services.isEmpty;
      _error = null;
    });

    try {
      final loaded = await _api.listarMeusServicos();
      if (!mounted) return;
      setState(() {
        for (final service in _services) {
          service.dispose();
        }
        _services = loaded.map(_EditableShopService.fromCatalog).toList();
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

  void _addService() {
    setState(() => _services.add(_EditableShopService.empty()));
  }

  void _removeNewService(int index) {
    if (index < 0 || index >= _services.length) return;
    final service = _services[index];
    if (!service.isNew) return;
    setState(() => _services.removeAt(index).dispose());
  }

  Future<void> _save(BuildContext context) async {
    FocusScope.of(context).unfocus();
    if (_saving || !_formKey.currentState!.validate()) return;

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final saved = <ServicoCatalogo>[];
      for (final service in _services) {
        final price = service.priceValue!;
        if (service.isNew) {
          saved.add(
            await _api.criarServico(
              nome: service.nameController.text,
              descricao: service.descriptionController.text,
              duracaoMin: service.durationMin,
              preco: price,
              ativo: service.active,
            ),
          );
        } else {
          saved.add(
            await _api.atualizarServico(
              id: service.id!,
              nome: service.nameController.text,
              descricao: service.descriptionController.text,
              duracaoMin: service.durationMin,
              preco: price,
              ativo: service.active,
            ),
          );
        }
      }

      if (!context.mounted) return;
      setState(() {
        for (final service in _services) {
          service.dispose();
        }
        _services = saved.map(_EditableShopService.fromCatalog).toList();
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Serviços salvos')));
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString().replaceFirst('Exception: ', '').trim();
      });
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: buildShopAppBar(
        context,
        title: 'Serviços e Preços',
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
              onRefresh: _loadServices,
              child: Form(
                key: _formKey,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (_error != null) ...[
                      _ServiceErrorBanner(message: _error!),
                      const SizedBox(height: 14),
                    ],
                    _ServiceIntroCard(total: _services.length),
                    const SizedBox(height: 16),
                    if (_services.isEmpty)
                      _EmptyServicesCard(onAdd: _addService)
                    else
                      ...List.generate(
                        _services.length,
                        (index) => _ServiceEditorCard(
                          service: _services[index],
                          index: index,
                          onChanged: () => setState(() {}),
                          onRemoveNew: _services[index].isNew
                              ? () => _removeNewService(index)
                              : null,
                        ),
                      ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: _saving ? null : _addService,
                      icon: const Icon(Icons.add),
                      label: const Text('Adicionar serviço'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.accent,
                        padding: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),
    );
  }
}

class _EditableShopService {
  final int? id;
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final TextEditingController priceController;
  int durationMin;
  bool active;

  _EditableShopService({
    required this.id,
    required this.nameController,
    required this.descriptionController,
    required this.priceController,
    required this.durationMin,
    required this.active,
  });

  factory _EditableShopService.fromCatalog(ServicoCatalogo service) {
    return _EditableShopService(
      id: service.id,
      nameController: TextEditingController(text: service.nome),
      descriptionController: TextEditingController(
        text: service.descricao ?? '',
      ),
      priceController: TextEditingController(text: _formatPrice(service.preco)),
      durationMin: service.duracaoMin,
      active: service.ativo,
    );
  }

  factory _EditableShopService.empty() {
    return _EditableShopService(
      id: null,
      nameController: TextEditingController(),
      descriptionController: TextEditingController(),
      priceController: TextEditingController(),
      durationMin: 30,
      active: true,
    );
  }

  bool get isNew => id == null;

  double? get priceValue => _parsePrice(priceController.text);

  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
  }
}

class _ServiceIntroCard extends StatelessWidget {
  final int total;

  const _ServiceIntroCard({required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: buildShopCardDecoration(radius: 18),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.design_services_outlined,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Vitrine de serviços',
                  style: TextStyle(
                    color: AppColors.textBold,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  total == 0
                      ? 'Adicione o primeiro serviço com descrição e preço.'
                      : '$total serviços cadastrados para este estabelecimento.',
                  style: const TextStyle(
                    color: AppColors.textRegular,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
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

class _ServiceEditorCard extends StatelessWidget {
  final _EditableShopService service;
  final int index;
  final VoidCallback onChanged;
  final VoidCallback? onRemoveNew;

  const _ServiceEditorCard({
    required this.service,
    required this.index,
    required this.onChanged,
    required this.onRemoveNew,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        boxShadow: buildShopCardDecoration(radius: 14).boxShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  service.isNew ? 'Novo serviço' : 'Serviço ${index + 1}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textBold,
                  ),
                ),
              ),
              if (onRemoveNew != null)
                IconButton(
                  onPressed: onRemoveNew,
                  icon: const Icon(Icons.delete_outline),
                  color: AppColors.error,
                  tooltip: 'Remover serviço',
                )
              else
                Switch(
                  value: service.active,
                  onChanged: (value) {
                    service.active = value;
                    onChanged();
                  },
                  activeThumbColor: AppColors.accent,
                ),
            ],
          ),
          const SizedBox(height: 12),
          _ServiceTextField(
            controller: service.nameController,
            label: 'Nome do serviço',
            icon: Icons.design_services_outlined,
            validator: _validateServiceName,
          ),
          const SizedBox(height: 12),
          _ServiceTextField(
            controller: service.descriptionController,
            label: 'Descrição',
            icon: Icons.notes_rounded,
            maxLines: 3,
            validator: _validateServiceDescription,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _DurationControl(
                  duration: service.durationMin,
                  onChanged: (value) {
                    service.durationMin = value;
                    onChanged();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ServiceTextField(
                  controller: service.priceController,
                  label: 'Preço',
                  icon: Icons.payments_outlined,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d,.]')),
                    LengthLimitingTextInputFormatter(9),
                  ],
                  validator: _validatePrice,
                ),
              ),
            ],
          ),
          if (!service.active) ...[
            const SizedBox(height: 12),
            const Text(
              'Serviço pausado: ele não aparece para clientes no catálogo.',
              style: TextStyle(
                color: AppColors.textRegular,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ServiceTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final int maxLines;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?) validator;

  const _ServiceTextField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.validator,
    this.maxLines = 1,
    this.keyboardType,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textMuted),
        prefixIcon: Icon(icon, color: AppColors.accent),
        filled: true,
        fillColor: AppColors.inputBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _DurationControl extends StatelessWidget {
  final int duration;
  final ValueChanged<int> onChanged;

  const _DurationControl({required this.duration, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: duration <= 10 ? null : () => onChanged(duration - 5),
            icon: const Icon(Icons.remove_circle_outline),
            color: AppColors.accent,
            tooltip: 'Reduzir duração',
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$duration min',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const Text(
                  'Duração',
                  style: TextStyle(fontSize: 10, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: duration >= 240 ? null : () => onChanged(duration + 5),
            icon: const Icon(Icons.add_circle_outline),
            color: AppColors.accent,
            tooltip: 'Aumentar duração',
          ),
        ],
      ),
    );
  }
}

class _EmptyServicesCard extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyServicesCard({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: buildShopCardDecoration(radius: 18),
      child: Column(
        children: [
          const Icon(
            Icons.add_business_outlined,
            color: AppColors.accent,
            size: 34,
          ),
          const SizedBox(height: 10),
          const Text(
            'Nenhum serviço cadastrado',
            style: TextStyle(
              color: AppColors.textBold,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Cadastre pelo menos um serviço para iniciar a vitrine.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textRegular,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('Adicionar serviço'),
          ),
        ],
      ),
    );
  }
}

class _ServiceErrorBanner extends StatelessWidget {
  final String message;

  const _ServiceErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.34)),
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

String _formatPrice(double value) =>
    value.toStringAsFixed(2).replaceAll('.', ',');

String? _validateServiceName(String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return 'Informe o nome do serviço.';
  if (text.length > 120) return 'Use até 120 caracteres.';
  return null;
}

String? _validateServiceDescription(String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return 'Informe a descrição.';
  if (text.length > 1000) return 'Use até 1000 caracteres.';
  return null;
}

String? _validatePrice(String? value) {
  final price = _parsePrice(value ?? '');
  if (price == null) return 'Preço inválido.';
  if (price <= 0) return 'Use um preço maior que zero.';
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

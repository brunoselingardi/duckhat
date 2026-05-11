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
  final _scrollController = ScrollController();
  final DuckHatApi _api = DuckHatApi.instance;
  List<_EditableShopService> _services = [];
  bool _loading = true;
  bool _saving = false;
  String? _error;

  int get _activeServices =>
      _services.where((service) => service.active).length;

  int get _pausedServices => _services.length - _activeServices;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  @override
  void dispose() {
    _scrollController.dispose();
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    });
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
      bottomNavigationBar: _loading
          ? null
          : _ServiceSaveBar(saving: _saving, onSave: () => _save(context)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadServices,
              child: Form(
                key: _formKey,
                child: ListView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (_error != null) ...[
                      _ServiceErrorBanner(message: _error!),
                      const SizedBox(height: 14),
                    ],
                    _ServicePanelCard(
                      total: _services.length,
                      active: _activeServices,
                      paused: _pausedServices,
                      onAdd: _addService,
                    ),
                    const SizedBox(height: 18),
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
                    const SizedBox(height: 96),
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

  String get title {
    final text = nameController.text.trim();
    return text.isEmpty ? 'Novo serviço' : text;
  }

  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
  }
}

class _ServicePanelCard extends StatelessWidget {
  final int total;
  final int active;
  final int paused;
  final VoidCallback onAdd;

  const _ServicePanelCard({
    required this.total,
    required this.active,
    required this.paused,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: buildShopCardDecoration(radius: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.dashboard_customize_outlined,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Painel da vitrine',
                      style: TextStyle(
                        color: AppColors.textBold,
                        fontSize: 17,
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
              FilledButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Adicionar'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _ServiceMetric(
                  label: 'Total',
                  value: total.toString(),
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ServiceMetric(
                  label: 'Serviços ativos',
                  value: active.toString(),
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ServiceMetric(
                  label: 'Serviços pausados',
                  value: paused.toString(),
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ServiceMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _ServiceMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textBold,
                fontSize: 11,
                height: 1.15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceStatusBadge extends StatelessWidget {
  final bool active;

  const _ServiceStatusBadge({required this.active});

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.success : AppColors.warning;
    final label = active ? 'Ativo na vitrine' : 'Pausado';
    final icon = active ? Icons.visibility_outlined : Icons.visibility_off;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textBold,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceCardHeader extends StatelessWidget {
  final String title;
  final bool active;
  final bool isNew;
  final Widget trailing;

  const _ServiceCardHeader({
    required this.title,
    required this.active,
    required this.isNew,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.1),
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
                isNew ? 'Novo serviço' : 'Serviço publicado',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textBold,
                ),
              ),
              const SizedBox(height: 6),
              _ServiceStatusBadge(active: active),
            ],
          ),
        ),
        trailing,
      ],
    );
  }
}

class _ServiceFieldGroupLabel extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ServiceFieldGroupLabel({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.accent, size: 17),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textBold,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: service.active
              ? AppColors.border
              : AppColors.warning.withValues(alpha: 0.35),
        ),
        boxShadow: buildShopCardDecoration(radius: 18).boxShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ServiceCardHeader(
            title: service.title,
            active: service.active,
            isNew: service.isNew,
            trailing: onRemoveNew != null
                ? IconButton(
                    onPressed: onRemoveNew,
                    icon: const Icon(Icons.delete_outline),
                    color: AppColors.error,
                    tooltip: 'Remover serviço',
                  )
                : Switch(
                    value: service.active,
                    onChanged: (value) {
                      service.active = value;
                      onChanged();
                    },
                    activeThumbColor: AppColors.accent,
                  ),
          ),
          const SizedBox(height: 18),
          const _ServiceFieldGroupLabel(
            icon: Icons.description_outlined,
            label: 'Informações do serviço',
          ),
          const SizedBox(height: 12),
          _ServiceSectionShell(
            child: Column(
              children: [
                _ServiceTextField(
                  controller: service.nameController,
                  label: 'Nome do serviço',
                  icon: Icons.design_services_outlined,
                  validator: _validateServiceName,
                  onChanged: (_) => onChanged(),
                ),
                const SizedBox(height: 12),
                _ServiceTextField(
                  controller: service.descriptionController,
                  label: 'Descrição',
                  icon: Icons.notes_rounded,
                  maxLines: 3,
                  validator: _validateServiceDescription,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const _ServiceFieldGroupLabel(
            icon: Icons.tune_rounded,
            label: 'Agenda e preço',
          ),
          const SizedBox(height: 12),
          _ServiceSectionShell(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final duration = _DurationControl(
                  duration: service.durationMin,
                  onChanged: (value) {
                    service.durationMin = value;
                    onChanged();
                  },
                );
                final price = _ServiceTextField(
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
                );

                if (constraints.maxWidth < 330) {
                  return Column(
                    children: [duration, const SizedBox(height: 12), price],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: duration),
                    const SizedBox(width: 12),
                    Expanded(child: price),
                  ],
                );
              },
            ),
          ),
          if (!service.active) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text(
                'Serviço pausado: ele não aparece para clientes no catálogo.',
                style: TextStyle(
                  color: AppColors.textRegular,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ServiceSectionShell extends StatelessWidget {
  final Widget child;

  const _ServiceSectionShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.55)),
      ),
      child: child,
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
  final ValueChanged<String>? onChanged;

  const _ServiceTextField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.validator,
    this.maxLines = 1,
    this.keyboardType,
    this.inputFormatters,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      validator: validator,
      style: const TextStyle(
        color: AppColors.textBold,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textMuted),
        prefixIcon: Icon(icon, color: AppColors.accent),
        filled: true,
        fillColor: AppColors.cardBackground,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.6),
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
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
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
      padding: const EdgeInsets.all(22),
      decoration: buildShopCardDecoration(radius: 20),
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.11),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.add_business_outlined,
              color: AppColors.accent,
              size: 30,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Nenhum serviço cadastrado',
            style: TextStyle(
              color: AppColors.textBold,
              fontSize: 16,
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
            label: const Text('Criar primeiro serviço'),
          ),
        ],
      ),
    );
  }
}

class _ServiceSaveBar extends StatelessWidget {
  final bool saving;
  final VoidCallback onSave;

  const _ServiceSaveBar({required this.saving, required this.onSave});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: const BoxDecoration(
          color: AppColors.cardBackground,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: FilledButton.icon(
          onPressed: saving ? null : onSave,
          icon: saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.check_rounded),
          label: Text(saving ? 'Salvando' : 'Salvar alterações'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
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

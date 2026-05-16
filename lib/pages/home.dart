import 'package:duckhat/components/home/appointment.dart';
import 'package:duckhat/components/home/header.dart';
import 'package:duckhat/components/home/rebook.dart';
import 'package:duckhat/core/app_route.dart';
import 'package:duckhat/models/agendamento.dart';
import 'package:duckhat/pages/appointment_detail.dart';
import 'package:duckhat/pages/search.dart';
import 'package:duckhat/services/duckhat_api.dart';
import 'package:duckhat/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _api = DuckHatApi.instance;

  bool _loading = true;
  String? _error;
  List<Agendamento> _agendamentos = const [];
  int _lastSyncRevision = 0;

  @override
  void initState() {
    super.initState();
    _lastSyncRevision = _api.agendamentoSync.value.revision;
    _api.agendamentoSync.addListener(_handleAgendamentoSync);
    _loadHomeData();
  }

  @override
  void dispose() {
    _api.agendamentoSync.removeListener(_handleAgendamentoSync);
    super.dispose();
  }

  Future<void> _loadHomeData({bool showLoader = true}) async {
    if (showLoader) {
      setState(() {
        _loading = true;
        _error = null;
      });
    } else {
      setState(() => _error = null);
    }

    try {
      final items = await _api.listarAgendamentos()
        ..sort((a, b) => a.inicioEm.compareTo(b.inicioEm));

      if (!mounted) return;
      setState(() {
        _agendamentos = items;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString().replaceFirst('Exception: ', '').trim();
        _loading = false;
      });
    }
  }

  void _handleAgendamentoSync() {
    final signal = _api.agendamentoSync.value;
    if (signal.revision == _lastSyncRevision || !mounted) return;
    _lastSyncRevision = signal.revision;
    _loadHomeData(showLoader: false);
  }

  List<Map<String, dynamic>> get _todayAppointments {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final items = _agendamentos.where((item) {
      final itemDay = DateTime(
        item.inicioEm.year,
        item.inicioEm.month,
        item.inicioEm.day,
      );
      return itemDay == today && item.status != 'CANCELADO';
    }).toList()..sort((a, b) => a.inicioEm.compareTo(b.inicioEm));

    return items
        .map(
          (item) => {
            'id': item.id,
            'time': _formatTime(item.inicioEm),
            'service': item.servicoNome ?? 'Serviço #${item.servicoId}',
            'place': item.prestadorNome ?? 'Prestador #${item.prestadorId}',
            'image': _imageForAppointment(item),
            'profileImageBase64': item.prestadorFotoPerfilBase64,
            'agendamento': item,
          },
        )
        .toList();
  }

  List<Map<String, dynamic>> get _favoriteServices {
    return const [];
  }

  String _imageForAppointment(Agendamento item) {
    final source = '${item.prestadorNome ?? ''} ${item.servicoNome ?? ''}'
        .toLowerCase();

    if (source.contains('barbie')) return 'assets/barbiesalon.jpg';
    if (source.contains('james')) return 'assets/jamessalon.jpg';
    if (source.contains('barba') || source.contains('corte')) {
      return 'assets/mariano.jpg';
    }
    if (source.contains('manicure') || source.contains('unha')) {
      return 'assets/salao.jpg';
    }
    return 'assets/logologo.png';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _openAppointmentDetail(Map appointment) async {
    final item = appointment['agendamento'] as Agendamento?;
    if (item == null) return;

    await Navigator.of(context).push<bool>(
      AppRoute(
        builder: (_) => AppointmentDetailPage(
          agendamento: item,
          onCancel: item.podeCancelar
              ? (agendamento) => _api.cancelarAgendamento(agendamento.id)
              : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final username = _api.currentSession?.nome;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: _loadHomeData,
            color: AppColors.accent,
            child: ListView(
              key: const PageStorageKey('home-scroll'),
              cacheExtent: 500,
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                HomeHeader(username: username),
                const SizedBox(height: 10),
                const _SearchShortcut(),
                const SizedBox(height: 20),
                const _PromoBanner(),
                const SizedBox(height: 20),
                if (_loading)
                  const _HomeLoadingState()
                else if (_error != null)
                  _HomeErrorState(message: _error!, onRetry: _loadHomeData)
                else ...[
                  RebookSection(
                    rebookServices: _favoriteServices,
                    title: 'Seus favoritos:',
                    emptyMessage: 'Seus favoritos salvos aparecerão aqui.',
                  ),
                  const SizedBox(height: 20),
                  AppointmentSection(
                    appointments: _todayAppointments,
                    onAppointmentTap: _openAppointmentDetail,
                  ),
                ],
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchShortcut extends StatelessWidget {
  const _SearchShortcut();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        onTap: () {
          Navigator.of(
            context,
          ).push(AppRoute(builder: (_) => const SearchPage()));
        },
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
            boxShadow: const [
              BoxShadow(
                color: AppColors.cardShadow,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: const Row(
            children: [
              Icon(Icons.search, color: AppColors.accent),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Buscar salões, barbearias e serviços',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textRegular,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.tune, color: AppColors.accent),
            ],
          ),
        ),
      ),
    );
  }
}

class _PromoBanner extends StatelessWidget {
  const _PromoBanner();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        onTap: () {
          Navigator.of(
            context,
          ).push(AppRoute(builder: (_) => const SearchPage()));
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.secondary, AppColors.accent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadowAccent,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Encontre os\nmelhores serviços",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Pesquise por categoria, bairro ou CEP.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(35),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(35),
                  child: Image.asset("assets/logologo.png", fit: BoxFit.cover),
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeLoadingState extends StatelessWidget {
  const _HomeLoadingState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 40),
      child: Center(child: CircularProgressIndicator(color: AppColors.accent)),
    );
  }
}

class _HomeErrorState extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _HomeErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 26),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textBold,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => onRetry(),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
              ),
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:duckhat/core/app_route.dart';
import 'package:duckhat/theme.dart';
import 'package:flutter/material.dart';

import 'search.dart';

class PromotionsPage extends StatefulWidget {
  const PromotionsPage({super.key});

  @override
  State<PromotionsPage> createState() => _PromotionsPageState();
}

class _PromotionsPageState extends State<PromotionsPage> {
  static const _filters = [
    _PromoFilter('Todos', null),
    _PromoFilter('Cabelo', 'cabelo'),
    _PromoFilter('Barba', 'barba'),
    _PromoFilter('Unhas', 'unhas'),
    _PromoFilter('Pacotes', 'pacote'),
  ];

  static const _deals = [
    _PromoDeal(
      title: 'Corte + hidratação premium',
      place: 'Sugestão de busca DuckHat',
      image: 'assets/barbiesalon.jpg',
      discountLabel: 'Cabelo',
      category: 'cabelo',
      badge: 'Curadoria local',
      description:
          'Use como ponto de partida para encontrar salões e barbearias cadastrados ou próximos.',
      priceText: 'Consulte valores',
      originalPriceText: '',
      expiryText: 'Busque horários reais',
      highlight: true,
    ),
    _PromoDeal(
      title: 'Barba desenhada + toalha quente',
      place: 'Sugestão de busca DuckHat',
      image: 'assets/jamessalon.jpg',
      discountLabel: 'Barba',
      category: 'barba',
      badge: 'Serviços próximos',
      description:
          'Pesquise profissionais para alinhar barba, contorno e acabamento.',
      priceText: 'Consulte valores',
      originalPriceText: '',
      expiryText: 'Consulte disponibilidade',
    ),
    _PromoDeal(
      title: 'Mãos e pés com esmaltação',
      place: 'Sugestão de busca DuckHat',
      image: 'assets/salao.jpg',
      discountLabel: 'Unhas',
      category: 'unhas',
      badge: 'Busca guiada',
      description:
          'Encontre atendimento de manicure e pedicure por termo ou localização.',
      priceText: 'Consulte valores',
      originalPriceText: '',
      expiryText: 'Veja opções reais',
    ),
    _PromoDeal(
      title: 'Dia do noivo completo',
      place: 'Sugestão de busca DuckHat',
      image: 'assets/niceduck.jpg',
      discountLabel: 'Pacotes',
      category: 'pacote',
      badge: 'Planejamento',
      description:
          'Pesquise serviços combinados para eventos e confirme detalhes com o estabelecimento.',
      priceText: 'Consulte valores',
      originalPriceText: '',
      expiryText: 'Confirme no agendamento',
    ),
  ];

  int _selectedFilterIndex = 0;

  List<_PromoDeal> get _visibleDeals {
    final category = _filters[_selectedFilterIndex].category;
    if (category == null) return _deals;
    return _deals.where((deal) => deal.category == category).toList();
  }

  _PromoDeal get _featuredDeal {
    final visible = _visibleDeals;
    return visible.firstWhere(
      (deal) => deal.highlight,
      orElse: () => visible.first,
    );
  }

  List<_PromoDeal> get _expiringDeals {
    return _visibleDeals.where((deal) => !deal.highlight).take(2).toList();
  }

  void _openFeaturedDeal() {
    Navigator.of(context).push(AppRoute(builder: (_) => const SearchPage()));
  }

  void _openAllServices() {
    Navigator.of(context).push(AppRoute(builder: (_) => const SearchPage()));
  }

  @override
  Widget build(BuildContext context) {
    final visibleDeals = _visibleDeals;
    final featuredDeal = _featuredDeal;
    final expiringDeals = _expiringDeals;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          key: const PageStorageKey('promotions-scroll'),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _PromoHeader(onBack: () => Navigator.of(context).pop()),
                    const SizedBox(height: 20),
                    _PromoHero(
                      deal: featuredDeal,
                      onPrimaryTap: _openFeaturedDeal,
                      onSecondaryTap: _openAllServices,
                    ),
                    const SizedBox(height: 18),
                    _FilterChips(
                      filters: _filters,
                      selectedIndex: _selectedFilterIndex,
                      onSelected: (index) {
                        setState(() => _selectedFilterIndex = index);
                      },
                    ),
                    const SizedBox(height: 18),
                    const _PromoInsightRow(),
                    const SizedBox(height: 22),
                    _SectionHeader(
                      title: 'Sugestões em destaque',
                      subtitle:
                          'Atalhos para buscar serviços por categoria e encontrar horários reais.',
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              sliver: SliverList.builder(
                itemCount: visibleDeals.length,
                itemBuilder: (context, index) {
                  final deal = visibleDeals[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _PromoCard(deal: deal, onTap: _openFeaturedDeal),
                  );
                },
              ),
            ),
            if (expiringDeals.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
                  child: _SectionHeader(
                    title: 'Vencendo em breve',
                    subtitle:
                        'Caminhos rápidos para comparar opções antes de agendar.',
                  ),
                ),
              ),
            if (expiringDeals.isNotEmpty)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
                sliver: SliverList.builder(
                  itemCount: expiringDeals.length,
                  itemBuilder: (context, index) {
                    final deal = expiringDeals[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _ExpiryTile(deal: deal, onTap: _openFeaturedDeal),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PromoHeader extends StatelessWidget {
  final VoidCallback onBack;

  const _PromoHeader({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: onBack,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: AppColors.textBold,
            ),
          ),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Promoções',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textBold,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Descontos ativos para salão, barba e cuidados pessoais.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textRegular,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PromoHero extends StatelessWidget {
  final _PromoDeal deal;
  final VoidCallback onPrimaryTap;
  final VoidCallback onSecondaryTap;

  const _PromoHero({
    required this.deal,
    required this.onPrimaryTap,
    required this.onSecondaryTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.secondary, AppColors.accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowAccent,
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  deal.badge,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                deal.discountLabel,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      deal.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      deal.description,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.88),
                        fontSize: 13,
                        height: 1.35,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      deal.originalPriceText.isEmpty
                          ? deal.priceText
                          : '${deal.priceText}  •  antes ${deal.originalPriceText}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Image.asset(
                  deal.image,
                  width: 88,
                  height: 112,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: onPrimaryTap,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.accent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Buscar serviços',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton(
                onPressed: onSecondaryTap,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.55)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                child: const Text('Explorar'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  final List<_PromoFilter> filters;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const _FilterChips({
    required this.filters,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final selected = index == selectedIndex;

          return InkWell(
            onTap: () => onSelected(index),
            borderRadius: BorderRadius.circular(999),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: selected ? AppColors.secondary : Colors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: selected
                      ? AppColors.secondary
                      : AppColors.border.withValues(alpha: 0.7),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                filter.label,
                style: TextStyle(
                  color: selected ? Colors.white : AppColors.textBold,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PromoInsightRow extends StatelessWidget {
  const _PromoInsightRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: _InsightCard(
            title: 'Curadoria',
            subtitle: 'por categoria',
            icon: Icons.local_offer_outlined,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _InsightCard(
            title: 'Catálogo',
            subtitle: 'interno e externo',
            icon: Icons.bolt_rounded,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _InsightCard(
            title: 'Reserva rápida',
            subtitle: 'em poucos toques',
            icon: Icons.schedule_rounded,
          ),
        ),
      ],
    );
  }
}

class _InsightCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _InsightCard({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.65)),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.accent, size: 18),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textBold,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppColors.textRegular,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textBold,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            color: AppColors.textRegular,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _PromoCard extends StatelessWidget {
  final _PromoDeal deal;
  final VoidCallback onTap;

  const _PromoCard({required this.deal, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
          boxShadow: const [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 14,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              child: Image.asset(
                deal.image,
                width: double.infinity,
                height: 172,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          deal.discountLabel,
                          style: const TextStyle(
                            color: AppColors.accent,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        deal.expiryText,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    deal.title,
                    style: const TextStyle(
                      color: AppColors.textBold,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    deal.place,
                    style: const TextStyle(
                      color: AppColors.secondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    deal.description,
                    style: const TextStyle(
                      color: AppColors.textRegular,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          deal.priceText,
                          style: const TextStyle(
                            color: AppColors.textBold,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (deal.originalPriceText.isNotEmpty) ...[
                        Text(
                          deal.originalPriceText,
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      const Spacer(),
                      const Text(
                        'Ver busca',
                        style: TextStyle(
                          color: AppColors.accent,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpiryTile extends StatelessWidget {
  final _PromoDeal deal;
  final VoidCallback onTap;

  const _ExpiryTile({required this.deal, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.asset(
                deal.image,
                width: 66,
                height: 66,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    deal.title,
                    style: const TextStyle(
                      color: AppColors.textBold,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    deal.expiryText,
                    style: const TextStyle(
                      color: AppColors.warning,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${deal.priceText}  •  ${deal.place}',
                    style: const TextStyle(
                      color: AppColors.textRegular,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded, color: AppColors.accent),
          ],
        ),
      ),
    );
  }
}

class _PromoFilter {
  final String label;
  final String? category;

  const _PromoFilter(this.label, this.category);
}

class _PromoDeal {
  final String title;
  final String place;
  final String image;
  final String discountLabel;
  final String category;
  final String badge;
  final String description;
  final String priceText;
  final String originalPriceText;
  final String expiryText;
  final bool highlight;

  const _PromoDeal({
    required this.title,
    required this.place,
    required this.image,
    required this.discountLabel,
    required this.category,
    required this.badge,
    required this.description,
    required this.priceText,
    required this.originalPriceText,
    required this.expiryText,
    this.highlight = false,
  });
}

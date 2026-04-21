import 'package:duckhat/theme.dart';
import 'package:flutter/material.dart';

import 'service.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchController = TextEditingController();
  final _locationController = TextEditingController();

  int _selectedFilter = -1;

  final _filters = const [
    _SearchFilter(Icons.cut, 'Cabeleireiro'),
    _SearchFilter(Icons.spa_outlined, 'Manicure'),
    _SearchFilter(Icons.plumbing, 'Encanador'),
    _SearchFilter(Icons.lightbulb_outline, 'Eletricista'),
    _SearchFilter(Icons.key_outlined, 'Chaveiro'),
    _SearchFilter(Icons.face_retouching_natural, 'Barbeiro'),
    _SearchFilter(Icons.favorite_border, 'Esteticista'),
    _SearchFilter(Icons.build_outlined, 'Pedreiro'),
  ];

  final _recent = const [
    _SearchSuggestion(
      title: 'M&L encanamentos LTDA',
      subtitle: 'Manutencao de pia',
      icon: Icons.plumbing,
      opensEstablishment: true,
    ),
  ];

  final _suggestions = const [
    _SearchSuggestion(title: 'Encanamento', icon: Icons.plumbing),
    _SearchSuggestion(title: 'Eletricista', icon: Icons.lightbulb_outline),
    _SearchSuggestion(title: 'Marcenaria', icon: Icons.chair_outlined),
    _SearchSuggestion(title: 'Cabeleireiro', icon: Icons.cut),
    _SearchSuggestion(title: 'Manicure', icon: Icons.spa_outlined),
    _SearchSuggestion(title: 'Barbeiro', icon: Icons.face),
  ];

  List<_SearchSuggestion> get _visibleSuggestions {
    final query = _searchController.text.trim().toLowerCase();
    final selected = _selectedFilter == -1 ? null : _filters[_selectedFilter];

    if (query.isEmpty && selected == null) return _suggestions;

    return _suggestions.where((item) {
      final matchesText =
          query.isEmpty || item.title.toLowerCase().contains(query);
      final matchesFilter =
          selected == null ||
          item.title.toLowerCase().contains(selected.label.toLowerCase());
      return matchesText && matchesFilter;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _applySuggestion(String value) {
    setState(() => _searchController.text = value);
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _locationController.clear();
      _selectedFilter = -1;
    });
  }

  void _openEstablishment() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const ServicePage()));
  }

  void _handleRecentTap(_SearchSuggestion item) {
    if (item.opensEstablishment) {
      _openEstablishment();
      return;
    }

    _applySuggestion(item.title);
  }

  @override
  Widget build(BuildContext context) {
    final suggestions = _visibleSuggestions;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _SearchHeader(onBack: () => Navigator.pop(context)),
                    const SizedBox(height: 18),
                    _SearchPanel(
                      searchController: _searchController,
                      locationController: _locationController,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 16),
                    _FilterRail(
                      filters: _filters,
                      selectedIndex: _selectedFilter,
                      onSelected: (index) {
                        setState(() {
                          _selectedFilter = _selectedFilter == index
                              ? -1
                              : index;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    if (_searchController.text.isEmpty &&
                        _locationController.text.isEmpty &&
                        _selectedFilter == -1)
                      _RecentSearches(
                        items: _recent,
                        onClear: _clearSearch,
                        onTap: _handleRecentTap,
                      ),
                    _SectionTitle(
                      title: suggestions.isEmpty
                          ? 'Nenhum resultado'
                          : 'Sugestoes',
                      action: suggestions.isEmpty ? null : 'Ver todos',
                    ),
                  ],
                ),
              ),
            ),
            if (suggestions.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: _EmptySearchState(),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(18, 4, 18, 28),
                sliver: SliverList.builder(
                  itemCount: suggestions.length,
                  itemBuilder: (context, index) {
                    final item = suggestions[index];
                    return _SuggestionTile(
                      item: item,
                      onTap: () => _applySuggestion(item.title),
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

class _SearchHeader extends StatelessWidget {
  final VoidCallback onBack;

  const _SearchHeader({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton.filled(
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.textBold,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pesquisar',
                style: TextStyle(
                  color: AppColors.textBold,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'Servicos, profissionais e reparos perto de voce',
                style: TextStyle(
                  color: AppColors.textRegular,
                  fontSize: 12,
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

class _SearchPanel extends StatelessWidget {
  final TextEditingController searchController;
  final TextEditingController locationController;
  final ValueChanged<String> onChanged;

  const _SearchPanel({
    required this.searchController,
    required this.locationController,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          _SearchInput(
            controller: searchController,
            icon: Icons.search,
            hint: 'Encontre especialistas ou servicos',
            onChanged: onChanged,
          ),
          const SizedBox(height: 10),
          _SearchInput(
            controller: locationController,
            icon: Icons.location_on_outlined,
            hint: 'Pesquise por bairro, cidade ou CEP',
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _SearchInput extends StatelessWidget {
  final TextEditingController controller;
  final IconData icon;
  final String hint;
  final ValueChanged<String> onChanged;

  const _SearchInput({
    required this.controller,
    required this.icon,
    required this.hint,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: const TextStyle(
        color: AppColors.textBold,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: AppColors.textMutedLight,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        prefixIcon: Icon(icon, color: AppColors.accent),
        filled: true,
        fillColor: AppColors.inputFill,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.6),
        ),
      ),
    );
  }
}

class _FilterRail extends StatelessWidget {
  final List<_SearchFilter> filters;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const _FilterRail({
    required this.filters,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final selected = selectedIndex == index;

          return InkWell(
            onTap: () => onSelected(index),
            borderRadius: BorderRadius.circular(999),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: selected ? AppColors.accent : Colors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: selected ? AppColors.accent : AppColors.border,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    filter.icon,
                    size: 18,
                    color: selected ? Colors.white : AppColors.accent,
                  ),
                  const SizedBox(width: 7),
                  Text(
                    filter.label,
                    style: TextStyle(
                      color: selected ? Colors.white : AppColors.textBold,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RecentSearches extends StatelessWidget {
  final List<_SearchSuggestion> items;
  final VoidCallback onClear;
  final ValueChanged<_SearchSuggestion> onTap;

  const _RecentSearches({
    required this.items,
    required this.onClear,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SectionTitle(
          title: 'Buscas recentes',
          action: 'Limpar',
          onAction: onClear,
        ),
        ...items.map(
          (item) => _SuggestionTile(
            item: item,
            compact: true,
            onTap: () => onTap(item),
          ),
        ),
        const SizedBox(height: 6),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;

  const _SectionTitle({required this.title, this.action, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title.toUpperCase(),
              style: const TextStyle(
                color: AppColors.textBold,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          if (action != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textRegular,
                visualDensity: VisualDensity.compact,
              ),
              child: Text(action!.toUpperCase()),
            ),
        ],
      ),
    );
  }
}

class _SuggestionTile extends StatelessWidget {
  final _SearchSuggestion item;
  final bool compact;
  final VoidCallback onTap;

  const _SuggestionTile({
    required this.item,
    required this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: compact ? 8 : 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(item.icon, color: AppColors.accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        color: AppColors.textBold,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (item.subtitle != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        item.subtitle!,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(
                Icons.north_west,
                color: AppColors.textMutedLight,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptySearchState extends StatelessWidget {
  const _EmptySearchState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, color: AppColors.textMutedLight, size: 52),
            SizedBox(height: 12),
            Text(
              'Nenhuma sugestao encontrada',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textBold,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Tente outro termo ou remova o filtro selecionado.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textRegular, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchFilter {
  final IconData icon;
  final String label;

  const _SearchFilter(this.icon, this.label);
}

class _SearchSuggestion {
  final String title;
  final String? subtitle;
  final IconData icon;
  final bool opensEstablishment;

  const _SearchSuggestion({
    required this.title,
    required this.icon,
    this.subtitle,
    this.opensEstablishment = false,
  });
}

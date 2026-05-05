import 'package:duckhat/theme.dart';
import 'package:flutter/material.dart';

import '../core/app_route.dart';
import 'service.dart';
import 'search_results.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _queryController = TextEditingController();
  final _locationController = TextEditingController();

  _SearchMode _mode = _SearchMode.local;

  final _suggestions = const [
    _SearchSuggestion('Barbeiro', Icons.face_retouching_natural),
    _SearchSuggestion('Cabeleireiro', Icons.cut),
    _SearchSuggestion('Manicure', Icons.spa_outlined),
    _SearchSuggestion('Esteticista', Icons.favorite_border_rounded),
    _SearchSuggestion('Encanador', Icons.plumbing),
    _SearchSuggestion('Eletricista', Icons.lightbulb_outline),
    _SearchSuggestion('Chaveiro', Icons.key_outlined),
    _SearchSuggestion('Pedreiro', Icons.build_outlined),
    _SearchSuggestion(
      'M&L encanamentos LTDA',
      Icons.plumbing,
      opensEstablishment: true,
    ),
  ];

  @override
  void dispose() {
    _queryController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _submitSearch({String? query}) {
    Navigator.of(context).push(
      AppRoute(
        builder: (_) => SearchResultsPage(
          query: (query ?? _queryController.text).trim(),
          location: _locationController.text.trim(),
          useCurrentLocation: _mode == _SearchMode.local,
        ),
      ),
    );
  }

  void _openSuggestion(_SearchSuggestion suggestion) {
    if (suggestion.opensEstablishment) {
      Navigator.of(context).push(AppRoute(builder: (_) => const ServicePage()));
      return;
    }

    setState(() => _queryController.text = suggestion.title);
    _submitSearch(query: suggestion.title);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          key: const PageStorageKey('search-page'),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded),
                iconSize: 26,
                color: Colors.black,
                tooltip: 'Fechar',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.tightFor(
                  width: 40,
                  height: 40,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _ModeSelector(
              selected: _mode,
              onChanged: (value) => setState(() => _mode = value),
            ),
            const SizedBox(height: 20),
            _SearchTextField(
              controller: _queryController,
              icon: Icons.search_rounded,
              hint: 'Encontre serviços ou estabelecimentos',
              active: true,
              onSubmitted: (_) => _submitSearch(),
            ),
            const SizedBox(height: 14),
            _SearchTextField(
              controller: _locationController,
              icon: Icons.location_on,
              hint: 'Encontre por bairro, cidade ou CEP',
              active: false,
              enabled: _mode == _SearchMode.home,
              onSubmitted: (_) => _submitSearch(),
            ),
            const SizedBox(height: 34),
            const Text(
              'SUGESTÕES',
              style: TextStyle(
                color: Color(0xFF667085),
                fontSize: 13,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 12),
            ..._suggestions.map(
              (suggestion) => _SuggestionRow(
                suggestion: suggestion,
                onTap: () => _openSuggestion(suggestion),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _SearchMode {
  local('NO LOCAL'),
  home('EM DOMICÍLIO');

  final String label;

  const _SearchMode(this.label);
}

class _ModeSelector extends StatelessWidget {
  final _SearchMode selected;
  final ValueChanged<_SearchMode> onChanged;

  const _ModeSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _SearchMode.values.map((mode) {
        final isSelected = selected == mode;
        return Padding(
          padding: const EdgeInsets.only(right: 10),
          child: InkWell(
            onTap: () => onChanged(mode),
            borderRadius: BorderRadius.circular(999),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.accent : Colors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: isSelected
                      ? AppColors.accent
                      : const Color(0xFFE5E7EB),
                  width: 1.3,
                ),
              ),
              child: Center(
                child: Text(
                  mode.label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF667085),
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _SearchTextField extends StatelessWidget {
  final TextEditingController controller;
  final IconData icon;
  final String hint;
  final bool active;
  final bool enabled;
  final ValueChanged<String> onSubmitted;

  const _SearchTextField({
    required this.controller,
    required this.icon,
    required this.hint,
    required this.active,
    required this.onSubmitted,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = active ? AppColors.accent : const Color(0xFFE2E5EA);
    final iconColor = active ? AppColors.accent : const Color(0xFF98A2B3);

    return SizedBox(
      height: 54,
      child: TextField(
        controller: controller,
        enabled: enabled,
        onSubmitted: onSubmitted,
        textInputAction: TextInputAction.search,
        style: const TextStyle(
          color: AppColors.textBold,
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            color: Color(0xFFD7D9DE),
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 14, right: 8),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 48),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 15,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: borderColor, width: 1.6),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: borderColor, width: 1.6),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: borderColor, width: 1.3),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: borderColor, width: 1.8),
          ),
        ),
      ),
    );
  }
}

class _SuggestionRow extends StatelessWidget {
  final _SearchSuggestion suggestion;
  final VoidCallback onTap;

  const _SuggestionRow({required this.suggestion, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.16),
                shape: BoxShape.circle,
              ),
              child: Icon(suggestion.icon, color: AppColors.accent, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                suggestion.title,
                style: const TextStyle(
                  color: Color(0xFF1F2937),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchSuggestion {
  final String title;
  final IconData icon;
  final bool opensEstablishment;

  const _SearchSuggestion(
    this.title,
    this.icon, {
    this.opensEstablishment = false,
  });
}

import 'package:flutter/material.dart';

class EstablishmentCategory {
  final String code;
  final String label;
  final String description;
  final IconData icon;
  final List<String> keywords;

  const EstablishmentCategory({
    required this.code,
    required this.label,
    required this.description,
    required this.icon,
    required this.keywords,
  });

  bool matches(String query) {
    final normalized = normalize(query);
    if (normalized.isEmpty) return true;
    return normalize(label).contains(normalized) ||
        normalize(description).contains(normalized) ||
        keywords.any((keyword) => normalize(keyword).contains(normalized));
  }

  static EstablishmentCategory byCode(String? code) {
    return categories.firstWhere(
      (category) => category.code == code,
      orElse: () => generic,
    );
  }

  static String normalize(String value) {
    const replacements = {
      'á': 'a',
      'à': 'a',
      'â': 'a',
      'ã': 'a',
      'é': 'e',
      'ê': 'e',
      'í': 'i',
      'ó': 'o',
      'ô': 'o',
      'õ': 'o',
      'ú': 'u',
      'ü': 'u',
      'ç': 'c',
    };
    var normalized = value.toLowerCase();
    replacements.forEach((from, to) {
      normalized = normalized.replaceAll(from, to);
    });
    return normalized
        .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static const generic = EstablishmentCategory(
    code: 'barbearia',
    label: 'Barbearia',
    description: 'Cortes, barba e acabamento.',
    icon: Icons.content_cut,
    keywords: ['barbeiro', 'barba', 'corte masculino'],
  );

  static const categories = [
    generic,
    EstablishmentCategory(
      code: 'salao_cabeleireiro',
      label: 'Salão de cabelo',
      description: 'Cabelo, escova, coloração e tratamento.',
      icon: Icons.cut,
      keywords: ['cabeleireiro', 'cabelo', 'escova', 'coloracao'],
    ),
    EstablishmentCategory(
      code: 'manicure',
      label: 'Manicure e unhas',
      description: 'Manicure, pedicure e design de unhas.',
      icon: Icons.spa_outlined,
      keywords: ['unhas', 'pedicure', 'nail'],
    ),
    EstablishmentCategory(
      code: 'estetica_spa',
      label: 'Estética e spa',
      description: 'Estética facial, corporal e relaxamento.',
      icon: Icons.self_improvement,
      keywords: ['estetica', 'spa', 'limpeza de pele', 'massagem'],
    ),
    EstablishmentCategory(
      code: 'encanador',
      label: 'Encanador',
      description: 'Vazamentos, canos, ralos e manutenção hidráulica.',
      icon: Icons.plumbing,
      keywords: ['encanamento', 'hidraulica', 'vazamento', 'pia'],
    ),
    EstablishmentCategory(
      code: 'eletricista',
      label: 'Eletricista',
      description: 'Instalação, reparos elétricos, tomadas e iluminação.',
      icon: Icons.electrical_services,
      keywords: ['eletrica', 'luz', 'tomada', 'fiacao'],
    ),
    EstablishmentCategory(
      code: 'chaveiro',
      label: 'Chaveiro',
      description: 'Chaves, cópias, portas e fechaduras.',
      icon: Icons.key_outlined,
      keywords: ['chave', 'fechadura', 'porta'],
    ),
    EstablishmentCategory(
      code: 'pedreiro',
      label: 'Pedreiro',
      description: 'Obras, reformas e reparos de construção.',
      icon: Icons.construction,
      keywords: ['obra', 'reforma', 'construcao', 'alvenaria'],
    ),
    EstablishmentCategory(
      code: 'limpeza',
      label: 'Limpeza',
      description: 'Faxina, diarista e higienização.',
      icon: Icons.cleaning_services_outlined,
      keywords: ['faxina', 'diarista', 'higienizacao'],
    ),
    EstablishmentCategory(
      code: 'pets',
      label: 'Pet care',
      description: 'Banho, tosa e cuidados para pets.',
      icon: Icons.pets,
      keywords: ['pet', 'banho e tosa', 'veterinario'],
    ),
    EstablishmentCategory(
      code: 'saude_bem_estar',
      label: 'Saúde e bem-estar',
      description: 'Fisioterapia, personal, pilates e terapias.',
      icon: Icons.health_and_safety_outlined,
      keywords: ['saude', 'fisioterapia', 'personal', 'pilates'],
    ),
    EstablishmentCategory(
      code: 'aulas',
      label: 'Aulas e mentoria',
      description: 'Aulas particulares, reforço e cursos.',
      icon: Icons.school_outlined,
      keywords: ['aula', 'professor', 'reforco', 'curso'],
    ),
    EstablishmentCategory(
      code: 'tecnologia',
      label: 'Tecnologia',
      description: 'Suporte para computador, celular e sistemas.',
      icon: Icons.computer_outlined,
      keywords: ['informatica', 'computador', 'celular', 'suporte'],
    ),
    EstablishmentCategory(
      code: 'automotivo',
      label: 'Automotivo',
      description: 'Mecânica, estética automotiva e lava jato.',
      icon: Icons.directions_car_outlined,
      keywords: ['carro', 'mecanico', 'lava jato', 'moto'],
    ),
    EstablishmentCategory(
      code: 'eventos',
      label: 'Eventos',
      description: 'Fotografia, buffet, decoração e cerimonial.',
      icon: Icons.celebration_outlined,
      keywords: ['fotografia', 'buffet', 'decoracao', 'cerimonial'],
    ),
  ];
}

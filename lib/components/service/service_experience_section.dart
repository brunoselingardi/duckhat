import 'package:duckhat/theme.dart';
import 'package:flutter/material.dart';

class ServiceExperienceSection extends StatelessWidget {
  const ServiceExperienceSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Experiencia',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textBold,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Um espaco criativo com energia pop e atendimento premium para quem quer um visual impecavel, moderno e cheio de presenca.',
            style: TextStyle(
              fontSize: 15,
              height: 1.6,
              color: AppColors.textBold,
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'Destaques',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textBold,
            ),
          ),
          const SizedBox(height: 14),
          const _BulletLine(
            'Visual Barbiecore reinterpretado para o universo masculino',
          ),
          const _BulletLine('Equipe focada em imagem, acabamento e identidade'),
          const _BulletLine('Ambiente instagramavel com experiencia premium'),
          const SizedBox(height: 22),
          const Text(
            'Formatos de atendimento',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textBold,
            ),
          ),
          const SizedBox(height: 14),
          const _InfoLine(
            icon: Icons.storefront_outlined,
            title: 'Presencial',
            subtitle: 'Atendimento na unidade conceito com estrutura completa.',
          ),
          const SizedBox(height: 12),
          const _InfoLine(
            icon: Icons.chat_outlined,
            title: 'Curadoria por mensagem',
            subtitle:
                'Converse antes e alinhe o look ideal para o seu horario.',
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {},
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFF3EFE8),
                foregroundColor: AppColors.textBold,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Mostrar mais detalhes',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BulletLine extends StatelessWidget {
  final String text;

  const _BulletLine(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 7),
            decoration: const BoxDecoration(
              color: AppColors.accent,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14.5,
                height: 1.5,
                color: AppColors.textBold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _InfoLine({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.accent),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textBold,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 13.5,
                  height: 1.5,
                  color: AppColors.textRegular,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

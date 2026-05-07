import 'package:duckhat/components/service/service_models.dart';
import 'package:duckhat/models/estabelecimento_publico.dart';

class ServiceExperienceData {
  final String summary;
  final List<String> highlights;

  const ServiceExperienceData({
    required this.summary,
    required this.highlights,
  });
}

class ServicePublicPageFallback {
  final EstabelecimentoPublico profile;
  final List<String> galleryImages;
  final List<ServiceReview> reviews;
  final List<ServiceFaq> faqs;
  final ServiceExperienceData experience;

  const ServicePublicPageFallback({
    required this.profile,
    required this.galleryImages,
    required this.reviews,
    required this.faqs,
    required this.experience,
  });
}

const serviceTabs = [
  'Experiencia',
  'Servicos',
  'Galeria',
  'Avaliacoes',
  'Perguntas',
];

const Map<int, ServicePublicPageFallback> servicePublicPageFallbacks = {
  2: ServicePublicPageFallback(
    profile: EstabelecimentoPublico(
      id: 2,
      nome: 'Barbie Dream Barber',
      telefone: '5562999990001',
      endereco: 'Av. DuckHat, 120 - Setor Bueno',
      descricaoPublica:
          'Uma barberaria com energia Barbie: visual marcante, atendimento caloroso e uma experiencia pensada para quem quer sair com mais estilo e personalidade.',
      horarioAtendimento: 'Segunda a sexta 9h - 20h | Sabado 9h - 18h',
      imagemCapa: 'assets/barbie.jpg',
      imagemLogo: 'assets/barbielogo.jpg',
    ),
    galleryImages: [
      'assets/barbie.jpg',
      'assets/barbiesalon.jpg',
      'assets/mariano.jpg',
      'assets/jamessalon.jpg',
    ],
    reviews: [
      ServiceReview(
        name: 'Marina Couto',
        rating: 5,
        comment:
            'A Barbie Dream Barber entrega um atendimento impecavel. O ambiente e lindo e o visual final ficou perfeito.',
        date: 'Mar 7, 2025',
      ),
      ServiceReview(
        name: 'Theo Martins',
        rating: 4,
        comment:
            'Gostei muito da proposta da casa. Tudo parece pensado para gerar experiencia, nao so um corte comum.',
        date: 'Fev 18, 2025',
      ),
      ServiceReview(
        name: 'Bruno Araujo',
        rating: 5,
        comment:
            'Do atendimento ate a finalizacao, tudo foi muito acima do esperado. Voltaria facil.',
        date: 'Jan 26, 2025',
      ),
    ],
    faqs: [
      ServiceFaq(
        question: 'Precisa agendar com antecedencia?',
        answer:
            'Recomendamos reservar antes, principalmente nos horarios mais concorridos e em datas especiais.',
      ),
      ServiceFaq(
        question: 'A Barbie Dream Barber atende por ordem de chegada?',
        answer:
            'Sim, mas os horarios reservados pelo app ou por mensagem recebem prioridade no atendimento.',
      ),
      ServiceFaq(
        question: 'Quais formas de pagamento sao aceitas?',
        answer:
            'Cartao, Pix e dinheiro. Alguns combos tambem podem ser pagos antecipadamente.',
      ),
    ],
    experience: ServiceExperienceData(
      summary:
          'Um espaco criativo com energia pop e atendimento premium para quem quer um visual impecavel, moderno e cheio de presenca.',
      highlights: [
        'Visual Barbiecore reinterpretado para o universo masculino',
        'Equipe focada em imagem, acabamento e identidade',
        'Ambiente instagramavel com experiencia premium',
      ],
    ),
  ),
};

ServicePublicPageFallback? fallbackForPrestador(int prestadorId) {
  return servicePublicPageFallbacks[prestadorId];
}

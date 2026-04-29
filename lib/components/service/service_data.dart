import 'package:duckhat/components/service/service_models.dart';

const serviceTabs = [
  'Experiencia',
  'Servicos',
  'Galeria',
  'Avaliacoes',
  'Perguntas',
];

const serviceEstablishmentName = 'Barbie Dream Barber';
const servicePrestadorId = 2;

const serviceGalleryImages = [
  'assets/barbie.jpg',
  'assets/barbiesalon.jpg',
  'assets/mariano.jpg',
  'assets/jamessalon.jpg',
];

const serviceOffers = [
  ServiceOffer(
    serviceId: 1,
    prestadorId: servicePrestadorId,
    title: 'Glow Cut Barbie',
    description:
        'Corte com acabamento leve, volume alinhado e finalizacao com assinatura fashionista.',
    durationMin: 50,
    priceValue: 55,
  ),
  ServiceOffer(
    serviceId: 2,
    prestadorId: servicePrestadorId,
    title: 'Pink Beard Design',
    description:
        'Desenho de barba com contorno preciso, toalha quente e cuidado premium.',
    durationMin: 35,
    priceValue: 42,
  ),
  ServiceOffer(
    serviceId: 3,
    prestadorId: servicePrestadorId,
    title: 'Dream Combo',
    description:
        'Pacote completo com corte, barba e finalizacao pensado para um visual marcante.',
    durationMin: 80,
    priceValue: 89,
  ),
  ServiceOffer(
    serviceId: 4,
    prestadorId: servicePrestadorId,
    title: 'Ken Executive Finish',
    description:
        'Acabamento rapido para quem quer elegancia, limpeza e presenca no mesmo horario.',
    durationMin: 30,
    priceValue: 38,
  ),
];

const serviceReviews = [
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
];

const serviceFaqs = [
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
];

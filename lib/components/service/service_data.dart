import 'package:duckhat/components/service/service_models.dart';

const serviceTabs = [
  'Experiencia',
  'Servicos',
  'Galeria',
  'Avaliacoes',
  'Perguntas',
];

const serviceGalleryImages = [
  'assets/barbie.jpg',
  'assets/barbiesalon.jpg',
  'assets/mariano.jpg',
  'assets/jamessalon.jpg',
];

const serviceOffers = [
  ServiceOffer(
    title: 'Glow Cut Barbie',
    duration: '50 min',
    price: 'R\$ 55',
    description:
        'Corte com acabamento leve, volume alinhado e finalizacao com assinatura fashionista.',
  ),
  ServiceOffer(
    title: 'Pink Beard Design',
    duration: '35 min',
    price: 'R\$ 42',
    description:
        'Desenho de barba com contorno preciso, toalha quente e cuidado premium.',
  ),
  ServiceOffer(
    title: 'Dream Combo',
    duration: '1h 20 min',
    price: 'R\$ 89',
    description:
        'Pacote completo com corte, barba e finalizacao pensado para um visual marcante.',
  ),
  ServiceOffer(
    title: 'Ken Executive Finish',
    duration: '30 min',
    price: 'R\$ 38',
    description:
        'Acabamento rapido para quem quer elegancia, limpeza e presenca no mesmo horario.',
  ),
];

const serviceReviews = [
  ServiceReview(
    name: 'Marina Couto',
    rating: '5.0',
    comment:
        'A Barbie Dream Barber entrega um atendimento impecavel. O ambiente e lindo e o visual final ficou perfeito.',
    date: 'Mar 7, 2025',
  ),
  ServiceReview(
    name: 'Theo Martins',
    rating: '4.9',
    comment:
        'Gostei muito da proposta da casa. Tudo parece pensado para gerar experiencia, nao so um corte comum.',
    date: 'Fev 18, 2025',
  ),
  ServiceReview(
    name: 'Bruno Araujo',
    rating: '5.0',
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

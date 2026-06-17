import '../models/store.dart';
import '../models/barber.dart';
import '../models/service_item.dart';
import '../models/plan.dart';
import '../models/product.dart';
import '../models/appointment.dart';

class MockData {
  static final List<Store> stores = [
    Store(
      id: 'store-matriz',
      name: "Alce's Barbearia - Matriz",
      phone: '5547996155719',
      address: 'R. Erich Steinbach, 22 – sl 02 – Itoupava Seca, Blumenau – SC',
      openTime: '08:30',
      closeTime: '20:00',
    ),
    Store(
      id: 'store-escola-agricola',
      name: "Alce's Barbearia - Escola Agrícola",
      phone: '5547996155719',
      address: 'R. Benjamin Constant, 939 – Escola Agrícola, Blumenau – SC',
      openTime: '08:30',
      closeTime: '20:00',
    ),
  ];

  static final List<Barber> barbers = [
    Barber(
      id: 'barber-gabriel',
      storeId: 'store-matriz',
      name: 'Gabriel Becker',
      specialty: 'Especialista em Degradê e Barboterapia',
      avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&q=80&w=200',
      isLeader: true,
      isActive: true,
    ),
    Barber(
      id: 'barber-jerffeson',
      storeId: 'store-matriz',
      name: 'Jerffeson',
      specialty: 'Cortes clássicos e modernos',
      avatarUrl: 'https://images.unsplash.com/photo-1621605815971-fbc98d665033?auto=format&fit=crop&q=80&w=200',
      isLeader: false,
      isActive: true,
    ),
    Barber(
      id: 'barber-thiago',
      storeId: 'store-matriz',
      name: 'Thiago Ferreira',
      specialty: 'Especialista em Visagismo e Química',
      avatarUrl: 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?auto=format&fit=crop&q=80&w=200',
      isLeader: false,
      isActive: true,
    ),
    Barber(
      id: 'barber-lucas-pelizer',
      storeId: 'store-matriz',
      name: 'Lucas Pelizer',
      specialty: 'Cortes clássicos e tesoura',
      avatarUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&q=80&w=200',
      isLeader: false,
      isActive: true,
    ),
    Barber(
      id: 'barber-jorge',
      storeId: 'store-escola-agricola',
      name: 'Jorge Henrique Funke',
      specialty: 'Mestre barbeiro, cortes clássicos',
      avatarUrl: 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?auto=format&fit=crop&q=80&w=200',
      isLeader: true,
      isActive: true,
    ),
    Barber(
      id: 'barber-peterson',
      storeId: 'store-escola-agricola',
      name: 'Peterson',
      specialty: 'Especialista em Degradê e Barba',
      avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=200',
      isLeader: false,
      isActive: true,
    ),
    Barber(
      id: 'barber-ryan',
      storeId: 'store-escola-agricola',
      name: 'Ryan',
      specialty: 'Cortes modernos e penteados',
      avatarUrl: 'https://images.unsplash.com/photo-1501196354995-cbb51c65aaea?auto=format&fit=crop&q=80&w=200',
      isLeader: false,
      isActive: true,
    ),
  ];

  static final List<ServiceItem> services = [
    ServiceItem(
      id: 'service-corte',
      storeId: 'store-matriz',
      name: 'Corte Masculino',
      description: 'Corte moderno ou tradicional adaptado ao seu estilo, com lavagem premium inclusa.',
      price: 45.00,
      duration: 30,
      category: 'Cabelo',
    ),
    ServiceItem(
      id: 'service-degrade',
      storeId: 'store-matriz',
      name: 'Degradê Premium',
      description: 'Corte degradê (fade) de alta precisão, finalizado com produtos de primeira linha.',
      price: 55.00,
      duration: 40,
      category: 'Cabelo',
    ),
    ServiceItem(
      id: 'service-combo',
      storeId: 'store-matriz',
      name: 'Combo: Corte + Barba',
      description: 'Serviço completo. Corte de cabelo premium combinado com barboterapia tradicional.',
      price: 70.00,
      duration: 60,
      category: 'Combos',
    ),
    ServiceItem(
      id: 'service-barba',
      storeId: 'store-matriz',
      name: 'Barba Alce\'s',
      description: 'Design de barba alinhado com toalha quente, óleo hidratante e massagem rápida.',
      price: 35.00,
      duration: 30,
      category: 'Barba',
    ),
    // Escola Agricola
    ServiceItem(
      id: 'service-corte-ea',
      storeId: 'store-escola-agricola',
      name: 'Corte Masculino',
      description: 'Corte moderno ou tradicional adaptado ao seu estilo, com lavagem premium inclusa.',
      price: 45.00,
      duration: 30,
      category: 'Cabelo',
    ),
    ServiceItem(
      id: 'service-combo-ea',
      storeId: 'store-escola-agricola',
      name: 'Combo: Corte + Barba',
      description: 'Serviço completo. Corte de cabelo premium combinado com barboterapia tradicional.',
      price: 70.00,
      duration: 60,
      category: 'Combos',
    ),
    ServiceItem(
      id: 'service-barba-ea',
      storeId: 'store-escola-agricola',
      name: 'Barba Alce\'s',
      description: 'Design de barba alinhado com toalha quente, óleo hidratante e massagem rápida.',
      price: 35.00,
      duration: 30,
      category: 'Barba',
    ),
  ];

  static final List<SubscriptionPlan> plans = [
    SubscriptionPlan(
      id: 'plan-essencial',
      name: 'Clube Essencial',
      description: 'Perfeito para manter o visual sempre alinhado.',
      price: 89.90,
      billingCycle: 'mensal',
      features: [
        '2 Cortes de Cabelo por mês',
        '10% de desconto em qualquer produto',
        'Café espresso cortesia',
        'Sem taxa de adesão'
      ],
    ),
    SubscriptionPlan(
      id: 'plan-premium',
      name: 'Clube Premium',
      description: 'Nosso clube mais popular, visual impecável toda semana.',
      price: 149.90,
      billingCycle: 'mensal',
      features: [
        'Cortes ilimitados de cabelo',
        '1 Barboterapia inclusa por mês',
        '15% de desconto em produtos',
        'Cerveja artesanal ou café de cortesia',
        'Agendamento prioritário'
      ],
    ),
    SubscriptionPlan(
      id: 'plan-vip',
      name: 'Clube Alce\'s VIP',
      description: 'A experiência máxima da Alce\'s Barbearia.',
      price: 199.90,
      billingCycle: 'mensal',
      features: [
        'Cortes e Barbas ILIMITADOS',
        '20% de desconto em toda a linha de produtos',
        'Bebidas premium liberadas (chopp/cerveja/café)',
        '1 Massagem capilar ou relaxamento por mês',
        'Atendimento com profissionais líderes'
      ],
    ),
  ];

  static final List<ProductItem> products = [
    ProductItem(
      id: 'prod-pomada-matte',
      name: 'Pomada Matte Forte',
      description: 'Fixação forte e efeito matte (seco). Ideal para penteados texturizados e modernos.',
      price: 45.90,
      imageUrl: 'https://images.unsplash.com/photo-1608248597279-f99d160bfcbc?auto=format&fit=crop&q=80&w=200',
      category: 'Penteados',
      stockQuantity: 15,
    ),
    ProductItem(
      id: 'prod-oleo',
      name: 'Óleo Hidratante Alce\'s',
      description: 'Óleo essencial com aroma de sândalo. Hidrata os fios da barba e a pele por baixo.',
      price: 38.00,
      imageUrl: 'https://images.unsplash.com/photo-1626015713026-d837d172406f?auto=format&fit=crop&q=80&w=200',
      category: 'Barba',
      stockQuantity: 8,
    ),
    ProductItem(
      id: 'prod-balm',
      name: 'Balm Alinhador para Barba',
      description: 'Reduz o frizz, amacia e modela a barba levemente, dando volume e hidratação.',
      price: 42.00,
      imageUrl: 'https://images.unsplash.com/photo-1556228720-195a672e8a03?auto=format&fit=crop&q=80&w=200',
      category: 'Barba',
      stockQuantity: 12,
    ),
    ProductItem(
      id: 'prod-shampoo',
      name: 'Shampoo 3 em 1 Cabelo/Barba/Corpo',
      description: 'Limpeza profunda com sensação refrescante de hortelã. Fortalece o folículo piloso.',
      price: 29.90,
      imageUrl: 'https://images.unsplash.com/photo-1535585209827-a15fcdbc4c2d?auto=format&fit=crop&q=80&w=200',
      category: 'Higiene',
      stockQuantity: 20,
    ),
  ];

  static final List<Appointment> pastAppointments = [
    Appointment(
      id: 'appt-1',
      storeId: 'store-matriz',
      barberId: 'barber-gabriel',
      serviceId: 'service-corte',
      clientName: 'Cliente Demo',
      date: DateTime.now().subtract(const Duration(days: 15)),
      time: '15:30',
      status: 'confirmed',
    ),
    Appointment(
      id: 'appt-2',
      storeId: 'store-matriz',
      barberId: 'barber-jerffeson',
      serviceId: 'service-barba',
      clientName: 'Cliente Demo',
      date: DateTime.now().subtract(const Duration(days: 32)),
      time: '18:00',
      status: 'confirmed',
    ),
  ];
  
  static final List<Appointment> upcomingAppointments = [];
}

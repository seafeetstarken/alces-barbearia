import 'package:flutter/material.dart';
import '../core/supabase_client.dart';
import '../models/store.dart';
import '../models/barber.dart';
import '../models/service_item.dart';
import '../models/appointment.dart';
import '../models/product.dart';
import '../models/plan.dart';

class AppState {
  // Singleton instance
  static final AppState _instance = AppState._internal();
  factory AppState() => _instance;
  AppState._internal();

  // Supabase collections
  final ValueNotifier<List<Store>> stores = ValueNotifier<List<Store>>([]);
  final ValueNotifier<List<Barber>> barbers = ValueNotifier<List<Barber>>([]);
  final ValueNotifier<List<ServiceItem>> services = ValueNotifier<List<ServiceItem>>([]);
  final ValueNotifier<List<ProductItem>> products = ValueNotifier<List<ProductItem>>([]);
  final ValueNotifier<List<SubscriptionPlan>> plans = ValueNotifier<List<SubscriptionPlan>>([]);
  
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(true);

  // Selected active store/unit
  final ValueNotifier<Store> activeStore = ValueNotifier<Store>(
    Store(id: '', name: 'Carregando...', phone: '', address: '', openTime: '', closeTime: '')
  );

  // Upcoming appointments booked during this session
  final ValueNotifier<List<Appointment>> upcomingAppointments = ValueNotifier<List<Appointment>>([]);

  // Shopping cart items (Product -> Quantity)
  final ValueNotifier<Map<ProductItem, int>> cart = ValueNotifier<Map<ProductItem, int>>({});

  // Global booking cart for services
  final ValueNotifier<List<ServiceItem>> bookingCart = ValueNotifier<List<ServiceItem>>([]);

  // Active membership plan (null if none, otherwise plan name)
  final ValueNotifier<String?> activePlan = ValueNotifier<String?>(null);

  // Profile Gamification Stats
  final ValueNotifier<int> userXp = ValueNotifier<int>(0);
  final ValueNotifier<int> userCoins = ValueNotifier<int>(0);
  final ValueNotifier<int> userLevel = ValueNotifier<int>(1);
  final ValueNotifier<String?> userBirthDate = ValueNotifier<String?>(null);
  final ValueNotifier<String?> userSavedEmail = ValueNotifier<String?>(null);
  
  // Profile fields
  String get userName {
    final user = supabase.auth.currentUser;
    return user?.userMetadata?['full_name'] ?? 'Usuário';
  }

  String get userEmail {
    final user = supabase.auth.currentUser;
    return user?.email ?? '';
  }

  String get userPhone {
    final user = supabase.auth.currentUser;
    return user?.userMetadata?['phone'] ?? '';
  }

  Future<void> loadInitialData() async {
    try {
      isLoading.value = true;
      final storesData = await supabase.from('stores').select();
      final barbersData = await supabase.from('barbers').select();
      final servicesData = await supabase.from('services').select();
      final productsData = await supabase.from('products').select();
      final plansData = await supabase.from('plans').select();
      
      // Load user gamification profile if logged in
      final user = supabase.auth.currentUser;
      if (user != null) {
        try {
          final profileData = await supabase.from('profiles').select().eq('id', user.id).maybeSingle();
          if (profileData != null) {
            userXp.value = profileData['xp'] ?? 0;
            userCoins.value = profileData['alce_coins'] ?? 0;
            userLevel.value = profileData['level'] ?? 1;
            userBirthDate.value = profileData['birth_date'];
            userSavedEmail.value = profileData['email'];
          }
        } catch (_) {}
      }

      if (user != null) {
        try {
          final appointmentsData = await supabase.from('appointments').select().eq('user_id', user.id).neq('status', 'cancelled');
          upcomingAppointments.value = appointmentsData.map<Appointment>((e) => Appointment.fromJson(e)).toList();
        } catch (e) {
          debugPrint('Error loading appointments: $e');
        }
      }

      stores.value = storesData.map<Store>((e) => Store.fromJson(e)).toList();
      barbers.value = barbersData.map<Barber>((e) => Barber.fromJson(e)).toList();
      services.value = servicesData.map<ServiceItem>((e) => ServiceItem.fromJson(e)).toList();

      // Sort services to put Corte and Barba first
      services.value.sort((a, b) {
        final aLower = a.name.toLowerCase();
        final bLower = b.name.toLowerCase();
        
        int getPriority(String name) {
          if (name.contains('corte')) return 1;
          if (name.contains('barba')) return 2;
          return 3;
        }
        
        final aPriority = getPriority(aLower);
        final bPriority = getPriority(bLower);
        
        if (aPriority != bPriority) return aPriority.compareTo(bPriority);
        return a.name.compareTo(b.name);
      });

      products.value = productsData.map<ProductItem>((e) => ProductItem.fromJson(e)).toList();
      plans.value = plansData.map<SubscriptionPlan>((e) => SubscriptionPlan.fromJson(e)).toList();

      if (stores.value.isNotEmpty) {
        // Sort stores so 'Escola Agrícola' appears first in the list
        stores.value.sort((a, b) {
          if (a.name.contains('Escola Agrícola')) return -1;
          if (b.name.contains('Escola Agrícola')) return 1;
          return a.name.compareTo(b.name);
        });
        
        activeStore.value = stores.value.first;
      }
    } catch (e) {
      debugPrint('Error loading initial data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void changeStore(Store store) {
    activeStore.value = store;
  }

  Future<void> addAppointment(Appointment appt) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('Usuário não logado');

    final data = appt.toJson();
    data['user_id'] = user.id;

    // Salvar no Supabase
    await supabase.from('appointments').insert(data);

    // Atualizar UI
    final list = List<Appointment>.from(upcomingAppointments.value);
    list.add(appt);
    upcomingAppointments.value = list;
  }

  Future<void> cancelAppointment(String appointmentId) async {
    try {
      await supabase.from('appointments').update({'status': 'cancelled'}).eq('id', appointmentId);
      final list = List<Appointment>.from(upcomingAppointments.value);
      list.removeWhere((a) => a.id == appointmentId);
      upcomingAppointments.value = list;

      // Deduct Gamification Rewards
      final user = supabase.auth.currentUser;
      if (user != null) {
        int newXp = userXp.value - 50;
        if (newXp < 0) newXp = 0;
        
        int newCoins = userCoins.value - 10;
        if (newCoins < 0) newCoins = 0;

        await supabase.from('profiles').update({
          'xp': newXp,
          'alce_coins': newCoins,
        }).eq('id', user.id);
        
        userXp.value = newXp;
        userCoins.value = newCoins;
      }
    } catch (e) {
      debugPrint('Erro ao cancelar agendamento: $e');
      rethrow;
    }
  }

  // Buscar horários ocupados de um barbeiro específico num dia
  Future<List<String>> fetchBookedSlots(String barberId, DateTime date) async {
    try {
      final dateStr = date.toIso8601String().split('T')[0];
      final response = await supabase
          .from('appointments')
          .select('appointment_time')
          .eq('barber_id', barberId)
          .eq('appointment_date', dateStr)
          .neq('status', 'cancelled');
      
      return response.map<String>((e) => e['appointment_time'] as String).toList();
    } catch (e) {
      print('Erro ao buscar horários: $e');
      return [];
    }
  }

  // Lógica de Desconto de Clube
  double getDiscountForService(ServiceItem service) {
    final plan = activePlan.value;
    if (plan == null || plan.isEmpty) return 0.0;

    final lowerName = service.name.toLowerCase();

    final lowerPlan = plan.toLowerCase();

    if (lowerPlan.contains('cabelo e barba ilimitado')) {
      if (lowerName.contains('corte') || lowerName.contains('barba')) return service.price;
    } else if (lowerPlan.contains('corte ilimitado')) {
      if (lowerName.contains('corte')) return service.price;
    } else if (lowerPlan.contains('barba ilimitado')) {
      if (lowerName.contains('barba')) return service.price;
    }

    return 0.0; // No discount
  }

  void addToCart(ProductItem product) {
    final current = Map<ProductItem, int>.from(cart.value);
    if (current.containsKey(product)) {
      current[product] = current[product]! + 1;
    } else {
      current[product] = 1;
    }
    cart.value = current;
  }

  void removeFromCart(ProductItem product) {
    final current = Map<ProductItem, int>.from(cart.value);
    if (current.containsKey(product)) {
      if (current[product] == 1) {
        current.remove(product);
      } else {
        current[product] = current[product]! - 1;
      }
    }
    cart.value = current;
  }

  void clearCart() {
    cart.value = {};
  }

  void selectPlan(String? planName) {
    if (planName == null || planName.isEmpty) {
      activePlan.value = null;
    } else {
      activePlan.value = planName;
    }
    
    // Save to Supabase for TestFlight persistence
    final user = supabase.auth.currentUser;
    if (user != null) {
      supabase.from('profiles').update({'active_plan': activePlan.value}).eq('id', user.id);
    }
  }

  double get cartTotal {
    double total = 0.0;
    cart.value.forEach((product, qty) {
      total += product.price * qty;
    });
    return total;
  }

  Future<void> reserveProducts() async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('Usuário não logado');
    if (cart.value.isEmpty) return;

    final store = activeStore.value;
    final total = cartTotal;

    final itemsList = cart.value.entries.map((entry) {
      return {
        'product_id': entry.key.id,
        'name': entry.key.name,
        'price': entry.key.price,
        'quantity': entry.value,
        'subtotal': entry.key.price * entry.value,
      };
    }).toList();

    // Call checkout single for products (Avulso)
    try {
      final customerId = await getOrCreateAsaasCustomer();
      final response = await supabase.functions.invoke('checkout-single', body: {
        'amount': total,
        'billingType': 'PIX',
        'customerId': customerId,
        'description': 'Reserva de Produtos - Alce\'s Barbearia',
      });
      // Handle the PIX code response here if needed
    } catch (e) {
      debugPrint('Erro ao pagar produtos: $e');
    }

    try {
      await supabase.from('product_reservations').insert({
        'user_id': user.id,
        'store_id': store.id.isNotEmpty ? store.id : null,
        'total_amount': total,
        'items': itemsList,
        'status': 'Aguardando Retirada',
      });
      clearCart();
    } catch (e) {
      debugPrint('Erro ao reservar produtos: $e');
      rethrow;
    }
  }

  // --- Asaas Gateway Integration ---

  Future<String> getOrCreateAsaasCustomer() async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('Usuário não logado');

    final response = await supabase.functions.invoke('create-customer', body: {});

    if (response.status != 200) {
      throw Exception('Erro ao criar cliente no Asaas: ${response.data}');
    }

    final data = response.data as Map<String, dynamic>;
    return data['customerId'] as String;
  }

  Future<Map<String, dynamic>> checkoutSingle({required double amount, required String billingType, String? appointmentId, String? description, Map<String, dynamic>? creditCard, Map<String, dynamic>? creditCardHolderInfo}) async {
    final customerId = await getOrCreateAsaasCustomer();
    
    final body = {
      'amount': amount,
      'billingType': billingType,
      'customerId': customerId,
      'appointmentId': appointmentId,
      'description': description,
    };
    if (creditCard != null) body['creditCard'] = creditCard;
    if (creditCardHolderInfo != null) body['creditCardHolderInfo'] = creditCardHolderInfo;

    final response = await supabase.functions.invoke('checkout-single', body: body);

    if (response.status != 200) {
      throw Exception('Erro ao gerar cobrança: ${response.data}');
    }

    final data = response.data as Map<String, dynamic>;
    return data['payment'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> checkoutSubscription({required String planName, required double price, required String billingType, Map<String, dynamic>? creditCard, Map<String, dynamic>? creditCardHolderInfo}) async {
    final customerId = await getOrCreateAsaasCustomer();
    
    final body = {
      'planName': planName,
      'price': price,
      'billingType': billingType,
      'customerId': customerId,
    };
    if (creditCard != null) body['creditCard'] = creditCard;
    if (creditCardHolderInfo != null) body['creditCardHolderInfo'] = creditCardHolderInfo;

    final response = await supabase.functions.invoke('checkout-subscription', body: body);

    if (response.status != 200) {
      throw Exception('Erro ao gerar assinatura: ${response.data}');
    }

    final data = response.data as Map<String, dynamic>;
    return data['subscription'] as Map<String, dynamic>;
  }
}

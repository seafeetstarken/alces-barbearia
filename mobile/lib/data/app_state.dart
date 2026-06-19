import 'package:flutter/material.dart';
import '../core/supabase_client.dart';
import '../models/store.dart';
import '../models/barber.dart';
import '../models/service_item.dart';
import '../models/appointment.dart';
import '../models/product.dart';

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
  
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(true);

  // Selected active store/unit
  final ValueNotifier<Store> activeStore = ValueNotifier<Store>(
    Store(id: '', name: 'Carregando...', phone: '', address: '', openTime: '', closeTime: '')
  );

  // Upcoming appointments booked during this session
  final ValueNotifier<List<Appointment>> upcomingAppointments = ValueNotifier<List<Appointment>>([]);

  // Shopping cart items (Product -> Quantity)
  final ValueNotifier<Map<ProductItem, int>> cart = ValueNotifier<Map<ProductItem, int>>({});

  // Active membership plan (null if none, otherwise plan name)
  final ValueNotifier<String?> activePlan = ValueNotifier<String?>(null);

  // Profile fields
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

      stores.value = storesData.map<Store>((e) => Store.fromJson(e)).toList();
      barbers.value = barbersData.map<Barber>((e) => Barber.fromJson(e)).toList();
      services.value = servicesData.map<ServiceItem>((e) => ServiceItem.fromJson(e)).toList();
      products.value = productsData.map<ProductItem>((e) => ProductItem.fromJson(e)).toList();

      if (stores.value.isNotEmpty) {
        // Find 'Matriz' to set as default if it exists, otherwise the first one
        final matriz = stores.value.firstWhere(
          (s) => s.name.contains('Matriz'), 
          orElse: () => stores.value.first
        );
        activeStore.value = matriz;
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

  void addAppointment(Appointment appt) {
    final list = List<Appointment>.from(upcomingAppointments.value);
    list.add(appt);
    upcomingAppointments.value = list;
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

  void selectPlan(String planName) {
    activePlan.value = planName;
  }

  double get cartTotal {
    double total = 0.0;
    cart.value.forEach((product, qty) {
      total += product.price * qty;
    });
    return total;
  }
}

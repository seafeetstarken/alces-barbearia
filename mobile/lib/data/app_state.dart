import 'package:flutter/material.dart';
import '../models/store.dart';
import '../models/appointment.dart';
import '../models/product.dart';
import 'mock_data.dart';

class AppState {
  // Singleton instance
  static final AppState _instance = AppState._internal();
  factory AppState() => _instance;
  AppState._internal();

  // Selected active store/unit
  final ValueNotifier<Store> activeStore = ValueNotifier<Store>(MockData.stores[0]);

  // Upcoming appointments booked during this session
  final ValueNotifier<List<Appointment>> upcomingAppointments = ValueNotifier<List<Appointment>>([]);

  // Shopping cart items (Product -> Quantity)
  final ValueNotifier<Map<ProductItem, int>> cart = ValueNotifier<Map<ProductItem, int>>({});

  // Active membership plan (null if none, otherwise plan name)
  final ValueNotifier<String?> activePlan = ValueNotifier<String?>(null);

  // Profile fields
  final String userName = 'Juan Starken';
  final String userEmail = 'juan@starken.com.br';
  final String userPhone = '(47) 99615-5719';

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

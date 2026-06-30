import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../core/supabase_client.dart';
import '../models/barber.dart';
import '../models/barber_appointment_view.dart';

class BarberRepository {
  /// Verifica se o usuário logado está vinculado a um registro de barbeiro
  Future<Barber?> getLinkedBarber(String userId) async {
    try {
      final response = await supabase
          .from('barbers')
          .select()
          .eq('profile_id', userId)
          .eq('is_active', true)
          .maybeSingle();

      if (response != null) {
        return Barber.fromJson(response);
      }
    } catch (e) {
      debugPrint('Erro ao buscar barbeiro vinculado: $e');
    }
    return null;
  }

  /// Busca agendamentos do barbeiro para um dia específico (com joins)
  Future<List<BarberAppointmentView>> fetchDayAgenda(String barberId, DateTime date) async {
    try {
      final dateStr = date.toIso8601String().split('T')[0];
      final response = await supabase
          .from('appointments')
          .select('id, appointment_date, appointment_time, status, client_name, profiles(full_name), services(name, price, duration_minutes)')
          .eq('barber_id', barberId)
          .eq('appointment_date', dateStr);

      final list = List<Map<String, dynamic>>.from(response);
      
      // Mapear e ordenar por horário
      final appointments = list.map((e) => BarberAppointmentView.fromJson(e)).toList();
      appointments.sort((a, b) => a.time.compareTo(b.time));
      return appointments;
    } catch (e) {
      debugPrint('Erro ao buscar agenda do dia do barbeiro: $e');
      return [];
    }
  }

  /// Conta agendamentos do dia para o resumo na Home (ignora cancelados)
  Future<int> countTodayAppointments(String barberId) async {
    try {
      final dateStr = DateTime.now().toIso8601String().split('T')[0];
      final response = await supabase
          .from('appointments')
          .select('id')
          .eq('barber_id', barberId)
          .eq('appointment_date', dateStr)
          .neq('status', 'cancelled')
          .neq('status', 'Cancelado'); // Trata ambos os formatos de status

      return (response as List).length;
    } catch (e) {
      debugPrint('Erro ao contar agendamentos de hoje: $e');
      return 0;
    }
  }

  /// Busca o próximo agendamento do barbeiro hoje (para preview na Home)
  Future<BarberAppointmentView?> fetchNextAppointment(String barberId) async {
    try {
      final now = DateTime.now();
      final todayAppointments = await fetchDayAgenda(barberId, now);
      
      for (var appt in todayAppointments) {
        if (appt.status.toLowerCase() == 'cancelado' || appt.status.toLowerCase() == 'cancelled') {
          continue;
        }
        
        // Converter time string (HH:mm) para comparar com a hora atual
        final timeParts = appt.time.split(':');
        final apptHour = int.parse(timeParts[0]);
        final apptMinute = int.parse(timeParts[1]);
        
        final apptDateTime = DateTime(now.year, now.month, now.day, apptHour, apptMinute);
        
        if (apptDateTime.isAfter(now)) {
          return appt;
        }
      }
    } catch (e) {
      debugPrint('Erro ao buscar próximo agendamento: $e');
    }
    return null;
  }

  /// Barbeiro agenda para um cliente (sem pagamento)
  Future<void> createBarberBooking({
    required String barberId,
    required String storeId,
    required String serviceId,
    required DateTime date,
    required String time,
    required String clientName,
  }) async {
    final user = supabase.auth.currentUser;
    final dateStr = date.toIso8601String().split('T')[0];
    
    final data = {
      'store_id': storeId,
      'barber_id': barberId,
      'service_id': serviceId,
      'appointment_date': dateStr,
      'appointment_time': time,
      'client_name': clientName,
      'status': 'Agendado', // Agendado direto sem fluxo de pagamento
      'user_id': user?.id, // Associa ao id de quem criou (o barbeiro logado)
    };

    await supabase.from('appointments').insert(data);
  }

  /// Atualizar status (Concluído, Cancelado)
  Future<void> updateAppointmentStatus(String appointmentId, String newStatus) async {
    await supabase
        .from('appointments')
        .update({'status': newStatus})
        .eq('id', appointmentId);
  }
}

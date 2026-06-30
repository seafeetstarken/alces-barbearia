class BarberAppointmentView {
  final String id;
  final String clientName;
  final String serviceName;
  final double servicePrice;
  final DateTime date;
  final String time;
  final int durationMinutes;
  final String status;

  BarberAppointmentView({
    required this.id,
    required this.clientName,
    required this.serviceName,
    required this.servicePrice,
    required this.date,
    required this.time,
    required this.durationMinutes,
    required this.status,
  });

  factory BarberAppointmentView.fromJson(Map<String, dynamic> json) {
    final profile = json['profiles'] as Map<String, dynamic>?;
    final service = json['services'] as Map<String, dynamic>?;

    final resolvedClientName = json['client_name'] as String? ??
        profile?['full_name'] as String? ??
        'Cliente Walk-in';

    final resolvedServiceName = service?['name'] as String? ?? 'Serviço Geral';
    final resolvedServicePrice = (service?['price'] as num?)?.toDouble() ?? 0.0;
    final resolvedDuration = service?['duration_minutes'] as int? ?? 30;

    final rawTime = json['appointment_time'] as String;
    final resolvedTime = rawTime.length > 5 ? rawTime.substring(0, 5) : rawTime;

    return BarberAppointmentView(
      id: json['id'] as String,
      clientName: resolvedClientName,
      serviceName: resolvedServiceName,
      servicePrice: resolvedServicePrice,
      date: DateTime.parse(json['appointment_date'] as String),
      time: resolvedTime,
      durationMinutes: resolvedDuration,
      status: json['status'] as String? ?? 'Agendado',
    );
  }
}

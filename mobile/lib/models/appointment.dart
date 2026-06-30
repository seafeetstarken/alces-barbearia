class Appointment {
  final String id;
  final String storeId;
  final String barberId;
  final String serviceId;
  final String? clientName;
  final DateTime date;
  final String time;
  final String status;

  Appointment({
    required this.id,
    required this.storeId,
    required this.barberId,
    required this.serviceId,
    this.clientName,
    required this.date,
    required this.time,
    required this.status,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] as String,
      storeId: json['store_id'] as String,
      barberId: json['barber_id'] as String,
      serviceId: json['service_id'] as String,
      clientName: json['client_name'] as String?,
      date: DateTime.parse(json['appointment_date'] as String),
      time: json['appointment_time'] as String,
      status: json['status'] as String? ?? 'Agendado',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'store_id': storeId,
      'barber_id': barberId,
      'service_id': serviceId,
      'client_name': clientName,
      'appointment_date': date.toIso8601String().split('T')[0],
      'appointment_time': time,
      'status': status,
    };
  }
}

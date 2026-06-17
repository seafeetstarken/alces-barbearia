class Appointment {
  final String id;
  final String storeId;
  final String barberId;
  final String serviceId;
  final String clientName;
  final DateTime date;
  final String time;
  final String status;

  Appointment({
    required this.id,
    required this.storeId,
    required this.barberId,
    required this.serviceId,
    required this.clientName,
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
      clientName: json['client_name'] as String? ?? 'Cliente',
      date: DateTime.parse(json['date'] as String),
      time: json['time'] as String,
      status: json['status'] as String? ?? 'pending',
    );
  }
}

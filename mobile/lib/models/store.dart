class Store {
  final String id;
  final String name;
  final String phone;
  final String address;
  final String openTime;
  final String closeTime;

  Store({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    required this.openTime,
    required this.closeTime,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String? ?? '',
      address: json['address'] as String? ?? '',
      openTime: json['open_time'] as String? ?? '08:30',
      closeTime: json['close_time'] as String? ?? '20:00',
    );
  }
}

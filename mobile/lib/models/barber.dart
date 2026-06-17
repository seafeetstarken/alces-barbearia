class Barber {
  final String id;
  final String storeId;
  final String name;
  final String specialty;
  final String avatarUrl;
  final bool isLeader;
  final bool isActive;

  Barber({
    required this.id,
    required this.storeId,
    required this.name,
    required this.specialty,
    required this.avatarUrl,
    required this.isLeader,
    required this.isActive,
  });

  String get initials {
    final parts = name.split(' ');
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  factory Barber.fromJson(Map<String, dynamic> json) {
    return Barber(
      id: json['id'] as String,
      storeId: json['store_id'] as String,
      name: json['name'] as String,
      specialty: json['specialty'] as String? ?? 'Barbeiro',
      avatarUrl: json['avatar_url'] as String? ?? '',
      isLeader: json['is_leader'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
    );
  }
}

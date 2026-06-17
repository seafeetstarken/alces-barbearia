class ServiceItem {
  final String id;
  final String storeId;
  final String name;
  final String description;
  final double price;
  final int duration;
  final String category;

  ServiceItem({
    required this.id,
    required this.storeId,
    required this.name,
    required this.description,
    required this.price,
    required this.duration,
    required this.category,
  });

  factory ServiceItem.fromJson(Map<String, dynamic> json) {
    return ServiceItem(
      id: json['id'] as String,
      storeId: json['store_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      duration: json['duration'] as int? ?? 30,
      category: json['category'] as String? ?? 'Geral',
    );
  }
}

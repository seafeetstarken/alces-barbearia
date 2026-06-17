class SubscriptionPlan {
  final String id;
  final String name;
  final String description;
  final double price;
  final String billingCycle;
  final List<String> features;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.billingCycle,
    required this.features,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    var featuresFromJson = json['features'];
    List<String> featuresList = [];
    if (featuresFromJson is List) {
      featuresList = List<String>.from(featuresFromJson);
    } else if (featuresFromJson is String) {
      featuresList = [featuresFromJson];
    }
    
    return SubscriptionPlan(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      billingCycle: json['billing_cycle'] as String? ?? 'mensal',
      features: featuresList,
    );
  }
}

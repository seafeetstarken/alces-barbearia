import 'package:flutter/material.dart';

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
      storeId: json['store_id'] as String? ?? 'global',
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      duration: json['duration'] as int? ?? json['duration_minutes'] as int? ?? 30,
      category: json['category'] as String? ?? 'Geral',
    );
  }

  IconData getIcon() {
    final lowerName = name.toLowerCase();
    final lowerCategory = category.toLowerCase();
    
    if (lowerName.contains('corte') || lowerCategory.contains('cabelo')) {
      return Icons.content_cut;
    } else if (lowerName.contains('barba') || lowerCategory.contains('barba')) {
      return Icons.face; // Or face_retouching_natural
    } else if (lowerName.contains('limpeza') || lowerName.contains('pele') || lowerCategory.contains('estética')) {
      return Icons.spa;
    } else if (lowerName.contains('pigmentação') || lowerName.contains('cor')) {
      return Icons.color_lens;
    } else if (lowerName.contains('sobrancelha')) {
      return Icons.remove_red_eye;
    } else if (lowerName.contains('hidratação')) {
      return Icons.water_drop;
    } else if (lowerCategory.contains('combo')) {
      return Icons.style;
    }
    return Icons.design_services;
  }
}

// lib/models/list_item.dart

import 'package:hive/hive.dart';

part 'list_item.g.dart'; // Adapter será gerado automaticamente

@HiveType(typeId: 1)
class ListItem extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  double quantity;

  @HiveField(3)
  String unit;

  @HiveField(4)
  bool bought;

  @HiveField(5)
  String? productDefinitionId;

  ListItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    this.bought = false,
    this.productDefinitionId,
  });

  /// Alias getter/setter para UI com checkbox
  bool get checked => bought;
  set checked(bool value) => bought = value;

  /// Conversão para map (ex: se precisares exportar em JSON)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'bought': bought,
      'productDefinitionId': productDefinitionId,
    };
  }

  /// Conversão de map para objeto (se precisares importar ou usar JSON)
  factory ListItem.fromMap(Map<String, dynamic> map) {
    return ListItem(
      id: map['id'],
      name: map['name'],
      quantity: (map['quantity'] as num).toDouble(),
      unit: map['unit'],
      bought: map['bought'] ?? false,
      productDefinitionId: map['productDefinitionId'],
    );
  }
}

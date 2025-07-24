import 'package:hive/hive.dart';

part 'storage_item.g.dart';

@HiveType(typeId: 3)
class StorageItem extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  double quantity;

  @HiveField(3)
  String unit;

  @HiveField(4)
  double? minQuantity;

  @HiveField(5)
  DateTime? expiryDate;

  @HiveField(6)
  String? category;

  @HiveField(7)
  double? idealQuantity;

  @HiveField(8)
  String? productDefinitionId;

  StorageItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    this.minQuantity,
    this.expiryDate,
    this.category,
    this.idealQuantity,
    this.productDefinitionId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'minQuantity': minQuantity,
      'expiryDate': expiryDate?.toIso8601String(),
      'category': category,
      'idealQuantity': idealQuantity,
      'productDefinitionId': productDefinitionId,
    };
  }

  factory StorageItem.fromMap(Map<String, dynamic> map) {
    return StorageItem(
      id: map['id'] as String,
      name: map['name'] as String,
      quantity: _toDouble(map['quantity']),
      unit: map['unit'] as String,
      minQuantity: map['minQuantity'] != null ? _toDouble(map['minQuantity']) : null,
      expiryDate: map['expiryDate'] != null ? DateTime.tryParse(map['expiryDate']) : null,
      category: map['category'] as String?,
      idealQuantity: map['idealQuantity'] != null ? _toDouble(map['idealQuantity']) : null,
      productDefinitionId: map['productDefinitionId'] as String?,
    );
  }

  static double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  StorageItem copyWith({
    String? id,
    String? name,
    double? quantity,
    String? unit,
    double? idealQuantity,
    double? minQuantity,
    String? category,
    DateTime? expiryDate,
    String? productDefinitionId,
  }) {
    return StorageItem(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      idealQuantity: idealQuantity ?? this.idealQuantity,
      minQuantity: minQuantity ?? this.minQuantity,
      category: category ?? this.category,
      expiryDate: expiryDate ?? this.expiryDate,
      productDefinitionId: productDefinitionId ?? this.productDefinitionId,
    );
  }
}

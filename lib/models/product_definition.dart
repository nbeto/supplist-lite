// lib/models/product_definition.dart

import 'package:hive/hive.dart';

part 'product_definition.g.dart';

@HiveType(typeId: 11)
class ProductDefinition {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String defaultUnit;

  @HiveField(3)
  final String? category;

  @HiveField(4)
  final double? dailyUsage;

  @HiveField(5)
  bool favorite; // <-- novo campo

  ProductDefinition({
    required this.id,
    required this.name,
    required this.defaultUnit,
    this.category,
    this.dailyUsage,
    this.favorite = false, // <-- valor por defeito
  });
}

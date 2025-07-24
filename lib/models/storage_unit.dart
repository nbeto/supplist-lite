// lib/models/storage_unit.dart

import 'package:hive/hive.dart';
import 'storage_item.dart';

part 'storage_unit.g.dart';

@HiveType(typeId: 4)
class StorageUnit extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final List<StorageItem> items;

  @HiveField(3)
  final double? idealQuantity;

  @HiveField(4)
  final double? minQuantity;

  @HiveField(5)
  bool favorite; // << NOVO CAMPO ADICIONADO

  StorageUnit({
    required this.id,
    required this.name,
    required this.items,
    this.idealQuantity,
    this.minQuantity,
    this.favorite = false, // valor por omissão
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'items': items.map((item) => item.toMap()).toList(),
      'idealQuantity': idealQuantity,
      'minQuantity': minQuantity,
      'favorite': favorite,
    };
  }

  factory StorageUnit.fromMap(Map<String, dynamic> map) {
    return StorageUnit(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      items: (map['items'] as List<dynamic>? ?? [])
          .map((e) => StorageItem.fromMap(e))
          .toList(),
      idealQuantity: map['idealQuantity']?.toDouble(),
      minQuantity: map['minQuantity']?.toDouble(),
      favorite: map['favorite'] ?? false,
    );
  }

  StorageUnit copyWith({
    String? id,
    String? name,
    List<StorageItem>? items,
    double? idealQuantity,
    double? minQuantity,
    bool? favorite,
  }) {
    return StorageUnit(
      id: id ?? this.id,
      name: name ?? this.name,
      items: items ?? this.items,
      idealQuantity: idealQuantity ?? this.idealQuantity,
      minQuantity: minQuantity ?? this.minQuantity,
      favorite: favorite ?? this.favorite,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StorageUnit &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          items == other.items &&
          idealQuantity == other.idealQuantity &&
          minQuantity == other.minQuantity &&
          favorite == other.favorite;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      items.hashCode ^
      idealQuantity.hashCode ^
      minQuantity.hashCode ^
      favorite.hashCode;
}

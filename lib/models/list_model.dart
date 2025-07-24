// lib/models/list_model.dart

import 'package:hive/hive.dart';
import 'list_item.dart';

part 'list_model.g.dart';

@HiveType(typeId: 2)
class ListModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  List<ListItem> items;

   @HiveField(3)
  bool favorite;

  ListModel({
    required this.id,
    required this.name,
    required this.items,
    this.favorite = false,
  });

  /// Adicionar item à lista
  void addItem(ListItem item) {
    items.add(item);
  }

  /// Remover item por ID
  void removeItem(String itemId) {
    items.removeWhere((item) => item.id == itemId);
  }

  /// Alternar estado "comprado"
  void toggleItemBought(String itemId) {
    final item = items.firstWhere((item) => item.id == itemId);
    item.bought = !item.bought;
  }

  /// Serializar para exportação/backup
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'items': items.map((item) => item.toMap()).toList(),
    };
  }

  /// Reconstruir de um mapa (útil para importação/exportação)
  factory ListModel.fromMap(Map<String, dynamic> map) {
    return ListModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      items: (map['items'] as List<dynamic>? ?? [])
          .map((e) => ListItem.fromMap(e))
          .toList(),
    );
  }

  /// Criar cópia com alterações
  ListModel copyWith({
    String? id,
    String? name,
    List<ListItem>? items,
  }) {
    return ListModel(
      id: id ?? this.id,
      name: name ?? this.name,
      items: items ?? this.items,
    );
  }

  /// Comparação por igualdade
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ListModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          items == other.items;

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ items.hashCode;
}

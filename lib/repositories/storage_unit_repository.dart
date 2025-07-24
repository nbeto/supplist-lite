import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../models/storage_unit.dart';
import '../models/storage_item.dart';

class StorageUnitRepository {
  final String _boxName = 'storage_units';
  final Uuid _uuid = const Uuid();

  Future<void> init() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox<StorageUnit>(_boxName);
    }
  }

  Future<List<StorageUnit>> getAllUnits() async {
    final box = Hive.box<StorageUnit>(_boxName);
    return box.values.toList();
  }

  /// Criar nova unidade de armazenamento
  Future<void> createUnit(String name, {bool favorite = false}) async {
    final box = Hive.box<StorageUnit>(_boxName);
    final unit = StorageUnit(
      id: _uuid.v4(),
      name: name,
      favorite: favorite, // <--- Passa o valor aqui
      items: [],
    );
    await box.put(unit.id, unit);
  }

  /// Remover unidade pelo ID
  Future<void> removeUnit(String id) async {
    final box = Hive.box<StorageUnit>(_boxName);
    await box.delete(id);
  }

  /// Renomear unidade existente
  Future<void> renameUnit(String id, String newName) async {
    final box = Hive.box<StorageUnit>(_boxName);
    final unit = box.get(id);
    if (unit != null) {
      final updated = StorageUnit(
        id: unit.id,
        name: newName,
        favorite: unit.favorite, // <-- Adiciona isto!
        items: unit.items,
      );
      await box.put(id, updated);
    }
  }

  /// Adicionar item a uma unidade
  Future<void> addItemToUnit(String unitId, StorageItem item) async {
    final box = Hive.box<StorageUnit>(_boxName);
    final unit = box.get(unitId);
    if (unit != null) {
      final updatedItems = [...unit.items, item];
      final updated = StorageUnit(
        id: unit.id,
        name: unit.name,
        favorite: unit.favorite, // <-- Adiciona isto!
        items: updatedItems,
      );
      await box.put(unitId, updated);
    }
  }

  /// Remover item da unidade pelo ID do item
  Future<void> removeItemFromUnit(String unitId, String itemId) async {
    final box = Hive.box<StorageUnit>(_boxName);
    final unit = box.get(unitId);
    if (unit != null) {
      final updatedItems = unit.items.where((item) => item.id != itemId).toList();
      final updated = StorageUnit(
        id: unit.id,
        name: unit.name,
        favorite: unit.favorite, // <-- Adiciona isto!
        items: updatedItems,
      );
      await box.put(unitId, updated);
    }
  }

  /// Atualizar um item existente dentro da unidade
  Future<void> updateItemInUnit(String unitId, StorageItem updatedItem) async {
    final box = Hive.box<StorageUnit>(_boxName);
    final unit = box.get(unitId);
    if (unit != null) {
      final updatedItems = unit.items.map((item) {
        return item.id == updatedItem.id ? updatedItem : item;
      }).toList();
      final updated = StorageUnit(
        id: unit.id,
        name: unit.name,
        favorite: unit.favorite, // <-- Adiciona isto!
        items: updatedItems,
      );
      await box.put(unitId, updated);
    }
  }

  /// Obter todos os items (de todas as unidades)
  Future<List<StorageItem>> getAllItems() async {
    final box = Hive.box<StorageUnit>(_boxName);
    return box.values.expand((unit) => unit.items).toList();
  }

  /// Obter uma unidade pelo ID
  Future<StorageUnit?> getUnitById(String id) async {
    final box = Hive.box<StorageUnit>(_boxName);
    return box.get(id);
  }

  /// Simulação de unidades favoritas
  Future<List<StorageUnit>> getFavoriteUnits() async {
    final units = await getAllUnits();
    return units.take(2).toList(); // apenas as primeiras como exemplo
  }

  Future<void> updateUnit(StorageUnit updatedUnit) async {
    final box = Hive.box<StorageUnit>(_boxName);
    await box.put(updatedUnit.id, updatedUnit);
  }
}

import 'package:flutter/foundation.dart';

import '../models/storage_unit.dart';
import '../models/storage_item.dart';
import '../repositories/storage_unit_repository.dart';
import '../services/product_definition_service.dart';

class StorageUnitService with ChangeNotifier {
  final StorageUnitRepository _repository;

  final ProductDefinitionService productService;

  StorageUnitService(this.productService) : _repository = StorageUnitRepository();

  List<StorageUnit> _units = [];

  List<StorageUnit> get allUnits => [..._units];

  Future<void> init() async {
    await _repository.init();
    _units = await _repository.getAllUnits();

    if (_units.isEmpty) {
      await createUnit('General Pantry', favorite: true);
      _units = await _repository.getAllUnits(); // Atualiza a lista após criar o armazém

      final pantry = _units.firstWhere((u) => u.name == 'General Pantry');
      final waterDefinition = productService.all.firstWhere((d) => d.name == 'Water');
      final breadDefinition = productService.all.firstWhere((d) => d.name == 'Bread');
      await addItemToUnit(pantry.id, StorageItem(
        id: 'water_default',
        name: 'Water',
        productDefinitionId: waterDefinition.id, // <-- associa à definição
        quantity: 1,
        unit: 'L',
        minQuantity: 1,
        idealQuantity: 6,
      ));
      await addItemToUnit(pantry.id, StorageItem(
        id: 'bread_default',
        name: 'Bread',
        productDefinitionId: breadDefinition.id, // <-- associa à definição
        quantity: 1,
        unit: 'unit',
        minQuantity: 1,
        idealQuantity: 6,
        expiryDate: DateTime.now().add(const Duration(days: 3)), // expira em 3 dias
      ));
      _units = await _repository.getAllUnits(); // Atualiza novamente após adicionar os itens

      await createUnit('Emergency Kit');
      await createUnit('Alcoholic Drinks');
      _units = await _repository.getAllUnits();
    }

    notifyListeners();
  }

  Future<void> createUnit(String name, {bool favorite = false}) async {
    await _repository.createUnit(name, favorite: favorite);
    _units = await _repository.getAllUnits();
    notifyListeners();
  }

  Future<void> deleteUnit(String id) async {
    await _repository.removeUnit(id);
    _units.removeWhere((unit) => unit.id == id);
    notifyListeners();
  }

  Future<void> renameUnit(String id, String newName) async {
    await _repository.renameUnit(id, newName);
    _units = await _repository.getAllUnits();
    notifyListeners();
  }

  StorageUnit? getUnitById(String id) {
    final index = _units.indexWhere((unit) => unit.id == id);
    return index != -1 ? _units[index] : null;
  }

  Future<void> addItemToUnit(String unitId, StorageItem item) async {
    await _repository.addItemToUnit(unitId, item);
    _units = await _repository.getAllUnits();
    notifyListeners();
  }

  Future<void> updateItemInUnit(String unitId, StorageItem item) async {
    await _repository.updateItemInUnit(unitId, item);
    _units = await _repository.getAllUnits();
    notifyListeners();
  }

  List<StorageUnit> getAllUnits() {
    return [..._units];
  }

  List<StorageItem> getAllItems() {
    return _units.expand((unit) => unit.items).toList();
  }

  List<StorageItem> getLowStockItems() {
    return _units
        .expand((unit) => unit.items)
        .where((item) =>
            item.minQuantity != null && item.quantity <= item.minQuantity!)
        .toList();
  }

  List<StorageItem> getExpiringItems({int daysThreshold = 7}) {
    final now = DateTime.now();
    final threshold = now.add(Duration(days: daysThreshold));

    return allUnits
        .expand((unit) => unit.items)
        .where((item) =>
            item.expiryDate != null &&
            item.expiryDate!.isAfter(now) &&
            item.expiryDate!.isBefore(threshold))
        .toList();
  }

  List<StorageUnit> getFavoriteUnits() {
    return _units.where((unit) => unit.favorite).toList();
  }

  Future<void> toggleFavoriteUnit(String unitId) async {
    final unitIndex = _units.indexWhere((u) => u.id == unitId);
    if (unitIndex == -1) return;

    final unit = _units[unitIndex];
    unit.favorite = !unit.favorite;
    await unit.save(); // HiveObject permite guardar diretamente
    notifyListeners();
  }

  Future<void> updateItemQuantity(String unitId, String itemId, double change) async {
    final unit = _units.firstWhere((u) => u.id == unitId, orElse: () => throw Exception('Armazém não encontrado'));
    final itemIndex = unit.items.indexWhere((i) => i.id == itemId);
    if (itemIndex == -1) throw Exception('Item não encontrado');

    final item = unit.items[itemIndex];
    final newQuantity = item.quantity + change;

    if (newQuantity < 0) throw Exception('A quantidade não pode ser negativa');

    final updatedItem = item.copyWith(quantity: newQuantity);
    final updatedItems = [...unit.items];
    updatedItems[itemIndex] = updatedItem;

    final updatedUnit = unit.copyWith(items: updatedItems);
    await _repository.updateUnit(updatedUnit);

    _units = await _repository.getAllUnits();
    notifyListeners();
  }

  Future<void> removeItemFromUnit(String unitId, String itemId) async {
    final unit = _units.firstWhere((u) => u.id == unitId, orElse: () => throw Exception('Armazém não encontrado'));
    final updatedItems = unit.items.where((item) => item.id != itemId).toList();

    final updatedUnit = unit.copyWith(items: updatedItems);
    await _repository.updateUnit(updatedUnit);

    _units = await _repository.getAllUnits();
    notifyListeners();
  }
}

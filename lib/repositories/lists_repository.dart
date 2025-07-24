import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../models/list_model.dart';
import '../models/list_item.dart';

class ListsRepository {
  final String _boxName = 'shopping_lists';
  final Uuid _uuid = const Uuid();

  Future<void> init() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox<ListModel>(_boxName);
    }
  }

  Future<List<ListModel>> getAllLists() async {
    final box = Hive.box<ListModel>(_boxName);
    return box.values.toList();
  }

  Future<void> addList(String name, {bool favorite = false}) async {
    final box = Hive.box<ListModel>(_boxName);
    final newList = ListModel(
      id: _uuid.v4(),
      name: name,
      items: [],
      favorite: favorite,
    );
    await box.put(newList.id, newList);
  }

  Future<void> deleteList(String id) async {
    final box = Hive.box<ListModel>(_boxName);
    await box.delete(id);
  }

  Future<void> addItemToList(String listId, ListItem item) async {
    final box = Hive.box<ListModel>(_boxName);
    final list = box.get(listId);
    if (list != null) {
      list.items.add(item);
      await list.save();
    }
  }

  Future<void> removeItemFromList(String listId, String itemId) async {
    final box = Hive.box<ListModel>(_boxName);
    final list = box.get(listId);
    if (list != null) {
      list.items.removeWhere((item) => item.id == itemId);
      await list.save();
    }
  }

  Future<void> toggleItemBought(String listId, String itemId) async {
    final box = Hive.box<ListModel>(_boxName);
    final list = box.get(listId);
    if (list != null) {
      final itemIndex = list.items.indexWhere((item) => item.id == itemId);
      if (itemIndex != -1) {
        final item = list.items[itemIndex];
        item.bought = !item.bought;
        await list.save();
      }
    }
  }

  Future<void> updateItemStatus(String listId, String itemId, bool bought) async {
    final box = Hive.box<ListModel>(_boxName);
    final list = box.get(listId);
    if (list != null) {
      final updatedItems = list.items.map((item) {
        if (item.id == itemId) {
          return ListItem(
            id: item.id,
            name: item.name,
            quantity: item.quantity,
            unit: item.unit,
            bought: bought,
          );
        }
        return item;
      }).toList();

      final updatedList = ListModel(
        id: list.id,
        name: list.name,
        items: updatedItems,
        favorite: list.favorite,
      );

      await box.put(list.id, updatedList);
    }
  }

  Future<ListItem?> getItemById(String listId, String itemId) async {
    final box = Hive.box<ListModel>(_boxName);
    final list = box.get(listId);
    try {
      return list?.items.firstWhere((item) => item.id == itemId);
    } catch (_) {
      return null;
    }
  }

  Future<ListModel?> getListById(String listId) async {
    final box = Hive.box<ListModel>(_boxName);
    return box.get(listId);
  }

  /// Atualiza a lista inteira (usado por exemplo para atualizar campo favorito)
  Future<void> updateList(ListModel list) async {
    final box = Hive.box<ListModel>(_boxName);
    await box.put(list.id, list);
  }
}

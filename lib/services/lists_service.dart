import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/list_model.dart';
import '../models/list_item.dart';
import '../repositories/lists_repository.dart';

class ListsService extends ChangeNotifier {
  final ListsRepository _repository = ListsRepository();
  final Uuid _uuid = const Uuid();
  List<ListModel> _lists = [];

  List<ListModel> get allLists => _lists;

  Future<void> init() async {
    await _repository.init();
    _lists = await _repository.getAllLists();

    if (_lists.isEmpty) {
      await createList('Weekly Shopping', favorite: true);
      await createList('Monthly Shopping');
      await createList('Party List');
      _lists = await _repository.getAllLists();
    }

    notifyListeners();
  }

  Future<void> createList(String name, {bool favorite = false}) async {
    await _repository.addList(name, favorite: favorite);
    _lists = await _repository.getAllLists();
    notifyListeners();
  }

  Future<void> removeList(String listId) async {
    await _repository.deleteList(listId);
    _lists.removeWhere((l) => l.id == listId);
    notifyListeners();
  }

  Future<void> addItemToList({
    required String listId,
    required String name,
    required double quantity,
    required String unit,
  }) async {
    final item = ListItem(
      id: _uuid.v4(),
      name: name,
      quantity: quantity,
      unit: unit,
      bought: false,
    );
    await _repository.addItemToList(listId, item);
    _lists = await _repository.getAllLists();
    notifyListeners();
  }

  Future<void> toggleItemBought(String listId, String itemId) async {
    await _repository.toggleItemBought(listId, itemId);
    _lists = await _repository.getAllLists();
    notifyListeners();
  }

  Future<void> toggleListFavorite(String listId) async {
    final list = _lists.firstWhere(
      (l) => l.id == listId,
      orElse: () => throw Exception('Lista não encontrada'),
    );

    list.favorite = !list.favorite;
    await _repository.updateList(list);

    _lists = await _repository.getAllLists();
    notifyListeners();
  }

  Future<void> removeItem(String listId, String itemId) async {
    await _repository.removeItemFromList(listId, itemId);
    _lists = await _repository.getAllLists();
    notifyListeners();
  }

  List<ListItem> getItems(String listId) {
    return _lists.firstWhere((l) => l.id == listId).items;
  }

  ListModel? getListById(String listId) {
    try {
      return _lists.firstWhere((l) => l.id == listId);
    } catch (_) {
      return null;
    }
  }

  /// Agora apenas listas favoritas
  List<ListModel> getFavoriteLists() {
    return _lists.where((list) => list.favorite).toList();
  }

  Future<void> updateItemStatus({
    required String listId,
    required String itemId,
    required bool bought,
  }) async {
    await _repository.updateItemStatus(listId, itemId, bought);
    _lists = await _repository.getAllLists();
    notifyListeners();
  }

  Future<void> deleteList(String listId) async {
    await _repository.deleteList(listId);
    _lists.removeWhere((list) => list.id == listId);
    notifyListeners();
  }

  Future<void> addList(String name, {bool favorite = false}) async {
    await _repository.addList(name, favorite: favorite);
    _lists = await _repository.getAllLists();
    notifyListeners();
  }
}

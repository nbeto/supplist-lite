// lib/services/product_definition_service.dart

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../models/product_definition.dart';
import '../repositories/product_definition_repository.dart';

class ProductDefinitionService extends ChangeNotifier {
  final ProductDefinitionRepository _repository;

  List<ProductDefinition> _definitions = [];
  List<ProductDefinition> get all => _definitions;

  String? categoriaSelecionada;
  final categoriaController = TextEditingController();

  ProductDefinitionService(this._repository);

  Future<void> init() async {
    await _repository.init();
    _definitions = await _repository.getAll();

    if (_definitions.isEmpty) {
      // Produtos e categorias em inglês, conforme as predefinidas nas preferências
      await createDefinition(name: 'Rice', defaultUnit: 'kg', category: 'Cereals', dailyUsage: 1);
      await createDefinition(name: 'Milk', defaultUnit: 'L', category: 'Drinks', dailyUsage: 1);
      await createDefinition(name: 'Water', defaultUnit: 'L', category: 'Drinks', dailyUsage: 1, favorite: true); // favorito
      await createDefinition(name: 'Bread', defaultUnit: 'unit', category: 'Bakery', dailyUsage: 1, favorite: true); // favorito
      await createDefinition(name: 'Toilet Paper', defaultUnit: 'unit', category: 'Hygiene', dailyUsage: 1);
      await refresh();
    }

    notifyListeners();
  }

  Future<void> addDefinition(ProductDefinition def) async {
    await _repository.update(def);
    await refresh();
  }

  Future<void> createDefinition({
    required String name,
    String defaultUnit = 'un',
    double? dailyUsage,
    String? category,
    bool favorite = false, // novo parâmetro
  }) async {
    await _repository.create(
      name,
      defaultUnit: defaultUnit,
      dailyUsage: dailyUsage,
      category: category,
      favorite: favorite, // passa o favorito
    );
    await refresh();
  }

  Future<void> updateDefinition(ProductDefinition def) async {
    await _repository.update(def);
    await refresh();
  }

  Future<void> deleteDefinition(String id) async {
    await _repository.delete(id);
    await refresh();
  }

  Future<void> refresh() async {
    _definitions = await _repository.getAll();
    notifyListeners();
  }

  ProductDefinition? getById(String id) {
    return _definitions.firstWhereOrNull((d) => d.id == id);
  }

  List<ProductDefinition> searchByName(String query) {
    return _definitions
        .where((d) => d.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  List<String> getAllNames() {
    return _definitions.map((d) => d.name).toList();
  }

  ProductDefinition? getByName(String name) {
    try {
      return _definitions.firstWhere((d) => d.name.toLowerCase() == name.toLowerCase());
    } catch (_) {
      return null;
    }
  }

  Future<void> toggleFavorite(String id) async {
    final index = _definitions.indexWhere((d) => d.id == id);
    if (index != -1) {
      _definitions[index].favorite = !_definitions[index].favorite;
      await _repository.update(_definitions[index]); // <-- grava no storage!
      await refresh(); // <-- lê novamente do storage para garantir consistência
      notifyListeners();
    }
  }
}
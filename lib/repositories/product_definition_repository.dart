// lib/repositories/product_definition_repository.dart

import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../models/product_definition.dart';

class ProductDefinitionRepository {
  final String _boxName = 'product_definitions';
  final Uuid _uuid = const Uuid();

  Future<void> init() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox<ProductDefinition>(_boxName);
    }
  }

  Future<List<ProductDefinition>> getAll() async {
    final box = Hive.box<ProductDefinition>(_boxName);
    return box.values.toList();
  }

  Future<ProductDefinition?> getById(String id) async {
    final box = Hive.box<ProductDefinition>(_boxName);
    return box.get(id);
  }

  Future<void> create(
    String name, {
    String defaultUnit = 'un',
    double? dailyUsage,
    String? category,
    bool favorite = false, // <-- Adiciona este parâmetro
  }) async {
    final box = Hive.box<ProductDefinition>(_boxName);
    final product = ProductDefinition(
      id: _uuid.v4(),
      name: name,
      defaultUnit: defaultUnit,
      dailyUsage: dailyUsage,
      category: category,
      favorite: favorite, // <-- Passa para o modelo
    );
    await box.put(product.id, product);
  }

  Future<void> update(ProductDefinition updatedProduct) async {
    final box = Hive.box<ProductDefinition>(_boxName);
    await box.put(updatedProduct.id, updatedProduct);
  }

  Future<void> delete(String id) async {
    final box = Hive.box<ProductDefinition>(_boxName);
    await box.delete(id);
  }

  Future<List<ProductDefinition>> searchByName(String query) async {
    final box = Hive.box<ProductDefinition>(_boxName);
    return box.values
        .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}

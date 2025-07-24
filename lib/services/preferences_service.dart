import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class PreferencesService extends ChangeNotifier {
  static const _boxName = 'preferencesBox';
  static const _categoriesKey = 'categories';
  static const _unitsKey = 'units';

  List<String> _categories = [
    'Cereals', 'Drinks', 'Bakery', 'Hygiene', 'Cleaning', 'Fresh', 'Frozen', 'Grocery', 'Pasta', 'Canned'
  ];
  List<String> _units = ['unit', 'kg', 'g', 'L', 'ml', 'pack', 'box'];

  List<String> get categories => _categories;
  List<String> get units => _units;

  String? _language = 'en';
  String? get language => _language; // 'en' ou 'pt'

  Future<void> init() async {
    final box = await Hive.openBox(_boxName);
    _categories = List<String>.from(box.get(_categoriesKey, defaultValue: _categories));
    _units = List<String>.from(box.get(_unitsKey, defaultValue: _units));
    _language = box.get('language', defaultValue: 'en');
    notifyListeners();
  }

  Future<void> addCategory(String category) async {
    if (!_categories.contains(category)) {
      _categories.add(category);
      await _save();
    }
  }

  Future<void> removeCategory(String category) async {
    _categories.remove(category);
    await _save();
  }

  Future<void> addUnit(String unit) async {
    if (!_units.contains(unit)) {
      _units.add(unit);
      await _save();
    }
  }

  Future<void> removeUnit(String unit) async {
    _units.remove(unit);
    await _save();
  }

  Future<void> setLanguage(String lang) async {
    _language = lang;
    final box = await Hive.openBox(_boxName);
    await box.put('language', lang);
    notifyListeners();
  }

  Future<void> _save() async {
    final box = await Hive.openBox(_boxName);
    await box.put(_categoriesKey, _categories);
    await box.put(_unitsKey, _units);
    notifyListeners();
  }
}

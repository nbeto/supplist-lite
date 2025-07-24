import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:dropdown_search/dropdown_search.dart';

import '../models/storage_item.dart';
import '../models/storage_unit.dart';
import '../services/storage_unit_service.dart';
import '../services/product_definition_service.dart';
import '../l10n/gen_l10n/app_localizations.dart';

class StorageUnitDetailScreen extends StatelessWidget {
  final String unitId;

  const StorageUnitDetailScreen({super.key, required this.unitId});

  Future<double?> _showQuantityDialog(BuildContext context, String title) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();

    return showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(hintText: l10n.quantityHint),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel)),
          TextButton(
              onPressed: () {
                final amount = double.tryParse(controller.text.trim());
                Navigator.pop(ctx, amount);
              },
              child: Text(l10n.confirm)),
        ],
      ),
    );
  }

  Future<bool> _confirmDeletion(BuildContext context, String itemName) async {
    final l10n = AppLocalizations.of(context)!;
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(l10n.deleteItemTitle),
            content: Text(l10n.deleteItemConfirm(itemName)),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)),
              TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.delete)),
            ],
          ),
        ) ??
        false;
  }

  void _showAddItemDialog(BuildContext context, StorageUnit unit) {
    final l10n = AppLocalizations.of(context)!;
    String? selectedProductName;
    String? unidadeSelecionada;
    String? categoriaSelecionada;
    final quantityController = TextEditingController();
    final idealQuantityController = TextEditingController();
    final minQuantityController = TextEditingController();
    DateTime? selectedExpiryDate;

    final productService = context.read<ProductDefinitionService>();
    final alreadyAddedNames = unit.items.map((item) => item.name).toSet();
    final availableProductNames = productService.getAllNames()
        .where((name) => !alreadyAddedNames.contains(name))
        .toList();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.addItem),
        content: StatefulBuilder(
          builder: (context, setState) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownSearch<String>(
                  items: availableProductNames, // <-- só mostra os produtos ainda não adicionados
                  popupProps: const PopupProps.menu(showSearchBox: true),
                  dropdownDecoratorProps: DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(labelText: l10n.selectItem),
                  ),
                  onChanged: (selected) {
                    setState(() {
                      selectedProductName = selected;
                      final def = productService.getByName(selected ?? '');
                      if (def != null) {
                        unidadeSelecionada = def.defaultUnit;
                        categoriaSelecionada = def.category ?? '';
                        if (def.dailyUsage != null) {
                          idealQuantityController.text = (def.dailyUsage! * 7).toStringAsFixed(0);
                          minQuantityController.text = (def.dailyUsage! * 2).toStringAsFixed(0);
                        }
                      }
                    });
                  },
                ),
                TextField(
                  controller: quantityController,
                  decoration: InputDecoration(labelText: l10n.currentQuantity),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: idealQuantityController,
                  decoration: InputDecoration(labelText: l10n.idealQuantity),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: minQuantityController,
                  decoration: InputDecoration(labelText: l10n.minQuantity),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text('${l10n.expiryDate}: '),
                    TextButton(
                      child: Text(
                        selectedExpiryDate != null
                            ? '${selectedExpiryDate!.day}/${selectedExpiryDate!.month}/${selectedExpiryDate!.year}'
                            : l10n.select,
                      ),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() {
                            selectedExpiryDate = picked;
                          });
                        }
                      },
                    ),
                  ],
                ),
                // UNIDADE E CATEGORIA NO FIM
                const SizedBox(height: 8),
                Text('${l10n.unit}: ${unidadeSelecionada ?? ''}'),
                Text('${l10n.category}: ${categoriaSelecionada ?? ''}'),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = selectedProductName ?? '';
              final quantity = double.tryParse(quantityController.text.trim());
              final ideal = double.tryParse(idealQuantityController.text.trim());
              final min = double.tryParse(minQuantityController.text.trim());

              if (name.isEmpty || quantity == null) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  SnackBar(content: Text(l10n.selectItemAndQuantity)),
                );
                return;
              }

              final def = productService.getByName(name);
              final item = StorageItem(
                id: const Uuid().v4(),
                name: name,
                quantity: quantity,
                unit: unidadeSelecionada ?? '',
                idealQuantity: ideal,
                minQuantity: min,
                category: categoriaSelecionada,
                expiryDate: selectedExpiryDate,
                productDefinitionId: def?.id,
              );

              await context.read<StorageUnitService>().addItemToUnit(unit.id, item);
              Navigator.pop(dialogContext);
            },
            child: Text(l10n.add),
          ),
        ],
      ),
    );
  }

  void _showEditItemDialog(BuildContext context, StorageUnit unit, StorageItem item) {
    final l10n = AppLocalizations.of(context)!;
    String selectedProductName = item.name;
    String unidadeSelecionada = item.unit;
    String categoriaSelecionada = item.category ?? '';
    final quantityController = TextEditingController(text: item.quantity.toString());
    final idealQuantityController = TextEditingController(text: item.idealQuantity?.toString() ?? '');
    final minQuantityController = TextEditingController(text: item.minQuantity?.toString() ?? '');
    DateTime? selectedExpiryDate = item.expiryDate;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.editProduct),
        content: StatefulBuilder(
          builder: (context, setState) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(selectedProductName, style: const TextStyle(fontWeight: FontWeight.bold)),
                TextField(
                  controller: quantityController,
                  decoration: InputDecoration(labelText: l10n.currentQuantity),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: idealQuantityController,
                  decoration: InputDecoration(labelText: l10n.idealQuantity),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: minQuantityController,
                  decoration: InputDecoration(labelText: l10n.minQuantity),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text('${l10n.expiryDate}: '),
                    TextButton(
                      child: Text(
                        selectedExpiryDate != null
                            ? '${selectedExpiryDate!.day}/${selectedExpiryDate!.month}/${selectedExpiryDate!.year}'
                            : l10n.select,
                      ),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedExpiryDate ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() {
                            selectedExpiryDate = picked;
                          });
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('${l10n.unit}: $unidadeSelecionada'),
                Text('${l10n.category}: $categoriaSelecionada'),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              final quantity = double.tryParse(quantityController.text.trim());
              final ideal = double.tryParse(idealQuantityController.text.trim());
              final min = double.tryParse(minQuantityController.text.trim());

              if (quantity == null) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  SnackBar(content: Text(l10n.selectItemAndQuantity)),
                );
                return;
              }

              final updatedItem = item.copyWith(
                quantity: quantity,
                idealQuantity: ideal,
                minQuantity: min,
                expiryDate: selectedExpiryDate,
              );

              await context.read<StorageUnitService>().updateItemInUnit(unit.id, updatedItem);
              Navigator.pop(dialogContext);
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final unit = context.watch<StorageUnitService>().getUnitById(unitId);

    if (unit == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.unitNotFound)),
        body: Center(child: Text(l10n.unitLoadError)),
      );
    }

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.only(top: 16, left: 8, right: 8, bottom: 80),
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    '${l10n.storage} > ${unit.name}',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
          if (unit.items.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 32),
              child: Center(child: Text(l10n.noItemsInStorage)),
            )
          else
            ...unit.items.map((item) {
              final isLowStock = item.minQuantity != null && item.quantity <= item.minQuantity!;

              return ListTile(
                leading: Icon(
                  isLowStock ? Icons.warning : Icons.check_circle,
                  color: isLowStock ? Colors.red : Colors.green,
                ),
                title: Text(item.name),
                subtitle: Text(
                  '${l10n.quantityLabel(item.quantity)}'
                  '${item.idealQuantity != null ? ' | ${l10n.idealLabel(item.idealQuantity!)}' : ''}'
                  '${item.minQuantity != null ? ' | ${l10n.minLabel(item.minQuantity!)}' : ''}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      tooltip: l10n.consumeOne,
                      onPressed: () async {
                        await context.read<StorageUnitService>().updateItemQuantity(unit.id, item.id, -1);
                      },
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) async {
                        final service = context.read<StorageUnitService>();

                        if (value == 'quickRemove') {
                          await service.updateItemQuantity(unit.id, item.id, -1);
                        } else if (value == 'add') {
                          final amount = await _showQuantityDialog(context, l10n.addQuantity);
                          if (amount != null) {
                            await service.updateItemQuantity(unit.id, item.id, amount);
                          }
                        } else if (value == 'remove') {
                          final amount = await _showQuantityDialog(context, l10n.removeQuantity);
                          if (amount != null) {
                            await service.updateItemQuantity(unit.id, item.id, -amount);
                          }
                        } else if (value == 'edit') {
                          _showEditItemDialog(context, unit, item);
                        } else if (value == 'delete') {
                          final confirmed = await _confirmDeletion(context, item.name);
                          if (confirmed) {
                            await service.removeItemFromUnit(unit.id, item.id);
                          }
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(value: 'quickRemove', child: Text(l10n.consumeOne)),
                        PopupMenuItem(value: 'add', child: Text(l10n.addQuantity)),
                        PopupMenuItem(value: 'remove', child: Text(l10n.removeQuantity)),
                        PopupMenuItem(value: 'edit', child: Text(l10n.editProduct)),
                        PopupMenuItem(value: 'delete', child: Text(l10n.deleteProduct)),
                      ],
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddItemDialog(context, unit),
        icon: const Icon(Icons.add),
        label: Text(l10n.addItem),
      ),
    );
  }
}

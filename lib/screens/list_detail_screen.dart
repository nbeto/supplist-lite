import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/lists_service.dart';
import '../services/product_definition_service.dart';
import '../models/product_definition.dart';
import '../l10n/gen_l10n/app_localizations.dart';

class ListDetailScreen extends StatelessWidget {
  final String listId;

  const ListDetailScreen({super.key, required this.listId});

  void _showAddItemDialog(BuildContext context, String listId) {
    final l10n = AppLocalizations.of(context)!;
    final productService = context.read<ProductDefinitionService>();
    final list = context.read<ListsService>().getListById(listId);

    // Filtra produtos já adicionados
    final alreadyAddedNames = list?.items.map((item) => item.name).toSet() ?? {};
    final availableProducts = productService.all
        .where((prod) => !alreadyAddedNames.contains(prod.name))
        .toList();

    ProductDefinition? selectedProduct;
    final quantityController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.newItem),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<ProductDefinition>(
              decoration: InputDecoration(labelText: l10n.product),
              items: availableProducts
                  .map((prod) => DropdownMenuItem(
                        value: prod,
                        child: Text(prod.name),
                      ))
                  .toList(),
              onChanged: (value) {
                selectedProduct = value;
              },
            ),
            const SizedBox(height: 8),
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(hintText: l10n.quantityHint),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              final quantity = double.tryParse(quantityController.text.trim()) ?? 1.0;
              if (selectedProduct != null) {
                context.read<ListsService>().addItemToList(
                      listId: listId,
                      name: selectedProduct!.name,
                      quantity: quantity,
                      unit: selectedProduct!.defaultUnit,
                    );
                Navigator.of(dialogContext).pop();
              }
            },
            child: Text(l10n.add),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteItem(
      BuildContext context, String listId, String itemName, String itemId) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteItemTitle),
        content: Text(l10n.deleteItemConfirm(itemName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      context.read<ListsService>().removeItem(listId, itemId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final list = context.watch<ListsService>().getListById(listId);

    if (list == null) {
      return Scaffold(
        body: Center(child: Text(l10n.listNotFound)),
      );
    }

    final unboughtItems = list.items.where((i) => !i.bought).toList();
    final boughtItems = list.items.where((i) => i.bought).toList();
    final sortedItems = [...unboughtItems, ...boughtItems];

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.only(top: 16, left: 8, right: 8, bottom: 80),
        children: [
          // Header: botão de voltar + título hierárquico centrado
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    '${l10n.lists} > ${list.name}',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
          if (sortedItems.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 32),
              child: Center(child: Text(l10n.noItemsInList)),
            )
          else
            ...sortedItems.map((item) {
              final isBought = item.bought;
              return ListTile(
                leading: Checkbox(
                  value: isBought,
                  onChanged: (_) {
                    context.read<ListsService>().toggleItemBought(list.id, item.id);
                  },
                ),
                title: Text(
                  isBought ? '✔️ ${item.name}' : item.name,
                  style: isBought
                      ? const TextStyle(decoration: TextDecoration.lineThrough)
                      : null,
                ),
                subtitle: Text(
                  '${item.quantity} ${item.unit}',
                  style: isBought
                      ? const TextStyle(decoration: TextDecoration.lineThrough)
                      : null,
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'delete') {
                      _confirmDeleteItem(context, list.id, item.name, item.id);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem<String>(
                      value: 'delete',
                      child: Text(l10n.deleteItemMenu),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddItemDialog(context, list.id),
        icon: const Icon(Icons.add),
        label: Text(l10n.addItem),
      ),
    );
  }
}

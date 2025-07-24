// lib/screens/storage_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/storage_unit.dart';
import '../services/storage_unit_service.dart';
import '../screens/storage_unit_detail_screen.dart';
import '../l10n/gen_l10n/app_localizations.dart';

class StorageScreen extends StatelessWidget {
  const StorageScreen({super.key});

  void _addStorageUnit(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final TextEditingController controller = TextEditingController();
    final storageService = context.read<StorageUnitService>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.newStorageTitle),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: l10n.newStorageHint,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            child: Text(l10n.cancel),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: Text(l10n.add),
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                await storageService.createUnit(name);
              }
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _openStorage(BuildContext context, StorageUnit unit) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StorageUnitDetailScreen(unitId: unit.id),
      ),
    );
  }

  Future<void> _confirmAndDeleteUnit(BuildContext context, StorageUnit unit) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(l10n.deleteStorageTitle),
        content: Text(l10n.deleteStorageConfirm(unit.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await context.read<StorageUnitService>().deleteUnit(unit.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final storageUnits = context.watch<StorageUnitService>().allUnits;

    // Ordena favoritos primeiro, depois por nome
    final sortedUnits = [...storageUnits]
      ..sort((a, b) {
        if (a.favorite == b.favorite) {
          return a.name.compareTo(b.name);
        }
        return b.favorite ? 1 : -1;
      });

    return Scaffold(
      body: sortedUnits.isEmpty
          ? Padding(
              padding: const EdgeInsets.only(top: 32),
              child: Column(
                children: [
                  // Título da página no corpo
                  Text(
                    l10n.storage,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      l10n.noStorageUnits,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.only(top: 16, left: 8, right: 8, bottom: 80),
              itemCount: sortedUnits.length + 1,
              separatorBuilder: (context, index) => index == 0 ? const SizedBox() : const Divider(),
              itemBuilder: (context, index) {
                if (index == 0) {
                  // Título da página como primeiro item da lista
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Center(
                      child: Text(
                        l10n.storage,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                }
                final unit = sortedUnits[index - 1];
                return ListTile(
                  leading: const Icon(Icons.inventory_2),
                  title: Text(unit.name),
                  subtitle: Text(l10n.itemsCount(unit.items.length)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          unit.favorite ? Icons.star : Icons.star_border,
                          color: unit.favorite ? Colors.amber : null,
                        ),
                        onPressed: () {
                          context.read<StorageUnitService>().toggleFavoriteUnit(unit.id);
                        },
                      ),
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'delete') {
                            _confirmAndDeleteUnit(context, unit);
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem<String>(
                            value: 'delete',
                            child: Text(l10n.deleteStorageMenu),
                          ),
                        ],
                      ),
                    ],
                  ),
                  onTap: () => _openStorage(context, unit),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addStorageUnit(context),
        icon: const Icon(Icons.add),
        label: Text(l10n.newStorage),
      ),
    );
  }
}

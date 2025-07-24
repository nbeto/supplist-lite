// lib/screens/product_management_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/product_definition.dart';
import '../services/product_definition_service.dart';
import '../services/preferences_service.dart';
import '../l10n/gen_l10n/app_localizations.dart';

class ProductManagementScreen extends StatelessWidget {
  const ProductManagementScreen({super.key});

  void _showProductForm({
    required BuildContext context,
    ProductDefinition? existing,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final prefs = Provider.of<PreferencesService>(context, listen: false);
    final categoriasPadrao = List<String>.from(prefs.categories);
    final unidadesPadrao = prefs.units;

    // Valor inicial é sempre uma unidade válida
    var unidadeSelecionada = unidadesPadrao.contains(existing?.defaultUnit)
        ? existing?.defaultUnit ?? unidadesPadrao.first
        : unidadesPadrao.first;

    final nameController = TextEditingController(text: existing?.name ?? '');
    final usageController = TextEditingController(text: existing?.dailyUsage?.toString() ?? '');
    final categoriaController = TextEditingController();
    String? categoriaSelecionada = existing?.category ?? categoriasPadrao.first;

    final isEdit = existing != null;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEdit ? l10n.editProduct : l10n.newProduct),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: l10n.productName),
              ),
              DropdownButtonFormField<String>(
                value: unidadeSelecionada,
                decoration: InputDecoration(labelText: l10n.unitDefault),
                items: unidadesPadrao
                    .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                    .toList(),
                onChanged: (value) {
                  unidadeSelecionada = value ?? unidadesPadrao.first;
                },
              ),
              DropdownButtonFormField<String>(
                value: categoriaSelecionada,
                decoration: InputDecoration(labelText: l10n.category),
                items: [
                  ...categoriasPadrao.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))),
                  DropdownMenuItem(value: 'nova', child: Text(l10n.addCategory)),
                ],
                onChanged: (value) async {
                  if (value == 'nova') {
                    final novaCategoria = await showDialog<String>(
                      context: context,
                      builder: (ctx2) => AlertDialog(
                        title: Text(l10n.newCategory),
                        content: TextField(
                          controller: categoriaController,
                          decoration: InputDecoration(labelText: l10n.categoryName),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx2),
                            child: Text(l10n.cancel),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx2, categoriaController.text.trim()),
                            child: Text(l10n.add),
                          ),
                        ],
                      ),
                    );
                    if (novaCategoria != null && novaCategoria.isNotEmpty) {
                      if (!categoriasPadrao.contains(novaCategoria)) {
                        prefs.addCategory(novaCategoria);
                        categoriasPadrao.add(novaCategoria);
                      }
                      categoriaSelecionada = novaCategoria;
                    }
                  } else {
                    categoriaSelecionada = value;
                  }
                },
              ),
              TextField(
                controller: usageController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: l10n.dailyUsageOptional),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: Text(l10n.cancel),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          ElevatedButton(
            child: Text(l10n.save),
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) return;

              final def = ProductDefinition(
                id: existing?.id ?? const Uuid().v4(),
                name: name,
                defaultUnit: unidadeSelecionada,
                category: categoriaSelecionada,
                dailyUsage: double.tryParse(usageController.text.trim()),
              );

              final service = context.read<ProductDefinitionService>();
              if (isEdit) {
                await service.updateDefinition(def);
              } else {
                await service.addDefinition(def);
              }

              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, ProductDefinition def) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(l10n.deleteProduct),
            content: Text(l10n.confirmDeleteProduct(def.name)),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(l10n.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(l10n.delete),
              ),
            ],
          ),
        ) ??
        false;

    if (confirmed) {
      await context.read<ProductDefinitionService>().deleteDefinition(def.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final definitions = List<ProductDefinition>.from(
      context.watch<ProductDefinitionService>().all,
    );

    // Ordena favoritos para o topo
    definitions.sort((a, b) {
      if (a.favorite == b.favorite) {
        return a.name.compareTo(b.name); // opcional: ordena alfabeticamente dentro do grupo
      }
      return b.favorite ? 1 : -1; // favoritos primeiro
    });

    return Scaffold(
      body: definitions.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    l10n.products,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Text(l10n.noProducts),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.only(top: 16, left: 8, right: 8, bottom: 80),
              itemCount: definitions.length + 1,
              separatorBuilder: (context, index) => index == 0 ? const SizedBox() : const Divider(),
              itemBuilder: (context, index) {
                if (index == 0) {
                  // Título da página como primeiro item da lista
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Center(
                      child: Text(
                        l10n.products,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                }
                final def = definitions[index - 1];
                return ListTile(
                  title: Text(def.name),
                  subtitle: Text(
                    '${def.defaultUnit} ${def.category != null ? '| ${def.category}' : ''}'
                    '${def.dailyUsage != null ? ' | ${l10n.dailyUsage}: ${def.dailyUsage}' : ''}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          def.favorite ? Icons.star : Icons.star_border,
                          color: def.favorite ? Colors.amber : null,
                        ),
                        tooltip: l10n.favorite,
                        onPressed: () {
                          context.read<ProductDefinitionService>().toggleFavorite(def.id);
                        },
                      ),
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            _showProductForm(context: context, existing: def);
                          } else if (value == 'delete') {
                            _confirmDelete(context, def);
                          }
                        },
                        itemBuilder: (ctx) => [
                          PopupMenuItem(value: 'edit', child: Text(l10n.edit)),
                          PopupMenuItem(value: 'delete', child: Text(l10n.delete)),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showProductForm(context: context),
        icon: const Icon(Icons.add),
        label: Text(l10n.addProduct),
      ),
    );
  }
}

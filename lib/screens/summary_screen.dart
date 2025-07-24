import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/storage_unit_service.dart';
import '../services/product_utils.dart';
import '../services/product_definition_service.dart';
import '../l10n/gen_l10n/app_localizations.dart';

class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final service = context.watch<StorageUnitService>();
    final productService = context.read<ProductDefinitionService>();
    final allItems = service.getAllItems();
    final allUnits = service.allUnits;

    final lowStockItems = ProductUtils.filterLowStock(allItems);
    final expiringSoonItems = ProductUtils.filterExpiringSoon(allItems, days: 7);

    // Mapeia os IDs dos produtos para os nomes dos armazéns
    final Map<String, String> itemToUnitMap = {};
    for (final unit in allUnits) {
      for (final item in unit.items) {
        itemToUnitMap[item.id] = unit.name;
      }
    }

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Título da página no corpo
          Center(
            child: Text(
              l10n.alerts,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 24),

          Text(
            l10n.lowStock,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          if (lowStockItems.isEmpty)
            ListTile(title: Text(l10n.allStockOk))
          else
            ...lowStockItems.map((item) {
              final unitName = itemToUnitMap[item.id] ?? l10n.unknown;
              return ListTile(
                leading: const Icon(Icons.warning, color: Colors.orange),
                title: Text('${item.name} ($unitName)'),
                subtitle: Text(l10n.quantity(item.quantity, item.unit)),
              );
            }),
          const SizedBox(height: 24),

          Text(
            l10n.expiringSoon,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          if (expiringSoonItems.isEmpty)
            ListTile(title: Text(l10n.noExpiringSoon))
          else
            ...expiringSoonItems.map((item) {
              final unitName = itemToUnitMap[item.id] ?? l10n.unknown;
              return ListTile(
                leading: const Icon(Icons.schedule, color: Colors.redAccent),
                title: Text('${item.name} ($unitName)'),
                subtitle: Text(l10n.expiry(ProductUtils.formatDate(item.expiryDate))),
              );
            }),
          const SizedBox(height: 24),

          Text(
            l10n.daysLeftByCategory,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          ...(() {
            // 1. Soma quantidade total por produto
            final Map<String, double> quantidadePorProduto = {};
            for (final item in allItems.where((i) => i.productDefinitionId != null)) {
              quantidadePorProduto[item.productDefinitionId!] =
                  (quantidadePorProduto[item.productDefinitionId!] ?? 0) + item.quantity;
            }

            // 2. Agrupa por categoria
            final Map<String, double> totalQuantidadePorCategoria = {};
            final Map<String, double> totalConsumoPorCategoria = {};

            for (final product in productService.all) {
              final categoria = product.category ?? l10n.noCategory;
              final quantidadeTotal = quantidadePorProduto[product.id] ?? 0;
              final dailyUsage = product.dailyUsage ?? 0;

              totalQuantidadePorCategoria[categoria] =
                  (totalQuantidadePorCategoria[categoria] ?? 0) + quantidadeTotal;

              // Só soma o consumo se o produto tem quantidade > 0 em algum armazém
              if (quantidadeTotal > 0 && dailyUsage > 0) {
                totalConsumoPorCategoria[categoria] =
                    (totalConsumoPorCategoria[categoria] ?? 0) + dailyUsage;
              }
            }

            // Só mostra categorias com consumo > 0
            final categoriasComConsumo = totalQuantidadePorCategoria.keys
                .where((categoria) => (totalConsumoPorCategoria[categoria] ?? 0) > 0)
                .toList();

            if (categoriasComConsumo.isEmpty) {
              return [
                ListTile(title: Text(l10n.noStats)),
              ];
            }

            return categoriasComConsumo.map((categoria) {
              final totalQtd = totalQuantidadePorCategoria[categoria] ?? 0;
              final totalConsumo = totalConsumoPorCategoria[categoria] ?? 0;
              final diasRestantes = (totalConsumo > 0) ? (totalQtd / totalConsumo).floor() : null;

              return ListTile(
                leading: const Icon(Icons.category),
                title: Text(categoria),
                subtitle: diasRestantes != null
                    ? Text(l10n.daysLeft(diasRestantes))
                    : Text(l10n.noUsageData),
              );
            }).toList();
          })(),
        ],
      ),
    );
  }
}

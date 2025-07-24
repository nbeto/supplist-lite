import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/gen_l10n/app_localizations.dart';

import '../services/lists_service.dart';
import '../services/storage_unit_service.dart';
import '../services/product_definition_service.dart';
import '../screens/list_detail_screen.dart';
import '../screens/storage_unit_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final favoriteLists = context.watch<ListsService>().getFavoriteLists();
    final favoriteStorageUnits = context.watch<StorageUnitService>().getFavoriteUnits();
    final allItems = context.watch<StorageUnitService>().getAllItems();
    final productService = context.watch<ProductDefinitionService>();

    // NOVO: Produtos favoritos
    final favoriteProducts = productService.all.where((p) => p.favorite).toList();

    // Mapa de produtoId -> quantidade total em todos os armazéns
    final Map<String, double> favoriteProductQuantities = {};
    for (final product in favoriteProducts) {
      final items = allItems.where((item) => item.productDefinitionId == product.id);
      final total = items.fold<double>(0, (sum, item) => sum + item.quantity);
      if (total > 0) {
        favoriteProductQuantities[product.id] = total;
      }
    }

    // 1. Agrupa quantidades totais por produto
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

    final estatisticasCategoria = totalQuantidadePorCategoria.keys
        .where((categoria) => (totalConsumoPorCategoria[categoria] ?? 0) > 0)
        .map((categoria) {
      final totalQtd = totalQuantidadePorCategoria[categoria] ?? 0;
      final totalConsumo = totalConsumoPorCategoria[categoria] ?? 0;
      final diasRestantes = (totalConsumo > 0) ? (totalQtd / totalConsumo).floor() : null;

      return Card(
        color: Colors.grey[100],
        child: ListTile(
          leading: const Icon(Icons.category),
          title: Text(categoria),
          subtitle: diasRestantes != null
              ? Text(l10n.daysLeft(diasRestantes))
              : Text(l10n.noUsageData),
        ),
      );
    }).toList();

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título da página no corpo
            Center(
              child: Text(
                l10n.home,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 24),

            // 1. DAYS LEFT BY CATEGORY NO TOPO
            Text(
              l10n.daysLeftByCategory,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (estatisticasCategoria.isEmpty)
              Text(l10n.noStats)
            else
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 3.5,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                children: estatisticasCategoria,
              ),
            const SizedBox(height: 24),

            // 2. FAVORITE PRODUCTS
            Text(
              l10n.favoriteProducts,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (favoriteProducts.isEmpty)
              Text(
                l10n.noFavoriteProducts, // Adiciona esta chave no .arb
              )
            else if (favoriteProductQuantities.isEmpty)
              Text(
                l10n.noFavoriteProductsInStorage, // Adiciona esta chave no .arb
              )
            else
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 2.8,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                children: favoriteProducts
                    .where((p) => favoriteProductQuantities.containsKey(p.id))
                    .map((product) {
                  final total = favoriteProductQuantities[product.id]!;
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.star, color: Colors.amber),
                      title: Text(product.name),
                      subtitle: Text('${l10n.totalQuantity}: $total ${product.defaultUnit}'),
                    ),
                  );
                }).toList(),
              ),
            const SizedBox(height: 24),

            Text(
              l10n.favoriteLists,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (favoriteLists.isEmpty)
              Text(l10n.noFavoriteLists)
            else
              ...favoriteLists.map((list) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.list_alt),
                      title: Text(list.name),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ListDetailScreen(listId: list.id),
                          ),
                        );
                      },
                    ),
                  )),

            const SizedBox(height: 24),

            Text(
              l10n.favoriteStorageUnits,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (favoriteStorageUnits.isEmpty)
              Text(l10n.noFavoriteStorageUnits)
            else
              ...favoriteStorageUnits.map((unit) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.inventory),
                      title: Text(unit.name),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => StorageUnitDetailScreen(unitId: unit.id),
                          ),
                        );
                      },
                    ),
                  )),
          ],
        ),
      ),
    );
  }
}

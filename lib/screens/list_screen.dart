import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/list_model.dart';
import '../services/lists_service.dart';
import '../screens/list_detail_screen.dart';
import '../l10n/gen_l10n/app_localizations.dart';

class ListScreen extends StatefulWidget {
  const ListScreen({super.key});

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  late ListsService _listsService;

  @override
  void initState() {
    super.initState();
    _listsService = context.read<ListsService>();
  }

  void _createNewList() {
    final l10n = AppLocalizations.of(context)!;
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text(l10n.newList),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: l10n.listExampleHint),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                Navigator.of(dialogContext).pop();

                await Future.delayed(const Duration(milliseconds: 50));
                if (!mounted) return;

                await _listsService.createList(name);
              }
            },
            child: Text(l10n.create),
          ),
        ],
      ),
    );
  }

  void _openList(BuildContext context, ListModel listModel) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ListDetailScreen(listId: listModel.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final allLists = context.watch<ListsService>().allLists;

    // Ordena: favoritos primeiro, depois por nome
    final sortedLists = [...allLists]
      ..sort((a, b) {
        if (a.favorite == b.favorite) {
          return a.name.compareTo(b.name);
        }
        return b.favorite ? 1 : -1;
      });

    return Scaffold(
      body: sortedLists.isEmpty
          ? Padding(
              padding: const EdgeInsets.only(top: 32),
              child: Column(
                children: [
                  // Título da página no corpo
                  Text(
                    l10n.lists,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Center(child: Text(l10n.noLists)),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.only(top: 16, left: 8, right: 8, bottom: 80),
              itemCount: sortedLists.length + 1,
              separatorBuilder: (context, index) => index == 0 ? const SizedBox() : const Divider(),
              itemBuilder: (context, index) {
                if (index == 0) {
                  // Título da página como primeiro item da lista
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Center(
                      child: Text(
                        l10n.lists,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                }
                final list = sortedLists[index - 1];
                return ListTile(
                  leading: const Icon(Icons.list_alt),
                  title: Text(list.name),
                  subtitle: Text(l10n.itemsCount(list.items.length)),
                  onTap: () => _openList(context, list),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          list.favorite ? Icons.star : Icons.star_border,
                          color: list.favorite ? Colors.amber : null,
                        ),
                        onPressed: () {
                          context.read<ListsService>().toggleListFavorite(list.id);
                        },
                      ),
                      PopupMenuButton<String>(
                        onSelected: (value) async {
                          if (value == 'delete') {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: Text(l10n.deleteListTitle),
                                content: Text(l10n.deleteListConfirm(list.name)),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(ctx).pop(false),
                                    child: Text(l10n.cancel),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.of(ctx).pop(true),
                                    child: Text(l10n.delete),
                                  ),
                                ],
                              ),
                            );

                            if (confirmed == true) {
                              final service = context.read<ListsService>();
                              await service.deleteList(list.id);
                            }
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem<String>(
                            value: 'delete',
                            child: Text(l10n.deleteListMenu),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createNewList,
        tooltip: l10n.createNewListTooltip,
        icon: const Icon(Icons.add),
        label: Text(l10n.newList),
      ),
    );
  }
}

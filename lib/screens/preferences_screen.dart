import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/preferences_service.dart';
import '../l10n/gen_l10n/app_localizations.dart';

class PreferencesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final prefs = context.watch<PreferencesService>();
    final l10n = AppLocalizations.of(context)!;
    final catController = TextEditingController();
    final unitController = TextEditingController();

    // Lista de idiomas disponíveis
    final languages = {
      'en': l10n.english,
      'pt': l10n.portuguese,
    };

    void _showManageDialog(BuildContext context, List<String> items, void Function(String) onRemove, String title) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.manage(title)),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: items.map((item) => ListTile(
                title: Text(item),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    onRemove(item);
                    Navigator.of(ctx).pop();
                  },
                ),
              )).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(l10n.close),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Text(
              l10n.preferences,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 24),
          // Seletor de idioma
          Row(
            children: [
              Text(l10n.language, style: const TextStyle(fontWeight: FontWeight.bold)),
              const Spacer(),
              DropdownButton<String>(
                value: prefs.language ?? 'en',
                items: languages.entries
                    .map((entry) => DropdownMenuItem(
                          value: entry.key,
                          child: Text(entry.value),
                        ))
                    .toList(),
                onChanged: (lang) {
                  if (lang != null) {
                    prefs.setLanguage(lang);
                  }
                },
              ),
            ],
          ),
          const Divider(),
          Row(
            children: [
              Text(l10n.categories, style: const TextStyle(fontWeight: FontWeight.bold)),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.settings),
                tooltip: l10n.manageCategories,
                onPressed: () => _showManageDialog(
                  context,
                  prefs.categories,
                  prefs.removeCategory,
                  l10n.categories,
                ),
              ),
            ],
          ),
          Wrap(
            spacing: 8,
            children: prefs.categories.map((cat) => Chip(label: Text(cat))).toList(),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: catController,
                  decoration: InputDecoration(hintText: l10n.newCategory),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  if (catController.text.trim().isNotEmpty) {
                    prefs.addCategory(catController.text.trim());
                    catController.clear();
                  }
                },
              ),
            ],
          ),
          const Divider(),
          Row(
            children: [
              Text(l10n.units, style: const TextStyle(fontWeight: FontWeight.bold)),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.settings),
                tooltip: l10n.manageUnits,
                onPressed: () => _showManageDialog(
                  context,
                  prefs.units,
                  prefs.removeUnit,
                  l10n.units,
                ),
              ),
            ],
          ),
          Wrap(
            spacing: 8,
            children: prefs.units.map((unit) => Chip(label: Text(unit))).toList(),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: unitController,
                  decoration: InputDecoration(hintText: l10n.newUnit),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  if (unitController.text.trim().isNotEmpty) {
                    prefs.addUnit(unitController.text.trim());
                    unitController.clear();
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

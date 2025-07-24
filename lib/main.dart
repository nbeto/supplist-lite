import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/gen_l10n/app_localizations.dart';

import 'models/storage_unit.dart';
import 'models/storage_item.dart';
import 'models/list_model.dart';
import 'models/list_item.dart';
import 'models/product_definition.dart';

import 'screens/home_screen.dart';
import 'screens/list_screen.dart';
import 'screens/storage_screen.dart';
import 'screens/summary_screen.dart';
import 'screens/product_management_screen.dart';
import 'screens/preferences_screen.dart';
import 'screens/about_screen.dart';

import 'services/storage_unit_service.dart';
import 'services/lists_service.dart';
import 'services/product_definition_service.dart';
import 'services/preferences_service.dart';

import 'repositories/product_definition_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  Hive.registerAdapter(StorageItemAdapter());
  Hive.registerAdapter(StorageUnitAdapter());
  Hive.registerAdapter(ListItemAdapter());
  Hive.registerAdapter(ListModelAdapter());
  Hive.registerAdapter(ProductDefinitionAdapter());

  final repository = ProductDefinitionRepository();
  final productDefinitionService = ProductDefinitionService(repository);
  await productDefinitionService.init();

  final storageUnitService = StorageUnitService(productDefinitionService);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<StorageUnitService>(
          create: (_) => storageUnitService..init(),
        ),
        ChangeNotifierProvider<ListsService>(
          create: (_) => ListsService()..init(),
        ),
        ChangeNotifierProvider<ProductDefinitionService>.value(
          value: productDefinitionService,
        ),
        ChangeNotifierProvider<PreferencesService>(
          create: (_) => PreferencesService()..init(),
        ),
      ],
      child: const SupplistApp(),
    ),
  );
}

class SupplistApp extends StatelessWidget {
  const SupplistApp({super.key});

  @override
  Widget build(BuildContext context) {
    final prefs = Provider.of<PreferencesService>(context);
    Locale? appLocale;
    if (prefs.language != null) {
      appLocale = Locale(prefs.language!);
    }

    return MaterialApp(
      title: 'Supplist',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      locale: appLocale,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('pt'),
      ],
      home: const SupplistHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SupplistHomePage extends StatefulWidget {
  const SupplistHomePage({super.key});

  @override
  State<SupplistHomePage> createState() => _SupplistHomePageState();
}

class _SupplistHomePageState extends State<SupplistHomePage> {
  int _selectedIndex = 0;
  final List<GlobalKey<NavigatorState>> _navigatorKeys = List.generate(7, (_) => GlobalKey<NavigatorState>());

  void _onItemTapped(int index) {
    if (_selectedIndex == index) {
      _navigatorKeys[index].currentState!.popUntil((route) => route.isFirst);
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  Widget _buildOffstageNavigator(int index, Widget screen) {
    return Offstage(
      offstage: _selectedIndex != index,
      child: Navigator(
        key: _navigatorKeys[index],
        onGenerateRoute: (settings) => MaterialPageRoute(
          builder: (_) => screen,
        ),
      ),
    );
  }

  void _openDrawerItem(String item) {
    Navigator.pop(context); // Fecha o drawer

    if (item == 'Produtos') {
      setState(() {
        _selectedIndex = 4;
      });
    } else if (item == 'Preferências') {
      setState(() {
        _selectedIndex = 5;
      });
    } else if (item == 'Sobre') {
      setState(() {
        _selectedIndex = 6;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Abrir: $item')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, popResult) async {
        if (!didPop) {
          final currentNavigator = _navigatorKeys[_selectedIndex].currentState;
          if (currentNavigator != null && currentNavigator.canPop()) {
            currentNavigator.pop();
          }
        }
      },
      child: Scaffold(
        drawer: Drawer(
          child: ListView(
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(color: Colors.blue),
                child: Text(l10n.menu, style: const TextStyle(color: Colors.white, fontSize: 24)),
              ),
              ListTile(
                leading: const Icon(Icons.category),
                title: Text(l10n.products),
                onTap: () => _openDrawerItem('Produtos'),
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: Text(l10n.preferences),
                onTap: () => _openDrawerItem('Preferências'),
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(l10n.about),
                onTap: () => _openDrawerItem('Sobre'),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            AppBar(
              title: Text(l10n.appTitle),
              leading: Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Image.asset(
                    'assets/app_icon.png',
                    height: 32,
                    width: 32,
                  ),
                ),
              ],
            ),
            const Divider(height: 1, thickness: 1, color: Color(0xFFDDDDDD)),
            Expanded(
              child: Stack(
                children: [
                  _buildOffstageNavigator(0, const HomeScreen()),
                  _buildOffstageNavigator(1, const ListScreen()),
                  _buildOffstageNavigator(2, const StorageScreen()),
                  _buildOffstageNavigator(3, const SummaryScreen()),
                  _buildOffstageNavigator(4, const ProductManagementScreen()),
                  _buildOffstageNavigator(5, PreferencesScreen()),
                  _buildOffstageNavigator(6, const AboutScreen()), // Adiciona este
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex > 3 ? 0 : _selectedIndex,
          onTap: _onItemTapped,
          items: [
            BottomNavigationBarItem(icon: const Icon(Icons.home), label: l10n.home),
            BottomNavigationBarItem(icon: const Icon(Icons.list_alt), label: l10n.lists),
            BottomNavigationBarItem(icon: const Icon(Icons.inventory_2), label: l10n.storage),
            BottomNavigationBarItem(icon: const Icon(Icons.notifications), label: l10n.alerts),
          ],
        ),
      ),
    );
  }
}

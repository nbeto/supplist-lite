# 📦 Supplist Lite

**Supplist Lite** is the offline version of Supplist, a mobile app for managing household stock. With Supplist Lite, you can organize your pantry, shopping lists, and consumption planning without needing an internet connection. Developed with Flutter, this app is cross-platform (Android, iOS, and Web). The full version of Supplist will offer cloud sync and advanced features.

## ✅ Lite Version (Supplist Lite)
- 📦 Manage multiple storage units (Pantry, Warehouse, Kits...)
- 📝 Create and organize multiple lists
- 🔔 Low stock alerts and products nearing expiration
- 📆 Estimate remaining days of consumption by category
- 💡 Intuitive interface with bottom navigation (Home, Storage, Lists, Alerts)

## 🌐 Full Version (Supplist)
- 👨‍👩‍👧‍👦 User sharing (e.g., family)
- ☁️ Cloud sync (Firebase)
- 📷 Barcode scanning
- 🔁 Automatic backup

## 🛠️ Technologies
- [Flutter](https://flutter.dev/) & [Dart](https://dart.dev/) — cross-platform development
- [Hive](https://docs.hivedb.dev/) — lightweight and fast local database for offline storage
- [Provider](https://pub.dev/packages/provider) — state management
- [intl](https://pub.dev/packages/intl) — internationalization and localization
- [uuid](https://pub.dev/packages/uuid) — unique ID generation for models
- [Material Design](https://m3.material.io/) — modern UI components
- Compatible with **Android**, **iOS**, **Web**, and **Desktop**

## 📁 Project Structure
lib/
├── main.dart
├── screens/                # App screens (UI pages)
│   ├── home_screen.dart
│   ├── storage_screen.dart
│   ├── list_screen.dart
│   ├── summary_screen.dart
│   ├── product_management_screen.dart
│   ├── about_screen.dart
│   └── ...
├── models/                 # Data models (Hive objects, domain classes)
│   ├── storage_unit.dart
│   ├── storage_item.dart
│   ├── list_model.dart
│   ├── list_item.dart
│   └── product_definition.dart
├── services/               # Business logic and state management
│   ├── storage_unit_service.dart
│   ├── lists_service.dart
│   ├── product_definition_service.dart
│   ├── preferences_service.dart
│   └── product_utils.dart
├── repositories/           # Data persistence (Hive, etc.)
│   ├── product_definition_repository.dart
│   ├── storage_unit_repository.dart
│   └── lists_repository.dart
├── l10n/                   # Localization files (.arb, generated code)
│   ├── gen_l10n/
│   │   └── ...
│   ├── app_en.arb
│   └── app_pt.arb
└── LICENCE
└── README.md

## 🔗 Repository
https://github.com/nbeto/supplist-lite

## 📄 License
Copyright 2025 Supplist.  
All rights reserved.

This code is provided strictly for **personal** and **academic** use only.

The following actions are strictly prohibited:
- Copying, modifying, or distributing any part of this code;
- Using this code for **commercial purposes**, including paid apps, services, or products with profit intent;
- Creating competing or derivative software based on this code.

Any use outside these terms requires **prior written permission** from the author.

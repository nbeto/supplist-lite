import 'package:intl/intl.dart';
import '../models/storage_item.dart';

class ProductUtils {
  static bool isLowStock(StorageItem item) {
    return item.minQuantity != null && item.quantity < item.minQuantity!;
  }

  static bool isExpiringSoon(StorageItem item, {int daysBefore = 3}) {
    if (item.expiryDate == null) return false;
    final now = DateTime.now();
    final threshold = now.add(Duration(days: daysBefore));
    return item.expiryDate!.isBefore(threshold);
  }

  static int? daysUntilExpiry(StorageItem item) {
    if (item.expiryDate == null) return null;
    return item.expiryDate!.difference(DateTime.now()).inDays;
  }

  static int? estimateDaysRemaining(StorageItem item, double dailyUsage) {
    if (dailyUsage <= 0) return null;
    return (item.quantity / dailyUsage).floor();
  }

  static String formatDate(DateTime? date) {
    if (date == null) return 'Sem validade';
    return DateFormat('yyyy-MM-dd').format(date);
  }

  static List<StorageItem> filterLowStock(List<StorageItem> items) {
    return items.where((item) =>
      item.minQuantity != null && item.quantity <= item.minQuantity!
    ).toList();
  }

  static List<StorageItem> filterExpiringSoon(List<StorageItem> items, {int days = 7}) {
    final now = DateTime.now();
    final threshold = now.add(Duration(days: days));
    return items.where((item) =>
        item.expiryDate != null &&
        item.expiryDate!.isAfter(now) &&
        item.expiryDate!.isBefore(threshold)).toList();
  }
}
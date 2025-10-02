import 'package:flutter_pda_broadcast/flutter_pda_broadcast.dart';

/// Modèle pour gérer l'historique des scans
class ScanHistory {
  final List<ScanData> scans;

  ScanHistory({required this.scans});

  /// Retourne les scans d'aujourd'hui
  List<ScanData> get todayScans {
    final today = DateTime.now();
    return scans.where((scan) {
      return scan.timestamp.year == today.year &&
          scan.timestamp.month == today.month &&
          scan.timestamp.day == today.day;
    }).toList();
  }

  /// Retourne les scans de cette semaine
  List<ScanData> get weekScans {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    return scans.where((scan) {
      return scan.timestamp.isAfter(weekStart);
    }).toList();
  }

  /// Filtre les scans par type de code-barres
  List<ScanData> scansByType(String type) {
    return scans.where((scan) => scan.type == type).toList();
  }

  /// Recherche dans les codes-barres
  List<ScanData> search(String query) {
    final lowerQuery = query.toLowerCase();
    return scans.where((scan) {
      return scan.barcode.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Statistiques des types de codes-barres
  Map<String, int> get typeStats {
    final stats = <String, int>{};
    for (final scan in scans) {
      stats[scan.type] = (stats[scan.type] ?? 0) + 1;
    }
    return stats;
  }

  /// Nombre total de scans
  int get totalScans => scans.length;

  /// Nombre de scans aujourd'hui
  int get todayCount => todayScans.length;

  /// Nombre de scans cette semaine
  int get weekCount => weekScans.length;
}

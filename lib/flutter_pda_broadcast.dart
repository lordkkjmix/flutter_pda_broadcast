/// Flutter plugin pour scanner KingTop KT-KP36 ou autres modèles similaires via Broadcast natif.
///
/// Supporte le mode Broadcast avec configuration exacte:
/// - Action: com.kte.scan.result
/// - Extras: code, type, code_sro
///
/// Exemple d'utilisation:
/// ```dart
/// final scanner = FlutterPdaBroadcast();
/// await scanner.initialize();
///
/// scanner.scanStream.listen((scan) {
///   print('Code scanné: ${scan.barcode}');
/// });
/// ```
library;

export 'src/flutter_pda_broadcast.dart';
export 'src/scan_data.dart';
export 'src/scanner_config.dart';

/// Configuration du scanner KingTop
class ScannerConfig {
  /// Action broadcast (par défaut: com.kte.scan.result)
  final String broadcastAction;
  
  /// Nom de l'extra pour le code-barres (par défaut: code)
  final String barcodeExtra;
  
  /// Nom de l'extra pour le type (par défaut: type)
  final String typeExtra;
  
  /// Nom de l'extra pour le code original (par défaut: code_sro)
  final String originalExtra;
  
  /// Activer les logs de debug
  final bool enableDebugLogs;

  const ScannerConfig({
    this.broadcastAction = 'com.kte.scan.result',
    this.barcodeExtra = 'code',
    this.typeExtra = 'type',
    this.originalExtra = 'code_sro',
    this.enableDebugLogs = false,
  });

  /// Configuration par défaut pour KingTop KT-KP36
  static const ScannerConfig kingtopKP36 = ScannerConfig();

  /// Configuration personnalisée
  ScannerConfig copyWith({
    String? broadcastAction,
    String? barcodeExtra,
    String? typeExtra,
    String? originalExtra,
    bool? enableDebugLogs,
  }) {
    return ScannerConfig(
      broadcastAction: broadcastAction ?? this.broadcastAction,
      barcodeExtra: barcodeExtra ?? this.barcodeExtra,
      typeExtra: typeExtra ?? this.typeExtra,
      originalExtra: originalExtra ?? this.originalExtra,
      enableDebugLogs: enableDebugLogs ?? this.enableDebugLogs,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'broadcastAction': broadcastAction,
      'barcodeExtra': barcodeExtra,
      'typeExtra': typeExtra,
      'originalExtra': originalExtra,
      'enableDebugLogs': enableDebugLogs,
    };
  }
}
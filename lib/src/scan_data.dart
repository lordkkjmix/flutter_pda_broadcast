/// Représente les données d'un scan de code-barres
class ScanData {
  /// Le code-barres scanné
  final String barcode;
  
  /// Le type de code-barres (EAN13, QR, CODE128, etc.)
  final String type;
  
  /// Le code-barres original avant traitement (optionnel)
  final String? originalBarcode;
  
  /// La date et heure du scan
  final DateTime timestamp;

  const ScanData({
    required this.barcode,
    required this.type,
    this.originalBarcode,
    required this.timestamp,
  });

  /// Crée un [ScanData] à partir d'une Map
  factory ScanData.fromMap(Map<String, dynamic> map) {
    return ScanData(
      barcode: map['barcode'] as String? ?? '',
      type: map['type'] as String? ?? 'UNKNOWN',
      originalBarcode: map['original'] as String?,
      timestamp: map['timestamp'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int)
          : DateTime.now(),
    );
  }

  /// Convertit le [ScanData] en Map
  Map<String, dynamic> toMap() {
    return {
      'barcode': barcode,
      'type': type,
      if (originalBarcode != null) 'original': originalBarcode,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  /// Convertit le [ScanData] en JSON
  Map<String, dynamic> toJson() => toMap();

  @override
  String toString() {
    return 'ScanData(barcode: $barcode, type: $type, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ScanData &&
        other.barcode == barcode &&
        other.type == type &&
        other.originalBarcode == originalBarcode &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return Object.hash(barcode, type, originalBarcode, timestamp);
  }

  /// Copie le [ScanData] avec de nouvelles valeurs
  ScanData copyWith({
    String? barcode,
    String? type,
    String? originalBarcode,
    DateTime? timestamp,
  }) {
    return ScanData(
      barcode: barcode ?? this.barcode,
      type: type ?? this.type,
      originalBarcode: originalBarcode ?? this.originalBarcode,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
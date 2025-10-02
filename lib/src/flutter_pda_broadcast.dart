import 'dart:async';
import 'package:flutter/services.dart';
import 'scan_data.dart';
import 'scanner_config.dart';

/// Plugin principal pour le scanner KingTop KT-KP36
class FlutterPdaBroadcast {
  static const MethodChannel _channel = MethodChannel('flutter_pda_broadcast');
  static const EventChannel _eventChannel = EventChannel('flutter_pda_broadcast_events');

  final ScannerConfig config;
  final _scanController = StreamController<ScanData>.broadcast();
  StreamSubscription? _subscription;
  bool _isInitialized = false;

  /// Stream pour écouter les scans
  Stream<ScanData> get scanStream => _scanController.stream;

  /// Indique si le scanner est initialisé
  bool get isInitialized => _isInitialized;

  FlutterPdaBroadcast({this.config = ScannerConfig.kingtopKP36});

  /// Initialise le scanner
  /// 
  /// Lance l'écoute des broadcasts et configure le scanner.
  /// Doit être appelé avant d'utiliser le scanner.
  /// 
  /// Exemple:
  /// ```dart
  /// final scanner = FlutterPdaBroadcast();
  /// await scanner.initialize();
  /// ```
  Future<void> initialize() async {
    if (_isInitialized) {
      _log('Scanner déjà initialisé');
      return;
    }

    try {
      // Envoyer la configuration au plugin natif
      await _channel.invokeMethod('configure', config.toMap());

      // Écouter les événements du scanner
      _subscription = _eventChannel.receiveBroadcastStream().listen(
        (dynamic event) {
          if (event is Map) {
            try {
              final scanData = ScanData.fromMap(Map<String, dynamic>.from(event));
              _log('Scan reçu: ${scanData.barcode}');
              _scanController.add(scanData);
            } catch (e) {
              _logError('Erreur parsing scan: $e');
            }
          }
        },
        onError: (error) {
          _logError('Erreur stream: $error');
        },
      );

      _isInitialized = true;
      _log('Scanner initialisé avec succès');
    } catch (e) {
      _logError('Erreur initialisation: $e');
      rethrow;
    }
  }

  /// Récupère les informations du PDA
  /// 
  /// Retourne un Map contenant:
  /// - manufacturer: Fabricant
  /// - model: Modèle
  /// - broadcastAction: Action broadcast configurée
  /// - status: Statut du scanner
  Future<Map<String, dynamic>?> getPdaInfo() async {
    try {
      final result = await _channel.invokeMethod('getPdaInfo');
      return result != null ? Map<String, dynamic>.from(result) : null;
    } catch (e) {
      _logError('Erreur getPdaInfo: $e');
      return null;
    }
  }

  /// Active le scanner
  Future<void> enable() async {
    try {
      await _channel.invokeMethod('enableScanner');
      _log('Scanner activé');
    } catch (e) {
      _logError('Erreur enable: $e');
    }
  }

  /// Désactive le scanner
  Future<void> disable() async {
    try {
      await _channel.invokeMethod('disableScanner');
      _log('Scanner désactivé');
    } catch (e) {
      _logError('Erreur disable: $e');
    }
  }

  /// Démarre un scan programmé
  /// 
  /// Active le scanner pour environ 5 secondes.
  /// Équivalent à appuyer sur le bouton physique.
  Future<void> startScan() async {
    try {
      await _channel.invokeMethod('startScan');
      _log('Scan démarré');
    } catch (e) {
      _logError('Erreur startScan: $e');
    }
  }

  /// Arrête le scan en cours
  Future<void> stopScan() async {
    try {
      await _channel.invokeMethod('stopScan');
      _log('Scan arrêté');
    } catch (e) {
      _logError('Erreur stopScan: $e');
    }
  }

  /// Libère les ressources
  /// 
  /// À appeler dans le dispose() de votre widget.
  void dispose() {
    _subscription?.cancel();
    _scanController.close();
    _isInitialized = false;
    _log('Scanner disposed');
  }

  void _log(String message) {
    if (config.enableDebugLogs) {
      print('[KingtopScanner] $message');
    }
  }

  void _logError(String message) {
    print('[KingtopScanner] ERROR: $message');
  }
}

/// Exception personnalisée pour le scanner
class ScannerException implements Exception {
  final String message;
  final String? code;

  ScannerException(this.message, {this.code});

  @override
  String toString() => 'ScannerException: $message${code != null ? ' (code: $code)' : ''}';
}
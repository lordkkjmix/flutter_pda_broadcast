# flutter_pda_broadcast

[![pub package](https://img.shields.io/badge/pub-v1.0.0-blue)](https://pub.dev/packages/flutter_pda_broadcast)

Plugin Flutter pour scanner KingTop KT-KP36 avec support Broadcast Mode et iScan API.

## 📦 Fonctionnalités

- ✅ **Support KingTop KT-KP36** - Configuration optimisée
- ✅ **Mode Broadcast** - Utilise l'action `com.kte.scan.result`
- ✅ **Temps réel** - Stream pour écouter les scans
- ✅ **Type de code-barres** - Identifie EAN13, QR, Code128, etc.
- ✅ **Configuration flexible** - Personnalisable pour d'autres PDA
- ✅ **Logs de debug** - Pour faciliter le dépannage
- ✅ **Android uniquement** - Optimisé pour PDA

## 🚀 Installation

Ajoutez le package à votre `pubspec.yaml` :

```yaml
dependencies:
  kingtop_scanner:
    git:
      url: https://github.com/kingcortex/flutter_pda_broadcast.git
    # ou en local:
    # path: ../flutter_pda_broadcast
```

Puis exécutez :

```bash
flutter pub get
```

## 📱 Configuration du PDA

Dans les paramètres de votre KingTop KT-KP36 ou tout autres:

1. Ouvrir **Scanner Settings** (Paramètres Scanner)
2. Sélectionner **Output Broadcast Settings**
3. Vérifier la configuration :
   - **Broadcast mode**: `com.kte.scan.result`
   - **Barcode Extra**: `code`
   - **Barcode type Extra**: `type`
   - **Original barcode Extra**: `code_sro`

## 💡 Utilisation Simple

```dart
import 'package:kingtop_scanner/flutter_pda_broadcast.dart';

// Créer une instance
final scanner = FlutterPdaBroadcast();

// Initialiser
await scanner.initialize();

// Écouter les scans
scanner.scanStream.listen((scan) {
  print('Code scanné: ${scan.barcode}');
  print('Type: ${scan.type}');
  print('Heure: ${scan.timestamp}');
});

// Nettoyer (dans dispose)
scanner.dispose();
```

## 🎯 Exemple Complet

```dart
class ScannerPage extends StatefulWidget {
  @override
  _ScannerPageState createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  final _scanner = KingtopScanner();
  final List<ScanData> _scans = [];

  @override
  void initState() {
    super.initState();
    _initScanner();
  }

  Future<void> _initScanner() async {
    await _scanner.initialize();
    
    _scanner.scanStream.listen((scan) {
      setState(() {
        _scans.add(scan);
      });
      
      // Feedback haptique
      HapticFeedback.mediumImpact();
    });
  }

  @override
  void dispose() {
    _scanner.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Scanner')),
      body: ListView.builder(
        itemCount: _scans.length,
        itemBuilder: (context, index) {
          final scan = _scans[index];
          return ListTile(
            title: Text(scan.barcode),
            subtitle: Text(scan.type),
          );
        },
      ),
    );
  }
}
```

## ⚙️ Configuration Avancée

### Activer les logs de debug

```dart
final scanner = FlutterPdaBroadcast(
  config: ScannerConfig(
    enableDebugLogs: true,
  ),
);
```

### Configuration personnalisée

```dart
final scanner = FlutterPdaBroadcast(
  config: ScannerConfig(
    broadcastAction: 'com.custom.scan',
    barcodeExtra: 'barcode',
    typeExtra: 'type',
    enableDebugLogs: true,
  ),
);
```

## 📊 Modèle de Données

### ScanData

```dart
class ScanData {
  final String barcode;           // Code-barres scanné
  final String type;              // Type (EAN13, QR, etc.)
  final String? originalBarcode;  // Code original (optionnel)
  final DateTime timestamp;       // Date et heure du scan
}
```

## 🔧 API Disponibles

### Méthodes Principales

```dart
// Initialiser le scanner
await scanner.initialize();

// Obtenir les infos du PDA
Map<String, dynamic>? info = await scanner.getPdaInfo();

// Démarrer un scan programmé
await scanner.startScan();

// Arrêter le scan
await scanner.stopScan();

// Activer/désactiver le scanner
await scanner.enable();
await scanner.disable();

// Nettoyer les ressources
scanner.dispose();
```

### Propriétés

```dart
// Stream des scans
Stream<ScanData> scanStream = scanner.scanStream;

// État d'initialisation
bool isInitialized = scanner.isInitialized;
```

## 🐛 Dépannage

### Aucun scan reçu

1. **Vérifier la configuration du PDA**
   - Assurez-vous que le mode Broadcast est activé
   - Vérifiez l'action : `com.kte.scan.result`

2. **Activer les logs**
   ```dart
   config: ScannerConfig(enableDebugLogs: true)
   ```

3. **Vérifier les logs Android**
   ```bash
   adb logcat | grep FlutterPdaBroadcast
   ```

### Tester manuellement

```bash
# Envoyer un broadcast de test via ADB
adb shell am broadcast -a com.kte.scan.result --es code "123456" --es type "EAN13"
```

Si le test fonctionne mais pas le scanner physique → Problème de configuration PDA

### App crash au démarrage

Vérifiez votre `build.gradle` :

```gradle
android {
    compileSdk 34
    defaultConfig {
        minSdk 21
        targetSdk 34
    }
}
```

## 📝 Exemples de Types de Codes

Le scanner KT-KP36 supporte :

- **1D** : EAN13, EAN8, UPC-A, UPC-E, Code39, Code93, Code128, Interleaved 2of5
- **2D** : QR Code, DataMatrix, PDF417, Aztec

Le champ `type` contient le nom du type détecté.

## 🔒 Permissions

Le package gère automatiquement les permissions nécessaires :

```xml
<uses-permission android:name="android.permission.VIBRATE"/>
```

Aucune permission supplémentaire requise !

## 🌐 Compatibilité

- **Flutter** : >=3.0.0
- **Dart** : >=3.0.0
- **Android** : API 21+ (Android 5.0+)
- **PDA** : KingTop KT-KP36 (et compatibles iScan API)

## 🤝 Contribution

Les contributions sont les bienvenues !

1. Fork le projet
2. Créer une branche (`git checkout -b feature/amelioration`)
3. Commit vos changements (`git commit -m 'Ajout fonctionnalité'`)
4. Push vers la branche (`git push origin feature/amelioration`)
5. Ouvrir une Pull Request

## 📄 Licence

MIT License - voir le fichier [LICENSE](LICENSE) pour plus de détails.

## 👤 Auteur

Votre Nom - [@votre_twitter](https://twitter.com/votre_twitter)

Projet : [https://github.com/kingcortex/flutter_pda_broadcast](https://github.com/kingcortex/flutter_pda_broadcast)

## 🙏 Remerciements

- KingTop pour le PDA KT-KP36
- La communauté Flutter

## 📞 Support

- **Issues** : [GitHub Issues](https://github.com/kingcortex/flutter_pda_broadcast/issues)
- **Email** : souleydiom@gmail.com.com
- **Documentation** : [Wiki](https://github.com/kingcortex/flutter_pda_broadcast/wiki)

---

**Fait avec ❤️ pour la communauté Flutter**
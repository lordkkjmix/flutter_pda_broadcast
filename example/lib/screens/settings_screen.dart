import 'package:flutter/material.dart';
import 'package:flutter_pda_broadcast/flutter_pda_broadcast.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late FlutterPdaBroadcast _scanner;
  Map<String, dynamic>? _pdaInfo;
  bool _isLoading = false;

  // Paramètres de l'application
  bool _enableVibration = true;
  bool _enableSound = true;
  bool _enableAutoStart = false;
  bool _darkMode = false;
  String _selectedScannerModel = 'KingTop KT-KP36';

  final List<String> _supportedModels = [
    'KingTop KT-KP36',
    'Scanner générique',
    'Autre',
  ];

  @override
  void initState() {
    super.initState();
    _scanner = FlutterPdaBroadcast();
    _loadPdaInfo();
    _loadSettings();
  }

  Future<void> _loadPdaInfo() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final info = await _scanner.getPdaInfo();
      setState(() {
        _pdaInfo = info;
      });
    } catch (e) {
      _showSnackBar(
        'Erreur lors du chargement des informations: $e',
        Colors.red,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _loadSettings() {
    // Ici, vous pourriez charger les paramètres depuis les SharedPreferences
    // Pour cet exemple, on utilise des valeurs par défaut
  }

  void _saveSettings() {
    // Ici, vous pourriez sauvegarder les paramètres dans les SharedPreferences
    _showSnackBar('Paramètres sauvegardés', Colors.green);
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveSettings,
            tooltip: 'Sauvegarder',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPdaInfoSection(),
                  const SizedBox(height: 24),
                  _buildScannerConfigSection(),
                  const SizedBox(height: 24),
                  _buildAppSettingsSection(),
                  const SizedBox(height: 24),
                  _buildAboutSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildPdaInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.smartphone, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Informations du PDA',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadPdaInfo,
                  tooltip: 'Actualiser',
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_pdaInfo != null) ...[
              _buildInfoRow(
                'Fabricant',
                _pdaInfo!['manufacturer'] ?? 'Inconnu',
              ),
              _buildInfoRow('Modèle', _pdaInfo!['model'] ?? 'Inconnu'),
              _buildInfoRow(
                'Action Broadcast',
                _pdaInfo!['broadcastAction'] ?? 'Non configuré',
              ),
              _buildInfoRow('Statut', _pdaInfo!['status'] ?? 'Inconnu'),
            ] else ...[
              const Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange),
                  SizedBox(width: 8),
                  Text('Informations non disponibles'),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildScannerConfigSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.settings, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Configuration du Scanner',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDropdownSetting(
              'Modèle de Scanner',
              _selectedScannerModel,
              _supportedModels,
              (value) {
                setState(() {
                  _selectedScannerModel = value ?? _supportedModels.first;
                });
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _testScanner,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Tester le Scanner'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppSettingsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.tune, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Paramètres de l\'Application',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSwitchSetting(
              'Vibration lors du scan',
              'Active la vibration à chaque scan réussi',
              _enableVibration,
              (value) {
                setState(() {
                  _enableVibration = value;
                });
              },
            ),
            _buildSwitchSetting(
              'Son lors du scan',
              'Joue un son à chaque scan réussi',
              _enableSound,
              (value) {
                setState(() {
                  _enableSound = value;
                });
              },
            ),
            _buildSwitchSetting(
              'Démarrage automatique',
              'Lance le scanner automatiquement à l\'ouverture',
              _enableAutoStart,
              (value) {
                setState(() {
                  _enableAutoStart = value;
                });
              },
            ),
            _buildSwitchSetting(
              'Mode sombre',
              'Utilise le thème sombre de l\'application',
              _darkMode,
              (value) {
                setState(() {
                  _darkMode = value;
                });
                // Ici, vous pourriez implémenter la logique de changement de thème
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'À propos',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Version de l\'app', '1.0.0'),
            _buildInfoRow('Version du plugin', '1.0.0'),
            _buildInfoRow('Développeur', 'Votre Nom'),
            const SizedBox(height: 16),
            const Text(
              'Cette application démontre l\'utilisation du plugin Flutter PDA Broadcast pour scanner des codes-barres avec des PDAs compatibles.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontFamily: 'monospace')),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchSetting(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[600])),
      trailing: Switch(value: value, onChanged: onChanged),
    );
  }

  Widget _buildDropdownSetting(
    String label,
    String value,
    List<String> options,
    ValueChanged<String?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: options
              .map(
                (option) =>
                    DropdownMenuItem(value: option, child: Text(option)),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Future<void> _testScanner() async {
    try {
      _showSnackBar('Test du scanner en cours...', Colors.blue);

      // Simuler un test du scanner
      await Future.delayed(const Duration(seconds: 2));

      // Ici, vous pourriez implémenter un véritable test du scanner
      // Par exemple, activer le scanner pendant quelques secondes

      _showSnackBar('Test du scanner réussi', Colors.green);
    } catch (e) {
      _showSnackBar('Erreur lors du test: $e', Colors.red);
    }
  }
}

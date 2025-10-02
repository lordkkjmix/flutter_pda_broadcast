import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pda_broadcast/flutter_pda_broadcast.dart';
import '../models/scan_history.dart';
import '../widgets/scan_card.dart';
import '../widgets/status_indicator.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class ScannerHomeScreen extends StatefulWidget {
  const ScannerHomeScreen({super.key});

  @override
  State<ScannerHomeScreen> createState() => _ScannerHomeScreenState();
}

class _ScannerHomeScreenState extends State<ScannerHomeScreen>
    with TickerProviderStateMixin {
  late FlutterPdaBroadcast _scanner;
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isInitialized = false;
  bool _isScanning = false;
  ScanData? _lastScan;
  Map<String, dynamic>? _pdaInfo;
  final List<ScanData> _scanHistory = [];
  int _totalScansToday = 0;

  @override
  void initState() {
    super.initState();
    _scanner = FlutterPdaBroadcast();
    _initializeAnimations();
    _initializeScanner();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
        );
  }

  Future<void> _initializeScanner() async {
    try {
      await _scanner.initialize();

      // Écouter les scans
      _scanner.scanStream.listen(_onScanReceived);

      // Récupérer les informations du PDA
      final pdaInfo = await _scanner.getPdaInfo();

      setState(() {
        _isInitialized = true;
        _pdaInfo = pdaInfo;
      });

      _showSnackBar('Scanner initialisé avec succès', Colors.green);
    } catch (e) {
      _showSnackBar('Erreur d\'initialisation: $e', Colors.red);
    }
  }

  void _onScanReceived(ScanData scan) {
    setState(() {
      _lastScan = scan;
      _scanHistory.insert(0, scan);
      _totalScansToday++;
    });

    // Animation de glissement pour le nouveau scan
    _slideController.reset();
    _slideController.forward();

    // Vibration et son
    HapticFeedback.mediumImpact();

    _showSnackBar('Code scanné: ${scan.barcode}', Colors.green);
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

  Future<void> _toggleScanner() async {
    if (_isScanning) {
      await _scanner.disable();
      _pulseController.stop();
    } else {
      await _scanner.enable();
      _pulseController.repeat(reverse: true);
    }

    setState(() {
      _isScanning = !_isScanning;
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    _scanner.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner PDA'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HistoryScreen(
                    scanHistory: ScanHistory(scans: _scanHistory),
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: _isInitialized ? _buildMainContent() : _buildLoadingScreen(),
    );
  }

  Widget _buildLoadingScreen() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Initialisation du scanner...'),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildStatusCard(),
          const SizedBox(height: 16),
          _buildScannerControls(),
          const SizedBox(height: 16),
          _buildStatsCards(),
          const SizedBox(height: 16),
          _buildLastScanCard(),
          const SizedBox(height: 16),
          _buildRecentScansSection(),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
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
                  'Statut du Scanner',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                StatusIndicator(isActive: _isInitialized, label: 'Initialisé'),
                const SizedBox(width: 16),
                StatusIndicator(isActive: _isScanning, label: 'Actif'),
              ],
            ),
            if (_pdaInfo != null) ...[
              const SizedBox(height: 12),
              Text(
                'Modèle: ${_pdaInfo!['model'] ?? 'Inconnu'}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                'Fabricant: ${_pdaInfo!['manufacturer'] ?? 'Inconnu'}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildScannerControls() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _isScanning ? _pulseAnimation.value : 1.0,
                  child: child,
                );
              },
              child: ElevatedButton.icon(
                onPressed: _toggleScanner,
                icon: Icon(_isScanning ? Icons.stop : Icons.play_arrow),
                label: Text(
                  _isScanning ? 'Arrêter le Scanner' : 'Démarrer le Scanner',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isScanning
                      ? Colors.red
                      : Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _isScanning
                  ? 'Scanner actif - Pointez vers un code-barres'
                  : 'Appuyez pour activer le scanner',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(
                    Icons.today,
                    color: Theme.of(context).primaryColor,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$_totalScansToday',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  Text(
                    'Scans aujourd\'hui',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(
                    Icons.history,
                    color: Theme.of(context).primaryColor,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_scanHistory.length}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  Text(
                    'Total scans',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLastScanCard() {
    if (_lastScan == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(Icons.qr_code_scanner, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'Aucun scan pour le moment',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
              ),
              Text(
                'Activez le scanner pour commencer',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      );
    }

    return SlideTransition(
      position: _slideAnimation,
      child: ScanCard(scan: _lastScan!, isLatest: true),
    );
  }

  Widget _buildRecentScansSection() {
    if (_scanHistory.length <= 1) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Scans récents',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HistoryScreen(
                      scanHistory: ScanHistory(scans: _scanHistory),
                    ),
                  ),
                );
              },
              child: const Text('Voir tout'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: (_scanHistory.length - 1).clamp(0, 3),
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ScanCard(scan: _scanHistory[index + 1]),
            );
          },
        ),
      ],
    );
  }
}

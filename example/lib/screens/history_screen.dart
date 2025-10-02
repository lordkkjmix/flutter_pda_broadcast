import 'package:flutter/material.dart';
import '../models/scan_history.dart';
import '../widgets/scan_card.dart';

class HistoryScreen extends StatefulWidget {
  final ScanHistory scanHistory;

  const HistoryScreen({super.key, required this.scanHistory});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _searchController;

  String _searchQuery = '';
  String _selectedType = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique des scans'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Tous', icon: Icon(Icons.all_inclusive)),
            Tab(text: 'Aujourd\'hui', icon: Icon(Icons.today)),
            Tab(text: 'Statistiques', icon: Icon(Icons.analytics)),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildSearchAndFilter(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAllScansTab(),
                _buildTodayScansTab(),
                _buildStatsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              labelText: 'Rechercher un code-barres',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('Filtrer par type: '),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButton<String>(
                  value: _selectedType.isEmpty ? null : _selectedType,
                  hint: const Text('Tous les types'),
                  isExpanded: true,
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value ?? '';
                    });
                  },
                  items: _getAvailableTypes()
                      .map(
                        (type) =>
                            DropdownMenuItem(value: type, child: Text(type)),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _clearFilters,
                icon: const Icon(Icons.clear),
                tooltip: 'Effacer les filtres',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAllScansTab() {
    final filteredScans = _getFilteredScans(widget.scanHistory.scans);

    if (filteredScans.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredScans.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: ScanCard(scan: filteredScans[index]),
        );
      },
    );
  }

  Widget _buildTodayScansTab() {
    final todayScans = _getFilteredScans(widget.scanHistory.todayScans);

    if (todayScans.isEmpty) {
      return _buildEmptyState('Aucun scan aujourd\'hui');
    }

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Text(
            '${todayScans.length} scan(s) aujourd\'hui',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: todayScans.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ScanCard(scan: todayScans[index]),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatsTab() {
    final stats = widget.scanHistory.typeStats;
    final totalScans = widget.scanHistory.totalScans;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatCard(
            'Total des scans',
            totalScans.toString(),
            Icons.qr_code_scanner,
            Colors.blue,
          ),
          const SizedBox(height: 16),
          _buildStatCard(
            'Scans aujourd\'hui',
            widget.scanHistory.todayCount.toString(),
            Icons.today,
            Colors.green,
          ),
          const SizedBox(height: 16),
          _buildStatCard(
            'Scans cette semaine',
            widget.scanHistory.weekCount.toString(),
            Icons.date_range,
            Colors.orange,
          ),
          const SizedBox(height: 24),
          Text(
            'Répartition par type',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (stats.isEmpty)
            const Text('Aucune donnée disponible')
          else
            ...stats.entries.map(
              (entry) => _buildTypeStatCard(
                entry.key,
                entry.value,
                totalScans > 0 ? (entry.value / totalScans * 100) : 0,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  ),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeStatCard(String type, int count, double percentage) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    type,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '$count scan(s) • ${percentage.toStringAsFixed(1)}%',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _getTypeColor(type).withOpacity(0.1),
              ),
              child: Center(
                child: Text(
                  count.toString(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _getTypeColor(type),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState([String? message]) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            message ?? 'Aucun scan trouvé',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
          ),
          if (_searchQuery.isNotEmpty || _selectedType.isNotEmpty) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: _clearFilters,
              child: const Text('Effacer les filtres'),
            ),
          ],
        ],
      ),
    );
  }

  List<String> _getAvailableTypes() {
    final types = widget.scanHistory.scans
        .map((scan) => scan.type)
        .toSet()
        .toList();
    types.sort();
    return types;
  }

  List<dynamic> _getFilteredScans(List<dynamic> scans) {
    return scans.where((scan) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          scan.barcode.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesType = _selectedType.isEmpty || scan.type == _selectedType;
      return matchesSearch && matchesType;
    }).toList();
  }

  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _selectedType = '';
      _searchController.clear();
    });
  }

  Color _getTypeColor(String type) {
    switch (type.toUpperCase()) {
      case 'EAN13':
      case 'EAN8':
        return Colors.blue;
      case 'QR_CODE':
      case 'QR':
        return Colors.green;
      case 'CODE128':
        return Colors.orange;
      case 'CODE39':
        return Colors.purple;
      case 'UPC_A':
      case 'UPC_E':
        return Colors.red;
      case 'DATA_MATRIX':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }
}
